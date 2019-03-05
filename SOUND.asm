/*
 * SOUND.asm
 *
 *  Created: 2019-03-05 13:16:25
 *   Author: danma256
 */ 


	clr		r16
	out		DDRA, r16
	dec		r16
	out		DDRC, r16

	START:
	sbis	PINA, 0
	rjmp	START
	call    PLAY
	call	WAIT

PLAY:
SOUND:
 ldi r16, $0A
SOUND_LOOP:
 sbi PORTC, 1
 call delay
 cbi PORTC, 1
 call delay
 dec r16
 cpi r16, 0
 brne SOUND_LOOP
 ret
DELAY:
 push r18
 push r17
 ldi r18, 10
delayYttreLoop:
 ldi r17,$FF
delayInreLoop:
 dec r17
 brne delayInreLoop
 dec r18
 brne delayYttreLoop
 pop r17
 pop r18
 ret

WAIT:
	sbic	PINA,0
	rjmp	WAIT
	ret
