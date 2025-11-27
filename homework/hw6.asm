; Файл: hw6.asm
; Універсальна функція сортування для даних різної розрядності
.model small
.stack 100h

.data
    ; --- ТЕСТОВІ ДАНІ ---
    ; Приклад 1: Масив слів (2 байти)
    source_arr  dw 500, 12, 300, 1, 65000
    dest_arr    dw 5 dup(0)
    
    count_bytes dw 10   ; Загальна кількість байтів (5 елементів * 2 байти)
    elem_size   dw 2    ; Розмір одного елемента (word = 2 байти)

    ; Приклад 2: Масив байтів (розкоментувати для тесту)
    ; source_arr  db 50, 12, 99, 1, 200
    ; dest_arr    db 5 dup(0)
    ; count_bytes dw 5
    ; elem_size   dw 1

    ; Приклад 3: Масив dword (4 байти) - розкоментувати для тесту
    ; source_arr  dd 100000, 50, 999999, 1
    ; dest_arr    dd 4 dup(0)
    ; count_bytes dw 16
    ; elem_size   dw 4

    msg_done    db 13, 10, 'Sorting complete. Check debugger.$'

.code
start:
    mov ax, @data
    mov ds, ax
    mov es, ax      ; ES потрібен для роботи з DI

    ; --- ПІДГОТОВКА ПАРАМЕТРІВ ---
    lea si, source_arr  ; SI = Адреса джерела
    lea di, dest_arr    ; DI = Адреса призначення
    mov cx, count_bytes ; CX = Кількість байтів для сортування
    mov bx, elem_size   ; BX = Розмір одного елемента (1, 2, 4 або 8)

    ; --- ВИКЛИК ФУНКЦІЇ СОРТУВАННЯ ---
    call SORT_GENERIC

    ; --- ЗАВЕРШЕННЯ ---
    lea dx, msg_done
    mov ah, 09h
    int 21h

    mov ax, 4c00h
    int 21h

; =========================================================
; ПРОЦЕДУРА: SORT_GENERIC
; Сортує масив даних будь-якої розрядності методом бульбашки
; Вхід:
;   DS:SI - вхідний масив (джерело)
;   ES:DI - вихідний буфер (призначення)
;   CX    - загальна кількість байтів для сортування
;   BX    - розмір одного елемента (в байтах: 1, 2, 4 або 8)
; Вихід:
;   Відсортований масив за адресою ES:DI
; =========================================================
SORT_GENERIC proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    ; 1. Копіюємо вхідний масив з SI в DI
    push cx
    push si
    push di
    cld             ; Напрямок копіювання вперед
    rep movsb       ; Копіювання байт за байтом
    pop di          ; Відновлюємо DI (початок вихідного буфера)
    pop si
    pop cx

    ; 2. Розрахунок кількості елементів (N = Bytes / Size)
    mov ax, cx
    xor dx, dx
    div bx          ; AX = Кількість елементів
    cmp ax, 1       ; Якщо <= 1 елемент, сортувати не треба
    jle sort_exit

    mov cx, ax      ; CX = Кількість елементів (N)
    dec cx          ; Зовнішній цикл: N-1 ітерацій

    ; Зберігаємо початкову адресу вихідного буфера
    mov bp, di

outer_loop:
    push cx         ; Зберігаємо лічильник зовнішнього циклу
    mov di, bp      ; Повертаємося на початок масиву

    ; Внутрішній цикл: CX ітерацій
inner_loop:
    ; Порівнюємо елементи [DI] та [DI+BX]
    call COMPARE_ELEMENTS
    ; Результат у прапорах: JA означає [DI] > [DI+BX] (без знака)
    
    jbe no_swap     ; Якщо лівий <= правий, не міняємо

    ; Міняємо місцями [DI] і [DI+BX]
    call SWAP_ELEMENTS

no_swap:
    add di, bx      ; Переходимо до наступного елемента
    loop inner_loop ; Повторюємо CX разів

    pop cx          ; Відновлюємо лічильник зовнішнього циклу
    loop outer_loop ; Повторюємо зовнішній цикл

sort_exit:
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
SORT_GENERIC endp

; ---------------------------------------------------------
; COMPARE_ELEMENTS
; Порівнює два числа розміром BX байтів за адресами [DI] та [DI+BX]
; Враховує порядок байтів Little Endian (порівняння починається з MSB)
; Вхід: 
;   ES:DI - адреса першого числа
;   BX    - розмір елемента в байтах
; Вихід: 
;   Прапори встановлені як після CMP [DI], [DI+BX]
; ---------------------------------------------------------
COMPARE_ELEMENTS proc
    push cx
    push si
    push di
    push ax
    push dx

    mov cx, bx      ; Лічильник байтів

    ; Для Little Endian старший байт (MSB) знаходиться в кінці
    ; Переміщаємо вказівники на останні байти чисел
    add di, bx
    dec di          ; DI -> MSB першого числа

    mov si, di
    add si, bx      ; SI -> MSB другого числа

compare_byte_loop:
    mov al, es:[di] ; Байт першого числа
    mov dl, es:[si] ; Байт другого числа
    cmp al, dl
    jne done_compare ; Якщо байти різні, результат визначено

    dec di
    dec si
    loop compare_byte_loop

    ; Якщо всі байти однакові, числа рівні (ZF=1)

done_compare:
    ; Прапори встановлені останньою інструкцією CMP
    ; POP регістрів не змінює прапори
    pop dx
    pop ax
    pop di
    pop si
    pop cx
    ret
COMPARE_ELEMENTS endp

; ---------------------------------------------------------
; SWAP_ELEMENTS
; Міняє місцями два числа розміром BX байтів
; Вхід:
;   ES:DI - адреса першого числа
;   BX    - розмір елемента в байтах
; ---------------------------------------------------------
SWAP_ELEMENTS proc
    push cx
    push si
    push di
    push ax

    mov si, di      ; SI -> перший елемент
    add di, bx      ; DI -> другий елемент
    mov cx, bx      ; Кількість байтів для обміну

swap_loop:
    mov al, es:[si] ; Читаємо байт з першого елемента
    xchg al, es:[di]; Обмінюємо з байтом другого елемента
    mov es:[si], al ; Записуємо у перший елемент

    inc si
    inc di
    loop swap_loop

    pop ax
    pop di
    pop si
    pop cx
    ret
SWAP_ELEMENTS endp

end start