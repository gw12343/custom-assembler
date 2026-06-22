    mov sp, #$100           ; Setup stack
    mov bp, #$100           ; Initialize base pointer to match stack bottom
    mov r8, #$6000          ; Output Port

    ; Load Float A directly
    mov r1, myconst
    ; Load Float B directly
    mov r2, myconst2

    call fadd               ; Call Floating-Point Add (Arguments in r1, r2)

    mov [r8], r1            ; Print final packed 32-bit float to display (Should be 40400000)

    hlt                     ; Terminate program

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

myconst:       .resw %01001011100000000000000000000000
myconst2:      .resw %00111111100000000000000000000000





;    mov sp, #$100           ; Setup stack
;    mov bp, #$100           ; Initialize base pointer to match stack bottom
;    mov r8, #$6000          ; Output Port
;    mov r1, #'a'
;    ; ==========================================
;    ; Main Execution
;    ; ==========================================
;    mov r1, #5              ; We want to calculate the triangular sum of 5
;    push r1                 ; [Arg 1] Push argument to stack
;
;    call tri_sum            ; Call the function
;
;    pop r2                  ; [Cleanup] Pop the argument off the stack
;
;    mov [r8], r1            ; Print the answer (Hex 0F)
;    hlt                     ; Program finished.
;
;; ==========================================
;; Function: tri_sum
;; Calculates sum of all integers from N to 1.
;; Argument 1: [bp + 3]
;; Returns: r1
;; ==========================================
;tri_sum:
;    ; --- FUNCTION PROLOGUE ---
;    push bp                 ; Save the caller's Base Pointer
;    mov bp, sp              ; Set our new Base Pointer (bp = current sp)
;
;    mov r1, #0              ; Setup our local variable (Accumulator = 0)
;    push r1                 ; Allocate Local Var 1 on the stack
;
;    ; --- FUNCTION BODY ---
;sum_loop:
;    mov r1, [bp+3]          ; Load Argument 1 (N) [Shifted to +3 for post-decrement]
;    cmp r1, #0              ; If N == 0, we are done
;    je sum_end
;
;    mov [r8], r1            ; Print the current N to the display
;
;    mov r2, [bp]            ; Load our local Accumulator variable safely from [bp]
;    add r2, r1              ; Add N to the Accumulator
;    mov [bp], r2            ; Store the updated Accumulator back to [bp]
;
;    dec r1                  ; Decrement N (N = N - 1)
;    mov [bp+3], r1          ; Save the decremented N back into its stack argument slot
;    jmp sum_loop            ; Loop
;
;    ; --- FUNCTION EPILOGUE ---
;sum_end:
;    mov r1, [bp]            ; Load the final Accumulator value into r1 (Return Value)
;
;    mov sp, bp              ; Restore SP to BP (Instantly deallocates all local variables)
;    pop bp                  ; Restore the caller's old Base Pointer
;    ret                     ; Return to caller





