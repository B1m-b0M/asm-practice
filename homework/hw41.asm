; Файл: hw41.asm
.model small
.stack 100h

.data
    msg_in  db 'Input: $'
    msg_out db 13, 10, 'Factorial: $' ; 13, 10 - перехід на новий рядок
    newline db 13, 10, '$'

.code
start:
    mov ax, @data
    mov ds, ax

    ; --- ЗАДАННЯ ВХІДНОГО ЧИСЛА ---
    mov ax, 8          ; Вхідне число (можна змінити, наприклад, на 5 або 10)
    
    ; Збережемо вхідне число в BX для друку, бо AX буде змінено
    mov bx, ax         

    ; --- ДРУК ВХІДНОГО ЧИСЛА ---
    lea dx, msg_in     ; Вивід тексту "Input: "
    mov ah, 09h
    int 21h

    mov ax, bx         ; Відновлюємо число для друку
    xor dx, dx         ; Обнуляємо DX для процедури друку
    call PRINT_DXAX_DEC

    ; --- ОБЧИСЛЕННЯ ФАКТОРІАЛУ (ІТЕРАТИВНО) ---
    mov ax, bx         ; Повертаємо вхідне число в AX для розрахунку
    call FACTORIAL_ITER

    ; --- ДРУК РЕЗУЛЬТАТУ ---
    push dx            ; Зберігаємо результат (DX:AX)
    push ax
    
    lea dx, msg_out    ; Вивід тексту "Factorial: "
    mov ah, 09h
    int 21h

    pop ax             ; Відновлюємо результат
    pop dx
    call PRINT_DXAX_DEC ; Друкуємо значення з регістрів DX:AX

    ; --- ВИХІД ---
    mov ax, 4c00h
    int 21h

; -----------------------------------------------------
; Процедура: FACTORIAL_ITER
; Вхід: AX - число N
; Вихід: DX:AX - результат N!
; Алгоритм: Цикл від N до 2, множення
; -----------------------------------------------------
FACTORIAL_ITER proc
    cmp ax, 0          ; Перевірка на 0!
    je is_zero
    cmp ax, 1          ; Перевірка на 1!
    je is_one

    mov cx, ax         ; CX = лічильник (поточний множник)
    dec cx             ; Починаємо множити на (N-1)
    
    ; AX вже містить N, DX обнуляємо для чистоти старту, якщо число мале
    xor dx, dx         

calc_loop:
    cmp cx, 1          ; Якщо множник дійшов до 1, виходимо
    jle done
    
    mul cx             ; DX:AX = AX * CX
    dec cx             ; Зменшуємо множник
    jmp calc_loop      ; Повторюємо (loop/jnz)

is_zero:
is_one:
    mov ax, 1          ; 0! = 1, 1! = 1
    xor dx, dx
    ret

done:
    ret
FACTORIAL_ITER endp

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

    mov bx, 10          ; Дільник = 10
    xor cx, cx          ; Лічильник цифр

divide_loop:
    ; Складна ділення 32-біт DX:AX на 16-біт BX
    ; 1. Ділимо старшу частину (DX)
    push ax             ; Зберігаємо молодшу частину
    mov ax, dx          ; Переносимо старшу частину в AX для ділення
    xor dx, dx          ; Обнуляємо DX перед діленням
    div bx              ; AX = частка (старша), DX = остача
    mov si, ax          ; Зберігаємо частку старшої частини в SI
    pop ax              ; Відновлюємо молодшу частину

    ; 2. Ділимо (Остача:Молодша) на BX. 
    ; DX вже містить остачу від попереднього ділення
    div bx              ; Тепер AX = частка (молодша), DX = остача (цифра)

    push dx             ; Зберігаємо цифру (остачу) в стек
    inc cx              ; Збільшуємо лічильник цифр

    ; Оновлюємо DX:AX результатом ділення
    mov dx, si          ; DX = нова старша частина
    ; AX вже містить нову молодшу частину

    ; Перевірка: якщо DX:AX == 0, кінець
    cmp ax, 0
    jne divide_loop
    cmp dx, 0
    jne divide_loop

print_loop:
    pop dx              ; Дістаємо цифру зі стека
    add dl, 30h         ; Перетворюємо число в ASCII ('0'-'9')
    mov ah, 02h         ; Функція виводу символу
    int 21h
    loop print_loop

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PRINT_DXAX_DEC endp

end start