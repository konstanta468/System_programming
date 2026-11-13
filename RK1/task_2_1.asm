format ELF64

public _start

include '../MyLibrary.asm'

section ".data" writeable
    error_msg db "Error: the number is even", 0xA

section ".text" executable
_start:
    pop rax
    cmp rax, 2
    jl exit

    pop rax
    pop rax
    call ATOI ; rcx = 2n+1

    ; делим на 2: rax = n, rdx = остаток
    mov rax, rcx
    xor rdx, rdx
    mov r9, 2
    div r9

    cmp rdx, 0
    je .error

    ; 1+3+5+...+(2n+1) = (n+1)^2
    inc rax
    mul rax
    call print_int
    call exit

    .error:
        mov rax, 1
        mov rdi, 1
        mov rsi, error_msg
        mov rdx, 26
        syscall
        call exit
