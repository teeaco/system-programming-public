;Ниже представлена программа, в которой создается анонимное отображение в память, 
;после чего ввод с клавиатуры ассоцируется с этой областью памяти. 
;Для проверки мы также печатаем из этой памяти.

format elf64
	;public _start
	public free_memory
	public chet_count
	public create_array
	public randi_array
	public ranint
	public sum_array
	public reverse_array
	include 'func.asm'

	
	section '.data' writable
	f  db "/dev/urandom", 0

	section '.bss' writable
	volume rq 1
	number rq 1
    place rb 100

	array_begin rq 1
	count rq 1
	section '.text' executable


chet_count:
    xor rcx, rcx        
    xor rdx, rdx        

.loop:
    cmp rdx, rsi        
    jge .done           ; если индекс >= размер массива, выходим из цикла

    mov rax, [rdi + rdx * 8] 
    test rax, 1         ; проверяем младший бит числа
    jnz .not_chet       ;если младший бит установлен, число нечётное

    inc rcx             

.not_chet:
    inc rdx             
    jmp .loop           

.done:
    mov rax, rcx        
    ret


reverse_array:
    mov rcx, rsi            
    shr rcx, 1              ; делим размер на 2, чтобы пройтись до середины массива
    xor rdx, rdx            

.loop:
    cmp rdx, rcx            ; если индекс достиг половины размера, выходим из цикла
    jge .done

    ;адрес элемента с конца массива
    mov rax, rsi            
    sub rax, rdx            ; rax = rsi - rdx
    dec rax                 ; rax = rsi - rdx - 1
    shl rax, 3              ; умножаем на 8, чтобы получить смещение в байтах

    ; элементы для обмена
    mov rbx, [rdi + rdx * 8]     ; элемент с начала массива
    mov r8, [rdi + rax]          ; симметричный элемент с конца массива

    ; Обмениваем местами
    mov [rdi + rdx * 8], r8      ; элемент с конца в начало
    mov [rdi + rax], rbx         ;элемент с начала в конец

    inc rdx                     
    jmp .loop                   

.done:
    ret
	
sum_array:
    mov rcx, rsi    
    xor rax, rax    
    xor rdx, rdx    
    
.loop:
    cmp rdx, rcx    ; сравниваем текущий индекс с размером массива
    jge .done       

    add rax, [rdi + rdx*8] ; добавляем элемент массива к сумме
    inc rdx                
    jmp .loop              

.done:
    ret                    ; возвращаем сумму в rax

	

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

randi_array:
	xor rcx,rcx
	
	.l1:
	call ranint ;rax = random
	mov QWORD [rdi+rcx*8], rax 
	inc rcx
	cmp rcx, rsi

	jne .l1
	ret



free_memory:
	mov rsi, [volume]
	mov rax, 11
	syscall

	ret

ranint:
	push rdi
	push rcx
	push rsi
	mov rdi, f
    mov rax, 2 
    mov rsi, 0o
    syscall 

    mov r8, rax

    mov rax, 0 ;
    mov rdi, r8
    mov rsi, number
    mov rdx, 1
    syscall
    
	mov rax, [number]
	pop rsi
	pop rcx
	pop rdi
	ret 
   