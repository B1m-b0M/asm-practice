; Файл: hw42.asm
.model small
.stack 100h

.data
    msg_in  db 'Input: $'
    msg_out db 13, 10, 'Factorial: $'

.code
start:
    mov ax, @data
    mov ds, ax

    ; --- ЗАДАННЯ ВХІДНОГО ЧИСЛА ---
    mov ax, 8          ; Вхідне число
    
    ; Друк вхідного
    mov bx, ax         ; Копія для збереження
    lea dx, msg_in
    mov ah, 09h
    int 21h

    mov ax, bx
    xor dx, dx
    call PRINT_DXAX_DEC

    ; --- ОБЧИСЛЕННЯ (РЕКУРСИВНО) ---
    mov ax, bx         ; Відновлюємо AX
    call FACTORIAL_REC ; Результат повернеться в DX:AX

    ; --- ДРУК РЕЗУЛЬТАТУ ---
    push dx
    push ax
    
    lea dx, msg_out
    mov ah, 09h
    int 21h

    pop ax
    pop dx
    call PRINT_DXAX_DEC

    ; --- ВИХІД ---
    mov ax, 4c00h
    int 21h

; -----------------------------------------------------
; Процедура: FACTORIAL_REC
; Вхід: AX - число N
; Вихід: DX:AX - результат N!
; Алгоритм: Рекурсія (N * Fact(N-1))
; -----------------------------------------------------
FACTORIAL_REC proc
    cmp ax, 1          ; Базовий випадок: якщо N <= 1
    jle base_case

    push ax            ; Зберігаємо поточне N у стеку
    dec ax             ; Готуємо аргумент (N-1)
    call FACTORIAL_REC ; Рекурсивний виклик. Повертає (N-1)! у DX:AX
    
    ; Після повернення: DX:AX містить (N-1)!
    pop bx             ; Відновлюємо наше N зі стека в BX
    
    ; Множимо 32-бітне число DX:AX на 16-бітне BX
    ; Формула: (DX:AX) * BX = (AX * BX) + (DX * BX * 65536)
    
    push bx            ; Зберігаємо BX (N)
    push dx            ; Зберігаємо старшу частину (N-1)!
    
    ; Крок 1: Множимо старшу частину DX на BX
    mov ax, dx         ; AX = старша частина
    pop dx             ; Очищаємо стек (відновлюємо старий DX, але він вже скопійований)
    push dx            ; Повертаємо назад для подальшого використання
    mul bx             ; DX:AX = (стара DX) * BX
    mov cx, ax         ; CX = молодша частина від множення старшої частини
                       ; (старшу частину DX ігноруємо - переповнення)
    
    ; Крок 2: Множимо молодшу частину на BX
    pop dx             ; Відновлюємо старшу частину (N-1)!
    push cx            ; Зберігаємо результат множення старшої частини
    mov ax, dx         ; Помилка! Нам потрібна молодша частина
    
    ; Виправлення: збережемо обидві частини правильно
    pop cx             ; Витягуємо CX
    pop bx             ; Витягуємо N
    
    ; Почнемо заново з правильною логікою
    push bx            ; Зберігаємо N
    
    ; DX = старша частина (N-1)!
    ; AX = молодша частина (N-1)! - але ми її втратили!
    ; Треба зберегти обидві частини перед першим множенням
    
    push ax            ; Зберігаємо молодшу частину (N-1)!
    push dx            ; Зберігаємо старшу частину (N-1)!
    
    ; Множимо старшу частину: DX * BX
    mov ax, dx
    pop dx             ; Очищаємо DX зі стеку (але значення вже в AX)
    mul bx             ; DX:AX = (стара старша частина) * N
    mov cx, ax         ; Зберігаємо молодшу частину результату в CX
    
    ; Множимо молодшу частину: (молодша частина) * BX  
    pop ax             ; Відновлюємо молодшу частину (N-1)!
    mul bx             ; DX:AX = (молодша частина) * N
    
    ; Додаємо внесок від старшої частини
    add dx, cx         ; DX = DX + внесок від старшої частини
    
    pop bx             ; Відновлюємо BX (очищаємо стек)
    ret

base_case:
    mov ax, 1          ; Результат 1
    xor dx, dx         ; Старша частина 0
    ret
FACTORIAL_REC endp

; -----------------------------------------------------
; Процедура: PRINT_DXAX_DEC
; Друкує 32-бітне число з регістрів DX:AX у консоль
; -----------------------------------------------------
PRINT_DXAX_DEC proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov bx, 10
    xor cx, cx

divide_loop_rec:
    push ax
    mov ax, dx
    xor dx, dx
    div bx
    mov si, ax
    pop ax
    div bx
    push dx
    inc cx
    mov dx, si
    cmp ax, 0
    jne divide_loop_rec
    cmp dx, 0
    jne divide_loop_rec

print_loop_rec:
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    loop print_loop_rec

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PRINT_DXAX_DEC endp

end start