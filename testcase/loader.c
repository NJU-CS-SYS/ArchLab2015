#define VMEM ((char *)0xc0000000)

/* 0xc000 0000  : VMEM
 * 0x0          : cache + ddr
 * 0xb000 0000  : flash
 */

#define deref(x) *((volatile unsigned int *) (x))

#define screen_width 160

char* vga = VMEM + screen_width*2 + 5;

// #define start_addr 0xf0000000
#define start_addr 0

int main() {
  unsigned int addr = 0x100 | start_addr;
  unsigned int flash_addr = 0xb0000000;
  deref(addr) = deref(flash_addr);
  for(; addr < (0x8000 | start_addr); addr += 4) {
    deref(addr) = deref(flash_addr);
    flash_addr += 4;
    *vga++ = '.';
  }

#if start_addr
  asm volatile("li $ra, 0xf0000100; jr $ra");
#else
  asm volatile("li $ra, 0x100; jr $ra");
#endif
  return 0;
}
