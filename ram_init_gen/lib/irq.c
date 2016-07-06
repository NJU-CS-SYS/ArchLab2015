#include <stdio.h>

/**
 * irq_handle:
 *   Called when an interruption happens.
 *   For test purpose.
 */
void irq_handle()
{
    npc_puts("irq happens\n");
}
