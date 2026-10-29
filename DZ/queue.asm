; queue: [ 4bytes(capacity), 4bytes(start), 4bytes(end),
; 4bytes(alignment), 8bytes(data[0]), 8bytes(data[1]), ...]
; data - знаковые 64-битные числа 

format elf64

public create_queue
public push_queue
public pop_queue
public print_queue
public fill_rabdom_queue
public ending_one_queue
public get_list_odd_queue
public delete_even_queue

include '../MyLibrary.asm'

section '.text' executable

create_queue:
    push rdi
    push rsi
    push rdx
    push r10
    push r8
    push r9
    ; выполняем анонимное отображение в память
	mov rdi, 0      ;начальный адрес выберет сама ОС
	mov rsi, 4096 ;задаем размер области памяти
	mov rdx, 0x3    ;совмещаем флаги PROT_READ | PROT_WRITE
	mov r10,0x22    ;задаем режим MAP_ANONYMOUS|MAP_PRIVATE
	mov r8, -1      ;указываем файловый дескриптор null
	mov r9, 0       ;задаем нулевое смещение
	mov rax, 9      ;номер системного вызова mmap
	syscall

    mov dword [rax], 510 

    pop r9
    pop r8
    pop r10
    pop rdx
    pop rsi
    pop rdi

    ret

push_queue:
    push r9
    push r8
    push r10
    push r12

    mov r9d, dword [rdi + 8]    ; end offset
    mov r8d, dword [rdi + 4]    ; start offset
    mov r10d, dword [rdi]       ; capacity

    mov r12, r9
    call inc_offset             ; r12 - следующее значение end

    cmp r12d, r8d               ; если следующий end совпадает со start, очередь полна
    je error

    mov qword[rdi + 16 + r9*8], rsi
    mov dword[rdi + 8], r12d

    pop r12
    pop r10
    pop r8
    pop r9
    ret

pop_queue:
    push r9
    push r8
    push r10
    push r12

    mov r9d, dword [rdi + 8]    ; end 
    mov r8d, dword [rdi + 4]    ; start
    mov r10d, dword [rdi]       ; capacity

    cmp r9d, r8d
    je error

    mov rax, qword [rdi + r8*8 + 16]

    mov r12, r8
    call inc_offset
    mov dword [rdi + 4], r12d

    pop r12
    pop r10
    pop r8
    pop r9
    ret

fill_rabdom_queue:
    push rax
    push r9
    push r8
    xor r8,r8
    mov r9, rsi


    .loop:
        cmp r8, r9
        je .done

        call random
        mov rsi, rax
        call push_queue
        inc r8
        jmp .loop

    .done:
    pop r8
    pop r9
    pop rax
    ret

ending_one_queue:
    push r9
    push r12
    push r10
    push r11
    push r13

    mov r13, 10
    mov r9d, dword [rdi + 8]    ; end 
    mov r12d, dword [rdi + 4]    ; start
    mov r10d, dword [rdi]       ; capacity
    xor r11, r11 ; count

    .loop:
        cmp r9d, r12d
        je .done

        mov rax, [rdi+ 16 + r12*8]
        call inc_offset

        cmp rax, 0
        jge .positive
        neg rax
        .positive:

        xor rdx, rdx
        div r13
        cmp rdx, 1
        jne .loop
        inc r11
        jmp .loop

    .done:

    mov rax, r11
    pop r13
    pop r11
    pop r10
    pop r12
    pop r9

    ret

get_list_odd_queue:
    push rbx
    push r9
    push r10
    push r12
    push rsi

    mov rbx, rdi                ; исходная очередь
    mov r9d, dword [rbx + 8]    ; end offset
    mov r12d, dword [rbx + 4]   ; start offset
    mov r10d, dword [rbx]       ; capacity

    call create_queue
    mov rdi, rax ; очередь для нечетных чисел

    .loop:
        cmp r9d, r12d
        je .done

        mov rsi, [rbx + 16 + r12*8] ; читаем элемент до сдвига индекса
        call inc_offset

        test rsi, 1             ; младший бит = 1 -> нечётное (и для отрицательных)
        jz .loop
        call push_queue
        jmp .loop

    .done:

    mov rax, rdi

    pop rsi
    pop r12
    pop r10
    pop r9
    pop rbx

    ret

; Удаляет чётные элементы из очереди (rdi - адрес очереди).
; Каждый элемент извлекается pop_queue, нечётные возвращаются в конец push_queue,
; поэтому порядок оставшихся элементов сохраняется.
delete_even_queue:
    push rax
    push rcx
    push rsi
    push r8

    mov ecx, dword [rdi + 8]    ; end
    mov r8d, dword [rdi + 4]    ; start
    sub ecx, r8d                ; количество элементов = end - start
    jge @f
    add ecx, dword [rdi]        ; если end < start, прибавляем capacity
    @@:

    .loop:
        test rcx, rcx
        jz .done

        call pop_queue          ; rax - элемент из начала очереди
        dec rcx

        test rax, 1             ; чётное - не возвращаем в очередь
        jz .loop
        mov rsi, rax
        call push_queue         ; нечётное - кладём обратно в конец
        jmp .loop

    .done:

    pop r8
    pop rsi
    pop rcx
    pop rax

    ret



; Выводит элементы очереди от start до end, каждый с новой строки
print_queue:
    push r12
    push r13

    mov r12d, dword [rdi + 4]   ; текущий индекс = start
    mov r13d, dword [rdi + 8]   ; end
    mov r10d, dword [rdi]

    .loop:
        cmp r12d, r13d
        je .done

        mov rax, qword [rdi + 16 + r12*8]
        call print_int  ; выводит число и '\n'

        call inc_offset
        jmp .loop

    .done:
    pop r13
    pop r12
    ret

; input:    r10 - capasity
;           r12 - offset
; output:   r12 - offset
inc_offset:
    inc r12
    cmp r12, r10
    jl @f ; если смещение равно вместимости, то переносим его в начало памяти
    xor r12, r12
    @@:
    ret

error:
    mov rax,60
    mov rdi, 1
    syscall