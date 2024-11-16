;в качестве параметра командной строки значение $2n+1$, выполняет расчет указанного выражения и выводит результат на экран:
;$$1+3+5+7+ ... + (2n+1)
Если пользователь ввел четное число, программа должна выдать ошибку.
;для переданного как первый параметр в командной строке 2n+1 посчитать сумму 1+3+5+...+2n+1

format ELF64
public _start

include 'func.asm'

section '.data' writable
	msg0	db 'Usage: S1 odd_number',0
	msg	db 'Error: the number is even.',0
section '.text' executable

_start:
	mov rcx, [rsp]
	cmp rcx, 2
	jnb .l0
	mov rsi, msg0
	jmp .l3
.l0:
	mov rsi, [rsp + 16]
	call str_number
	test rax, 1
	jz .l2
	xor rdx, rdx
.l1:
	add rdx, rax
	sub rax, 2
	jnc .l1
	xchg rax, rdx
	mov rsi, msg
	call number_str
.l2:
	mov rsi, msg
.l3:
	call print_str
	call new_line
	call exit
