format ELF64

public _start

include '../MyLibrary.asm'

section '.text' executable

_start:
    mov rsi, buffer
    call input_keyboard

    xor rax, rax
    mov al, '0'
    .loop:
        cmp byte [rsi], '0'
        jl .true
        cmp al, byte [rsi]
        jg .false

        mov al, [rsi]
        inc rsi

        jmp .loop

    .false:
        mov rax, 0
        call print_int
        call exit
    .true:
        mov rax, 1
        call print_int
        call exit