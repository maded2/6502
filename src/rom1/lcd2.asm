



                                ; This simplifies LCD_INSTR_STO and LCD_DATA_STO.
LCD_NIB_STO:                    ; Start w/ nibble & register-select bit in A, & E false.
        STA     VIA1PA          ; Store in VIA's PB that way,
        ORA     #%00100000
        STA     VIA1PA          ; then with E (enable) true,
        AND     #%11011111
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
        AND     #%00001111      ; and AND-out the high nibble,
        ORA     #%00010000      ; set the register-select bit to "data" again,
        JMP     LCD_NIB_STO     ; and store the low nibble.  (JSR, RTS)
 ;-----------------------

RST_LCD:                        ; Set VIA1 for keys, LCD, beeper, and part of printer.

        LDA #40                 ; wait > 40ms
        JSR DELAY_ms

        LDA #$38                ; set 4-bit mode - 1st
        JSR LCD_NIB_STO
        LDA #2                  ; wait > 2ms
        JSR DELAY_ms

        LDA #$38                  ; set 4-bit mode - 2nd
        JSR LCD_NIB_STO
        LDA #1                  ; wait > 37us
        JSR DELAY_ms

        LDA #$38                  ; set 4-bit mode - 3rd
        JSR LCD_NIB_STO
        LDA #1                  ; wait > 37us
        JSR DELAY_ms

        LDA #$28              ; set 4-bit mode - 4th
        JSR LCD_NIB_STO
        LDA #1                  ; wait > 37us
        JSR DELAY_ms

        LDA #$28              ; set mode,   N=1, EXT=0
        JSR LCD_NIB_STO
        LDA #1                  ; wait > 37us
        JSR DELAY_ms

        LDA #$0f          ; set display,   D=1, C=1, P=0
        JSR LCD_NIB_STO
        LDA #1                  ; wait > 37us
        JSR DELAY_ms

        LDA #$01          ; clear display
        JSR LCD_NIB_STO
        LDA #2                  ; wait > 1.52ms
        JSR DELAY_ms

        LDA #$06          ; entry mode, I=1, S=0
        JSR LCD_NIB_STO
        LDA #1                  ; wait > 37us
        JSR DELAY_ms

        LDA #$41
        JSR LCD_DATA_STO
        RTS