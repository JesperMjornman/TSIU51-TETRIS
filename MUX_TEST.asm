

	.org	0
	rjmp	COLD
	.org	OVF0addr
	rjmp	MUX

.def	MUXCOUNTER = r19
.dseg
VMEM:	.byte 16
LINE:	.byte 1
POSX:	.byte 1
POSY:   .byte 1
.cseg

COLD:				
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
	out		SPL, r16
	clr		MUXCOUNTER

	ldi		ZH, HIGH(LINE)
	ldi		ZL, LOW(LINE)
	ldi		r16, $01
	st		Z, r16

	call	VMEM_INIT
	call	HW_INIT

WARM:
	call	BUILD_BLOCK
START:
	rjmp	START
  ;-----------------------------
  ;--- VMEM initieras med värden
VMEM_INIT:
	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	clr		r16
	ldi		r17, $FF
VMEM_SET:
	st		Z+,	r17
	inc		r16
	sbrs	r16, 3
	rjmp	VMEM_SET
	inc		r16
	dec		r17
	st		Z+, r17
	sbrs	r16, 7
	rjmp	VMEM_SET
	ret
  ;----------------------------
  ;--MUX
  ;--USES: Z, r16, r17, MUXCOUNTER (r19)
MUX:
	push	ZH
	push	ZL
	push	r16
	push	r17
	push	r18

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	add		ZL, MUXCOUNTER
	ld		r16, Z
	subi	ZL, -8
	ld		r18, Z

	ldi		ZH, HIGH(LINE)
	ldi		ZL, LOW(LINE)
	ld		r17, Z


/*	cpi		r17, $80
	brne	NOT_0
	ldi		r17, $01
	rjmp	SPI_LCD
NOT_0:
	lsl		r17
SPI_LCD:
	st		Z, r17*/
	//BLUE
	out		SPDR, r17
	rcall	Wait_Transmit
	//GREEN
	out		SPDR, r17
	rcall	Wait_Transmit
	//RED
	out		SPDR, r17
	rcall	Wait_Transmit
	//KOLUMN (Satta värden visas ej)	
	;ld		r18, Z
	out		SPDR, r16
	rcall	Wait_Transmit

	//BLUE	
	out		SPDR, r17
	rcall	Wait_Transmit
	//GREEN
	out		SPDR, r17
	rcall	Wait_Transmit
	//RED
	out		SPDR, r17
	rcall	Wait_Transmit
	//KOLUMN (Satta värden visas ej)	
	;ld		r18, Z
	out		SPDR, r18
	rcall	Wait_Transmit

	rjmp	SEND_BITS

Wait_Transmit:
	sbis	SPSR,SPIF
	rjmp	Wait_Transmit
	ret
SEND_BITS:
	sbi		PORTB, 0
	cbi		PORTB, 0

	inc		MUXCOUNTER
	sbrc	MUXCOUNTER, 3
	clr		MUXCOUNTER

	cpi		r17, $80
	brne	NOT_0
	ldi		r17, $01
	rjmp	END_MUX
NOT_0:
	lsl		r17
END_MUX:
	st		Z, r17
	pop		r18
	pop		r17
	pop		r16
	pop		ZL
	pop		ZH

	reti

BUILD_BLOCK:
	push	ZH
	push	ZL
	push	r16
	push	r17

	ldi		r16, $EF
	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	st		Z, r16

	clr	r17
	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	st		Z, r17

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	st		Z, r16

	pop		r17
	pop		r16
	pop		ZL
	pop		ZH
	ret

HW_INIT:											
	ldi		r17,(1<<DDB5)|(1<<DDB7)|(1<<DDB4)|(1<<DDB0)	; Set MOSI, SCK, SS, PB0  output, all others input
	out		DDRB,r17
												
	ldi		r17,(1<<SPE)|(1<<MSTR)|(0<<SPR0)			      ; Enable SPI, Master, set clock rate fck/4
	out		SPCR,r17
	cbi		PORTB, 0

	ldi		r16, (1 << CS01)
	out		TCCR0, r16
	ldi		r16, (1 << TOIE0)
	out		TIMSK, r16

	ldi		r16, $FF
	out		DDRA, r16								
	clr		r16
	out		DDRC, r16								
	sei

	ret

LINECONVERTER:
	.db $01, $02, $04, $08, $10, $20, $40, $80, $01, $02, $04, $08, $10, $20, $40, $80
