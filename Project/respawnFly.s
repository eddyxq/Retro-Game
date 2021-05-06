;
; this is for respawning flies
;

respawn_flies:

; Respawns flies by checking every platform block and every platform has a small chance to spawn to fly
respawn_flies_loop:
	lda 	fly_count						; Load fly count
	cmp 	#2								; Check to see if its 2
	bcc		next							; if fly count < 2 then check for platforms to respawn flies

	rts

next:
	jsr 	check_for_platform	
	jmp 	respawn_flies_loop	

; Checks every x for y = 18, 6, 14, 10 as these are the rows where platforms are randomly generated
check_for_platform:
	lda		#18								; Load 18
	sta 	screen_y						; Store in screen_y for use in check_for_platform_loop
	lda		#0								; Load 0
	sta 	screen_x						; Store in screen_x for use in check_for_platform_loop

	jsr		check_for_platform_loop

	lda		#6								; Load 6
	sta 	screen_y						; Store in screen_y for use in check_for_platform_loop
	lda		#0								; Load 0
	sta 	screen_x						; Store in screen_x for use in check_for_platform_loop
	jsr		check_for_platform_loop

	lda		#14								; Load 14
	sta 	screen_y						; Store in screen_y for use in check_for_platform_loop
	lda		#0								; Load 6
	sta 	screen_x						; Store in screen_x for use in check_for_platform_loop
	jsr		check_for_platform_loop

	lda		#10								; load 10
	sta 	screen_y						; Store in screen_y for use in check_for_platform_loop
	lda		#0								; load 0
	sta 	screen_x						; Store in screen_x for use in check_for_platform_loop
	jsr		check_for_platform_loop

	rts




check_for_platform_loop:
	lda 	fly_count						; Check to see if fly count is >= 2, if so do nothing
	clc
	cmp		#2
	bcs		check_for_platform_end

	lda		screen_x						; Get the character at screen_x, screen_y on screen location
	sta		cursor_x

	lda 	screen_y
	sta 	cursor_y

	jsr		get_character
	lda		character						; load screen character

	cmp 	platform_tile					; is current screen character a platform?
	bne		next_platform_loop				; if so check for small chance of spawning fly on top


	; Get the character above the platform tile
	; Check to see if its a fly, if so look at nxt platform tile
	ldy 	screen_y
	dey
	tya
	sta 	cursor_y

	jsr 	get_character
	lda 	character

	cmp 	fly_graphic						; Check if this platform is valid by checking if there is a fly on top
	beq 	next_platform_loop				; If so, do nothing and check the next platform tile

	cmp		player_graphic					; Check if this platform is valid by checking if there is a player on top		
	beq		next_platform_loop				; If so, do nothing and check the next platform tile

	jmp 	chance_for_fly					; if the platform is valid then check for small chance of fly spawn

next_platform_loop:
	inc		screen_x						; Increment screen x
	lda		screen_x						; Increment screen y
	cmp 	#22								; Check if new value is 22
	bne		check_for_platform_loop			; if not, keep looping

check_for_platform_end:
	rts



chance_for_fly:
	jsr		get_random_num					; Get random 5 bit number 
	lda		random_num

	cmp 	#1								; check to see if it's < 1
	bcc		set_fly_location				; if so, spawn a new fly here

	jmp 	next_platform_loop

set_fly_location:
	ldx 	#0								; load offset 0
	lda		screen_x						; load screen x

	sta 	fly_locations,x					; Store in fly_locations for fly_init to use

	inx

	ldy		screen_y						; load screen y
	dey										; Set y coord for fly to be 1 above the platform y
	tya										
	sta 	fly_locations,x					; Store in fly_locations for fly_init to use 

	
	jsr 	init_fly						; spawn the fly at new location
	inc 	fly_count						; increment fly_count 

no_fly:
	rts



get_random_num:								; Get the random number
    lda     $9014
    and     #$1F
    sta     random_num
    lda     #0
    clc
    adc     random_num
    sta     random_num

    rts


reset_fly_count:							; Reset fly count
	lda		#0
	sta 	fly_count
	rts

; Variables
random_num:
	dc.b	#0

screen_x:
	dc.b	#0

screen_y:
	dc.b	#0

