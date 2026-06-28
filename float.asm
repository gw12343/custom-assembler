.org $8000
    mov sp, #$fff           ; Setup stack
    mov bp, #$fff           ; Initialize base pointer to match stack bottom
    mov r8, #$6000          ; Output Port

    call init_uart
    call clear_screen


;
;    mov r1, #0 ;x
;    mov r2, #0 ;y


 ; PRINT BORDER
    mov r5, #1
    mov r3, '#'
border_loop:
    mov r1, r5
    mov r2, #1
    call output_at_pos   ; print left wall
    mov r2, #15
    call output_at_pos   ; print right wall

    mov r2, r5
    mov r1, #1
    call output_at_pos   ; print top wall
    mov r1, #15
    call output_at_pos   ; print bottom wall

    inc r5
    cmp r5, #16
    je border_end
    jmp border_loop
border_end:



; MOVE SNAKE
    mov r1, #5  ; x
    mov r2, #5  ; y
    mov r3, 'S' ; char
    mov r4, #0   ; dx
    mov r5, #1   ; dy
snake_loop:
    call output_at_pos

    cmp r1, #1
    je game_over
    cmp r2, #1
    je game_over
    cmp r1, #15
    je game_over
    cmp r2, #15
    je game_over

    add r1, r4
    add r2, r5


    call snake_delay
    jmp snake_loop


game_over:
    mov r1, #5
    mov r2, #18
    call cursor_to_pos
    mov r1, #GAME_OVER_TEXT
    call print_string
    hlt





check_buttons:
    push r2
    push r1
    check_up:
        mov r2, BTN_UP_MASK
        mov r1, $6001  ; load inputs
        and r1, r2     ; mask inputs
        cmp r1, #0
        je check_down
        mov r4, MINUS_ONE
        mov r5, #0
        ;dont jump to end to ensure roughly constant time during loop even when button is pressed
    check_down:
        mov r2, BTN_DOWN_MASK
        mov r1, $6001  ; load inputs
        and r1, r2     ; mask inputs
        cmp r1, #0
        je check_left
        mov r4, #1
        mov r5, #0
        ;jmp check_buttons_end
    check_left:
        mov r2, BTN_LEFT_MASK
        mov r1, $6001  ; load inputs
        and r1, r2     ; mask inputs
        cmp r1, #0
        je check_right
        mov r4, #0
        mov r5, MINUS_ONE
        ;jmp check_buttons_end
    check_right:
        mov r2, BTN_RIGHT_MASK
        mov r1, $6001  ; load inputs
        and r1, r2     ; mask inputs
        cmp r1, #0
        je check_buttons_end
        mov r4, #0
        mov r5, #1
    check_buttons_end:
        pop r1
        pop r2
        ret
BTN_CENTER_MASK: .resw %000010000000000000000
BTN_UP_MASK:     .resw %000100000000000000000
BTN_LEFT_MASK:   .resw %001000000000000000000
BTN_RIGHT_MASK:  .resw %010000000000000000000
BTN_DOWN_MASK:   .resw %100000000000000000000
MINUS_ONE:       .resw $ffffffff



GAME_OVER_TEXT: .asciiz "GAME OVER!"





snake_delay:
    push r7
    push r6
    mov r6, #$007F                      ; Outer loop counter
snake_delay_outer_loop:
    cmp r6, #0                          ; Check if outer loop is finished
    je snake_delay_end

    mov r7, #$5FF                       ; Inner loop counter

snake_delay_inner_loop:
    call check_buttons
    dec r7                              ; Decrement inner counter (Assume 1 cycle)
    cmp r7, #0                          ; Check if inner loop is finished (Assume 1 cycle)
    jne snake_delay_inner_loop          ; Jump if not equal (Assume 2 cycles)

snake_delay_inner_end:
    dec r6                              ; Decrement outer loop counter
    jmp snake_delay_outer_loop          ; Loop back to outer

