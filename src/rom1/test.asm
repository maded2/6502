; vasm -Fbin -dotdir src/rom1/test.asm
; minipro -p AT28C256 -w a.out

ACIA1 = $9000
VIA1 = $a000

VIA1PB   = VIA1
VIA1PA   = VIA1 + 1
VIA1DDRB = VIA1 + 2
VIA1DDRA = VIA1 + 3

ACIA_DATA	= ACIA1
ACIA_STAT	= ACIA1 + 1
ACIA_COM	= ACIA1 + 2
ACIA_CTRL	= ACIA1 + 3

    .org $8000
    nop

    .org $c000
reset:
    lda #250
    jsr DELAY_ms

    lda #$ff
    sta VIA1DDRB
    sta VIA1DDRA

    ;jsr RST_LCD
    jmp MAIN

loop:
    lda #$aa
    sta VIA1PA
    sta VIA1PB

    lda #250
    jsr DELAY_ms

    lda #$55
    sta VIA1PA
    sta VIA1PB

    lda #250
    jsr DELAY_ms
    jmp loop



    .include utils.asm
    .include acia.asm





    .org $fffc
    .word reset
    .word reset