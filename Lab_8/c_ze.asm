;крестики-нолики реализация 

format ELF64

public _start
include 'func.asm'

section '.data' writeable
    f0 db 3 dup('.'), 0, 3 dup('.'), 0, 3 dup('.'), 0  
    f db 3 dup('.'), 0, 3 dup('.'), 0, 3 dup('.'), 0  
    msg1 db 'За кого вы играете? X/0 ', 0xA, 0
    sym db 'X'
    in_buf db 10 dup(0)
    msg2 db '  победили', 0xA, 0
    msg3 db 'Хотите ли сыграть еще? (y/n)', 0xA, 0
    msg4 db 'Ход  ', 0xA, 0
    msg5 db 'Введите строку:  ', 0
    msg6 db 'Введите столбик:  ', 0
    msg7 db 'Занято!!!', 0xA, 0
    msg8 db 'Неверная координата', 0xA, 0

section '.bss' writable
    
section '.text' executable

_start:

_loop:
    call print_field

_input_xy:
    _input_x:
    mov rsi, msg5
    call print_str
    mov rsi, in_buf
    call input_keyboard
    mov rsi, in_buf
    call str_number
    cmp rax, 3
    jb _x_ok

    mov rsi, msg8
    call print_str
    jmp _input_x
;проверка на норм координаты
_x_ok:
    mov r9, rax
_input_y:
    mov rsi, msg6
    call print_str
    mov rsi, in_buf
    call input_keyboard
    mov rsi, in_buf
    call str_number
    cmp rax, 3
    jb _y_ok
    mov rsi, msg8
    call print_str
    jmp _input_y
_y_ok:
    mov r10, rax
    cmp byte [f+r9*4 + r10], '.'
    je _put_sym
    mov rsi, msg7
    call print_str
    jmp _input_xy

_put_sym:
    mov al, [sym]
    mov byte [f+r9*4 + r10], al  
    call _if_horizontal
    or al, al   ;al!=0 
    jnz _win
    call _if_vertical
    or al, al
    jnz _win
    call _d_win
    or al, al
    jnz _win
    ;0 = 0x30 = 0011 0000
    ;X = 0x58 = 0101 1000
    ;0110 1000 = 0x68
    xor byte[sym], 0x68     ;0-X
    jmp _loop

_win:
    call print_field
    mov rsi, msg2
    mov [rsi], al
    call print_str
    mov rsi, msg3
    call print_str
    mov rsi, in_buf
    call input_keyboard
    mov al, [in_buf]
    cmp al, 'y'
    jne _finish 
    mov rsi, f0
    mov rdi, f
    movsq 
    movsd 
    jmp _loop

_finish:
    call exit

print_field:
    push rcx
    push rsi
    push rax
    mov rcx, 3  
    mov rsi, f

_print_loop:
    push rcx
    push rsi
    call print_str
    call new_line
    pop rsi
    add rsi, 4  ;указатель на строку +4
    pop rcx
    loop _print_loop
    mov al, [sym]
    mov rsi, msg4
    mov [rsi+7], al
    call print_str
    pop rax
    pop rsi
    pop rcx
    ret

;функция возвращает в al символ победителя или 0, если никто не выиграл
_if_horizontal:
    xor rax, rax
    mov rsi, f
    mov rcx, 3
_h_loop:
    lodsb   ;al - 1 байт, al - 1 pos str
    cmp al, '.'
    je _h_no_win
    mov dl, al  ;dl - 1 pos str
    lodsw   ;ax -> al, ah: al - 2 pos str, ah - 3 pos str
    cmp dl, al 
    jne _h_no_win
    cmp dl, ah
    je _h_res
_h_no_win:
    inc rsi 
    loop _h_loop     ;dec rcx, jnz .h_loop 
    xor rax, rax    
_h_res:
    ret

;функция возвращает в al символ победителя или 0, если никто не выиграл
_if_vertical:
    xor rax, rax
    mov rsi, f
    mov rcx, 3
_v_loop:
    lodsb   ;al - 1 байт, al - 1 pos str
    push rsi
    cmp al, '.'
    je _v_no_win
    mov dl, al  ;dl - 1 pos str
    add rsi, 3
    lodsb
    cmp dl, al 
    jne _v_no_win
    add rsi, 3
    lodsb
    cmp dl, al 
    jne _v_no_win
    pop rsi
    jmp _v_res
_v_no_win:
    pop rsi
    loop _v_loop     ;dec rcx, jnz .h_loop 
    xor rax, rax    
_v_res:
    ret

_d_win:
    mov rsi, f
    mov al, [rsi + 5]       
    cmp al, '.'
    je _d_nowin2
    cmp al, [rsi]       
    jne _d_nowin1        
    cmp al, [rsi+10]        
    je _d_res       
_d_nowin1:      
    cmp al,[rsi + 2]    
    jne _d_nowin2   
    cmp al,[rsi + 8]    
    je _d_res   
_d_nowin2:
    xor rax, rax
_d_res:
    ret