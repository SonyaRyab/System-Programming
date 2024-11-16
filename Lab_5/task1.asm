;1
;для заданного текстового файла подсчет кол-ва букв, цифр

format ELF64
public _start

include 'func.asm'

buffer rb 32

section '.data' writable
    msg1 db 'number of letters: ',0  ; первая строка
    len1 dq 19
    msg2 db 10,'number of digits: ',0    ; вторая строка
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
    mov rdi,[rsp+16] ;загружаем адрес имени файла из стека
    mov rax, 2 ;системный вызов открытия файла
    mov rsi, 0o ;Права только на чтение
    syscall ;выполняем системный вызов open
    cmp rax, 0 ;если вернулось отрицательное значение,
    jl .l1 ;то произошла ошибка открытия файла, также завершаем работу

    mov r8, rax ;сохраняем файловый дескриптор
    xor r9, r9 ;обнуляем счетчик букв
    xor r10, r10 ;обнуляем счетчик цифр

.loop_read: ;начинаем цикл чтения из файла
    mov rax, 0 ;номер системного вызова чтения
    mov rdi, r8 ;загружаем файловый дескриптор
    mov rsi, buffer ;указываем, куда помещать прочитанные данные
    mov rdx, 1 ;устанавливаем количество считываемых данных
    syscall ;выполняем системный вызов read
    cmp rax, 0 ;если прочитано 0 байт, то достигли конца файла 
    je .next  ;выходим из цикла чтения

    mov al, [buffer]
    cmp al, 48; '0'
    jb .loop_read
    cmp al, 57; '9'
    ja .maybe_letter
    inc r10
    jmp .loop_read

.maybe_letter:
    cmp al, 65; 'A'
    jb .loop_read
    cmp al, 90; 'Z'
    ja .maybe_small
    inc r9
    jmp .loop_read

.maybe_small:
    cmp al, 97; 'a'
    jb .loop_read
    cmp al, 122; 'z'
    ja .loop_read
    inc r9
    jmp .loop_read ;продолжаем цикл чтения

.next: 
    mov rdi, r8
    mov rax, 3
    syscall

    ;mov rsi, [rsp + 24]
    ;call print_str
    
    mov rax, 2
    mov rdi, [rsp + 24]
    mov rsi, 577
    mov rdx, 677o
    syscall
    cmp rax, 0
    jl .l1
    mov r8, rax

    mov rdi, r8
    
    mov rax, 1        ; номер системного вызова для sys_write
    mov rsi, msg1           ; адрес первой строки для вывода
    mov rdx, [len1]          ; длина первой строки
    syscall                  ; вызов ядра

    mov rax, r9 ;число букв
    mov rsi, buffer ;переписываем число из rax
    call number_str   ;в виде строки в буфер
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

    mov rax, r10 ;число цифр
    mov rsi, buffer ;переписываем число из rax
    call number_str   ;в виде строки в буфер
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