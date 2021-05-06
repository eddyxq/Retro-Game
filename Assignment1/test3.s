; test program that prints keyboard movement inputs with slight delay and clears the screen with space key

	processor 6502			;specify 6502 processor
	org $1001			;beginning of our memory

	dc.w	nextstmt
	dc.w	10
	dc.b	158, "4109"
	dc.b	0
nextstmt
	dc.w	0
	jsr $e55f			;clear screen
	
loop
	lda $00c5			;check if key is pressed
	
	cmp #17				;'A' key pressed?
	beq left			;move left
	cmp #18				;'D' key pressed?
	beq right			;move right
	cmp #9				;'W' key pressed?
	beq jump			;jump
	
	cmp #32				;'space' key pressed?
	beq clear			;clears the screen
	
	jmp loop			;infinite loop
	
left
	lda #65				;load A into a
	jsr $ffd2 			;print	
	jmp setdelay			;delay next input

right
	lda #68				;load D into a
	jsr $ffd2 			;print	
	jmp setdelay			;delay next input

jump
	lda #87				;load W into a
	jsr $ffd2 			;print	
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
	
	rts				;return

