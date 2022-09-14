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



clt
bld R16,0; Sets LSB of R16 to T of sreg
rcall display ; call display subroutine

rjmp   mloop

buttonpress:
ldi r28, 0xff
ldi r29, 0x50
ldi r30, 0x00  ; r31:r30  <-- load a 16-bit value into counter register for outer loop
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

ldi r29,0x29
cp r29,r31
BRGE  d1
ldi R16,N_A ;Loads in Reg if greater than 1 sec button press
ret
d1: 
ldi R16,N_8
ret
d3:
ldi R16,N_F
ret
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
rjmp end set_ser_in_1:
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

.equ N_0 = 0b11111100
.equ N_1 = 0b01100000  
.equ N_2 = 0b11011010 
.equ N_3 = 0b11110010 
.equ N_4 = 0b01100110 
.equ N_5 = 0b10110110 
.equ N_6 = 0b10111110 
.equ N_7 = 0b11100000 
.equ N_8 = 0b11111111
.equ N_9 = 0b11110110 
.equ N_A = 0b11101110  
.equ N_B = 0b00111110 
.equ N_C = 0b10011100 
.equ N_D = 0b01111010 
.equ N_E = 0b10011110  
.equ N_F = 0b10001110 
.exit