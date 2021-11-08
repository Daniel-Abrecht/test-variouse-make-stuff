#include <hello.h>
#include <utils.h>
#include <stdio.h>

int main(){
  say_hello();
  hello_arch();
  if(hello_asm) hello_asm();
  printf("0x%02x -> 0x%02x\n", 0x01, bit8_reverse(0x01));
}