snake_delay_end:
    pop r6
    pop r7
    ret                     ; Return to main loop






 ; ========================================================= STANDARD LIBRARY =========================================================
 ; ========================================================= STANDARD LIBRARY =========================================================
 ; ========================================================= STANDARD LIBRARY =========================================================
 ; ========================================================= STANDARD LIBRARY =========================================================
 ; ========================================================= STANDARD LIBRARY =========================================================
 ; ========================================================= STANDARD LIBRARY =========================================================


; ==========================================================
; Function: cursor_to_pos
; Moves the cursor to (x, y)
; Input: r1=x r2=y
; ==========================================================
cursor_to_pos:
    push r1
    push r5

    push r2 ; y
    push r1 ; x

    mov r5, #move_format
    push r5 ; format

    call printf
    pop r1
    pop r1
    pop r1

    pop r5 ; preserve r5
    pop r1 ; preserve r1
    ret
move_format: .asciiz "\e[%d;%dH"
; ==========================================================
; Function: output_at_pos
; Moves the cursor to (x, y) and outputs c over uart
; Input: r1=x r2=y r3=c
; ==========================================================
output_at_pos:
    push r1
    push r5

    push r3 ; char
    push r2 ; y
    push r1 ; x

    mov r5, #output_format
    push r5 ; format

    call printf
    pop r1
    pop r1
    pop r1
    pop r1

    pop r5 ; preserve r5
    pop r1 ; preserve r1
    ret
output_format: .asciiz "\e[%d;%dH%c"


; ==========================================================
; Function: printf
; Prints a string with embedded format specifiers. Accepts
; %s: string, %d integer, %f float.
; Input: arguments pushed onto stack in reverse order
; ==========================================================
printf:
    push bp
    mov bp, sp

    mov r7, bp
    add r7, #4 ; points to the first argument

    mov r1, [bp + 3] ; string pattern
printf_loop:
    mov r5, [r1]
    cmp r5, #0
    je printf_end
    cmp r5, '%'
    je printf_check_format_specifier
printf_send:                ; Jump back if this is just a % and not a format specifier
    call uart_tx_char
printf_dont_send:           ; Jump here if this % is part of a specifier and shouldn't be printed
    inc r1
    jmp printf_loop

printf_check_format_specifier:
    inc r1
    mov r6, [r1]
    dec r1
    cmp r6, 'd'
    mov r5, [r1]
    jne printf_check_float

    inc r1             ; consume 'd' character
    push r1
    mov r1, [r7]       ; get next argument
    inc r7             ; increment argument pointer
    call print_uint    ; print integer
    pop r1

    jmp printf_dont_send
printf_check_float:
    inc r1
    mov r6, [r1]
    dec r1
    cmp r6, 'f'
    mov r5, [r1]
    jne printf_check_string

    inc r1             ; consume 'f' character
    push r1
    mov r1, [r7]       ; get next argument
    inc r7             ; increment argument pointer
    call print_float_dec    ; print integer
    pop r1
    jmp printf_dont_send   ; contine in character loop
printf_check_string:
    inc r1
    mov r6, [r1]
    dec r1
    cmp r6, 's'
    mov r5, [r1]
    jne printf_check_char

    inc r1             ; consume 's' character
    push r1
    mov r1, [r7]       ; get next argument
    inc r7             ; increment argument pointer
    call print_string    ; print integer
    pop r1
    jmp printf_dont_send   ; continue in character loop
printf_check_char:
    inc r1
    mov r6, [r1]
    dec r1
    cmp r6, 'c'
    mov r5, [r1]
    jne printf_check_bool

    inc r1             ; consume 'c' character
    push r5
    mov r5, [r7]       ; get next argument
    push r8
    mov r8, #$ff
    and r5, r8       ; mask 8 bits
    pop r8
    inc r7             ; increment argument pointer

    call uart_tx_char  ; print char

    pop r5
    jmp printf_dont_send   ; continue in character loop
printf_check_bool:
    inc r1
    mov r6, [r1]
    dec r1
    cmp r6, 'b'
    mov r5, [r1]
    jne printf_send

    inc r1             ; consume 'b' character
    push r1
    mov r1, [r7]       ; get next argument
    inc r7             ; increment argument pointer

    cmp r1, #0
    je printf_false

    mov r1, #true_string
    jmp printf_print_bool
