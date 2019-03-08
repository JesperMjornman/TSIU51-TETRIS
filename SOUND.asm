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
	call	PLAY2
	
	sbic	PINA, 2 ; PIN 38
	call	PLAY3



	END_START:
	rjmp	START

	 PLAY2:
	 ldi	r16, $2A
	SOUND_LOOP2:
	 sbi	PORTC, 1
	 call	 delay2
	 cbi	PORTC, 1
	 call	delay2
	 dec	r16
	 cpi	r16, 0
	 brne	SOUND_LOOP2
	 ret
	DELAY2:
	 push	r18
	 push	r17
	 ldi	r18, 10
	delayYttreLoop2:
	 ldi	r17,$FF
	delayInreLoop2:
	 dec	r17
	 brne	delayInreLoop2
	 dec	r18
	 brne	delayYttreLoop2
	 pop	r17
	 pop	r18
	 rcall	WAIT
	 ret

	 PLAY3:
	 ldi	r16, $7D
	SOUND_LOOP3:
	 sbi	PORTC, 1
	 call	delay3
	 cbi	PORTC, 1
	 call	delay3
	 dec	r16
	 cpi	r16, 0
	 brne	SOUND_LOOP3
	 ret
	DELAY3:
	 push	r18
	 push	r17
	 ldi	r18, 10
	delayYttreLoop3:
	 ldi	r17,$FF
	delayInreLoop3:
	 dec	r17
	 brne	delayInreLoop3
	 dec	r18
	 brne	delayYttreLoop3
	 pop	r17
	 pop	r18
	 rcall	WAIT
	 ret

	WAIT:
	sbic	PINA,0
	rjmp	WAIT
	sbic	PINA,1
	rjmp	WAIT
	sbic	PINA,2 
	rjmp	WAIT
	ret
