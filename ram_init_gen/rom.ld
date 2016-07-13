SECTIONS
{
    . = 0x00000100;
    .text : AT(0x00000100) { *(.text) }
    .data : { *(.data) }
    .bss : { *(.bss) }
    stack_top = .;
}
