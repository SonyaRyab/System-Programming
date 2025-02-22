format ELF64
public _start

section '.data'
start_room dq 8 dup(0) 
n dq 8 ;length
m dq 8 ;width
gav_str dq 0A0D30564147h 

section '.bss'
rooms rq 2048
tmp rq 1

;Ofs Len Meaning
;0    8   id 

section '.text'

_start:
    call gav
    ;mov rdi, rooms
    ;call generate0
    ;mov byte[gav_str+3], 31h
    ;call gav
    ;mov rsi, rooms
    ;call print_field
    xor rdi, rdi
    mov rax, 60
    syscall
    ;mov rbx, [start_room]
    ;mov rbx, [rbx+40]  ;room on the right

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

generate0:
;генерация когда все двери открыты
;идем из левого верхнего угла 
;4 указателя r8-north, r9-east, r10-south, r11-west
    xor r8, r8 ;north=0
    mov r9, rdi 
    ;rdi and r9
    add r9, 64  ; +64 r9 east 
    mov r10, [m]
    shl rax, 6 ;shift left *64
    add r10, rdi  ;west

    mov rdx, [n]
    g0_l1:
    xor r11, r11 ;west=0
    mov rcx, [m]
    cmp rdx, 1
    jne g0_l2
    xor r10, r10
    g0_l2:
    mov rbx, rdi
    mov rax, r8
    stosq  ;rax rdi, rdi+8
    cmp rcx, 1
    jne g0_l2b
    g0_l2a:
    mov rax, r9
    g0_l2b:
    stosq
    mov rax, r10
    stosq
    mov rax, r11
    stosq
    mov r8, rdi

    mov rax, rdx
    shl rax, 32
    or rax, rcx
    stosq
    xor rax, rax
    stosq
    stosq
    stosq
    add r9, 64
    or r10, r10
    jz g0_l3a
    add r10, 64
    g0_l3a:
    or r8, r8  ;проверка на 0
    jz g0_l3b
    add r8, 64
    g0_l3b:
    loop g0_l2
    mov r8, rdi
    mov rax, [m]
    shl rax, 6
    sub r8, rax
    dec rdx
    jnz g0_l1
    ret

    print_field:
    mov rdx, [n]
    pf_l1:
    push rdx
    mov rcx, [m]
    pf_l2:
    push rcx
    lodsq
    lodsq ;rax rsi, rsi+8
    lodsq
    lodsq
    lodsq
    mov rbx, rax
    shr rax, 16
    and rbx, 15 ;
    shl rbx, 8
    or rax, rbx
    add rax, 20303020h ; _00_
    mov [tmp], rax
    mov rax, 1
    mov rdi, 1
    mov rsi, tmp
    mov rdx, 4
    syscall
    add rsi, 24
    pop rcx
    loop pf_l2
    mov qword[tmp], 0A0Dh ;enter
    mov rax, 1
    mov rdi, 1
    mov rsi, tmp
    mov rdx, 2
    syscall
    pop rdx
    dec rdx
    jnz pf_l1
    ret

