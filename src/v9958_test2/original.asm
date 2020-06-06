; This is a simple demo program for the VDP S-100 Board
;
; Code is based on a version of Hello World was written by Timo "NYYRIKKI" Soilamaa
; 17.10.2001
;
; Converted to Z80ASM by Leon Byles 25 Feb 2012 for testing
; N8VEM-S100 Computers S-100 VDP board
;
; Converted to Dumb terminal display mode by John Monahan 6/23/2013
;
;	V0.2	;Entering CR from keyboard repositions "cursor"
;	V0.3	;Reduce resolution to 40X24 Char/line
;	V0.4	;Remove hardware console port requirements. Use CPM for all I/O
;	V0.5	;Initilize all chip registers for 80X24 TEXT2 mode
;
;		Note character update not yet changed/updated from 40X24 Mode
;
;----------------------------------------------------------------------

SCROLL		EQU	01H	;Set scrool direction UP.
LF		EQU	0AH
CR		EQU	0DH
BS		EQU	08H	;Back space (required for sector display)
BELL		EQU	07H
SPACE		EQU	20H
QUIT		EQU	11H	;Turns off any screen enhancements (flashing, underline etc).
NO$ENHANCEMENT	EQU	17H	;Turns off whatever is on
FAST		EQU	10H	;High speed scrool
TAB		EQU	09H	;TAB ACROSS (8 SPACES FOR SD-BOARD)
ESC		EQU	1BH


RDCON		EQU	1	;For CP/M I/O
WRCON		EQU	2
PRINT		EQU	9
CONST		EQU	11	;CONSOLE STAT
BDOS		EQU	5


DATAP:		EQU	98H	; VDP Data port
CMDP:		EQU	99H	; VDP Command portVDP register
				; For write to port (bit 7=1 in second write)
				; For VRAM address register (bit 7=0 in second write, bit 6: read/write access (0=read))
				; Status register read port
				; Port 9AH, Palette access port (only v9938/v9958)
				; Port 9BH, Indirect register access port (only v9938/v9958)

LATCH:		EQU	9CH	; LATCH-WR* port

;-----------------------------------------------------------------------

	ORG 0100H		; Z80 starts always from here when power is turned on

	DI			; We don't know, how interrupts works in this system,
				; so we disable them.

begin:	LD	SP,STACK
	LD	HL,SIGN$ON	; Print a welcome message on Console
	CALL	PSTRING

	CALL	ZCI		;Stay here until keyboard hit
	PUSH	AF

	LD	HL,CRLF		; Print a CR/LF
	CALL	PSTRING

	POP	AF
	CP	A,ESC		;ESC to abort
	JP	Z,DONE

	LD	A,010H		; reset VDP by
	OUT	(LATCH),A	; toggling  SYNTMS* bit
	NOP			; >> Note this may be different for "real" MSX2 systems
	NOP			;    and may be commented out <<<
	NOP
	NOP
	NOP
	LD	A,00H
	OUT	(LATCH),A	;???

				; Set up rest of VDP registers:
	LD	C,CMDP		; Port always in [C], Register pointer in [E]

				;----------------------------------------

	LD	E,80H		; Register 0.
				; Set mode selection bit M3 (maybe also M4 & M5) to zero and
				; disable external video & horizontal interrupt
	LD	A,0000100B	; For Text Mode 1 (80X24 Chars/line)
	OUT	(C),A		; but with repeat text half way down screen
	OUT	(C),E


	INC	E		; Register 1.    Select 80 column mode, enable screen and disable vertical interrupt
	LD	A,01010000B	; For Text Modes 1 & 2
;	LD	A,70H		;XXXXXXXXXXXXXX
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register 2.    Set pattern name table to #0000
;	XOR	A
	LD	A,03H		;XXXXXXXXXXXXXX
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #3
	LD	A,27H		;XXXXXXXXXXXXXX
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #4.
;	LD	A,1
	LD	A,02H		;XXXXXXXXXXXXXX
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #5.
;	LD	A,1
	LD	A,36H		;XXXXXXXXXXXXXX
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #6.
;	LD	A,1
	LD	A,07H		;XXXXXXXXXXXXXX
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #7.    Set colors to white on black
;	LD	A,0F1H		; Bits 7-4 = Text color (White), Bits 3-0 Background color (Black)
	LD	A,0F4H
	OUT	(C),A		; Data = 0F1H  (white on black)
	OUT	(C),E

	INC	E		; To Register #8
