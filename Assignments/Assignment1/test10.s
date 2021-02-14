; test program that lets the player 'X' jump up with the 'W' key in addition
; to letting the player move left and right with 'A' and 'D' keys

	processor 6502			;specify 6502 processor
	org $1001			;beginning of our memory
	dc.w	nextstmt
	dc.w	10
	dc.b	158, "4109"
	dc.b	0
nextstmt
	dc.w	0
	jsr $e55f			;clear screen
	
	ldy #220			;beginning of screen
createfloor				;creates a floor with 'T'
	lda #20				;load graphic 'T'
	sta $1e00,y			;display graphic 'T'
	lda #2				;load color red
	sta $9600,y	 		;set fllor color to red
	iny				;y+=1
	cpy #242			;end of screen?
	bne createfloor			;loop until floor stretches end to end

createplayer
	lda #24				;load player graphic 'X'
	ldx screenoffset		;load offset
	sta $1e00,x		 	;display player
	lda #0				;load black
	ldx screenoffset		;load offset
	sta $9600,x	 		;set player color to black
	
loop
	lda $00c5			;check if key is pressed
	cmp #17				;'A' key pressed?
	beq leftkeypress		;move left
	cmp #18				;'D' key pressed?
	beq rightkeypress		;move right
	cmp #9				;'W' key pressed?
	beq upkeypress			;jump up
	jmp loop			;infinite loop
	
leftkeypress
	ldx screenoffset		;load offset
	cpx #198	     		;left boarder collision?
	beq loop	 		;move valid?
	lda #1			 	;load white color
	ldx screenoffset		;load offset
	sta $9600,x		 	;erase previous position	
	dec screenoffset		;offset-=1
	jsr updateposition		;draw player in new position
	jmp loop

rightkeypress
	ldx screenoffset
	cpx #219	     		;left boarder collision?
	beq loop	 		;move valid?
	lda #1			 	;load white color
	ldx screenoffset		;load offset
	sta $9600,x		 	;erase previous position	
	inc screenoffset		;offset+=1
	jsr updateposition		;draw player in new position
	jmp loop
	
upkeypress
	lda #1			 	;load white color
	ldx screenoffset		;load offset
	sta $9600,x		 	;erase previous position
	;jump height currently 3 blocks
	jsr moveupablock		;translates player up one block
	jsr moveupablock		;translates player up one block
	jsr moveupablock		;translates player up one block
	jsr updateposition		;draw player in new position
	;bring player back onto ground
	jsr fall			;translates player down one block
	jsr fall			;translates player down one block
	jsr fall			;translates player down one block
	jmp loop

updateposition
	lda #24				;load player graphic 'X'
	ldx screenoffset		;load offset
	sta $1e00,x		 	;display player
	lda #0				;load black
	ldx screenoffset		;load offset
	sta $9600,x		 	;set player color to black
	jsr setdelay	 		;delay next input
	rts				;return

fall
	lda #1			 	;load white color
	ldx screenoffset		;load offset
	sta $9600,x		 	;erase previous position
	lda screenoffset		;load screenoffset
	adc blockheight			;offset+blockheight
	sta screenoffset		;store new offset
	jsr updateposition		;draw player in new position
	rts				;return

setdelay
	lda #200			;200 cycles of outer loop
	jsr busyloop			;delay next input
	rts				;return

busyloop
	cmp #0				;a=0?
	beq return			;go back to main loop
	ldy #100			;100 cycles of inner loop, total 20000 cycles (200*100)
	jmp decrement			;go to decrement
	
return
	rts				;return

decrement
	dey				;y-=1
	cpy #0				;y=0?
	bne decrement			;go back decrement loop
	sbc #1		 		;a-=1
	jmp busyloop			;go back to busy loop

moveupablock
	clc				;clear carry
	lda screenoffset		;load screenoffset
	sbc blockheight			;offset-blockheight
	sta screenoffset		;store new offset
	rts				;return

screenoffset				;tracks position of player on screen
	dc.w #199			;e.g. offset = 0 then player is in top left corner, offset = 1 then player in second square

blockheight
	dc.w #21			;size of offset needed to move up/down a row
