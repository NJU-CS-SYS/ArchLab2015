ENTRY(_reset)
SECTIONS
{
    . = 0xf0000000;
    PROVIDE(_reset = .);
    .text : AT(0xf0000000) { *(.text) }
    .data : { *(.data) }
    .bss : { *(.bss) }
    . = . + 0x1000; /* 4kB of stack memory */
    stack_top = .;
}
