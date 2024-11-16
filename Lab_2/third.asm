format ELF64
public _start

simv db "&", 0
simv_newline db 0xA, 0

_start:
    mov rcx, 300  ;кол-во символов
    mov rdx, 0   ;длина 

    .iter1:
        inc rdx
        push rdx
        .iter2:
            dec rdx
            push rcx
            push rdx
            call print_simv
            pop rdx
            pop rcx
            dec rcx
            cmp rdx, 0
            jne .iter2
        pop rdx
        push rdx
        push rcx
        call print_newline
        pop rcx
        pop rdx

        cmp rcx, 0
        jne .iter1
    call exit

print_simv:
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
    mov rbx, 0
    int 0x80