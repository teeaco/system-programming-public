format ELF64

public _start

extrn initscr
extrn start_color
extrn init_pair
extrn getmaxx
extrn getmaxy
extrn raw
extrn noecho
extrn keypad
extrn stdscr
extrn move
extrn getch
extrn addch
extrn refresh
extrn endwin
extrn exit
extrn timeout
extrn usleep
extrn printw

section '.bss' writable
    xmax dq 1
  ymax dq 1
    xmid dq 1
    ymid dq 1
  palette dq 1
    delay dq ?
section '.text' executable  ; Начинает секцию .text, где будет исполняемый код
_start:                     ; Метка начала программы
    call initscr           ; Вызов функции initscr для инициализации окна ncurses
    mov rdi, [stdscr]      ; Перемещает адрес стандартного окна в регистр rdi
    call getmaxx           ; Вызов функции getmaxx для получения максимальной ширины окна
    dec rax                ; Уменьшает значение rax на 1 (максимальная ширина - 1)
    mov [xmax], rax        ; Сохраняет значение xmax в переменную xmax
    xor rdx, rdx           ; Обнуляет регистр rdx
    xor rcx, rcx           ; Обнуляет регистр rcx
    mov rcx, 2             ; Устанавливает значение 2 в регистр rcx
    div rcx                ; Делит значение в rax на 2 (вычисляет середину по x)
    mov [xmid], rax        ; Сохраняет результат деления (середина по x) в переменную xmid
    call getmaxy           ; Вызов функции getmaxy для получения максимальной высоты окна
    dec rax                ; Уменьшает значение rax на 1 (максимальная высота - 1)
    mov [ymax], rax        ; Сохраняет значение ymax в переменную ymax
    xor rdx, rdx           ; Обнуляет регистр rdx
    xor rcx, rcx           ; Обнуляет регистр rcx
    mov rcx, 2             ; Устанавливает значение 2 в регистр rcx
    div rcx                ; Делит значение в rax на 2 (вычисляет середину по y)
    mov [ymid], rax        ; Сохраняет результат деления (середина по y) в переменную ymid
    call start_color       ; Вызов функции start_color для инициализации цветовой системы
    ; Установка цветовой пары COLOR_WHITE
    mov rdi, 1             ; Устанавливает первый аргумент (номер пары) в 1
    mov rsi, 7             ; Устанавливает второй аргумент (цвет фона) в 7 (белый)
    mov rdx, 7             ; Устанавливает третий аргумент (цвет текста) в 7 (белый)
    call init_pair         ; Вызов функции init_pair для инициализации цветовой пары
    ; Установка цветовой пары COLOR_CYAN
    mov rdi, 2             ; Устанавливает первый аргумент (номер пары) в 2
    mov rsi, 6             ; Устанавливает второй аргумент (цвет фона) в 6 (циановый)
    mov rdx, 6             ; Устанавливает третий аргумент (цвет текста) в 6 (циановый)
    call init_pair         ; Вызов функции init_pair для инициализации цветовой пары
    call refresh           ; Вызов функции refresh для обновления окна
    call noecho            ; Вызов функции noecho для отключения отображения вводимых символов
    call raw               ; Вызов функции raw для включения режима "сырых" вводов
    mov rax, ' '           ; Загружает пробел в регистр rax
    or rax, 0x200          ; Устанавливает бит 9 (выбор палитры)
    mov [palette], rax     ; Сохраняет значение в переменную palette
    
    
    .begin:                ; Метка начала цикла
    mov rax, [palette]     ; Загружает текущее значение палитры в rax
    and rax, 0x100         ; Проверяет, установлен ли бит 8 (выбор цвета)
    cmp rax, 0             ; Сравнивает rax с 0
    jne .mag               ; Если бит 8 установлен, переход к метке .mag
    mov rax, [palette]     ; Загружает текущее значение палитры в rax
    and rax, 0xff          ; Очищает все биты, кроме 8 младших
    or rax, 0x100          ; Устанавливает бит 8
    jmp @f                 ; Переход к метке @f
    .mag:                  ; Метка для изменения палитры
    mov rax, [palette]     ; Загружает текущее значение палитры в rax
    and rax, 0xff          ; Очищает все биты, кроме 8 младших
    or rax, 0x200          ; Устанавливает бит 9
    @@:                    ; Метка для завершения изменения палитры
    mov [palette], rax     ; Сохраняет новое значение палитры
    mov r8, [xmax]         ; Загружает максимальную ширину в r8
    mov r9, [ymax]         ; Обнуляет регистр r9 (счетчик по высоте)
    jmp .loop_to_up      ; Переход к метке .loop_to_up
    .to_up: 
    dec r9             ; Метка для перемещения влево
    dec r8                 ; Увеличивает r9 (переход к следующей строке)
    cmp r8, 0         ; Сравнивает r9 с ymax
    jl .begin          ; Если r9 больше ymax, переход к .begin
        ; Загружает максимальную ширину в r8
    .loop_to_up:         ; Метка для цикла перемещения влево
        mov rdi, [delay]   ; Загружает текущее значение задержки в rdi
        call usleep        ; Приостанавливает выполнение на значение delay
        mov rdi, r9         ; Устанавливает rdi как текущую строку
        mov rsi, r8         ; Устанавливает rsi как текущую колонку
        push r8             ; Сохраняет значение r8 на стеке
        push r9             ; Сохраняет значение r9 на стеке
        call move           ; Перемещает курсор в указанную позицию
        mov rdi, [palette]  ; Загружает текущее значение палитры в rdi
        call addch          ; Добавляет символ в текущее окно
        call refresh        ; Обновляет окно
        mov rdi, 1          ; Устанавливает тайм-аут на 1 мс
        call timeout        ; Устанавливает тайм-аут для ввода
        call getch          ; Считывает символ с клавиатуры
        cmp rax, 'o'        ; Сравнивает считанный символ с 'o'
        jne @f              ; Если не равно, перейти к метке @f
        jmp .exit           ; Переход к завершению программы
        @@:                 ; Метка для проверки 'w'
        cmp rax, 'w'        ; Сравнивает считанный символ с 'w'
        jne @f              ; Если не равно, перейти к метке @f
        cmp [delay], 2000   ; Сравнивает значение задержки с 2000
        je .fast1           ; Если равно, переход к .fast1
        mov [delay], 2000   ; Устанавливает задержку в 2000
        jmp @f              ; Переход к метке @f
        .fast1:             ; Метка для быстрой задержки
        mov [delay], 100    ; Устанавливает задержку в 100
        @@:                 ; Метка для завершения цикла
        pop r9              ; Восстанавливает значение r9 из стека
        pop r8              ; Восстанавливает значение r8 из стека
        dec r9              ; Уменьшает r8 на 1
        cmp r9, 0     ; Сравнивает r8 с 0
        jl .to_down        ; Если меньше 0, переход к .to_down
        jmp .loop_to_up   ; Иначе продолжает цикл влево
    .to_down:
    inc r9              ; Метка для перемещения вправо
    dec r8                  ; Увеличивает r9 (переход к следующей строке)
    cmp r8, 0         ; Сравнивает r9 с ymax
    jl .begin               ; Если r9 больше ymax, переход к .begin
          
    .loop_to_down:         ; Метка для цикла перемещения вправо
    mov rdi, [delay]    ; Загружает текущее значение задержки в rdi
        call usleep        ; Приостанавливает выполнение на значение delay
        mov rdi, r9         ; Устанавливает rdi как текущую строку
        mov rsi, r8         ; Устанавливает rsi как текущую колонку
        push r8             ; Сохраняет значение r8 на стеке
        push r9             ; Сохраняет значение r9 на стеке
        call move           ; Перемещает курсор в указанную позицию
    ; Reverse horizontal movement (right to left)
