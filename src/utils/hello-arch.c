#include <stdio.h>
#include <hello.h>

__attribute__((weak)) void hello_arch(void){
  puts("Generic Hello");
}
