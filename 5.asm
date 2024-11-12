format elf64
public _start

include 'f.asm' 

section '.bss' writable
  buffer rb 100               ; Буфер для чтения строки из файла
  rev_buf rb 1                ; Буфер для одного символа
  buf64 rb 64

section '.data' writable
  endfile db '10e', 0         ; Имя второго файла для записи

section '.text' executable

_start:
  ;; Открываем первый файл для чтения
  mov rdi, [rsp+16]           ; Имя первого файла из аргументов командной строки
  mov rax, 2                  ; Системный вызов open
  mov rsi, 0o                 ; O_RDONLY (режим только для чтения)
  syscall
  cmp rax, 0
  jl l1
  mov r8, rax                 ; Сохраняем дескриптор первого файла в r8

  ;; Открываем второй файл для записи
  mov rdi, [rsp + 24]         ; Имя второго файла
  mov rax, 2                  ; Системный вызов open
  mov rsi, 577                ; O_WRONLY | O_CREAT | O_TRUNC
  mov rdx, 777o               ; Права доступа к файлу
  syscall
  cmp rax, 0
  jl l1
  mov r10, rax                ; Сохраняем дескриптор второго файла в r10

  ;; Читаем содержимое первого файла в buffer
  mov rax, 0                  ; Системный вызов read
  mov rdi, r8                 ; Дескриптор первого файла
  mov rsi, buffer             ; Куда читать (в buffer) 
  mov rdx, 100                ; Сколько читать (до 100 байт)
  syscall
  mov r9, rax                 ; Сохраняем количество прочитанных байт в r9

  ;; Устанавливаем начальные значения для k и m из аргументов командной строки
  mov rbx, [rsp + 32]         ; Загрузка k (начальная позиция)
  mov rcx, [rsp + 40]         ; Загрузка m (длина для маятникового порядка)

  ;; Инициализация начального индекса для маятникового перемещения
  xor rdx, rdx                ; Счетчик шагов
  ;mov byte [rbx], 'A'
  ;call write_char
next_char:
  ;; Вычисляем новую позицию для символа
  mov rsi, rbx                ; k в rsi
  mov rcx, rdx                ; Индекс шага в rcx
  call calculate_position     ; Получаем новую позицию в rax

  push rsi
  mov rsi, buf64
; rax=наше число
  call number_str
  call print_str
  call new_line
  pop rsi

  ;call print_str  ;; Проверяем границы буфера
  cmp rax, 0
  jl end_swing                ; Если позиция меньше 0, завершить
  cmp rax, r9
  jge end_swing               ; Если позиция >= r9, завершить

  ;; Читаем символ из buffer по новой позиции
  mov rsi, buffer
  movzx rbx, byte [rsi + rax] ; Читаем символ по позиции из rax в rbx

  ;; Сохраняем символ в переменную (rev_buf)
  mov [rev_buf], bl           ; Сохраняем символ в rev_buf
  ;mov byte [rev_buf], 'A'  ; Для проверки
  
  
  ;; Записываем символ в файл
  call write_char             ; Записываем символ в файл

  ;; Обновляем индекс и продолжаем, пока не обработаем все символы
  inc rdx
  cmp rdx, rcx
  jl next_char

end_swing:
  call exit

calculate_position:
    push rbx  
    push rcx
    push rdx

    mov rax, rbx          ; rbx = k

    ;; Determine the step direction and magnitude
    test rdx, 1           ; Check if the step is even or odd
    jz forward_step       ; If even, go forward

backward_step:
    ;; Odd step: subtract (m - ((step + 1) / 2))
    mov rcx, rdx          ;rdx = m
    shr rcx, 1            ; Divide step by 2sss
    add rcx, 1            ; rcx = (step + 1) / 2
    sub rcx, rbx          ; rcx = m - (step + 1) / 2
    sub rax, rcx          ; rax = k - (m - step_adjust)
    jmp end_calculate_position

forward_step:
    ;; Even step: add (m - (step / 2))
    mov rcx, rdx
    shr rcx, 1            ; Divide step by 2
    sub rcx, rbx          ; rcx = m - (step / 2)
    add rax, rcx          ; rax = k + (m - step_adjust)

end_calculate_position:
    ;; Ensure the position is within valid range
    cmp rax, 0            ; Check if position is less than 0
    jl end_calculate_position

    cmp rax, r9           ; Check if position exceeds the buffer size
    jge end_calculate_position

    pop rdx
    pop rcx
    pop rbx
    ret


write_char:
    ;mov [rev_buf], 'Q'
    mov rax, 1              ; Системный вызов write
    mov rdi, r10            ; Дескриптор второго файла (r10)
    mov rsi, rev_buf        ; Адрес rev_buf
    call print_str
    mov rdx, 1              ; Количество байт для записи (1 байт)
    syscall                 ; Выполняем системный вызов
    ret

l1:
  call exit
