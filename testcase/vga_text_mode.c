#define VMEM ((char *)0xc0000000)
#define HEIGHT 160
#define WIDTH 128
#define SCROLL_SIZE  21504 // WIDTH * (HEIGHT - 1)

static int curr_line = 0;
static int curr_col = 0;

void npc_putc(char ch)
{
    // Backup the global vars to avoid async side-effects,
    // which may make (line * WIDTH + col) exceed buffer boundary.
    int local_line = curr_line;
    int local_col = curr_col;

    if (local_line == HEIGHT) {
        // No line for print, it is time to scroll ;-)
        char *dst = VMEM;
        char *src = VMEM + WIDTH;
        for (int i = 0; i < SCROLL_SIZE; i++) {
            *dst++ = *src++;
        }
        for (int i = 0; i < WIDTH; i++) {
            *dst++ = ' ';
        }
        local_line--;
    }

    char *ws_pos = VMEM + local_col;
    for (int i = 0; i < local_line; i++) ws_pos += WIDTH;
    if (ch == '\n') {
        // Use space to mimic new line
        while (local_col < WIDTH) {
            *ws_pos++ = ' ';
            local_col++;
        }
    }
    else {
        *ws_pos = ch;
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

int main()
{
    npc_puts("Hello, World!\n");
    npc_puts("Foo Bar\n");
    return 0;
}
