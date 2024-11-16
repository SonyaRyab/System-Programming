format ELF64
public _start

msg db 0xA, "qICelfwrMKpLbficRZvsmdvghv", 0
len = $ - msg

_start:
    mov rcx, msg
    mov rdx, len
    


    reverse:
        dec rdx
        push rdx
        mov rax, 4
        mov rbx, 1
        mov rcx, msg
        add rcx, rdx
        mov rdx, 1
        int 0x80
        
        pop rdx
        cmp rdx, 0
        jne reverse
    call exit

exit:
    mov rax, 1
    mov rbx, 0
    int 0x80
