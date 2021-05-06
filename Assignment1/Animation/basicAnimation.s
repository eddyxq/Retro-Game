; Rough program meant to test character animations.
; Crudely using print string to place animated characters on screen

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

	
	lda		#<lots_of_at_signs
	sta 	$00
	lda 	#>lots_of_at_signs
	sta 	$01
	jsr		prints

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

; Variables
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


lots_of_at_signs:
	dc.b	"@A@A@A@A@A@A@A@A@A@A@A"
	dc.b	#$00
