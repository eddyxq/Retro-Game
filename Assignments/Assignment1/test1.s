; test program that uses a loop to print the letter A five times

	processor 6502			;specify 6502 processor
	org $1001			;beginning of our memory

	dc.w	nextstmt
	dc.w	10
	dc.b	158, "4109"
	dc.b	0
nextstmt
	dc.w	0
	
start
	ldx #0				;load 0 into x
	
	
loop
	lda #65				;load A into a
	jsr $ffd2 			;print
	inx				;x+1
	cpx #5				;x = 5?
	bne loop
	
	rts				;return
