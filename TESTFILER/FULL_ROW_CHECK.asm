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
	ld		r18, Z			;(Sparar värdet)
	add		ZL, r20
	ld		r17, Z
	cpi		r17, $00
	brne		DONE_ROW
	mov		r16, r20		; Intern loop counter för FULL_ROW_FOUND
	FULL_ROW_FOUND:
	dec		r16			; Kolla raden ovanför den fulla
	ldi		ZL, LOW(VMEM)
	add		ZL, r16
	ld		r17, Z			; Z så ladda och öka ZL
	inc		ZL
	inc		r16			; Återställ countern
	st		Z, r17

	dec		ZL			; Tillbaks till raden ovanför
	ldi		r17, $FF		; Nollställ raden
	st		Z, r17			; Spara nollställningen

	dec		r16
	cpi		r16, 0
	brne		FULL_ROW_FOUND

	DONE_ROW:
	inc		r20
	cpi		r20, $0F
	brne		UPDATE_LOOP

	END_CHECK:
	pop		r20
	pop		r18
	pop		r17
	pop		r16
	pop		ZL
	pop		ZH
	ret
