OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY {
    rom (rx) : ORIGIN = 0x00000000, LENGTH = 1024
    ram (rwx) : ORIGIN = 0x00000000, LENGTH = 1024
}

SECTIONS {
    .text : {
        *(.text.init)
        *(.text)
    } > rom

    .data : {
        *(.data)
        *(.sdata)
        *(.rodata)
    } > ram

    .bss : {
        *(.bss)
        *(.sbss)
        *(COMMON)
    } > ram

    /DISCARD/ : { *(.comment) *(.note) }
}
