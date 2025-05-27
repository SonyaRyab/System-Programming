format ELF64
include 'utilities.asm'
include 'question_test.asm'
include 'table_rec.asm'

public _start

section '.data' writable
    ;start_room dq 8 dup(0) 
    n dq 8    ;length
    m dq 8    ;width
    cr dq 0A0Dh
    gav_str dq 0A30564147h 
    rnd dq 0A30564147h, 0, 0, 0
    score dq 0  ;очки при собирании артефактов 
    steps dq 0  ;шаги 
    qst_amount dq 0   ;кол-во вопросов в тесте 
    msg_stuknulis db 24, 'You have hit the wall.', 13, 10
    msg_been_there db 28, 'You have been in this room', 13, 10
    no_file_msg db "Послушай, Дарагой, а где файл с тестом??", 13, 10, "#"
    clue_msg1 db "If you venture to the #"
    clue_msgN db "North: #"
    clue_msgE db "East: #"
    clue_msgS db "South: #"
    clue_msgW db "West: #"
    clue_msg2 db " steps to the goal.", 13, 10, "#"
    clue_msg3 db "No way.", 13, 10, "#"
    clue_msg4 db "Go learn System Programming!", 13, 10, "#" 
    clue_msg_lst dq clue_msgW, clue_msgS, clue_msgE, clue_msgN  ;указатели на начала строк подсказок
    art_msg db 27, "You have collected artifact"
    score_msg db 14, "Your score is "
    alive_msg db 16, 27, '[1;32mAlive', 27, '[0m' ;green 
    dead_msg db 15, 27, '[5;30mDead', 27, '[0m'   ;black 
    filename db "one.txt", 0
    record_file db "record_file.dat", 0
    msg_hello db 7, "Hello, "
    msg_name db 19, "What is your name? "
    msg_win db 18, 'Congratulations!', 13, 10
    msg_mode db 48, "Which mode do you prefer: hard (H) or easy (E)? "
    room_descr1 db 27, 'You are in the room #  .', 13, 10 ;32 bytes ;enter ;27 - length
    room_descr2 db 20, 'It has doors to the ' ;20 bytes
    r_east db 15, 27, '[1;32mEast', 27, '[0m'     ;green ;15 ; 27-сигнал о краске ; '[0m' - красить закончили
    r_west db 15, 27, '[1;35mWest', 27, '[0m'     ;violet
    r_north db 16, 27, '[1;36mNorth', 27, '[0m'   ;cyan
    r_south db 16, 27, '[1;31mSouth', 27, '[0m'   ;red
    r_comma db 2, ', '
    r_dot db 3, '.', 13, 10  ;. enter
    room_qst db 33, 'Where would you go? (E, N, W, S) ' ;33 bytes
    cannot_open_file db 20, "Error opening file", 13, 10
    mode_flag db 0  
    tab_char db 9

section '.bss' writable
    buffer rb 2600   ;строка-изображение  
    rooms rq 2048
    tmp rq 1
    tmp2 rq 128
    pu64_buf rb 24   ;16+8 для 10-чных
    dlg_buf rb 16
    test_buf rb 8
    ptr_buf rb 256  ;список указателей на вопросы, 10 шт; 1 байт-кол-во, 2 байт-№ верного ответа 
    qst_buf rb 4096   ;буфер для вопросов 
    user_buf rb 64     ;буфер для имен игроков 
    records_buf rb 256  ;буфер для печати рекордов
    
;комната 6 байта + 2 байта стенки 
;5*65 байт - 1 ряд комнат, 1 комната - 6 байт
;весь лабиринт 8*8, 5*65*8 = 2600 байт 

;Ofs Len Meaning
;=== === =======
;0     8    north
;8     8    east
;16    8    south
;24    8    west
;32    8    id = {x, y}
;40    8    description
;48    8    artifacts
;56    8    visited

section '.text' executable

_start:
    mov rax, 2          ;open file 
    mov rdi, filename   ;указатель на строку с именем файла 
    xor rsi, rsi        ;flags=0 - флаги открытия readonly  
    mov rdx, 444o       ;444o - права доступа на чтение (8-ричное представление)
    syscall      
    or rax, rax         ;ошибка при чтении-проверка знака (установка флагов), в rax - файловый дескриптор (неотрицательное число)/код ошибки (отрицательное число)
    jns qp_l0           ;jump if not signed (SF-Signed Flag), перейти если нет отрицат знака 
    mov rsi, cannot_open_file
    call print_pascal_str
    jmp init_game

