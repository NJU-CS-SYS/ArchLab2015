#include "debug.h"
#include "stdio.h"


#define deref(x) *((volatile unsigned int *) (x))
#define screen_width 210
#define start_reg (0xdc000004)
#define end_reg (0xdc000008)

int main() {
  char* vga = VMEM + screen_width*2 + 5;
  unsigned val = 0xffff0001;
  unsigned addr = 0;
  unsigned addr_step = 0x800;
  for (int i = 0; i < 6; ++i) {
    deref(addr) = val;
    val += 1;
    addr += addr_step;
  }

  addr = 0;
  val = 0xffff0001;
  for (int i = 0; i < 6; ++i) {
    if (deref(addr) != val) {
      putc('N', vga++);
      unsigned start = deref(start_reg);
      unsigned end = deref(end_reg);
      put_hex(start, vga + 15);
      put_hex(end, vga + 30);
      vga += screen_width/5;
      for (unsigned j = 0xd0000000 + (start << 2);
           j <= 0xd0000000 + (end << 2); j += 4) {
        put_hex(deref(j), vga);
        vga += screen_width/10;
      }
    }
    addr += addr_step;
  }
  deref(0xdddd0000) = 0;
  return 0;
}
