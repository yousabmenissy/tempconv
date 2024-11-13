.section .text

# r8 holds the integer form of the number
# r10 is the scale factor with initial value of 1
# xmm0 holds the result in decimal form
# rax holds the result in truncated integer form
.global readNumber
.type readNumber, @function
readNumber:
 	pushq   %rbp
 	movq    %rsp, %rbp
 	subq    $16, %rsp

 	pushq %r8
    pushq %r10
    pushq %r11
    xor %rax, %rax

    movq %rdi, %rsi
    lodsb

    movq $1, -8(%rbp)
    movq $1, %r10
    movq $-1, %r11

sectionRN0:
    cmpb $'-', %al
    jne .LPRN0
    movq $-1, -8(%rbp)
    lodsb
.LPRN0:
    cmpb $0, %al
    je sectionRN2
    cmpb $'.', %al
    je sectionRN1

    subq $'0', %rax
    addq %rax, %r8

    lodsb

    cmpb $0, %al
    je sectionRN2

    imul $10, %r8 # r8 *= 10
    jmp .LPRN0

sectionRN1:
    lodsb

    movq %r8, %r11
    cmpq $0, %r11
    jne .LPRN1
    addq $1, %r8
    imul $10, %r8 # r8 *= 10
.LPRN1:
    cmpb $0, %al
    je sectionRN2

    subq $'0', %rax
    addq %rax, %r8

    lodsb

    imul $10, %r10 # r10 *= 10

    cmpb $0, %al
    je sectionRN2

    imul $10, %r8  # r8 *= 10
    jmp .LPRN1

sectionRN2:
    imul        -8(%rbp), %r8

    cvtsi2sd    %r8, %xmm0
    cvtsi2sd    %r10, %xmm1
    divsd       %xmm1, %xmm0      # complete result
    cvttsd2si   %xmm0, %rax   # truncated result

    cmpq        $0, %r11
    jne         sectionRN3
    movq        $-1, %r11
    cvtsi2sd    %r11, %xmm1
    subsd       %xmm1, %xmm0

sectionRN3:
    popq %r11
    popq %r10
    popq %r8

    leave
    ret
