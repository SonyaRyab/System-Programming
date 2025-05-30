;;server_4.asm

format ELF64
public _start
include 'func.asm'
include 'c_ze.asm'

section '.data' writeable
  
  msg_1 db 'Error bind', 0xa, 0
  msg_2 db 'Successfull bind', 0xa, 0
  msg_3 db 'New connection on port ', 0
  msg_4 db 'Successfull listen', 0xa, 0
  msg1 db 'Lab_8 is working', 0xA, 0
  
section '.bss' writable

  buffer rb 100
  f db 3 dup('.'), 0, 3 dup('.'), 0, 3 dup('.'), 0  

;;Структура для клиента
  struc sockaddr_in
{
  .sin_family dw 2         ; AF_INET
  .sin_port dw 0x3d9     ; port 55555
  .sin_addr dd 0           ; localhost
  .sin_zero_1 dd 0
  .sin_zero_2 dd 0
}

  addrstr sockaddr_in 
  addrlen = $ - addrstr

section '.text' executable

_start:
    ;;Создаем сокет
    mov rdi, 2 ;AF_INET - IP v4 
    mov rsi, 1 ;SOCK_STREAM
    mov rdx, 6 ;TCP
    mov rax, 41
    syscall
    
    ;;Сохраняем дескриптор сокета
    mov r9, rax
    
    ;;Связываем сокет с адресом
    
    mov rax, 49              ; SYS_BIND
    mov rdi, r9              ; дескриптор сервера
    mov rsi, addrstr        ; sockaddr_in struct
    mov rdx, addrlen         ; length of sockaddr_in
    syscall

    ;; Проверяем успешность вызова
    cmp        rax, 0
    jl         _bind_error
    
    
    ;;Запускаем прослушивание сокета
    mov rax, 50 ;sys_listen
    mov rdi, r9 ;дескриптор
    mov rsi, 10  ;количество клиентов
    syscall
    cmp rax, 0
    jl  _bind_error
    
    ;;Главный цикл ожидания подключений
    .main_loop:
      ;;accept
      mov rax, 43
      mov rdi, r9
      mov rsi, f
      mov rdx, 0
      syscall
      
      ;;Сохраняем дескриптор сокета клиента
      mov r12, rax
       
     ;;Делаем fork for read
   
     mov rax, 57
     syscall
   
     cmp rax,0
     je _read
     
     mov rax, 57
     syscall
   
     cmp rax,0
     je _write
      
     jmp .main_loop
    
_bind_error:
   mov rsi, msg_1
   call print_str
   call exit
   
_read:
      mov rax, 0  ;номер системного вызова чтения
      mov rdi, r12  ;загружаем файловый дескриптор
      mov rsi, f
      ;mov rsi, buffer   ;указываем, куда помещать прочитанные данные
      mov rdx, 100  ;устанавливаем количество считываемых данных
      syscall   ;выполняем системный вызов read
      
      ;;Если клиент ничего не прислал, продолжаем
      cmp rax, 0
      je _read     
      call print_str
      call new_line
      
      ;;Очищаем буффер, чтобы он не хранил старые значения
      mov rcx, 100
      mov rax, 0
      .lab:
        mov [buffer+rcx], 0
      loop .lab 
jmp _read

_write:
    mov rsi, f
    call print_str
    ;call print_field
    ;mov rsi, buffer
    ;call input_keyboard

    ;;Отправляем сообщение клиенту
    mov rax, 1
    mov rdi, r12
    mov rsi, f
    ;mov rsi, buffer
    mov rdx, 100
    syscall
jmp _write