#ifndef __MY_STDIO_H__
#define __MY_STDIO_H__

#define VMEM ((char *)0xc0000000)

#define KEY_CODE_ADDR ((volatile unsigned int *)0xe0000000)
#define KEY_CODE (*KEY_CODE_ADDR)

void npc_putc(char ch);

void npc_puts(const char *s);

inline void putc(char c, char *addr) {
    *addr = c;
}

void put_hex(unsigned int x, char *addr);

void print_hex(unsigned int x);

char npc_getc();

#endif