.loop_to_right:              ; Start of the loop for moving right to left
    mov rdi, [delay]         ; Load the current delay value into rdi
    call usleep              ; Pause for 'delay' microseconds
    mov rdi, r9              ; Set rdi to the current row
    mov rsi, r8              ; Set rsi to the current column (x position, starting at xmax)
    push r8                  ; Save r8 on the stack
    push r9                  ; Save r9 on the stack
    call move                ; Move the cursor to (rsi, rdi)
    mov rdi, [palette]       ; Load current palette value into rdi
    call addch               ; Add character to the window
    call refresh             ; Refresh the screen to update the window
    mov rdi, 1               ; Set the timeout to 1 ms
    call timeout             ; Set the timeout for input
    call getch               ; Get a character from input
    cmp rax, 'o'             ; Compare the input with 'o'
    jne @f                   ; If not 'o', continue with the loop
    jmp .exit                ; Exit if 'o' was pressed

    ; Check for 'w' to toggle speed
    @@:
    cmp rax, 'w'             ; Compare the input with 'w'
    jne @f                   ; If not 'w', continue with the loop
    cmp [delay], 2000        ; Compare current delay with 2000
    je .fast1                ; If equal, go to fast1
    mov [delay], 2000        ; Set delay to 2000
    jmp @f                   ; Skip to the next iteration

    .fast1:
    mov [delay], 100         ; Set faster delay (100)
    @@:

    pop r9                   ; Restore r9 from the stack
    pop r8                   ; Restore r8 from the stack
    dec r8                   ; Decrease x position (move left)
    cmp r8, 0                ; Compare x position with 0
    jge .loop_to_right       ; If still greater or equal to 0, continue the loop

    ; Switch to the next line (move down)
    inc r9                   ; Increase y position (move down)
    cmp r9, [ymax]           ; Check if we've reached the bottom of the screen
    jge .exit                ; If we've reached the bottom, exit
    jmp .loop_to_right       ; Otherwise, continue the right-to-left loop

.exit:
    call endwin              ; Call endwin to clean up ncurses
    call exit                ; Exit the program
 