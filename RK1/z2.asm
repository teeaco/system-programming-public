
format elf64 
public _start
include "funcnew.asm"

section '.bss' writable
   place db "HHHHHHHHH", 0
   msg rb 255
   n dq 0
   num dq 0

section '.text' executable

_start:
   mov rax, 0
   mov rdi, 0
   mov rsi, msg
   mov rdx, 255
   syscall
   mov rsi, msg
   xor rdx, rdx
   xor rax, rax
   call str_number
   mov [n], rax
   mov r9, [n]
   ;call print_int
   call new_line
   sum:
        call cycle
        dalsh:
            dec r9
            cmp r9, 0
            je exit
        jmp sum

   call exit




cycle:
    mov rax, [n]
    itera:
        mov rsi, msg
        call number_str ;out rsi
        ;call reverse
        d:
        call print_str ;inp rsi 
        call new_line
        cmp rax, 0
        je exit
        dec rax
        jmp itera
    jmp dalsh


reverse: ;input/output rsi 
;через стек!!!
    ;push rsi
    call str_number ;rax
    call number_str
    ;mov r8, 1
    ;iter:
     ;   mov rbx, rax
      ;  xor rdx, rdx
       ; mov rcx, 10
        ;div rcx ;частное rax, ost rdx
        ;push rdx
        ;cmp rax, 0
        ;je do
        ;push rax
        ;push rdx
        ;xor rax, rax
        ;mov rdx, 10
        ;mov rax, 1
        ;mul rdx
        ;mov r8, rax
        ;pop rax
    ;jmp iter
        ;do:
        ;xor rbx, rbx
        ;mov rbx, 1
        ;push rax
        ;mul rbx
        ;mov r10, rax
        ;mov rbx, 10
        ;mul rbx
        ;cmp rbx, r8
        ;xor rsi, rsi
        ;pop rsi
        ;mov rsi, [rax] ;r10
        ;pop rax
        ;je d
        ;jmp do