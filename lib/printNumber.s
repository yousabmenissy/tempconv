.section .data
digit: .ascii "0"

.section .text

# r8 is 10, the divisor
# r9 is the integer part
# r10 is the decimal part
# r11 is the multiplyer
# rdi holds number of decimal points to be printed
#	0 to truncate the decimal points
#	-1 to print all decimal points as is
.global printNumber
.type   printNumber, @function
printNumber:
	pushq %rbp
	movq  %rsp, %rbp
	subq  $16, %rsp
	movq %rdi, -8(%rbp)

	pushq %r8
	pushq %r9
	pushq %r10
	pushq %r11
	pushq %rbx
	pushq %rcx
sectionPF0:
	xor   		%rcx, %rcx            # clear rcx to be used later
	cvttsd2si 	%xmm0, %rax
	movq 		%rax, -16(%rbp)
	movq 		$1, %r11

	# cmpq $0, %rax
	testq %rax, %rax
	jns  sectionPF1

	movq 	 $-1, %rax
	cvtsi2sd %rax, %xmm1
	mulsd    %xmm1, %xmm0

sectionPF1:
	movq      $10, %r8
	cvttsd2si %xmm0, %r9
	cmpq	  $0, %rdi
	je 		  .LPPF3-3
	js 	  	  .LPPF1

	movq $10, %rax
.LPPF0:
	mul %rax
	dec %rdi
	cmpq $1, %rdi
	jne .LPPF0

	cvtsi2sd %rax, %xmm1

	mulsd 	 	%xmm1, %xmm0
	cvtsd2si 	%xmm0, %r10
	movq		%rax, %r11

	jmp sectionPF2

.LPPF1:
	cvttsd2si %xmm0, %r10     # convert into integer truncating the decimal points
	cvtsi2sd  %r10, %xmm2     # convert it back to a rounded up decimal form

	comisd    %xmm2, %xmm0     # compare to see if there is any decimal points in xmm0
	je        sectionPF2      # if the truncated value is the equal to the actual value, break the loop

	# multiply by ten and repeat
	imul  		%r8, %r11
	cvtsi2sd 	%r8, %xmm1
	mulsd 		%xmm1, %xmm0
	jmp   		.LPPF1

sectionPF2:
	movq %r9, %rax
	imul %r11, %rax
	imul $1, %r11
	addq %r11, %r10
	subq %rax, %r10

	movq %r10, %rax
	cmpq $1, %rax
	je .LPPF3-3
.LPPF2:
	cqo
	div   %r8
	addq  $'0', %rdx
	pushq %rdx
	incq  %rcx

	cmpq $1, %rax
	jne  .LPPF2

	pushq $'.'
	incq  %rcx

	movq %r9, %rax	# .LPPF3-3
.LPPF3:
	cqo
	div   %r8
	addq  $'0', %rdx
	pushq %rdx
	incq  %rcx

	cmpq $0, %rax
	jne  .LPPF3

	cmpq   $0, -16(%rbp)
	jns    sectionPF3
	pushq  $'-'
	incq   %rcx

sectionPF3:
	movq %rcx, %rbx
.LPPF4:
	popq %rax
	movb %al, digit(%rip)

	# system write to stdout
	movq $1, %rax
	movq $1, %rdi
	leaq digit(%rip), %rsi
	movq $1, %rdx
	syscall

	decq %rbx
	cmpq $0, %rbx
	jne  .LPPF4

	popq %rcx
	popq %rbx
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	leave
	ret
