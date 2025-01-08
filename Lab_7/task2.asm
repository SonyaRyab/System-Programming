;4
;переписать во второй файл текст без гласных букв: 
;«A», «E», «I», «O», «U», «Y» (верхнего регистра). 
;Имена файлов передавать параметрами командной строки.

format ELF64
public _start

include 'func.asm'

buffer rb 32

section '.data' writable
    msg1 db 'OK', 10, 0
    msg0 db 'Usage: t1_0 inputfilename outputfilename', 10, 0
    ban db 'AOUYIE',0

section '.text' executable

_start:
    mov rcx, [rsp]  ;количество параметров командной строки
    cmp rcx, 3  ;если параметров достаточно, переходим к основной части
    jnb .l0     ;завершаем работу
    mov rsi, msg0
    call print_str
    jmp .l1
    
.l0:
    mov rdi,[rsp+16]    ;загружаем адрес имени файла из стека
    mov rax, 2      ;системный вызов открытия файла
    mov rsi, 0o     ;Права только на чтение
    syscall         ;open
    cmp rax, 0      ;если вернулось отрицательное значение
    jl .l1          ;ошибка открытия файла, завершение работы

    mov r8, rax     ;сохранение файлового дескриптора
    mov rdi, [rsp+24]   ;аргументы - файлы 
    mov rax,2
    mov rsi,577
    mov rdx,677o
    syscall

    cmp rax, 0
    jnl .l_begin
    mov rdi, r8
    mov rax, 3
    syscall
    jmp .l1

.l_begin:
    mov r9, rax
    
;чтение из файла
.loop_read: 
    mov rax, 0  ;системный вызов 
    mov rdi, r8     ;файловый дескриптор
    mov rsi, buffer     ;куда помещать прочитанные данные
    mov rdx, 1  ;количество считываемых данных
    syscall     
    cmp rax, 0  ; прочитано 0 байт, то конец файла 
    je .next  ;выход

    mov dl, [buffer]
    mov rsi, ban

.check_ban:
    lodsb
    or al, al
    jz .check_ok    ;если флаг 0
    cmp al, dl
    je .loop_read   ;al=dl 
    jmp .check_ban

.check_ok:
    mov rax, 1
    mov rdi, r9
    mov rsi, buffer
    mov rdx, 1
    syscall
    jmp .loop_read ;продолжение цикл чтения

.next: 
    mov rdi, r9
    mov rax, 3
    syscall
    mov rdi, r8
    mov rax, 3
    syscall
    mov rsi, msg1
    call print_str

.l1:
    call exit
