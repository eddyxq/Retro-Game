; test program that moves the player 'X' left and right with 'A' and 'D' keys

	processor 6502			;specify 6502 processor
	org $1001			;beginning of our memory

	dc.w	nextstmt
	dc.w	10
	dc.b	158, "4109"
	dc.b	0
nextstmt
	dc.w	0
	jsr $e55f			;clear screen
	
initplayer
	lda #24				;load player graphic 'X'
	sta $1fe4,x		 	;display player
	lda #0				;load black
	sta $97e4,x		 	;set player color to black
	
loop
	lda $00c5			;check if key is pressed
	cmp #17				;'A' key pressed?
	beq leftkeypress		;move left
	cmp #18				;'D' key pressed?
	beq rightkeypress		;move right
	cmp #9				;'W' key pressed?
	beq jumpkeypress		;not implemented yet, does nothing for now
	cmp #32				;'space' key pressed?
	beq clear			;clears the screen
	cmp #48				;'Q' key pressed?
	beq exit			;exits the game
	jmp loop			;infinite loop
	
leftkeypress
	cpx #$00	     		;left boarder collision?
	beq setdelay	 		;move valid?
	lda #1			 	;load white color
	sta $97e4,x		 	;erase previous position
moveleft	
	dex				;x-=1
	jmp updateposition		;draw player in new position

rightkeypress
	cpx #$15	     		;right boarder collision?
	beq setdelay	 		;move valid?
	lda #1			 	;load white color
	sta $97e4,x		 	;erase previous position
moveright	
	inx				 ;x+=1
	jmp updateposition		;draw player in new position

updateposition
	lda #24				;load player graphic 'X'
	sta $1fe4,x		 	;display player
	lda #0				;load black
	sta $97e4,x		 	;set player color to black
	jmp setdelay	 		;delay next input

jumpkeypress
	;not implemented yet, does nothing for now
	jmp setdelay			;delay next input

setdelay
	lda #200			;200 cycles of outer loop
	jmp busyloop			;delay next input	

busyloop:
	cmp #0				;a=0?
	beq loop			;go back to main loop
	ldy #100			;100 cycles of inner loop, total 20000 cycles (200*100)
	jmp decrement			;go to decrement

decrement
	dey				;y-=1
	cpy #0				;y=0?
	bne decrement			;go back decrement loop
	sbc #1		 		;a-=1
	jmp busyloop			;go back to busy loop
	
clear
	jsr $e55f			;clear screen
	jmp loop			;go back to main loop
	
exit
	rts				;return

