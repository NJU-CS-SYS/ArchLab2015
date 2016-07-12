ENTRY(main)
SECTIONS
{
    . = 0xf0000000;
    PROVIDE(main = .);
    .text : AT(0xf0000000) { *(.text) }
    .data : { *(.data) }
    .bss : { *(.bss) }
    . = . ; /* 4kB of stack memory */
    stack_top = .;
}
