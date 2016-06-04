#include "inc/debug.h"
#include "inc/stdio.h"


#define deref(x) *((volatile unsigned int *) (x))
#define screen_width 160
#define start_reg (0xdc000004)
#define end_reg (0xdc000008)


int main() {
  char* vga = VMEM + screen_width*2 + 5;
  unsigned val = 0xffff0001;
  unsigned addr = 0;
  unsigned addr_step = 0x800;
  unsigned K0, K1, K2, K3;
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
      if (end < start) {
        end += 64;  // round up
      }
      put_hex(start, vga);
      put_hex(end, vga + 16);
      vga += screen_width/5;
      for (unsigned j = (start << 4); j <= (end << 4); j += 16) {
        K0 = deref(0xd0000000 | j | (0 << 2));
        K1 = deref(0xd0000000 | j | (1 << 2));
        K2 = deref(0xd0000000 | j | (2 << 2));
        K3 = deref(0xd0000000 | j | (3 << 2));

        put_hex(K0, vga);
        vga += screen_width/10;
        put_hex(K1, vga);
        vga += screen_width/10;
        put_hex(K2, vga);
        vga += screen_width/10;
        put_hex(K3, vga);
        vga += screen_width/10;
      }
      vga += screen_width*2;
      break;
    }
    addr += addr_step;
  }
  deref(0xdddd0000) = 0;
  return 0;
}
