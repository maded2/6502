
	.macro outport
    lda #\1
    sta VPORT2
    lda #1
    jsr DELAY_ms

    lda #\2
    sta VPORT2
    lda #1
    jsr DELAY_ms
	.endm output