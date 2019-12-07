; vasm -Fbin -dotdir src/rom1/test.asm
; minipro -p AT28C256 -w a.out

VIA1PB = $a000
VIA1PA = $a001

VIA1DDRB = $a002
VIA1DDRA = $a003

    .org $8000
    nop

    .org $c000
reset:
    lda #250
    jsr DELAY_ms

    lda #$ff
    sta VIA1DDRB
    sta VIA1DDRA

    jsr RST_LCD


loop:
    lda #$aa
    sta VIA1PB

    lda #250
    jsr DELAY_ms

    lda #$55
    sta VIA1PB

    lda #250
    jsr DELAY_ms
    jmp loop



    .include utils.asm
    .include lcd2.asm





    .org $fffc
    .word reset
    .word reset