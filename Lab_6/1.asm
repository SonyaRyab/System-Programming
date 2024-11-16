;Алгоритм:  [4]
;Цвета заполнения:  ['COLOR_BLACK', 'COLOR_BLUE']
;Кнопки выхода, изменения скорости:  ['b', 'w']

format ELF64
	public _start
	extrn initscr
	extrn printw
	extrn refresh
	extrn getch
	extrn endwin
	extrn exit
	extrn stdscr
	extrn getmaxx
	extrn getmaxy
	extrn move
	extrn keypad
	extrn mydelay
	extrn get_random
	extrn init_pair
	extrn addch
	extrn insch
	extrn start_color
	extrn noecho
	extrn cbreak
	extrn timeout
	extrn addchnstr   ;вывод строки



	section '.bss' writable

	section '.data' writable
	current_x dq 0
	current_y dq 0
	current_delay dq 100
	maxx dq 0
	maxy dq 0
	current_dx dq 1   ;смещение влево/вправо 1/-1
	current_t dq 0   ;число шагов |max_x|
	chr dq 120h     ;40h - @ , 1- blue colour

	section '.text' executable

_start:
	;; Инициализация
	call initscr

	call start_color
	;; Синий цвет
	mov rdx, 0x4 ;фон
	mov rsi,0x4 ;символ (курсор)
	mov rdi, 0x1
	call init_pair   

	;; Черный цвет
	mov rdx, 0x0
	mov rsi,0x0
	mov rdi, 0x2
	call init_pair

	call refresh
	call noecho
	call cbreak

	
    
;; Размеры экрана
	mov rdi, [stdscr]
	call getmaxx
	;dec rax
	mov [maxx], rax ;размер окна по х
	call getmaxy
	mov [maxy], rax
	mov rdi, 50
	call timeout
	
mloop:
	mov rsi, [current_x]
	mov rdi, [current_y]
	call move
	mov rdi, chr      ;chr - символ+атрибут; 
	mov rsi, 1
	call addchnstr  ;строка, а не символ, чтобы не было доп смещения курсора         
	mov rax, [current_x]
	mov rcx, [current_dx]
	add rax, rcx  ;current_x + current_dx
	mov [current_x], rax
	mov rax, [current_t]  ;значение номер шага
	inc rax
	mov [current_t], rax
	cmp rax, [maxx]  

	jb l_1          ;если меньше без учета знака
	xor rax,rax
	mov [current_t], rax
	neg [current_dx]
	mov rax, [current_x]
	mov rcx, [current_dx]
	add rax, rcx   ;c_x-c_dx ; смещаем влево/вправо
	mov [current_x], rax

	mov rdx, [current_y]
	inc rdx
	cmp rdx, [maxy]
	jb l_2            
	;если rdx = maxy
	xor [chr], 0x300   ;символ, атрибут, замена цветов 1 2
	mov [current_dx], 1    ;curr_dx+1
	xor rdx, rdx
	mov [current_x], rdx   ;curr_x=0
		
	l_2:
	mov [current_y], rdx
	
	l_1:
	call getch    ;если вводится b, w
	cmp al,'b'   ;al младший байт rax, возвращает rax
	je l_quit
	cmp al, 'w'
	jne l_refresh
	mov rax, 400h   ;значение задержки
	xor [current_delay], rax     ;rax = 1024
	mov rdi,[current_delay]
	call timeout     ;getch

l_refresh:
	call refresh    ;обновление изображения
	jmp mloop

l_quit:
	call exit