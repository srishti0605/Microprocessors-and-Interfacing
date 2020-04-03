.model tiny
.data
    STARTING_IP DW ?   
    PORTA EQU 00H
    PORTB EQU 02H
    PORTC EQU 04H  
    CREG EQU 06H
    MODENO DB 00H
    STACK DW 100 DUP(?)
    TOP_STACK LABEL WORD   
.code
.startup 
    
    MOV AX,200H         ;MOVE SS,ES,DS TO START OF RAM
    MOV DS,AX
    MOV SS,AX
    MOV ES,AX 
    LEA SP, TOP_STACK   ;---STORE THE ISR ADDRESS OF THE NMI(STOP) IN THE IVT
    MOV AX,0
    MOV ES,AX
    ;calculate vector address for interrupt 02H(NMI)
    MOV AL,02H
    MOV BL,04H
    MUL BL
    MOV BX,AX
    
    MOV SI,OFFSET [STOP_BUTTON]
    MOV ES:[BX],SI
    ADD BX,2
    
    MOV AX,0000
    MOV ES:[BX],AX  
    MOV AL,10010000B        ;programming the 8255
   
    OUT CREG,AL
    POLL_START:   
    MOV AL,08H
    OUT PORTC,AL
    MOV AX,OFFSET [POLL_START]
    MOV STARTING_IP,AX
    
    MOV AL,03H
    OUT PORTB,AL            ;initially no output device in PORT B(agitator,buzzer) should be ON
   
      
    
    START:                  ;polling the START button
        MOV AL,00H
        MOV MODENO,AL       ;**moving 0 into mode number
        IN AL, PORTA
        CMP AL, 11111110B
        JNZ START  
        CALL DEBOUNCE_DELAY   
        MOV AL,00H
        MOV MODENO,AL       ;**moving 0 into mode number
        IN AL, PORTA
        CMP AL, 11111110B  ;after start button comes up then only proceed
        MOV AL,00000000B
       OUT PORTC,AL      
    
    LOAD:                   ;polling the LOAD button and DOOR_LOCK switch 
        IN AL, PORTA
        CMP AL, 11101111B   ;if DOOR is locked(means mode of operation has been selected)
        JZ LOADEXIT
        CMP AL, 11111011B   
        JNZ LOAD
        INC BYTE PTR MODENO ;if LOAD button is pressed increase the MODE number
        CALL DEBOUNCE_DELAY ;one press of LOAD button should only raise MODE number by 1
    JMP LOAD
    LOADEXIT:
    ;Storing the MODE in AH
    MOV AH, MODENO
    MOV BL, 00H
    MOV MODENO, BL
    CMP AH, 00H             ;checking if mode is selected before closing of door
    JZ LOAD                 
    CMP AH, 03H             ;checking if mode number selected is valid
    JG LOAD                 
    MOV MODENO, AH
    OUT1: 
    CMP AH, 01H             ;displaying on the 7 segment display
    JNE OUT2
    MOV AL, 01H
    OUT PORTC, AL
    JMP LIGHT
    OUT2:
    CMP AH, 02H
    JNE OUT3
    MOV AL, 02H
    OUT PORTC, AL
    JMP MED
    OUT3:
    MOV AL, 03H
    OUT PORTC, AL
    JMP HEAVY
    LIGHT:                  ;LIGHT MODE
        CALL WATER_MAX      ;sensing if water level is max
        MOV AL,00000010b         ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,2
        X1:CALL DELAY_1m    ;rinse cycle runs for 2 minutes
        LOOP X1
        MOV AL,00000011b
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully 
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        CALL DELAY_1m       ;ASSUMPTION: USER PUTS DETERGENT IN 1 MINUTE
	TO:	IN AL,PORTA
	    CMP AL,11001111B; CHECKING FOR DOOR CLOSE AFTER DETERGENT
		JNZ TO
        
        MOV AL,00000010b         ;wash cycle
        OUT PORTB,AL
        MOV CX,3
        X2:CALL DELAY_1m    ;wash cycle runs for 3 minutes
        LOOP X2
        MOV AL,00000011B
        OUT PORTB,AL
        CALL BUZZER_WASH    ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully  
        CALL WATER_MAX      ;check if water is at max level again for wash cycle      
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY 
		
	M1:	IN AL,PORTA
	    CMP AL,11001111B; CHECKING FOR DOOR CLOSE AGAIN
		JNZ M1
        
        MOV AL,00000010B          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,2
        X3:CALL DELAY_1m    ;rinse cycle runs for 2 minutes
        LOOP X3
        MOV AL,00000011B
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        
        MOV AL,00000001B          ;dry cycle
        OUT PORTB,AL        ;activating the revolving tub
        MOV CX,2
   X4:	CALL DELAY_1m    ;dry cycle runs for 2 minutes
        LOOP X4
        MOV AL,00000011B
        OUT PORTB,AL
        CALL BUZZER_DRY
        JMP DONE_WASHING
        
    MED:                 ;MEDIUM MODE
        CALL WATER_MAX      ;sensing if water level is max
        MOV AL,00000010B          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,3
        X5:CALL DELAY_1m    ;rinse cycle runs for 3 minutes
        LOOP X5
        MOV AL,00000011B
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        CALL DELAY_1m       ;ASSUMPTION: USER PUTS DETERGENT IN 1 MINUTE
	M2: IN AL,PORTA
	    CMP AL,11001111B; CHECKING FOR DOOR CLOSE AFTER DETERGENT
		JNZ M2
        
        MOV AL,00000010B       ;wash cycle
        OUT PORTB,AL
        MOV CX,5
        X6:CALL DELAY_1m    ;wash cycle runs for 5 minutes
        LOOP X6
        MOV AL,00000011B
        OUT PORTB,AL
        CALL BUZZER_WASH    ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
		CALL DEBOUNCE_DELAY  
		
	M3: IN AL,PORTA
	    CMP AL,11001111B; CHECKING FOR DOOR CLOSE AGAIN
		JNZ M3
        
        MOV AL,00000010B          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,3
        X7:CALL DELAY_1m    ;rinse cycle runs for 3 minutes
        LOOP X7
        MOV AL,00000011B
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        
        MOV AL,00000001B         ;dry cycle
        OUT PORTB,AL        ;activating the revolving tub
        MOV CX,4
        X8:CALL DELAY_1m    ;dry cycle runs for 4 minutes
        LOOP X8
        MOV AL,00000011B
        OUT PORTB,AL
        CALL BUZZER_DRY
        JMP DONE_WASHING
    HEAVY:                  ;HEAVY MODE
        CALL WATER_MAX      ;sensing if water level is max
        MOV AL,00000010B          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,3
        X9:CALL DELAY_1m    ;rinse cycle runs for 3 minutes
        LOOP X9
        MOV AL,00000011B
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle      
		CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        CALL DELAY_1m       ;ASSUMPTION: USER PUTS DETERGENT IN 1 MINUTE
    M4: IN AL,PORTA         ; CHECK FOR DOOR CLOSE AFTER DETERGENT
        CMP AL,11001111B
        JMP M4
		
        MOV AL,00000010B          ;wash cycle
        OUT PORTB,AL
        MOV CX,5
        X10:CALL DELAY_1m    ;wash cycle runs for 5 minutes
        LOOP X10
        MOV AL,00000011B
        OUT PORTB,AL
        CALL BUZZER_WASH    ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY
		
	M5: IN AL,PORTA         ; CHECK FOR DOOR CLOSE AGAIN
        CMP AL,11001111B
        JMP M5
        MOV AL,00000010B          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,3
    X11:CALL DELAY_1m    ;rinse cycle runs for 3 minutes
        LOOP X11
        MOV AL,00000011B
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
	M6: IN AL,PORTA         ; CHECK FOR DOOR CLOSE AGAIN
        CMP AL,11001111B
        JMP M6
        
        MOV AL,0000010B         ;wash cycle
        OUT PORTB,AL
        MOV CX,5
    X12:CALL DELAY_1m    ;wash cycle runs for 5 minutes
        LOOP X12
        MOV AL,00000011B
        OUT PORTB,AL
        CALL BUZZER_WASH    ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL WATER_MAX      ;check if water is at max level again for wash cycle       
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY
	M7: IN AL,PORTA         ; CHECK FOR DOOR CLOSE AGAIN
        CMP AL,11001111B
        JMP M7	
      
        MOV AL,00000010B          ;rinse cycle
        OUT PORTB,AL        ;activating the agitator
        MOV CX,3
    X13:CALL DELAY_1m    ;rinse cycle runs for 3 minutes
        LOOP X13
        MOV AL,00000011B
        OUT PORTB,AL        ;stop rinse cycle(i.e. stop agitator)
        CALL BUZZER_RINSE   ;play the buzzer for 1 minute
        
        CALL WATER_MIN      ;check if water has drained fully
        CALL CHECK_RESUME   ;check if resume button is pressed   
        CALL DEBOUNCE_DELAY ;only when resume button comes up, proceed
        
        MOV AL,00000001B          ;dry cycle
        OUT PORTB,AL        ;activating the revolving tub
        MOV CX,4
    X14:CALL DELAY_1m   ;dry cycle runs for 4 minutes
        LOOP X14
        MOV AL,00000011B
        OUT PORTB,AL
        CALL BUZZER_DRY
        JMP DONE_WASHING
                
    DONE_WASHING:
        JMP POLL_START
    
   
    STOP_BUTTON:              ;this procedure is an ISR for NMI(STOP button)
        MOV BP,SP
        MOV AL,00000011b
        OUT PORTB,AL
		mov al,00000000b
        OUT PORTC,AL
		jmp poll_start
        ;RET               ;now the IP address popped will be of the starting line of program
