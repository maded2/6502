; vasm -Fbin -dotdir src/v9958_test/test.asm


VDP = $8400

VPORT1   = VDP
VPORT2   = VDP + 1
VPORT3   = VDP + 2
VPORT4   = VDP + 3

R0 = %10000000
R1 = %10000001
R2 = %10000010
R3 = %10000011
R4 = %10000100
R5 = %10000101
R6 = %10000110
R7 = %10000111
R8 = %10001000
R9 = %10001001


    .org $5000
    nop

init:
    lda #$0E
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$80
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$40
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$81
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$0A
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$88
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$88
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$89
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$F0  ; $11
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$87
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$1F
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$82
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$00
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #$40
    sta VPORT2
    lda #1
    jsr DELAY_ms

    ldy #0
loop:
    ldx #0
loop2:
    txa
    sta VPORT1
    lda #1
    jsr DELAY_ms

		inx
		bne loop2
		lda $10
		adc $11
		sta $00
		iny
		tya
		cmp #211
		bne loop
		rts





DELAY_ms:
    sta $ff
    tya
    pha
    txa
    pha

    lda $ff
    tay             ; (2 cycles)
    ldx  #143       ; (2 cycles)
delay2:
    nop              ; (2 cycles)
    dex              ; (2 cycles)
    bne  delay2       ; (3 cycles in loop, 2 cycles at end)
    dey              ; (2 cycles)
    bne  delay2       ; (3 cycles in loop, 2 cycles at end)

    pla
    tax
    pla
    tay
    rts
