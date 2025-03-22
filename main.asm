bits 64
extern malloc, free, puts, printf, fflush, abort
global main

section .data
empty_str: db 0x0
int_format: db "%ld ", 0x0
data: dq 4, 8, 15, 16, 23, 42
data_length: equ ($-data) / 8

section .text

;;; print_int proc
print_int:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    mov rsi, rdi
    mov rdi, int_format
    xor rax, rax
    call printf

    xor rdi, rdi
    call fflush

    mov rsp, rbp
    pop rbp
    ret

;;; p proc
p:
    mov rax, rdi
    and rax, 1
    ret

;;; add_element proc
add_element:
    push rbp
    push rbx
    push r14
    mov rbp, rsp
    sub rsp, 16

    mov r14, rdi
    mov rbx, rsi

    mov rdi, 16
    call malloc
    test rax, rax
    jz abort

    mov [rax], r14
    mov [rax + 8], rbx

    mov rsp, rbp
    pop r14
    pop rbx
    pop rbp
    ret

;;; m proc (оптимизированная версия)
m:
    push rbx
    mov rbx, rdi       ; Указатель на начало списка
loop_m:
    test rbx, rbx      ; Проверяем, достигнут ли конец списка
    jz end_m
    mov rdi, [rbx]     ; Загружаем значение текущего узла
    call rsi           ; Вызываем функцию
    mov rbx, [rbx + 8] ; Переходим к следующему узлу
    jmp loop_m
end_m:
    pop rbx
    ret

;;; f proc (оптимизированная версия)
f:
    push rbx
    push r12
    push r13
    mov rbx, rdi       ; Указатель на начало списка
    mov r12, rsi       ; Аккумулятор
    mov r13, rdx       ; Предикат
loop_f:
    test rbx, rbx      ; Проверяем, достигнут ли конец списка
    jz end_f
    mov rdi, [rbx]     ; Загружаем значение текущего узла
    call r13           ; Вызываем предикат
    test rax, rax      ; Проверяем результат предиката
    jz skip_add
    mov rdi, [rbx]     ; Загружаем значение текущего узла
    mov rsi, r12       ; Текущий аккумулятор
    call add_element   ; Добавляем элемент в аккумулятор
    mov r12, rax       ; Обновляем аккумулятор
skip_add:
    mov rbx, [rbx + 8] ; Переходим к следующему узлу
    jmp loop_f
end_f:
    mov rax, r12       ; Возвращаем аккумулятор
    pop r13
    pop r12
    pop rbx
    ret

;;; free_list proc
free_list:
    push rbx
    mov rbx, rdi       ; Указатель на начало списка
loop_free:
    test rbx, rbx      ; Проверяем, достигнут ли конец списка
    jz end_free
    mov rdi, rbx       ; Подготавливаем узел для освобождения
    mov rbx, [rbx + 8] ; Переходим к следующему узлу
    call free          ; Освобождаем память
    jmp loop_free
end_free:
    pop rbx
    ret

;;; main proc
main:
    push rbx

    xor rax, rax
    mov rbx, data_length
adding_loop:
    mov rdi, [data - 8 + rbx * 8]
    mov rsi, rax
    call add_element
    dec rbx
    jnz adding_loop

    mov rbx, rax

    ; Выводим все элементы списка
    mov rdi, rax
    mov rsi, print_int
    call m

    mov rdi, empty_str
    call puts

    ; Фильтруем список, оставляя только нечетные числа
    mov rdx, p
    xor rsi, rsi
    mov rdi, rbx
    call f

    mov rdi, rax
    mov rsi, print_int
    call m

    mov rdi, empty_str
    call puts

    ; Освобождаем память
    mov rdi, rbx
    call free_list

    mov rdi, rax
    call free_list

    pop rbx

    xor rax, rax
    ret