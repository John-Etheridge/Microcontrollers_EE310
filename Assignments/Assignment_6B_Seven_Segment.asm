//-----------------------------
// Title: Seven Segment Display
//-----------------------------
// Purpose: This program will take an input from two switches. If the first switch is set on then the seven segment will increment and if the second switch is set on the seven segment will decrement.
// Dependencies: Config.inc
// Compiler: IDE v6.30
// Author: John Etheridge
// OUTPUTS: PORTD
// INPUTS: PORTB
// Versions:
//  	V1.0: todays date - 03/26/26
//  	V1.2: date - 03/31/26
//-----------------------------


;---------------------
; Initialization
;---------------------
#include ".\Segment.inc"
#include <xc.inc>

;--------------------
;  Program Inputs
;--------------------
#define	NUM0	0x3F
#define NUM1	0x06
#define	NUM2	0x5B
#define NUM3   0x4F
#define NUM4	0x66
#define NUM5   0x6D
#define NUM6	0x7D
#define	NUM7	0x07
#define NUM8	0x7F
#define NUM9	0x67
#define NUMA	0x77
#define NUMB	0x7C
#define NUMC	0x39
#define	NUMD	0x5E
#define NUME	0x79
#define NUMF	0x71
#define	INNERLOOP   0x10
#define OUTERLOOP   0x100
#define UPPERLOOP   0x120

;--------------------
;  Program Constants
;--------------------

REG10	EQU 0x10
REG11	EQU 0x11
REG12	EQU 0x12
REG20	EQU 0x20
REG21	EQU 0x21
REG22	EQU 0x22
REG23	EQU 0x23
REG24	EQU 0x24
REG25	EQU 0x25
REG26	EQU 0x26
REG27	EQU 0x27
REG28	EQU 0x28
REG29	EQU 0x29
REG2A	EQU 0x2A
REG2B	EQU 0x2B
REG2C	EQU 0x2C
REG2D	EQU 0x2D
REG2E	EQU 0x2E
REG2F	EQU 0x2F
	
;---------------------
; Program Organization
;---------------------
    PSECT absdata,abs,ovrld        ; Do not change

    ORG          0                ;Reset vector
    GOTO        _setup

    ORG          0020H           ; Begin assembly at 0020H
    
;---------------------
;  Main Program
;---------------------
    
_setup:
    MOVLW   NUM0
    MOVWF   REG20
    MOVLW   NUM1
    MOVWF   REG21
    MOVLW   NUM2
    MOVWF   REG22
    MOVLW   NUM3
    MOVWF   REG23
    MOVLW   NUM4
    MOVWF   REG24
    MOVLW   NUM5
    MOVWF   REG25
    MOVLW   NUM6
    MOVWF   REG26
    MOVLW   NUM7
    MOVWF   REG27
    MOVLW   NUM8
    MOVWF   REG28
    MOVLW   NUM9
    MOVWF   REG29
    MOVLW   NUMA
    MOVWF   REG2A
    MOVLW   NUMB
    MOVWF   REG2B
    MOVLW   NUMC
    MOVWF   REG2C
    MOVLW   NUMD
    MOVWF   REG2D
    MOVLW   NUME
    MOVWF   REG2E
    MOVLW   NUMF
    MOVWF   REG2F
    MOVLW   INNERLOOP
    MOVWF   REG10
    MOVLW   OUTERLOOP
    MOVWF   REG11
    MOVLW   UPPERLOOP
    MOVWF   REG12
    LFSR    1,REG20
    RCALL   _setupPortB
    RCALL   _setupPortD
    
    
_main:
    RCALL   _DELAY  ;Calls delay function
    BTFSC   PORTB, 0	;Checks to see if switch one is pressed
    RCALL   _INCR   ;If pressed Calls increment function
    BTFSC   PORTB, 1	;Checks to see if swich two is pressed
    RCALL   _DECR   ;If pressed calls decrement function
    MOVLW   0x30
    CPFSLT  FSR1L   ;checks to see If address in pointer is less than 30
    RCALL   _RETURN ;If address is not less than 30 call return
    MOVLW   0x1F
    CPFSGT  FSR1L   ;checks to see if address in pointer is greater than 1F
    RCALL   _FORWARD	;If address is not greater than 1F call forward
    RCALL   _DISPLAY	;calls display function
    GOTO    _main   ;Returns to the top of the main loop
    
;-------------------------------------
; Call Functions
;-------------------------------------
    
_DELAY:
    DECF    REG10,1 ;Decrements inner loop
    BNZ	_DELAY	;If status does not equal zero, loop back to delay
    MOVLW   INNERLOOP	;Resets inner loop
    MOVWF   REG10
    DECF    REG11,1 // outer loop
    BNZ	_DELAY
    MOVLW   OUTERLOOP
    MOVWF   REG11
    DECF    REG12,1
    BNZ	_DELAY
    MOVLW   UPPERLOOP
    MOVWF   REG12
    RETURN
    
    
_setupPortD:
    BANKSEL	PORTD ;
    CLRF	PORTD ;Init PORTD
    BANKSEL	LATD ;Data Latch
    CLRF	LATD ;
    BANKSEL	ANSELD ;
    CLRF	ANSELD ;digital I/O
    BANKSEL	TRISD ;
    MOVLW	0b00000000 ;Set RD[7:1] as outputs
    MOVWF	TRISD ;and set RD0 as ouput
    RETURN

_setupPortB:
    BANKSEL	PORTB ;
    CLRF	PORTB ;Init PORTB
    BANKSEL	LATB ;Data Latch
    CLRF	LATB ;
    BANKSEL	ANSELB ;
    CLRF	ANSELB ;digital I/O
    BANKSEL	TRISB ;
    MOVLW   0xFF ;
    MOVWF   TRISB;
    RETURN
    
    
_INCR:
    BTFSC   PORTB,1 ;Checks to see if the second switch is also pressed
    GOTO    _RETURN ;If pressed go to restart
    INCF    FSR1L,1 ;If not pressed, increment pointer by 1
    RETURN
    

_DECR:
    BTFSC   PORTB,0 ;Checks to see if the first switch is also pressed
    GOTO    _RETURN ;If pressed go to restart
    DECF    FSR1L,1 ;If not pressed, decrement the pointer by 1
    RETURN
    
_RETURN:
    LFSR    1,REG20 ;Restarts the seven segment back to zero
    RETURN
    
_FORWARD:
    LFSR    1,REG2F ;If the seven segment decrements below zero it goes back to F
    RETURN
    
_DISPLAY:
    MOVLW   0x0	
    MOVFF   INDF1,WREG	;Moves value inside FSR1 into WREG
    MOVWF   PORTD   ;Moves value inside WREG into PORTD to display on seven segment
    RETURN
    