;читает файл и сохраняет указатели на строки, начинающиеся с '#'
;question_parse
qp_l0:
    mov rdi, rax   ;файловый дескриптор (получен ранее)->rdi 
    xor rax, rax 
    mov rsi, qst_buf  ;указатель на буфер для чтения 
    mov rdx, 1000h   ;размер буфера 4 Кб
    syscall    ;read 
    push rax   ;сохраняем кол-во прочитанных байт в стеке 
    mov rax, 3   
    syscall    ;close file 
    mov rdi, ptr_buf  
    mov rsi, qst_buf 
    lodsw            ;load 2 bytes (word) -> ax, rsi++ 
    call convert_16 
    movzx rax, al 
    mov qword[qst_amount], rax 
    pop rcx
qp_l3:
    lodsb     ;load 1 byte -> ax, rsi++
    cmp al, '#'
    jne qp_l5
    mov rax, rsi 
    stosq     ;store string quadword ;записывает 8 байт (rax) по адресу [rdi]
qp_l5:
    loop qp_l3
    mov rsi, ptr_buf 
    sub rdi, 8 
    movsq    ;lodsq+stosq ;lodsq - load string quadword 

init_game:
    mov rsi, msg_name
    call print_pascal_str
    xor rax, rax  ;read 
    mov rdi, rax 
    mov rsi, user_buf+1    ;1 символ - длина введенного имени 
    mov rdx, 63  ;оставшая длина буффера 
    syscall 
    mov rdi, rsi 
    dec rdi  
    stosb    ;длина имени - сдвиг 
    mov rsi, msg_hello
    call print_pascal_str
    mov rsi, user_buf
    call print_pascal_str
l_mode:
    mov rsi, msg_mode 
    call print_pascal_str
    mov rdx, 2    ;ввод 1 символа + enter 
    xor rdi, rdi 
    xor rax, rax 
    mov rsi, dlg_buf
    syscall 
    lodsb    ;чтение 1 байта по адресу [rsi] в al; rsi++
    cmp al, 'a'  ;буква маленькая 
    jb l_mode_a
    sub al, 32   ;между а и А = 32 символа 
l_mode_a:
    cmp al, 'H'
    jne l_mode_easy
    mov byte[mode_flag], 1  ;hard mode 
    jmp init_random
l_mode_easy:
    cmp al, 'E'
    jne l_mode
    mov byte[mode_flag], 0

init_random:
    mov rax, 64h  ;100 = times
    mov rdi, rnd  ;random 
    syscall
    mov rdx, rax
    shr rdx, 32
    xor rax, rdx
    xor qword[rnd], rax
l_gen:
    mov rdi, rooms
    call generate0
    mov rsi, rooms
    call lock_doors
    mov rdi, rooms+64*63   ;смещение на последнюю комнату от начала массива rooms 
    mov rdx, 1
    call solve
    ;inc rax    ;rax =F -> inc=0 
    ;jz l_gen   ;generate again 
    mov al, [mode_flag]
    cmp al, 1
    je no_print 
    call print_field
no_print:
    mov rbx, rooms
    mov r13, 0000000100000001h  ;двойные слова
    call dialogue
    mov qword[dlg_buf], rax
    mov rax, 2
    mov rdi, record_file
    mov rdx, 666o  
    mov rsi, 441h   ;флаги открытия 
    syscall 
    mov rdi, rax 
    mov rax, 1
    mov rsi, user_buf
    xor rdx, rdx 
    mov dl, byte[rsi]    ;длина имени пользователя 
    inc rdx 
    syscall 
    mov rsi, steps 
    mov rdx, 8
    mov rax, 1
    syscall   ;записываем steps 
    mov rsi, score 
    mov rdx, 8
    mov rax, 1
    syscall
    mov rsi, dlg_buf 
    mov rdx, 8
    mov rax, 1
    syscall 
    mov rax, 3
    syscall   ;close 
    mov rdi, record_file
    call table_rec
    ;call test_rand
    xor rdi, rdi
    mov rax, 60
    syscall
    ;mov rbx, [start_room]
    ;mov rbx, [rbx+40]  ;room on the right

gav:
    push rax
    push rcx
    push rdx
    push rsi
    push rdi
    mov rax, 1
    mov rdi, 1
    mov rsi, gav_str
    mov rdx, 5
    syscall
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

