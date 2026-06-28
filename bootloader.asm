; ==========================================================
; SYSTEM BOOTLOADER v1.1
; Resides at 0x0000.
; Baud Rate: 38400, 8-N-1 (100MHz)
; Protocol:
;   "XXXX=YYYYYYYY" -> Write 32-bit hex Y to 16-bit address X
;   "jXXXX"         -> Jump to 16-bit address X
; ==========================================================
    mov sp, #$FFF           ; Setup bootloader stack at the very top of memory
    mov bp, sp

    mov r8, #$6000          ; Output Port (Display / TX)
    mov r2, #$6001          ; Input Port (RX)

    ; Boot sequence visual indicator (Prints "B00T" to display)
    mov r1, #$B007
    mov [r8], r1

    ; Pre-calculate RX Bitmask (Bit 21) into r3
    mov r3, #1
    mov r6, #21
boot_mask_loop:
    shl r3
    dec r6
    cmp r6, #0
    jne boot_mask_loop      ; r3 = 0x00200000

    mov r6, #$80            ; Bitmask for RX data assembly

; ==========================================================
; STATE MACHINE: Idle Loop
; ==========================================================
state_idle:
    call uart_rx_char       ; Wait for first char

    ; Check for Jump Command ('j' is 106, 'J' is 74)
    cmp r5, #106
    je parse_jump
    cmp r5, #74
    je parse_jump

    ; First hex digit of an address
    mov r7, #4
    mov r4, #0
    jmp accumulate_address

; ==========================================================
; Parse Memory Write Command
; ==========================================================
accumulate_address:
    call ascii_to_hex

    shl r4
    shl r4
    shl r4
    shl r4
    or r4, r5

    dec r7
    cmp r7, #0
    je wait_for_equals

    call uart_rx_char
    jmp accumulate_address

wait_for_equals:
    call uart_rx_char
    cmp r5, #61             ; ASCII '='
    jne state_idle

    mov r7, #8
    push r4
    mov r4, #0

accumulate_data:
    call uart_rx_char
    call ascii_to_hex

    shl r4
    shl r4
    shl r4
    shl r4
    or r4, r5

    dec r7
    cmp r7, #0
    jne accumulate_data

    ; Execute the Write!
    pop r1
    mov [r1], r4

    ; Visual feedback
    mov [r8], r4

    jmp state_idle

; ==========================================================
; Parse Jump Command
; ==========================================================
parse_jump:
    mov r7, #4
    mov r4, #0

accumulate_jump:
    call uart_rx_char
    call ascii_to_hex

    shl r4
    shl r4
    shl r4
    shl r4
    or r4, r5

    dec r7
    cmp r7, #0
    jne accumulate_jump

    mov [r8], r4

    ; Execute Jump!
    jmp r4

; ==========================================================
; Subroutine: ascii_to_hex
; ==========================================================
ascii_to_hex:
    cmp r5, #48
    jl invalid_hex
    cmp r5, #57
    jg check_alpha_upper
    sub r5, #48
    ret

check_alpha_upper:
    cmp r5, #65
    jl invalid_hex
    cmp r5, #70
    jg check_alpha_lower
    sub r5, #55
    ret

check_alpha_lower:
    cmp r5, #97
    jl invalid_hex
    cmp r5, #102
    jg invalid_hex
    sub r5, #87
    ret

invalid_hex:
    mov r5, #0
    ret

; ==========================================================
; Subroutine: uart_rx_char (38,400 Baud)
; ==========================================================
uart_rx_char:
    push r1
    push r4
    push r7

rx_wait_idle:
    mov r1, [r2]            ; Read input port
    and r1, r3              ; Isolate bit 21 (UART RX)
    cmp r1, #0              ; 0 means the line is LOW
    je rx_wait_idle         ; CRITICAL FIX: Block here until the line goes HIGH!
                            ; This absorbs clock drift and guarantees we are in the Stop Bit.

rx_wait_start:
    mov r1, [r2]            ; Read input port
    and r1, r3              ; Isolate bit 21 (UART RX)
    cmp r1, #0              ; Start bit is LOW
    jne rx_wait_start       ; Block until line drops to LOW (The true Start Bit edge)

    ; Detected Start Bit. Wait 1.5 bit times.
    mov r7, #$00F4          ; 244 loops (1.5 bit times at 38400)
    call delay

    mov r4, #8              ; 8 bits to read
    mov r5, #0              ; Data accumulator

rx_read_bit:
    shr r5                  ; Shift right (LSB first)

    mov r1, [r2]            ; Read port
    and r1, r3              ; Isolate RX
    cmp r1, #0
    je bit_is_zero

    or r5, r6               ; Inject 1 at highest bit ($80)

bit_is_zero:
    mov r7, #$00A3          ; Wait 1 bit time (163 loops for 38400)
    call delay

    dec r4
    cmp r4, #0
    jne rx_read_bit


    pop r7
    pop r4
    pop r1
    ret

; ==========================================
; Delay Subroutine
; ==========================================
delay:
    dec r7
    cmp r7, #0
    jne delay
    ret