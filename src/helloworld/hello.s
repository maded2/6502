
          .segment "CODE"

CHROUT = $FF4E

				PHA
				PHX
				LDX #$00
LOOP		LDA	HELLO_WORLD,X	;Get BIOS init msg (4)
				BEQ	EXIT	;If zero, msg done, goto cold start monitor (2/3)
				JSR	CHROUT	;Send to console (6)
				INX	;Increment Index (2)
				BRA	LOOP	;Loop back until done (3)
EXIT
				PLX
				PLA
				RTS

HELLO_WORLD
				.byte	$0D,$0A
				.byte	"Hello World"
				.byte	$0D,$0A
				.byte	$00	;Terminate string

