#include <stdio.h>

int main()
{
    curr_line = 0;
    curr_col = 0;
    for (;;) {
        npc_puts("nemu> ");
        for (;;) {
            char ch = npc_getc();
            npc_putc(ch);
            if (ch == 'q') {
                return 0;
            } else if (ch == '\n') {
                break;
            }
        }
    }
    return 0;
}
