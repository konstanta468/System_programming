format ELF64

public _start

section ".data" writeable
    n = 4693338485
    buffer db 16

section ".text" executable

_start:
    mov R8, 0
    mov rax, n
    mov rdi, 10

    @@:
        xor rdx,rdx
        div rdi
        add R8, rdx

        cmp rax, 0
        jg @b

    mov rax, R8
    call print_int

    mov rax, 60
    xor rdi, rdi
    syscall

print_int:
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
    ret