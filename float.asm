.org $8000
    mov sp, #$fff           ; Setup stack
    mov bp, #$fff           ; Initialize base pointer to match stack bottom
    mov r8, #$6000          ; Output Port

    call init_uart
    call clear_screen

    ; Load Float A directly
    mov r1, myconst
    ; Load Float B directly
    mov r2, myconst2

    ;call fadd               ; Call Floating-Point Add (Arguments in r1, r2)

    ;call print_float_dec    ; Print the 32-bit float in r1 as Decimal ASCII


    mov r6, #5
    mov r7, myconst ; // float num
    lbl:
        mov r1, r6
        call print_uint

        call send_newline

        mov r1, r7
        call print_float_dec

        call send_newline

        mov r2, myconst2
        call fadd
        mov r7, r1

        dec r6
        cmp r6, #0
        jl donel_loop
        jmp lbl
    donel_loop:
    hlt                     ; Terminate program


; ==========================================================
; Function: send_newline
; Send Linefeed and CR over uart
; Preserves registers
; ==========================================================
send_newline:
    push r5
    mov r5, #$0D ; newline
    call uart_tx_char
    mov r5, #$0A ; newline
    call uart_tx_char
    pop r5
    ret

; ==========================================================
; Function: init_uart
; Set tx to idle state, wait enough time before start bit
; is allowed. Preserves registers
; ==========================================================
init_uart:
    push r2
    mov r2, #1
    mov [r8], r2            ; Force TX pin HIGH (Idle State)

    call delay_1bit

    pop r2
    ret
; ==========================================================
; Function: clear_screen
; Sends clear screen sequence to Tera Term
; Preserves registers
; ==========================================================
clear_screen:
    push r5
    mov r5, #27
    call uart_tx_char
    mov r5, #91
    call uart_tx_char
    mov r5, #50
    call uart_tx_char
    mov r5, #74
    call uart_tx_char
    mov r5, #27
    call uart_tx_char
    mov r5, #91
    call uart_tx_char
    mov r5, #72
    call uart_tx_char
    pop r5
    ret

; ==========================================================
; print_uint
; Prints unsigned integer in r1
; Input: r1 = value
; ==========================================================

print_uint:
    push bp
    mov bp, sp

    push r2
    push r3
    push r4
    push r5

    ; Special case: 0
    cmp r1, #0
    jne print_uint_start

    mov r5, #48          ; '0'
    call uart_tx_char
    jmp print_uint_done

print_uint_start:
    mov r3, #$FFFF
    push r3              ; sentinel

extract_loop:
    mov r2, #0           ; quotient
    mov r4, r1           ; remainder

div10_loop:
    cmp r4, #10
    jl div10u_done

    sub r4, #10
    inc r2
    jmp div10_loop

div10u_done:
    push r4              ; digit
    mov r1, r2           ; quotient

    cmp r1, #0
    jne extract_loop

print_loop:
    pop r2

    cmp r2, #$FFFF
    je print_uint_done

    add r2, #48          ; digit -> ASCII

    mov r5, r2
    call uart_tx_char

    jmp print_loop

print_uint_done:
    pop r5
    pop r4
    pop r3
    pop r2

    pop bp
    ret



; ==========================================
; Subroutine: uart_tx_char
; Sends ASCII character in r5 over UART.
; Preserves ALL registers.
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
    call delay_1bit         ; CRITICAL: 2 Stop Bits for high-speed stability!

    pop r8
    pop r7
    pop r6
    pop r3
    pop r2
    pop r1
    ret

; ==========================================
; Subroutine: delay_1bit (38,400 Baud)
; ==========================================
delay_1bit:
    push r7
    mov r7, #$00A3          ; Load calibrated 1-bit loop count (163 loops)
delay_loop:
    dec r7
    cmp r7, #0
    jne delay_loop
    pop r7
    ret



; ==========================================================
; Function: print_float_dec
; Converts an IEEE 754 float to ASCII decimal and prints it.
; Inputs: r1 = Float to print
; ==========================================================
print_float_dec:
    ; --- FUNCTION PROLOGUE ---
    push bp
    mov bp, sp
    push r5
    push r6
    push r7

    ; 1. Extract and Calculate True Exponent
    mov r3, mask_exp
    mov r6, r1
    and r6, r3              ; r6 = Raw Exponent aligned left

    mov r4, #23             ; Shift exponent down to integer
