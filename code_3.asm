section .data
    array db "xababcdcdababcdcd"
    len equ $ - array
    space db ' '

section .bss
    result resb 2
    num_string resb 2 

section .text
    global _start

%macro print_int 1
    mov rax, %1
    mov rcx, 10
    lea rdi, [num_string + 2]
.convert_digit:
    ; rax를 rcx로 나눠서 각 자리 숫자를 아스키 문자로 변환
    dec rdi               ; rdi를 감소시켜 다음 문자 위치로 이동
    xor rdx, rdx          ; rdx 레지스터를 0으로 초기화
    div rcx               ; rax를 rcx(10)로 나누기 (몫은 rax, 나머지는 rdx에 저장)
    add dl, '0'           ; 나머지 값을 아스키 코드 문자로 변환            
    mov [rdi], dl         ; 변환된 문자를 메모리에 저장
    test rax, rax         ; rax가 0인지 확인 (몫이 0인지 확인)
    jnz .convert_digit     ; rax가 0이 아니면 반복
    lea rsi, [rdi]
    lea rdx, [num_string + 2]
    sub rdx, rdi
    print rsi, rdx
%endmacro

%macro print 2
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, %1         ; 주소
    mov rdx, %2         ; 길이
    syscall
%endmacro

_start:
    mov r14, 500   ; 최종 결과 저장
    mov r9, len        ; 배열 길이 로드
    push r9
    cmp r9, 1    ; 문자열 1개면 1 출력
    je out

    xor rdx, rdx   ; 문자열 / 2 저장
    mov rax, r9
    mov rbx, 2
    div rbx            
    mov r8, rax   ;r8에 chunk 크기 저장
    
    call chunk_loop
    print_int r14
   
system_out:
    mov rax, 60   ; 시스템 종료
    xor rdi, rdi
    syscall
   
chunk_loop:
    xor r13, r13   ; equal 반복인자
    xor r12, r12   ; 중간 결과값
    sub r9, r8
    lea r15, [array]     ; 원본 위치
    lea r10, [num_string]  ; 목표 위치
    add r12, r8   ; 초기값 chunk 더해주기
    call compare_part_loop   ; 작업 시작
    mov r9, len  ; r9 복원
 
    cmp r14, r12
    jbe skip_update
    mov r14, r12
skip_update:
    dec r8
    cmp r8, 1
    jae chunk_loop
    jb done_

compare_part_loop:
    cmp r9, r8
    jb back
    call get_word       ; r10에 비교할 문자 저장, r10에 알파벳 저장
    mov rsi, r15   ; 이동한 원본 위치 "(ab)abcdcde" -> "ab(ab)cdcde"
    mov rdi, r10   ; chunk 추출한 문자 "ab"
    xor rcx, rcx
    add rsi, r8     ; 원본은 chunk칸 뒤의 글자와 비교
compare_loop:
    cmp rcx, r8    ;rcx(add), r8(int)
    jae equal
    xor rax, rax
    xor rbx, rbx
    movzx rax, byte[rsi]   ; rax, rbx ,rcx, rdx, rsi rdi
    movzx rbx, byte[rdi]
    cmp rax, rbx
    jne not_equal
    inc rsi
    inc rdi

    inc rcx
    jmp compare_loop
equal:
    sub r9, r8  ; r9 = 1
    cmp r13, 0
    jbe equal_first
    ja equal_repeat
equal_first:
    add r12, 1
    add r15, r8  ; 다음 chunk로 이동 후 sampling
    mov r13, 1  ; 1번 이상 반복 check
    jmp compare_part_loop
equal_repeat:
    add r15, r8
    jmp compare_part_loop

   
not_equal:
    add r15, r8
    add r12, r8
    mov r13, 0
    sub r9, r8
    jmp compare_part_loop

get_word:
    push rax
    push rcx
    xor rax, rax
word_loop:
    cmp rax, r8
    jae done
    movzx rcx, byte [r15 + rax]   ; 첫 번째 바이트 로드
    mov [r10 + rax], rcx          ; num_string에 저장
    inc rax
    jmp word_loop
done:
    pop rcx
    pop rax
    ret
done_:
    ret
   
back:
    add r12, r9 ; 남은 문자 개수
    ret
out:
    mov rsi, 1
    print_int rsi
    mov rax, 60   ; 시스템 종료
    xor rdi, rdi
    syscall