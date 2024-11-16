format ELF64
public _start

_start:
    mov rax, [rsp + 16]  ;первый аргумент
    mov bl, byte [rax]   
    call print
    call exit

place db ?
  
print:
    movzx rax, bl
    mov rcx, 10
    xor rbx, rbx
    iter1:
      xor rdx, rdx
      div rcx
      add rdx, '0'
      push rdx
      inc rbx
      cmp rax, 0
    jne iter1
    iter2:
      pop rax
      call print_symb
      dec rbx
      cmp rbx, 0
    jne iter2
 mov rax, 0xA
 call print_symb
 call exit

print_symb:
     push rbx
     push rdx
     push rcx
     push rax
     push rax
     mov rax, 4
     mov rbx, 1
     pop rdx
     mov [place], dl
     mov rcx, place
     mov rdx, 1
     int 0x80
     pop rax
     pop rcx
     pop rdx
     pop rbx
     ret

exit:
    mov rax,1
    mov rbx,0
    int 0x80
