;1. перевод из строки в число
;input rsi
;output rsi
str_to_int:
    push rsi
    push rbx
    push rcx
    push rdx
    xor rax, rax
    xor rdx, rdx
    mov rcx, 10
    itera:
        mov byte bl, [rsi + rdx]
        
        cmp bl, '0'
        jl next
        cmp bl, '9'
        jg next
        sub bl, '0'
        add rax, rbx
        cmp byte [rsi+rdx+1], 0
        je next
        push rdx
        mov rcx, 10
        mul rcx
        pop rdx
        inc rdx
    jmp itera
    next:
    pop rdx
    pop rcx
    pop rbx
    pop rsi
  ret

;2. перевод из чисоа в строку
;The function converts the nubmer to string
;input rax - number
;rsi -address of begin of string
number_str:
  push rbx
  push rcx
  push rdx
  xor rcx, rcx
  mov rbx, 10
  .loop_1:
    xor rdx, rdx
    div rbx
    add rdx, 48
    push rdx
    inc rcx
    cmp rax, 0
    jne .loop_1
  xor rdx, rdx
  .loop_2:
    pop rax
    mov byte [rsi+rdx], al
    inc rdx
    dec rcx
    cmp rcx, 0
  jne .loop_2
  mov byte [rsi+rdx], 0   
  pop rdx
  pop rcx
  pop rbx
  ret


;3. цикл с условием для выхода
;rdi - true false 
;rax - счетчик
itera:
  cmp rdi, 1
  jmp print_int ;for instance
  inc rbx
  cmp rbx, 0
  jmp exit
jmp itera

;4. условие как функция rdi 0 1
;rax
mov rdi, 0
cmp rax, chtoto
mov rdi, 1

;5. new_line

;The function makes new line
new_line:
   push rax
   push rdi
   push rsi
   push rdx
   push rcx
   mov rax, 0xA
   push rax
   mov rdi, 1
   mov rsi, rsp
   mov rdx, 1
   mov rax, 1
   syscall
   pop rax
   pop rcx
   pop rdx
   pop rsi
   pop rdi
   pop rax
   ret

;6. print int
; in out put rax
print_int:

    mov rcx, 10
    xor rbx, rbx
    .iter1:
      xor rdx, rdx
      div rcx
      add rdx, '0'
      push rdx
      inc rbx
      cmp rax,0
    jne .iter1
    .iter2:
      pop rax
      call print_symbl
      dec rbx
      cmp rbx, 0
    jne .iter2

7. print str

;input rsi - place of memory of begin string
;Function printing of string
;input rsi - place of memory of begin string
print_str:
    push rax
    push rdi
    push rdx
    push rcx
    mov rax, rsi
    call len_str
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall
    pop rcx	
    pop rdx
    pop rdi
    pop rax
    ret

;input rax - place of memory of begin string
;output rax - length of the string
len_str:
  push rdx
  mov rdx, rax
  .iter:
      cmp byte [rax], 0
      je .next
      inc rax
      jmp .iter
  .next:
     sub rax, rdx
     pop rdx
     ret

   print_symbl:
     push rbx
     push rdx
     push rcx
     push rax
     push rax
     mov eax, 4
     mov ebx, 1
     pop rdx
     ;mov [place], dl
     ;mov ecx, place
     mov edx, 1
     int 0x80
     pop rax
     pop rcx
     pop rdx
     pop rbx
     ret
