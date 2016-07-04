;**********************************************************************
; AUTHOR:  David Scott
; VERSION: 11/29/15
; PURPOSE: Binary clock.  Seconds LEDs are driven thru a 74HC393 chip.
;      All other LEDs driven directly.
;
;  This project/work consists of a electronic circuit, an associated
;  circuit board design, microcontroller program (software) and supporting
;  documents/information.  Users are free to modify and/or utilize this
;  project for any non-commercial use.  THERE IS NO WARRANTY.  ANY PART
;  OF OR THE ENTIRE PROJECT/WORK, AS-IS OR AFTER MODIFICATION, MAY BE
;  UNFIT FOR USE, UNSAFE OR DANGEROUS.  USE AT YOUR OWN RISK!  This
;  project/work is licensed under the Creative Commons Attribution-
;  NonCommercial-ShareAlike 4.0 International License. To view a copy of
;  this license, visit http://creativecommons.org/licenses/by-sa/4.0/
;  or send a letter to Creative Commons, PO Box 1866, Mountain View,
;  CA 94042, USA.
;
;**********************************************************************
;    Files Required: P16F57.INC
;**********************************************************************
; PROGRAM NOTES:
;
;	TMR0 overflows to zero approx. every 20msec.  (4MHz crystal)
;	Timing is calculated in "BinClk Timing.xls".
;
; I/O:  (16F57)
;   PORTC 7  Minutes(1)
;         6  Minutes(2)
;   PORTA 0  Minutes(4)
;         1  Minutes(8)
;         2  Minutes_Tens(4)
;         3  Minutes_Tens(2)
;   PORTB 0  Minutes_Tens(1)
;         1  Hours(1)
;         2  Hours(2)
;         3  Hours(4)
;         4  Hours(8)
;         5  Hours_Tens(1)
;   PORTC 4  Clear input on 74HC393.
;         5  Pulse (clock) input on 74HC393.
; All other I/O are unused and set as outputs and High.
;
; REVISION HISTORY:
;	8/23/13	Begin with Ding2.asm from 2004. ds
;   11/30/13  Add comments and code cleanup.  ds
;   4/18/15  Adjusted timing.  ds
;   5/17/15  Start Ver7. Adding "Fade" for change of time displayed. ds
;   11/29/15  Implemented Fade for minutes. ds
;
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	  #include <P16F57.inc>         ; processor specific variable definitions
      LIST P=16F57, F=INHX8M, R=DEC

;; Removing crossing page boundary messages (always happens during startup)
	errorlevel -306
	__CONFIG   _CP_OFF & _WDT_OFF & _XT_OSC; & _PWRT_ON

;***** VARIABLE DEFINITIONS
;P16F57
; Shared registers:  08h (8) thru 0Fh (15)  [8 registers]
; Paged registers:  10h thru 1Fh (16 thru 31, 16 registers)
;                   also 3Fh-30h, 5Fh-50h, 7Fh-70h  (64 total paged registers)
Count_RTC_1s equ 8		;cycles thru main loop, every 20 msec
				;???? cycles = 1 sec.
Count_Secs_RTC equ 9		;seconds, RTC
Count_Mins_RTC equ 18       ;minutes, actual RTC, new value for fade
Count_Hrs_RTC equ 20        ;hours, actual RTC, new value for fade

Count_Mins_Old equ 19       ;minutes, old value for fade
Count_Hrs_Old equ 21        ;hours, old value for fade

CountNew equ 22             ;Counters for fade routine.
CountOld equ 23
K equ 24

Disp_Mins equ 10		;minutes to be displayed
Disp_Hrs equ 13       ;hours to be displayed
Disp_MinsOnes equ 11
Disp_MinsTens equ 12

Count_DisplaySeconds equ 14     ;Used for count of whether to display seconds or not.

; other registers
SysStatus equ 15	;status register
    Constant CountUpSecondsLEDs=0
    Constant FadeHrsON=1
    Constant FadeMinsON=2
    Constant FadeHrsNext=3
    Constant FadeMinsNext=4
            ;<5>  to <7>  Unused
