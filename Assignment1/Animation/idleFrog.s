; Puts a frog on the screen :)

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

	lda		#$09 		; 0000 1 000 
	sta		$900f

	lda		#5
	sta		colour

	jsr		place_character

	inc		cursor_x
	inc		cursor_x
	inc		character
	jsr		place_character

	inc		cursor_x
	inc		cursor_x
	inc		character
	jsr		place_character
	
	ldx		#0
character_loop:
	lda		spr_frog_idle,x
	sta		$1c00,x
	
	lda		spr_frog_right,x
	sta		$1c08,x

	lda		spr_frog_left,x
	sta		$1c10,x

	lda		spr_blank,x
	sta		$1d00,x



	inx
	cpx		#8
	bne		character_loop

inf:
	nop
	jmp		inf

main_end:
	rts


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

spr_frog_idle:
	dc.b	#$00, #$66, #$5A, #$DB, #$FF, #$66, #$FF, #$E7

; 00000000
; 01100110
; 01011010
; 11011011
; 11111111
; 01100110
; 11111111
; 11100111

spr_frog_right:
	dc.b	#$36, #$6D, #$6D, #$FF, #$FF, #$FC, #$DA, #$65

; 00110110
; 01101101
; 01101101
; 11111111
; 11111111
; 11111100
; 11011010
; 01100101

spr_frog_left:
	dc.b	#$6C, #$B6, #$B6, #$FF, #$FF, #$3F, #$5B, #$A6

; 01101100
; 10110110
; 10110110
; 11111111
; 11111111
; 00111111
; 01011011
; 10100110

spr_blank:
	dc.b	#$00, #$00, #$00, #$00, #$00, #$00, #$00, #$00