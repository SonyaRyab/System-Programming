format ELF64

include 'func.asm'

 public _start

 extrn initscr
 extrn init_pair
 extrn getmaxx
 extrn getmaxy
 extrn move
 extrn getch
 extrn clear
 extrn refresh
 extrn endwin
; extrn exit
 extrn color_pair
 extrn usleep
 extrn stdscr
 extrn halfdelay
 extrn noecho
  
 section '.bss' writable
 xmax rq 1
 ymax rq 1
 x rq 1
 y rq 1
 yy rq 1
 
 buf rb 100
 
 section '.data' writable
 d dq 100000
 a dq 10.0
 w dq 0.1
 factor dq 2.0
 section '.text' executable
 
_start:
 ;; Инициализация
 call initscr
 mov rdi, 1
 call halfdelay
 call noecho

 ;; Размеры экрана
 xor rdi, rdi
 mov rdi, [stdscr]
 call getmaxx
 mov [xmax], rax
 call getmaxy
 mov [ymax], rax
 sar rax, 1
 mov [y], rax
 dec rax
 mov [a], rax
 fild [a]
 fstp [a];   [a] = (double)[a]

 ;; Синий цвет
 mov rdx, 0x4
 mov rsi,0x0
 mov rdi, 0x1
 call init_pair

 ;; Черный цвет
 mov rdx, 0x0
 mov rsi,0xf
 mov rdi, 0x2
 call init_pair

_l_loop:
 mov rdi, [y]
 mov rsi, [x]
 inc rsi
 cmp rsi, [xmax]
 jb _l1
 xor rsi, rsi
 _l1:
 mov [x], rsi
 
 fild [y]
 fild [x]
 fld [w]
 fmulp
 fsin
 fld [a]
 fmulp
 fsubp
 fistp [yy] 
 mov rdi, [yy]
  
 call move
 call refresh
 mov rdi, [d]
 call usleep
 
 xor rax, rax
 call getch
 
 ; омега
 cmp al, 'a'
 jne _l2
 fld [w]
 fld [factor]
 fmulp
 jmp _l3
_l2:
 cmp al, 'z'
 jne _l4
 fld [w]
 fld [factor]
 fdivp
_l3:
 fstp [w]

_l4:; разгон-торможение
 cmp al, 's'
 jne _l5
 cmp qword[d], 1000000
 ja _l7
 shl qword[d], 1
 jmp _l7
_l5:
 cmp al, 'd'
 jne _l6
 cmp qword[d], 1
 jna _l7
 shr qword [d], 1
 jmp _l7
_l6:
 cmp al,'q'
 je _exit
 _l7:
 jmp _l_loop
 
 _exit:
 call exit