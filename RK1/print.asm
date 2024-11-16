place db ?
print:
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
            call print_symb
            dec rbx
            cmp rbx, 0
        jne iter2
        mov rax, 0xA
        call print_symb
        ret

print_symb:
    push rbx
    push rdx
    push rcx
    push rax
    push rax
    mov eax, 4
    mov ebx, 1
    pop rdx
    mov [place], dl
    mov ecx, place
    mov edx, 1
    int 0x80
    pop rax
    pop rcx
    pop rdx
    pop rbx
    ret
    