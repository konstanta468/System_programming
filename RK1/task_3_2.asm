format ELF64

public _start

include '../MyLibrary.asm'

section ".text" executable
_start:
    pop rax
    cmp rax, 3
    jl exit

    pop rax
    pop r9 ; имя каталога name
    pop rax
    call ATOI
    mov r8, rcx ; n

    mov rax, 80 ; chdir
    mov rdi, r9
    syscall
    cmp rax, 0
    jl exit

    .loop:
        cmp r8, 0
        jle exit

        mov rax, 83 ; mkdir
        mov rdi, r9
        mov rsi, 755o
        syscall

        mov rax, 80 ; chdir
        mov rdi, r9
        syscall

        dec r8
        jmp .loop
