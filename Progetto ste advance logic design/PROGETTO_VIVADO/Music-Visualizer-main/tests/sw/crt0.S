.section .text.init
.global _start

_start:
    # Inizializza lo stack pointer alla fine della RAM (1024 byte)
    li sp, 1024
    
    # Salta al main
    call main

    # C-HALT: Fine simulazione
    li t0, 0xFFFFFFFC
    sw zero, 0(t0)

loop_halt:
    j loop_halt
