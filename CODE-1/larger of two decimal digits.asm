; =====================================================================
; PROGRAM INFORMATION
; =====================================================================
; Program Name  : Larger of Two Decimal Digits
; Processor     : Intel 8086 Microprocessor
; Emulator      : EMU8086
; Interrupt     : INT 21H
; =====================================================================
; Objective     :
;                 1. Display prompt "?"
;                 2. Accept two decimal digits from keyboard
;                 3. Compare the two digits
;                 4. Display the larger digit
; =====================================================================
;
; -------------------------------
; INPUT - PROCESS - OUTPUT
; -------------------------------
; Input   : Two decimal digits (e.g., 3 and 7)
; Process : Compare using CMP and conditional jump
; Output  : THE LARGER OF 3 AND 7 IS 7
;
; -------------------------------
; REGISTERS USED
; -------------------------------
; AX | Accumulator (16-bit)     | DOS functions & ASCII conversion
; AH | Accumulator High (8-bit) | Stores DOS function number
; AL | Accumulator Low (8-bit)  | Stores input character
; CL | Counter Low (8-bit)      | Stores first digit (numeric)
; CH | Counter High (8-bit)     | Stores second digit (numeric)
; DX | Data Register (16-bit)   | Holds address of string
; DL | Data Low (8-bit)         | Holds character for output
; DS | Data Segment Register    | Points to DATA segment
;
; -------------------------------
; DOS FUNCTIONS USED (INT 21H)
; -------------------------------
; AH = 01H -> Input Single Character (returned in AL)
; AH = 02H -> Display Single Character (character in DL)
; AH = 09H -> Display String (address in DX, ends with $)
; AH = 4CH -> Terminate Program
; =====================================================================

.MODEL SMALL
.STACK 100H

.DATA
    MSG1 DB 0DH,0AH,'THE LARGER OF $'
    MSG2 DB ' AND $'
    MSG3 DB ' IS $'

.CODE

MAIN PROC

    MOV AX,@DATA              ; Load DATA segment address into AX
    MOV DS,AX                 ; Initialize DS register

; -------------------------
; Display "?"
; -------------------------

    MOV DL,'?'                ; Load '?' into DL
    MOV AH,02H                ; DOS function: display character
    INT 21H                   ; Display '?'

; -------------------------
; Input First Digit
; -------------------------

    MOV AH,01H                ; DOS function: read character
    INT 21H                   ; AL = first digit (ASCII)
    MOV CL,AL                 ; CL = Counter Low, store first digit
    SUB CL,30H                ; Convert ASCII to numeric in CL

; -------------------------
; Input Second Digit
; -------------------------

    MOV AH,01H                ; DOS function: read character
    INT 21H                   ; AL = second digit (ASCII)
    MOV CH,AL                 ; CH = Counter High, store second digit
    SUB CH,30H                ; Convert ASCII to numeric in CH

; -------------------------
; Compare and Find Larger
; -------------------------

    MOV AL,CL                 ; Move first digit into AL
    CMP AL,CH                 ; CMP = Compare AL with CH
                              ; Sets flags without changing values
    JAE FIRST_LARGER          ; JAE = Jump if Above or Equal
                              ; If CL >= CH, jump to FIRST_LARGER

    MOV AL,CH                 ; Else AL = second digit (larger)
    JMP DISPLAY               ; Jump to display section

FIRST_LARGER:
    MOV AL,CL                 ; AL = first digit (larger or equal)

; -------------------------
; AL now holds larger digit (numeric)
; -------------------------

DISPLAY:

    ADD AL,30H                ; Convert numeric result to ASCII

; -------------------------
; Display MSG1 "THE LARGER OF "
; -------------------------

    PUSH AX                   ; PUSH = Save AX onto stack
                              ; Preserve AL (larger digit) before INT calls

    LEA DX,MSG1               ; Load address of MSG1
    MOV AH,09H                ; DOS function: display string
    INT 21H                   ; Display MSG1

; -------------------------
; Display First Digit
; -------------------------

    MOV DL,CL                 ; Move first digit (numeric) to DL
    ADD DL,30H                ; Convert to ASCII
    MOV AH,02H                ; DOS function: display character
    INT 21H                   ; Display first digit

; -------------------------
; Display MSG2 " AND "
; -------------------------

    LEA DX,MSG2               ; Load address of MSG2
    MOV AH,09H                ; DOS function: display string
    INT 21H                   ; Display MSG2

; -------------------------
; Display Second Digit
; -------------------------

    MOV DL,CH                 ; Move second digit (numeric) to DL
    ADD DL,30H                ; Convert to ASCII
    MOV AH,02H                ; DOS function: display character
    INT 21H                   ; Display second digit

; -------------------------
; Display MSG3 " IS "
; -------------------------

    LEA DX,MSG3               ; Load address of MSG3
    MOV AH,09H                ; DOS function: display string
    INT 21H                   ; Display MSG3

; -------------------------
; Display Larger Digit
; -------------------------

    POP AX                    ; POP = Restore AX from stack
                              ; Recover AL (ASCII of larger digit)

    MOV DL,AL                 ; Move ASCII result to DL
    MOV AH,02H                ; DOS function: display character
    INT 21H                   ; Display larger digit

; -------------------------
; Program Termination
; -------------------------

    MOV AH,4CH                ; DOS function: terminate program
    INT 21H                   ; Return control to DOS

MAIN ENDP
END MAIN
