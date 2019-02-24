CHECKING_COLL:


	ldi		ZL, LOW(POSY)
	ldi		ZH, HIGH(POSY)
	subi	ZL, LOOPCOUNTER
	ld		r17, Z
  
	cpi		r17, $0F
	breq	HIT
	
	ldi		ZH, HIGH(VMEM)
    ldi		ZL, LOW(VMEM)
	inc		r17
    add		ZL, r17	 
	ld		r17, Z

	ldi		ZH, HIGH(POSX)
	ldi		ZL, LOW(POSX)
	add		ZL, LOOPCOUNTER
    ld		r18, Z+
	cpi		ZL, BLOCK_SIZE-1
	breq	CL

	ld		r21, Z
	com		r21
	add		r17, r21	; "Fyll igen" x-koordinaterna nedanför för att undvika kollision med sig själv
CL:
	mov		r19, r17
    com		r18         ; $EF -> $10 etc
	or		r19, r18
    cp		r17, r19
    breq	LOOP_CHECK	
	rjmp	HIT

LOOP_CHECK:		
	cpi		LOOPCOUNTER, BLOCK_SIZE-1
	brne	CHECKING_COLL
HIT:
	ldi		r20, $01
	call	CHECK_ROW_FILLED
	call	CHECK_IF_LOST
	call	BUILD_BLOCK
	;call	BUILD_BLOCK_2
END_CHECK:
	pop		LOOPCOUNTER
	pop		r21
	pop		r19
	pop		r18
	pop		r17
	pop		ZL
	pop		ZH
	ret
