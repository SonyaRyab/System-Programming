format ELF64
public _start

array db 5 dup ('&')
simv_newline db 0xA, 0
simv db ?

_start:
    xor rcx, rcx
    xor rdx, rdx
    .iter1:
        push rcx
        xor rdx, rdx
        .iter2:
            push rdx
            mov al, [array+rdx]
            call print_simv
            pop rdx
            inc rdx
            cmp rdx, 5
            jne .iter2
        push rdx
        call print_newline
        pop rdx
        pop rcx
        inc rcx

        cmp rcx, 11
        jne .iter1
    call exit

print_simv:
    mov [simv], al
    mov rax, 4
    mov rbx, 1 
    mov rcx, simv
    mov rdx, 1 
    int 0x80
    ret

print_newline:
    mov rax, 4
    mov rbx, 1
    mov rcx, simv_newline
    mov rdx, 1
    int 0x80
    ret

exit:
    mov rax, 1
    xor rbx, rbx
    int 0x80