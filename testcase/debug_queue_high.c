#include "inc/debug.h"
#include "inc/stdio.h"


#define deref(x) *((volatile unsigned int *) (x))
#define screen_width 160
#define start_reg (0xdc000004)
#define end_reg (0xdc000008)


int main() {
  char* vga = VMEM + screen_width*2 + 5;
  unsigned val = 0xffff0001;
  unsigned addr = 20;
  unsigned addr_step = 0x800;
  union debug_que_entry dqe;
  for (int i = 0; i < 6; ++i) {
    deref(addr) = val;
    val += 1;
    addr += addr_step;
  }

  addr = 20;
  val = 0xffff0001;
  for (int i = 0; i < 6; ++i) {
    unsigned test_read = deref(addr);
    if (test_read != val) {
      putc('N', vga);
      vga += 2;
      put_hex(addr, vga);
      put_hex(test_read, vga + 16);
      unsigned start = deref(start_reg);
      unsigned end = deref(end_reg);
      if (end < start) {
        end += 64;  // round up
      }
      put_hex(start, vga + 32);
      put_hex(end, vga + 48);
      vga += 2*screen_width;

      for (unsigned j = 0; j < (64 << 4); j += 16) {
        dqe.part[3] = deref(0xd0000000 | j | (0 << 2));
        dqe.part[2] = deref(0xd0000000 | j | (1 << 2));
        dqe.part[1] = deref(0xd0000000 | j | (2 << 2));
        dqe.part[0] = deref(0xd0000000 | j | (3 << 2));

        put_hex(dqe.part[0], vga);
        vga += screen_width/10;
        put_hex(dqe.part[1], vga);
        vga += screen_width/10;
        put_hex(dqe.part[2], vga);
        vga += screen_width/10;
        put_hex(dqe.part[3], vga);
        vga += screen_width/10 * 7;

        if (j == (16 << 4) || j == (32 << 4) || j == (48 << 4)) {
          vga += screen_width;
        }
      }
      vga += screen_width*2;
      break;
    }
    val += 1;
    addr += addr_step;
  }
  putc('N', vga++);
  putc('I', vga++);
  putc('C', vga++);
  putc('E', vga++);
  deref(0xdddd0000) = 0;
  return 0;
}
