; Contains functions for the end screen

draw_end_screen:
	jsr     $e55f                           ; Clear screen
	; Set cursor_x and cursor_y to the x and y screen coordinate of where priting starts 
	jsr 	draw_game_over                  ; draw game over
	jsr 	draw_moved_score_counter        ; draw moved score counter
	jsr 	draw_hold_space                 ; draw hold space to return text 
	jsr 	key_input_loop                  ; check if space is pressed
	rts


draw_moved_score_counter:
	lda 	#6                              ; load #6            
	sta 	score_label_x                   ; move score label x to 6 
	lda 	#11                             ; load #11
	sta 	score_label_y                   ; move score label y to 11
	jsr 	draw_score_text                 ; draw score text
	jsr 	draw_score_number               ; draw score number


draw_game_over:
	lda     game_end_text_label_x           ; load game end text label x    
	sta     cursor_x                        ; move cursor x to game end text label x
	lda     game_end_text_label_y           ; load game end text label y
	sta     cursor_y                        ; move cursor y to game end text label y
	ldx    #0                               ; load #0
	stx 	game_end_text_offset            ; store game end text offset


; Prints "G A M E   O V E R"
draw_game_over_loop:
	ldx     game_end_text_offset            ; load game end text offset
    lda     game_end_text,x                 ; load game end text to load game end text offset
    sta     character                       ; store game end text
    lda     #2                              ; red
    sta     colour                          ; store colour red
    jsr     place_character                 ; place game end text
    inc     game_end_text_offset            ; game end text offset + 1
    inc     cursor_x                        ; cursor x + 1
    lda     game_end_text_offset            ; load game end text offset
    cmp     #18                             ; check if it is 18
    bne     draw_game_over_loop             ; if not, keep drawing game over 
    rts


; Prints "hold space to return"
draw_hold_space:
    lda     hold_space_text_label_x         ; load hold space text label x
    sta     cursor_x                        ; move cursor x to hold space text label x
    lda     hold_space_text_label_y         ; load hold space text label y
    sta     cursor_y                        ; move cursor y to hold space text label y
    lda     #1                              ; white
    sta     colour                          ; store colour
    ldx     #0                              ; load 0 in acc to loop through hold_space_text
    stx     game_name_text_offset           ; store in offset


draw_hold_space_loop:
    ldx     game_name_text_offset           ; load game name text offset
    lda     hold_space_text,x               ; load hold space text
    sta     character                       ; store hold space text
    jsr     place_character                 ; place hold space text
    inc     game_name_text_offset           ; game name text offset + 1
    inc     cursor_x                        ; cursor x + 1
    lda     game_name_text_offset           ; load game text offset
    cmp     #20                             ; check if it is 20
    bne     draw_hold_space_loop            ; if not, keep drawing hold space text
    rts

game_end_text:
	dc.b	#7	; G
	dc.b	#32	; space
	dc.b	#1 	; A
	dc.b	#32	; space
	dc.b	#13	; M
	dc.b	#32	; space
	dc.b	#5	; E
	dc.b	#32	; space
	dc.b	#32	; space
	dc.b	#32	; space
	dc.b	#32	; space
	dc.b	#15	; O
	dc.b	#32	; space
	dc.b	#22	; V
	dc.b	#32	; space
	dc.b	#5	; E
	dc.b	#32 ; space
	dc.b 	#18	; R

hold_space_text:
    dc.b	#8	;H
    dc.b	#15	;O
    dc.b	#12	;L
    dc.b	#4	;D
    dc.b	#32	;space
    dc.b	#19	;S
    dc.b	#16	;P
    dc.b	#1	;A
    dc.b	#3	;C
    dc.b	#5	;E
    dc.b	#32	;space
    dc.b	#20	;T
    dc.b	#15	;O
    dc.b	#32	;space
    dc.b	#18	;R
    dc.b	#5	;E
    dc.b	#20	;T
    dc.b	#21	;U
    dc.b	#18	;R
	dc.b 	#14 ;N

game_end_text_offset:
	dc.b 	#0

game_end_text_label_x:
	dc.b 	#2

game_end_text_label_y:
	dc.b 	#4

hold_space_text_label_x:
    dc.b 	#1

hold_space_text_label_y:
    dc.b	#18
