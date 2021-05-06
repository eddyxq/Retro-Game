; Plays a song for you :D
; 	- basic song compression technique
; 	- note timings

; Basic Stub
	processor 6502

	org $1001

	; declare statement		stubend
	dc.w	nextstmt 
	dc.w	10
	dc.b	158, "4109"
	dc.b	0

nextstmt:
	dc.w	0


; Assembly Program
main:
	lda		#2			; set volume to 2
	sta 	$900E
	
playnote:
	ldx		noteindex	; load index of note to play
	lda		song,x		; load time/note pair using index

	tax					; transfer time/note pair to x so we do not need to load again
	
	and		#$0F		; isolate note index
	tay

	lda 	notes,y		; load note associated with index
	sta 	$900A		; play note

	txa
	and		#$F0		; isolate note time
	jsr		busyloop 	; wait in busy loop (n * 255)


	lda		#0
	sta 	$900A 		; release note


	lda		#$10
	jsr		busyloop 	; wait in busy loop (80 * 255)


	inc		noteindex 	; noteindex += 1
	lda		noteindex	; accumulator = noteindex (for compare)
	cmp		songend		; noteindex == songend?
	bne		playnote	; play next note if song not over

loopnote:
	lda		#0
	sta 	noteindex	; loop song back to first note

	lda 	shouldloop	; check if this song loops
	cmp 	#0			
	beq		end

	jmp		playnote	; play note

end:
	rts



; FUNCTIONS

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



; VARIABLES

noteindex:				; index for current note
	dc.b	#0

songend:				; length of song array (max 255 notes)
	dc.b	#31

shouldloop:				; 1 = loop, 0 = one time
	dc.b	#0

						; song compression
						; array of notes used in song
notes:
	dc.b	#0			; rest 0
	dc.b	#215		; g2   1
	dc.b	#225		; c3   2
	dc.b	#228		; d3   3
	dc.b	#231		; e3   4
	dc.b	#232		; f3   5
	dc.b	#235		; g3   6
	dc.b	#237		; a4   7

						; page 97 for value of notes
						; first nibble = note length (n*16*255 in busy loop)
						; second nibble = note index (in notes array)
song: 					; array of notes
	dc.b	#$52		; c3
	dc.b	#$53		; d3
	dc.b	#$54		; e3
	dc.b	#$32		; c3
	dc.b	#$10		; rest
	; 5

	dc.b	#$52		; c3
	dc.b	#$53		; d3
	dc.b	#$54		; e3
	dc.b	#$32		; c3
	dc.b	#$10		; rest
	; 10

	dc.b	#$54		; e3
	dc.b	#$55		; f3
	dc.b	#$A6		; g3
	; 13

	dc.b	#$54		; e3
	dc.b	#$55		; f3
	dc.b	#$A6		; g3
	; 16

	dc.b	#$26		; g3
	dc.b	#$27		; a4
	dc.b	#$26		; g3
	dc.b	#$25		; f3
	dc.b	#$54		; e3
	dc.b	#$52		; c3
	; 22

	dc.b	#$26		; g3
	dc.b	#$27		; a4
	dc.b	#$26		; g3
	dc.b	#$25		; f3
	dc.b	#$54		; e3
	dc.b	#$52		; c3
	; 28

	dc.b	#$53		; d3
	dc.b	#$51		; g2
	dc.b	#$A2		; c3
	; 31