; Test program to write a character to any space on the screen

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

inf:
	nop
	jmp		inf

	rts


; FUNCTIONS
get_character_page:
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
	lda		colour
	sta		($00),y

	rts


; function to place a character at an x, and y
place_character:
	jsr		get_character_page

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
	lda		colour
	sta		($00),y

	rts


; function to get a character at an x, and y
get_character:
	jsr		get_character_page

	lda		#00
	sta		$00
	lda		character_page
	sta		$01

	ldy		pc_vertical_offset
	lda		($00),y
	sta		character


; VARIABLES
colour:
	dc.b	#0

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