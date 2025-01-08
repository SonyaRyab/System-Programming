;[994, ['Треды (clone)'], 
;['Среднее арифметическое значение (округленное до целого)',
;'Наиболее часто встречающаяся цифра в случайных числах', 
;'Наиболее редко встречающаяся цифра в случайных числах', 
;'Медиана (округленная до целого)']]

format elf64
public _start
include 'func.asm'

THREAD_FLAGS=2147585792

section '.data' writable

n dq 12
arr dq 8, 1, 1, 2, 2, 3, 4, 5, 6, 7, 10, 120

msg_avg  db 'Average: '
buf_avg db 32 dup(0)
msg_mode db 'Mode: '
buf_md db 32 dup(0)
msg_antimode db 'Antimode: '
buf_antmd db 32 dup(0)
msg_median db 'Median '
buf_med db 32 dup(0)
msg_done db 'Done.', 0


semphr_forth dw 0,1,4096,0
semphr_back dw 0,-1,4096,0
semphr_init dq 0

sem dq 0
task_count dq 4

section '.bss' writable

pid1 rq 1
pid2 rq 1
pid3 rq 1
pid4 rq 1
wstat rq 0

stack_1 rq 4096
stack_2 rq 4096
stack_3 rq 4096
stack_4 rq 4096
buffer rb 100
buffer4 rq 1024
tmp_buf rq 4096

sem_key rq 1

section '.text' executable

_start:

   ;;Печатаем PID родительского процесса
   ;mov rax, 39
   ;syscall
   ;mov rsi, buffer
   ;call number_str
   ;call print_str
   ;call new_line
   
   xor rdi, rdi
   mov rsi, 1
   mov rdx, 666o
   mov rax, 64
   syscall
   mov [sem_key], rax
   mov rdi, rax
   xor rsi, rsi
   mov rdx, 16
   mov rcx, semphr_init
   mov rax, 66
   syscall
   
   ;; Создаем новый тред   
   mov rsi, stack_1+4096   ;;Инициализируем указатель стека 
   mov rbx, new_thread1
   call create_new_thread
   mov [pid1], rax
   mov rsi, stack_2+4096   ;;Инициализируем указатель стека 
   mov rbx, new_thread2
   mov [pid2], rax
   call create_new_thread
   mov rsi, stack_3+4096   ;;Инициализируем указатель стека 
   mov rbx, new_thread3
   call create_new_thread
   mov [pid3], rax
   mov rsi, stack_4+4096   ;;Инициализируем указатель стека 
   mov rbx, new_thread4
   call create_new_thread
   mov [pid4], rax
   
lp1:
   mov rax, [task_count]
   or rax, rax
   jnz lp1
   
   mov rdi, [pid1]
   call waitchld     ;ожидает завершение указанного дочернего процесса
   mov rdi, [pid2]
   call waitchld 
   mov rdi, [pid3]
   call waitchld
   mov rdi, [pid4]
   call waitchld

   mov rsi, msg_done
   call print_str
   call new_line
   call exit

del_semphr0:
   mov rdi, [sem_key]
   xor rsi, rsi
   xor rdx, rdx
   xor rcx, rcx
   mov rax, 66
   syscall
   ret

; on entry: rdi = pid

waitchld:
   mov rsi, wstat
   mov rdx, 40000000h
   xor r10, r10
   mov rax, 61
   syscall
   ret

semwait0:
   push rax
   push rdx
   push rsi
   push rdi
l_semwait:
   mov rdi, [sem_key]
   xor rsi, rsi
   mov rdx, 14
   mov rax, 66
   syscall
   or rax, rax
   jnz l_semwait
   mov rdi, [sem_key]
   mov rsi, semphr_forth
   mov rdx, 1
   mov rax, 65
   syscall
   pop rdi
   pop rsi
   pop rdx
   pop rax
   ret
   
release_semphr0:
   push rax
   push rdx
   push rsi
   push rdi
   mov rdi, [sem_key]
   mov rsi, semphr_back
   mov rdx, 1
   mov rax, 65
   syscall
   pop rdi
   pop rsi
   pop rdx
   pop rax
   ret

semwait:
   push rax
sw_l:
   mov rax, [sem]
   or rax, rax
   jnz sw_l
   mov qword[sem], 1
   pop rax
   ret

release_semphr:
   mov qword[sem], 0
   ret

; On entry:
;	rsi	new thread's stack top


create_new_thread:
   ;; Создаем новый тред   
   mov rdi, THREAD_FLAGS   ;;Устанавливаем флаги
   mov rax, 56
   syscall
   or rax, rax    ;;Проверяем это дочерний процесс, или родитель
   jnz crnt_proceed
   jmp rbx
      
   ;;Продолжаем работу в родительском процессе
