format ELF64
public _start
public exit

section '.bss' writable
my db 0xA, "dCvNLCHIwRBfHrlibTfnOuAfqXhQskBnlVMtoFF"

section '.text' executable
_start:
  mov rcx, 52
  .iter:
    push rcx

    mov rax, my
    add rax, rcx
    mov rcx, rax 

    mov rax, 4
    mov rbx, 1

    mov rdx, 1
    int 0x80

    pop rcx

    dec rcx
    cmp rcx, -1
    jne .iter


  call exit


exit:
  mov rax, 1
  xor rbx, rbx
  int 0x80
