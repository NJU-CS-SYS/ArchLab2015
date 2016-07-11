#include <stdio.h>

int main()
{
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
