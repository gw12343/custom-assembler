.org $8000
    mov sp, #$fff           ; Setup stack
    mov bp, #$fff           ; Initialize base pointer to match stack bottom
    mov r8, #$6000          ; Output Port

    call init_uart
    call clear_screen

    call print_border
    call init_snake_and_apple

snake_loop:
    mov r8, APPLE_X
    cmp r1, r8              ; check if head x matches apple x
    jne remove_tail
    mov r8, APPLE_Y
    cmp r2, r8              ; check if head y matches apple y
    jne remove_tail

    jmp skip_remove_tail

remove_tail:
    ; DELETE SNAKE TAIL
    push r1
    push r2
    push r3
    mov r1, r6
    mov r2, r7
    mov r3, ' '                 ; Space literal
    call output_at_pos          ; Delete tail
    pop r3
    pop r2
    pop r1
    ; TAIL INDEX
    mov r8, r7                  ; y cord
    sub r8, #1                  ; zero index
    mul r8, #15                 ; times width
    add r8, r6                  ; plus x
    sub r8, #1                  ; zero index
    add r8, #DIRECTION_GRID     ; offset into array
     push r8 ; keep track of index
        mov r8, [r8] ; get direction index at tail

        cmp r8, #2
        je dir_check_left
        cmp r8, #4
        je dir_check_right
        cmp r8, #1
        je dir_check_up
        cmp r8, #5
        je dir_check_down

        hlt ; TODO unknown????

         dir_check_left:
            sub r6, #1
            jmp dir_check_end
         dir_check_right:
            add r6, #1
            jmp dir_check_end
         dir_check_up:
            sub r7, #1
            jmp dir_check_end
         dir_check_down:
            add r7, #1
         dir_check_end:
    pop r8
    push r1
    mov r1, #0
    mov [r8], r1 ; remove direction index at tail
    pop r1
    jmp end_tail
skip_remove_tail:
    mov r8, SNAKE_LENGTH
    inc r8
    mov SNAKE_LENGTH, r8

    mov r8, SPACES_LEFT
    dec r8
    mov SPACES_LEFT, r8
    cmp r8, #0
    je you_win           ; check for win

    call move_apple
    call move_cursor_away
end_tail:



    ; PRINT SNAKE HEAD
    call output_at_pos

    call move_cursor_away

    ;call print_dbg_info

    call calc_head_index        ; put index in r8

    call check_head_collision


    ; calculate direction index,  f(dx, dy) = dx + 1 + 2(dy + 1)
    ;    xxxxxx     air ==> 0
    ;    (0, -1)     up ==> 1
    ;    (-1, 0)   left ==> 2
    ;    XXXXXX    wall ==> 3
    ;    (1, 0)   right ==> 4
    ;    (0, 1)    down ==> 5

    push r7
    mov r7, r5      ; load dy
    add r7, #1      ; add 1
    mul r7, #2      ; mul by 2
    add r7, r4      ; offset by dx
    add r7, #1      ; add 1
    mov [r8], r7    ; put direction index at head
    pop r7



    ; MOVE HEAD IN DIRECTION
    add r1, r4
    add r2, r5

    call snake_delay
    jmp snake_loop



dbg: .asciiz "\r\nHEAD: (%d, %d)  \r\nTAIL: (%d, %d)  \r\nAPPLE: (%d, %d)  \r\nL: %d  \r\nS: %d  "



move_cursor_away:
    push r1
    push r2
    mov r1, #16
    mov r2, #16
    call cursor_to_pos  ; move the cursor out of the game area
    pop r2
    pop r1
    ret

check_head_collision:
    push r8 ; keep track of index
    mov r8, [r8] ; get direction index at head
    cmp r8, #0
    pop r8
    jne game_over
    ret



game_over:
    mov r1, #18
    mov r2, #8
    call cursor_to_pos
    mov r1, #GAME_OVER_TEXT
    call print_string
    jmp print_score
you_win:
    mov r1, #18
    mov r2, #8
    call cursor_to_pos
    mov r1, #YOU_WIN_TEXT
    call print_string
print_score:
    mov r1, #18
    mov r2, #9
    call cursor_to_pos
    mov r8, SNAKE_LENGTH
    push r8
    mov r8, #SCORE_TEXT
    push r8
    call printf
    pop r8
    pop r8
    hlt

