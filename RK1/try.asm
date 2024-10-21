format elf64 
public _start
include "funcnew.asm"

section '.bss' writable
    place rb 64
   msg rb 64
   buf1 rb 64
   buf2 rb 64
   tests db "1234050100", 0
   N dq 0
   num dq 0
   SUM dq 0

section '.text' executable

_start:

    mov rsi, buf2
    call input_keyboard
    call str_number
    mov [N], rax

    mov rsi, buf2
    
    mov rcx, [N]
    .iter:
        mov rax, rcx
        call number_str
        mov rdi, buf1
        call RevPr
        mov rsi, rdi
        call str_number ;;получили rax = rev(int)
        add [SUM], rax
        loop .iter

    mov rax, [SUM]
    call number_str
    call print_str
    call exit

;функция которая проходит н раз. взять число buff rb 256 cложить buff rb 256
;функция преобразования числа в строку внутри цикла перебор rax [0, n]
;перед циклом rsi в буфер, reverse_string_nozero
;len строки mov r9, len     mov byte dl [rsi + rdx]
; rsi, rdi -> rdi = rsi^-1
RevPr:
    push rax
    push rsi
    push rdi
    push rcx
    push rbx
    push rdx 

    mov rax, rsi
    call len_str  
    mov rdx, rax ;rdx=len
    
    mov rax, 1
    dec rdx
    xor rcx, rcx
    .iter:

        mov byte bl, [rsi+rdx]
        cmp bl, '0'
        jne .n 
        cmp rax, 1
        je .en
        .n:
        mov rax, 0
        mov byte [rdi+rcx], bl
        inc rcx
        .en:
        dec rdx
        cmp rdx,-1
        jne .iter

    pop rdx
    pop rbx
    pop rcx
    pop rdi
    pop rsi
    pop rax

    ret