;    mov sp, #$100           ; Setup stack
;
;    ; Initialize Master Counters
;    mov r2, #0              ; r2 = Memory Address Pointer (Starts at 0)
;    mov r3, #256            ; r3 = Total words to print (256 slots)
;    mov r4, #0              ; r4 = Column counter (0 to 7)
;
;; ==========================================
;; Main Memory Dump Loop
;; ==========================================
;memory_loop:
;    mov r1, [r2]            ; Read the 32-bit word from current memory address
;    call print_hex          ; Print it over UART
;
;    inc r2                  ; Advance memory pointer to the next address
;    inc r4                  ; Increment our column counter
;    dec r3                  ; Decrement our total words counter
;
;    ; Format checking: Are we at the end of the line (8th item)?
;    cmp r4, #8
;    je print_newline
;
;    ; Format checking: Are we at the middle of the line (4th item)?
;    cmp r4, #4
;    je print_double_space
;
;    ; Otherwise, print a single space ($20)
;    mov r5, #$20
;    call uart_tx_char
;    jmp check_end
;
;print_double_space:
;    mov r5, #$20            ; Load ASCII Space
;    call uart_tx_char       ; Print space 1
;    call uart_tx_char       ; Print space 2
;    jmp check_end
;
;print_newline:
;    mov r5, #$0D            ; ASCII Carriage Return (CR)
;    call uart_tx_char
;    mov r5, #$0A            ; ASCII Line Feed (LF)
;    call uart_tx_char
;    mov r4, #0              ; Reset column counter back to 0
;
;check_end:
;    cmp r3, #0              ; Have we printed all 256 words?
;    je end_program
;    jmp memory_loop         ; If not, fetch the next address
;
;end_program:
;    hlt                     ; Memory dump complete!
;
;; ==========================================
;; Subroutine: print_hex
;; Prints the 32-bit value in r1 as 8 hex digits.
;; Preserves ALL registers.
;; ==========================================
;print_hex:
;    push r1
;    push r3
;    push r4
;    push r5
;    push r7
;
;    mov r4, #8              ; Print 8 hex nibbles
;
;hex_loop:
;    mov r3, r1              ; Copy the 32-bit value
;
;    ; Isolate the TOP 4 bits (Shift right 28 times)
;    mov r7, #28
;shift_right_28:
;    shr r3
;    dec r7
;    cmp r7, #0
;    jne shift_right_28
;
;    ; Convert 0-15 to ASCII
;    mov r5, r3
;    cmp r5, #9
;    jg is_alpha             ; If > 9, it's a letter (A-F)
;
;is_num:
;    add r5, #$30            ; Add $30 for '0'-'9'
;    jmp print_char
;
;is_alpha:
;    add r5, #$37            ; Add $37 for 'A'-'F'
;
;print_char:
;    call uart_tx_char       ; Print the character
;
;    ; Shift r1 left by 4 to queue up the next nibble
;    mov r7, #4
;shift_left_4:
;    shl r1
;    dec r7
;    cmp r7, #0
;    jne shift_left_4
;
;    dec r4
;    cmp r4, #0
;    jne hex_loop
;
;    pop r7
;    pop r5
;    pop r4
;    pop r3
;    pop r1
;    ret
;
;; ==========================================
;; Subroutine: uart_tx_char
;; Sends ASCII character in r5 over UART.
;; Preserves ALL registers.
;; ==========================================
;uart_tx_char:
;    push r1
;    push r2
;    push r3
;    push r6
;    push r7
;    push r8
;
;    mov r8, #$6000          ; Output Port
;    mov r1, r5              ; Copy char to r1 for shifting
;    mov r6, #1              ; Bitmask for isolating LSB
;
;    ; Send START BIT (LOW)
;    mov r2, #0
;    mov [r8], r2
;    call delay_1bit
;
;    ; Send 8 DATA BITS (LSB First)
;    mov r3, #8
;tx_bit_loop:
;    mov r2, r1
;    and r2, r6              ; Mask all but the lowest bit using r6
;    mov [r8], r2
;    call delay_1bit
;
;    shr r1
;    dec r3
;    cmp r3, #0
;    jne tx_bit_loop
;
;    ; Send STOP BIT (HIGH)
;    mov r2, #1
;    mov [r8], r2
;    call delay_1bit
;
;    pop r8
;    pop r7
;    pop r6
;    pop r3
;    pop r2
;    pop r1
;    ret
;
;; ==========================================
;; Subroutine: delay_1bit (9600 Baud)
;; ==========================================
;delay_1bit:
;    push r7
;    mov r7, #$028B          ; Load calibrated 1-bit loop count (651 loops)
;delay_loop:
;    dec r7
;    cmp r7, #0
;    jne delay_loop
;    pop r7
;    ret








