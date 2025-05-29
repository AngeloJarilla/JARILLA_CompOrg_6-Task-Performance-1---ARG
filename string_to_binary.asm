section .bss
    input resb 20
    binary_buf resb 32

section .data
    prompt db "Enter a number (0 to quit): ", 0
    len_prompt equ $ - prompt

    newline db 10
    newline_len equ $ - newline

    binary_msg db "Binary: ", 0
    binary_msg_len equ $ - binary_msg

section .text
    global _start

_start:
input_loop:
    ; Print prompt
    mov eax, 4          ; syscall: sys_write
    mov ebx, 1          ; stdout
    mov ecx, prompt
    mov edx, len_prompt
    int 0x80

    ; Read input
    mov eax, 3          ; syscall: sys_read
    mov ebx, 0          ; stdin
    mov ecx, input
    mov edx, 20
    int 0x80

    ; Replace newline with null term
    mov ecx, input
remove_nl:
    cmp byte [ecx], 10
    je replace_nl
    cmp byte [ecx], 0
    je remove_done
    inc ecx
    jmp remove_nl

replace_nl:
    mov byte [ecx], 0

remove_done:
    ; Convert string to integer
    mov esi, input
    call atoi
    cmp eax, 0
    je exit_program     ; Exit if input is 0

    ; Print "Binary: "
    mov eax, 4
    mov ebx, 1
    mov ecx, binary_msg
    mov edx, binary_msg_len
    int 0x80

    ; Print binary
    mov eax, edi        ; integer value in edi
    call print_binary

    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, newline_len
    int 0x80

    jmp input_loop

; Converts ASCII decimal to integer
atoi:
    xor eax, eax        ; clear result
    xor edi, edi
    xor ebx, ebx        ; sign flag
    mov bl, [esi]
    cmp bl, '-'
    jne parse_loop
    ; if negative
    inc esi
    mov bl, 1

parse_loop:
    movzx edx, byte [esi]
    test edx, edx
    je parse_done
    sub edx, '0'
    imul eax, eax, 10
    add eax, edx
    inc esi
    jmp parse_loop

parse_done:
    mov edi, eax
    cmp bl, 1
    jne done_atoi
    neg eax
    neg edi
done_atoi:
    ret

print_binary:
    mov ecx, 32
    mov ebx, eax
    mov esi, binary_buf

print_loop:
    shl ebx, 1
    jc bit_one
    mov byte [esi], '0'
    jmp bit_done

bit_one:
    mov byte [esi], '1'

bit_done:
    inc esi
    loop print_loop

    ; print binary buffer
    mov eax, 4
    mov ebx, 1
    mov ecx, binary_buf
    mov edx, 32
    int 0x80
    ret

;exit
exit_program:
    mov eax, 1          ; syscall: exit
    xor ebx, ebx        ; status 0
    int 0x80
