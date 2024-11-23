;;example6.asm
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
	extrn clear
	extrn addch
	extrn refresh
	extrn endwin
	extrn exit
	extrn color_pair
	extrn insch
	extrn cbreak
	extrn timeout
	extrn mydelay
	extrn setrnd
	extrn get_random


	section '.bss' writable
	x dq 0        ;; Текущая координата X
	y dq 0        ;; Текущая координата Y
	d_x dq 0       ;; Изменение X (1 — вправо, -1 — влево)
	d_y dq 0       ;; Изменение Y (1 — вниз, -1 — вверх)
	min_x dq 0    ;; Левая граница
	max_x dq 0    ;; Правая граница
	min_y dq 0    ;; Верхняя граница
	max_y dq 0    ;; Нижняя граница

	xmax dq 1
	ymax dq 1
	rand_x dq 1
	rand_y dq 1
	palette dq 1
	count dq 1

	section '.data' writable

	digit db '          '

	section '.text' executable
	
_start:
	;; Инициализация
	call initscr

	mov rax, [xmax]
	dec rax
	mov [max_x], rax         ;; Устанавливаем правую границу
	mov rax, [ymax]
	dec rax
	mov [max_y], rax         ;; Устанавливаем нижнюю границу

	;; Размеры экрана
	xor rdi, rdi
	mov rdi, [stdscr]
	call getmaxx
	mov [xmax], rax
	call getmaxy
	mov [ymax], rax

	call start_color

    ;; Пара 1: MAGENTA текст на CYAN фоне
    mov rdx, 0x6    ;; Цвет фона (CYAN)
    mov rsi, 0x5    ;; Цвет текста (MAGENTA)
    mov rdi, 0x1    ;; Номер цветовой пары
    call init_pair

    ;; Пара 2: CYAN текст на MAGENTA фоне
    mov rdx, 0x5    ;; Цвет фона (MAGENTA)
    mov rsi, 0x6    ;; Цвет текста (CYAN)
    mov rdi, 0x2    ;; Номер цветовой пары
    call init_pair


	call refresh
	call noecho
	call cbreak
	call setrnd

	;; Начальная инициализация палитры
	call get_digit
	or rax, 0x100
	mov [palette], rax
	mov [count], 0
        
	;; движение
mloop:
	;; Перемещаемся в текущем направлении
	mov rax, [x]        ;; Загружаем текущую координату X
	mov rbx, [d_x]      ;; Загружаем направление изменения X
	add rax, rbx        ;; Прибавляем d_x к X (перемещение по X)
	mov [x], rax        ;; Сохраняем новое значение X

	mov rax, [y]        ;; Загружаем текущую координату Y
	mov rbx, [d_y]      ;; Загружаем направление изменения Y
	add rax, rbx        ;; Прибавляем d_y к Y (перемещение по Y)
	mov [y], rax        ;; Сохраняем новое значение Y

	mov rax, [x]        ;; Загружаем текущую X
	cmp rax, [min_x]    ;; Сравниваем X с левой границей
	je .change_to_down  ;; Если X == min_x, меняем направление на вниз

	;; Проверяем границы и меняем направление
	mov rax, [y]        ;; Загружаем текущую Y
	cmp rax, [max_y]    ;; Сравниваем Y с нижней границей
	je .change_to_right ;; Если Y == max_y, меняем направление на вправо

	mov rax, [x]        ;; Загружаем текущую X
	cmp rax, [max_x]    ;; Сравниваем X с правой границей
	je .change_to_up    ;; Если X == max_x, меняем направление на вверх

	mov rax, [y]        ;; Загружаем текущую Y
	cmp rax, [min_y]    ;; Сравниваем Y с верхней границей
	je .change_to_left  ;; Если Y == min_y, меняем направление на влево

	jmp .continue_movement ;; Если границы не достигнуты, продолжаем движение

.change_to_right:
	mov rax, 1          ;; Устанавливаем d_x = 1 (вправо)
	mov [d_x], rax
	mov rax, 0          ;; Устанавливаем d_y = 0 (останавливаем движение по Y)
	mov [d_y], rax
	inc qword [min_y]   ;; Сужаем верхнюю границу (минус одна строка сверху)
	jmp .continue_movement

.change_to_up:
	mov rax, 0          ;; Устанавливаем d_x = 0 (останавливаем движение по X)
	mov [d_x], rax
	mov rax, -1         ;; Устанавливаем d_y = -1 (движение вверх)
	mov [d_y], rax
	dec qword [max_x]   ;; Сужаем правую границу (минус один столбец справа)
	jmp .continue_movement

.change_to_left:
	mov rax, -1         ;; Устанавливаем d_x = -1 (движение влево)
	mov [d_x], rax
	mov rax, 0          ;; Устанавливаем d_y = 0 (останавливаем движение по Y)
	mov [d_y], rax
	dec qword [max_y]   ;; Сужаем верхнюю границу (минус одна строка сверху)
	jmp .continue_movement

.change_to_down:
	mov rax, 0          ;; Устанавливаем d_x = 0 (останавливаем движение по X)
	mov [d_x], rax
	mov rax, 1          ;; Устанавливаем d_y = 1 (движение вниз)
	mov [d_y], rax
	inc qword [min_x]   ;; Сужаем левую границу (плюс один столбец слева)

.continue_movement:
	;; Перемещаем курсор в текущую позицию
	mov rdi, [y]        ;; Передаем координату Y в rdi
	mov rsi, [x]        ;; Передаем координату X в rsi
	call move  


	;; Печатаем случайный символ в палитре
	mov rax, [palette]
	and rax, 0x100
	cmp rax, 0x100
	jne @f
	call get_digit
	or rax, 0x100
	mov [palette],rax
	jmp yy
	@@:
	call get_digit
	or rax, 0x200
	mov [palette],rax
	yy:
	mov  rdi,[palette]
	call addch
	;; 	call insch
	
	;; Задержка
	mov rdi,100
	call mydelay

	;; Обновляем экран и количество выведенных знакомест в заданной палитре
	call refresh
	mov r8, [count]
	inc r8
	mov [count], r8

	;; Анализируем текущее значение r8=[count]
	call analiz
    
    ;;Задаем таймаут для getch
	mov rdi, 1
	call timeout
	call getch
	cmp rax, 'v'
	je .increase_speed
	cmp rax, 'b'
	je .decrease_speed
	cmp rax, 'q'
	je next
	jmp mloop
	
.increase_speed:
	mov rax, 100
	sub rdi, rax             ;; Увеличиваем скорость (уменьшаем задержку)
	jmp mloop


.decrease_speed:
	mov rax, 100
	add rdi, rax             ;; Уменьшаем скорость (увеличиваем задержку)
	jmp mloop

next:	
	call endwin
	call exit

;;Анализируем количество выведенных знакомест в заданной палитре, меняем палитру, если количество больше 10000
analiz:
	cmp r8, 10000
	jl .p
	mov r8,[palette]
	and r8, 0x100 
	cmp r8, 0x100
	je .pp
	call get_digit
	or rax, 0x100
	mov [palette], rax
	xor r8, r8
	mov [count],r8
	ret
	.pp:
	call get_digit
	or rax, 0x200
	mov [palette], rax
	xor r8, r8
	mov [count], r8
	ret
	.p:
	 ret

;;Выбираем случайную цифру
get_digit:
	push rcx
	push rdx
	call get_random
	mov rcx, 10
	xor rdx, rdx
	div rcx
	xor rax,rax
	mov al, [digit + rdx]
	pop rdx
	pop rcx
	ret


