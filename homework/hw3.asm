section .data
    msg_number db "Number: ", 0
    msg_number_len equ $ - msg_number
    
    msg_is_prime db " is PRIME", 10, 0
    msg_is_prime_len equ $ - msg_is_prime
    
    msg_not_prime db " is NOT prime", 10, 0
    msg_not_prime_len equ $ - msg_not_prime
    
    newline db 10
    
section .bss
    buffer resb 6
    
section .text
    global _start

_start:
    mov ax, 17
    
    call print_number
    call is_prime
    
    test al, al
    jnz .print_prime
    
.print_not_prime:
    mov ecx, msg_not_prime
    mov edx, msg_not_prime_len - 1
    jmp .do_print
    
.print_prime:
    mov ecx, msg_is_prime
    mov edx, msg_is_prime_len - 1
    
.do_print:
    mov eax, 4
    mov ebx, 1
    int 0x80
    
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_number:
    push ebp
    mov ebp, esp
    push eax
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_number
    mov edx, msg_number_len
    int 0x80
    
    pop eax
    and eax, 0xFFFF
    mov esi, buffer
    call uint16_to_string
    
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, esi
    int 0x80
    
    mov esp, ebp
    pop ebp
    ret

uint16_to_string:
    push ebp
    mov ebp, esp
    push edi
    push ebx
    
    mov edi, esi
    xor ecx, ecx
    mov ebx, 10
    
    test ax, ax
    jnz .extract_digits
    mov byte [esi], '0'
    inc esi
    mov byte [esi], 0
    mov esi, 1
    jmp .done
    
.extract_digits:
    movzx eax, ax
    
.digit_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    push dx
    inc ecx
    test eax, eax
    jnz .digit_loop
    
    mov esi, edi
.write_loop:
    pop dx
    mov [esi], dl
    inc esi
    loop .write_loop
    
    mov byte [esi], 0
    sub esi, edi
    
.done:
    pop ebx
    pop edi
    mov esp, ebp
    pop ebp
    ret

is_prime:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    movzx eax, ax
    
    cmp eax, 1
    jbe .not_prime
    
    cmp eax, 2
    je .is_prime
    
    test al, 1
    jz .not_prime
    
    cmp eax, 3
    je .is_prime
    
    mov esi, eax
    mov ebx, 3
    xor edx, edx
    div ebx
    test edx, edx
    jz .not_prime
    
    mov eax, esi
    mov ecx, 5
    
.check_loop:
    mov eax, ecx
    mul eax
    cmp eax, esi
    ja .is_prime
    
    mov eax, esi
    xor edx, edx
    div ecx
    test edx, edx
    jz .not_prime
    
    add ecx, 2
    mov eax, esi
    xor edx, edx
    div ecx
    test edx, edx
    jz .not_prime
    
    add ecx, 4
    jmp .check_loop
    
.is_prime:
    mov al, 1
    jmp .done
    
.not_prime:
    xor al, al
    
.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret