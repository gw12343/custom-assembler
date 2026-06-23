.org $8000
; ==========================================================
; UART ECHO SERVER
; Baud Rate: 38,400 (Optimized for 100MHz FPGA)
; Function: Receives a character via RX and echoes it to TX
; ==========================================================
    mov sp, #$FFF           ; Setup stack
    mov bp, sp

    mov r8, #$6000          ; Output Port (TX is bit 0)
    mov r2, #$6001          ; Input Port (RX is bit 21)

    ; 1. Initialize TX line to Idle HIGH
    mov r1, #1
    mov [r8], r1

    ; 2. Wait for a few bit-times so the receiver recognizes Idle state
    call delay_1bit
    call delay_1bit

    ; 3. Pre-calculate RX Bitmask (Bit 21) into r3
    mov r3, #1
    mov r6, #21
mask_loop:
    shl r3
    dec r6
    cmp r6, #0
    jne mask_loop           ; r3 = 0x00200000

    mov r6, #$80            ; Bitmask for injecting bits during RX

; ==========================================================
; MAIN ECHO LOOP
; ==========================================================
echo_loop:
    call uart_rx_char       ; Wait for keystroke. Character returns in r5.
    call uart_tx_char       ; Send it right back out! (Reads from r5).
    jmp echo_loop           ; Loop forever

; ==========================================================
; Subroutine: uart_rx_char (38,400 Baud - Edge Synchronized)
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

    ; 8th bit sampled. Wait 0.5 bit times to ensure we approach the Stop Bit.
   ; mov r7, #$0051
   ; call delay

    ; Return immediately. If we return slightly too early, the rx_wait_idle
    ; loop at the top of this function will catch us and safely wait it out!
    pop r7
    pop r4
    pop r1
    ret

; ==========================================
; Subroutine: uart_tx_char (38,400 Baud)
; Sends ASCII character in r5 over UART.
; ==========================================
uart_tx_char:
    push r1
    push r2
    push r3
    push r6
    push r7
    push r8

    mov r8, #$6000          ; Output Port
    mov r1, r5              ; Copy char to r1 for shifting
    mov r6, #1              ; Bitmask for isolating LSB

    ; Send START BIT (LOW)
    mov r2, #0
    mov [r8], r2
    call delay_1bit

    ; Send 8 DATA BITS (LSB First)
    mov r3, #8
tx_bit_loop:
    mov r2, r1
    and r2, r6              ; Mask all but the lowest bit using r6
    mov [r8], r2
    call delay_1bit

    shr r1
    dec r3
    cmp r3, #0
    jne tx_bit_loop

    ; Send STOP BIT (HIGH)
    mov r2, #1
    mov [r8], r2
    call delay_1bit
    call delay_1bit         ; 2 Stop Bits for high-speed stability

    pop r8
    pop r7
    pop r6
    pop r3
    pop r2
    pop r1
    ret

; ==========================================
; Universal Delay Subroutines
; ==========================================
; Used by TX (Static 1-bit delay)
delay_1bit:
    push r7
    mov r7, #$00A3          ; 163 loops (1 bit time at 38400)
delay_1bit_loop:
    dec r7
    cmp r7, #0
    jne delay_1bit_loop
    pop r7
    ret

; Used by RX (Dynamic delay set by r7)
delay:
    dec r7
    cmp r7, #0
    jne delay
    ret

