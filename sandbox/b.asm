format ELF
public _start
msg db "Bronnikova", 0xA, "Maria", 0xA, "Evgenievna", 0xA, 0

_start:
    ;инициализация регистров для вывода информации на экран
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, 29
    int 0x80
    ;инициализация регистров для успешного завершения работы программы
    mov eax, 1
    mov ebx, 0
    int 0x80