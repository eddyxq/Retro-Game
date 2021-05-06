;
; used to play sounds for jumping, eating flies, and dying
;


initialize_sound:
	lda	    #2			               ; set volume to 2
	sta 	$900E                      ; memory mapped volume
	rts

; eat and jump sound are a fifth apart
play_eat_sound:
	lda 	#218                       ; pitch for eat sound (A)
	sta 	$900C                      ; tone generator 3
	
	lda 	jump_sound_max             ; load jump sound max
	sta 	jump_sound_timer           ; store jump sound timer

	rts


play_jump_sound:
	lda 	#200                       ; pitch for jump sound (D)
	sta 	$900C                      ; tone generator 3
	
	lda 	jump_sound_max             ; load jump sound max
	sta 	jump_sound_timer           ; store jump sound timer

	rts

; No timer on this one as it will always
; have a closing sound jsr
play_platform_sound:
	lda 	#173
	sta 	$900C

	rts

stop_jump_sound:
	lda 	#0                         ; no tone value
	sta 	$900C                      ; tone generator 3
	rts

play_death_sound:
	lda 	#131                       ; pitch value (arbitrary)
	sta 	$900D                      ; noise generator

	lda 	death_sound_max            ; load death sound max
	sta 	death_sound_timer          ; store death sound timer

	rts

stop_death_sound:
	lda 	#0                         ; no noise value
	sta 	$900D                      ; noise generator
	rts

sound_tick:
	lda 	death_sound_timer          ; load death_sound_timer
	cmp 	#0                         ; check if it is #0
	beq 	sound_tick0                ; if so, go to next sound timer

	dec 	death_sound_timer          ; death_sound_timer -= 1
	bne 	sound_tick0                ; if death_sound_timer != 0, next sound timer

	jsr 	stop_death_sound           ; stop death sound

sound_tick0:
	lda 	jump_sound_timer           ; load jump_sound_timer
	cmp 	#0                         ; check if it is #0
	beq 	sound_tick1                ; if so, go to next sound timer

	dec 	jump_sound_timer           ; jump_sound_timer -= 1
	bne 	sound_tick1                ; if jump_sound_timer != 0, next sound timer

	jsr 	stop_jump_sound            ; stop jump sound

sound_tick1:
	rts

;
; Variables
;

; timer variable for length of death sound
death_sound_timer:
	dc.b 	#0

; value timer is set to when triggered, higher = longer
death_sound_max:
	dc.b 	#100

; timer variable for length of jump (and eat) sound
jump_sound_timer:
	dc.b 	#0

; value timer is set to when triggered, higher = longer
jump_sound_max:
	dc.b 	#100