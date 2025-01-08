format ELF64

public _start
include 'func.asm'

section '.data' writeable
    e dq 1e-3
    x dq 0.75
    m dq 1       ;m = 2*n+1
    s dq 0 ;summ
    z dq 0 ;эталон суммы
    d dq 0 ;|s-z|, d<e -> answer
    t dq 0 ;доп переменная
    t10000 dq 10000
    r dq 0


section '.bss' writable
    buff rb 32

section '.text' executable

_start:
    mov qword[t], 8
    fldpi   ;Pi -> st(0) ; st - stack
    fldpi   ;st(0) -> st(1) ; Pi -> st(0)
    fmulp   ;st(0)*st(1) -> st(1) ; st(0) -> trash ; st(1) -> st(0)
    fild [t]    ;st(0) -> st(1) ; (double)t -> st(0)
    fdivp       ;st(1)/st(0) -> st(1) ; st(0) -> trash ; st(1) -> st(0)

    mov qword[t], 4
    fldpi
    fild [t]
    fdivp
    faddp   ;st(0)+st(1) -> st(1) ; st(0) -> trash ; st(1) -> st(0)
    fstp [z]    ;st(0) -> [z], st() пустой

;summ
xor rdx, rdx
l_loop: 
    inc rdx
    fild [m]
    fld [x]
    fmulp    ;x*m
    fcos    ;cos(st(0)) -> st(1)
    fild [m]
    fild [m]        
    fmulp   ;n^2
    fdivp  ;st(1) / m^2 
    fld [s]
    faddp 
    fstp [s]  ;st(0) -> [s]
    fld [z]
    fld [s]
    fsubp
    fabs    ;st(0) -> abs(st(0))
    fld [e]
    fcompp    ;compare st(0) and st(1)
    fstsw ax     ;flag87 -> AX
    sahf     ;AH -> flag
    ja l_finish     ;jump if above, with no sign, st(0)=e > st(1)=d
    add qword[m], 2     ;m+2= 3, 5, 7, ...
    cmp rdx, 1000000000
    ja l_finish
    jmp l_loop 

l_finish:
    mov rax, rdx
    mov rsi, buff
    call number_str
    call print_str
    call new_line
    fld [s]
    fild [t10000]
    fmulp 
    fabs 
    fistp [r]

    mov rax, [r]
    mov rsi, buff
    call number_str
    call print_str
    call new_line
    call exit 