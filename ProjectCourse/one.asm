format ELF64
public _start

section '.data' writable
    ;start_room dq 8 dup(0) 
    n dq 8 ;length
    m dq 8 ;width
    cr dq 0A0Dh
    gav_str dq 0A30564147h 
    rnd dq 0A30564147h

section '.bss' writable
    buffer rb 2600   ;строка-изображение  
    rooms rq 2048
    tmp rq 1
    tmp2 rq 128
    pu64_buf rb 16

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
    call gav
    mov rax, m
    call print_uint64
    call newline
    mov rdi, rooms
    call generate0
    call dump
    mov byte[gav_str+3], 31h
    call gav
    mov rax, [m]
    call print_uint64
    call newline
    mov rsi, rooms
    call lock_doors
    call print_field
    mov byte[gav_str+3], 32h
    call gav
    call test_rand
    xor rdi, rdi
    mov rax, 60
    syscall
    ;mov rbx, [start_room]
    ;mov rbx, [rbx+40]  ;room on the right

;random numbers - метод Фон Неймана, меод срединного квадрата
rand:
    push rcx  ;counter
    push rdx  ;используется при умножении
    mov rax, [rnd]
    mul rax  ;квадрат rax 
    xor rax, rdx  
    mov [rnd], rax
    sub rcx, rcx  ;rcx=0
rand_l1:
    or rax, rax   ;проверка на 0
    jz rand_l2
    mov dl, al ; dl - младшие 4 бита из rax, al - 8 младших бит rax
    and dl, 0xF ;1111 - младшие 4 бита 
    mov byte[rcx+tmp2], dl
    shr rax, 4
    inc rcx
    jmp rand_l1
rand_l2:
    shr rcx, 1  ;rcx/2
    mov al, byte[rcx+tmp2] 
    pop rdx
    pop rcx
    ret

test_rand:
    mov rcx, 100
tr_l1:
    push rcx
    call rand
    cmp al, 9  ;без символов . , 
    jna tr_l2  ;без знака
    add al, 7
tr_l2:
    add al, 30h
    mov ah, 0xA  ;enter в столбик
    mov word[tmp], ax
    mov rax, 1
    mov rdi, 1
    mov rdx, 2
    mov rsi, tmp
    syscall
    pop rcx
    loop tr_l1
    ret

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

newline:
    push rax
    push rcx
    push rdx
    push rsi
    push rdi
    mov rax, 1
    mov rdi, rax
    mov rdx, 2
    mov rsi, cr
    syscall
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    ret

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
    lodsq 
    lodsq
    lodsq   ;add rsi, 24
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
    mov byte[gav_str+3], '!'
    call newline
    call gav
    call newline
    mov rax, rcx
    call print_uint64
    call newline

ld_l2:
    push rcx
ld_north:
    call rand 
    cmp al, 8 
    jb ld_east   ;below
    mov rdi, [rsi]
    or rdi, rdi
    jz ld_east
    
    mov [gav_str+3], 'N'
    call gav 
    mov rax, rdi
    call print_uint64
    call newline

    xor rbx, rbx
    mov [rdi+16], rbx
    mov [rsi], rbx

    mov [gav_str+3], 'n'
    call gav
ld_east:
    add rsi, 8
    call rand
    cmp al, 8
    jb ld_south
    mov rdi, [rsi]
    or rdi, rdi
    jz ld_south

    mov [gav_str+3], 'E'
    call gav
    mov rax, rdi
    call print_uint64
    call newline

    xor rbx, rbx
    mov [rdi+24], rbx
    mov [rsi], rbx
    
    mov [gav_str+3], 'e'
    call gav
ld_south:
    add rsi, 8
    call rand
    cmp al, 8
    jb ld_west
    mov rdi, [rsi]
    or rdi, rdi
    jz ld_west
    
    mov [gav_str+3], 'S'
    call gav
    mov rax, rdi
    call print_uint64
    call newline

    xor rbx, rbx
    mov [rdi], rbx
    mov [rsi], rbx

    mov [gav_str+3], 's'
    call gav
ld_west:
    add rsi, 8
    call rand
    cmp al, 8
    jb ld_north_again
    mov rdi, [rsi]
    or rdi, rdi
    jz ld_north_again

    mov [gav_str+3], 'W'
    call gav
    mov rax, rdi
    call print_uint64
    call newline

    xor rbx, rbx
    mov [rdi+8], rbx
    mov [rsi], rbx

    mov [gav_str+3], 'w'
    call gav
ld_north_again:
    add rsi, 32
    pop rcx
    call newline
    mov rax, rcx
    call print_uint64
    call newline
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


;On entry: rax

print_uint64:
    push rdx
    push rax
    push rcx
    push rdi
    push rsi
    mov rdx, rax
    mov rdi, pu64_buf
    mov rcx, 16
pu64_l0:
    rol rdx, 4
    mov rax, rdx
    and al, 0xF
    cmp al, 9
    jna pu64_l1
    add al, 7
pu64_l1:
    add al, 30h   ;0
    stosb 
    loop pu64_l0
    mov rax, 1
    mov rdi, 1
    mov rsi, pu64_buf
    mov rdx, 16
    syscall
    pop rsi
    pop rdi
    pop rcx
    pop rax
    pop rdx
    ret
    
