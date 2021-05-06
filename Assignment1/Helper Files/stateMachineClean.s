; Test program to create a scalable state machine
; 	State machine can have n states (such that n*n < 256-n)
;		- this restriction comes from using a single register to index an n x n table
; 	Each state can have one key to transition from state a to state b
; 	Can have final states with no exit transitions


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

	jsr		update_state 	; update current state based off of previous state and key press

	lda		state 			; load state
main_s0:
	cmp		#00 			; check if state 0
	bne		main_s1 		; if not state 0 go to else if
	jsr		state_idle 		; if state 0, execute state idle
	jmp		main_end 		; go to main end after state 0

main_s1:
	cmp		#01 			; check if state 1
	bne		main_s2 		; if not state 1 go to else if
	jsr		state_left		; if state 1, go to state left
	jmp		main_end 		; go to main end after state 1

main_s2:
	cmp		#02 			; check if state 2
	bne		main_s3			; if not state 2 go to else
	jsr		state_right 	; if state 2, go to state right
	jmp		main_end 		; go to main end after state 2

main_s3:
	cmp		#03 			; check if state 3
	bne		main_s4 		; if not state 3 go to else
	jsr		state_up 	 	; if state 3, go to state up
	jmp		main_end 		; go to main end after state 3

main_s4:
	cmp		#04 			; check if state 4
	bne		main_s5 		; if not state 4 go to else
	jsr		state_up_left 	; if state 4, go to state up left
	jmp		main_end 		; go to main end after state 4

main_s5:
	cmp		#05 			; check if state 5
	bne		main_s6 		; if not state 5 go to else
	jsr		state_up_right 	; if state 5, go to state up right
	jmp		main_end		; go to main end after state 5

main_s6:
	cmp		#06 			; check if state 6
	bne		main_s7 		; if not state 6 go to else
	jsr		state_falling 	; if state 6, go to state falling
	jmp		main_end		; go to main end after state 6

main_s7:
	cmp		#07 			; check if state 7
	bne		main_end 		; if not state 7 go to else
	jsr		state_attack 	; if state 7, go to state attack
							; fall through


main_end:
	jmp		main 			; infinite loop

main_exit:
	rts

state_idle:
	lda		#<str_idle
	sta 	$00
	lda 	#>str_idle
	sta 	$01
	jsr 	prints

	rts

state_left:
	lda		#<str_left
	sta 	$00
	lda 	#>str_left
	sta 	$01
	jsr 	prints

	rts

state_right:
	lda		#<str_right
	sta 	$00
	lda 	#>str_right
	sta 	$01
	jsr 	prints

	rts

state_up:
	lda		#<str_up
	sta 	$00
	lda 	#>str_up
	sta 	$01
	jsr 	prints

	rts

state_up_left:
	lda		#<str_up_left
	sta 	$00
	lda 	#>str_up_left
	sta 	$01
	jsr 	prints

	rts

state_up_right:
	lda		#<str_up_right
	sta 	$00
	lda 	#>str_up_right
	sta 	$01
	jsr 	prints

	rts

state_falling:
	rts

state_attack:
	rts


update_state:
	lda 	#0						; initialize a to 0
	ldy		state 					; initialize y to state

update_state_offset:
	cpy		#00						; might not be needed
	beq		update_state_offset_end
	dey

	clc
	adc 	num_states 
	jmp		update_state_offset

update_state_offset_end:
	sta 	state_offset 			; state_offset = state * num_states
	ldx		#0 						; x = 0

update_state_inner:
	txa
	clc
	adc		state_offset
	tay								; y = state_offset + x

	lda 	transition_table,y		; a = transition_table[y] (transition_table[state][x])
	cmp		$00C5					; compare a to current held key
	beq		update_state_outer		; if (a == held key) then exit loop

	inx 							; x += 1
	cpx		num_states 				; check if (x == num_states)
	bne		update_state_inner 		; if not then keep going

	rts								; if no transition found, stay in current state

update_state_outer:
	stx 	state 					; current x is new state

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
							; 0 = idle, 1 = left, 2 = right
state:						; stores current state
	dc.b	#0

num_states:					; amount of states
	dc.b	#8

state_offset:				; offset for transition table
	dc.b	#0

; an nxn table to represent state transitions
	; rows are current state
	; columns are next state
	; cell is which key to press to transition
	;
	; key 64 is NO KEY
	; key 9  is W
	; key 17 is A
	; key 18 is D
	; key 48 is Q
	; key 49 is E
	; key 32 is SPACE
	; key 16 is NONE
	; key numbers found on page 179
transition_table:
	; idle
	dc.b	#64, #17, #18, #9, #48, #49, #16, #32

	; left
	dc.b	#64, #17, #18, #9, #48, #49, #16, #32

	; right
	dc.b	#64, #17, #18, #9, #48, #49, #16, #32

	; up
	dc.b	#64, #16, #16, #9, #16, #16, #16, #16

	; up left
	dc.b	#64, #16, #16, #16, #48, #16, #16, #16

	; up right
	dc.b	#64, #16, #16, #16, #16, #49, #16, #16

	; falling state
	dc.b	#16, #16, #16, #16, #16, #16, #16, #16

	; attack state
	dc.b	#16, #16, #16, #16, #16, #16, #16, #16



str_idle:
	dc.b	"IDLE"
	dc.b	#$00

str_left:
	dc.b	"LEFT"
	dc.b	#$00

str_right:
	dc.b	"RIGHT"
	dc.b	#$00

str_up:
	dc.b	"UP"
	dc.b	#$00

str_up_left:
	dc.b	"UP LEFT"
	dc.b	#$00

str_up_right:
	dc.b	"UP RIGHT"
	dc.b	#$00
