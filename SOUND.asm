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
	sbic	PINA, 0
	rjmp	PLAY1

	sbic	PINA, 1
	rjmp	PLAY1

	sbic	PINA,2
	rjmp	PLAY2

	call    START
	call	WAIT

PLAY1:
 ldi r16, $0A
SOUND_LOOP1:
 sbi PORTC, 1
 call delay1
 cbi PORTC, 1
 call delay1
 dec r16
 cpi r16, 0
 brne SOUND_LOOP1
 ret
DELAY1:
 push r18
 push r17
 ldi r18, 10
delayYttreLoop1:
 ldi r17,$FF
delayInreLoop1:
 dec r17
 brne delayInreLoop1
 dec r18
 brne delayYttreLoop1
 pop r17
 pop r18
 ret

 PLAY2:
 ldi r16, $C7
SOUND_LOOP2:
 sbi PORTC, 1
 call delay2
 cbi PORTC, 1
 call delay2
 dec r16
 cpi r16, 0
 brne SOUND_LOOP2
 ret
DELAY2:
 push r18
 push r17
 ldi r18, 10
delayYttreLoop2:
 ldi r17,$FF
delayInreLoop2:
 dec r17
 brne delayInreLoop2
 dec r18
 brne delayYttreLoop2
 pop r17
 pop r18
 ret

 PLAY3:
 ldi r16, $FF
SOUND_LOOP3:
 sbi PORTC, 1
 call delay3
 cbi PORTC, 1
 call delay3
 dec r16
 cpi r16, 0
 brne SOUND_LOOP3
 ret
DELAY3:
 push r18
 push r17
 ldi r18, 10
delayYttreLoop3:
 ldi r17,$FF
delayInreLoop3:
 dec r17
 brne delayInreLoop3
 dec r18
 brne delayYttreLoop3
 pop r17
 pop r18
 ret

WAIT:
	sbic	PINA,0
	rjmp	WAIT
	ret