;mov sp, #$100           ; Setup stack
;    mov r2, #$6001          ; r2 = Input Port (Switches, Buttons, UART RX)
;    mov r8, #$6000          ; r8 = Output Port (Display / UART TX)
;
;    ; Construct the Bit 21 Mask (0x00200000)
;    mov r3, #1              ; Start with bit 0
;    mov r6, #21             ; Shift counter
;mask_loop:
;    shl r3
;    dec r6
;    cmp r6, #0
;    jne mask_loop           ; r3 now contains 0x00200000
;
;    mov r6, #$80            ; Load $80 into r6 to use as an OR bitmask later
;
;; ==========================================
;; Main UART RX Loop
;; ==========================================
;rx_wait_start:
;    mov r1, [r2]            ; Read input port
;    and r1, r3              ; Isolate bit 21 (UART RX)
;    cmp r1, #0              ; Idle state is HIGH (not 0). Start bit is LOW (0).
;    jne rx_wait_start       ; Loop until line drops to 0
;
;    ; We detected a Start Bit! Wait 1.5 bit times.
;    mov r7, #$03D0          ; Load calibrated 1.5-bit loop count (976 loops)
;    call delay
;
;    mov r4, #8              ; r4 = Bit counter (We need to read 8 bits)
;    mov r5, #0              ; r5 = Data accumulator
;
;rx_read_bit:
;    shr r5                  ; Shift accumulator right (UART sends LSB first)
;
;    mov r1, [r2]            ; Read input port
;    and r1, r3              ; Isolate UART RX bit
;    cmp r1, #0              ; Check if bit is 0
;    je bit_is_zero          ; If it is 0, skip injecting a 1
;
;    or r5, r6               ; Inject a 1 at the highest bit (using r6 = $80)
;
;bit_is_zero:
;    mov r7, #$028B          ; Load calibrated 1-bit loop count (651 loops)
;    call delay
;
;    dec r4                  ; Decrement our bit counter
;    cmp r4, #0
;    jne rx_read_bit         ; Read the next bit if we haven't reached 8 yet
;
;    ; 8 Data bits received! Wait for Stop Bit (1 bit time)
;    mov r7, #$028B
;    call delay
;
;    ; Output the received character!
;    mov [r8], r5            ; Push accumulator to Output Port
;
;    jmp rx_wait_start       ; Wait for the next character
;
;; ==========================================
;; Delay Subroutine
;; ==========================================
;delay:
;    dec r7                  ; \
;    cmp r7, #0              ;  > 16 cycles
;    jne delay               ; /
;    ret                     ; Return to caller






;    mov sp, #$100           ; Setup stack
;    mov r8, #$6000          ; r8 = Output Port (UART TX is bit 0)
;    mov r1, #$41            ; r1 = The character to send ('A' = hex 41)
;    mov r4, #1              ; r4 = Bitmask for LSB
;
;    ; 1. Ensure UART line is IDLE (HIGH) before starting
;    mov r2, #1
;    mov [r8], r2
;    call delay_1bit
;
;    ; 2. Send START BIT (LOW)
;    mov r2, #0
;    mov [r8], r2
;    call delay_1bit
;
;    ; 3. Send 8 DATA BITS (LSB First)
;    mov r3, #8              ; Set loop counter to 8
;tx_bit_loop:
;    mov r2, r1              ; Copy the character into r2
;    and r2, r4              ; Mask everything except the lowest bit using r4
;    mov [r8], r2            ; Output that single bit to the TX line
;
;    call delay_1bit         ; Wait for 1 bit time
;
;    shr r1                  ; Shift the character right so the next bit is at position 0
;    dec r3                  ; Decrement our loop counter
;    cmp r3, #0              ; Check if we have sent all 8 bits
;    jne tx_bit_loop         ; Keep looping until counter hits 0
;
;    ; 4. Send STOP BIT (HIGH)
;    mov r2, #1
;    mov [r8], r2
;    call delay_1bit
;
;    hlt                     ; Transmission complete. Halt the program.
;
;; ==========================================
;; Subroutine: delay_1bit (9600 Baud)
;; 10,416 cycles / 16 cycles per loop = 651 loops
;; 651 Decimal = $028B Hex
;; ==========================================
;delay_1bit:
;    mov r7, #$028B          ; Load calibrated 1-bit loop count
;delay_loop:
;    dec r7                  ; \
;    cmp r7, #0              ;  > 16 cycles
;    jne delay_loop          ; /
;    ret                     ; Return to caller





