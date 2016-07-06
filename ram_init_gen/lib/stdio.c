#include <stdio.h>

#define HEIGHT 128
#define WIDTH 160
#define SCROLL_SIZE  20320 // WIDTH * (HEIGHT - 1)

static int curr_line = 0;
static int curr_col = 0;

// Record all characters in text buffer in favor of scrolling.
// 160 * 128 = 20KB
static char scroll_buffer[WIDTH * HEIGHT];

void npc_putc(char ch)
{
    // Backup the global vars to avoid async side-effects,
    // which may make (line * WIDTH + col) exceed buffer boundary.
    int local_line = curr_line;
    int local_col = curr_col;

    if (local_line == HEIGHT) {
        // No line for print, it is time to scroll ;-)
        char *dst = VMEM;
        char *buf = scroll_buffer;
        char *src = scroll_buffer + WIDTH;
        for (int i = 0; i < SCROLL_SIZE; i++) {
            *dst++ = *src;
            *buf++ = *src++;
        }
        for (int i = 0; i < WIDTH; i++) {
            *dst++ = ' ';
        }
        local_line--;
    }

    char *ws_pos = VMEM + local_col;
    for (int i = 0; i < local_line; i++) ws_pos += WIDTH;
    char *bk_pos = scroll_buffer + (ws_pos - VMEM);
    if (ch == '\n') {
        // Use space to mimic new line
        while (local_col < WIDTH) {
            *ws_pos++ = ' '; *bk_pos++ = ' ';
            local_col++;
        }
    }
    else {
        *ws_pos = ch; *bk_pos = ch;
        local_col++;
    }

    if (local_col == WIDTH) {
        local_line++;
        local_col = 0;
    }

    curr_line = local_line;
    curr_col = local_col;
}

void npc_puts(const char *s)
{
    while (*s != '\0') {
        npc_putc(*s++);
    }
}

__attribute__((noinline)) void put_hex(unsigned int x, char *addr) {
    int i;
    *addr++ = '0';
    *addr++ = 'x';
    for (i = 0; i < 8; i++) {
        unsigned int val = (x >> ((7 - i) << 2)) & 0xf;
        if (val >= 16) {
            *addr++ = '?';
        }
        else if (val < 10) {
            *addr++ = ((char) val) + '0';
        }
        else {
            *addr++ = ((char) val) - 10 + 'a';
        }
    }
}
