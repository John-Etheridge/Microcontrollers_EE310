//-----------------------------
// Title: Heating and Cooling System
//-----------------------------
// Purpose: This project takes the desired temperature inputed by the used and compares it to the measured temp. 
//Depending on how the measured temperature compares to the desired temperature either a heating or cooling fan will turn on.
// Dependencies: Config.inc
// Compiler: IDE v6.30
// Author: John Etheridge
// OUTPUTS: LED_COOL = PORTD,1; LED_HOT = PORTD,0
// INPUTS: measuredtemp = keypad input, refTemp = Temp sensor
// Versions:
//  	V1.0: today’s date - 03/08/26
//  	V1.2: date - 03/11/26
//-----------------------------


;---------------------
; Initialization
;---------------------
#include ".\Config.inc"
#include <xc.inc>

;---------------------
; Definitions
;---------------------
#define	SWITCH	  LATD,2
#define LED0	  PORTD,0
#define LED1	  PORTD,1

;---------------------
; Program Inputs
;---------------------
#define  measuredTempInput 	-2 ; this is the input value
#define  refTempInput 		60 ; this is the input value

;---------------------
; Registers
;---------------------
measuredTemp	EQU 0x20    ;
refTemp		EQU 0x21
contReg		EQU 0x22
		
REG60	EQU 0x60
REG61	EQU 0x61
REG62	EQU 0x62
	
REG70	EQU 0x70
REG71	EQU 0x71
REG72	EQU 0x72

;---------------------
; Main Program
;---------------------
PSECT absdata,abs,ovrld        ; Do not change
   
	ORG	0x00		;Reset vector
	GOTO	START

	ORG	0020H		;Begin assembly at 0020H
START:	
	MOVLW	measuredTempInput   ;Store inputs into Registers
	MOVWF	measuredTemp,A
	MOVLW	refTempInput
	MOVWF	refTemp,A
	MOVLW	0x00
	MOVWF	contReg,A
	MOVWF	TRISD,A
	GOTO	_COMPARE    ;Go to compare measuredTemp and refTemp
ORIG:	GOTO	measuredTempd	;Go to convert measuredTemp from Hex to Decimal
BACK:	GOTO	refTempd    ;Go to convert refTemp from HEX to Decimal
BACK2:	GOTO	HERE

	
	ORG	0x100
_COMPARE:   
	MOVLW	measuredTempInput
	BTFSC	measuredTemp,7,A    ;Checks to see if measuredTemp is not negative
	GOTO	BTS ;If measuredTemp is negative go to BTS
	CPFSGT	refTemp,A   ;Checks to see if refTemp > measuredTemp
	GOTO	SKIP
	BSF	contReg,0,A ;Sets bit 0 in contReg to 1
	GOTO	LED_COOL    
SKIP:	CPFSLT	refTemp,A   
	GOTO	SKIP2
BTS:	BSF	contReg,1,A
	GOTO	LED_HOT
SKIP2:	CPFSEQ	refTemp,A
	CLRF	contReg,A   ;Clears contReg
	GOTO	LED_OFF
	GOTO	ORIG
	
	ORG	0x200
LED_OFF:
	CLRF	PORTD,A	;PORTD = 0
	GOTO	ORIG
	
	ORG	0x300
LED_COOL:
	MOVLW	0x1
	MOVWF	PORTD,A	;PORTD = 1
	GOTO	ORIG
	
	ORG	0x400
LED_HOT:
	MOVLW	0x2
	MOVWF	PORTD,A	;PORTD = 2
	GOTO	ORIG
	
	
	ORG	0x500
refTempd:
	MOVLW	0xA
D1:	INCF	0x30,A	;Adds 1 to REG30
	SUBWF	refTemp,F,A ;Subtracts 10 decimal from refTemp
	BNN	D1  ;Checks to see if negative bit in status is not set
	ADDWF	refTemp,F,A ;Adds 10 decimal to refTemp if refTemp is negative
	DECF	0x30,A	;Subtracts one from REG30
	MOVFF	refTemp,REG70	;Moves value in refTemp into REG70
D2:	INCF	0x31,A
	SUBWF	0x30,F,A
	BNN	D2
	ADDWF	0x30,F,A
	DECF	0x31,A
	MOVFF	0x30,REG71
D3:	INCF	0x32,A
	SUBWF	0x31,F,A
	BNN	D3
	ADDWF	0x31,F,A
	DECF	0x32,A
	MOVFF	0x32,REG72
	GOTO	BACK2
	
	
	ORG	0x600
measuredTempd:
	MOVLW	0x79
	CPFSGT	measuredTemp,A	;if measuredTemp > 79 then measuredTemp is negative
	GOTO	BN1 
	GOTO	BN2
BN1:	MOVLW	0xA ;This block is for if measuredTemp < 79
B1:	INCF	0x40,A
	SUBWF	measuredTemp,F,A
	BNN	B1
	GOTO	BN4
BN2:	MOVLW	0xA ;This block is for if measuredTemp > 79
	NEGF	measuredTemp,A	;Does 2s compliment to measuredTemp
BN3:	INCF	0x40,A
	SUBWF	measuredTemp,F,A
	BNN	BN3
BN4:	ADDWF	measuredTemp,F,A
	DECF	0x40,A
	MOVFF	measuredTemp,REG60
B2:	INCF	0x41,A
	SUBWF	0x40,F,A
	BNN	B2
	ADDWF	0x40,F,A
	DECF	0x41,A
	MOVFF	0x40,REG61
B3:	INCF	0x42,A
	SUBWF	0x41,F,A
	BNN	B3
	ADDWF	0x41,F,A
	DECF	0x42,A
	MOVFF	0x42,REG62
	GOTO	BACK
	
	ORG	0x1000
HERE:
	MOVLW	measuredTempInput   
	MOVWF	measuredTemp,A	;Restores measuredTemp
	MOVLW	refTempInput
	MOVWF	refTemp,A   ;Restores refTemp
	SLEEP	;Turns of clocks