;    mov sp, #$100           ; Setup stack
;    mov r8, #$6000          ; r8 = Output Port
;    mov r1, #0              ; r1 = Millisecond counter
;
;main_loop:
;    mov [r8], r1            ; Output the current ms count
;    inc r1                  ; Increment the ms counter
;
;    call delay_1ms          ; Wait exactly 1 millisecond
;
;    jmp main_loop           ; Loop forever
;
;; ==========================================
;; Subroutine: delay_1ms
;; Burns 100,000 cycles for a 100MHz CPU.
;; Inner loop is 16 cycles. 100,000 / 16 = 6,250 iterations.
;; 6,250 Decimal = $186A Hex
;; ==========================================
;delay_1ms:
;    mov r7, #$186A          ; Load 6,250 into our loop counter
;delay_loop:
;    dec r7                  ; \
;    cmp r7, #0              ;  > These 3 instructions take 16 cycles total
;    jne delay_loop          ; /
;    ret                     ; Return to caller






;    mov sp, #$100           ; Setup stack
;    mov r8, #$6000          ; r8 = Output Port (UART TX is bit 0)
;    mov r1, #$41            ; r1 = The character to send ('A' = hex 41)
;    mov r4, #1              ; r4 = Bitmask for LSB (Workaround for no immediate bitwise ops)
;
;    ; 1. Ensure UART line is IDLE (HIGH) before starting
;    mov r2, #1
;    mov [r8], r2
;    call delay_1bit
;
;    ; 2. Send START BIT (LOW)
;    mov r2, #0
;    mov [r8], r2
;    call delay_1bit
;
;    ; 3. Send 8 DATA BITS (LSB First)
;    mov r3, #8              ; Set loop counter to 8
;tx_bit_loop:
;    mov r2, r1              ; Copy the character into r2
;    and r2, r4              ; Mask everything except the lowest bit using r4 (Register-to-Register)
;    mov [r8], r2            ; Output that single bit to the TX line
;
;    call delay_1bit         ; Wait for 1 bit time
;
;    shr r1                  ; Shift the character right so the next bit is at position 0
;    dec r3                  ; Decrement our loop counter
;    cmp r3, #0              ; Check if we have sent all 8 bits
;    jne tx_bit_loop         ; Keep looping until counter hits 0
;
;    ; 4. Send STOP BIT (HIGH)
;    mov r2, #1
;    mov [r8], r2
;    call delay_1bit
;
;    hlt                     ; Transmission complete. Halt the program.
;
;; ==========================================
;; Subroutine: delay_1bit
;; Delays for 1 UART bit time at 9600 baud on a 100MHz CPU.
;; Needs ~10,416 cycles. Loop is ~4 cycles, so 2604 iterations.
;; 2604 in decimal is $0A2C in hex.
;; ==========================================
;delay_1bit:
;    mov r7, #$0A2C          ; Load our calculated loop count
;delay_loop:
;    dec r7                  ; 1 cycle
;    cmp r7, #0              ; 1 cycle
;    jne delay_loop          ; 2 cycles (assumed)
;    ret                     ; Return to caller








;
;    mov sp, #$100           ; Setup stack
;    mov r2, #$6001          ; Store the input port address in r2
;    mov r3, #$6000          ; Store the output port address in r3
;
;echo_loop:
;    mov r1, [r2]            ; Read the current state of the switches/buttons at $6001
;    add r1, #$4
;    mov [r3], r1            ; Instantly write that exact state to the display at $6000
;    jmp echo_loop           ; Loop back and do it again forever
;
;
;






;mov sp, #$100           ; Setup stack
;    mov r2, #$6000          ; Store the 7-segment display address
;    mov r1, #0              ; Initialize our visible counter at 0
;
;main_loop:
;    mov [r2], r1            ; Push the current counter to the 8-digit display
;    inc r1                  ; Increment the visible counter
;
;    call delay_1s           ; Call the 1-second delay subroutine
;
;    jmp main_loop           ; Loop forever

;; ---------------------------------------------------------
;; Subroutine: delay_1s
;; Burns ~100,000,000 cycles for a 100MHz CPU
;; ---------------------------------------------------------
;delay_1s:
;    mov r6, #$007F          ; Outer loop counter (Decimal 127)
;
;outer_loop:
;    cmp r6, #0              ; Check if outer loop is finished
;    je delay_end
;
;    mov r7, #$FFFF          ; Inner loop counter (Decimal 65,535)
;
;inner_loop:
;    nop                     ; Burn 4 cycles
;    nop                     ; Burn 4 cycles
;    dec r7                  ; Decrement inner counter (Assume 1 cycle)
;    cmp r7, #0              ; Check if inner loop is finished (Assume 1 cycle)
;    jne inner_loop          ; Jump if not equal (Assume 2 cycles)
;
;inner_end:
;    dec r6                  ; Decrement outer loop counter
;    jmp outer_loop          ; Loop back to outer
;
;delay_end:
;    ret                     ; Return to main loop