;on entry:
;rbx - pointer to starting room 
;r13 - target artifact (target id)
;returns: rax=0 (success), =Q (fail) 
dialogue:
    push rbx 
    push rdx
    push rsi
dlg_l1:
    inc qword[steps]    ;ДОБАВИТЬ вывод кол-ва пройденных шагов на экран 
    mov rax, [rbx+48]
    ;add rax, [score]
    ;call print_uint64
    add [score], rax
    mov rax, [rbx+32]
    cmp r13, rax    ;id, pointers on east, west, south, north
    jne dlg_l2
    jmp dlg_win 
dlg_l2:
    mov rdx, rax
    shr rax, 24     ;y>>24  3 байт вправо ***y***x -> ******yx 
    or rax, rdx
    add rax, 3030h ; +00
    mov word[room_descr1+22], ax  ;номер комнаты в строку 
    mov rsi, room_descr1
    call print_pascal_str
    test qword[rbx+56], 80h   ;56 - краска; 80h - степень 2, 1 бит 
    jz dlg_l2_no 
    mov rsi, msg_been_there 
    call print_pascal_str
dlg_l2_no:  ;не были в комнате 
    or qword[rbx+56], 80h   ;устанавливаем бит 80h, были в комнате 
    mov rsi, room_descr2
    call print_pascal_str
    xor rdx, rdx
dlg_l2n:
    cmp qword[rbx], 0
    jz dlg_l2e
    mov rsi, r_north
    call print_pascal_str
    inc rdx
dlg_l2e:
    cmp qword[rbx+8], 0
    jz dlg_l2s
    or rdx, rdx
    jz dlg_l2ee
    mov rsi, r_comma
    call print_pascal_str
dlg_l2ee:
    mov rsi, r_east
    call print_pascal_str
    inc rdx
dlg_l2s:
    cmp qword[rbx+16], 0
    jz dlg_l2w
    or rdx, rdx
    jz dlg_l2ss
    mov rsi, r_comma
    call print_pascal_str
dlg_l2ss:
    mov rsi, r_south
    call print_pascal_str
    inc rdx
dlg_l2w:
    cmp qword[rbx+24], 0
    jz dlg_l3
    or rdx, rdx
    jz dlg_l2ww
    mov rsi, r_comma
    call print_pascal_str
dlg_l2ww:
    mov rsi, r_west
    call print_pascal_str
    inc rdx
dlg_l3:
    mov rsi, r_dot
    call print_pascal_str
    mov rsi, score_msg
    call print_pascal_str
    mov rax, [score]
    call print_dec
    call newline
    mov [rbx+48], rax 
    or al, al 
    jz dlg_l3a
    mov rsi, art_msg
    call print_pascal_str
    call newline
    mov qword[rbx+48], 0  ;8байт 
dlg_l3a:
    mov rsi, room_qst
    call print_pascal_str
    mov rsi, dlg_buf 
    xor rdi, rdi
    mov rdx, 2   ;2 символа: буква+enter
dlg_l3b:
    xor rax, rax
    syscall
    lodsb ;символ в al 
    cmp al, 0Ah
    je dlg_l3b
    ;call print_uint64
    cmp al, 60h
    jna dlg_l3n
    sub al, 20h  ;переводим маленькие буквы в большие 
dlg_l3n:
    cmp al, 'N'
    jne dlg_l3e
    mov rax, qword[rbx]
    jmp dlg_l3z 
dlg_l3e:
    cmp al, 'E'
    jne dlg_l3s
    mov rax, qword[rbx+8]
    jmp dlg_l3z
dlg_l3s:
    cmp al, 'S'
    jne dlg_l3w
    mov rax, qword[rbx+16]
    jmp dlg_l3z
dlg_l3w:
    cmp al, 'W'
    jne dlg_l3q
    mov rax, qword[rbx+24]
    jmp dlg_l3z
dlg_l3q:
    cmp al, 'Q'
    jne dlg_l3h
    jmp dlg_finish
dlg_l3h:
    cmp al, 'H'
    jne dlg_l3a
    call clue
    jmp dlg_l3a
dlg_l3z:
    or rax, rax 
    jnz dlg_l30
    mov rsi, msg_stuknulis
    call print_pascal_str
    jmp dlg_l1
dlg_l30:
    mov rbx, rax   ;переход к след комнате
    jmp dlg_l1
dlg_win:
    mov rsi, msg_win
    call print_pascal_str
    xor rax, rax 

