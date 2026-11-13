
format elf64
public _start

include '../MyLibrary.asm'

section '.data' writeable

  nl db 10       ;символ перевода строки
  need_nl db 0   ;1 - если файл не заканчивается переводом строки

section '.bss' writable

  buf rb 100 ;буфер для чтения кусков файла

section '.text' executable

_start:
  ;Считываем количество пааметров командной строки
    pop rcx
    cmp rcx, 3
    jl .l1

    ;открываем файл, который будем читать
    mov rdi,[rsp+8]
    mov rax, 2
    mov rsi, 0o ;файл только для чтения
    syscall
    cmp rax, 0
    jl .l1
    ;Сохраняем дескриптор
    mov r8, rax

    ;открываем файл, в который будем записывать
    mov rdi,[rsp+16]
    mov rax, 2
    mov rsi, 577   ;если файл существует, его содержимое будет стёрто. Если файла нет — он создастся
    mov rdx, 777o  ;права доступа
    syscall
    cmp rax, 0
    jl .l1
    ;Сохраняем дескриптор
    mov r9, rax

    ;Узнаём размер файла: lseek(fd, 0, SEEK_END)
    mov rax, 8
    mov rdi, r8
    mov rsi, 0
    mov rdx, 2
    syscall
    cmp rax, 0
    jle .close ;пустой файл - записывать нечего

    ;r12 - конец текущей строки (смещение за её последним символом)
    ;r13 - смещение, левее которого ищем '\n'
    mov r12, rax
    mov r13, rax

    ;Читаем последний символ файла
    mov rsi, rax
    dec rsi
    mov rax, 8
    mov rdi, r8
    mov rdx, 0
    syscall
    mov rax, 0
    mov rdi, r8
    mov rsi, buf
    mov rdx, 1
    syscall

    cmp byte [buf], 10
    jne @f
    dec r13 ;последний '\n' относится к последней строке, пропускаем его
    jmp .search
    @@:
    mov byte [need_nl], 1

    ;Идём от конца файла к началу кусками по 100 байт
    .search:
      cmp r13, 0
      je .write_first

      ;r14 - начало куска: max(r13 - 100, 0)
      mov r14, r13
      sub r14, 100
      cmp r14, 0
      jge @f
      mov r14, 0
      @@:

      ;Читаем кусок [r14, r13) в buf
      mov rax, 8
      mov rdi, r8
      mov rsi, r14
      mov rdx, 0
      syscall
      mov rax, 0
      mov rdi, r8
      mov rsi, buf
      mov rdx, r13
      sub rdx, r14
      syscall

      ;rbx - индекс в buf, ищем '\n' с конца куска
      mov rbx, r13
      sub rbx, r14
      .scan:
        cmp rbx, 0
        je .next_chunk
        dec rbx
        cmp byte [buf + rbx], 10
        jne .scan

      ;Нашли '\n' на смещении r14+rbx - строка начинается сразу за ним
      mov r13, r14
      add r13, rbx
      mov rsi, r13
      inc rsi
      mov rdi, r12
      call copy_part
      ;конец следующей строки - сразу за найденным '\n'
      mov r12, r13
      inc r12
      jmp .search

      .next_chunk:
        mov r13, r14
        jmp .search

    ;первая строка файла: с 0 по r12 (не включая)
    .write_first:
      mov rsi, 0
      mov rdi, r12
      call copy_part

    .close:
    mov rdi, r8
    mov rax, 3
    syscall

    mov rdi, r9
    mov rax, 3
    syscall

.l1:
   call exit

;Копирует часть входного файла (r8) в выходной (r9) кусками по 100 байт
;input: rsi - смещение начала, rdi - смещение конца (не включая)
copy_part:
  push rbx
  push r15

  mov rbx, rsi ;текущее смещение
  mov r15, rdi ;смещение конца

  ;lseek(fd, начало, SEEK_SET)
  mov rax, 8
  mov rdi, r8
  mov rdx, 0
  syscall

  .loop:
    cmp rbx, r15
    jge .end

    ;читаем min(100, конец - текущее) байт
    mov rdx, r15
    sub rdx, rbx
    cmp rdx, 100
    jle @f
    mov rdx, 100
    @@:
    mov rax, 0
    mov rdi, r8
    mov rsi, buf
    syscall
    cmp rax, 0
    jle .end
    add rbx, rax

    mov rdx, rax
    mov rax, 1
    mov rdi, r9
    mov rsi, buf
    syscall
    jmp .loop
  .end:

  ;Первой записывается последняя строка файла - если у неё не было '\n', дописываем
  cmp byte [need_nl], 1
  jne @f
  mov rax, 1
  mov rdi, r9
  mov rsi, nl
  mov rdx, 1
  syscall
  mov byte [need_nl], 0
  @@:

  pop r15
  pop rbx
  ret