;    mov sp, #$100           ; Setup stack
;    mov r5, #$6000          ; Address for output display
;
;    mov r1, #10             ; 'n' - The Fibonacci number we want to find (e.g., 10th)
;
;    mov r2, #0              ; F(n-2) starting at 0
;    mov r3, #1              ; F(n-1) starting at 1
;
;    ; Handle the edge case where n = 0
;    cmp r1, #0
;    je is_zero
;
;fib_loop:
;    cmp r1, #1              ; If n reaches 1, our answer is in r3
;    je fib_end
;
;    mov r4, r2              ; Copy F(n-2) into r4 (temporary register)
;    add r4, r3              ; Add F(n-1) to r4 to get the NEW Fibonacci number
;
;    mov r2, r3              ; Shift the window: F(n-2) becomes the old F(n-1)
;    mov r3, r4              ; Shift the window: F(n-1) becomes the new number
;
;    dec r1                  ; Decrement our 'n' counter
;    jmp fib_loop            ; Repeat until n == 1
;
;is_zero:
;    mov r3, r2              ; If n=0, our answer is 0 (which is in r2). Move it to r3 for printing.
;
;fib_end:
;    mov [r5], r3            ; Write the final calculated number to the display
;    hlt                     ; Halt program




;    mov sp, #$100
;    mov r5, #$6000          ; Display address
;
;    mov r2, #0              ; F(n-2)
;    mov r3, #1              ; F(n-1)
;
;    mov [r5], r2            ; Print 0
;    call delay_1s
;
;    mov [r5], r3            ; Print 1
;    call delay_1s
;
;fib_loop:
;    mov r4, r2              ; r4 = F(n-2)
;    add r4, r3              ; r4 = F(n)
;
;    mov [r5], r4            ; Display next Fibonacci number
;    call delay_1s
;
;    mov r2, r3              ; Shift window
;    mov r3, r4
;
;    jmp fib_loop
;
;; ---------------------------------------------------------
;; Subroutine: delay_1s
;; Burns ~100,000,000 cycles for a 100MHz CPU
;; ---------------------------------------------------------
;delay_1s:
;    mov r6, #$007F          ; Outer loop counter (Decimal 127)
;
;outer_loop:
;    cmp r6, #0              ; Check if outer loop is finished
;    je delay_end
;
;    mov r7, #$FFFF          ; Inner loop counter (Decimal 65,535)
;
;inner_loop:
;    nop                     ; Burn 4 cycles
;    nop                     ; Burn 4 cycles
;    dec r7                  ; Decrement inner counter (Assume 1 cycle)
;    cmp r7, #0              ; Check if inner loop is finished (Assume 1 cycle)
;    jne inner_loop          ; Jump if not equal (Assume 2 cycles)
;
;inner_end:
;    dec r6                  ; Decrement outer loop counter
;    jmp outer_loop          ; Loop back to outer
;
;delay_end:
;    ret                     ; Return to main loop
;












;mov sp, #$100           ; Setup stack
;    mov r4, #$6000          ; Address for output display
;    mov r5, #$7000          ; Memory pointer to record the sequence history
;
;    mov r1, #15             ; Our starting number (n = 15)
;    mov r2, #0              ; Step counter
;    mov r3, #1              ; Constant 1 (used for math and bit-masking)
;
;collatz_loop:
;    mov [r5], r1            ; Record current 'n' into memory
;    inc r5                  ; Move memory pointer to the next address
;
;    cmp r1, #1              ; Check if we have reached 1
;    je collatz_end          ; If n == 1, the sequence is complete
;
;    inc r2                  ; We are taking a step, so increment counter
;
;    ; Determine if 'n' is even or odd
;    mov r6, r1              ; Copy 'n' into r6 so we don't destroy it
;    and r6, r3              ; Bitwise AND with 1. If r6 becomes 0, 'n' is even.
;    cmp r6, #0              ; Check the result
;    je is_even              ; Jump to even logic if the lowest bit was 0
;
;is_odd:
;    ; Math: n = (3 * n) + 1
;    mul r1, #3              ; Multiply n by 3
;    add r1, #1              ; Add 1
;    jmp collatz_loop        ; Loop back around
;
;is_even:
;    ; Math: n = n / 2
;    shr r1                  ; Shift right by 1 bit (which divides by 2)
;    jmp collatz_loop        ; Loop back around
;
;collatz_end:
;    mov [r4], r2            ; Output the total number of steps to the display
;    hlt                     ; Halt program
;
;




