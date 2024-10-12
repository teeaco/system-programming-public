;Написать программу, которая для заданного n
; позволяет определить, сколько целых чисел между 1 и n
; не делятся на 11 или на 5.

format elf64 
public _start
include "funcnew.asm"

section '.bss' writable
   place db ";oiuygf", 0
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

   xor rdx, rdx
   xor rax, rax
   call str_number
   mov [n], rax
   mov rbx, 1 ;[1, n]
   mov rcx, 0 ;number of numbers who int % 55 != 0
   count:
      mov rax, rbx
      mov rdx, 55  ;floating point exception
      div rdx
      cmp rdx, 0
      inc rbx
      cmp rbx, [n]
      je exit
      call new_line
      cmp rbx, [n]
      inc rcx
      je exit
      inc rbx
   jmp count
   mov [num], rcx ;на всякий ;not sure
   mov rax, 4
   mov rbx, 1
   mov rcx, [num]
   mov rdx, 124
   syscall

   call exit