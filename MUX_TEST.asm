

	.org	0
	rjmp	COLD
	.org	OVF0addr
	rjmp	MUX

.def	MUXCOUNTER = r19
.dseg
VMEM:	.byte 8
LINE:	.byte 1
.cseg

COLD:				
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
	out		SPL, r16
	clr		MUXCOUNTER

	ldi		ZH, HIGH(LINE)
	ldi		ZL, LOW(LINE)
	ldi		r16, $80
	st		Z, r16

	call	VMEM_INIT
	call	HW_INIT

WARM:
	rjmp	WARM

  ;-----------------------------
  ;--- VMEM initieras med värden
VMEM_INIT:
	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	clr		r16

VMEM_SET:
	st		Z+,	r16
	inc		r16
	sbrs	r16, 3
	rjmp	VMEM_SET
	ret
  ;----------------------------
  ;------ MUX
  ;--USES: Z, r16, r17, MUXCOUNTER (r19)
MUX:
	push	ZH
	push	ZL
	push	r16
	push	r17

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	add		ZL, MUXCOUNTER
	ld		r16, Z

	ldi		ZH, HIGH(LINE)
	ldi		ZL, LOW(LINE)
	ld		r17, Z

	cpi		r17, $01
	brne	NOT_0
	ldi		r17, $80
	rjmp	SPI_LCD
NOT_0:
	lsr		r17
SPI_LCD:
	st		Z, r17
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
	out		SPDR, r16
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

	pop		r17
	pop		r16
	pop		ZL
	pop		ZH

	reti

HW_INIT:											
	ldi		r17,(1<<DDB5)|(1<<DDB7)|(1<<DDB4)|(1<<DDB0)	; Set MOSI, SCK, SS, PB0  output, all others input
	out		DDRB,r17
												
	ldi		r17,(1<<SPE)|(1<<MSTR)|(1<<SPR0)			      ; Enable SPI, Master, set clock rate fck/16
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
