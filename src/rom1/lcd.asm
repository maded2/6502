



                                ; This simplifies LCD_INSTR_STO and LCD_DATA_STO.
LCD_NIB_STO:                    ; Start w/ nibble & register-select bit in A, & E false.
        STA     VIA1PA          ; Store in VIA's PB that way,
        ORA     #00100000B
        STA     VIA1PA          ; then with E (enable) true,
        AND     #11011111B
        STA     VIA1PA          ; then make E false again before data go away.
        RTS
 ;-----------------------
                                ; Instruction store.  Start with byte in A.
LCD_INSTR_STO:                  ; High nibble must be written first.
        PHA                     ; Save on stack for low nibble later.
           LSR  A               ; Shift high nibble into low nibble's position.
           LSR  A               ; LSR shifts 0's into high bits,
           LSR  A               ; which is perfect because we initially want E false
           LSR  A               ; and want RS=0 for instruction register.
           JSR  LCD_NIB_STO     ; Store first (high) nibble,
        PLA                     ; then get the original byte back
        AND     #00001111B      ; and AND-out everything but the low nibble
        JMP     LCD_NIB_STO     ; and store that.  (JSR, RTS)
 ;-----------------------
                                ; Data store.  Start with byte in A.
LCD_DATA_STO:                   ; Again, high nibble is written first.
        PHA                     ; Save on stack for low nibble later.
           SEC                  ; This time we want to set bit 4 for RS=1 (for data)
           ROR  A               ; so we set C flag and rotate instead of shift.
           LSR  A               ; Shift 0's into the 3 high bits as the rest goes right.
           LSR  A
           LSR  A
           JSR  LCD_NIB_STO     ; Store first (high) nibble,
        PLA                     ; then get the original byte back
        AND     #00001111B      ; and AND-out the high nibble,
        ORA     #00010000B      ; set the register-select bit to "data" again,
        JMP     LCD_NIB_STO     ; and store the low nibble.  (JSR, RTS)
 ;-----------------------

RST_LCD:                        ; Set VIA1 for keys, LCD, beeper, and part of printer.
        LDA     #BFH            ; Set appropriate 6522 bits as outputs. (PB6
        STA     VIA1DDRA        ; is an input for keys.)
        STZ     VIA1PA          ; Set enable line false.

        JSR     WAIT_EIGHTH     ; Wait at least 15ms after power-up for internal LCD operations.

        LDA     #3              ; Write function set.  It's no error
        STA     VIA1PA          ; that this is here three times.  It's
        LDX     #23H            ; necessary for a good power-up initialization.
        STX     VIA1PA
        STA     VIA1PA
        LDA     #5
        JSR     DELAY_ms

        LDX     #23H
        STX     VIA1PA
        LDA     #3
        STA     VIA1PA

        STX     VIA1PA
        STA     VIA1PA

        DEC     A               ; Set for 4-bit data.
        STA     VIA1PA
        DEC     VIA1PA
        STX     VIA1PA
        STA     VIA1PA

        LDA     #2BH            ; Set bit 3 for two-line display (8
        JSR     LCD_INSTR_STO   ; characters each, end-to-end).

        LDA     #0CH
        JSR     LCD_INSTR_STO   ; Display on, no cursor display, no cursor blink.

        LDA     #1
        JSR     LCD_INSTR_STO   ; Write clear display.

        LDA     #5              ; Delay 5 milliseconds.
        JSR     DELAY_ms

        LDA     #6
        JSR     LCD_INSTR_STO   ; Write entry mode set, increment mode, no display shift.

 ; then in Forth I initialized the end-of-line sequence for CR only and made the
 ; LCD the current output device, and recorded that we're starting a new line.
 ;-----------------------

CLR_LCD:
        LDA     #1
        JSR     LCD_INSTR_STO
        LDA     #5
        JSR     DELAY_ms        ; Clearing the display takes up to 5ms.
 ; and in Forth I also recorded that we're starting a new line, by putting 0 in variable "OUT".
 ;-----------------------

SET_LCD_ADR:
 ; Y = character position (in the range of 0-0FH) (It does not get destroyed.)
 ; The character address system for the 1x16 LCD is (in hex):
 ;                        0, 1, 2, 3, 4, 5, 6, 7, 40, 41, 42, 43, 44, 45, 46, 47.
 ; ie, it's like two 8-character lines stuck end to end.

        TYA
        AND     #0FH            ; Limit the LCD address to 00-0F for 16 characters.
        CMP     #8
        BMI     sla             ; If character address is for second half of display,
        AND     #7              ; then clear bit 3
        ORA     #40H            ; and set bit 6.
 sla:   ORA     #80H            ; Set bit 7 to indicate LCD character address.
        JMP     LCD_INSTR_ADR   ; Give address as instruction to LCD.  (JSR, RTS)
 ;-----------------------

WR_LCD: PHA                     ; Write LCD, starting with chr adr in Y and chr in A.
        JSR  SET_LCD_ADR
        PLA
        JMP     LCD_DATA_STO    ; (JSR, RTS)
 ;-----------------------

LCD_CURSOR_ON:                  ; (Makes the cursor show.)
        LDA     #0DH
        JMP     LCD_INSTR_STO   ; (JSR, RTS)
 ;-----------------------

LCD_CURSOR_OFF:                 ; (Hides the cursor.)
        LDA     #0CH
        JMP     LCD_INSTR_STO   ; (JSR, RTS)
 ;-----------------------