;	LD	A,09H		; *** (00001001) = no mouse,no LP, set color code,color bus output mode,
	                        ;                  VRAM = 64K , 0, Sprite disable, Set to B&W
	LD	A,08H		;XXXXXXXXXXXXXX
	OUT	(C),A
	OUT	(C),E

	INC	E		; To Register #9.    Cycle Mode S1=1 S0=0 IL=0 E0=0
;	LD	A,24H		; ***
	LD	A,02H		;XXXXXXXXXXXXXX
	OUT	(C),A		; ***
	OUT	(C),E		; ***


	INC	E		; Register #10 to 0H
				; Color Table base address Higher Order BitsBits A16 to A14
				; (Lower Order Bits A13 to A9 loaded into #R3
	LD	A,00H
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #11 to 0H
	LD	A,00H
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #12 to 0H
	LD	A,00H
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #13 to 0H
	LD	A,00H
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #14 to 0H
	LD	A,00H
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #15 to 0H
	LD	A,00H
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #16 to 0H
	LD	A,0FH		; XXXXXXXXXXXXXXXX
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #17 to 0H
	LD	A,00H
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #18 to 0H
	LD	A,00H
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #19 to 0H
	LD	A,00H
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #20 to 0H
	LD	A,00H
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #21 to 0H
	LD	A,38H		; XXXXXXXXXXXX
	OUT	(C),A
	OUT	(C),E

	INC	E		; Register #22 to 0H
	LD	A,05H		; XXXXXXXXXXXXXXXX
	OUT	(C),A
	OUT	(C),E



	XOR A			; Let's set VDP write address to #0000
	OUT (CMDP),A
	LD A,40H
	OUT (CMDP),A
				; Clear first 16Kb of VDP memory
	LD B,0
	LD HL,3FFFH
	LD C,DATAP

CLEAR:	OUT (C),B
	DEC HL
	LD A,H
	OR L
	NOP			; Let's wait 8 clock cycles just in case VDP is not quick enough.
	NOP
	JR NZ,CLEAR

				; ----------------------------------------
	LD C,CMDP		; Let's set VDP write address to 808H so, that we can write
	LD A,8			; character set to memory
	OUT (C),A		; (No need to write SPACE it is clear char already)
;	LD A,48H		; Serious error!
	LD A,50H		;XXXXXXXXXXXXXXXXXXXX
	OUT (C),A

				; Let's use the IBM-PC ROM BIOS character set
	PUSH	BC		; Save C
	LD	HL,CHARS_IBM
	LD	B,(CHARS_END_IBM-CHARS_IBM)/8	;Number of 8 byte characters to move

COPYCHARS:
	LD	C,8		; 8 bytes per character
COPY1:	LD	A,(HL)
	OUT	(DATAP),A
	INC	HL
	NOP			; Let's wait 8 clock cycles just in case VDP is not quick enough.
	NOP
	NOP
	NOP
	DEC	C
	JP	NZ,COPY1
	DJNZ	COPYCHARS
	POP	BC		; Return C



	XOR A			; Let's set write address to start of name table
	OUT (C),A
	LD A,40H
	OUT (C),A

				;======  We are done setting up registers! =======

				;Let's set write address to start of "name table" (CRT Display)
	LD	IY,0		;[IY] Will ALWAYS hold the line number on screen (0 - 23)
	LD	IX,0		;[IX] Will ALWAY  hold X position on current line (0 - 39)
	XOR	A
	OUT	(C),A		;send 0 to CMD port
	LD	A,40H
	OUT	(C),A

	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	HL,VH_SIGNON	;Send VPD Board signon message to VGA display
	CALL	VPSTRING
	POP	BC
	POP	DE
	POP	HL


				;---------------  MAIN PROGRAM LOOP ------------------

NEXTCHAR:
	CALL	ZCI		;Stay here until keyboard hit
	CP	A,ESC		;ESC to abort
	JP	Z,DONE
	CP	A,CR		;If CR then special treatment
	JP	NZ,NO_CR
	CALL	DO_CR		;CR+LF
	JP	NEXTCHAR
NO_CR:	SUB	A,1FH		;Adjust ASCII to table offset
	OUT	(DATAP),A	;Send character to DATA PORT
	CALL	UPDATE_POSITION	;Update cursor positioning data
	JP	NEXTCHAR

DONE:	LD	C,00H		; CP/M SYSTEM RESET CALL
	CALL	BDOS		; RETURN TO CP/M PROMPT


UPDATE_POSITION:		;>>> NOTE THIS CODE IS NOT CORRECTED YET FOR 80X24 MODE <<<
	PUSH	HL
	INC	IX		;Line position (Note [HL] Altered)
	PUSH	IX
	POP	HL
	LD	A,H
	CP	A,40		;40 characters/line
	POP	HL
	RET	NZ		;If not at end of line then return
	LD	IX,0		;X back to start of line
	INC	IY		;Normally the chip will position cursor on next line
	RET			;<<<< NOTE Scroll on bottom line not done yet >>>


DO_CR:	PUSH	HL		;Do a CR+LF on screen (80 characters/line)
	PUSH	BC
	LD	IX,0
	INC	IY		;Next line
	PUSH	IY
	POP	HL		;Now calculate position for chip (0 - 3FFF) from line count
	LD	A,L		;Line count will be 0 to 23
	LD	BC,40		;40 characters/line
	LD	HL,0
DO_CR1:	ADD	HL,BC		;0,40,80,120,160,,,,
	DEC	A		;line count
	JP	NZ,DO_CR1
	CALL	SET_CURSOR	;Update V9938
	POP	BC
	POP	HL
	RET

SET_CURSOR:			;Set cursor at position [A]+[HL]
	RLC	H
	RLA
	RLC	H
	RLA
	SRL	H
	SRL	H
	OUT	(CMDP),A	;(Note Control Port)
	LD	A,14+128
	OUT	(CMDP),A	;Send A16, A15, A14 to register #14 (Note Control Port)
	LD	A,L
	NOP
	NOP
	OUT	(CMDP),A	;(Note Control Port)
	LD	A,H
	OR	64
	OUT	(CMDP),A	;(Note Control Port)
	RET
				; The end 						;


; ---------------- SUPPORT ROUTINES ON S100 SIDE -------------------

ZCI:	PUSH	BC		;Via CPM, return keyboard character in [A]
	PUSH	DE
	PUSH	HL
	LD	C,RDCON
	CALL	BDOS
	POP	HL
	POP	DE
	POP	BC
	RET

ZCO:	PUSH	AF		;Via CPM, print on S100 System character in [C]
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	E,C
	LD	C,WRCON
	CALL	BDOS
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET


PSTRING:LD	A,(HL)		;Print a string in [HL] up to '$' on CPM/Console
	CP	A,'$'
	RET	Z
	LD	C,A
	CALL	ZCO
	INC	HL
	JP	PSTRING

VPSTRING:			;Print a string in [HL] up to '$' on V9938 VGA Display
	LD	A,(HL)
	CP	A,'$'
	RET	Z
	LD	C,A
	CALL	ZCO		;Show on CPM Console first (A is returned unchanged)
	SUB	A,1FH		;Adjust ASCII to table offset
	OUT	(DATAP),A
	CALL	UPDATE_POSITION	;Update cursor positioning data
	INC	HL
	DJNZ	VPSTRING



; DISPLAY CURRNT VALUE IN [A] (For Debugging Only)
; All registers unchanged

LBYTE:PUSH	AF
	PUSH	BC
	PUSH	AF
	RRCA
	RRCA
	RRCA
	RRCA
	CALL	CONV
	CALL  ZCO
	POP	AF
SF598:	CALL	CONV
	CALL	ZCO		;Send to consol
	POP	BC
	POP	AF
	RET
;
CONV:	AND	0FH		;CONVERT HEX TO ASCII
	ADD	A,90H
	DAA
	ADC	A,40H
	DAA
	LD	C,A
	RET


SIGN$ON:DB	CR,LF,BELL,'AW9938 on VDP S-100 Board Test Program 2/9/2014 (V0.5) '
	DB	CR,LF,'Enter characters to appear on V9938 screen. ESC to abort.',CR,LF,LF
	DB	CR,LF,'First hit any key to start test. $'
CRLF	DB	CR,LF,'$'

VH_SIGNON: DB	'VH9938, VIDEO DISPLAY  (80 X 24 Characters/Line - TEXT MODE 2). $'


CHARS_IBM:									;This is the IBM-PC Character ROM +20H
		DB	000H,000H,000H,000H,000H,000H,000H,000H 		;SP
		DB	030H,078H,078H,030H,030H,000H,030H,000H 		;!
		DB	06CH,06CH,06CH,000H,000H,000H,000H,000H 		;"
		DB	06CH,06CH,0FEH,06CH,0FEH,06CH,06CH,000H 		;#
		DB	030H,07CH,0C0H,078H,00CH,0F8H,030H,000H 		;$
		DB	000H,0C6H,0CCH,018H,030H,066H,0C6H,000H 		;%
		DB	038H,06CH,038H,076H,0DCH,0CCH,076H,000H 		;&
		DB	060H,060H,0C0H,000H,000H,000H,000H,000H 		;'
		DB	018H,030H,060H,060H,060H,030H,018H,000H 		;(
		DB	060H,030H,018H,018H,018H,030H,060H,000H 		;)
		DB	000H,066H,03CH,0FFH,03CH,066H,000H,000H 		;*
		DB	000H,030H,030H,0FCH,030H,030H,000H,000H 		;+
		DB	000H,000H,000H,000H,000H,030H,030H,060H 		;'
		DB	000H,000H,000H,0FCH,000H,000H,000H,000H 		;-
		DB	000H,000H,000H,000H,000H,030H,030H,000H 		;.
		DB	006H,00CH,018H,030H,060H,0C0H,080H,000H 		;/

		DB	07CH,0C6H,0CEH,0DEH,0F6H,0E6H,07CH,000H 		;30, 0
		DB	030H,070H,030H,030H,030H,030H,0FCH,000H 		;31, 1
		DB	078H,0CCH,00CH,038H,060H,0CCH,0FCH,000H 		;32, 2
		DB	078H,0CCH,00CH,038H,00CH,0CCH,078H,000H 		;33, 3
		DB	01CH,03CH,06CH,0CCH,0FEH,00CH,01EH,000H 		;34, 4
		DB	0FCH,0C0H,0F8H,00CH,00CH,0CCH,078H,000H 		;35, 5
		DB	038H,060H,0C0H,0F8H,0CCH,0CCH,078H,000H 		;36, 6
		DB	0FCH,0CCH,00CH,018H,030H,030H,030H,000H 		;37, 7
		DB	078H,0CCH,0CCH,078H,0CCH,0CCH,078H,000H 		;38, 8
		DB	078H,0CCH,0CCH,07CH,00CH,018H,070H,000H 		;39, 9

		DB	000H,030H,030H,000H,000H,030H,030H,000H 		;:
		DB	000H,030H,030H,000H,000H,030H,030H,060H 		;;
		DB	018H,030H,060H,0C0H,060H,030H,018H,000H 		;<
		DB	000H,000H,0FCH,000H,000H,0FCH,000H,000H 		;=
		DB	060H,030H,018H,00CH,018H,030H,060H,000H 		;>
		DB	078H,0CCH,00CH,018H,030H,000H,030H,000H 		;?
		DB	07CH,0C6H,0DEH,0DEH,0DEH,0C0H,078H,000H 		;@
		DB	030H,078H,0CCH,0CCH,0FCH,0CCH,0CCH,000H 		;A
		DB	0FCH,066H,066H,07CH,066H,066H,0FCH,000H 		;B
		DB	03CH,066H,0C0H,0C0H,0C0H,066H,03CH,000H 		;C
		DB	0F8H,06CH,066H,066H,066H,06CH,0F8H,000H 		;D
		DB	0FEH,062H,068H,078H,068H,062H,0FEH,000H 		;E
		DB	0FEH,062H,068H,078H,068H,060H,0F0H,000H 		;F
		DB	03CH,066H,0C0H,0C0H,0CEH,066H,03EH,000H 		;G
		DB	0CCH,0CCH,0CCH,0FCH,0CCH,0CCH,0CCH,000H 		;H
		DB	078H,030H,030H,030H,030H,030H,078H,000H 		;I
		DB	01EH,00CH,00CH,00CH,0CCH,0CCH,078H,000H 		;J
		DB	0E6H,066H,06CH,078H,06CH,066H,0E6H,000H 		;K
		DB	0F0H,060H,060H,060H,062H,066H,0FEH,000H 		;L
		DB	0C6H,0EEH,0FEH,0FEH,0D6H,0C6H,0C6H,000H 		;M
		DB	0C6H,0E6H,0F6H,0DEH,0CEH,0C6H,0C6H,000H 		;N
		DB	038H,06CH,0C6H,0C6H,0C6H,06CH,038H,000H 		;O
		DB	0FCH,066H,066H,07CH,060H,060H,0F0H,000H 		;P
		DB	078H,0CCH,0CCH,0CCH,0DCH,078H,01CH,000H 		;Q
		DB	0FCH,066H,066H,07CH,06CH,066H,0E6H,000H 		;R
		DB	078H,0CCH,0E0H,070H,01CH,0CCH,078H,000H 		;S
		DB	0FCH,0B4H,030H,030H,030H,030H,078H,000H 		;T
		DB	0CCH,0CCH,0CCH,0CCH,0CCH,0CCH,0FCH,000H 		;U
		DB	0CCH,0CCH,0CCH,0CCH,0CCH,078H,030H,000H 		;V
		DB	0C6H,0C6H,0C6H,0D6H,0FEH,0EEH,0C6H,000H 		;W
		DB	0C6H,0C6H,06CH,038H,038H,06CH,0C6H,000H 		;X
		DB	0CCH,0CCH,0CCH,078H,030H,030H,078H,000H 		;Y
		DB	0FEH,0C6H,08CH,018H,032H,066H,0FEH,000H 		;Z
		DB	078H,060H,060H,060H,060H,060H,078H,000H 		;[
		DB	0C0H,060H,030H,018H,00CH,006H,002H,000H 		;\
		DB	078H,018H,018H,018H,018H,018H,078H,000H 		;]
		DB	010H,038H,06CH,0C6H,000H,000H,000H,000H 		;^
		DB	000H,000H,000H,000H,000H,000H,000H,000H 		;_

		DB	030H,030H,018H,000H,000H,000H,000H,000H 		;'
		DB	000H,000H,078H,00CH,07CH,0CCH,076H,000H 		;a
		DB	0E0H,060H,060H,07CH,066H,066H,0DCH,000H 		;b
		DB	000H,000H,078H,0CCH,0C0H,0CCH,078H,000H 		;c
		DB	01CH,00CH,00CH,07CH,0CCH,0CCH,076H,000H 		;d
		DB	000H,000H,078H,0CCH,0FCH,0C0H,078H,000H 		;e
		DB	038H,06CH,060H,0F0H,060H,060H,0F0H,000H 		;f

;		DB	000H,000H,076H,0CCH,0CCH,07CH,00CH,0F8H 		;g
		DB	000H,000H,076H,0CCH,0CCH,07CH,00CH,000H 		;g

		DB	0E0H,060H,06CH,076H,066H,066H,0E6H,000H 		;h
		DB	030H,000H,070H,030H,030H,030H,078H,000H 		;i

;		DB	00CH,000H,00CH,00CH,00CH,0CCH,0CCH,078H 		;j
		DB	00CH,000H,00CH,00CH,00CH,0CCH,0CCH,000H 		;j

		DB	000H,060H,066H,06CH,078H,06CH,0E6H,000H 		;k
		DB	070H,030H,030H,030H,030H,030H,078H,000H 		;l
		DB	000H,000H,0CCH,0FEH,0FEH,0D6H,0C6H,000H 		;m
		DB	000H,000H,0F8H,0CCH,0CCH,0CCH,0CCH,000H 		;n
		DB	000H,000H,078H,0CCH,0CCH,0CCH,078H,000H 		;o

;		DB	000H,000H,0DCH,066H,066H,07CH,060H,0F0H 		;p
;		DB	000H,000H,076H,0CCH,0CCH,07CH,00CH,01EH 		;q
		DB	000H,000H,0DCH,066H,066H,07CH,060H,000H 		;p
		DB	000H,000H,076H,0CCH,0CCH,07CH,00CH,000H 		;q

		DB	000H,000H,0DCH,076H,066H,060H,0F0H,000H 		;r
		DB	000H,000H,07CH,0C0H,078H,00CH,0F8H,000H 		;s
		DB	010H,030H,07CH,030H,030H,034H,018H,000H 		;t
		DB	000H,000H,0CCH,0CCH,0CCH,0CCH,076H,000H 		;u
		DB	000H,000H,0CCH,0CCH,0CCH,078H,030H,000H 		;v
		DB	000H,000H,0C6H,0D6H,0FEH,0FEH,06CH,000H 		;w
		DB	000H,000H,0C6H,06CH,038H,06CH,0C6H,000H 		;x

;		DB	000H,000H,0CCH,0CCH,0CCH,07CH,00CH,0F8H 		;y
		DB	000H,000H,0CCH,0CCH,0CCH,07CH,00CH,000H 		;y

		DB	000H,000H,0FCH,098H,030H,064H,0FCH,000H 		;z
		DB	01CH,030H,030H,0E0H,030H,030H,01CH,000H 		;{
		DB	018H,018H,018H,000H,018H,018H,018H,000H 		;|
		DB	0E0H,030H,030H,01CH,030H,030H,0E0H,000H 		;}
		DB	076H,0DCH,000H,000H,000H,000H,000H,000H 		;~
		DB	000H,010H,038H,06CH,0C6H,0C6H,0FEH,000H 		;DEL

CHARS_END_IBM:
	DS	40H
STACK:	DW	0

	END
