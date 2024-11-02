;Ниже представлена программа, в которой создается анонимное отображение в память, 
;после чего ввод с клавиатуры ассоцируется с этой областью памяти. 
;Для проверки мы также печатаем из этой памяти.

format elf64
	;public _start
	public free_memory
	public create_array

	include 'func.asm'

	
	section '.data' writable

	section '.bss' writable
	volume rq 1

	array_begin rq 1
	count rq 1
	section '.text' executable
	
create_array:
	;; выполняем анонимное отображение в память
	mov [volume], rdi
	mov rdi, 0    ;начальный адрес выберет сама ОС
	mov rsi, [volume] ;задаем размер области памяти
	mov rdx, 0x3  ;совмещаем флаги PROT_READ | PROT_WRITE
	mov r10,0x22  ;задаем режим MAP_ANONYMOUS|MAP_PRIVATE
	mov r8, -1   ;указываем файловый дескриптор null
	mov r9, 0     ;задаем нулевое смещение
	mov rax, 9    ;номер системного вызова mmap
	syscall
	ret


free_memory:
	mov rsi, [volume]
	mov rax, 11
	syscall

	ret
