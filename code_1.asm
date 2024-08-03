section .data
    array dw 36, 60
    len_of_array equ $ - array

section .bss
    result resb 2
    num_string resb 6

; print 매크로 생성
%macro print 2
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
%endmacro

section .text
    global _start

_start: ;
    movzx rax, word [array]
    movzx rbx, word [array + 2]

continue_loop:
    cmp rax, rbx
    jb xchg_loop
    ja div_loop
    je done
xchg_loop:
    xchg rax, rbx
    test rbx, rbx
    jz done
    jmp continue_loop
div_loop:
    xor rdx, rdx
    div rbx
    mov rax, rdx
    jmp continue_loop
done:
    mov [result], rax    
    mov rsi, result
    movzx eax, word [rsi]
    call print_number

    ; 프로그램 종료
    mov rax, 60
    xor rdi, rdi
    syscall

print_number:
    mov rdi, num_string + 5
    mov byte [rdi], 0
    mov rcx, 10

convert_loop:
    dec rdi
    xor rdx, rdx
    div rcx
    add dl, '0'
    mov [rdi], dl
    test rax, rax
    jnz convert_loop

    mov rsi, rdi
    lea rdx, [num_string + 6]
    sub rdx, rsi
    print rsi, rdx
    ret