dlg_finish:
    pop rsi
    pop rdx
    pop rbx
    ret

;on entry: rbx - pointer on starting room, r13 - target id
clue:
    push rax
    mov rax, [qst_amount]
    or rax, rax 
    jnz clue_ll
    mov rsi, no_file_msg
    call jailed_string
    pop rax 
    ret
clue_ll:
    call gav 
    call question_test
    or rax, rax 
    jz clue_l0
    mov rsi, clue_msg4
    call jailed_string
    pop rax 
    ret
clue_l0:
    push rbx 
    push rcx
    push rsi
    push rdi
    push r13
    mov rdi, r13
    mov rdx, 2
    mov rcx, 4
clue_l1:
    mov rsi, clue_msg1
    xor rax, rax 
    call jailed_string
    mov rsi, [clue_msg_lst+rcx*8-8]
    call jailed_string  ;строка с #
    mov rsi, [rbx+rcx*8-8]   ;4 3 2 1 -8
    push rcx
    push rsi
    mov rsi, rooms 
    mov rcx, 40h  ;64
    call clear
    pop rsi
    pop rcx 
    call solve 
    cmp rax, 0
    jnl clue_l2  ;if rax>0
    mov rsi, clue_msg3
    inc rax
    call jailed_string
    jmp clue_l3
clue_l2:
    call print_dec  ;rax число 
    mov rsi, clue_msg2
    call jailed_string
clue_l3:
    loop clue_l1
    pop r13
    pop rdi
    pop rsi
    pop rcx
    pop rbx 
    pop rax
    ret

;проверка создания лабиринта для отладки 
dump:
    push rax
    push rcx
    push rdx
    push rsi
    mov rsi, rooms
    mov rdx, 64
d_l1:
    mov rcx, 8
d_l2:
    lodsq
    call print_uint64
    call newline
    loop d_l2
    call newline
    dec rdx
    jnz d_l1
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

;шаблон комнат с открытыми дверями
generate0:
;генерация когда все двери открыты
;идем из левого верхнего угла 
;4 указателя r8-north, r9-east, r10-south, r11-west
    xor r8, r8 ;north=0
    mov r9, rdi 
    ;rdi and r9
    add r9, 64  ; +64 r9 east 
    mov r10, [m]
    shl r10, 6 ;shift left *64
    add r10, rdi  ;south
    mov rdx, [n]
g0_l1:
    xor r11, r11 ;west=0
    mov rcx, [m]   ;x
    cmp rdx, 1
    jne g0_l2
    xor r10, r10
g0_l2:
    mov rbx, rdi
    xor rax, rax
    cmp rdx, [n]
    je g0_l2a
    mov rax, r8
g0_l2a:
    stosq  ;rax rdi, rdi+8
    xor rax, rax
    cmp rcx, 1
    je g0_l2b
    mov rax, r9
g0_l2b:
    stosq
    mov rax, r10
    stosq
    xor rax, rax
    cmp rcx, [m]
    je g0_l2c
    mov rax, r11
g0_l2c:
    stosq
    mov rax, rdx
    shl rax, 32
    or rax, rcx
    stosq
    xor rax, rax
    stosq
    stosq
    stosq
    add r9, 64
    or r10, r10
    jz g0_l3a
    add r10, 64
g0_l3a:
    or r8, r8  ;проверка на 0
    jz g0_l3b
    add r8, 64   ;0к =0 , 1к 64, 
g0_l3b:
    or r11, r11
    jnz g0_l3c
    add r11, rdi
    sub r11, 64
    jmp g0_l3d
g0_l3c:
    add r11, 64
g0_l3d:
    loop g0_l2
    mov r8, rdi
    mov rax, [m]
    shl rax, 6
    sub r8, rax
    dec rdx
    jnz g0_l1
    ret
    
print_field:
    mov rdx, [n]
pf_l1:
    push rdx
    mov rdi, buffer ;
    mov rcx, [m]
pf_l2:
    push rcx
    mov r8, 0x2B2D2D2D2D2D2D2B  ;2B + , 2D - ; +------+  ;north
    mov r12, r8  ;south
    mov r9, 0x7C2020202020207C  ;7C |, 20 _ ; |      | ;west+room+east
    mov r10, r9
    mov r11, r9
    lodsq    ;северный указатель 
    or rax, rax
    jz pf_NoWayNorth 
    mov rax, 0x7FFFFF2020FFFF7F
    and r8, rax   ;маска, 20 _ , F - оставляем любое число 
