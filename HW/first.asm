;Очередь
;Куча
;Добавление в конец, Удаление из начала
;Заполнение случайными числами
;Удаление всех четных чисел (прочитанное нечетное число добавляется обратно в конец)
;Подсчет количества четных чисел 
;Подсчет количества чисел, оканчивающихся на 1

format ELF64

public get_size
public printhex
public count_1
public count_even
public remove_even
public fill_rand
public pop_front
public push_back
public printstr

section '.data' writable
head	dq 0   ;указатель на начало очереди
tail	dq 0   ;указатель на конец очереди
size	dq 0   ;количество элементов в данный момент
;номер
rnd_seq  dq 0x1234567, 0x63538962, 0x432178909, 0x478826291, 0x766552920, 0x6829197393, 0x7361810397
rnd_cnt dq 0x1234567 

buf db '0000000000000000', 0xA, 0

section '.text' executable
printhex:
	push rax
	push rdi
	push rcx
	push rdx
	mov rcx, 16 
	mov rdx, buf
	xchg rdx, rdi

ph_l1:
	rol rdx, 4
	mov rax, rdx
	and al, 0xf
	cmp al, 0xa
	jb ph_l2
	add al, 7
ph_l2:
	add al, 0x30
	stosb 
	loop ph_l1 
	mov rdi, buf
	call printstr
	pop rdx
	pop rcx
	pop rdi
	pop rax
	ret

printstr:
;rsi - str ;указатель на начало 
	push rax
	push rdi
	push rsi
	cld           ;
	xor rdx, rdx  ;кол-во байтов для вывода
	mov rsi, rdi
	ps_l1:
		lodsb      ;
		or al, al  ;
		jz ps_l2
		inc rdx
		jmp ps_l1
	ps_l2:
		xchg rsi, rdi
		mov rax, 1 ;write
		mov rdi, 1 ;descriptor
		syscall
		pop rsi
		pop rdi
		pop rax
		ret

get_size:
	mov rax, [size]
	ret


;количество чисел, оканчивающихся на 1 (остаток от деления на 10 =1)
count_1:
	push rbx
	push rdx
	push rdi
	push rcx
	xor rbx, rbx
	mov rcx, [size]
	mov rdi, rcx
	;call printhex

c_l1:
	call pop_front
	mov rdi, rax
	cqo            ;преобразовываем значение rax в rdx:rax c учетом знака 
	mov r10, 10    
	idiv r10       ;целочисленное деление с учетом знака
	;dec rdx  
	push rdi
	mov rdi, rdx
	;call printhex
	pop rdi
	cmp rdx, 1   
	jnz c_l2       ;если остаток от деления rdx:rax на 10 =1, то rdx=0 
	inc rbx

c_l2:
	call push_back  
	loop c_l1       
	mov rax, rbx  
	pop rcx
	pop rdi
	pop rdx
	pop rbx  
	ret

;Количество четных
count_even:
	push rdx
	push rcx
	push rdi
	xor rdx, rdx
	mov rcx, [size]

ce_l1:
	call pop_front
	test rax, 1
	jnz ce_l2
	inc rdx

ce_l2:
	mov rdi, rax
	call push_back
	loop ce_l1
	mov rax, rdx
	pop rdi
	pop rcx
	pop rdx
	ret

;Удаление четных
remove_even:
	mov rcx, [size]

re_l1:
	call pop_front   
	test rax, 1      ;проверка установлен ли бит=0 в RAX
;если бит=1, флаг знака ZF=1. если бит=0, флаг нуля ZF=1, SF=0
	jz re_l2
	mov rdi, rax
	call push_back

re_l2:
	loop re_l1
	ret

fill_rand:
	push rax
	push rcx
	push rdx
	push rdi
	mov rcx, rdi

fr_l1:
	push rcx
	push rdi
	mov rdi, rcx
	;call printhex
	pop rdi
	call random 
	
	mov rdi, rax
	;call printhex

	call push_back
	pop rcx
	loop fr_l1
	pop rdi
	pop rdx
	pop rcx
	pop rax
	ret

random:
	push rdx
	push rcx
	push rbx
	push rsi
	push rdi
	mov rax, 96
	syscall
	mov rcx, [rnd_cnt]
	xor rax, rcx
	mov rsi, rcx
	and rsi, 7
	mov rbx, rnd_seq
	shl rsi, 3
	add rbx, rsi
	add qword[rnd_cnt], 3
	mov rdi, [rbx]
	;call printhex
	mov rdi, [rnd_cnt]
	;call printhex
	xor rdx, [rbx]
	and cl, 3
	add cl, 11
	rol rdx, cl  
	shr rcx, 8
	and cl, 7
	add cl, 3
	ror rax, cl  
	shr rcx, 8
	and cl, 0xf
	add cl, 7   
	xor rax, rdx
	rol rdx, cl    
	xor rax, rdx
	shr rax, 1 
	xor [rnd_cnt], rdx
	inc qword[rnd_cnt]
	pop rdi
	pop rsi
	pop rbx
	pop rcx
	pop rdx
	ret

pop_front:
	push rcx
	mov rcx, [size]
	jrcxz pf_end
	push rdx
	push rsi
	dec rcx
	mov [size], rcx
	mov rsi, [head]
	lodsq
	xchg rax, rdx
	lodsq
	mov [head], rax
	xchg rax, rdx
	pop rsi
	pop rdx
	
pf_end:
	pop rcx
	ret

push_back:
	push rax
	push rdi
	push rcx
	call create_node
	mov rcx, [size]
	jrcxz pb_l1       ;jump if RCX=0 
	mov rdi, [tail]
	add rdi, 8
	stosq             
	jmp pb_l2

pb_l1:
	mov [head], rax
	
pb_l2:
	mov [tail], rax
	inc rcx
	mov [size], rcx
	pop rcx
	pop rdi
	pop rax
	ret

;Узел
create_node:
	push rdi
	push rdx
	push rcx
	push rdi
	xor rdi, rdi
	mov rax, 12
	syscall
	mov rdx, rax
	mov rdi, rax
	add rdi, 16
	mov rax, 12
	syscall
	mov rdi, 0
	mov rax, 12
	syscall
	mov rdi, rdx
	pop rax
	stosq          ;[rdi] <- rax; rdi += 8  
	xor rax, rax
	stosq
	xchg rax, rdx
	pop rcx
	pop rdx
	pop rdi
	ret