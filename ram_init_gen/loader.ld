SECTIONS
{
    . = 0xf0000000;
    .text : AT(0xf0000000) { *(.text) }
    .data : { *(.data) }
    .bss : { *(.bss) }
    stack_top = .;
}