.exit

STORE_IP PROC NEAR          ;this procedure will store the IP address
    MOV BP,SP               ;of the label POLL_START
    MOV AX,[BP]
    MOV STARTING_IP,AX
    RET
STORE_IP ENDP



DEBOUNCE_DELAY PROC NEAR    ;this procedure checks all the buttons and
    DEBOUNCE:               ;returns only of all the buttons are up
        IN AL,PORTA
        OR AL,11110000B
        CMP AL,11111111B
        JNZ DEBOUNCE
    RET
DEBOUNCE_DELAY ENDP

INITIALIZE_INT PROC NEAR
    MOV AX, 0
    MOV ES, AX
    CLI
    MOV WORD PTR ES:[320], OFFSET INT50H
    MOV WORD PTR ES:[322], CS
    STI  
    MOV AX, 0
    RET
INITIALIZE_INT ENDP 

INT50H PROC FAR
    ;int 3
    MOV AL, 08H
    OUT PORTC, AL
    IRET
INT50H ENDP 

DELAY_1m PROC NEAR          ;this procedure is used to generate a delay of 1 minute
    PUSH CX                 ;for simulation purpose 1 minute(virtual) = 10 seconds(real)
    MOV BX,00E5H
    L2:MOV CX,0FFFFH
    L1:NOP
        LOOP L1
        DEC BX
        JNZ L2
    POP CX
        RET
