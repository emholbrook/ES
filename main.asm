;
; AssemblerApplication1.asm
;
; Created: 9/11/2022 12:08:50 PM
; Author : Ross
;

 .include "m328Pdef.inc"
.cseg
.org 0
; Configure I/O PINS
sbi   DDRB,1      ; PB1 is now output SER
sbi   DDRB,2      ; PB2 is now output SRCLK
sbi   DDRB,3      ; PB3 is now output RCLK
cbi   DDRB,0      ; PB4 is now input for BTN Press

;Sets Initial Display
CLT
bld R16,0
ldi R16, N_0
rcall display
ldi R18,0x00

;main loop
mloop:

; display a digit

waitforbuttonrelease:
sbis PINB,0
rjmp waitforbuttonrelease

waitforbuttonpress:
sbic PINB,0
rjmp waitforbuttonpress

;sbis PINB,0 ; Skip next inst. if bit 0 in Port B is Low
rcall buttonpress



rcall set_display
bld R16,0; Sets LSB of R16 to T of sreg
rcall display ; call display subroutine

rjmp   mloop
; End Main Loop
buttonpress:
ldi r28, 0xff
ldi r29, 0x54  ; Sets value to check in button press is greater than 2 seconds based on counts aquired in L1 loop
ldi r30, 0x00  ; r31:r30  are use to count for button press timing
ldi r31, 0x00;
L1:
ADIW r31:r30,1
d2:
nop ; no operation
nop
dec   r28            ; r29 <-- r29 - 1
brne  d2 ; branch to d2 if result is not "0"
cp r31,r29
BRGE d3
sbis PINb,0; checks for button input still pressed
rjmp L1

ldi r29,0x2d ; Sets count to compare to for greater than 1 second
cp r29,r31
BRGE  d1
;Executes if Button press is greater than 1 and less than 2
BRBS 6, T2zero ;Check bit 6 of status reg which is T flag.T Flag is used to monitor inc or dec mode
SET  ;Sets T flag of status reg to 1 if it is not set
ret
T2zero:
CLT ;Sets T flag of status reg to 0 if it is set. DP LED will be off indicating increment mode
ret
;End of Button press is greater than 1 and less than 2

d1: ;less than 1 second branch
BRBS 6, Tis_one
inc r18
ret
Tis_one:
dec r18
ret
d3: ; Greater that 2 second branch
rjmp 0
ret
;end button press

display:
; backup used registers on stack
push R16
push R17
in R17, SREG
push R17
ldi R17, 8 ; loop --> test all 8 bits
loop:
rol R16 ; rotate left trough Carry
BRCS set_ser_in_1 ; branch if Carry is set
; put code here to set SER to 0
cbi   PORTB,1     ; SER at PB1 low (0)
...
rjmp end 
set_ser_in_1:
; put code here to set SER to 1
sbi   PORTB,1     ; SER at PB1 high (1)
...
end:
; put code here to generate SRCLK pulse
sbi   PORTB,2     ; LED at PB2 off
cbi   PORTB,2     ; LED at PB2 on
nop
sbi   PORTB,2     ; LED at PB2 off
...
dec R17
brne loop
; put code here to generate RCLK pulse
sbi   PORTB,3     ; LED at PB3 off
cbi   PORTB,3     ; LED at PB3 on
nop
sbi   PORTB,3     ; LED at PB3 off
...
; restore registers from stack
pop R17
out SREG, R17
pop R17
pop R16
ret 
; End Display

set_display:
	cpi R18, 0xff
		breq dec_overflow
	cpi R18, 0x10
		breq inc_overflow
overflow_return:
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
		breq out_A
	cpi R18, 0x0B
		breq out_b
	cpi R18, 0x0C
		breq out_c
	cpi R18, 0x0D
		breq out_D
	cpi R18, 0x0E
		breq out_E
	cpi R18, 0x0F
		breq out_F
	ret
	dec_overflow:
			ldi R18, 0x0F
			rjmp overflow_return
	inc_overflow:
			ldi R18, 0x00
			rjmp overflow_return
	out_zero:
			ldi R16, N_0
			ret
	out_one:
			ldi R16, N_1
			ret
	out_two:
			ldi R16, N_2
			ret
	out_three:
			ldi R16, N_3
			ret
	out_four:
			ldi R16, N_4
			ret
	out_five:
			ldi R16, N_5
			ret
	out_six:
			ldi R16, N_6
			ret
	out_seven:
			ldi R16, N_7
			ret
	out_eight:
			ldi R16, N_8
			ret
	out_nine:
			ldi R16, N_9
			ret
	out_A:
			ldi R16, N_A
			ret
	out_B:
			ldi R16, N_B
			ret
	out_C:
			ldi R16, N_C
			ret
	out_D:
			ldi R16, N_D
			ret
	out_E:
			ldi R16, N_E
			ret
	out_F:
			ldi R16, N_F
			ret

.equ N_0 = 0b11111100
.equ N_1 = 0b01100000  
.equ N_2 = 0b11011010 
.equ N_3 = 0b11110010 
.equ N_4 = 0b01100110 
.equ N_5 = 0b10110110 
.equ N_6 = 0b10111110 
.equ N_7 = 0b11100000 
.equ N_8 = 0b11111110
.equ N_9 = 0b11110110 
.equ N_A = 0b11101110  
.equ N_B = 0b00111110 
.equ N_C = 0b10011100 
.equ N_D = 0b01111010 
.equ N_E = 0b10011110  
.equ N_F = 0b10001110 
.exit