printf_false:
    mov r1, #false_string
printf_print_bool:
    call print_string  ; print true_string or false_string
    pop r1
    jmp printf_dont_send   ; continue in character loop
printf_end:
    pop bp
    ret
true_string: .asciiz "true"
false_string: .asciiz "false"

; ==========================================================
; Function: print_string
; Print null-terminated string
; Input: r1 = string ptr
; ==========================================================
print_string:
   push r5
print_string_loop:
   mov r5, [r1]
   cmp r5, #0   ; check for null terminator
   inc r1
   je print_string_end
   call uart_tx_char
   jmp print_string_loop
print_string_end:
   pop r5
   ret

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
    mov $6000, r2            ; Force TX pin HIGH (Idle State)

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
; print_binary
; Prints value over uart in binary
; Input: r1 = value
; ==========================================================
print_binary:
    push r2
    push r3
    push r5
    push r6
    mov r3, r1                                      ; move input value into r3 to be shifted
    mov r2, #32                                     ; r2 is shift counter
    mov r6, msb_mask      ; leftmost bit mask
print_binary_loop:
    mov r5, r3
    and r5, r6
    cmp r5, #0     ; check if 0
    je print_binary_send0
    mov r5, '1'
    jmp print_binary_send1
print_binary_send0:
    mov r5, '0'
print_binary_send1:
    call uart_tx_char

    shl r3
    dec r2
    cmp r2, #0            ; check if done shifting
    je end_print_binary   ; yes, jump to end
    jmp print_binary_loop ; no, keep looping
end_print_binary:
    pop r6
    pop r5
    pop r3
    pop r2
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

    mov r1, r5              ; Copy char to r1 for shifting
    mov r6, #1              ; Bitmask for isolating LSB

    ; Send START BIT (LOW)
    mov r2, #0
    mov $6000, r2
    call delay_1bit

    ; Send 8 DATA BITS (LSB First)
    mov r3, #8
tx_bit_loop:
    mov r2, r1
    and r2, r6              ; Mask all but the lowest bit using r6
    mov $6000, r2
    call delay_1bit

    shr r1
    dec r3
    cmp r3, #0
    jne tx_bit_loop

    ; Send STOP BIT (HIGH)
    mov r2, #1
    mov $6000, r2
    call delay_1bit
    call delay_1bit         ; CRITICAL: 2 Stop Bits for high-speed stability!

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
    ;mov $6000, r2            ; Print character
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

    ;mov $6000, r2

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
    ;mov $6000, r2            ; Print character
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
; Entry Points: fadd and fsub
; ==========================================================
fadd:
    push bp                 ; [cite: 7]
    mov bp, sp              ; [cite: 7]
    push r3
    push r4
    push r5
    push r6
    push r7
    push r8                 ; Save extra register for operation flag
    mov r8, #0              ; 0 = ADD flag
    jmp f_arithmetic_core   ; [cite: 28]

fsub:
    push bp                 ; [cite: 7]
    mov bp, sp              ; [cite: 7]
    push r3
    push r4
    push r5
    push r6
    push r7
    push r8                 ; Save extra register for operation flag
    mov r8, #1              ; 1 = SUB flag
    jmp f_arithmetic_core   ; [cite: 28]

; ==========================================================
; Shared Arithmetic Logic
; ==========================================================
f_arithmetic_core:
    ; 1. Load masks into registers (Required by ISA )
    mov r3, mask_exp
    mov r4, mask_mant

    ; 2. Zero/Denormal Guard
    mov r5, r1
    and r5, r3              ; Extract ExpA
    cmp r5, #0              ; [cite: 27]
    je return_b             ; [cite: 29]

    mov r6, r2
    and r6, r3              ; Extract ExpB
    cmp r6, #0              ; [cite: 27]
    je return_a             ; [cite: 29]

    ; 3. Unpack and insert implicit 1-bit
    mov r7, one_bit
    mov r5, r1
    mov r6, r2
    and r1, r4              ; Clear everything except Mantissa A
    or r1, r7               ; Inject implicit bit 23
    and r2, r4              ; Clear everything except Mantissa B
    or r2, r7               ; Inject implicit bit 23

    ; 4. Align Exponents
    mov r7, mask_exp
    mov r3, r5
    and r3, r7              ; r3 = Raw ExpA
    mov r4, r6
    and r4, r7              ; r4 = Raw ExpB
    cmp r3, r4              ; [cite: 27]
    je mantissa_op          ; [cite: 29]
    jl align_a_shared       ; [cite: 29]

