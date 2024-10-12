;Реализовать функцию, которая для заданного числа n
; определяет, что все его цифры следуют в неубывающем порядке.

format elf64 
public _start
include "funcnew.asm"

section '.bss' writable
   place db ";oiuygf", 0
   no db "no", 0
   yes db "yes", 0
   msg rb 255
   n dq 0
   ost dq 0
section '.text' executable

_start:
   mov rax, 0
   mov rdi, 0
   mov rsi, msg
   mov rdx, 255
   syscall

   xor rdx, rdx
   xor rax, rax
   call str_number
   mov [n], rax
   mov rax, [n]
   mov rbx, 10
   div rbx
   mov [ost], rbx
   mov rdx, 0
   checkost:
        mov rcx, rax
        mov rbx, 10
        div rbx ;ost in rbx
        cmp [ost], rbx
        jnae ohno
        inc rdx
        mov [ost], rbx
        cmp rax, 0
        je ohyes
    jmp checkost

    ohno:
        mov rax, 4
        mov rbx, 1
        mov rcx, [no]
        mov rdx, 8
        syscall

    ohyes:
        mov rax, 4
        mov rbx, 1
        mov rcx, [yes]
        mov rdx, 8
        syscall

   call exit