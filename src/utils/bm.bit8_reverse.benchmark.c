#include <utils.h>
#include <stdio.h>
#include <time.h>

__attribute__((noinline)) static void benchmark(void){
  volatile uint8_t result;
  for(int i=0x3000000; i; i--){
    result = bit8_reverse(i);
  }
  (void)result;
}

int main(void){
  clock_t a = clock();
  benchmark();
  clock_t b = clock();
  printf("%f\n", (double)(b - a) / CLOCKS_PER_SEC);
}