calc_head_index:
    mov r8, r2                  ; y cord
    sub r8, #1                  ; zero index
    mul r8, #15                 ; times width
    add r8, r1                  ; plus x
    sub r8, #1                  ; zero index
    add r8, #DIRECTION_GRID     ; offset into array
    ret

print_dbg_info:
    push r1
    mov r8, SPACES_LEFT
    push r8
    mov r8, SNAKE_LENGTH
    push r8
    mov r8, APPLE_Y
    push r8
    mov r8, APPLE_X
    push r8
    push r7
    push r6
    push r2
    push r1
    mov r1, #dbg
    push r1
    call printf
    pop r1
    pop r1
    pop r1
    pop r1
    pop r1
    pop r1
    pop r1
    pop r1
    pop r1
    pop r1
    ret


init_snake_and_apple:
    ; PRINT APPLE
    mov r1, APPLE_X
    mov r2, APPLE_Y
    mov r3, '@'
    call output_at_pos

    ; MOVE SNAKE
    mov r1, #3  ; start x
    mov r2, #5  ; start y
    mov r3, 'S' ; char
    mov r4, #1   ; dx
    mov r5, #0   ; dy

    mov r6, #3  ; tail x
    mov r7, #5  ; tail y

    ; OUTPUT FIRST 3 SEGMENTS OF SNAKE
    call output_at_pos
    inc r1
    call output_at_pos
    inc r1
    call output_at_pos
    inc r1
    ret



print_border:
    mov r5, #1
    mov r3, '#'
border_loop:
    mov r1, r5
    mov r2, #1
    call output_at_pos   ; print top wall
    mov r2, #15
    call output_at_pos   ; print bottom wall

    mov r2, r5
    mov r1, #1
    call output_at_pos   ; print left wall
    mov r1, #15
    call output_at_pos   ; print right wall

    inc r5
    cmp r5, #16
    je border_end
    jmp border_loop
border_end:
    ret



check_buttons:
    push r1
    push r2

    check_up:
        cmp r5, #1
        je check_down           ; prevent 180 turn
        mov r2, BTN_UP_MASK
        mov r1, $6001  ; load inputs
        and r1, r2     ; mask inputs
        cmp r1, #0
        je check_down
        mov r4, #0
        mov r5, MINUS_ONE
        ;dont jump to end to ensure roughly constant time during loop even when button is pressed
    check_down:
        cmp r5, #1
        jg check_left           ; prevent 180 turn (unsigned comparison)
        mov r2, BTN_DOWN_MASK
        mov r1, $6001  ; load inputs
        and r1, r2     ; mask inputs
        cmp r1, #0
        je check_left
        mov r4, #0
        mov r5, #1
        ;jmp check_buttons_end
    check_left:
        cmp r4, #1                  ; check if currently going right
        je check_right
        mov r2, BTN_LEFT_MASK
        mov r1, $6001  ; load inputs
        and r1, r2     ; mask inputs
        cmp r1, #0
        je check_right
        mov r4, MINUS_ONE
        mov r5, #0
        ;jmp check_buttons_end
    check_right:
        cmp r4, #1                  ; check if currently going left
        jg check_buttons_end
        mov r2, BTN_RIGHT_MASK
        mov r1, $6001  ; load inputs
        and r1, r2     ; mask inputs
        cmp r1, #0
        je check_buttons_end
        mov r4, #1
        mov r5, #0
    check_buttons_end:
        pop r2
        pop r1
        ret


snake_delay:
    push r7
    push r6
    mov r6, #$004F                      ; Outer loop counter
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
    ret                                 ; Return to main loop






move_apple:
    push r1
    push r2
    push r3
    call random32               ; get a random 32 bit #
    and r1, #$ff                ; mod 256
    mov r2, SPACES_LEFT         ; load # of spaces

move_apple_mod_loop:
    cmp r1, r2
    jl move_apple_done_mod      ; if already less than SPACES_LEFT, skip mod

    sub r1, r2
    jmp move_apple_mod_loop     ; keep subtracting while r1 >= SPACES_LEFT


    ; SCAN LEFT TO RIGHT TOP TO BOTTOM, COUNTING EMPTY SPACES
    ; UNTIL R1 IS 0, THEN PLACE APPLE THERE
