#include <stdio.h>

/* 0xc000 0000  : VMEM
 * 0x0          : cache + ddr
 * 0xb000 0000  : flash
 */

#define deref(x) *((volatile unsigned int *) (x))

#define PROG_MEM_BEGIN   0x00000100
#define PROG_MEM_END     0x00008000
#define PROG_FLAHS_BEGIN 0xb0000000

#define _S(x) # x
#define S(x) _S(x)

int main() {
  // Copy data flash from flash to memory.
  unsigned int addr = PROG_MEM_BEGIN;
  unsigned int flash_addr = PROG_FLAHS_BEGIN;
  deref(addr) = deref(flash_addr);  // Workaround the 1st-read failure
  for(; addr < PROG_MEM_END; addr += 4) {
    deref(addr) = deref(flash_addr);
    if (deref(addr) != deref(flash_addr)) {
        printf("0x%08x: write error flash %08x -> ddr %08x\n", addr, deref(flash_addr), deref(addr));
        // Why not use local variables to save the deref result?
        // Because this can detect whether a later access can be correct.
        // (When this branch is taken but the output seems correct.)
        for (;;) {}
    }
    flash_addr += 4;
  }

  // Check whether the copy is correct.
  addr = PROG_MEM_BEGIN;
  flash_addr = PROG_FLAHS_BEGIN;
  deref(addr) = deref(flash_addr);  // Workaround the 1st-read failure
  for(; addr < PROG_MEM_END; addr += 4) {
    unsigned int want = deref(flash_addr);
    unsigned int real = deref(addr);
    if (want != real) {
      printf("0x%08x: flash %08x -> ddr %08x", addr, want, real);
      printf("\n");
      printf(" error");
      for (;;) {}
    }
    flash_addr += 4;
  }

  // Use keyboard to confirm the execution of program.
  printf("Memory Check OK!\n");
  getchar();
  asm volatile("li $ra, "  S(PROG_MEM_BEGIN) "; jr $ra");
  return 0;
}