pf_NoWayNorth:
    lodsq ;rax rsi, rsi+8
    or rax, rax
    jz pf_NoWayEast
    mov rax, 0x20FFFFFFFFFFFFFF
    and r10, rax  ;east
pf_NoWayEast:
    lodsq
    or rax, rax
    jz pf_NoWaySouth
    mov rax, 0xFFFFFF2020FFFFFF
    and r12, rax    ;маска, 20 _ , F - оставляем любое число 
pf_NoWaySouth:
    lodsq ;4 шт указателей 
    or rax, rax
    jz pf_NoWayWest
    mov rax, 0xFFFFFFFFFFFFFF20
    and r10, rax  ;west
pf_NoWayWest:
    lodsq ;id
    mov rbx, rax
    shr rax, 16  ;y>>16
    and rbx, 15 
    shl rbx, 8  ;x << 8
    or rax, rbx
    add rax, 20303020h ; + _00_
    shl rax, 16 
    mov rbx, 0xFFFF00000000FFFF
    and r10, rbx   ;обнуляем биты r10 под rax (0)
    or r10, rax   ;rax в r10
    lodsq  ;reserved 
    lodsq  ;artifact 
    ;call print_uint64
    cmp al, 9   ;0-15 ; 48, 57 - digits, 65 - A
    jna pf_lart
    add al, 7
pf_lart:
    shl rax, 8   ;al на 1 байт влево 
    add rax, 20203020h  ;20 - _ ; 30 - 0
    shl rax, 16 
    mov rbx, 0xFFFF00000000FFFF
    and r9, rbx   ;обнуляем биты r9 под rax (0)
    or r9, rax   ;rax в r9
    lodsq  ;add rsi, 24
    add al, 23h   ;space _
    cmp al, 23h   ;#
    je pf_lx
    add al, 06h 
pf_lx:
    shl rax, 28h ;40
    or r10, rax
    mov qword[rdi], r8
    mov qword[rdi+65], r9
    mov qword[rdi+130], r10
    mov qword[rdi+195], r11
    mov qword[rdi+260], r12
    add rdi, 8
    pop rcx
    dec rcx
    jz pf_l3
    jmp pf_l2  ;конец обработки 1 строки
pf_l3:
    mov al, 0xA   ;enter
    mov byte[rdi+65], al
    mov byte[rdi+130], al
    mov byte[rdi+195], al
    mov byte[rdi+260], al
    stosb     ;al-> [rdi], rdi++  +1байт вправо
    push rsi
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, 325
    syscall
    pop rsi
    pop rdx
    dec rdx  ;n--
    jz pf_l4
    jmp pf_l1
pf_l4:
    ret

;*
;on exit: rax - кол-во шагов, <0 - непроходимый лабиринт, >0 - лабиринт проходим  
solve:
    push rbx   ;минимальная длина 
    push rcx 
    xor rcx, rcx 
    xor rbx, rbx 
    dec rbx   ;f = false (infinite distance) 
    or rsi, rsi
    jz slv_no_way
    call solve_aux 
slv_no_way:
    mov rax, rbx 
    pop rcx 
    pop rbx
    ret  

;on entry: rsi (текущая комната указатель), rdx - color (степень 2), rdi - целевая комната (id), rcx (номер шага), rbx - минимальное количество шагов
solve_aux:
    ;mov rax, rcx 
    ;call print_uint64
   ; call newline
    ;mov rax, rsi
    ;call print_uint64
    ;call newline
  ;  mov rax, rdi
    ;call print_uint64
    ;call newline
    push rsi
    cmp [rsi+32], rdi   ;адрес комнаты +32 = место id  
    jne slv_l1
    cmp rcx, rbx 
    jnb slv_l0 
    mov rbx, rcx 
slv_l0:
    mov rax, rbx
    jmp slv_l2
slv_l1:
    or qword[rsi+56], rdx  ;текущая комната помечаем цветом (посещенная)
slv_n:
    lodsq  ;повернулись к north 
    call try_enter ;если дверь есть и открывается, то заходим 
    jnz slv_e
    cmp rax, rbx 
    jnb slv_e
    mov rbx, rax  ;если найден более короткий путь 
slv_e:
    lodsq
    call try_enter
    jnz slv_s
    cmp rax, rbx 
    jnb slv_s
    mov rbx, rax
slv_s:
    lodsq 
    call try_enter
    jnz slv_w
    cmp rax, rbx 
    jnb slv_w
    mov rbx, rax
