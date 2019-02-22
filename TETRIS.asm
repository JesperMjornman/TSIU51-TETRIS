

	.org	0
	rjmp	COLD
	.org	OVF1addr
	rjmp	GRAVITY
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
	call	GET_KEY
	rjmp	START

  ;-----------------------------
  ;--- VMEM initieras med värden
VMEM_INIT:
	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	clr		r16
	ldi		r18, $FF
	ldi		r17, $10
VMEM_SET:
	st		Z+,	r18
	inc		r16
	sbrs	r16, 4
	rjmp	VMEM_SET
	ret

GET_KEY:
	sbic	PINC, 0
	call	MOV_LEFT

	sbic	PINC, 1
	call	MOV_RIGHT

	ret

  ;-----------------------------
  ;--- MOVEMENT - LEFT
  ;--- USES: Z, r16, r17
MOV_LEFT:
	push	ZH
	push	ZL
	push	r16
	push	r17
	push	r18 
	clr		r18

	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	ld		r16, Z

	cpi		r16, $FE		;BORDER CHECK
	breq	END_MOVL
	call	BLOCKED_LEFT
	sbrc	r18, 0
	rjmp	END_MOVL
		
	com		r16		
	lsr		r16
	com		r16
	st		Z, r16

	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	ld		r17, Z

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	add		ZL, r17
	ld		r17, Z
	and		r17, r16

	com		r16		;Fyll hålet
	lsl		r16
	or		r17, r16
	st		Z, r17
END_MOVL:
	call	WAIT_RELEASE	
	pop		r18
	pop		r17
	pop		r16
	pop		ZL
	pop		ZH
	ret

  ;-----------------------------
  ;--- MOVEMENT - RIGHT
  ;--- USES: Z, r16, r17
MOV_RIGHT:
	push	ZH
	push	ZL
	push	r16
	push	r17
	push	r18
	clr		r18

	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	ld		r16, Z
	
	cpi		r16, $7F	;BORDER CHECK
	breq	END_MOVR
	call	BLOCKED_RIGHT
	sbrc	r18, 0
	rjmp	END_MOVR

	com		r16	
	lsl		r16
	com		r16
	st		Z, r16

	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	ld		r17, Z

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	add		ZL, r17
	ld		r17, Z
	and		r17, r16

	com		r16		;Fyll hålet
	lsr		r16
	or		r17, r16
	st		Z, r17

END_MOVR:
	call	WAIT_RELEASE	
	pop		r18
	pop		r17
	pop		r16
	pop		ZL
	pop		ZH
	ret
	

WAIT_RELEASE:
	sbic	PINC, 0
	rjmp	WAIT_RELEASE
	sbic	PINC, 1
	rjmp	WAIT_RELEASE

	ret

BLOCKED_RIGHT:
	push	ZH
	push	ZL
	push	r16
	push	r17

	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	ld		r16, Z

	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	ld		r17, Z

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	add		ZL, r17
	ld		r17, Z

	com		r16
	lsl		r16

	and		r17, r16
	cpi		r17, 0
	brne	END_BRCHECK
	ldi		r18, 1

END_BRCHECK:
	pop		r17
	pop		r16
	pop		ZL
	pop		ZH
	ret

BLOCKED_LEFT:
	push	ZH
	push	ZL
	push	r16
	push	r17

	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	ld		r16, Z

	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	ld		r17, Z

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	add		ZL, r17
	ld		r17, Z

	com		r16
	lsr		r16

	and		r17, r16
	cpi		r17, 0
	brne	END_BRCHECK
	ldi		r18, 1

END_BLCHECK:
	pop		r17
	pop		r16
	pop		ZL
	pop		ZH
	ret
  ;-------------------------------------
  ;--- MUX
  ;--- USES: Z, r16, r17, MUXCOUNTER (r19)
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

SPI_LCD:
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

GRAVITY:
	push	ZH
	push	ZL
	push	r16
	push	r17

	call	CHECK_COLLISION

	ldi		ZL, LOW(POSX)
	ldi		ZH, HIGH(POSX)
	ld		r16, Z

	ldi		ZL, LOW(POSY)
	ldi		ZH, HIGH(POSY)
	ld		r17, Z
	inc		r17
	;sbrc	r17, 5
	;clr	r17
	st		Z, r17

	ldi		ZL, LOW(VMEM)
	ldi		ZH, HIGH(VMEM)
	add		ZL, r17
	ld		r17, Z
	and		r17, r16
	st		Z, r17

	call	UPDATE_POS
