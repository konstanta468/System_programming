format ELF64

public _start

section ".data" writeable
    n = 136
    buffer db n dup ("&")
    newline db 10


section ".text" executable

_start:
    mov R8, 1
    mov R9, n
    _loop:
        mov rax, 1
        mov rdi, 1
        mov rsi, buffer
        mov rdx, R8
        syscall

        call end_line

        sub R9, R8

        inc R8
        cmp R8, R9
        jle _loop

    cmp R9,0
    je exit
    
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, R9
    syscall

    call end_line
    jmp exit

end_line:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret

exit:
    mov rax, 60
    xor rdi,rdi
    syscall