; assembly stub


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
	jsr		show_score_text
	jsr		show_score_num
	jmp		main_loop




main_loop
	lda		$00c5		; check keypress
	cmp		#32			; spacebar
	bne		main_loop

	jsr		increment_score

	jmp		main_loop



end
	jsr		$e55f
	rts		



; show score text function
; displays "SCORE:" at the top right of screen

show_score_text
	ldy		#0								; loop counter y = 0


show_score_text_loop
	lda		score_text,y					; a = score_text[y]

	sta 	7693,y

	lda		score_color
	sta 	38413,y

	iny

	cpy		#6
	bne		show_score_text_loop

	rts	




show_score_num
	
	ldx		player_score_100

	lda		number_to_code_table,x
	sta 	7699
	lda		#2			; Color Red
	sta		38419



	clc
	lda		player_score

	and		#$0F		; Get higher 4 bits
	tax					; put value in x for offset

	lda		number_to_code_table,x
	sta 	7701

	lda		#2			; Color Red
	sta		38421	

	lda		player_score
	and		#$F0		; get the lower 4 bits

	clc
	ldy		#0

shift_4_loop
	lsr		
	iny
	cpy		#4
	bne		shift_4_loop

	tax
	lda		number_to_code_table,x
	sta 	7700

	lda		#2			; Color Red
	sta		38420

	clc
	jsr		setdelay

	rts


increment_score
	lda		player_score			; get current score
	cmp		#$99					; if its 0x99 increment 100s digit (BCD number)
	beq		inc_player_score_100

bcd_add	
	clc 							; clear carry 
	sed 							; set decimal mode for bcd addition
	adc		#1 						; inc a by 1 in bcd
	cld 							; clear decimal mode

	sta 	player_score 			; put new score back in score
	jsr		show_score_num 			; show updated score numbers
	rts

inc_player_score_100
	lda		player_score_100
	cmp		#9
	beq		return	

	inc 	player_score_100
	jmp 	bcd_add


setdelay
	lda #100			;100 cycles of outer loop
	jmp busyloop			;delay next input


busyloop
	cmp #0				;a=0?
	beq return
	ldx #100			;100 cycles of inner loop, total 20000 cycles (200*100)
	jmp decrement			;go to decrement

decrement
	dex				;y-=1
	cpx #0				;y=0?
	bne decrement			;go back decrement loop
	sbc #1		 		;a-=1
	jmp busyloop			;go back to busy loop

return
	rts

; variables


score_text
	dc.b	#19		;S 
	dc.b	#3		;C 
	dc.b	#15		;O 
	dc.b	#18		;R 
	dc.b	#5		;E 
	dc.b	#58		;:  


score_color
	dc.b	#0


; 0 is #48 and 9 is #57
number_to_code_table
	dc.b	#48
	dc.b	#49
	dc.b	#50
	dc.b	#51
	dc.b	#52
	dc.b	#53
	dc.b	#54
	dc.b	#55
	dc.b	#56
	dc.b	#57


; Player score is BCD number
; Player score 100 is not BCD number
player_score
	dc.b	#0

player_score_100
	dc.b	#0