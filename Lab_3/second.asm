format ELF64
public _start
include 'func.asm'

place db ?

_start:
    mov rsi, [rsp+16]   ;pointer on a
    call str_number     ;from string in rsi to number in rax
    mov rdi, rax        ;save a in rdi

    sub rax, rax
    add rax, rdi
    mov rdi, rax       ;current result in rdi

    mov rsi, [rsp+24]  
    call str_number    ;from string in rsi to number in rax
    
    sub rdi, rax
    mov rax, rdi       ;result in rax

    call print_num
    call new_line
    call exit

;input rax
print_num:
    mov rcx, 10
    xor rbx, rbx
    iter1:
        xor rdx, rdx
        div rcx
        add rdx, '0'
        push rdx
        inc rbx
        cmp rax, 0
    jne iter1
    iter2:
        pop rax
        call print_symbl_num
        dec rbx
        cmp rbx, 0
    jne iter2
    ret

print_symbl_num:
    push rbx
    push rdx
    push rcx
    push rax
    push rax
    mov rax, 4
    mov rbx, 1
    pop rdx
    mov [place], dl
    mov rcx, place
    mov rdx, 1
    int 0x80
    pop rax
    pop rcx
    pop rdx
    pop rbx
    ret