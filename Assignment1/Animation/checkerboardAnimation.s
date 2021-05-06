; Animation utilizing writeToScreen.s functions
; Draws a checkerboard of A and @ signs
; these characters have animated sprites to
; create illusion of a checkered flag sliding

	processor 6502

	org $1001

	dc.w	nextstmt
	dc.w	10
	dc.b	158, "4109"
	dc.b	0
nextstmt:
	dc.w	0
	
main:
	jsr		$e55f		; clear screen

	; change character memory to 0x9005 / 7168 (our memory)
	lda		#$ff 		; 255
	sta		$9005

	lda		#0
	sta		cursor_y
next_column:
	lda		#0
	sta		cursor_x

place_row:
	lda		cursor_y
	eor		cursor_x
	and		#1
	beq		at_sign
a_sign:
	lda		#1
	sta		character
	jmp		place_row_character

at_sign:
	lda		#0
	sta		character

place_row_character:
	jsr		place_character
	inc		cursor_x
	lda		cursor_x
	cmp		#22
	bne		place_row

	inc		cursor_y
	lda		cursor_y
	cmp		#23
	bne		next_column

animation_start:
	jsr		calc_offset
	
	ldx		#0
character_loop:
	txa
	clc
	adc		frame_offset
	tay

	lda		custom_character1,y
	sta		$1c00,x

	lda		custom_character2,y
	sta		$1c08,x
	
	inx
	cpx		#8
	bne		character_loop


	lda		#10
	jsr		busyloop

	ldx		frame
	inx
	stx		frame
	cpx		frames
	bne 	animation_start
	ldx		#0
	stx		frame
	jmp		animation_start

main_end:
	rts

calc_offset:
	lda 	#0						; initialize a to 0
	ldy		frame 					; initialize y to frame

calc_offset_loop:
	cpy		#00						; might not be needed
	beq		calc_offset_end
	dey

	clc
	adc 	#8 
	jmp		calc_offset_loop

calc_offset_end:
	sta 	frame_offset 			; frame_offset = frame * 8
	rts

prints:
	ldy		#0				; y = 0, counter for string index
print_inner:
	lda		($00),y			; a = string[y], current character
	jsr		$ffd2			; print character

	iny						; y += 1
	cmp		#$00			; if (a == 0) exit, (null terminated strings)
	bne		print_inner

	rts

; wait for a * 255 loop steps
; then return
busyloop:
	ldx		#0

busyloopinner:
	nop

	inx
	cpx		#255
	bne		busyloopinner

	sbc		#1			; a -= 1
	cmp		#0			; if (a != 0)
	bne		busyloop 	; outerloop

	rts					; return


place_character:
	lda		cursor_x
	sta		cursor_x_new

	lda		cursor_y
	sta		cursor_y_new

	clc
	cmp		#12
	bcc		pc_ylt_12		; y less than 12

	lda		#$1f
	sta		character_page
	lda		#$97
	sta		colour_page

	lda		cursor_y_new
	sec
	sbc		#12
	sta		cursor_y_new

	lda		cursor_x_new
	clc
	adc		#8
	sta		cursor_x_new

	jmp		pc_offset

pc_ylt_12:
	cmp		#11
	bne		pc_ylt_11		; y less than 11

	lda		cursor_x
	cmp		#14
	bcc		pc_xlt_14		; x less than 14

	lda		#$1f
	sta		character_page
	lda		#$97
	sta		colour_page

	lda		cursor_x
	sec
	sbc		#14
	sta		cursor_x_new

	lda		#0
	sta		cursor_y_new

	jmp		pc_offset

pc_xlt_14:
pc_ylt_11:
	lda		#$1e
	sta		character_page
	lda		#$96
	sta		colour_page

pc_offset:
	ldy		#0
	lda		#0

pc_offset_loop:
	cpy		cursor_y_new
	beq		pc_offset_loop_exit

	clc
	adc		#22

	iny
	jmp		pc_offset_loop

