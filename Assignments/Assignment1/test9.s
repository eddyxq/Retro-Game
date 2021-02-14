; This test program creates a score counter and pressing SPACE increments score by one
; Pressing Q exits the program
; Pressing R resets score back to 000

    processor 6502

    org $1001

    dc.w    nextstmt
    dc.w    10
    dc.b    158, "4109"
    dc.b    0

nextstmt
    dc.w    0


start
	jsr		$e55f	; Clear screen

initializeScoreText
	lda		#19		; S
	sta 	7693	; Memory location to display S on screen

	lda		#0		; Color Black
	sta 	38413	; Memory location for color 

	lda		#3		; C
	sta 	7694	; Memory location to display C on screen

	lda		#0		; Color Black
	sta 	38414	; Memory location for color 

	lda		#15		; O
	sta 	7695	; Memory location to display O on screen

	lda		#0		; Color Black
	sta 	38415	; Memory location for color 

	lda		#18		; R
	sta 	7696	; Memory location to display R on screen

	lda		#0		; Color Black
	sta 	38416	; Memory location for color 

	lda		#5		; E
	sta 	7697	; Memory location to display E on screen

	lda		#0		; Color Black
	sta 	38417	; Memory location for color 

	lda		#58		; : colon character
	sta 	7698	; Memory location to display : on screen

	lda		#0		; Color Black
	sta		38418	; Memory location for color 

showThreeZeroText
	lda		#48		; 0 char
	sta		7699	; Digit 3 0__

	lda		#2		; Color Red
	sta		38419	; Memory location for color that coresponds to score digit location

	lda		#48		; 0 char
	sta		7700	; Digit 2 _0_

	lda		#2		; Color Red
	sta		38420	; Memory location for color that coresponds to score digit location 

	lda		#48		; 0 char
	sta		7701	; Digit 1 __0

	lda		#2		; Color Red
	sta		38421	; Memory location for color that coresponds to score digit location

mainLoop
	lda		$00c5 	; Check for key press
	cmp		#32		; Check if its space
	beq		incrementScore

	cmp		#48		; Check for Q key press
	beq 	end		; Then end program

	cmp		#10		; Check for R key press
	beq		showThreeZeroText  ; Then set score to 000

	jmp		mainLoop


; Score increments works as follows:
; Check if the 1s digit before incrementing by 1 is a 9(code 57)
; If it is 9, set it to 0 then increment the 10s digit by one
; If 10s digit is 9 before increment, then set it to 0 and increment 100s digit by 1
; And so on...
; Max score possible is 999

incrementScore

incScoreDigitOne
	ldx		7701	; Read value from Digit 1s screen location
	cpx		#57		; Check if digit 1 is 9 before increment
	beq		digitOneisNine

	inx 			; Since digit is not 9, increment it

	txa				; If digit is not 9 then put X contents into A and updateScore
	jsr		updateScoreDigit1

	jmp 	setdelay


digitOneisNine
	lda		#48		; Load 0 into A to set Digit 1 to 0
	jsr		updateScoreDigit1

incScoreDigitTwo
	ldx		7700	; Read value from Digit 1s screen location
	cpx		#57		; Check if digit 1 is 9 before increment
	beq		digitTwoisNine

	inx 			; Since digit is not 9, increment it

	txa				; If digit is not 9 then put X contents into A and updateScore
	jsr		updateScoreDigit2

	jmp 	setdelay

digitTwoisNine
	lda		#48		; Load 0 into A to set Digit 2 to 0
	jsr		updateScoreDigit2

incScoreDigitThree
	ldx		7699	; Read value from Digit 3s screen location
	cpx		#57		; Check if digit 1 is 9 before increment
	beq		digitThreeisNine

	inx 			; Since digit is not 9, increment it

	txa				; If digit is not 9 then put X contents into A and updateScore
	jsr		updateScoreDigit3

	jmp setdelay

digitThreeisNine
	lda		#57		; Load 0 into A to set Digit 3 to 0
	jsr		updateScoreDigit3

	jmp 	setdelay




setdelay
	lda 	#200			;200 cycles of outer loop
	jmp 	busyloop			;delay next input


busyloop:
	cmp 	#0				;a=0?
	beq 	mainLoop			;go back to main loop
	ldx 	#100			;100 cycles of inner loop, total 20000 cycles (200*100)
	jmp 	decrement			;go to decrement

decrement
	dex						;y-=1
	cpx 	#0				;y=0?
	bne 	decrement			;go back decrement loop
	sbc 	#1		 		;a-=1
	jmp 	busyloop			;go back to busy loop



; Store updated score digits to their respective memory locations
updateScoreDigit1
	sta		7701	; Digit 1 __0

	lda		#2		; Color Red
	sta		38421
	rts

updateScoreDigit2
	sta		7700	; Digit 2 _0_

	lda		#2		; Color Red
	sta		38420
	rts

updateScoreDigit3
	sta		7699	; Digit 3 0__

	lda		#2		; Color Red
	sta		38419
	rts




end
	jsr		$e55f	; Clear screen
	rts