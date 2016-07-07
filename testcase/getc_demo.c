#include <stdio.h>

int main()
{
    for (;;) {
        npc_puts("cmd> ");
        char ch = npc_getc();
        npc_putc(ch);
        if (ch == 'q') {
            break;
        }
    }
}
