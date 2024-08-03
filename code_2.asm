section .data
    array db 9,8,7,6,3,4,2,1,5,10,13
    len_of_array equ $-array
section .bss
    result resb 2
    num_string resb 8 
%macro print 2 
    mov rax, 1 
    mov rdi, 1 
    mov rsi, %1 
    mov rdx, %2 
    syscall 
%endmacro
section .text
   global _start

_start:
    mov rsi, array
    mov rax, len_of_array
    mov r8, result
    call divide  ; rsi와 rax를 적절히 재귀함수로 호출하여 정렬하자
    mov r12, len_of_array ; 최종적으로 저장된 array값 반복인자
loop: 
    mov rax, len_of_array
    sub rax, r12
    lea rdi, [array]
    add rdi, rax
    movzx rax, byte [rdi]
    call print_number 

    ; 프로그램 종료
    mov rax, 60    
    xor rdi, rdi    
    syscall

print_number:
    mov rdi, num_string + 5 
    mov byte [rdi], ' '        
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
    
    dec r12
    test r12, r12
    jnz loop
    ret
divide:
    cmp rax, 1
    jbe done
    mov rdx, rax
    push rax
    shr rax, 1    
    mov rcx, rax   
    sub rdx, rcx  
    lea rdi, [rsi+rcx] 
    
    push rcx          
    push rdx
    push rdi
    push rsi   

    mov rax, rcx   ; 포인터 위치 update
    call divide    ; 왼쪽 블럭 접근
    
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rax
    
    push rax
    push rcx    
    push rdx
    push rdi
    push rsi   

    mov rsi, rdi  ; 포인터 위치 update
    mov rax, rdx
    call divide   ; 오른쪽 블럭 접근
    
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rax

    push rax
    push rcx  
    push rdx
    push rdi
    push rsi   
    push r8
    call merge   ; 정렬된 블럭 merge
    
    pop r8
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rax 
    
    mov rdi, rsi
    mov rsi, r8 
    mov rcx, rax 
    rep movsb ; sort된 블럭 갱신
    jmp done

merge:
    movzx r9, byte[rsi]
    movzx r10, byte[rdi]
    cmp r9, r10
    jbe select_left
    ja select_right
    ret
    
select_left:
    mov [r8], r9
    inc r8
    inc rsi
    dec rcx
    cmp rcx, 0
    ja merge
    jmp release_right
select_right:
    mov [r8], r10
    inc r8
    inc rdi
    dec rdx
    cmp rdx, 0
    ja merge
    jmp release_left

release_left:
    mov rdi, r8 
    rep movsb 
    jmp done
release_right:
    mov rsi, rdi 
    mov rdi, r8 
    mov rcx, rdx
    rep movsb 
    jmp done

done:
    ret