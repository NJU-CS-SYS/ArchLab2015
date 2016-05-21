// store a variable on stack and check

#include "trap.h"
#include "stdio.h"

#define VMEM ((char *)0xc0000000)

/* 0xc000 0000  : VMEM
 * 0x0          : cache + ddr
 */

#define lsb0 0x0
#define lsb1 0x2a0
#define lsb2 0x7e0

#define value1 0xc5c5c5c5
#define value2 0xf0f0f0f0
#define value3 0x84848484
#define value4 0x93939393

#define deref(x) *((unsigned int *) (x))

char* vga = VMEM + 420 + 80;

__attribute__((noinline)) void check(unsigned int mem, unsigned int expected_val) {
    if(mem == expected_val) {
        putc('Y', vga);
    }
    else {
        putc('N', vga);
        put_hex(mem, vga + 2);
        put_hex(expected_val, vga + 14);
        vga += 210;
    }
}

volatile int gx = value3;
volatile int gy = value3;

int main() {
    volatile int x = value1;
    volatile int y = value1;
    check(gx, value3);
    check(gy, value3);
    check(x, value1);
    check(y, value1);
    good();
    return 0;
}
