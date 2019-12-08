;
; screen /dev/tty.usbserial 9600,cs7,cstopb

;where '/dev/tty.usbserial' is your serial device. I used a cheap
;Usb->Serial converter.

;=====================================================================
; ACIA CONSTANTS
;=====================================================================
ACIA_INT	= %10000000	; 1 = Interrupt has occured
ACIA_DSR	= %01000000	; 1 = DSR not ready
ACIA_DCD	= %00100000	; 1 = DCD not detected
ACIA_TXE	= %00010000	; 1 = Tx Data Reg is Empty**
ACIA_RXF	= %00001000	; 1 = Rx Data Reg is Full
ACIA_OVR	= %00000100	; 1 = Overrun has occured
ACIA_FRER	= %00000010	; 1 = Framing Error detected
ACIA_PAER	= %00000001	; 1 = Parity Error detected

;=====================================================================
; Cold reset
;=====================================================================
MAIN:
			jsr INIZ_ACIA	; Setup the 6551
			lda #$00		; Iniz regs to zero
MSG:
			ldx #0			; iniz chr ptr
MSGLOOP:
			lda MSG_HDR,x	; Get a chr
			beq DOLOOP		; If it's null go wait for a key press
			jsr PUTCH		; Otherwise write it out
			inx				; Inc chr ptr
			jmp MSGLOOP		; and go get next chr
DOLOOP:
			jsr GETCH		; Read a char from the serial port
			cmp #$0D
			bne SENDIT
			jsr PUTCH
			lda #$0A
SENDIT:
			jsr PUTCH		; and send it back out
			jmp DOLOOP		; do silly stuff forever
MSG_HDR:
			.BYTE "TLC-MBC Monitor v0.1 - 27/06/15", $0D, $0A, $00

;=====================================================================
; ACIA routines
;=====================================================================
INIZ_ACIA:
			sei				; Disable ints.
			lda #$00
			sta ACIA_STAT	; Reset the ACIA
			lda #%00001011	; No parity, no echo, no interrupt
			sta ACIA_COM
			lda #%00011111	; 1 Stop bit, 8 data bits, 19.2K baud
			sta ACIA_CTRL
			cli				; Enable the ints
			rts

GETCH:      ; Read one char from ACIA
            lda #ACIA_RXF
GETCH_LOOP:
            bit ACIA_STAT   ; Test Status
            beq GETCH_LOOP   ; not yet
            lda ACIA_DATA   ; read char
            sta VIA1PB      ; show on LEDs
            rts

PUTCH:      ; Write one char to ACIA
            sta ACIA_DATA   ; and write it
            sta VIA1PA      ; show on LEDs
            jsr WAIT_6551   ; required Delay
            rts
WAIT_6551:
			phy
			phx
W6_LOOP:
			ldy #10			; Get Delay val (Clk rate in MHZ - 2 clk cycles)
MSEC:
			ldx #$68		; Seed X for 1ms
W6_DELAY:
			dex
			bne W6_DELAY
			dey
			bne MSEC
			plx
			ply
			rts