DELAY_1m ENDP

WATER_MAX PROC NEAR         ;this procedure checks if water level is max
                            ;water level is max when the pressure sensitive switch(WATER_MAX) is pressed
    CHECK1:
        IN AL,PORTA
		NOT AL
		AND al,00100000B
        CMP AL,00100000B
    JNE CHECK1 
    RET
WATER_MAX ENDP 

WATER_MIN PROC NEAR        ; this procedure checks if water level is min
                                                      ;water level is min when the pressure sensitive switch(WATER_MIN) is pressed
    CHECK2:
        IN AL,PORTA
		NOT AL
        AND AL,01000000B
        CMP AL,01000000B
		JNE CHECK2 
    RET
WATER_MIN ENDP

BUZZER_RINSE PROC NEAR      ;this procedure activates a buzzer after rinse cycle in complete
    MOV AL,00010011b
    OUT PORTB,AL
    CALL DELAY_1m
    MOV AL,03H
    OUT PORTB,AL
    RET
BUZZER_RINSE ENDP

BUZZER_WASH PROC NEAR       ;this procedure activates a buzzer after wash cycle in complete
    MOV AL,00001011B
    OUT PORTB,AL
    CALL DELAY_1m
    MOV AL,00000011B
    OUT PORTB,AL
    RET
BUZZER_WASH ENDP 

BUZZER_DRY PROC NEAR        ;this procedure activates a buzzer after dry cycle in complete
    MOV AL,00000111B
    OUT PORTB,AL
    CALL DELAY_1m
    MOV AL,00000011B
    OUT PORTB,AL
    RET
BUZZER_DRY ENDP
                            
CHECK_RESUME PROC NEAR      ;this procedure checks if resume button is pressed or not
    
    CHECKR:
        IN AL,PORTA
		NOT AL
        AND AL,00001000B
		CMP AL,00001000B
        JNE CHECKR     
    RET
CHECK_RESUME ENDP


end
