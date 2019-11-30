; vasm -Fbin -dotdir src/rom1/test.asm
; minipro -p AT28C256 -w a.out

    .org $8000
    nop

    .org $c000
reset:

    lda #$50
    sta $6000

loop:
    ror
    sta $6000


        ldy  #$ff   ; (2 cycles)
delay2: ldx  #$ff   ; (2 cycles)
delay:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        dex          ; (2 cycles)
        bne  delay   ; (3 cycles in loop, 2 cycles at end)
        dey          ; (2 cycles)
        bne  delay2   ; (3 cycles in loop, 2 cycles at end)


    jmp loop

    .org $fffc
    .word reset
    .word reset