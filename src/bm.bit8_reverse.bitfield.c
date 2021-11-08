#include <stdint.h>
#include <string.h>
#include <assert.h>
#include <utils.h>

uint8_t bit8_reverse(const uint8_t u8){
  struct __attribute__((packed)) b8 {
    unsigned b0 : 1;
    unsigned b1 : 1;
    unsigned b2 : 1;
    unsigned b3 : 1;
    unsigned b4 : 1;
    unsigned b5 : 1;
    unsigned b6 : 1;
    unsigned b7 : 1;
  };
  static_assert(sizeof(struct b8) == sizeof(uint8_t));
  struct b8 in;
  memcpy(&in, &u8, 1);
  const struct b8 out = {
    .b0 = in.b7,
    .b1 = in.b6,
    .b2 = in.b5,
    .b3 = in.b4,
    .b4 = in.b3,
    .b5 = in.b2,
    .b6 = in.b1,
    .b7 = in.b0,
  };
  uint8_t res;
  memcpy(&res, &out, 1);
  return res;
}