shift_exp_dec:
    shr r6
    dec r4
    cmp r4, #0
    jne shift_exp_dec

    sub r6, #127            ; r6 = True Exponent (e.g., 3)

    ; 2. Extract Mantissa and add Implicit 1
    mov r3, mask_mant
    mov r5, r1
    and r5, r3
    mov r3, one_bit
    or r5, r3               ; r5 = Mantissa with implicit bit

    ; 3. Calculate K (Number of bits in the fractional tail)
    mov r7, #23
    sub r7, r6              ; r7 = K (23 - True Exp)

    ; Create Fractional Mask: (1 << K) - 1
    mov r3, #1
    mov r4, r7
mask_loop_dec:
    cmp r4, #0
    je mask_done_dec
    shl r3
    dec r4
    jmp mask_loop_dec
mask_done_dec:
    dec r3                  ; r3 = Exact mask for fractional bits
    push r3                 ; Save this mask to the stack for later

    ; 4. Extract Integer Part
    mov r2, r5              ; Copy mantissa
    mov r4, r7              ; Shift right by K
int_shift_dec:
    cmp r4, #0
    je int_shift_done
    shr r2
    dec r4
    jmp int_shift_dec
int_shift_done:             ; r2 = Integer Part (e.g., 13)

    ; 5. Decimal String Extraction (Integer Part)
    mov r3, #$FFFF
    push r3                 ; Push sentinel value so we know when to stop popping
extract_int_loop:
    mov r3, #0              ; Quotient
    mov r4, r2              ; Remainder
div10_sub:
    cmp r4, #10
    jl div10_done           ; If < 10, division step is done
    sub r4, #10
    inc r3
    jmp div10_sub
div10_done:
    push r4                 ; Push remainder (the extracted digit 0-9)
    mov r2, r3              ; Set number to quotient for next loop
    cmp r2, #0
    jne extract_int_loop

    ; 6. Print Integer Digits
print_int_loop:
    pop r2
    cmp r2, #$FFFF          ; Hit the sentinel?
    je print_int_done
    add r2, #48             ; Add '0' to convert to ASCII
    ;mov [r8], r2            ; Print character
    push r5
    mov r5, r2
    call uart_tx_char
    pop r5
    jmp print_int_loop
print_int_done:

    ; 7. Print Decimal Point
    mov r2, #46             ; ASCII '.'
    push r5
    mov r5, r2
    call uart_tx_char
    pop r5

    ;mov [r8], r2

    ; 8. Extract and Print Fractional Digits
    pop r3                  ; Restore our Fractional Mask
    and r5, r3              ; r5 = Just the binary fractional bits
    mov r6, #5              ; We will print 5 decimal places

frac_loop:
    mul r5, #10             ; Multiply fraction by 10
    mov r2, r5

    mov r4, r7              ; Shift right by K to extract integer overflow
frac_shift:
    cmp r4, #0
    je frac_shift_done
    shr r2
    dec r4
    jmp frac_shift
frac_shift_done:            ; r2 = extracted decimal digit

    add r2, #48             ; Convert to ASCII
    ;mov [r8], r2            ; Print character
    push r5
    mov r5, r2
    call uart_tx_char
    pop r5

    and r5, r3              ; Mask out the integer we just printed, keeping the fraction

    dec r6
    cmp r6, #0
    jne frac_loop

    ; --- FUNCTION EPILOGUE ---
    pop r7
    pop r6
    pop r5
    pop bp
    ret

