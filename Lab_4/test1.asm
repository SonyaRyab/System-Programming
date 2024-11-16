format ELF64
public _start
include 'func.asm'

in_buf dq 256
res_buf db 32

_start:
    mov rsi, in_buf
    call input_keyboard
    mov rsi, in_buf
    call str_number
    mov rdi, 481
    xor rdx, rdx
    div rdi
    mov rsi, res_buf
    call number_str
    mov rsi, res_buf
    call print_str
    call new_line
    call exit