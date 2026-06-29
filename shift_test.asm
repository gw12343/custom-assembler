; Initialize r2 for the "shift by register" tests.
; We use #3 for an immediate value.
mov r2, #3

; ==========================================
; 1. TEST SHR (Logical Shift Right)
; ==========================================
mov r1, test_val
shr r1              ; Mode 1: Shift right by 1
call print_binary
call send_newline

mov r1, test_val
shr r1, #3          ; Mode 2: Shift right by immediate 3
call print_binary
call send_newline

mov r1, test_val
shr r1, r2          ; Mode 3: Shift right by value in r2 (3)
call print_binary
call send_newline
call send_newline   ; Extra newline for visual spacing

; ==========================================
; 2. TEST SHL (Logical Shift Left)
; ==========================================
mov r1, test_val
shl r1              ; Mode 1: Shift left by 1
call print_binary
call send_newline

mov r1, test_val
shl r1, #3          ; Mode 2: Shift left by immediate 3
call print_binary
call send_newline

mov r1, test_val
shl r1, r2          ; Mode 3: Shift left by value in r2 (3)
call print_binary
call send_newline
call send_newline

; ==========================================
; 3. TEST ASR (Arithmetic Shift Right)
; ==========================================
mov r1, test_val
asr r1              ; Mode 1: ASR by 1 (Sign bit preserved)
call print_binary
call send_newline

mov r1, test_val
asr r1, #3          ; Mode 2: ASR by immediate 3
call print_binary
call send_newline

mov r1, test_val
asr r1, r2          ; Mode 3: ASR by value in r2 (3)
call print_binary
call send_newline
call send_newline

; ==========================================
; 4. TEST ROL (Rotate Left)
; ==========================================
mov r1, test_val
rol r1              ; Mode 1: Rotate left by 1
call print_binary
call send_newline

mov r1, test_val
rol r1, #3          ; Mode 2: Rotate left by immediate 3
call print_binary
call send_newline

mov r1, test_val
rol r1, r2          ; Mode 3: Rotate left by value in r2 (3)
call print_binary
call send_newline
call send_newline

; ==========================================
; 5. TEST ROR (Rotate Right)
; ==========================================
mov r1, test_val
ror r1              ; Mode 1: Rotate right by 1
call print_binary
call send_newline

mov r1, test_val
ror r1, #3          ; Mode 2: Rotate right by immediate 3
call print_binary
call send_newline

mov r1, test_val
ror r1, r2          ; Mode 3: Rotate right by value in r2 (3)
call print_binary
call send_newline
call send_newline

hlt

; --- DATA SECTION ---
; Using a 32-bit test value that starts with a 1 (to properly test ASR sign-extension)
; and has an asymmetrical pattern so rotates are clearly visible.
test_val: .resw %10001111000010101100001111010101