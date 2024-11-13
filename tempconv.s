.include "lib/printNumber.s"
.include "lib/readNumber.s"
.include "lib/validation.s"
.include "lib/basename.s"
.include "lib/sys_write.s"
.include "lib/sys_exit.s"
.include "lib/strcmp.s"

.section .data
thirty_two: .double 32.0
one_point_eight: .double 1.8
cel_str: .string "cel"
fah_str: .string "fah"

cel_postfix: .string " °C"
cel_postfix_len: .quad . - cel_postfix
fah_postfix: .string " °F"
fah_postfix_len: .quad . - fah_postfix

cel_usage: .string "Usage: cel <fah>\n"
cel_usage_len: .quad . - cel_usage
fah_usage: .string "Usage: fah <cel>\n"
fah_usage_len: .quad . - fah_usage

error: .string "error: invalid input\n"
error_len: .quad . - error

.section .text
.global _start
_start:
    movq %rsp, %rbp

section0:
    movq 8(%rbp), %rsi   # rsi hold the location of the first argument (argv[0])
    call basename       # rax now hold the string pointer of the executable name

section1:
    pushq %rax
    strcmp cel_str(%rip), %rax, $3, section2_cel

    popq %rax
    strcmp fah_str(%rip), %rax, $3, section2_fah

    jmp exit_error  # if neither is a match, hell broke lose!

section2_cel:
    cmpq $2, (%rbp)
    jne exit_usage_cel

    # fetch and validate the command-line argument
    movq 16(%rbp), %rdi   # rsi hold the location of the second argument (argv[1])
    call validation
    cmpq $0, %rax
    jne exit_error

    movq 16(%rbp), %rdi  # restore rsi after being modifies by the validation function
    call readNumber
    subsd thirty_two(%rip), %xmm0
    divsd one_point_eight(%rip), %xmm0

    movq $2, %rdi
    call printNumber

    write $1, cel_postfix(%rip), cel_postfix_len(%rip)
    writeln $1

    jmp exit_success

section2_fah:
    cmpq $2, (%rbp)
    jne exit_usage_fah

    # fetch and validate the command-line argument
    movq 16(%rbp), %rdi   # rsi hold the location of the second argument (argv[1])
    call validation
    cmpq $0, %rax
    jne exit_error

    movq 16(%rbp), %rdi  # restore rsi after being modifies by the validation function
    call readNumber
    mulsd one_point_eight(%rip), %xmm0
    addsd thirty_two(%rip), %xmm0

    movq $2, %rdi
    call printNumber

    write $1, fah_postfix(%rip), fah_postfix_len(%rip)
    writeln $1

exit_success:
    exit $0

exit_usage_cel:
    write $1, cel_usage(%rip), cel_usage_len(%rip)
    exit $-1

exit_usage_fah:
    write $1, fah_usage(%rip), fah_usage_len(%rip)
    exit $-1

exit_error:
    write $1, error(%rip), error_len(%rip)
    exit $-2

