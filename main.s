section .data 
  msg_num1 db "Enter first number: "
  msg_num1_len equ $ - msg_num1

  msg_num2 db "Enter second number: "
  msg_num2_len equ $ - msg_num2 

  msg_oper db "Enter an operator: " 
  msg_oper_len equ $ - msg_oper

  msg_notanum db "Input is not a number!", 0xA
  msg_notanum_len equ $ - msg_notanum

  msg_invalidoper db "Invalid operator entered!", 0xA
  msg_invalidoper_len equ $ - msg_invalidoper

  msg_result db "Result: "
  msg_result_len equ $ - msg_result

  newline db 0xA

section .bss
  x resb 64
  y resb 64 
  oper resb 2
  result_buffer resb 64

section .text 
  global _start

_start:
  ; First number
  mov rax, msg_num1
  mov rdi, msg_num1_len
  call print

  mov rax, x
  mov rdi, 64
  call input
  mov rdi, rax
  mov rax, x
  call trimNewline
  
  call printNl
  
  mov rsi, x 
  call checkInt
  
  ; Convert x to integer
  mov rsi, x
  call atoi
  mov r12, rax    ; Store first number in r12

  
  ; Second number
  mov rax, msg_num2
  mov rdi, msg_num2_len
  call print

  mov rax, y
  mov rdi, 64
  call input
  mov rdi, rax
  mov rax, y
  call trimNewline
  
  call printNl
  
  mov rsi, y
  call checkInt
  
  ; Convert y to integer
  mov rsi, y
  call atoi
  mov r13, rax    ; Store second number in r13

  ; Operator
  mov rax, msg_oper
  mov rdi, msg_oper_len
  call print

  mov rax, oper
  mov rdi, 2
  call input
  mov rdi, rax
  mov rax, oper
  call trimNewline
  
  call printNl

  call isValidOper
  cmp rax, 0
  je notValidOper

  call calculate

  jmp sys_exit

printNl:
  mov rax, newline
  mov rdi, 1
  call print
  ret

; rax=buffer, rdi=bytes_read
trimNewline:
  push rbx
  push r10
  mov r10, rax
  mov rbx, 0
  
trim_loop:
  cmp rbx, rdi
  jge trim_done
  
  mov r8b, [r10 + rbx]  
  cmp r8b, 10
  jne trim_next
  
  mov byte [r10 + rbx], 0
  jmp trim_done
  
trim_next:
  inc rbx
  jmp trim_loop
  
trim_done:
  mov rax, r10      
  pop r10
  pop rbx
  ret

print:
  push rax
  push rdi
  push rsi
  push rdx
  
  mov rsi, rax
  mov rdx, rdi
  mov rax, 1
  mov rdi, 1
  syscall
  
  pop rdx
  pop rsi
  pop rdi
  pop rax
  ret

input:
  push rdi
  push rsi
  push rdx
  
  mov rsi, rax
  mov rdx, rdi
  mov rax, 0
  mov rdi, 0
  syscall
  
  pop rdx
  pop rsi
  pop rdi
  ret

isInt:
  xor r9, r9
  
isIntLoop:
  mov r8b, byte [rax + r9]
  test r8b, r8b
  jz returnTrue

  cmp r8b, 48
  jl returnFalse

  cmp r8b, 57
  jg returnFalse

  inc r9
  jmp isIntLoop

returnFalse:
  mov rax, 0
  ret

returnTrue:
  mov rax, 1
  ret

notANumber:
  mov rax, msg_notanum
  mov rdi, msg_notanum_len
  call print 
  jmp sys_exit

checkInt:
  push rsi
  mov rax, rsi 
  call isInt
  cmp rax, 1
  jne notANumber
  pop rsi
  ret

isValidOper:
  mov rax, oper

  cmp byte [rax], 43  ; '+'
  je validOper

  cmp byte [rax], 45  ; '-'
  je validOper

  cmp byte [rax], 47  ; '/'
  je validOper

  cmp byte [rax], 42  ; '*'
  je validOper

  mov rax, 0
  ret

validOper:
  mov rax, 1
  ret

notValidOper:
  mov rax, msg_invalidoper
  mov rdi, msg_invalidoper_len
  call print 
  jmp sys_exit

; Convert string to integer
; Input: rsi = pointer to string
; Output: rax = integer value
atoi:
  push rbx
  push rcx
  
  xor rax, rax        ; result = 0
  xor rbx, rbx        ; temp for digit
  
atoi_loop:
  movzx rbx, byte [rsi]
  test rbx, rbx       ; null terminator?
  jz atoi_done
  
  sub rbx, 48         ; ASCII to digit ('0' = 48)
  imul rax, 10        ; result *= 10
  add rax, rbx        ; result += digit
  inc rsi
  jmp atoi_loop
  
atoi_done:
  pop rcx
  pop rbx
  ret

; Convert integer to string
; Input: rax = integer value
; Output: result_buffer contains string, rax = length
itoa:
  push rbx
  push rcx
  push rdx
  push rsi
  
  mov rsi, result_buffer
  add rsi, 63         ; Point to end of buffer
  mov byte [rsi], 0   ; Null terminator
  dec rsi
  
  mov rbx, 10         ; Divisor
  xor rcx, rcx        ; Counter
  
  test rax, rax       ; Check if zero
  jnz itoa_loop
  
  ; Handle zero case
  mov byte [rsi], '0'
  inc rcx
  jmp itoa_done
  
itoa_loop:
  xor rdx, rdx        ; Clear rdx for division
  div rbx             ; rax / 10, remainder in rdx
  add dl, 48          ; Convert to ASCII
  mov [rsi], dl       ; Store digit
  dec rsi
  inc rcx             ; Increment counter
  
  test rax, rax       ; Check if done
  jnz itoa_loop
  
itoa_done:
  inc rsi             ; Adjust to first digit
  mov rax, rcx        ; Return length
  mov rdi, rsi        ; Return pointer in rdi
  
  pop rsi
  pop rdx
  pop rcx
  pop rbx
  ret

calculate:
  mov al, byte [oper]

  cmp al, 43          ; '+'
  je do_add

  cmp al, 45          ; '-'
  je do_subtract

  cmp al, 47          ; '/'
  je do_divide

  cmp al, 42          ; '*'
  je do_multiply

do_add:
  mov rax, r12
  add rax, r13
  jmp printOutput

do_subtract:
  mov rax, r12
  sub rax, r13
  jmp printOutput

do_divide:
  mov rax, r12
  xor rdx, rdx        ; Clear rdx for division 
  div r13             ; Unsigned division: rax / r13
  jmp printOutput

do_multiply:
  mov rax, r12
  imul rax, r13       ; Signed multiplication 
  jmp printOutput

printOutput:
  push rax
  
  ; Print "Result: " message
  mov rax, msg_result
  mov rdi, msg_result_len
  call print
  
  pop rax
  
  ; Convert to string
  call itoa
  
  ; Print result (rdi has pointer, rax has length)
  mov rsi, rdi
  mov rdx, rax
  mov rax, 1
  mov rdi, 1
  syscall
  
  ; Print newline
  mov rax, 1
  mov rdi, 1
  mov rsi, newline
  mov rdx, 1
  syscall
  
  ret

sys_exit:
  mov rax, 60
  mov rdi, 0
  syscall

