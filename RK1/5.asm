;;в переданном как первый параметр в командной строке каталоге у нескольких файлов случайным образом поменять права доступа

format ELF64
public _start

include 'func.asm'

section '.data' writable
	msg	db 'Usage: S1 dirname',13,10, 0
	msgok	db 'OK',13,10,0
	msgerr	db 'Error',13,10,0
	msgerr1 db 'Cannot CHMOD file: ',0
section '.bss' writable
	buffer	rb 1024
section '.text' executable

_start:
	mov rcx, [rsp]
	cmp rcx, 2
	jnb .l0
	jmp .l_fin
.l0:
;;Открываем каталог на чтение
	mov rax, 2
	mov rdi, [rsp + 16]
	mov rsi, 65536
	syscall
   	cmp rax, 0
   	jnl .l1
   	mov rsi, msgerr
   	jmp .l_fin	
.l1:
	mov r8, rax

.loop:
   
   ;;Читаем с винчестера len байт
	mov rax, 78
	mov rdi, r8
	mov rsi, buffer
	mov rdx, 1024
	syscall
	cmp rax, 0
	jle .l2
	mov r10, rax; количество прочитанных байт
   
   ;;текущая позиция в структуре
   xor rdx, rdx
   
   .loop2:
   ;;Получаем d_ino
	mov rax, qword [buffer+rdx]
	cmp rax, 0
	je .loop
	lea rdi, [buffer + 18 + rdx]
	mov rsi, qword [buffer + 18 + rdx]; начало имени файла (как компонент "случайного" числа)
	mov rax, rsi
	cmp al, 2Eh; пропускаем файлы, чьё имя начинается на точку
	je .la2
	xor rsi, rdi; для пущей случайности ксорим эти 8 байт с дескриптором
	and rsi, 777o
	mov rax, 5ah
	syscall 
	or rax, rax
	jns .la1
	mov rsi, msgerr1
	call print_str
.la1:
	lea rsi, [buffer + 18 + rdx]
	call print_str
	call new_line
.la2:
   ;вычисляем размер структуры в r9
	xor r9,r9
	mov r9W, word [buffer+16+rdx]
	add rdx, r9; переходим к следующей структуре
	cmp rdx, r10; если мы не вышли за предеды прочитанной порции, то исследуем её дальше
	jb .loop2

	jmp .loop

  ;;Закрываем чтение из каталога
.l2:   
	mov rax, 3
	mov rdi, r8
	syscall


.l_ok:
	mov rsi, msgok
.l_fin:
	call print_str
	call exit

