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
    mov rcx, [rsp] ;читаем количество параметров командной строки
    cmp rcx, 3 ;если параметров достаточно, переходим к основной части
    jnb .l0 ;иначе завершаем работу
    mov rsi, msg0
    call print_str
    jmp .l1
    
.l0:
    mov rdi,[rsp+16] ;загружаем адрес имени файла из стека
    mov rax, 2 ;системный вызов открытия файла
    mov rsi, 0o ;Права только на чтение
    syscall ;выполняем системный вызов open
    cmp rax, 0 ;если вернулось отрицательное значение,
    jl .l1 ;то произошла ошибка открытия файла, также завершаем работу

    mov r8, rax ;сохраняем файловый дескриптор
    mov rdi, [rsp+24]
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
    
.loop_read: ;начинаем цикл чтения из файла
    mov rax, 0 ;номер системного вызова чтения
    mov rdi, r8 ;загружаем файловый дескриптор
    mov rsi, buffer ;указываем, куда помещать прочитанные данные
    mov rdx, 1 ;устанавливаем количество считываемых данных
    syscall ;выполняем системный вызов read
    cmp rax, 0 ;если прочитано 0 байт, то достигли конца файла 
    je .next  ;выходим из цикла чтения

;    mov rax,1
;    mov rdi,1
;    mov rsi, buffer
;    mov rdx, 1
;    syscall

    mov dl, [buffer]
    mov rsi, ban
.check_ban:
    lodsb
    or al, al
    jz .check_ok
    cmp al, dl
    je .loop_read
    jmp .check_ban
.check_ok:
    mov rax, 1
    mov rdi, r9
    mov rsi, buffer
    mov rdx, 1
    syscall
    jmp .loop_read ;продолжаем цикл чтения
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
