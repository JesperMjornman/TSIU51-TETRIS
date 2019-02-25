

	.org	0
	rjmp	COLD
	.org	OVF1addr
	rjmp	GRAVITY
	.org	OVF0addr
	rjmp	MUX

 ; --------------------------  
; |---  VARIABLE LAYOUT  ---|
; ---------------------------	
.def	MUXCOUNTER  = r19
.def	LOOPCOUNTER = r21
.def	BOOLEAN		= r18
.equ	BLOCK_SIZE  = 3
; -------------------------  
; |---  MEMORY LAYOUT  ---|
; -------------------------	
.dseg
VMEM:	.byte 16
LINE:	.byte 1				; Sparar vilken rad vi är på för att MUX:a rätt
POSX:	.byte BLOCK_SIZE
POSY:   .byte BLOCK_SIZE

; ------------------------  
; |---  CODE SEGMENT  ---|
; ------------------------	
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
	;call	BUILD_BLOCK
	call	BUILD_BLOCK_2 

START:
	call	GET_KEY
	rjmp	START

 GET_KEY:
	sbic	PINC, 0
	call	MOV_LEFT

	sbic	PINC, 1
	call	MOV_RIGHT

	ret

  ;-----------------------------
  ;--- VMEM initieras med värden
  ;--- "Nollställer spelplanen"
VMEM_INIT:
	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	clr		r16
	ldi		r17, $FF
VMEM_SET:
	st		Z+,	r17
	inc		r16
	sbrs	r16, 4
	rjmp	VMEM_SET
	ret



  ;-----------------------------
  ;--- MOVEMENT - LEFT
  ;--- USES: Z, r16, r17, 
MOV_LEFT:
	push	ZH
	push	ZL
	push	r16
	push	r17
	push	BOOLEAN 
	push	LOOPCOUNTER
	clr		BOOLEAN
	ldi		LOOPCOUNTER, BLOCK_SIZE

	call	BORDER_CHECK		; Check borders before movement
	call	BLOCKED_LEFT
MOVING_L:
	dec		LOOPCOUNTER

	sbrc	BOOLEAN, 0
	rjmp	END_MOVL

	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	add		ZL, LOOPCOUNTER
	ld		r16, Z
		
	com		r16		
	lsr		r16
	com		r16
	st		Z, r16

	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	add		ZL, LOOPCOUNTER
	ld		r17, Z

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	add		ZL, r17
	ld		r17, Z
	com		r16
	lsl		r16
	or		r17, r16
	lsr		r16
	com		r16	
	and		r17, r16
	st		Z, r17
END_MOVL:
	cpi		LOOPCOUNTER, 0
	brne	MOVING_L

	call	WAIT_RELEASE	
	pop		LOOPCOUNTER
	pop		BOOLEAN
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
	push	BOOLEAN
	push	LOOPCOUNTER
	clr		BOOLEAN
	ldi		LOOPCOUNTER, BLOCK_SIZE

	call	BORDER_CHECK
	sbrs	BOOLEAN, 0
	call	BLOCKED_RIGHT
MOVING_R:
	dec		LOOPCOUNTER
	
	sbrc	BOOLEAN, 0
	rjmp	END_MOVR

	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	add		ZL, LOOPCOUNTER
	ld		r16, Z

	com		r16	
	lsl		r16
	com		r16
	st		Z, r16

	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	add		ZL, LOOPCOUNTER
	ld		r17, Z

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	add		ZL, r17
	ld		r17, Z
	com		r16
	lsr		r16
	or		r17, r16
	lsl		r16
	com		r16	
	and		r17, r16
	st		Z, r17

END_MOVR:
	cpi		LOOPCOUNTER, 0
	brne	MOVING_R

	call	WAIT_RELEASE	
	pop		LOOPCOUNTER
	pop		BOOLEAN
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

BORDER_CHECK:
	push	LOOPCOUNTER
	push	r16
	push	r17
	ldi		LOOPCOUNTER, 0
 CHECKING_BORDER:
	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	add		ZL, LOOPCOUNTER
	ld		r16, Z

	sbis	PINC, 1
	rjmp	CHECKING_L
 CHECKING_R:

	mov		r17, r16
	andi	r17, $80		; Border check
	sbrs	r17, 7			; - Bättre eftersom generell lösning
	ldi		BOOLEAN, 1	
	rjmp	END_BORDER

 CHECKING_L:
	andi	r16, $01
	sbrs	r16, 0
	ldi		BOOLEAN, 1	

