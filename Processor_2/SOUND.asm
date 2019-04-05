/*
 * SOUND.asm
 *
 *  Created: 2019-03-05 13:16:25
 *   Author: danma256
 */ 


	clr		r16
	out		DDRA, r16
	ldi		r16, $FF
	out		DDRC, r16

	START:
	sbic	PINA, 1 ; PIN 39
	call	FULL_ROW
	
	sbic	PINA, 2 ; PIN 38
	call	LOST



	END_START:
	rjmp	START

	FULL_ROW:
	 ldi	r16, $10
	SOUND_LOOP1:
	 sbi	PORTC, 1
	 call	DELAY1
	 cbi	PORTC, 1
	 call	DELAY1
	 dec	r16
	 cpi	r16, 0
	 brne	SOUND_LOOP1
	 ret
	DELAY1:
	 push	r18
	 push	r17
	 ldi	r18, 10
	delayYttreLoop1:
	 ldi	r17,$7D
	delayInreLoop1:
	 dec	r17
	 brne	delayInreLoop1
	 dec	r18
	 brne	delayYttreLoop1
	 pop	r17
	 pop	r18
	 rcall	WAIT
	 ret

	 LOST:
	 ldi	r16, $64
	SOUND_LOOP2:
	 sbi	PORTC, 1
	 call	DELAY2
	 cbi	PORTC, 1
	 call	DELAY2
	 dec	r16
	 cpi	r16, 0
	 brne	SOUND_LOOP2
	 rjmp	LOST2
	DELAY2:
	 push	r18
	 push	r17
	 ldi	r18, 10
	delayYttreLoop2:
	 ldi	r17,$DF
	delayInreLoop2:
	 dec	r17
	 brne	delayInreLoop2
	 dec	r18
	 brne	delayYttreLoop2
	 pop	r17
	 pop	r18
	 ret

	 LOST2:
	 call	NO_SOUND
	 ldi	r16, $7D
	SOUND_LOOP3:
	 sbi	PORTC, 1
	 call	DELAY3
	 cbi	PORTC, 1
	 call	DELAY3
	 dec	r16
	 cpi	r16, 0
	 brne	SOUND_LOOP3
	 rjmp	LOST3
	DELAY3:
	 push	r18
	 push	r17
	 ldi	r18, 10
	delayYttreLoop3:
	 ldi	r17,$EF
	delayInreLoop3:
	 dec	r17
	 brne	delayInreLoop3
	 dec	r18
	 brne	delayYttreLoop3
	 pop	r17
	 pop	r18
	 ret
	 
	 LOST3:
	 call	NO_SOUND
	 ldi	r16, $FF
	SOUND_LOOP4:
	 sbi	PORTC, 1
	 call	DELAY4
	 cbi	PORTC, 1
	 call	DELAY4
	 dec	r16
	 cpi	r16, 0
	 brne	SOUND_LOOP4
	 ret
	DELAY4:
	 push	r18
	 push	r17
	 ldi	r18, 10
	delayYttreLoop4:
	 ldi	r17,$Ff
	delayInreLoop4:
	 dec	r17
	 brne	delayInreLoop4
	 dec	r18
	 brne	delayYttreLoop4
	 pop	r17
	 pop	r18
	 rcall	WAIT
	 ret

	WAIT:
	sbic	PINA,1
	rjmp	WAIT
	sbic	PINA,2 
	rjmp	WAIT
	ret

NO_SOUND:
    ldi  r18, 6
    ldi  r19, 19
    ldi  r20, 174
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    ret
