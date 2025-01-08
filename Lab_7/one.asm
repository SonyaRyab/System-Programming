format elf64
public _start
include 'func.asm'

section '.data' writable

process_id dq 0
argv dq 0, 0
msg_enter db 'Enter command: ',10, 0
msg_started db 'Started process ID: ',0
msg_end db 'Program terminated', 10, 0

section '.bss' writable

buffer rb 100
status rd 1
section '.text' executable

_start:

   ;;Печатаем PID родительского процесса
l1:
   mov rax, 39
   syscall
   mov rsi, buffer
   call number_str
   call print_str
   call new_line

   mov rsi, msg_enter
   call print_str
   mov rsi, buffer
   call input_keyboard
   
   mov rax, 57
   syscall
   mov [process_id], rax
   or rax, rax
   jz do_exec
   mov rsi, buffer
   call number_str
   mov rsi, msg_started
   call print_str
   call new_line
   mov rsi, buffer
   call print_str
   
   mov rcx, 1000000000
delay:
   nop
   loop delay
   mov rdi, [process_id]
   mov rsi, status
   mov rdx, 1
   mov r10, 0
   mov rax, 61
   syscall
   jmp l1
   
do_exec:
   mov rdi, buffer
   mov rsi, argv
   mov [rsi], rdi
   mov rdx, 0
   mov rax, 59
   syscall
   mov rsi, msg_end
   call print_str
   mov rax, 60
   mov rdi, 0
   syscall

