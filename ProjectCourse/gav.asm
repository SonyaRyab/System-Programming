format ELF64
public _start

section '.data' writable
gav_str db 'gav', 10   ;enter

section '.bss' writable

;Ofs Len Meaning
;0    8   id 

section '.text' executable

_start:
    call gav
    xor rdi, rdi
    mov rax, 60
    syscall
    
gav:
push rax
push rcx
push rdx
push rsi
push rdi
mov rax, 1
mov rdi, 1
mov rsi, gav_str
mov rdx, 4
syscall
pop rdi
pop rsi
pop rdx
pop rcx
pop rax
ret
