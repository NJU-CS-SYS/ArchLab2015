#ifndef __MY_STDIO_H__
#define __MY_STDIO_H__

#define VMEM ((char *)0xc0000000)

void npc_putc(char ch);

void npc_puts(const char *s);

inline void putc(char c, char *addr) {
    *addr = c;
}

void put_hex(unsigned int x, char *addr);


#endif
