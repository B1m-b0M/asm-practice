; Файл: hw5.asm
; Програма виводить конверт у консоль
; AH - ширина конверту
; AL - висота конверту
.model small
.stack 100h

.data
    ; Можна додати повідомлення, якщо потрібно

.code
start:
    mov ax, @data
    mov ds, ax

    ; -------------------------------------------------------
    ; ВХІДНІ ДАНІ
    ; AH = Ширина (Width), AL = Висота (Height)
    ; -------------------------------------------------------
    mov ah, 30         ; Ширина = 30
    mov al, 15         ; Висота = 15
    
    ; Інші приклади для тесту:
    ; mov ah, 30
    ; mov al, 10
    
    ; mov ah, 20
    ; mov al, 10
    
    ; mov ah, 24
    ; mov al, 8

    ; -------------------------------------------------------
    ; 1. Зберігаємо розміри у безпечні регістри
    ; -------------------------------------------------------
    xor cx, cx
    mov cl, ah         ; CX = Width
    
    xor bx, bx
    mov bl, al         ; BX = Height

    ; -------------------------------------------------------
    ; 2. Розрахунок коефіцієнта (Ratio = Width / Height)
    ; -------------------------------------------------------
    xor ax, ax
    mov al, cl         ; AX = Width
    div bl             ; AL = Width / Height (ціле ділення)
    xor ah, ah
    mov bp, ax         ; BP = Ratio (співвідношення сторін)

    ; -------------------------------------------------------
    ; ГОЛОВНИЙ ЦИКЛ МАЛЮВАННЯ
    ; SI = поточний рядок (Y), від 0 до Height-1
    ; DI = поточний стовпець (X), від 0 до Width-1
    ; -------------------------------------------------------
    xor si, si         ; Y = 0

row_loop:
    cmp si, bx         ; Якщо Y >= Height, вихід
    jge exit_prog
    
    xor di, di         ; X = 0 (початок нового рядка)

col_loop:
    cmp di, cx         ; Якщо X >= Width, перехід на новий рядок
    jge print_newline

    ; --- ПЕРЕВІРКА УМОВ ДЛЯ ДРУКУ '*' ---
    
    ; Умова 1: Ліва межа (X == 0)
    cmp di, 0
    je print_star

    ; Умова 2: Права межа (X == Width - 1)
    mov dx, cx
    dec dx             ; DX = Width - 1
    cmp di, dx
    je print_star

    ; Умова 3: Верхня межа (Y == 0)
    cmp si, 0
    je print_star

    ; Умова 4: Нижня межа (Y == Height - 1)
    mov dx, bx
    dec dx             ; DX = Height - 1
    cmp si, dx
    je print_star

    ; --- РОЗРАХУНОК ДІАГОНАЛЕЙ ---
    ; Обчислюємо зміщення для поточного рядка: Offset = Y * Ratio
    mov ax, si         ; AX = Y
    mul bp             ; AX = Y * Ratio

    ; Умова 5: Головна діагональ (X == Offset)
    cmp di, ax
    je print_star

    ; Умова 6: Побічна діагональ (X == (Width - 1) - Offset)
    mov dx, cx         ; DX = Width
    dec dx             ; DX = Width - 1
    sub dx, ax         ; DX = (Width - 1) - Offset
    cmp di, dx
    je print_star

    ; Якщо жодна умова не виконалася -> друкуємо пробіл
    mov dl, ' '
    jmp do_print

print_star:
    mov dl, '*'

do_print:
    mov ah, 02h        ; Функція DOS: вивід символу з DL
    int 21h
    
    inc di             ; X++
    jmp col_loop

print_newline:
    ; Друкуємо CR (13) + LF (10) для переходу на новий рядок
    mov dl, 13
    mov ah, 02h
    int 21h
    
    mov dl, 10
    mov ah, 02h
    int 21h
    
    inc si             ; Y++
    jmp row_loop

exit_prog:
    mov ax, 4c00h      ; Вихід в DOS
    int 21h

end start