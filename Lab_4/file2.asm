format ELF64
public _start

n dq 0           ; Переменная для хранения числа n
result dq 0      ; Переменная для хранения суммы
msg db 'Sum: ', 0


_start:
    ; Чтение числа n (через системный вызов для простоты вводим с клавиатуры)
    mov rax, 0      ; системный вызов sys_read (номер 0)
    mov rdi, 0      ; ввод с клавиатуры
    mov rsi, n      ; буфер для числа
    mov rdx, 10     ; максимальная длина строки
    syscall

    ; Преобразование строки в число
    mov rax, 0      ; обнуляем rax для результата
    mov rdi, n      ; адрес строки
parse_input:
    movzx rbx, byte [rdi] ; берем текущий символ
    cmp rbx, 10     ; проверяем конец строки (символ новой строки)
    je calc_sum     ; если конец строки - идем к вычислению
    sub rbx, '0'    ; преобразуем символ в цифру
    imul rax, rax, 10 ; умножаем текущий результат на 10
    add rax, rbx    ; добавляем текущую цифру
    inc rdi         ; переходим к следующему символу
    jmp parse_input

calc_sum:
    ; n теперь хранится в rax, сбросим результат в rsi
    xor rsi, rsi    ; обнуляем rsi, будем в нем хранить сумму
    xor rbx, rbx    ; обнуляем rbx, это будет счетчик

loop_start:
    inc rbx             ; увеличиваем счетчик
    cmp rbx, rax        ; если счетчик больше n, то выходим
    jg end_loop
    
    ; Если остаток от деления rbx на 4 == 1 или 2, то прибавляем
    mov rdx, rbx
    and rdx, 3
    cmp rdx, 2
    jle add_number
    
    ; Иначе вычитаем
    sub rsi, rbx
    jmp loop_start

add_number:
    add rsi, rbx
    jmp loop_start

end_loop:
    ; rsi теперь содержит сумму
    ; Вывод результата на экран

    mov rax, 1         ; системный вызов sys_write
    mov rdi, 1         ; вывод в stdout
    mov rsi, msg       ; адрес сообщения
    mov rdx, 5         ; длина сообщения
    syscall

    ; Преобразование числа в строку и вывод
    mov rdi, rsi       ; результат в rdi для печати
    call print_number  ; вызов функции печати числа

    ; Завершаем программу
    mov rax, 60        ; системный вызов sys_exit
    xor rdi, rdi       ; код возврата 0
    syscall

print_number:
    ; rdi содержит число для печати
    mov rax, rdi
    mov rdi, 10        ; база для деления
    xor rbx, rbx       ; обнуляем rbx
    mov rsi, rsp       ; используем стек для временного хранения цифр

print_loop:
    xor rdx, rdx       ; обнуляем rdx перед делением
    div rdi            ; делим rax на 10, результат в rax, остаток в rdx
    add dl, '0'        ; преобразуем остаток в символ
    dec rsi            ; уменьшаем указатель стека
    mov [rsi], dl      ; сохраняем символ в стек
    test rax, rax      ; если rax == 0, то завершили
    jnz print_loop

    mov rdx, rsp       ; rdx теперь указывает на начало строки
    mov rdi, 1         ; вывод в stdout
    mov rax, 1         ; системный вызов sys_write
    mov rdx, rsp       ; количество символов (размер стека до rsp)
    syscall
    ret