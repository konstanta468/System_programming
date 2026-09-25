format ELF64

public _start

section ".data" writeable
    n = 136
    buffer db n dup ("&")
    newline db 10
    m = 8
    k = 17

section ".text" executable

loop_K:
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, m
    syscall

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    inc R8
    cmp R8, k
    jl loop_K

    mov rax, 60
    xor rdi, rdi
    syscall

_start:
    mov R8, 0
    jmp loop_K
    

