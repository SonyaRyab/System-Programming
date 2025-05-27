include 'utilities.asm'
;таблица рекордов 
;on entry: rdi - указатель на имя файла  
;returns: rax - кол-во рекордов (сеансов игры)
table_rec:
    push rax 
    push rdi 
    push rsi 
    push rdx
    push rcx
    xor rsi, rsi        ;flags=0 - флаги открытия readonly  
    mov rdx, 444o
    mov rax, 2
    syscall
    cmp rax, 0 
    jnl table_l1
    jmp table_exit
table_l1:
    mov rdi, rax 
table_l2:
    mov rsi, records_buf
    mov rdx, 1       ;читаем 1 байт 
    xor rax, rax 
    syscall     ;чтение длины строки Pascal
    lodsb       ;1 byte-> al, rsi++
    cmp al, 1   ;0 or -1
    jl table_close
    movzx rdx, al 
    xor rax, rax 
    syscall     ;чтение строки 
    mov byte[rsi+rax], 9    ;rax- прочитанные байты строки, rsi+rax=указанный байт ; 9-табуляция 
    dec rsi 
    inc byte[rsi]
    call print_pascal_str
    mov rdx, 24    ;score, steps, dead/alive 
    xor rax, rax 
    syscall     ;чтение score
    lodsq 
    call print_uint64
    call print_tab
    lodsq 
    call print_uint64
    call print_tab
    lodsq 
    or rax, rax 
    jz table_alive 
    mov rsi, dead_msg 
    jmp table_print
table_alive:
    mov rsi, alive_msg  
table_print:
    call print_pascal_str
    call newline
    jmp table_l2
table_close:
    mov rax, 3
    syscall   ;close file 
table_exit: 
    pop rcx 
    pop rdx 
    pop rsi 
    pop rdi
    pop rax  
    ret
    
print_tab:
    push rax
    push rcx
    push rdx 
    push rsi
    push rdi 
    mov rax, 1 
    mov rdi, rax 
    mov rsi, tab_char 
    mov rdx, rax 
    syscall
    pop rdi 
    pop rsi 
    pop rdx 
    pop rcx 
    pop rax 
    ret 