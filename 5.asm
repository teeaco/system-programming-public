format elf64
public _start

include 'func.asm' 

section '.bss' writable
  buffer rb 100               ; Буфер для чтения строки из файла
  sent_buf rb 100             ; buf for sentence
  buf64 rb 64
  buf2 rb 64
  stro dq 0
  swing_buf rb 100            ; Buffer for swinging pattern characters
  buf_index dq 0              ; Index forzalooping
  rev_buf rb 100

section '.data' writable
  endfile db '10e', 0         ; Имя второго файла для записи

section '.text' executable

_start:
  ;; Открываем первый файл для чтения
  mov rdi, [rsp+16]            ; Имя первого файла из аргументов командной строки
  mov rax, 2               ; Системный вызов open
  mov rsi, 0o                 ; O_RDONLY (режим только для чтения)
  syscall
  cmp rax, 0
  jl l1

  mov r8, rax                 ; Сохраняем дескриптор первого файла в r8

  ;; Открываем второй файл для записи
  mov rdi, [rsp + 24]            ; Имя второго файла
  mov rax, 2                  ; Системный вызов open
  mov rsi, 577                ; O_WRONLY | O_CREAT | O_TRUNC (для записи, создать, если не существует)
  mov rdx, 777o               ; Права доступа к файлу
  syscall
  cmp rax, 0
  jl l1
  mov r10, rax                ; Сохраняем дескриптор второго файла в r10
  mov r9, [rsp + 32]
  ;; Читаем содержимое первого файла в buffer
  mov rax, 0                  ; Системный вызов read
  mov rdi, r8                 ; Дескриптор первого файла
  mov rsi, buffer             ; Куда читать (в buffer) 
  mov rdx, 100                ; Сколько читать (до 100 байт)
  syscall
  mov r9, rax                 ; Сохраняем количество прочитанных байт в r9

  ; Set initial values for k and m from command-line args
  mov rbx, [rsp + 32]         ; Load k (starting position)
  mov rsi, rbx
  call str_number
  mov rbx, rax

  ;push rsi
   ; push rax 
    ;mov rax, rbx
    ;mov rsi, buf2
    ;call number_str
    ;call print_str

    ;pop rax
    ;pop rsi

  mov rcx, [rsp + 40]         ; Load m (length for swinging order)
  mov rsi, rcx
  call str_number
  mov rcx, rax

  mov rsi, buffer             ; Устанавливаем rsi на начало буфера
  mov rdi, sent_buf          
  mov rdx, rcx                ; Длина для записи
  xor rax, rax
  xor r9, r9                   ; Флаг направления (0 для +, 1 для -)
  
  maiatnik_loop:
    cmp rax, rdx                 ; Проверка, достигли ли нужного количества символов
    je write_sentence            
    
    ; Чтение символа из текущей позиции
    
    mov al, [rsi + rbx]
    call exit
    mov [rdi + rax], al          ; Запись символа в буфер

    inc rax                      ; Увеличение счётчика записанных символов

    ; Чередование направления
    test r9, r9                  ; Проверка флага направления
    jz forward                   ; Если r9 = 0, прибавляем шаг
    sub rbx, rcx                 ; Если r9 = 1, вычитаем шаг
    jmp toggle_direction

forward:
    add rbx, rcx                 ; Прибавляем шаг к позиции

toggle_direction:
    xor r9, 1                    ; Меняем направление (0 -> 1, 1 -> 0)
    inc rcx                      ; Увеличиваем шаг для следующей итерации
    jmp maiatnik_loop            ; Переход к следующей итерации

    
  ;; Завершение программы
l1:
  call exit

write_sentence:
  push rdi
  push rsi
  push rax
  push rbx
  push rcx
  push rdx
 ;call print_str
 
  mov rax, 1                  ; Системный вызов write
  mov rdi, r10                ; Дескриптор второго файла
  syscall
  pop rdx
  pop rcx
  pop rbx
  pop rax
  pop rsi
  pop rdi
  ret