;    mov sp, #$100             ; Setup stack
;    mov r2, #$6000            ; Store memory mapped address
;                              ;  (0x6000) of output display
;
;    call print_func
;    hlt                       ; Halt program
;
;print_func:
;    mov r8, #$0               ; Initalize counter with 0
;    mov r6, message           ; Initalize counter with 0
;func_loop:
;    mov r1, [r8+message]
;    cmp r1, #0                 ; Check if char is null
;    je func_end                ; If it is, end
;    mov [r2], r1               ; Put next char in output
;    inc r8                     ; Increment char ptr
;    jmp func_loop              ; Loop
;func_end:
;    ret                        ; Return from method
;
;
;message: .asciiz "Hello World!"
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;;print_hex_r3:
;;    push r3
;;   ; cmp r3, #$0
;;;    jne not_zero
;;;is_zero:
;;;    mov r2, #$30
;;;    mov $6000, r2
;;
;;;    jmp print_hex_end
;;;not_zero:
;;;    mov r5, r3
;;;    mov r4, LEFT_BIT
;;;    and r5, r4
;;;    cmp r5, #$0
;;;    je not_zero
;;
;;print_hex_loop:
;;    cmp r3, #0
;;    je print_hex_end
;;
;;    mov r5, r3
;;
;;    shr r5
;;    shr r5
;;    shr r5
;;    shr r5
;;    shr r5
;;    shr r5
;;    shr r5
;;
;;    add r5, #$30
;;    mov [r2], r5
;;
;;    shl r3
;;    shl r3
;;    shl r3
;;    shl r3
;;    jmp print_hex_loop
;;
;;
;;print_hex_end:
;;    pop r3
;;    ret
;;
;;
;;
;;
;;    ;LEFT_BIT: .res $f000000
;;
;;
;;
;;
;;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;
;;     mov sp, #$100           ; Setup stack
;;     mov r8, #$0             ; Initalize counter with 0
;; loop:
;;     mov r1, [r8+message]    ; Load next letter
;;     cmp r1, #0              ; Check if char is null
;;     je end                  ; If it is, end
;;     mov $6000, r1           ; Write char to output
;;     inc r8                  ; Increment counter
;;     jmp loop                ; Loop
;;end:
;;     hlt
;
;
;;loop:
;;    mov r4, message         ; Set
;;    call printf
;;    ;mov r4, message2         ; Set
;;    ;call printf
;;    hlt
;
;; set r4 ptr to string
;;printf:
;;    mov r8, #$0             ; Initalize counter with 0
;;    mov r1, #$0
;;    mov r2, #$0
;;printfloop:
;;    mov r2, r4
;;    add r2, r8
;;    mov r1, [r2]            ; Load next letter
;;    cmp r1, #0              ; Check if char is null
;;    je printfend            ; If it is, end
;;    mov $6000, r1           ; Write char to output
;;    inc r8                  ; Increment counter
;;    jmp printfloop          ; Loop
;;printfend:
;;    ret
;;
;;message:    .asciiz "Hello World!"
;;message2:    .asciiz "Hello World!"
;
;
;
;
;
;
;
;;     mov sp, #$100           ; Setup stack
;;     mov r8, #$0             ; Initalize counter with 0
;; loop:
;;     mov r1, [r8+message]    ; Load next letter
;;     cmp r1, #0              ; Check if char is null
;;     je end                  ; If it is, end
;;     mov $6000, r1           ; Write char to output
;;     inc r8                  ; Increment counter
;;     jmp loop                ; Loop
;; end:
;;     hlt
;; message:    .asciiz "Hello assembler!"