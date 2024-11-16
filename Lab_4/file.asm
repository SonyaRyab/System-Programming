format elf64
public _start
public is_prime

;include 'prime.asm'
include 'func.asm'

section '.bss' writable
  place rb 255
  answer rb 2

_start:
  mov rsi, place
  call input_keyboard
  call str_number
  call is_prime
  mov rax, rdi
  mov rsi, answer
  call number_str
  call print_str
  call new_line
  call exit