align_b_shared:
    sub r3, r4              ; Delta
    mov r4, #23
shift_count_b_shared:
    shr r3                  ;
    dec r4                  ; [cite: 23]
    cmp r4, #0              ; [cite: 27]
    jne shift_count_b_shared ; [cite: 29]
align_loop_b_shared:
    cmp r3, #0              ; [cite: 27]
    je set_exp_a_shared     ; [cite: 29]
    shr r2                  ;
    dec r3                  ; [cite: 23]
    jmp align_loop_b_shared ; [cite: 28]
set_exp_a_shared:
    mov r3, r5
    mov r4, mask_exp
    and r3, r4              ;
    jmp mantissa_op         ; [cite: 28]

align_a_shared:
    sub r4, r3              ; Delta
    mov r3, #23
shift_count_a_shared:
    shr r4                  ;
    dec r3                  ; [cite: 23]
    cmp r3, #0              ; [cite: 27]
    jne shift_count_a_shared ; [cite: 29]
align_loop_a_shared:
    cmp r4, #0              ; [cite: 27]
    je set_exp_b_shared     ; [cite: 29]
    shr r1                  ;
    dec r4                  ; [cite: 23]
    jmp align_loop_a_shared ; [cite: 28]
set_exp_b_shared:
    mov r3, r6
    mov r4, mask_exp
    and r3, r4              ;

; --- 5. Operation Branching ---
mantissa_op:
    cmp r8, #1              ; Check if operation is SUB [cite: 27]
    je mantissa_sub         ; [cite: 29]

; --- Addition Branch ---
mantissa_add:
    add r1, r2              ;
    mov r7, overflow_mask

norm_loop_add:
    mov r5, r1
    and r5, r7              ; Check carry
    cmp r5, #0              ; [cite: 27]
    je pack_result_shared   ; [cite: 29]
    shr r1                  ; Normalize right
    mov r5, one_bit
    add r3, r5              ; Increment exponent
    jmp norm_loop_add       ; [cite: 28]

; --- Subtraction Branch ---
mantissa_sub:
    sub r1, r2              ; Subtract aligned mantissas
    cmp r1, #0              ; Check for total cancellation [cite: 27]
    je return_zero_shared   ; [cite: 29]

    mov r7, one_bit         ; Setup bit 23 check mask

norm_loop_sub:
    mov r5, r1
    and r5, r7              ; Check if implicit bit 23 is present
    cmp r5, #0              ; [cite: 27]
    jne pack_result_shared  ; If set, it is normalized [cite: 29]
    shl r1                  ; Normalize left
    mov r5, one_bit
    sub r3, r5              ; Decrement exponent scale
    jmp norm_loop_sub       ; [cite: 28]

; --- 6. Packing & Exits ---
pack_result_shared:
    mov r4, mask_mant
    and r1, r4              ; Strip implicit bit back out
    or r1, r3               ; Combine Mantissa and final Exponent
    jmp exit_shared         ; [cite: 28]

return_zero_shared:
    mov r1, #0              ; Output true zero
    jmp exit_shared         ; [cite: 28]

return_b:
    mov r1, r2
    jmp exit_shared         ; [cite: 28]

return_a:
    jmp exit_shared         ; [cite: 28]

exit_shared:
    pop r8                  ; Restore flag register
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop bp                  ; [cite: 7]
    ret                     ; [cite: 31]
; ==========================================================
; Constant Data Pools
; ==========================================================
mask_exp:      .resw $7F800000
mask_mant:     .resw $007FFFFF
one_bit:       .resw $00800000
overflow_mask: .resw $01000000
msb_mask:      .resw %10000000000000000000000000000000

myconst:       .float f12.5
myconst2:      .float f1.0

