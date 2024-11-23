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
	var dq 1
	x dq 0        ;; Текущая координата X
	y dq 0        ;; Текущая координата Y
	d_x dq 0       ;; Изменение X (1 — вправо, -1 — влево)
	d_y dq 1       ;; Изменение Y (1 — вниз, -1 — вверх)
	min_x dq 0    ;; Левая граница
	max_x dq 0    ;; Правая граница
	min_y dq 0    ;; Верхняя граница
	max_y dq 0    ;; Нижняя граница
	max_xx dq 0
	max_yy dq 0
	speed dq 1
	s dq 0


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

	;; Размеры экрана
	xor rdi, rdi
	mov rdi, [stdscr]
	call getmaxx
	mov [max_x], rax
	mov [max_xx], rax
	dec [max_x]
	call getmaxy
	mov [max_y], rax
	mov [max_yy], rax
	dec [max_y]
	mov rbx, [max_xx]
	mul rbx
	mov [s], rax

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


	mov r8, [var]
	cmp r8, 1 
	
		jne check1
		
	mov rax, [y]
	cmp rax, [max_y]
		je change_to_right
		;inc qword [min_x]

	check1:

	mov r8, [var]
	cmp r8, 2
	jne check2

	mov rax, [x]
	cmp rax, [max_x]
		je change_to_up
		;dec qword [max_y]

	check2:
	mov r8, [var]
	cmp r8, 3
		jne check3
	mov rax, [y]
	cmp rax, [min_y]
		je change_to_left
		;dec qword [max_x]
	check3:
	mov r8, [var]
	cmp r8, 0
	jne check4
	mov rax, [x]
	cmp rax, [min_x]
		je change_to_down
check4:
	jmp continue_movement ;; Если границы не достигнуты, продолжаем движение

change_to_right:

	mov rax, 1          ;; Устанавливаем d_x = 1 (вправо)
	mov [d_x], rax
	mov rax, 0         ;; Устанавливаем d_y = 0 (останавливаем движение по Y)
	mov [d_y], rax
	mov [var], 2
	inc qword [min_x]
	jmp continue_movement

change_to_up:
	mov rax, 0          ;; Устанавливаем d_x = 0 (останавливаем движение по X)
	mov [d_x], rax 
	mov rax, -1       ;; Устанавливаем d_y = -1 (движение вверх)
	mov [d_y], rax
	mov [var], 3
	dec qword [max_y]
	jmp continue_movement

change_to_left:
	mov rax, -1         ;; Устанавливаем d_x = -1 (движение влево)
	mov [d_x], rax
	mov rax, 0          ;; Устанавливаем d_y = 0 (останавливаем движение по Y)
	mov [d_y], rax
	mov [var], 0
	dec qword [max_x]
	jmp continue_movement

change_to_down:
	mov rax, 0          ;; Устанавливаем d_x = 0 (останавливаем движение по X)
	mov [d_x], rax
	mov rax, 1          ;; Устанавливаем d_y = 1 (движение вниз)
	mov [d_y], rax
	mov [var], 1   ;; Сужаем левую границу (плюс один столбец слева)
	inc qword [min_y]
	jmp continue_movement 

continue_movement:
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
		;; Перемещаемся в текущем направлении
	mov rax, [x]        ;; Загружаем текущую координату X
	mov rbx, [d_x]      ;; Загружаем направление изменения X
	add rax, rbx        ;; Прибавляем d_x к X (перемещение по X)
	mov [x], rax        ;; Сохраняем новое значение X

	mov rax, [y]        ;; Загружаем текущую координату Y
	mov rbx, [d_y]      ;; Загружаем направление изменения Y
	add rax, rbx        ;; Прибавляем d_y к Y (перемещение по Y)
	mov [y], rax        ;; Сохраняем новое значение Y
	
	;; Задержка
	mov rdi, [speed]
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
	je .decrease_speed
	cmp rax, 'b'
	je next
	jmp mloop
	
	
.decrease_speed:
	mov rdi, [speed]
	mov rax, 100
	add rdi, rax             ;; Увеличиваем скорость (уменьшаем задержку)
	mov [speed], rax
	cmp rdi, 1000
	je .null
	.null:
		mov [speed], 1 
		mov rdi, [speed]
	call mydelay
	jmp mloop




next:	
	call endwin
	call exit

;;Анализируем количество выведенных знакомест в заданной палитре, меняем палитру, если количество больше 10000
analiz:
	mov rax, [s]
	cmp r8, rax
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
		mov rax, [max_xx]
		mov [max_x], rax
		dec [max_x]
		mov rax, [max_yy]
		mov [max_y], rax
		dec [max_y]
		mov [min_x], 0
		mov [min_y], 0
		mov [var], 1
		mov [d_x], 0
		mov [d_y], 1
		mov [y], 0
		mov [x], 0
	ret
	.pp:
	call get_digit
	or rax, 0x200
	mov [palette], rax
	xor r8, r8
	mov [count], r8
		mov rax, [max_xx]
		mov [max_x], rax
		dec [max_x]
		mov rax, [max_yy]
		mov [max_y], rax
		dec [max_y]
		mov [min_x], 0
		mov [min_y], 0
		mov [var], 1
		mov [d_x], 0
		mov [d_y], 1
		mov [y], 0
		mov [x], 0
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


