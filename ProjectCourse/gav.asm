format ELF64
public _start

section '.data'
gav_str dq 0x0A0D30564147

section '.bss'


;Ofs Len Meaning
;0    8   id 

section '.text'

_start:
    call gav
    xor rdi, rdi
    mov rax, 60
    syscall
    
gav:
push rax
push rdx
push rsi
push rdi
mov rax, 1
mov rdi, 2
mov rsi, gav_str
mov rdx, 5
syscall
pop rdi
pop rsi
pop rdx
pop rax
ret
