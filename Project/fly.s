;
; FLY CODE
;

init_fly:
	ldx 	#0
	lda 	fly_locations,x
	sta     cursor_x 				; move cursor x to fly one x 	

	inx

	lda 	fly_locations,x
	sta     cursor_y 				; move cursor y to fly one y

	lda     col_fly 				; load fly colour
    sta     colour 					; store fly colour
    lda     fly_graphic 			; load fly graphic
    sta     character 				; store fly graphic
    jsr     place_character         ; place fly one

    rts


; Erase fly, and respawn two new flies if the fly count is 0
erase_fly:
    lda     #32
    sta     character
    jsr     place_character
    jsr     increment_score         ; increment score by one 

    dec 	tenth_fly 				; tenth_fly -= 1
    bne 	erase_fly2 				; tenth_fly > 0, keep map

    lda 	#10
    sta 	tenth_fly 				; reset 10th fly counter

    jsr 	soft_reset
    jsr 	create_platform_below_player
    jmp 	erase_done

erase_fly2:
    dec		fly_count
    lda 	fly_count
    cmp		#2
    bcs 	erase_done

    jsr		respawn_flies

erase_done:
	rts


; Fly Variables

; stores the code of the last collided
; character
collider:
    dc.b    #0

fly_graphic:
    dc.b    #38

fly_locations:
	dc.b	#0		; fly x
	dc.b	#0		; fly y

fly_count:
	dc.b	#0


; every tenth fly changes the map
tenth_fly:
	dc.b 	#10