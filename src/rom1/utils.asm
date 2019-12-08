
; Delay loop.  around 1ms.  call with No. of ms in A

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
