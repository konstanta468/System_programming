
format elf64
public _start

include '../MyLibrary.asm'

section '.bss' writable

  buf rb 100  ;текущий кусок входного файла
  cbuf rb 100 ;буфер для функций копирования

section '.text' executable

_start:
   pop rcx
   cmp rcx, 3
   jl .l1

   ;открываем входной файл на чтение
   mov rdi,[rsp+8]
   mov rax, 2
   mov rsi, 0o
   syscall
   cmp rax, 0
   jl .l1
   mov r8, rax

   mov rdi,[rsp+16]
   mov rax, 2
   mov rsi, 577
   mov rdx, 777o
   syscall
   cmp rax, 0
   jl .l1
   mov r9, rax

   xor r12, r12 ;начало предложения
   mov r13, -1  ;первой буквы ещё не было
   xor r14, r14 ;за последней буквой
   xor r15, r15 ;смещение текущего куска

   .read_chunk:
     ;lseek(r8, r15, SEEK_SET) и читаем до 100 байт
     mov rax, 8
     mov rdi, r8
     mov rsi, r15
     mov rdx, 0
     syscall
     mov rax, 0
     mov rdi, r8
     mov rsi, buf
     mov rdx, 100
     syscall
     cmp rax, 0
     jle .eof
     mov r10, rax ;длина куска

     xor rbx, rbx
     .scan:
       cmp rbx, r10
       jge .chunk_done

       mov al, [buf + rbx]
       cmp al, '.'
       je .term
       cmp al, '!'
       je .term
       cmp al, '?'
       je .termz
       cmp al, ' '
       jle .next ;пробельный символ

       ;буква: rcx - её смещение в файле
       mov rcx, r15
       add rcx, rbx
       cmp r13, 0
       jge @f
       mov r13, rcx
       @@:
       inc rcx
       mov r14, rcx
       jmp .next

       .term:
         ;конец предложения - сразу за знаком
         mov rcx, r15
         add rcx, rbx
         inc rcx
         call write_sentence

       .next:
         inc rbx
         jmp .scan

     .chunk_done:
       add r15, r10
       jmp .read_chunk

   ;конец файла: записываем остаток, r15 - размер файла
   .eof:
     mov rcx, r15
     call write_sentence

   mov rdi, r8
   mov rax, 3
   syscall

   mov rdi, r9
   mov rax, 3
   syscall

.l1:
   call exit

;Записывает предложение в выходной файл и начинает новое
;input: r12 - начало, r13 - первая буква (-1 если нет), r14 - за последней буквой,
;       rcx - конец предложения (не включая)
;output: r12 = rcx, r13 = -1
write_sentence:
  push rbx
  mov rbx, rcx

  cmp r13, 0
  jge @f
  ;букв нет - копируем как есть
  mov rsi, r12
  mov rdi, rbx
  call copy_forward
  jmp .done

  @@:
  mov rsi, r12
  mov rdi, r13
  call copy_forward
  mov rsi, r13
  mov rdi, r14
  call copy_reversed
  mov rsi, r14
  mov rdi, rbx
  call copy_forward

  .done:
  mov r12, rbx
  mov r13, -1
  pop rbx
  ret

;Копирует часть входного файла (r8) в выходной (r9) как есть
;input: rsi - смещение начала, rdi - смещение конца (не включая)
copy_forward:
  push rbx
  push r15

  mov rbx, rsi
  mov r15, rdi

  call seek_input

  .loop:
    cmp rbx, r15
    jge .end

    ;читаем min(100, осталось) байт
    mov rdx, r15
    sub rdx, rbx
    cmp rdx, 100
    jle @f
    mov rdx, 100
    @@:
    call read_copy_chunk
    cmp rax, 0
    jle .end
    add rbx, rax

    mov rdx, rax
    call write_copy_chunk
    jmp .loop
  .end:

  pop r15
  pop rbx
  ret

;Копирует часть входного файла (r8) в выходной (r9) задом наперёд
;input: rsi - смещение начала, rdi - смещение конца (не включая)
copy_reversed:
  push rbx
  push r14
  push r15

  mov rbx, rsi ;начало
  mov r15, rdi ;конец ещё не записанной части

  .loop:
    cmp r15, rbx
    jle .end

    ;кусок [r14, r15), r14 = max(r15 - 100, начало)
    mov r14, r15
    sub r14, 100
    cmp r14, rbx
    jge @f
    mov r14, rbx
    @@:

    mov rsi, r14
    call seek_input
    mov rdx, r15
    sub rdx, r14
    call read_copy_chunk
    cmp rax, 0
    jle .end

    ;разворачиваем кусок и записываем
    mov rdx, rax
    mov rsi, cbuf
    mov rdi, cbuf
    add rdi, rax
    dec rdi
    call reverse_str

    call write_copy_chunk

    mov r15, r14
    jmp .loop
  .end:

  pop r15
  pop r14
  pop rbx
  ret

;Устанавливает позицию во входном файле (r8) на смещение rsi
seek_input:
  mov rax, 8
  mov rdi, r8
  xor rdx, rdx ;SEEK_SET
  syscall
  ret

;Читает до rdx байт из входного файла (r8) в cbuf, результат в rax
read_copy_chunk:
  xor rax, rax
  mov rdi, r8
  mov rsi, cbuf
  syscall
  ret

;Записывает rdx байт из cbuf в выходной файл (r9)
write_copy_chunk:
  mov rax, 1
  mov rdi, r9
  mov rsi, cbuf
  syscall
  ret
