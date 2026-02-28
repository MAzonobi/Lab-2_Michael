.section .data
prompt1: .ascii "Enter first string: "
prompt1len = . - prompt1
prompt2: .ascii "Enter second string: "
prompt2len = . - prompt2
outmsg: .ascii "Hamming distance: "
outlen = . - outmsg
nl: .ascii "\n"

.section .bss
.lcomm buf1, 256
.lcomm buf2, 256
.lcomm numbuf, 32

.section .text
.global _start
_start:
    mov $1, %rax
    mov $1, %rdi
    mov $prompt1, %rsi
    mov $prompt1len, %rdx
    syscall

    mov $0, %rax
    mov $0, %rdi
    mov $buf1, %rsi
    mov $255, %rdx
    syscall
    mov %rax, %r12

    mov $1, %rax
    mov $1, %rdi
    mov $prompt2, %rsi
    mov $prompt2len, %rdx
    syscall

    mov $0, %rax
    mov $0, %rdi
    mov $buf2, %rsi
    mov $255, %rdx
    syscall
    mov %rax, %r13

    mov %r12, %rax
    cmp $0, %rax
    jle len1_done
    mov %r12, %rcx
    dec %rcx
    movb buf1(,%rcx,1), %dl
    cmp $10, %dl
    jne len1_done
    dec %r12
len1_done:

    mov %r13, %rax
    cmp $0, %rax
    jle len2_done
    mov %r13, %rcx
    dec %rcx
    movb buf2(,%rcx,1), %dl
    cmp $10, %dl
    jne len2_done
    dec %r13
len2_done:

    mov %r12, %rbx
    cmp %r13, %rbx
    jle have_min
    mov %r13, %rbx
have_min:

    xor %r14, %r14
    xor %r15, %r15

loop_i:
    cmp %rbx, %r15
    jge done_calc

    movzbq buf1(,%r15,1), %rax
    movzbq buf2(,%r15,1), %rcx
    xor %rcx, %rax

    xor %r8, %r8
pop_loop:
    test %rax, %rax
    jz pop_done
    lea -1(%rax), %rdx
    and %rdx, %rax
    inc %r8
    jmp pop_loop
pop_done:
    add %r8, %r14

    inc %r15
    jmp loop_i

done_calc:
    mov $1, %rax
    mov $1, %rdi
    mov $outmsg, %rsi
    mov $outlen, %rdx
    syscall

    lea numbuf(%rip), %rsi
    add $31, %rsi
    movb $0, (%rsi)

    mov %r14, %rax
    cmp $0, %rax
    jne conv_loop
    dec %rsi
    movb $'0', (%rsi)
    jmp conv_done

conv_loop:
    xor %rdx, %rdx
    mov $10, %rcx
    div %rcx
    add $'0', %dl
    dec %rsi
    mov %dl, (%rsi)
    cmp $0, %rax
    jne conv_loop

conv_done:
    lea numbuf(%rip), %rdx
    add $31, %rdx
    sub %rsi, %rdx

    mov $1, %rax
    mov $1, %rdi
    syscall

    mov $1, %rax
    mov $1, %rdi
    mov $nl, %rsi
    mov $1, %rdx
    syscall

    mov $60, %rax
    xor %rdi, %rdi
    syscall