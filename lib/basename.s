.section .text
.global basename
.type basename, @function
basename :
    pushq %rbp
    movq %rsp, %rbp
    pushq %rdi
    pushq %rsi

sectionBN0:
.LPBN0:
    lodsb
    cmpb $'/', %al
    cmove %rsi, %rdi

    cmpq $0, %rax
    je sectionBN1

    jmp .LPBN0

sectionBN1:
    movq %rdi, %rax
    popq %rsi
    popq %rdi
    leave
    ret