DCount equ 16 ;in a different bank from other variables!  (Nope-not really!
              ;(DScott 5/17/15.  First group of 16 is in the same bank.)
DCountHi equ 17

  Constant TMR0_INIT=91	;  one TMR0 overflow from TMR0_INIT to 256
  Constant TMR0_REINIT=100	;  N-1 overflows from TMR0_REINIT to 256
  				;  This value cannot be zero.  Otherwise TMR0 will
				;  automatically reenter main loop upon return to
				;  PollTMR0 if TMR0 hasn't incremented yet.
  Constant N=50
  Constant COUNT_NEW=1  ;Count to start displaying new value for fade
  Constant COUNT_OLD=17 ;Count to start displaying old value for fade
;**********************************************************************
		ORG     0x7FF             ; processor reset vector
RESET CODE 0x00
        goto MainLine

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;  Subroutines

DisplaySeconds_Update

  bcf PORTC, 4
  bsf PORTC, 5    ;Send a 20 msec pulse on this pin to the counter IC so it will
  call DelaySubMsec   ;count another second.
  call DelaySubMsec
  call DelaySubMsec
  bcf PORTC, 5

  Return
;............................

ClearSecondsDisplay

  bsf PORTC, 4    ;Send a 20 msec pulse on this pin to the counter IC
  call DelaySubMsec   ;to clear out the counter.
  call DelaySubMsec
  call DelaySubMsec
  bcf PORTC, 4

  Return

;............................
FadeMins

  movf CountNew, w
  movwf K
  movf Count_Mins_RTC, w    ;display new pattern for CountNew delays
  movwf Disp_Mins
  call DisplayMinutes_Update
  call DelaySubMsec
  decfsz K, f
    goto $-2
  
  movf CountOld, w    ;display old pattern for CountOld delays
  movwf K
  movf Count_Mins_Old, w
  movwf Disp_Mins
  call DisplayMinutes_Update
  call DelaySubMsec
  decfsz K, f
    goto $-2

  incf CountNew, f      ;Update conters & bail if complete.
  incf CountNew, f
  decfsz CountOld, f
    Goto FadeMinsComplete   ;Fade is not yet complete, leave fade active

  bcf SysStatus, FadeMinsON     ;Fade is complete, turn fade OFF.
  movf Count_Mins_RTC, w
  movwf Count_Mins_Old
  movf Count_Mins_RTC, w     ;finally leave display with PatternNew
  movwf Disp_Mins
  call DisplayMinutes_Update

FadeMinsComplete
  Return
;..............................
FadeHrsMins

  Return
;............................
DisplayMinutes_Update
;Display the value in Count_Mins on the LEDs.
  movf Disp_Mins, w
  movwf Disp_MinsOnes
  clrf Disp_MinsTens
Next
  movlw 10
  subwf Disp_MinsOnes, w
  btfss STATUS, C
    Goto LessThan10
  incf Disp_MinsTens, f
  movlw 10
  subwf Disp_MinsOnes, f
  btfsc STATUS, C  ;shud always be set if it reaches here
    goto Next

LessThan10
;  bcf PORTC, 7
;  bcf PORTC, 6
;  bcf PORTA, 0
;  bcf PORTA, 1
;  bcf PORTB, 0
;  bcf PORTA, 3
;  bcf PORTA, 2
  btfss Disp_MinsOnes, 0
    bcf PORTC, 7
  btfss Disp_MinsOnes, 1
    bcf PORTC, 6
  btfss Disp_MinsOnes, 2
    bcf PORTA, 0
  btfss Disp_MinsOnes, 3
    bcf PORTA, 1
  btfss Disp_MinsTens, 0
    bcf PORTB, 0
  btfss Disp_MinsTens, 1
    bcf PORTA, 3
  btfss Disp_MinsTens, 2
    bcf PORTA, 2

  btfsc Disp_MinsOnes, 0
    bsf PORTC, 7
  btfsc Disp_MinsOnes, 1
    bsf PORTC, 6
  btfsc Disp_MinsOnes, 2
    bsf PORTA, 0
  btfsc Disp_MinsOnes, 3
    bsf PORTA, 1
  btfsc Disp_MinsTens, 0
    bsf PORTB, 0
  btfsc Disp_MinsTens, 1
    bsf PORTA, 3
  btfsc Disp_MinsTens, 2
    bsf PORTA, 2

  Return
;...............................
DisplayHours_Update
;Display the value in Disp_Hrs on the LEDs.
  bcf PORTB, 1
  bcf PORTB, 2
  bcf PORTB, 3
  bcf PORTB, 4
  bcf PORTB, 5

  movlw 10
  subwf Disp_Hrs, w
  btfss STATUS, C
    Goto NineOrLess
  btfsc Disp_Hrs, 2
    Goto Equals12
  btfsc Disp_Hrs, 0
    goto Equals11
Equals10
  bsf PORTB, 5
  goto EndHrsUpdate
Equals11
  bsf PORTB, 5
  bsf PORTB, 1
  goto EndHrsUpdate
Equals12
  bsf PORTB, 5
  bsf PORTB, 2
  goto EndHrsUpdate
NineOrLess
  btfsc Disp_Hrs, 0
    bsf PORTB, 1
  btfsc Disp_Hrs, 1
    bsf PORTB, 2
  btfsc Disp_Hrs, 2
    bsf PORTB, 3
  btfsc Disp_Hrs, 3
    bsf PORTB, 4

EndHrsUpdate
  Return
;.............................

Delay198m				;198 msec delay
;  32.768 kHz	DCount=181	DCountHi=1
;  4 MHz	DCount=255	DCountHi=255

  movlw  255
  movwf  DCount
  movlw  255
  movwf  DCountHi

  decfsz DCount, f
    goto $-1
  decfsz DCountHi,f
    goto $-3

  return
;..........................
DelaySubMsec			; msec delay
;  32.768 kHz	DCount=181	DCountHi=1
;  4 MHz	DCount=255	DCountHi=26

  movlw  2
  movwf  DCount
  movlw  1
  movwf  DCountHi

  decfsz DCount, f
    goto $-1
  decfsz DCountHi,f
    goto $-3

  return
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;  PollTMR0 and Main Loop
PollTMR0    ;TMR0 is timer zero, it is always running per the XTAL.

  btfss SysStatus, FadeHrsNext
    goto $+3
  bsf SysStatus, FadeHrsON
  bcf SysStatus, FadeHrsNext
  btfss SysStatus, FadeMinsNext
    goto $+3
  bsf SysStatus, FadeMinsON
  bcf SysStatus, FadeMinsNext

  btfss SysStatus, FadeHrsON
    goto $+7
  movf Count_Hrs_RTC, w
  movwf Disp_Hrs
  movf Count_Mins_RTC, w
  movwf Disp_Mins
  call FadeHrsMins
  goto NoFade

  btfss SysStatus, FadeMinsON
    goto $+4
  movf Count_Mins_RTC, w
  movwf Disp_Mins
  call FadeMins

NoFade
  movf TMR0, 0			;If TMR0=0, it's been 20msec - go on to main loop
  btfss STATUS, Z
    goto $-2        ;Not zero, go back two lines.

; This is the MAIN LOOP!
  movlw TMR0_REINIT     ;Restart TMR0 with this value.
  movwf TMR0

  decfsz Count_RTC_1s, f  ;Has it been 1.000 second yet?
    goto PollTMR0         ;No.  Go back and poll TMR0 more.

;It's been a second!
  movlw 7              ; Need 14 instruction cycle delay
  movwf DCount	    	; delay  = 2 + (2 X DCount)	[in cycles]

  decfsz DCount, f
    goto $-1

  movlw TMR0_INIT     ;Restart TMR0 with this value.
  movwf TMR0
  movlw N             ;It takes this many to get to 1.000 second.
  movwf Count_RTC_1s

  Incf Count_Secs_RTC, f		;It's been a second, so increment Count_Secs.

  movlw 60            ;has it been 60 seconds?
  subwf Count_Secs_RTC, w
  btfss STATUS, C	;C will be set if Count_Sec>59
    goto NotAMinute	; Count_Sec is 59 or lower

  clrf Count_Secs_RTC		;It's been 60 seconds, so clear out Count_Secs.
  call ClearSecondsDisplay    ;Clear the display also.
  incf Count_Mins_RTC, f          ;Increment Count_Mins.
  incf Count_DisplaySeconds, f   ;Increment this value to keep track of when we
                                 ;display the seconds counting up on the LEDs.
  bsf SysStatus, CountUpSecondsLEDs	;default is not to display, if it's been 5 minutes will change

  movlw 5		;has it been 5 minutes for displaying seconds?
  subwf Count_DisplaySeconds, w
  btfss STATUS, C
    goto NoSecondsDisplay
  bcf SysStatus, CountUpSecondsLEDs    ;Yes display seconds
  clrf Count_DisplaySeconds

NoSecondsDisplay
  movlw 60		;has it been 60 minutes?
  subwf Count_Mins_RTC, w
  btfss STATUS, C	;C will be set if Count_Min>59
    goto NotAnHour

  incf Count_Hrs_RTC, f		;It's been 60 minutes, so increment Count_Hrs.
  clrf Count_Mins_RTC
  movlw 13              ;is Hours >12?
  subwf Count_Hrs_RTC, w
  btfss STATUS, C	;C will be set if Count_Hrs>12
    goto UpdateHoursDisplay
  clrf Count_Hrs_RTC	;It was 12 hours, but now it's higher.
  bsf Count_Hrs_RTC, 0  ;Now it's 1:00

UpdateHoursDisplay
  movf Count_Hrs_RTC, w
  movwf Disp_Hrs
  movf Count_Mins_RTC, w
  movwf Disp_Mins
  call DisplayHours_Update    ;Update the display of the hours on the LEDs.

NotAnHour
  bsf SysStatus, FadeMinsNext
  movlw COUNT_NEW
  movwf CountNew
  movlw COUNT_OLD
  movwf CountOld
  goto PollTMR0

NotAMinute
  btfss SysStatus, CountUpSecondsLEDs
    call DisplaySeconds_Update  ;If we're displaying seconds, update thoses LEDs.
  goto PollTMR0                 ;Go back to polling TMR0 to see if it's timed out.

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
MainLine			;initialize timing variables

;setup STATUS, TMR0 & I/O ports....

  clrf SysStatus			;Start with display of seconds turned ON.

  call Delay198m		;This delay added 7/31/99
  call Delay198m		;One of 2 16C84s using for development got different
  call Delay198m		;results for RCTime depending on POR or MCLR.
  call Delay198m		;This delay made that difference go away.
  call Delay198m
  call Delay198m

  movlw 0x0D6			; D6=1101 0110
                        ; TMRO from instruction cycle
                        ; prescaler for TMR0, prescaler=128
  option

;initializations
  movlw 0	;count secs
  movwf Count_Secs_RTC
;================SET START TIME HERE===================
  movlw 52   ;mins
  movwf Count_Mins_RTC
  movlw 5  ;hours
  movwf Count_Hrs_RTC
;================SET START TIME HERE===================
  movlw 0   ;display secs
  movwf Count_DisplaySeconds

  clrf Count_Mins_Old
  clrf Count_Hrs_Old

  movlw TMR0_INIT		;Initialize TMR0 value.
  movwf TMR0
  movlw N
  movwf Count_RTC_1s

  movlw 0x000			; 00=0000 0000
					; all outputs
  TRIS PORTA ;& 0x07F
  movlw 0x000			; 00=0000 0000
					; all outputs
  TRIS PORTB ;& 0x07F
  movlw b'00000000'			; 00=0000 0000
					; all outputs
  TRIS PORTC ;& 0x07F

  movf Count_Hrs_RTC, w
  movwf Disp_Hrs
  ;movf Count_Mins_RTC, w
  ;movwf Disp_Mins
  call DisplayHours_Update
  ;call DisplayMinutes_Update

  goto NotAnHour

;  goto PollTMR0

  end
;			Copyright 2015 David E. Scott