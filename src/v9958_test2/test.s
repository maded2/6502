; vasm -Fbin -dotdir src/v9958_test2/test.asm


VDP = $8400

VPORT0   = VDP
VPORT1   = VDP + 1
VPORT2   = VDP + 2
VPORT3   = VDP + 3

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
R10 = %10001010
R11 = %10001011
R12 = %10001100
R13 = %10001101
R14 = %10001110

.macro outport value,register
    lda #value
    sta VPORT1
    lda #1
    jsr DELAY_ms

    lda #register
    sta VPORT1
    lda #1
    jsr DELAY_ms
.endmacro

.macro outchar value
    lda #value
    sta VPORT0
    lda #1
    jsr DELAY_ms
.endmacro

	.segment "CODE"
  nop


init
;		outport $0E,R0
;		outport $40,R1
;		outport $0A,R8
;		outport $88,R9
;		outport $11,R7
;		outport $1F,R2
;
;		outport $00,$40
;
;    ldy #0
;loop
;    ldx #0
;loop2
;    txa
;    sta VPORT0
;    lda #1
;    jsr DELAY_ms
;
;		inx
;		bne loop2
;		lda $10
;		adc $11
;		sta $00
;		iny
;		tya
;		cmp #211
;		bne loop
;
;		rts


		outport $04,R0
		outport $50,R1
		outport $00,R2
		outport $0A,R8
		outport $00,R9  ; 192 vertical dot, no interlace
		outport $01,R4
		outport $F0,R7

		outport $00,R14
		outport $00,$48

		LDA	#<CHARS	;Get low offset
		STA $20
		LDA	#>CHARS	;Get high offset
		STA $21

loop3
		LDY #$00
		LDA ($20),Y
		CMP #$88
		BEQ endloop

    sta VPORT0
    lda #2
    jsr DELAY_ms

    inc $20
    bne loop3
    inc $21

		JMP loop3
endloop

		outport $00,R14
		outport $00,$40
loop4

    ldx #0
loop5
		outchar 40
		outchar 37
		outchar 44
		outchar 44
		outchar 47
		outchar 00
		outchar 33+22
		outchar 47
		outchar 33+17
		outchar 44
		outchar 33+3
		outchar 00
		outchar 00
		inx
		txa
		cmp #148
		beq loop6
		jmp loop5
loop6
		rts


DELAY_ms
    sta $ff
    tya
    pha
    txa
    pha

    lda $ff
    tay             ; (2 cycles)
    ldx  #100       ; (2 cycles)
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



	.include "patterns.s"






