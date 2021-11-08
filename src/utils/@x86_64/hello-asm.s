.str_asm_hello:
        .string "Hello using x86_64 asm"

.global hello_asm
hello_asm:
        pushq   %rbp
        movq    %rsp, %rbp
        leaq    .str_asm_hello(%rip), %rax
        movq    %rax, %rdi
        call    puts@PLT
        nop
        popq    %rbp
        ret
