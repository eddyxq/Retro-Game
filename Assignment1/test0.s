;assembly stub test

	processor 6502

	org $1001

	dc.w	nextstmt
	dc.w	12345
	dc.b	158, "4109"
	dc.b	0
nextstmt
	dc.w	0
	
start
	rts
