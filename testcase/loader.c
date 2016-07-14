#include <stdio.h>

/* 0xc000 0000  : VMEM
 * 0x0          : cache + ddr
 * 0xb000 0000  : flash
 */

#define deref(x) *((volatile unsigned int *) (x))

#define PROG_MEM_BEGIN   0x00000100
#define PROG_MEM_END     0x00008000
#define PROG_FLAHS_BEGIN 0xb0000000

#define screen_width 160

char* vga = VMEM + screen_width * 2 + 5;

// #define start_addr 0xf0000000
#define start_addr 0

int main() {
  // Copy data flash from flash to memory.
  unsigned int addr = PROG_MEM_BEGIN;
  unsigned int flash_addr = PROG_FLAHS_BEGIN;
  deref(addr) = deref(flash_addr);  // Workaround the 1st-read failure
  for(; addr < PROG_MEM_END; addr += 4) {
    deref(addr) = deref(flash_addr);
    flash_addr += 4;
    *vga++ = '.';
  }

  // Check whether the copy is correct.
  addr = PROG_MEM_BEGIN;
  flash_addr = PROG_FLAHS_BEGIN;
  deref(addr) = deref(flash_addr);  // Workaround the 1st-read failure
  for(; addr < PROG_MEM_END; addr += 4) {
    unsigned int want = deref(flash_addr);
    unsigned int real = deref(addr);
    if (addr < PROG_MEM_BEGIN + 32) {
      printf("0x%08x: flash %08x -> ddr %08x\n", addr, want, real);
    }
    if (want != real) {
      printf("0x%08x: flash %08x -> ddr %08x\n", addr, want, real);
      printf(" error");
      for (;;) {}
    }
    flash_addr += 4;
  }

  // Use keyboard to confirm the execution of program.
  printf("Memory Check OK!\n");
  getchar();
  asm volatile("li $ra, 0x00000100; jr $ra");
  return 0;
}
