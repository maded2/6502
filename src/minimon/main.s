

.segment "OS"

    .include "xmodem-receive.asm"

RES_vec:



; system vectors

.segment "VECTORS"

	.word	NMI_Handler	; NMI vector
	.word	RES_vec		; RESET vector
	.word	IRQ_vec		; IRQ vector