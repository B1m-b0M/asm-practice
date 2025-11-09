section .data
    nl db 10,0          ; символ нового рядка

section .bss
    buffer resb 32

section .text
    global _start

; int2str(int eax, char* esi)
int2str:
    mov edi, esi
    mov ebx, 10
    mov ecx, 0
    cmp eax, 0
    jge .loop
    neg eax
    mov byte [edi], '-'
    inc edi
.loop:
    mov edx, 0
    div ebx
    add dl, '0'
    push dx
    inc ecx
    test eax, eax
    jnz .loop
.write_digits:
    pop dx
    mov [edi], dl
    inc edi
    loop .write_digits
    mov byte [edi], 0
    ret

_start:
    mov eax, 1234567
    mov esi, buffer
    call int2str

    mov ecx, buffer
    mov edx, 0
.count:
    cmp byte [ecx + edx], 0
    je .done_count
    inc edx
    jmp .count
.done_count:

    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, nl
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80
