format elf64
public _start

include 'func.asm'

section '.data' writable
buffer rb 100

section '.text' executable

_start:
   pop rcx
   cmp rcx, 5 
   jne .l1 

   ;open 1 file
   mov rdi,[rsp+8] ;файл 1
   mov rax, 2 
   mov rsi, 0o ;Права только на чтение
   syscall
   cmp rax, 0 ;ошибка открытия файла
   jl .l1
   
   mov r8, rax ;файловый дескриптор

   ;openn 2 file
   mov rdi,[rsp+16] 
   mov rax, 2 
   ;;Формируем O_WRONLY|O_TRUNC|O_CREAT
   mov rsi, 577
   mov rdx, 777o
   syscall 
   cmp rax, 0 
      jl .l1
   mov r9, rax         ; file 2

  mov rsi, [rsp+24] ;k
  call str_number
  mov r10, rax

  mov rsi, [rsp+32] ;m
  call str_number
  mov r11, rax

    sub r10, r11             ; k - m
    mov r12, r10             ; k - m = r12
    add r10, r11             ; k + m

.loop_read: ;чтение из файла
   mov rax, 0            
   mov rdi, r8           
   mov rsi, buffer       
   mov rdx, 100         
   syscall               ; системный вызов read
   cmp rax, 0            ; if 0 байт (EOF)
   je .next             

   ; k - m
    mov rbx, rax            ; сохраняем количество прочитанных байт в rbx
    lea r13, [buffer + r10] ; устанавливаем указатель на k - m
    lea r14, [buffer + r10] 
    mov rdi, r9


.write_char:

    cmp r12, r10            ; сравниваем [k - m , k + m] 
    jg .next               ; едем вправо

    cmp r13, r14           ; left <- -> право

    je .skip               ;r13 - r14 +
    mov rax, 1              ; системный вызов для записи
    mov rsi, r14            ; k - m
    mov rdx, 1              ; записываем 1 байт
    syscall
    .skip:
    mov rax, 1              ; системный вызов для записи
    mov rsi, r13           ; k + m
    mov rdx, 1              ; записываем 1 байт
    syscall

    dec r10                  
    inc r14
    dec r13                  ; переходим к предыдущему символу
    jmp .write_char       

   jmp .loop_read        
 
.next:   ;;Системный вызов close
   mov rdi, r8
   mov rax, 3
   syscall
   
.l1:
   call exit