
section ".data" writeable
    urandom_path db "/dev/urandom", 0

section ".bss" writeable
    buffer rb 255

section ".text" executable

;input rax - intager
print_int:
    push r10
    push rsi
    push rdi
    push rdx
    call ITOA

    mov rsi, rax
    mov rax, 1
    mov rdi, 1
    syscall
    
    pop rdx
    pop rdi
    pop rsi
    pop r10
    ret

;The function realizates user input from the keyboard
;input: rsi - place of memory saved input string 
input_keyboard:
  push rax
  push rdi
  push rdx

  mov rax, 0
  mov rdi, 0
  mov rdx, 255
  syscall

  xor rcx, rcx
  .loop:
     mov al, [rsi+rcx]
     inc rcx
     cmp rax, 0x0A
     jne .loop
  dec rcx
  mov byte [rsi+rcx], 0
  
  pop rdx
  pop rdi
  pop rax
  ret


exit:
    mov rax,60
    xor rdi, rdi
    syscall

;input: rax - pointer to the string
;output: rcx - integer
ATOI:
    push rsi ; pointer to end of string
    push rdx ; pointer to the string
    push rbx
    push R9
    push R8 ; хранит в себе не полный результат приобразования
    
    mov rsi, rax ; rsi должен указывать на конец строки
    mov rbx, rax
    xor R8, R8
    mov R9, 10 ; основание СС

    mov rax, 1 ; здесь хранятся степени 10

    @@: ; двигаем rsi до тех пор пока не встретим символ конца строки
        cmp byte [rsi], 0 
        je @f
        inc rsi
        jmp @b
    @@:

    dec rsi
    @@:
    xor rcx, rcx
        mov cl, [rsi] ; Получаем ASCII код цифры
        sub rcx, '0' ; из ASCII получаем само значение цифры
        push rax 
        mul rcx ; умножаем степень 10 на цифру

        add R8, rax; складываем результат умножения с предварительным результатом
        pop rax
        mul R9 ; увеличиваем степень 10

        cmp rsi,rbx ; проверяем не закончилось ли число
        je @f
        dec rsi
        jmp @b
    @@:

    mov rcx,R8

    pop R8
    pop R9
    pop rbx
    pop rdx
    pop rsi
    ret

; input rax - integer
; otput:
; rax - buffer
; rdx - len of buffer
ITOA:
    push rsi
    push rdi
    push rbx

    
    xor rsi, rsi
    cmp rax, 0
    jge @f
    neg rax
    mov byte [buffer], '-'
    inc rsi
    @@:

    push rsi
    mov r10, 10

    @@:
        xor rdx, rdx
        div r10
        add rdx, '0'
        mov [buffer + rsi], dl
        inc rsi

        cmp rax, 0
        jg @b

    mov [buffer + rsi], 10
    mov rdi, rsi
    mov rdx, rsi
    inc rdx
    dec rdi

    pop rsi
    add rsi, buffer
    add rdi, buffer
    call reverse_str
    
    mov rax, buffer
    pop rbx
    pop rdi
    pop rsi
    ret 

; input:
; rsi - start
; rdi - end
reverse_str:
    push rax
    xor rax, rax

    @@:
    
        cmp rsi, rdi
        jge @f

        mov al, [rsi]
        mov ah, [rdi]
        mov [rsi], ah
        mov [rdi], al

        inc rsi
        dec rdi
        jmp @b
        @@:
    pop rax
    ret

;The function generates a random 64-bit number 
;output: rax - random number (0 if could not be read)
random:
    push rdi
    push rsi
    push rdx
    push rcx
    push r11
    push r8
    push 0 

    mov rax, 2 ; open
    mov rdi, urandom_path
    xor rsi, rsi 
    syscall
    cmp rax, 0
    jl @f
    mov r8, rax 

    mov rax, 0 
    mov rdi, r8
    mov rsi, rsp
    mov rdx, 8
    syscall

    mov rax, 3 
    mov rdi, r8
    syscall
    @@:

    pop rax
    pop r8
    pop r11
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    ret