crnt_proceed:
   push rax
   ;call semwait
   ;mov rsi, buffer   ;;Печатаем PID дочернего процесса
   ;call number_str
   ;call print_str
   ;call new_line
   ;call release_semphr
   pop rax
   ret

   
;;THREAD 1: Average calculation

new_thread1:
   mov rcx, [n]
   mov rsi, arr
   xor rdx, rdx
   xor rbx, rbx
nt1_l1:
   lodsq
   add rbx, rax
   adc rdx, 0
   loop nt1_l1
   mov rax,[n]
   xchg rax, rbx  ; rdx:rax = dividend, rbx = divisor
   div rbx
   add rdx, rdx
   xchg rdx, rbx
   xchg rcx, rdx
   xchg rax, rbx  
   div rcx
   add rax, rbx      ; now rax = ready average (result)
   call semwait
   push rax
   mov rsi, buf_avg
   call number_str
   mov rsi, msg_avg
   call print_str
   pop rax
   call new_line
   call release_semphr
   dec qword[task_count]
   call exit


; THREAD 2: MODE CALCULATION
   
new_thread2:
   mov rbx, arr
   mov rcx, [n]
   xor r8, r8     ; max quantity of elements found
   mov r9, [rbx]  ; the max frequent element
nt2_l1:
   mov rdi, [rbx]
   add rbx, 8
   mov rsi, rbx
   dec rcx
   jz nt2_l5
   push rcx
   mov rdx, 1
nt2_l2:
   lodsq
   cmp rax, rdi
   jne nt2_l3
   inc rdx
nt2_l3:
   loop nt2_l2
   cmp rdx, r8
   jna nt2_l4
   mov r8, rdx
   mov r9, rdi
nt2_l4:
   pop rcx
   jmp nt2_l1   
nt2_l5:
   call semwait
   mov rax, r9
   mov rsi, buf_md
   call number_str
   mov rsi, msg_mode
   call print_str
   call new_line   
   call release_semphr
   dec qword[task_count]
   call exit

; THREAD 3: ANTIMODE CALCULATION
   
new_thread3:
   mov rbx, arr
   mov rcx, [n]
   mov r9, rcx
   mov r8, [rbx]
nt3_l1:
   mov rdi, [rbx]
   add rbx, 8
   dec rcx
   jz nt3_l5
   mov rsi, arr
   push rcx
   mov rcx, [n]
   mov rdx, 1
nt3_l2:
   lodsq
   cmp rax, rdi
   jne nt3_l3
   inc rdx
nt3_l3:
   loop nt3_l2
   cmp rdx, r9
   jnb nt3_l4
   mov r9, rdx ; memorizing the new antirecord
   mov r8, rdi ; and its antichampion
nt3_l4:
   pop rcx
   jmp nt3_l1   
nt3_l5:
   call semwait
   mov rax, r8
   mov rsi, buf_antmd
   call number_str
   mov rsi, msg_antimode
   call print_str
   call new_line
   call release_semphr
   dec qword[task_count]
   call exit


;;THREAD 4: Median calculation

new_thread4:
   mov rsi, arr
   mov rcx, [n]
   mov rdi, buffer4
   mov rdx, rcx
   mov rbx, rdi
   rep movsq      ;повторение rcx раз команды rep (loop)
   or rdx, rdx    ;проверка на 0 
   jz nt4_l5
nt4_l1:
   dec rdx
   jz nt4_l5
   mov rcx, rdx
   xor r10, r10
   mov rsi, rbx
   
nt4_l2:
   mov rdi, rsi
   lodsq
   mov r9, rax 
   lodsq
   sub rsi, 8
   cmp rax, r9
   jnl nt4_l3
   xchg rax, [rdi]
   mov [rsi], rax 
   inc r10
nt4_l3:
   loop nt4_l2
   or r10, r10
   jz nt4_l5
   jmp nt4_l1
nt4_l5:
   mov rcx, [n]
   shr rcx, 1
   mov rax, [rbx+rcx*8]
   jc nt4_l6
   add rax, [rbx+rcx*8-8]
   sar rax, 1
nt4_l6:
   call semwait
   push rbx
   mov rcx, [n]
   ;call print_arr
   pop rbx
   push rax
   mov rsi, buf_med
   call number_str
   mov rsi, msg_median
   call print_str
   pop rax
   call new_line
   call release_semphr 
   dec qword[task_count]
   call exit

print_arr:
   push rbx
   mov rax, 2020202020202020h ;8 пробелов
   mov rcx, 4096
   rep stosq ;заполение буфера
   xor rax, rax
   mov byte[rdi-1], 0
p_l1:
   mov rsi, tmp_buf
   mov rax, [rbx]
   call number_str
   add rsi, 16
   loop p_l1
   xor rax, rax
   stosb
   loop p_l1
   pop rsi
   call print_str
   ret
