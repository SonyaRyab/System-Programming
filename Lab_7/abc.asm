;1
;для заданного текстового файла подсчет кол-ва букв, цифр

format ELF64
public _start

include 'func.asm'

buffer rb 32

section '.data' writable
    msg1 db 'number of letters: ', 0, 0xA  ; первая строка
    len1 dq 19
    msg2 db 10,'number of digits: ', 0, 0xA    ; вторая строка
    len2 dq 19
    msg3 db 'OK', 10, 0
    msg0 db 'Usage: t1_0 inputfilename outputfilename', 10, 0

section '.text' executable

_start:
    mov rcx, [rsp] ;читаем количество параметров командной строки
    cmp rcx, 3 ;если параметров достаточно, переходим к основной части
    jnb .l0 ;иначе завершаем работу
    mov rsi, msg2
    call print_str
    jmp .l1

.l0:
    mov rdi,[rsp+16]    ;адрес имени файла из стека
    mov rax, 2   ;системный вызов открытия файла
    mov rsi, 0o     ;Права только на чтение
    syscall     ;open
    
    cmp rax, 0  ;если вернулось отрицательное значение
    jl .l1   ;то произошла ошибка открытия файла, завершение

    mov r8, rax ;  дескриптор
    xor r9, r9 ;обнуляем счетчик букв
    xor r10, r10 ;обнуляем счетчик цифр

.loop_read:     ;начинаем цикл чтения из файла
    mov rax, 0  ;номер системного вызова чтения
    mov rdi, r8  ;загружаем файловый дескриптор
    mov rsi, buffer ;куда помещать данные
    mov rdx, 1  ;количество считываемых данных
    syscall     ;read
    cmp rax, 0   ;если прочитано 0 байт, то конец файла 
    je .next     ;выход

    mov al, [buffer]
    cmp al, 48      ;'0'
    jb .loop_read
    cmp al, 57      ;'9'
    ja .maybe_letter
    inc r10
    jmp .loop_read

.maybe_letter:
    cmp al, 65  ;'A'
    jb .loop_read
    cmp al, 90  ;'Z'
    ja .maybe_small
    inc r9
    jmp .loop_read

.maybe_small:
    cmp al, 97      ;'a'
    jb .loop_read
    cmp al, 122     ;'z'
    ja .loop_read
    inc r9
    jmp .loop_read 

.next: 
    mov rdi, r8
    mov rax, 3
    syscall
    
    mov rax, 2
    mov rdi, [rsp + 24]
    mov rsi, 577
    mov rdx, 677o
    syscall
    cmp rax, 0
    jl .l1
    mov r8, rax
    mov rdi, r8
    
    mov rax, 1        ;номер системного вызова для sys_write
    mov rsi, msg1           ;адрес первой строки для вывода
    mov rdx, [len1]          ;длина первой строки
    syscall                  

    mov rax, r9     ;число букв
    mov rsi, buffer  
    call number_str   
    mov rax, buffer
    call len_str
    
    mov rdx, rax
    mov rax, 1
    mov rdi, r8
    mov rsi, buffer
    syscall
    
    mov rax, 1
    mov rdi, r8
    mov rsi, msg2
    mov rdx, [len2]
    syscall

    mov rax, r10    ;число цифр
    mov rsi, buffer  ;переписываем число из rax
    call number_str  
    mov rax, buffer
    call len_str
    
    mov rdx, rax
    mov rax, 1
    mov rdi, r8
    mov rsi, buffer
    syscall

    mov rax, 1
    mov rdi, r8
    mov rsi, msg2
    mov rdx, 1
    syscall

    ;;Системный вызов close
    mov rdi, r8
    mov rax, 3
    syscall

    mov rsi, msg3
    call print_str

.l1:
    call exit