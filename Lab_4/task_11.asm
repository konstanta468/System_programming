format ELF64

public _start

include '../MyLibrary.asm'

section '.bss' writeable
    n db 0

section '.text' executable

_start:
    mov rsi, buffer
    call input_keyboard

    mov rax, rsi
    call ATOI

    mov [n], cl
    xor r9, r9
    xor r8, r8

    .loop:
        call input_keyboard
        mov rax, rsi
        call ATOI

        cmp rcx, 0
        jg .true
            dec r8
            jmp .end_if

        .true:
            inc r8
        .end_if:

        inc r9b
        cmp r9b, [n]
        jl .loop
    
    cmp r8, 0
    jge .yes

    mov rax, 0
    call print_int
    call exit

    .yes:
        mov rax, 1
        call print_int
        call exit