END_BORDER:
	inc		LOOPCOUNTER
	cpi		LOOPCOUNTER, BLOCK_SIZE
	brne	CHECKING_BORDER

	pop		r17
	pop		r16
	pop		LOOPCOUNTER
	ret
  ;-------------------------------------
  ;--- CHECK IF BLOCKED BY BITS 
  ;--- USES: Z, r16, r17
BLOCKED_RIGHT:
	push	ZH
	push	ZL
	push	r16
	push	r17
	push	r20
	push	LOOPCOUNTER
	clr		LOOPCOUNTER
LOOP_R:
	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	add		ZL, LOOPCOUNTER
	ld		r16, Z

	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	add		ZL, LOOPCOUNTER
	ld		r17, Z

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	add		ZL, r17
	ld		r17, Z

	com		r16
	mov		r20, r16
	add		r17, r16
	lsl		r16
	lsl		r20

	and		r16, r17
	cp		r16, r20
	breq	END_BRCHECK
	ldi		BOOLEAN, 1
END_BRCHECK:
	inc		LOOPCOUNTER
	cpi		LOOPCOUNTER, BLOCK_SIZE
	brne	LOOP_R

	pop		LOOPCOUNTER
	pop		r20
	pop		r17
	pop		r16
	pop		ZL
	pop		ZH
	ret
	
  ;-------------------------------------
  ;--- CHECK IF BLOCKED BY BITS 
  ;--- USES: Z, r16, r17
BLOCKED_LEFT:
	push	ZH
	push	ZL
	push	r16
	push	r17
	push	r20
	push	LOOPCOUNTER
	clr		LOOPCOUNTER
LOOP_L:
	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	add		ZL, LOOPCOUNTER
	ld		r16, Z

	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	add		ZL, LOOPCOUNTER
	ld		r17, Z

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	add		ZL, r17
	ld		r17, Z

	com		r16
	mov		r20, r16
	add		r17, r16
	lsr		r16
	lsr		r20

	and		r16, r17
	cp		r16, r20
	breq	END_BLCHECK
	ldi		BOOLEAN, 1
END_BLCHECK:
	inc		LOOPCOUNTER
	cpi		LOOPCOUNTER, BLOCK_SIZE
	brne	LOOP_L

	pop		LOOPCOUNTER
	pop		r20
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
	
  ;-------------------------------------
  ;--- GRAVITY - DROPS THE BLOCKS 
  ;--- USES: Z, r16, r17, LOOPCOUNTER, r20
GRAVITY:
	push	ZH
	push	ZL
	push	r16
	push	r17
	push	r20
	push	LOOPCOUNTER
	ldi		LOOPCOUNTER, BLOCK_SIZE

	clr		r20
	call	CHECK_COLLISION
	sbrc	r20, 0			; BOOLEAN 
	rjmp	END_GRAV
FALLING:
	dec		LOOPCOUNTER

	ldi		ZL, LOW(POSX)
	ldi		ZH, HIGH(POSX)
	add		ZL, LOOPCOUNTER
	ld		r16, Z

	ldi		ZL, LOW(POSY)
	ldi		ZH, HIGH(POSY)
	add		ZL, LOOPCOUNTER
	ld		r17, Z
	inc		r17
	st		Z, r17

	ldi		ZL, LOW(VMEM)
	ldi		ZH, HIGH(VMEM)
	add		ZL, r17
	ld		r17, Z
	and		r17, r16
	st		Z, r17

	call	UPDATE_POS
	cpi		LOOPCOUNTER, 0
	brne	FALLING
END_GRAV:
	;call	UPDATE_POS
	pop		LOOPCOUNTER
	pop		r20
	pop		r17
	pop		r16
	pop		ZL
	pop		ZH
	reti
	
  ;-------------------------------------
  ;--- UPDATE VMEM WITH NEW COORDINATES
  ;--- (ERASE OLD COORDINATES)
  ;--- USES: Z, r16, r17, r18
UPDATE_POS:
	push	ZH
	push	ZL
	push	r16
	push	r17
	push	r18
UPDATING_POS:	
	ldi		ZL, LOW(POSX)
	ldi		ZH, HIGH(POSX)
	add		ZL, LOOPCOUNTER
	ld		r16, Z	
		
	ldi		ZL, LOW(POSY)
	ldi		ZH, HIGH(POSY)
	add		ZL, LOOPCOUNTER
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
	
  ;-------------------------------------
  ;--- CHECK IF COLLISION
  ;--- IF YES -> BUILD NEW BLOCK
  ;--- USES: Z, r17, r18, r19
