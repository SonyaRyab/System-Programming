format ELF64
public _start

;section .data
    input db 0
    result db 0

;section .bss
    num resb 10
    sum resb 10

;section .text
    global _start

_start:
    ; Ввод числа n
    mov rsi, num
    call input_keyboard

    ; Преобразование строки в число
    mov rsi, num
    call str_number

    ; Сохранение числа в rbx
    mov rbx, rax

    ; Инициализация суммы
    xor rax, rax
    xor rcx, rcx

    ; Цикл для вычисления суммы
    .calc_sum:
        inc rcx
        cmp rcx, rbx
        jg .end_calc

        ; Чередование знаков
        test rcx, 1
        jz .add
        sub rax, rcx
        jmp .calc_sum

        .add:
        add rax, rcx
        jmp .calc_sum

    .end_calc:
    ; Преобразование результата в строку
    mov rsi, sum
    call number_str

    ; Печать результата
    mov rsi, sum
    call print_str

    ; Завершение программы
    call exit