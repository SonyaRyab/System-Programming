;Для заданного n вычислить сумму (-1)^k*k*(k+4)*(k+8)
format ELF64
public _start

include 'func.asm'
include 'print.asm'

in_buf dq 256
res_buf dq 256

_start:
    mov rsi, input_prompt
    call print_str

    mov rsi, in_buf
    call input_keyboard
    call str_number  
    mov rbx, rax
    xor rdi, rdi
    xor rcx, rcx
    
    call count_loop
    call print
    call exit

count_loop: 
    inc rcx ; k
    cmp rcx, rbx
    jg end_loop

    mov rax, rcx 
    mov rsi, rcx
    add rsi, 4
    mul rsi
    
    add rsi, 4
    mul rsi

    test rcx, 1
    jz even

    sub rdi, rax    
    jmp count_loop
even:    
    add rdi, rax    
    jmp count_loop


end_loop:
    mov rsi, result_prompt
    call print_str
    mov rax, rdi
    call print
    call exit

input_prompt db "Enter n: ", 0
result_prompt db "Result: ", 0