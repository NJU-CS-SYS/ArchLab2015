#include "trap.h"
#include "stdio.h"

#define VMEM ((char *)0xc0000000)

/* 0xc000 0000  : VMEM
 * 0x0          : cache + ddr
 */

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

int main() {
  put_hex(deref(0xb0000000), vga);
  vga += screen_width;
  for (unsigned int pointer = 0xb0000000; pointer <= 0xb0000400; pointer += 4) {
    put_hex(deref(pointer), vga);
    vga += screen_width/10;
  }
  return 0;
}
