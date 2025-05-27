include 'utilities.asm'
question_test:
    push rsi 
    push rdi 
    push rdx
    push rcx 
    push rbx 
    call rand    ;rax - random number of a question 
    xor rdx, rdx 
    mov rcx, [qst_amount]   ;значение    
    div rcx    ;rcx - кол-во вопросов 
    mov rax, rdx 
    call print_uint64
    mov rsi,  qword[ptr_buf + rdx*8]   ;rdx - остаток от деления ранд числа/кол-во вопросов; rdx - № вопроса
    lodsd 
    call convert_16    ;ax - 04, 16-> number 4
    movzx rcx, ax  ;option count ;rcx - кол-во варинтов ответов
    shr rax, 16   ;сдвиг, убираем 04, получаем верный вариант ответа 0401 -> 01 
    call convert_16
    movzx rdx, ax   ;rdx - верный ответ 
    mov ax, 2B2Dh 
    call jailed_string
qt_l0:  
    push rcx 
    push rdx 
    mov rsi, dlg_buf 
    xor rdi, rdi
    mov rdx, 2   ;2 символа: буква+enter
qt_l1:
    xor rax, rax
    syscall
    lodsb ;символ в al 
    cmp al, 0Ah
    je qt_l1
    pop rdx 
    pop rcx 
    cmp al, 60h    ;маленькая буква 
    jb qt_l2
    sub al, 20h   ;большая буква
qt_l2:
    sub al, 41h   ;заглавная A 
    jb qt_l0 
    cmp al, cl    ;cl - кол-во вариантов ответа 
    jnb qt_l0 
    sub al, dl    ;!=0 - ответ неверный, al - введенный символ П, dl - верный ответ 
    movzx rax, al   ;обнулили старшие байты rax (rax=0)
    pop rbx 
    pop rcx
    pop rdx 
    pop rdi 
    pop rsi 

;запрашиваем ответ 
;вернуть 0, если ответ верный, F - ответ неверный 
    ret
