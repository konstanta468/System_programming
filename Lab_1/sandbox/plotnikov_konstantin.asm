format ELF
public _start

name db "Konstantin", 0xA, 0
surname db "Plotnikov", 0xA, 0
patronymic db "Vladimirovich", 0xA, 0
newline db 0xA

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, surname
    mov edx, 10
    int 0x80

    mov esi, name
    .loop:
    cmp byte [esi], 0xA
    je .end

    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80


    inc esi

    jmp .loop
    .end:

    mov eax, 4
    mov ebx, 1
    mov ecx, patronymic
    mov edx, 14
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80