format ELF64

public _start            

section '.data' writeable
    msg db 'dKGuxAlwQQtuoxTSEQhjxGKc', 10
    msg_len = $ - msg

section '.text' executable
_start:
    mov rsi, msg
    mov rdi, msg + msg_len - 2

reverse_loop:
    cmp rsi, rdi
    jge print_result

    mov al, [rsi]
    mov bl, [rdi]
    mov [rsi], bl
    mov [rdi], al

    inc rsi
    dec rdi
    jmp reverse_loop

print_result:
    mov rax, 1        
    mov rdi, 1          
    mov rsi, msg
    mov rdx, msg_len
    syscall

    mov rax, 60        
    xor rdi, rdi
    syscall