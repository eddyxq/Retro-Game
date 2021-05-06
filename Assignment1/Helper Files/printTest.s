; Test program that can print strings
;
; Slightly rudimentary since it does not support new line characters
; (ie: all strings are on the same line)

	processor 6502

	org $1001

	dc.w	nextstmt
	dc.w	10
	dc.b	158, "4109"
	dc.b	0
nextstmt
	dc.w	0
	
main:
	jsr 	$e55f			; clear screen


	lda		#<my_string		; load lower byte of address
	sta		$00				; store lower byte in zero page
	lda		#>my_string		; load higher byte of addres
	sta		$01				; store higher byte in zero page

	jsr		prints			; prints(my_string)


	lda		#<my_string2	; load lower byte of address
	sta		$00				; store lower byte in zero page
	lda		#>my_string2	; load higher byte of addres
	sta		$01				; store higher byte in zero page

	jsr		prints			; prints(my_string2)

	rts


; Prints single line strings
; max string length is 255
;
; Strings need to be null terminated
prints:
	ldy		#0				; y = 0, counter for string index
print_inner:
	lda		($00),y			; a = string[y], current character
	jsr		$ffd2			; print character

	iny						; y += 1
	cmp		#$00			; if (a == 0) exit, (null terminated strings)
	bne		print_inner

	rts


; Variables
my_string:
	dc.b	"HELLO, WORLD!"
	dc.b	#$00

my_string2:
	dc.b	"THIS IS THE SECOND STRING"
	dc.b	#$00