; ==========================================================
; Function: fadd
; Adds IEEE 754 single-precision floats.
; Inputs:  r1 = Float A, r2 = Float B (Per Calling Convention)
; Returns: r1 = Resulting Float
; ==========================================================
fadd:
    ; --- FUNCTION PROLOGUE ---
    push bp                 ; Save the caller's Base Pointer
    mov bp, sp              ; Set our new Base Pointer (bp = current sp)

    ; Save Callee-Saved registers safely (5 registers pushed)
    push r3
    push r4
    push r5
    push r6
    push r7

    ; Fetch utility masks into registers using direct evaluation
    mov r3, mask_exp        ; r3 = 0x7F800000 (Exponent Mask)
    mov r4, mask_mant       ; r4 = 0x007FFFFF (Mantissa Mask)

    ; 1. Denormal / Zero Guard Check
    mov r5, r1
    and r5, r3              ; Extract ExpA
    cmp r5, #0
    je return_b             ; If A is 0, return B

    mov r6, r2
    and r6, r3              ; Extract ExpB
    cmp r6, #0
    je return_a             ; If B is 0, return A

    ; 2. Unpack and insert explicit leading 1 bit
    mov r7, one_bit         ; r7 = 0x00800000

    mov r5, r1              ; Preserve raw A
    mov r6, r2              ; Preserve raw B

    and r1, r4              ; Clear everything except Mantissa A
    or r1, r7               ; Inject implicit bit 23 into Mantissa A

    and r2, r4              ; Clear everything except Mantissa B
    or r2, r7               ; Inject implicit bit 23 into Mantissa B

    ; Reload raw exponent values to evaluate alignment difference
    mov r7, mask_exp
    mov r3, r5
    and r3, r7              ; r3 = Raw ExpA
    mov r4, r6
    and r4, r7              ; r4 = Raw ExpB

    ; 3. Align Exponents
    cmp r3, r4
    je mantissa_add         ; Exponents already match, proceed to add
    jl align_a              ; ExpA < ExpB -> Mantissa A needs shifting

align_b:
    ; Case: ExpA > ExpB (Shift Mantissa B right)
    sub r3, r4              ; r3 = Raw Exponent Delta
    mov r4, #23             ; Use volatile r4 as our counter
shift_count_b:
    shr r3
    dec r4
    cmp r4, #0
    jne shift_count_b

align_loop_b:
    cmp r3, #0
    je set_exp_a
    shr r2                  ; Scale Mantissa B down
    dec r3
    jmp align_loop_b
set_exp_a:
    mov r3, r5              ; Target output exponent is ExpA
    mov r4, mask_exp
    and r3, r4
    jmp mantissa_add

align_a:
    ; Case: ExpB > ExpA (Shift Mantissa A right)
    sub r4, r3              ; r4 = Raw Exponent Delta
    mov r3, #23             ; Use r3 as counter
shift_count_a:
    shr r4
    dec r3
    cmp r3, #0
    jne shift_count_a

align_loop_a:
    cmp r4, #0
    je set_exp_b
    shr r1                  ; Scale Mantissa A down
    dec r4
    jmp align_loop_a
set_exp_b:
    mov r3, r6              ; Target output exponent is ExpB
    mov r4, mask_exp
    and r3, r4

mantissa_add:
    ; 4. Core Addition Phase
    add r1, r2              ; r1 = Cumulative Mantissa sum
    ; 5. Normalization Phase (Handling Carry Overflow out of Bit 23)
    mov r7, overflow_mask   ; r7 = 0x01000000 (Bit 24)

norm_loop:
    mov r5, r1
    and r5, r7              ; Check for active carry bit overflow
    cmp r5, #0
    je pack_result          ; Normalized successfully if bit 24 is clear

    shr r1                  ; Normalize mantissa rightward
    mov r5, one_bit
    add r3, r5              ; Increment raw exponent scale
    jmp norm_loop

pack_result:
    ; Strip hidden implicit bit back out before packing field
    mov r4, mask_mant
    and r1, r4

    or r1, r3               ; Combine Mantissa and final Exponent field
    jmp fadd_end

return_b:
    mov r1, r2              ; Output is float B
    jmp fadd_end

return_a:
    ; Output is already in r1
    jmp fadd_end

fadd_end:
    ; --- FUNCTION EPILOGUE ---
    ; Pop exactly the 5 registers we pushed, in reverse order
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3

    pop bp                  ; Restore old Base Pointer
    ret                     ; Return safely!

; ==========================================================
; Constant Data Pools
; ==========================================================
mask_exp:      .resw $7F800000
mask_mant:     .resw $007FFFFF
one_bit:       .resw $00800000
overflow_mask: .resw $01000000

myconst:       .float f12.5
myconst2:      .float f1.0