;	call	CHECK_COLLISION
	
	pop		r17
	pop		r16
	pop		ZL
	pop		ZH
	reti

UPDATE_POS:
	push	ZH
	push	ZL
	push	r16
	push	r17
	push	r18
	
	
	ldi		ZL, LOW(POSX)
	ldi		ZH, HIGH(POSX)
	ld		r16, Z	;r17
	
	
	ldi		ZL, LOW(POSY)
	ldi		ZH, HIGH(POSY)
	ld		r17, Z
	dec		r17

	ldi		ZL, LOW(VMEM)
	ldi		ZH, HIGH(VMEM)
	add		ZL, r17
	ld		r17, Z

	com		r16
	or		r17, r16
	st		Z, r17
END_UPDATE:
	pop		r18
	pop		r17
	pop		r16
	pop		ZL
	pop		ZH
	ret

CHECK_COLLISION:
	push	ZH
	push	ZL
	push	r17
	push	r18
	push	r19

	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
    ld		r18, Z

	ldi		ZL, LOW(POSY)
	ldi		ZH, HIGH(POSY)
	ld		r17, Z
  
	cpi		r17, $0F
	breq	HIT
	
    ldi		ZH, HIGH(VMEM)
    ldi		ZL, LOW(VMEM)
	inc		r17
    add		ZL, r17
    ld		r17, Z
	
	mov		r19, r17
    com		r18         ; $EF -> $10 etc
	or		r19, r18
    cp		r17, r19
    breq	END_CHECK

HIT:
	call	CHECK_ROW_FILLED
	call	CHECK_IF_LOST
	call	BUILD_BLOCK
END_CHECK:
	pop		r19
	pop		r18
	pop		r17
	pop		ZL
	pop		ZH
	ret

CHECK_IF_LOST:
	push	ZH
	push	ZL
	push	r16

	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	ld		r16, Z
	cpi		r16, $01
	brne	END_LOSS_CHECK
LOST:
	call	VMEM_INIT
END_LOSS_CHECK:
	pop		r16
	pop		ZL
	pop		ZH
	ret

BUILD_BLOCK:
	push	ZH
	push	ZL
	push	r16
	push	r17

	ldi		r16, $EF
	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	st		Z, r16

	clr		r17
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

CHECK_ROW_FILLED:
	push	ZH
	push	ZL
	push	r16
	push	r17
	push	r18
	push	r20

	ldi		r20, 1
	ldi		ZH, HIGH(VMEM)
UPDATE_LOOP:
	ldi		ZL, LOW(VMEM)
	ld		r18, Z		;(Sparar värdet)
	add		ZL, r20
	ld		r17, Z
	cpi		r17, $00
	brne	DONE_ROW
	mov		r16, r20	; Intern loop counter för FULL_ROW_FOUND

FULL_ROW_FOUND:
	dec		r16			; Kolla raden ovanför den fulla
	ldi		ZL, LOW(VMEM)
	add		ZL, r16
	ld		r17, Z		; Z så ladda och öka ZL
	inc		ZL
	inc		r16			; Återställ countern
	st		Z, r17

	dec		ZL			; Tillbaks till raden ovanför
	ldi		r17, $FF	; Nollställ raden
	st		Z, r17		; Spara nollställningen
	
	dec		r16
	cpi		r16, 0
	brne	FULL_ROW_FOUND

DONE_ROW:
	inc		r20
	cpi		r20, $10
	brne	UPDATE_LOOP

	pop		r20
	pop		r18
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
	ldi		r16, (1 << CS11 | 0 << CS10 | 0 << CS12| 1 << WGM12)	;	fclk / 256
	out		TCCR1B, r16	
	ldi		r16, (1 << TOIE0 | 1 << OCIE1B)
	out		TIMSK, r16

	ldi		r17, $3D
	ldi		r16, $09	
	out		OCR1AH, r17		
	out		OCR1AL, r16

	ldi		r16, $FF
	out		DDRA, r16								
	clr		r16
	out		DDRC, r16								
	sei

	ret


