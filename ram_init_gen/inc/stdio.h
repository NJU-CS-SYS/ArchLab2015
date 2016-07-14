#ifndef __MY_STDIO_H__
#define __MY_STDIO_H__

#define VMEM ((char *)0xc0000000)

#define KEY_CODE_ADDR ((volatile unsigned int *)0xe0000000)
#define KEY_CODE (*KEY_CODE_ADDR)

extern volatile int curr_line;
extern volatile int curr_col;

int npc_putc(char ch);

void npc_puts(const char *s);

void put_hex(unsigned int x, char *addr);

void print_hex(unsigned int x);

char npc_getc();

int printf(const char *format, ...);

int sprintf(char *out, const char *format, ...);

#define snprintf(out, n, fmt, ...) \
    sprintf(out, fmt, ## __VA_ARGS__)

#define fprintf(fd, fmt, ...) \
    printf(fmt, ## __VA_ARGS__)

#define fflush(...)

#define getchar npc_getc

#define puts npc_puts

#define putc(ch, file) npc_putc(ch)

#define putchar npc_putc

void npc_gets(char *buf);

#define fgets(buf, ...) npc_gets(buf)

#define NULL ((void *)0)

#endif
