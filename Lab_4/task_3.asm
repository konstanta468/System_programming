format ELF64

public _start

include '../MyLibrary.asm'

section '.data' writeable
    result dq 0
    n db 0
    buf db 16

section '.text' executable

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, buf
    mov rdx, 16
    syscall

    mov byte [buf + rax - 1], 0

    mov rax, buf
    call ATOI
    mov [n], cl

    xor rcx, rcx
    mov cl, 1
    mov r8, 0
    .loop:
        xor rax, rax
        mov al, cl
        call calculate_addend

        ;знак при сложении
        cmp r8, 0 ; каждый чётный шаг цикла добавляем, каждый нечётный - вычитаем
        jg @f
        mov r8, 2
        neg rax
        @@:
        dec r8

        add [result], rax
        inc cl
        cmp cl, [n]
        jle .loop
    mov rax, [result]
    call print_int
    call exit

;input rax - k
;output rax - result
calculate_addend:
    push rdx
    push rsi

    mov rsi, rax
    inc rsi ;k+1

    mul rsi ;k*(k+1)
    dec rsi 
    push rax

    ;(3k+1)
    mov rax, rsi
    mov rsi, 3
    mul rsi
    inc rax
    mov rsi, rax

    ;(3k+2)
    inc rax

    mul rsi
    pop rsi
    mul rsi

    pop rsi
    pop rdx

    ret
    

