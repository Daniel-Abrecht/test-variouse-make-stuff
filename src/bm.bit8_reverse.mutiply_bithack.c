#include <stdint.h>
#include <string.h>
#include <assert.h>
#include <utils.h>

uint8_t bit8_reverse(const uint8_t u8){
  return ((u8 * 0x80200802ULL) & 0x0884422110ULL) * 0x0101010101ULL >> 32;
}
