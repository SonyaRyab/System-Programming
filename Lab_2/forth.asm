format ELF64 
public _start

num dq 5607798014
place db ?

_start:
    mov rax, [num]
    mov rcx, 10
    xor rbx, rbx
    iter0:
        xor rdx, rdx
        div rcx
        add rbx, rdx
        cmp rax, 0
        jne iter0
    call print
    call exit

print:
    mov rax, rbx
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

exit:
    mov rax, 1
    xor rbx, rbx
    int 0x80
