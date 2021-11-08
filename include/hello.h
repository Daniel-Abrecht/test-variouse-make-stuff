#ifndef HELLO_H
#define HELLO_H

void say_hello(void);
void hello_arch(void);
__attribute__((weak)) void hello_asm(void);

#endif
