#ifndef __MY_STDIO_H__
#define __MY_STDIO_H__

inline void putc(char c, char *addr) {
    *addr = c;
}

void put_hex(unsigned int x, char *addr);


#endif
