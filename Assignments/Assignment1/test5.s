; test program that plays c3 then stops.

	processor 6502

	org $1001

	; declare statement		stubend
	dc.w	nextstmt 
	dc.w	10
	dc.b	158, "4109"
	dc.b	0

nextstmt:
	dc.w	0

start:
	; set volume to 15
	lda 	#15
	sta 	$900E

	; play c3
	lda 	#225 	; note c3
	sta 	$900B 	; 36875


	; pause before releasing note
	ldy		#0
yloop:
	ldx		#0

xloop:
	nop

	inx
	cpx		#255
	bne		xloop

	iny
	cpy		#255
	bne		yloop

	; release note
	lda		#0
	sta 	$900B

	rts