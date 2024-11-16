format ELF64
public _start
include 'func.asm'
include 'print.asm'
input dq 256
;place db ?

;кол-во чисел от 1 до n, делящихся на 13*37=481

;n dq 0               ;хранение n=0 /64 бита
;count dq 0           ;хранение количества чисел=0

_start:
    ;Чтение n 
    mov rax, 0          ; syscall: sys_read
    mov rdi, 0          ; файл: stdin
    mov rsi, input        ;загрузка адреса буфера для чтения
    mov rdx, 256          ; читаем 8 байт (64 бита)
    syscall
    call str_number
    ;Подсчет чисел, кратных 481 (37 * 13)
    mov rcx, rax        ; Сохраняем значение n в rcx
    call count_loop
    
    call exit       

count_loop: 
    mov rsi, 0
    mov rdi, 0
    .iter:
        inc rsi
        mov rax, rsi ;rax=rsi - счетчик чисел 
        push rax 
        push rbx
        push rcx
        push rdx
        xor rdx, rdx   ;rdx=0
        mov rbx, 481 
        div rbx ;rax/481 ;1%481 = 1
        cmp rdx, 0  
        inc rdi
        cmp rdx, 0 
        je increment_count        
        pop rdx
        pop rcx
        pop rbx
        pop rax
        cmp rsi, rcx 
        jne .iter
    ret
    mov rsi, rdi
    call print

increment_count:
    inc rsi              
   