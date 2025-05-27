;on entry: rax
print_dec:
    push rax
    push rbx 
    push rcx
    push rdx
    push rdi
    push rsi
    mov rdi, pu64_buf
    mov rbx, 10
    xor rcx, rcx    ;для syscall, кол-во цифр в частном 
pd_l1:
    xor rdx, rdx
    div rbx       ;rdx - остаток, rax - частное 
    add dl, 30h   ;+0 для печати на экран 
    mov [rdi], dl  ;rdi - указатель на текущее положение строки для вывода, dl - младшмй байт rdx, остаток от деления на 10 
    inc rdi 
    inc rcx 
    or rax, rax 
    jnz pd_l1
    mov rsi, pu64_buf   
    dec rdi 
;rsi - указатель на 1 цифру, rdi - на последнюю цифру 
pd_l2:
    cmp rsi, rdi 
    jae pd_l3    ;if above or equal 
    mov al, [rsi]  ;в al - 1я цифра (левая)
    xchg al, [rdi]   ;замена al -> последняя цифра, первая al -> в последнюю rdi
    mov [rsi], al   ;al - последняя, ее в 1ю цифру 
    inc rsi 
    dec rdi 
    jmp pd_l2

pd_l3:
    mov rax, 1
    mov rdi, 1
    mov rsi, pu64_buf
    mov rdx, rcx 
    syscall   ;вывод 
    pop rsi 
    pop rdi 
    pop rdx 
    pop rcx 
    pop rbx 
    pop rax 
    ret 


;On entry: rax
print_uint64:
    push rdx
    push rax
    push rcx
    push rdi
    push rsi
    mov rdx, rax
    mov rdi, pu64_buf
    mov rcx, 16
pu64_l0:
    rol rdx, 4
    mov rax, rdx
    and al, 0xF
    cmp al, 9
    jna pu64_l1
    add al, 7
pu64_l1:
    add al, 30h   ;0
    stosb 
    loop pu64_l0
    mov rax, 1
    mov rdi, 1
    mov rsi, pu64_buf
    mov rdx, 16
    syscall
    pop rsi
    pop rdi
    pop rcx
    pop rax
    pop rdx
    ret


newline:
    push rax
    push rcx
    push rdx
    push rsi
    push rdi
    mov rax, 1
    mov rdi, rax
    mov rdx, 2
    mov rsi, cr
    syscall
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret


;rsi - указатель на Паскалевскую строку 
print_pascal_str:
    push rax
    push rdx
    push rsi
    push rdi
    lodsb   ;прочитать 1 байт по адресу rsi ; al - length rsi, -> rdx, rsi+1 - text str
    movzx rdx, al   ;zero extend: страший разряд rdx=0
    mov rax, 1
    mov rdi, 1
    syscall
    pop rdi
    pop rsi
    pop rdx
    pop rax
    ret


;on entry: rsi - pointer on string, ah, al - characters to erase 
jailed_string:
    push rax
    push rcx
    push rdx 
    push rsi
    push rdi
    push rsi  ;проходим строку до #, считаем кол-во байт 
    mov rcx, rax
    xor rdx, rdx    ;кол-во символов 
js_l1:
    lodsb  ;смотрим байт rsi
    cmp al, '#'
    je js_l2
    or rcx, rcx 
    jz js_l1a
    cmp al, cl    ;al - rax, cl - rcx 
    je js_l1b 
    cmp al, ch    ;ch - 2ой байт по меньшинству rcx 
    jne js_l1a
js_l1b:
    mov byte[rsi-1], ' '  ;lodsb+1 байт 
js_l1a:
    inc rdx    
    jmp js_l1
js_l2:
    pop rsi
    mov rdi, 1
    mov rax, 1
    syscall    ;print string 
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret


;on entry: ax - hex number 
;конвертирует 2-символьное 16-ричное число в регистре ax в 8-битное число (в al).
convert_16:
    sub ax, 3030h  ;ax-48 ; ah-48, al-48  
    cmp al, 09h   ;9 
    jna qp_l1   
    sub al, 7 
qp_l1:
    cmp ah, 09h
    jna qp_l2
    sub ah, 7 
qp_l2:
    shl al, 4
    or al, ah
    xor ah, ah 
    ret


;random numbers - метод Фон Неймана, меод срединного квадрата
rand:
    push rcx  ;counter
    push rdx  ;используется при умножении
    mov rax, [rnd]
    mul rax  ;квадрат rax 
    xor rax, rdx  
    mov [rnd], rax
    sub rcx, rcx  ;rcx=0
rand_l1:
    or rax, rax   ;проверка на 0
    jz rand_l2
    mov dl, al ; dl - младшие 4 бита из rax, al - 8 младших бит rax
    and dl, 0xF ;1111 - младшие 4 бита 
    mov byte[rcx+tmp2], dl
    shr rax, 4
    inc rcx
    jmp rand_l1
rand_l2:
    shr rcx, 1  ;rcx/2
    mov al, byte[rcx+tmp2] 
    pop rdx
    pop rcx
    ret

test_rand:
    mov rcx, 100
tr_l1:
    push rcx
    call rand
    cmp al, 9  ;без символов . , 
    jna tr_l2  ;без знака
    add al, 7
tr_l2:
    add al, 30h
    mov ah, 0xA  ;enter в столбик
    mov word[tmp], ax
    mov rax, 1
    mov rdi, 1
    mov rdx, 2
    mov rsi, tmp
    syscall
    pop rcx
    loop tr_l1
    ret
