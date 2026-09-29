format ELF64

public _start

section ".data" writeable
    buffer db 16

section ".text" executable
_start:
    pop rax

    cmp rax, 2
    jl exit

    pop rdi
    pop rdi
    xor rax, rax
    mov al, byte [rdi]
    call print_int
    jmp exit
    
exit:
    mov rax,60
    xor rdi, rdi
    syscall

print_int:
    push rsi
    push rdi
    push rdx
    push rbx
    mov rsi, 0
    mov rdi, 10

    @@:
        xor rdx, rdx
        div rdi
        add rdx, '0'
        mov [buffer + rsi], dl
        inc rsi

        cmp rax, 0
        jg @b

    mov [buffer + rsi], 10

    mov rdi, buffer
    add rdi, rsi
    dec rdi
    mov rsi, buffer
    
    @@:
    cmp rsi, rdi
    jge @f

    mov al, [rsi]
    mov bl, [rdi]
    mov [rsi], bl
    mov [rdi], al

    inc rsi
    dec rdi
    jmp @b
    @@:

    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    syscall

    pop rbx
    pop rdx
    pop rdi
    pop rsi
    ret