move_apple_done_mod:
    mov r2, #2                  ; current x
    mov r3, #2                  ; current y
move_apple_loop:
    cmp r1, #0                  ; check counter
    je move_apple_done_xy       ; if reached final empty space, stay here
    inc r2                      ; increment x
    cmp r2, #15                 ; check for wrap
    jne dont_nl                 ; if not needed, skip over wrap
    mov r2, #2                  ; wrap back to left
    inc r3                      ; go to next line
dont_nl:
    ; curr index
    mov r8, r3                  ; y cord
    sub r8, #1                  ; zero index
    mul r8, #15                 ; times width
    add r8, r2                  ; plus x
    sub r8, #1                  ; zero index
    add r8, #DIRECTION_GRID     ; offset into array
    mov r8, [r8]
    cmp r8, #0
    jne invalid_space
    dec r1
    invalid_space:
    jmp move_apple_loop
move_apple_done_xy:
    mov APPLE_X, r2
    mov APPLE_Y, r3
    mov r1, r2
    mov r2, r3
    mov r3, '@'
    call output_at_pos
done_move_apple:
    pop r3
    pop r2
    pop r1
    ret


BTN_CENTER_MASK: .resw %000010000000000000000
BTN_UP_MASK:     .resw %000100000000000000000
BTN_LEFT_MASK:   .resw %001000000000000000000
BTN_RIGHT_MASK:  .resw %010000000000000000000
BTN_DOWN_MASK:   .resw %100000000000000000000
MINUS_ONE:       .resw $ffffffff

APPLE_X:            .resw 12
APPLE_Y:            .resw 5
SNAKE_LENGTH:       .resw 3
SPACES_LEFT:        .resw 166  ;  13x13 grid - 3 spaces for starting snake

DIRECTION_GRID:
    .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3
    .resw 3 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 0 .resw 4 .resw 4 .resw 4 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 0 .resw 3
    .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3 .resw 3

GAME_OVER_TEXT: .asciiz "GAME OVER!"
YOU_WIN_TEXT: .asciiz "YOU WIN!"
SCORE_TEXT: .asciiz "SCORE: %d"




 ; ============================================================================ STANDARD LIBRARY ============================================================================
 ; ============================================================================ STANDARD LIBRARY ============================================================================
 ; ============================================================================ STANDARD LIBRARY ============================================================================
 ; ============================================================================ STANDARD LIBRARY ============================================================================
 ; ============================================================================ STANDARD LIBRARY ============================================================================
 ; ============================================================================ STANDARD LIBRARY ============================================================================

; ==========================================================
; Function: random32
; Generates a random #
; Output: r1=random number
; ==========================================================
random32:
    push r2

    mov r1, RANDOM_SEED

    ; x ^= x << 13
    mov r2, r1
    shl r2, #13
    xor r1, r2

    ; x ^= x >> 17
    mov r2, r1
    shr r2, #17
    xor r1, r2

    ; x ^= x << 5
    mov r2, r1
    shl r2, #5
    xor r1, r2

    mov RANDOM_SEED, r1

    pop r2
    ret
RANDOM_SEED: .resw 1234
; ==========================================================
; Function: cursor_to_pos
; Moves the cursor to (x, y)
; Input: r1=x r2=y
; ==========================================================
cursor_to_pos:
    push r1
    push r5

    push r1 ; x
    push r2 ; y

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
    push r1 ; x
    push r2 ; y

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

    push r1
    push r2
    push r3
    push r4
    push r5
    push r6
    push r7
    push r8

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
    pop r8
    pop r7
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    pop r1

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
    mov r3, r1                  ; move input value into r3 to be shifted
    mov r2, #32                 ; r2 is shift counter
    mov r6, msb_mask            ; leftmost bit mask
print_binary_loop:
    mov r5, r3
    and r5, r6
    cmp r5, #0                  ; check if 0
    je print_binary_send0
    mov r5, '1'
    jmp print_binary_send1
print_binary_send0:
    mov r5, '0'
print_binary_send1:
    call uart_tx_char

    shl r3
    dec r2
    cmp r2, #0                  ; check if done shifting
    je end_print_binary         ; yes, jump to end
    jmp print_binary_loop       ; no, keep looping
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
