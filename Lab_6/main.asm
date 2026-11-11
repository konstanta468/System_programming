format ELF64

public _start

extrn initscr
extrn refresh
extrn getch
extrn endwin
extrn exit
extrn stdscr
extrn getmaxx
extrn getmaxy
extrn move
extrn addch
extrn napms
extrn start_color
extrn init_pair
extrn attron
extrn nodelay
extrn noecho

section '.bss' writeable
    width dd ?
    height dd ?
    x dd ?
    y dd ?
    direction dd ?

section '.data' writeable
    firstloop db 0
    delay dd 5

section '.text' executable

_start:
    call initscr
    call start_color

    mov rdi, [stdscr]
    mov esi, 1
    call nodelay
    call noecho

    mov edi, 1       
    mov esi, 0    
    mov edx, 1    
    call init_pair

    mov edi, 2    
    mov esi, 0    
    mov edx, 2  
    call init_pair

    mov rdi, [stdscr]
    call getmaxx
    mov [width], eax
    mov rdi, [stdscr]
    call getmaxy
    mov [height], eax

    ; Начинаем в правом верхнем углу и движемся влево.
    mov eax, [width]
    dec eax
    mov [x], eax
    mov dword [y], 0
    mov dword [direction], -1

    mov edi, 1 shl 8 ;  цветовая пара №1
    call attron

.draw:
    call getch
    cmp eax, 'r'
    je .exit
    cmp eax, 'h'
    jne @f
    add dword [delay], 5
    @@:

    mov edi, [y]
    mov esi, [x]
    call move
    mov edi, ' '
    call addch

    ; Возвращаем курсор на текущую клетку после вывода символа.
    mov edi, [y]
    mov esi, [x]
    call move
    call refresh
    mov edi, [delay] ; пауза в миллисекундах
    call napms

    mov eax, [x]
    add eax, [direction]
    cmp eax, 0
    jl .next_row
    cmp eax, [width]
    jge .next_row
    mov [x], eax
    jmp .draw

.next_row:
    ; На краю спускаемся вниз и меняем направление.
    inc dword [y]
    mov eax, [y]
    cmp eax, [height]
    jge .done
    neg dword [direction]
    jmp .draw

.done:
    cmp byte [firstloop], 0
    jg .exit

    mov byte[firstloop], 1
    mov edi, 2 shl 8 ;  цветовая пара №1
    call attron
    mov eax, [width]
    dec eax
    mov [x], eax
    mov dword [y], 0
    mov dword [direction], -1
    jmp .draw

    .exit:
    call getch
    call endwin
    xor edi, edi
    call exit
