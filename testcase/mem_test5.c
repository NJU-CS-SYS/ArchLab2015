#include "trap.h"
#include "stdio.h"

#define VMEM ((char *)0xc0000000)

/* 0xc000 0000  : VMEM
 * 0x0          : cache + ddr
 */

#define lsb0 0x0
#define lsb1 0x2a0
#define lsb2 0x7e0

#define deref(x) *((unsigned int *) (x))

char* vga = VMEM + 420 + 80;

void check(unsigned int mem, unsigned int expected_val) {
    if(mem == expected_val) {
        putc('Y', vga);
        vga += 210;
    }
    else {
        putc('N', vga);
        put_hex(mem, vga + 2);
        put_hex(expected_val, vga + 14);
        vga += 210;
    }
}

int main() {
    volatile unsigned int pointer = 0x0;
    unsigned int step = 0x800;
    int value[4] = { 0xc5c5c5c5, 0xf0f0f0f0, 0x84848484, 0x93939393};

    int i, j;
    for (j = 0; j < 8; j++) {
        for (i = 0; i < 8; i++) {
            deref((pointer + j*step + 4*i) | lsb0) = value[(i+j)%4];
            check(deref((pointer + j*step + 4*i) | lsb0), value[(i+j)%4]);
        }
    }
    // when j become 2 or 3 above, first two data blocks are written back;
    // so codes below will test whether they have been written back correctly
    // by read them again.
    for (j = 0; j < 6; j++) {
        for (i = 0; i < 8; i++) {
            check(deref((pointer + j*step + 4*i) | lsb0), value[(i+j)%4]);
        }
    }
    for (j = 0; j < 6; j++) {
        for (i = 0; i < 8; i++) {
            check(deref((pointer + j*step + 4*i) | lsb0), value[(i+j)%4]);
        }
    }


    good();
    return 0;
}
