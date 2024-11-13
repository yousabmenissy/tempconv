.macro strcmp src, dst, len, loc
    leaq \src, %rsi
    movq \dst, %rdi
    movq \len, %rcx

    repe cmpsb
    je   \loc
.endm
