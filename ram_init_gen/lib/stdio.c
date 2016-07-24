#include <stdio.h>

#define HEIGHT 135
#define WIDTH 240

#define SCROLL *(volatile int *)(0xcf000000)
#define SCROLL_ADDR ((char *)(VMEM + (HEIGHT - 1) * WIDTH))

int curr_line = 0;
int curr_col = 0;
char *pos = (char *)VMEM;

int npc_putc(char ch)
{
    // Backup the global vars to avoid async side-effects,
    // which may make (line * WIDTH + col) exceed buffer boundary.
    int local_line = curr_line;
    int local_col = curr_col;

    if (ch == '\n') {
        if (local_line >= HEIGHT - 1) {
            SCROLL = 1;
            local_line = HEIGHT - 1;
            for (int i = 0; i < WIDTH; i++) SCROLL_ADDR[i] = ' ';
            pos = SCROLL_ADDR;
        }
        else {
            local_line++;
            pos = pos + WIDTH - local_col;
        }
        local_col = 0;
    }
    else {
        if (local_line == HEIGHT) {
            // wrap into a new line.
            SCROLL = 1;
            local_line = HEIGHT - 1;
            for (int i = 0; i < WIDTH; i++) SCROLL_ADDR[i] = ' ';
            pos = SCROLL_ADDR;
        }

        *pos++ = ch;
        local_col++;

        // non-scrolling common wrap
        if (local_col == WIDTH) {
            local_line++;
            // pos is rightly at the begin of the next line.
            local_col = 0;
        }
    }

    curr_line = local_line;
    curr_col = local_col;

    return (unsigned char)ch;
}

void npc_puts(const char *s)
{
    while (*s != '\0') {
        npc_putc(*s++);
    }
    npc_putc('\n');
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

static char hex_literals[] = "0123456789abcdef";
#define digit(val, offset) (((val) & (0xfu << ((offset) << 2))) >> ((offset) << 2))

void print_hex(unsigned int x)
{
    npc_putc(hex_literals[ digit(x, 7) ]);
    npc_putc(hex_literals[ digit(x, 6) ]);
    npc_putc(hex_literals[ digit(x, 5) ]);
    npc_putc(hex_literals[ digit(x, 4) ]);
    npc_putc(hex_literals[ digit(x, 3) ]);
    npc_putc(hex_literals[ digit(x, 2) ]);
    npc_putc(hex_literals[ digit(x, 1) ]);
    npc_putc(hex_literals[ digit(x, 0) ]);
}

// Enumeration for unprintable keys
enum {
    KB_ESC = 128,
    KB_F1, KB_F2, KB_F3, KB_F4, KB_F5, KB_F6,
    KB_F7, KB_F8, KB_F9, KB_F10, KB_F11, KB_F12,
    KB_SHIFT_L, KB_SHIFT_R,
    KB_CTRL, KB_ALT,
    KB_UP, KB_DOWN, KB_LEFT, KB_RIGHT,
    KB_CAPS,
};

static char keycodemap[] = {
    [0x76] = KB_ESC,
    [0x05] = KB_F1,
    [0x06] = KB_F2,
    [0x04] = KB_F3,
    [0x0C] = KB_F4,
    [0x03] = KB_F5,
    [0x0B] = KB_F6,
    [0x83] = KB_F7,
    [0x0A] = KB_F8,
    [0X01] = KB_F9,
    [0X09] = KB_F10,
    [0X78] = KB_F11,
    [0X07] = KB_F12,
    [0X0E] = '`',
    [0X16] = '1',
    [0X1E] = '2',
    [0X26] = '3',
    [0X25] = '4',
    [0X2E] = '5',
    [0X36] = '6',
    [0X3D] = '7',
    [0X3E] = '8',
    [0X46] = '9',
    [0X45] = '0',
    [0x4E] = '-',
    [0x55] = '=',
    [0x0D] = ' ',
    [0x15] = 'q',
    [0x1D] = 'w',
    [0x24] = 'e',
    [0x2D] = 'r',
    [0x2C] = 't',
    [0x35] = 'y',
    [0x3C] = 'u',
    [0x43] = 'i',
    [0x44] = 'o',
    [0x4D] = 'p',
    [0x54] = '[',
    [0x5B] = ']',
    [0x5D] = '\\',
    [0x58] = KB_CAPS,
    [0x1C] = 'a',
    [0x1B] = 's',
    [0x23] = 'd',
    [0x2B] = 'f',
    [0x34] = 'g',
    [0x33] = 'h',
    [0x3B] = 'j',
    [0x42] = 'k',
    [0x4B] = 'l',
    [0x4C] = ';',
    [0x52] = '\'',
    [0x5A] = '\n',
    [0x12] = KB_SHIFT_L,
    [0x1A] = 'z',
    [0x22] = 'x',
    [0x21] = 'c',
    [0x2A] = 'v',
    [0x32] = 'b',
    [0x31] = 'n',
    [0x3A] = 'M',
    [0x41] = ',',
    [0x49] = '.',
    [0x4A] = '/',
    [0x59] = KB_SHIFT_R,
    [0x14] = KB_CTRL,
    [0x11] = KB_ALT,
    [0x29] = ' ',
    [0x75] = KB_UP,
    [0x6B] = KB_LEFT,
    [0x72] = KB_DOWN,
    [0x74] = KB_RIGHT
};

static int is_capslock = 0;

static inline char get_keycode()
{
    unsigned int keycode = KEY_CODE;
    return (keycode == 0xf0u) ? (char)keycode : keycodemap[keycode];
}

char npc_getc()
{
    char ch = get_keycode();
    if (ch == (char)0xf0) {
        ch = get_keycode();
        if (ch == KB_CAPS) {
            is_capslock = 0;
        }
        return npc_getc();
    }
    else if (ch == KB_CAPS) {
        is_capslock = 1;
        return npc_getc();
    }
    else {
        return ch;
    }
}

/**
 * Get a string, terminated by '\n' (included).
 *
 * FIXME: This function does not focus on safety
 *        so it does not check buffer boundary
 */
void npc_gets(char *buf)
{
    for (;;) {
        char ch = npc_getc();
        npc_putc(ch);
        *buf++ = ch;
        if (ch == '\n') {
            break;
        }
    }
    *buf = '\0';
}
