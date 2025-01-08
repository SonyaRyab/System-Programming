format ELF64

include 'func.asm'

 public _start

THREAD_FLAGS=2147585792

 section '.data' writable

 n dq 10
 x dq 7, 2, 4, 5, 1, 2, 3, 8, 9, 6
   dq 90 dup(0)
 sem dq 0
 sem_master dq 2
 odd_msg db 13, 10, 'Odd indices: ',0
 even_msg db 13, 10, 'Even indices: ',0
 msg_done db 13, 10, 'Done.', 13, 10, 0
 
 section '.bss' writable
 
 pids rq 2
 buf rb 100
 stack1 rb 1024
 stack2 rb 1024
 statvar rq 1 
 section '.text' executable
_start:
   popq rcx
   cmp rcx, 2
   jb _l_1
   popq rax
   popq rsi
;   call print_str
   call str_number
   mov [n], rax
   xchg rax, rcx
   push rcx
   mov rax, 96
   mov rdi, buf
   xor rsi, rsi
   syscall
   mov rax, qword [buf]
   ror rax, 32
   xor rax, qword [buf + 8]
   pop rcx
   mov rdi, x
_l_rnd:
   mov rdx, rax
   mul rdx
   ror rdx, 32
   rol rax, 32
   xor rax, rdx
   or rdx, rax
   and rax, 0xFF
   stosq
   mov rsi, buf
   call number_str
   call print_str
   call new_line
   xchg rax, rdx
   loop _l_rnd

_l_1:
   mov rax, stack1
   mov rbx, th1
   call new_thread
   mov [pids], rax
   mov rax, stack2
   mov rbx, th2
   call new_thread
   mov [pids+8], rax

_l_wait0:
   cmp qword [sem_master], 0
   jnz _l_wait0

   mov r10, 2
_l_wait:
   mov rsi, pids
   mov rcx, 2
_l_wait2:
   lodsq
   mov rdi, rax
   mov rdx, 1
   mov rax, 61
   push rcx
   push rsi
   mov rsi, statvar
   xor rcx, rcx
   syscall 
   pop rsi
   pop rcx
   cmp rax, 0
   jng _l_wait3
   dec r10
   jz _l_finish
_l_wait3:
   loop _l_wait2
_l_finish:
   cmp qword [sem], 0
   jne _l_finish
   mov qword [sem], 1
   mov rsi, msg_done
   call print_str
   call new_line
   mov qword [sem], 0
   call exit

; На входе:
;   rax  указатель стека для треда
;  rbx  точка входа дочернего треда
; На выходе:
;  rax  ID дочернего треда - в родительском треде, 0 - в дочернем треде
; Испорченные регистры:
;  rsi, rdi

new_thread:
   ;; Создаем новый тред
   mov rdi, THREAD_FLAGS;;Устанавливаем флаги
   xchg rax, rsi
   mov rax, 56
   syscall
   or rax, rax;;Проверяем это дочерний процесс, или родитель
   jnz nt_l1
   jmp rbx
nt_l1:
   ret


th1:
   mov rcx, [n]
   shr rcx, 1
   adc rcx, 0
   mov rsi, x
   xor rdx, rdx
th1_l1:
   lodsq
   add rdx, rax
   lodsq
   loop th1_l1
th1_l2:
   cmp qword [sem], 0
   jnz th1_l2
   mov qword [sem], 1
   mov rsi, even_msg
   call print_str
   mov rax, rdx
   mov rsi, buf
   call number_str
   call print_str
   mov qword [sem], 0
   dec qword [sem_master]
   call exit

th2:
   mov rcx, [n]
   shr rcx, 1
   mov rsi, x
   xor rdx, rdx
th2_l1:
   lodsq
   lodsq
   add rdx, rax
   loop th2_l1
th2_l2:
   cmp qword [sem], 0
   jnz th2_l2
   mov qword [sem], 1
   mov rsi, odd_msg
   call print_str
   mov rax, rdx
   mov rsi, buf
   call number_str
   call print_str
   mov qword [sem], 0
   dec qword [sem_master]
   call exit