$NOMOD51
$INCLUDE (8051.MCU)

ORG 0000H

MOV DPTR, #300H
;//MOV P0,#01H
CLR P2.4                            
CLR P2.6
ACALL DELAY
SETB P2.6
SETB P2.5
SETB P2.7
CLR P2.5                               ;initializing ADC

C1: CLR A
MOVC A, @A+DPTR
ACALL lcd_command
ACALL DELAY
JZ CONDITION
INC DPTR
SJMP C1                         ;initializing LCD

CONDITION: MOV A,P0
COMP:CJNE A,#76,COND
SJMP NOTDRUNK                             ;condition to check drunk state

COND: ;JC DRUNK
SJMP DRUNK

DRUNK:                                             

MOV TMOD,#00100001B        
MOV TH1,#253D           
MOV SCON,#50H          
SETB TR1

MOV DPTR, #230H                    ; GSM module initializing
   MOV R2,#02
   ACALL TRANS
   MOV A,#0DH
   ACALL SEND
   ACALL DELAY16

MOV DPTR,#250H                 ;setting gsm module to sms mode
   MOV R2,#09
   ACALL TRANS
   MOV A,#0DH
   ACALL SEND
   ACALL DELAY16
  
MOV DPTR,#270H               ;sending mobile number to GSM module
   MOV R2,#08
   ACALL TRANS
   ACALL DELAY16

MOV DPTR,#280H            ;sending number to GSM module
   MOV R2,#13
   MOV A,#34D
   ACALL SEND
   ACALL TRANS
   MOV A,#34D
   ACALL SEND
   MOV A,#0DH
   ACALL SEND
   ACALL DELAY16

MOV DPTR,#320H                   ;sending message to mentioned phone number
   MOV R2,#05
   ACALL TRANS
   ACALL DELAY
   
 MOV DPTR,#320H                 ;displaying drunk state on LCD
BACK:CLR A
MOVC A, @A+DPTR
ACALL lcd_data
CLR P3.2                                 ;motor stops
ACALL DELAY
INC DPTR
JZ EXIT
SJMP BACK

EXIT: SJMP EXIT

NOTDRUNK: MOV DPTR,#340H            ;if not drunk , display on LCD
BACK1:CLR A
MOVC A, @A+DPTR
ACALL lcd_data
SETB P3.2                                               ;motor runs
ACALL DELAY
INC DPTR
JZ EXIT1
SJMP BACK1

EXIT1: SJMP EXIT1

lcd_command:                                    ;commands for lCD display
MOV P1,A
CLR P2.0
CLR P2.1
SETB P2.2
ACALL DELAY
CLR P2.2
RET

lcd_data:                                       
MOV P1,A
SETB P2.0
CLR P2.1
SETB P2.2
ACALL DELAY
CLR P2.2
RET

DELAY: MOV R3,#0FFH
L2: MOV R4,#0FFH
HERE: DJNZ R4,HERE
DJNZ R3,L2
RET

TRANS:                                        ;for transmission of GSM commands
L:MOVC A,@A+DPTR
       ACALL SEND
       INC DPTR
       DJNZ R2,L
       RET

SEND:CLR TI                                 ;transmission of GSM data
     MOV SBUF,A
WAIT4:JNB TI,WAIT4
     RET

DELAY16:MOV R6,#15D       
BACK16: MOV TH0,#00000000B   
      MOV TL0,#00000000B   
      SETB TR0             
HERE16: JNB TF0,HERE16        
      CLR TR0              
      CLR TF0             
      DJNZ R6,BACK16
      RET
      
ORG 230H 
DB "AT" 
ORG 250H 
DB "AT+CMGF=1" 
ORG 270H 
DB "AT+CMGS=" 
ORG 280H 
DB "+919672084395" 
ORG 300H
DB 38H,0EH,01H,06H,80H,0
ORG 320H
DB'DRUNK', 0
ORG 340H
DB 'NOT DRUNK',0

END
