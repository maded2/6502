
; ACIA CONSTANTS

ACIA_INT	= %10000000	; 1 = Interrupt has occured
ACIA_DSR	= %01000000	; 1 = DSR not ready
ACIA_DCD	= %00100000	; 1 = DCD not detected
ACIA_TXE	= %00010000	; 1 = Tx Data Reg is Empty**
ACIA_RXF	= %00001000	; 1 = Rx Data Reg is Full
ACIA_OVR	= %00000100	; 1 = Overrun has occured
ACIA_FRER	= %00000010	; 1 = Framing Error detected
ACIA_PAER	= %00000001	; 1 = Parity Error detected