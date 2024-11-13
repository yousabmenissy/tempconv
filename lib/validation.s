.global validation
.type validation, @function
validation:
	pushq %rbp
	movq  %rsp, %rbp
	pushq %rbx
	pushq %rsi

    xor  %rax, %rax
	movq %rdi, %rsi
	movq %rcx, %rcx

sectionV0:
    lodsb

    cmpb   $0, %al
	je 	   exit_invalid
    cmpb $'.', %al
    cmove %rcx, %rbx
	cmpb $'-', %al
	je   .LPV0
	cmpb $'0', %al
	jb   exit_invalid
	cmpb $'9', %al
	ja   exit_invalid

    jmp .LPV0

sectionV1:
	cmpq %rcx, %rbx
	je   exit_invalid
	movq %rcx, %rbx

.LPV0:
    lodsb
	cmpb   $0, %al
	je 	   exit_valid

    cmpb $'-', %al
	je   exit_invalid
    cmpb $'.', %al
	je   sectionV0
  	cmpb $'0', %al
	jb   exit_invalid
	cmpb $'9', %al
	ja   exit_invalid

	jmp .LPV0

exit_invalid:
    movq $-1, %rax
    popq %rbx
    leave
    ret

exit_valid:
	movq $0, %rax
	popq %rbx
    leave
    ret
