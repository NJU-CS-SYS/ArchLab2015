#define VMEM ((char *)0xc0000000)

/* 0xc000 0000  : VMEM
 * 0x0          : cache + ddr
 * 0xb000 0000  : flash
 */

#define deref(x) *((volatile unsigned int *) (x))

#define screen_width 160

char* vga = VMEM + screen_width*2 + 5;

int main() {
  unsigned int addr = 0xf0000100;
  unsigned int flash_addr = 0xb0000000;
  deref(addr) = deref(flash_addr);
  for(; addr < 0xf0008000; addr += 4) {
    deref(addr) = deref(flash_addr);
    flash_addr += 4;
    *vga++ = '.';
  }

  asm volatile("li $ra, 0xf0000100; jr $ra");
  return 0;
}
