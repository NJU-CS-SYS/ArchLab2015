#include "trap.h"
#include "stdio.h"

#define VMEM ((char *)0xc0000000)

/* 0xc000 0000  : VMEM
 * 0x0          : cache + ddr
 */

#define lsb0 0x10
#define lsb1 0x2b0
#define lsb2 0x7f0

#define deref(x) *((volatile unsigned int *) (x))

#define screen_width 160

char* vga = VMEM + screen_width*2 + 5;

void check(unsigned int mem, unsigned int expected_val) {
  if(mem == expected_val) {
    putc('Y', vga);
    put_hex(mem, vga + 2);
    put_hex(expected_val, vga + 14);
    vga += screen_width/4;
  }
  else {
    putc('N', vga);
    put_hex(mem, vga + 2);
    put_hex(expected_val, vga + 14);
    vga += screen_width/4;
  }
}

void output_buffer() {
  unsigned int x;
  vga += screen_width;
  for (x = 0xdb000000; x < 0xdb000020; x += 4) {
    put_hex(deref(x), vga);
    vga += screen_width/8;
  }
  vga += screen_width;
}

int main() {
  unsigned int pointer = 0x0;
  unsigned int step = 0x800;
  //int value[4] = { 0xc5c5c5c5, 0xf0f0f0f0, 0x84848484, 0x93939393};

  int i, j;
  for (j = 0; j < 8; j++) {
    for (i = 0; i < 8; i++) {
      deref((pointer + j*step + 4*i) | lsb0) = i + j*16;
      check(deref((pointer + j*step + 4*i) | lsb0), i + j*16);
    }
  }
  vga += screen_width;
  // when j become 2 or 3 above, first two data blocks are written back;
  // so codes below will test whether they have been written back correctly
  // by read them again.
  /*
  for (j = 0; j < 8; j++) {
    for (i = 0; i < 8; i++) {
      check(deref((pointer + j*step + 4*i) | lsb0), i + j*16);
    }
    output_buffer();
  }
  vga += screen_width;

  */
  j = 0;
  for (i = 0; i < 8; i++) {
    check(deref((pointer + j*step + 4*i) | lsb0), i + j*16);
  }
  output_buffer();

  //deref(0xddd00000) = 0;
  /*
  for (j = 0; j < 8; j++) {
    for (i = 0; i < 8; i++) {
      deref((pointer + j*step + 4*i) | lsb1) = i + j*16;
      check(deref((pointer + j*step + 4*i) | lsb1), i + j*16);
    }
  }
  vga += screen_width;
  for (j = 0; j < 8; j++) {
    for (i = 0; i < 8; i++) {
      check(deref((pointer + j*step + 4*i) | lsb1), i + j*16);
    }
  }
  vga += screen_width;

  for (j = 0; j < 8; j++) {
    for (i = 0; i < 8; i++) {
      deref((pointer + j*step + 4*i) | lsb2) = i + j*16;
      check(deref((pointer + j*step + 4*i) | lsb2), i + j*16);
    }
  }
  vga += screen_width;
  for (j = 0; j < 8; j++) {
    for (i = 0; i < 8; i++) {
      check(deref((pointer + j*step + 4*i) | lsb2), i + j*16);
    }
  }
  */
  good();
  return 0;
}
