sbi DDRB, 1
sbi DDRB, 2
sbi DDRB, 3

cbi PORTB, 0

sbi PORTB, 0

initial_mode1:
ldi R28, 0x01 ; keep track of mode
ldi R16, 0b00111111
rcall display ; call display subroutine


sbi PORTB, 0
nop
cbi PORTB, 0

rjmp initial

initial_mode2:
ldi R28, 0x02
ldi R16, 0b00111111
rcall display

ldi R16, 0b00111111
rcall display

sbi PORTB,3
nop
cbi PORTB,3

initial:
ldi R18, 0x00 ;
ldi R22, 0x00 ;
ldi R26, 0x00 ;
ldi R19, 0x00 ; 
ldi R30, 0x00 ;

main: 
SBIS PINB, 0


rjmp main 

reset:
cpi R28, 1
		breq initial_mode1
		breq initial_mode2

yes_flash: 
	ldi R16, 0x00
	rcall display

	ldi R16, 0x00
	rcall display

	sbi PORTB, 3
	rcall delay_short
	cbi PORTB, 3

	rcall delay_long

	rcall delay_short
	rcall delay_short
	rcall delay_short
	rcall delay_short
	rcall delay_short
	rcall delay_long

	ldi r16, 0b01100111
	rcall display

	ldi r16, 0b01100111
	cpi R28, 1
		brne no_dp_flash

	ldi R21, 0b10000000
	add R16, R21

	no_dp_flash:
	rcall display

	
	rcall delay_short
	cbi PORTB, 3

	rcall delay_long

	rjmp yes_flash

	

				updateLeft:
					inc R26
					cpi R26, 0x0A
						brne no_flash

					rjmp yes_flash

					no_flash:
					MOV R18, R26
					rcall count_long
					ldi R18, 0x00

				ret


display: ; backup used registers on stack
	push R16
	push R17
	in R17, SREG
	push R17

	ldi R17, 8 ; loop --> test all 8 bits
loop:
	rol R16 ; rotate left trough Carry
	BRCS set_ser_in_1 ; branch if Carry is set; put code here to set SER to 0
	cbi PORTB,2

	rjmp end

	set_ser_in_1:
	sbi PORTB,2; 
		

	end:
	sbi PORTB,1
	nop 
	cbi PORTB,1
	dec R17
	brne loop
	pop R17
	out SREG, R17
	pop R17
	pop R16
	ret 


	count_long:
	rcall delay_short
	cpi R18, 0x00
		breq out_zero
	cpi R18, 0x01
		breq out_one
	cpi R18, 0x02
		breq out_two
	cpi R18, 0x03
		breq out_three
	cpi R18, 0x04
		breq out_four
	cpi R18, 0x05
		breq out_five
	cpi R18, 0x06
		breq out_six
	cpi R18, 0x07
		breq out_seven
	cpi R18, 0x08
		breq out_eight
	cpi R18, 0x09
		breq out_nine
	cpi R18, 0x0A
		breq out_zero

	ret

	out_zero:
			ldi R16, 0b00111111
			ret
	out_one:
			ldi R16, 0b00000110
			ret
	out_two:
			ldi R16, 0b01011011
			ret
	out_three:
			ldi R16, 0b01001111
			ret
	out_four:
			ldi R16, 0b01100110
			ret
	out_five:
			ldi R16, 0b01101101
			ret
	out_six:
			ldi R16, 0b01111101
			ret
	out_seven:
			ldi R16, 0b00000111
			ret
	out_eight:
			ldi R16, 0b01111111
			ret
	out_nine:
			ldi R16, 0b01100111
			ret

	delay_short: ; 33.3 ms
	ldi r23,12 ; r23 <-- counter for outer loop
	d1: ldi r24,90 ; r25
	d2: ldi r25, 52 ; r25
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dec r25
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	dec r24
	brne d2
	dec r23
	brne d1
	ret

	delay_long: 
		ldi R27, 27
		call_delay_short:
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		sbis PINB, 2
		sbis PINB, 3
		rcall delay_short
		brne call_delay_short

	ret
	.exit