slv_w:
    lodsq 
    call try_enter
    jnz slv_l2
    cmp rax, rbx 
    jnb slv_l2
    mov rbx, rax
slv_l2:
    mov rax, rbx 
    pop rsi 
    ret

;попытка зайти в комнату 
;on entry: rax - комната, куда хотим войти, rdx - color 
;попытка зайти в комнату 
;returns:
;rax - distance from this room to target, ZF=1 if way found (or -1 if no way / door closed / color-marked, ZF=0 in this case)
try_enter: 
    or rax, rax
    jnz te_l1
    dec rax
    ret
te_l1:
    push rsi
    mov rsi, rax
    test qword[rsi+56], rdx   ;окрашена ли комната в цвет. Если цвет есть, то не заходим 
    jz te_l1a
    xor rax, rax
    dec rax
    jmp te_l2
te_l1a:
    push rcx 
    inc rcx 
    call solve_aux
    pop rcx 
    cmp rax, rax  ;zero flag 
te_l2:
    pop rsi
    ret

;красим текущую rdx=2, solve, расстояние из сосед комнаты 
;стереть цвет 
;on entry: rsi - указатель на начала массива комнат, rdx - color который стереть, rcx - кол-во комнат, 
clear:
    push rsi 
    push rcx
    push rdx 
    not rdx  ;инверсия  
    add rsi, 56
cl_l1:
    and qword[rsi], rdx
    add rsi, 64 
    loop cl_l1   ;rcx - счетчик 
    pop rdx
    pop rcx
    pop rsi 
    ret

;подсчет закрытых дверей 
check_three:
    push rax
    push rcx
    push rdx
    push rsi
    xor rdx, rdx
    mov rcx, 4
ct_l0:
    lodsq
    or rax, rax
    jnz ct_l1
    inc rdx
ct_l1:
    loop ct_l0
    cmp rdx, 1  
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

;рандомное закрытие дверей 
;on entry: rsi - указатель описания комнат 
lock_doors:
    push rax
    push rcx
    push rdx
    push rbx
    push rsi
    push rdi
    xor rbx, rbx  ;rbx=0
    mov rdx, [n]
ld_l1:
    push rdx 
    mov rcx, [m]
ld_l2:
    push rcx
    call rand 
    cmp al, 14
    jb ld_l2a 
    call rand 
    and rax, 0Fh   ;младшие 4 бита для ограничения 0-15 
    mov [rsi+48], rax
ld_l2a:
    call check_three
    jb ld_north
    add rsi, 64
    jmp ld_l3a
ld_north:
    mov rdi, [rsi]
    or rdi, rdi
    jz ld_east
    push rsi
    mov rsi, rdi
    call check_three
    pop rsi
    jb ld_east
 
    call rand 
    cmp al, 8 
    jb ld_east   ;below
    
    xor rbx, rbx
    mov [rdi+16], rbx
    mov [rsi], rbx

ld_east:
    add rsi, 8
    mov rdi, [rsi]
    
    or rdi, rdi
    jz ld_south

    push rsi
    mov rsi, rdi
    call check_three
    pop rsi
    ja ld_south  ;jump above

    call rand
    cmp al, 8
    jb ld_south

    xor rbx, rbx
    mov [rdi+24], rbx
    mov [rsi], rbx
    
ld_south:
    add rsi, 8
    mov rdi, [rsi]

    or rdi, rdi
    jz ld_west
    
    push rsi
    mov rsi, rdi
    call check_three
    pop rsi
    ja ld_west

    call rand
    cmp al, 8
    jb ld_west
    
    xor rbx, rbx
    mov [rdi], rbx
    mov [rsi], rbx

ld_west:
    add rsi, 8
    mov rdi, [rsi]

    or rdi, rdi
    jz ld_north_again
    
    push rsi
    mov rsi, rdi
    call check_three
    pop rsi
    ja ld_north_again

    call rand
    cmp al, 8
    jb ld_north_again

    xor rbx, rbx
    mov [rdi+8], rbx
    mov [rsi], rbx

ld_north_again:
    add rsi, 8+32

ld_l3a:
    pop rcx

    dec rcx
    jz ld_l3
    jmp ld_l2
ld_l3:
    pop rdx
    dec rdx
    jz ld_l4
    jmp ld_l1
ld_l4:
    pop rdi
    pop rsi
    pop rbx
    pop rdx
    pop rcx
    pop rax
    ret