    mov sp, #$100             ; Setup stack
    mov r2, #$6000            ; Store memory mapped address
                              ;  (0x6000) of output display

    call print_func
    hlt                       ; Halt program

print_func:
    mov r8, #$0               ; Initalize counter with 0
    mov r6, message           ; Initalize counter with 0
func_loop:
    mov r1, [r8+message]
    cmp r1, #0                 ; Check if char is null
    je func_end                ; If it is, end
    mov [r2], r1               ; Put next char in output
    inc r8                     ; Increment char ptr
    jmp func_loop              ; Loop
func_end:
    ret                        ; Return from method


message: .asciiz "Hello World!"
mov r2, #$6000














































































;print_hex_r3:
;    push r3
;   ; cmp r3, #$0
;;    jne not_zero
;;is_zero:
;;    mov r2, #$30
;;    mov $6000, r2
;
;;    jmp print_hex_end
;;not_zero:
;;    mov r5, r3
;;    mov r4, LEFT_BIT
;;    and r5, r4
;;    cmp r5, #$0
;;    je not_zero
;
;print_hex_loop:
;    cmp r3, #0
;    je print_hex_end
;
;    mov r5, r3
;
;    shr r5
;    shr r5
;    shr r5
;    shr r5
;    shr r5
;    shr r5
;    shr r5
;
;    add r5, #$30
;    mov [r2], r5
;
;    shl r3
;    shl r3
;    shl r3
;    shl r3
;    jmp print_hex_loop
;
;
;print_hex_end:
;    pop r3
;    ret
;
;
;
;
;    ;LEFT_BIT: .res $f000000
;
;
;
;
;

















































































;     mov sp, #$100           ; Setup stack
;     mov r8, #$0             ; Initalize counter with 0
; loop:
;     mov r1, [r8+message]    ; Load next letter
;     cmp r1, #0              ; Check if char is null
;     je end                  ; If it is, end
;     mov $6000, r1           ; Write char to output
;     inc r8                  ; Increment counter
;     jmp loop                ; Loop
;end:
;     hlt


;loop:
;    mov r4, message         ; Set
;    call printf
;    ;mov r4, message2         ; Set
;    ;call printf
;    hlt

; set r4 ptr to string
;printf:
;    mov r8, #$0             ; Initalize counter with 0
;    mov r1, #$0
;    mov r2, #$0
;printfloop:
;    mov r2, r4
;    add r2, r8
;    mov r1, [r2]            ; Load next letter
;    cmp r1, #0              ; Check if char is null
;    je printfend            ; If it is, end
;    mov $6000, r1           ; Write char to output
;    inc r8                  ; Increment counter
;    jmp printfloop          ; Loop
;printfend:
;    ret
;
;message:    .asciiz "Hello World!"
;message2:    .asciiz "Hello World!"







;     mov sp, #$100           ; Setup stack
;     mov r8, #$0             ; Initalize counter with 0
; loop:
;     mov r1, [r8+message]    ; Load next letter
;     cmp r1, #0              ; Check if char is null
;     je end                  ; If it is, end
;     mov $6000, r1           ; Write char to output
;     inc r8                  ; Increment counter
;     jmp loop                ; Loop
; end:
;     hlt
; message:    .asciiz "Hello assembler!"