CHECK_COLLISION:
	push	ZH
	push	ZL
	push	r17
	push	r18
	push	r19
	push	r16
	push	LOOPCOUNTER
	clr		LOOPCOUNTER
CHECKING_COLL:
	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	add		ZL, LOOPCOUNTER
    ld		r18, Z+

	ldi		r16, $FF
	cpi		LOOPCOUNTER, BLOCK_SIZE-1
	breq	C1
	ld		r16, Z
C1:
	ldi		ZL, LOW(POSY)
	ldi		ZH, HIGH(POSY)
	add		ZL, LOOPCOUNTER
	ld		r17, Z
  
	cpi		r18, $FF
	breq	NOT_BOTTOM
	cpi		r17, $0F	; KNAS
	breq	HIT
NOT_BOTTOM:
    ldi		ZH, HIGH(VMEM)
    ldi		ZL, LOW(VMEM)
	inc		r17
    add		ZL, r17
    ld		r17, Z
	
	com		r16
	add		r17, r16
	mov		r19, r17
    com		r18         ; $EF -> $10 etc
	or		r19, r18
    cp		r17, r19
    brne	HIT
CHECK_LOOP:
	inc		LOOPCOUNTER
	cpi		LOOPCOUNTER, BLOCK_SIZE
	brne	CHECKING_COLL
	rjmp	END_CHECK
HIT:
	ldi		r20, $01
	call	CHECK_ROW_FILLED
	call	CHECK_IF_LOST
	;call	BUILD_BLOCK
	;call	BUILD_BLOCK_2
	call	BUILD_BLOCK_SQUARE
END_CHECK:
	pop		LOOPCOUNTER
	pop		r16
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

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	inc		ZL
	ld		r16, Z
	cpi		r16, $FF
	breq	END_LOSS_CHECK
LOST:
	call	VMEM_INIT
END_LOSS_CHECK:
	pop		r16
	pop		ZL
	pop		ZH
	ret
	
  ;-------------------------------------
  ;--- BUILD NEW BLOCK
  ;--- USES: Z, r16, r17, LOOPCOUNTER
BUILD_BLOCK:
	push	ZH
	push	ZL
	push	r16
	push	r17
	push	LOOPCOUNTER
	clr		LOOPCOUNTER
	clr		r17
BUILDING:
	ldi		r16, $EF

	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	add		ZL, LOOPCOUNTER
	st		Z, r16

	
	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	add		ZL, LOOPCOUNTER
	st		Z, r17

	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	add		ZL, LOOPCOUNTER
	st		Z, r16
	inc		LOOPCOUNTER
	inc		r17
	cpi		LOOPCOUNTER, BLOCK_SIZE
	brne	BUILDING
FINISHED_BUILD:
	pop		LOOPCOUNTER
	pop		r17
	pop		r16
	pop		ZL
	pop		ZH
	ret

  ;------------------------------------------
  ;--- CHECK IF ROW IS FILLED
  ;--- IF YES -> DELETE ROW, ROWS ABOVE FALL
  ;--- USES: Z, r16, r17, r18, r20
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


BUILD_BLOCK_2:
	push	ZH
	push	ZL
	push	r16
	push	r17

	clr		r17
	clr		r18
BUILDING_2:
	ldi		r16, $E7
	clr		r17

	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	st		Z+, r16
	ldi		r17, $EF
	st		Z+, r17
	st		Z, r17
	
	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	st		Z+, r16
	st		Z+, r17
	st		Z, r17
	
	clr		r16
	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	st		Z+, r16
	inc		r16
	st		Z+, r16
	inc		r16
	st		Z, r16
	
FINISHED_BUILD_2:
	pop		r17
	pop		r16
	pop		ZL
	pop		ZH
	ret

BUILD_BLOCK_SQUARE:
	push	ZH
	push	ZL
	push	r16
	push	r17

	clr		r17
	clr		r18
BUILDING_S:
	ldi		r16, $E7

	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	st		Z+, r16
	st		Z+, r16

	ldi		r17, $FF
	st		Z, r17
	
	ldi		ZH, HIGH(VMEM)
	ldi		ZL, LOW(VMEM)
	st		Z+, r16
	st		Z+, r16
	st		Z, r17
	
	clr		r16
	ldi		ZH, HIGH(POSY)
	ldi		ZL, LOW(POSY)
	st		Z+, r16
	inc		r16
	st		Z+, r16
	inc		r16
	st		Z, r16
	
FINISHED_BUILD_S:
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