pc_offset_loop_exit:
	clc
	adc		cursor_x_new
	sta		pc_vertical_offset

	lda		#00
	sta		$00
	lda		character_page
	sta		$01

	ldy		pc_vertical_offset
	lda		character
	sta		($00),y

	lda		#00
	sta		$00
	lda		colour_page
	sta		$01

	ldy		pc_vertical_offset
	lda		#0
	sta		($00),y

	rts

; VARIABLES
character:
	dc.b	#0

cursor_x:
	dc.b	#0

cursor_x_new:
	dc.b	#0

cursor_y:
	dc.b	#0

cursor_y_new:
	dc.b	#0

pc_vertical_offset:
	dc.b	#0

character_page:
	dc.b	#$1e

colour_page:
	dc.b	#$96



vertical_offset:
	dc.b	#0

frames:
	dc.b	#16

frame:
	dc.b	#0

frame_offset:
	dc.b	#0

custom_character1:
	dc.b	#$80, #$80, #$80, #$80, #$80, #$80, #$80, #$80
	dc.b	#$c0, #$c0, #$c0, #$c0, #$c0, #$c0, #$c0, #$c0
	dc.b	#$e0, #$e0, #$e0, #$e0, #$e0, #$e0, #$e0, #$e0
	dc.b	#$f0, #$f0, #$f0, #$f0, #$f0, #$f0, #$f0, #$f0
	dc.b	#$f8, #$f8, #$f8, #$f8, #$f8, #$f8, #$f8, #$f8
	dc.b	#$fc, #$fc, #$fc, #$fc, #$fc, #$fc, #$fc, #$fc
	dc.b	#$fe, #$fe, #$fe, #$fe, #$fe, #$fe, #$fe, #$fe
	dc.b	#$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff

	dc.b	#$7f, #$7f, #$7f, #$7f, #$7f, #$7f, #$7f, #$7f
	dc.b 	#$3f, #$3f, #$3f, #$3f, #$3f, #$3f, #$3f, #$3f
	dc.b	#$1f, #$1f, #$1f, #$1f, #$1f, #$1f, #$1f, #$1f
	dc.b	#$0f, #$0f, #$0f, #$0f, #$0f, #$0f, #$0f, #$0f
	dc.b	#$07, #$07, #$07, #$07, #$07, #$07, #$07, #$07
	dc.b	#$03, #$03, #$03, #$03, #$03, #$03, #$03, #$03
	dc.b	#$01, #$01, #$01, #$01, #$01, #$01, #$01, #$01
	dc.b	#$00, #$00, #$00, #$00, #$00, #$00, #$00, #$00

custom_character2:
	dc.b	#$7f, #$7f, #$7f, #$7f, #$7f, #$7f, #$7f, #$7f
	dc.b 	#$3f, #$3f, #$3f, #$3f, #$3f, #$3f, #$3f, #$3f
	dc.b	#$1f, #$1f, #$1f, #$1f, #$1f, #$1f, #$1f, #$1f
	dc.b	#$0f, #$0f, #$0f, #$0f, #$0f, #$0f, #$0f, #$0f
	dc.b	#$07, #$07, #$07, #$07, #$07, #$07, #$07, #$07
	dc.b	#$03, #$03, #$03, #$03, #$03, #$03, #$03, #$03
	dc.b	#$01, #$01, #$01, #$01, #$01, #$01, #$01, #$01
	dc.b	#$00, #$00, #$00, #$00, #$00, #$00, #$00, #$00

	dc.b	#$80, #$80, #$80, #$80, #$80, #$80, #$80, #$80
	dc.b	#$c0, #$c0, #$c0, #$c0, #$c0, #$c0, #$c0, #$c0
	dc.b	#$e0, #$e0, #$e0, #$e0, #$e0, #$e0, #$e0, #$e0
	dc.b	#$f0, #$f0, #$f0, #$f0, #$f0, #$f0, #$f0, #$f0
	dc.b	#$f8, #$f8, #$f8, #$f8, #$f8, #$f8, #$f8, #$f8
	dc.b	#$fc, #$fc, #$fc, #$fc, #$fc, #$fc, #$fc, #$fc
	dc.b	#$fe, #$fe, #$fe, #$fe, #$fe, #$fe, #$fe, #$fe
	dc.b	#$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff, #$ff