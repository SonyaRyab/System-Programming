;Для n вычислить сумму 1+2-3-4+5+6-7-8+...+-n 
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
    mov rdx, 1
    mov rcx, 1
    
    call count_loop
    call print
    call exit

count_loop: 
    inc rcx
    cmp rcx, rbx
    jg end_loop

    test rcx, 1
    jnz substract
    add rdx, rcx
    jmp count_loop
substract:
    sub rdx, rcx
    jmp count_loop


end_loop:
    mov rsi, result_prompt
    call print_str
    mov rax, rdx
    call print
    call exit

input_prompt db "Enter n: ", 0
result_prompt db "Result: ", 0