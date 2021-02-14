; test program that accepts 'A' keyboard input and prints the button pressed

	processor 6502			;specify 6502 processor
	org $1001			;beginning of our memory

	dc.w	nextstmt
	dc.w	10
	dc.b	158, "4109"
	dc.b	0
nextstmt
	dc.w	0

loop
	lda $00c5			;check if key is pressed
	cmp #17				;'A' key pressed?
	beq print			;go to print
	jmp loop			;infinite loop
	
print
	lda #65				;load A into a
	jsr $ffd2 			;print	
	jmp loop			;infinite loop
	
	rts				;return
