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

void check(unsigned int mem, unsigned int expected_val) {
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

int main() {
    volatile unsigned int pointer = 0x0;
    unsigned int step = 0x800;

    deref((pointer + 0*step) | lsb0) = value1;
    deref((pointer + 1*step) | lsb0) = value2;

    check(deref((pointer + 0*step) | lsb0), value1);
    check(deref((pointer + 1*step) | lsb0), value2);

    deref((pointer + 2*step) | lsb0) = value3;

    check(deref((pointer + 0*step) | lsb0), value1);

    deref((pointer + 3*step) | lsb0) = value4;

    check(deref((pointer + 0*step) | lsb0), value1);
    check(deref((pointer + 1*step) | lsb0), value2);
    check(deref((pointer + 2*step) | lsb0), value3);
    check(deref((pointer + 3*step) | lsb0), value4);

    pointer += 4*step;

    deref((pointer + 0*step) | lsb1) = value1;
    deref((pointer + 1*step) | lsb1) = value2;
    deref((pointer + 2*step) | lsb1) = value3;
    deref((pointer + 3*step) | lsb1) = value4;

    check(deref((pointer + 0*step) | lsb1), value1);
    check(deref((pointer + 1*step) | lsb1), value2);
    check(deref((pointer + 2*step) | lsb1), value3);
    check(deref((pointer + 3*step) | lsb1), value4);

    pointer += 4*step;

    deref((pointer + 0*step) | lsb2) = value1;
    deref((pointer + 1*step) | lsb2) = value2;
    deref((pointer + 2*step) | lsb2) = value3;
    deref((pointer + 3*step) | lsb2) = value4;

    check(deref((pointer + 0*step) | lsb2), value1);
    check(deref((pointer + 1*step) | lsb2), value2);
    check(deref((pointer + 2*step) | lsb2), value3);
    check(deref((pointer + 3*step) | lsb2), value4);

    good();
    return 0;
}
