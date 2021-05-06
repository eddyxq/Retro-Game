;This program is a retro 2D platformer game created for the VIC-20.

;Patch History:
;Date		 	 Version			Notes
;Feb 04, 2021 	 Ver. 1.0.0		 	implemented input detection
;Feb 07, 2021 	 Ver. 1.0.1		 	added busy loops to delay inputs
;Feb 08, 2021 	 Ver. 1.1.0		 	implemented horiozntal player movement
;Feb 09, 2021 	 Ver. 1.2.0		 	implemented vertical player jump and falling
;Feb 24, 2021 	 Ver. 1.3.0		 	implemented player platform collision detection
;Mar 14, 2021 	 Ver. 2.0.0		 	implemented player state machine
;Mar 16, 2021 	 Ver. 3.0.0		 	refactored code and reworked player movement system
;Mar 17, 2021 	 Ver. 3.1.0		 	improved movement feel and reworked collision detection

;TO-DO List and upcoming functionality
;Add background music and SFX
;Add player idle and movement animations
;Add score counter
;Add enemies
;Add player attack logic
;Add title screens and menu

;KNOWN ISSUES
;Code commenting is incomplete
;Use of magic numbers
;Player movement and feel can be fine tuned
;Hard coded platforms can be replaced with PCG

; CODE STARTS HERE

	processor 6502		 	 ; specify 6502 processor
	org 	$1001		 	 ; beginning of our memory
	dc.w 	nextstmt
	dc.w 	10
	dc.b 	158, "4109"
	dc.b 	0

nextstmt:
	dc.w 	0

; INITIALIZATION

; Places sprites into character memory
load_sprites:
	; change character memory to $1C00 / 7168 (our memory)
	lda 	#$ff					; 255 designates $1C00 as start of character memory
	sta 	$9005

	; set screen colour and screen border colour
	; See page 214-217
	lda		#%10101000	 		 	; XXXX Y ZZZ
	sta		$900f

	ldx 	#0
sprite_loop:
	; character offsets calculated with
	; 0x1c00 + (n * 8)
	lda 	spr_frog_idle,x 		; load x byte of sprite
	sta 	$1cb8,x 				; replace W character

	lda 	spr_frog_right,x 		; load x byte of sprite
	sta 	$1cc0,x 				; replace X character

	lda 	spr_frog_left,x 		; load x byte of sprite
	sta 	$1cc8,x 				; replace Y character

	lda 	spr_blank,x 			; load x byte of sprite
	sta 	$1d00,x 				; replace space character

	lda 	spr_solid,x 			; load x byte of sprite
	sta 	$1ca0,x 				; replace T character

	lda     spr_fly1,x					; load x byte of sprite
  sta     $1cd0,x       ; replace Z character

	lda     spr_fly2,x        ; load x byte of sprite
  sta     $1ca8,x       ; replace U character

	lda     spr_frog_right_eat,x
	sta     $1cd8,x                 ; [

	lda     spr_frog_left_eat,x
	sta     $1ce0,x                 ; 28

	inx
	cpx 	#8 						; 8x8 sprite, only load 8 bytes
	bne 	sprite_loop 			; x < 8, then loop

	jsr 	$e55f					; clear screen
	jsr 	draw_player				; init player

create_platforms:
	jsr   init_fly_one                            ; display fly1
	jsr   init_fly_two                            ; display fly2
	jsr 	init_map				; display platforms
	jsr 	init_floor				; display floor


; Main Game Loop
main_start:
	jsr 	update_state 			; update current state based off of previous state and key press
	lda 	state			 	  	; load state

main_s0:
	cmp 	#00				 		; check if state 0
	bne 	main_s1			 		; if not state 0 go to else if
	jsr 	state_idle		 	 	; if state 0, execute state idle
	jmp 	main_end				; go to main end after state 0

main_s1:
	cmp 	#01				 		; check if state 1
	bne 	main_s2			 		; if not state 1 go to else if
	jsr 	state_left		 	  	; if state 1, go to state left
	jmp 	main_end				; go to main end after state 1

main_s2:
	cmp 	#02				 		; check if state 2
	bne 	main_s3			 		; if not state 2 go to else
	jsr 	state_right		 	 	; if state 2, go to state right
	jmp 	main_end				; go to main end after state 2

main_s3:
	cmp 	#03				 		; check if state 3
	bne 	main_s4			 		; if not state 3 go to else
	jsr 	state_jump				; if state 3, go to state up
	jmp 	main_end				; go to main end after state 3

main_s4:
	cmp 	#04				 		; check if state 4
	bne 	main_s5			 		; if not state 4 go to else
	jsr 	state_jump_left			; if state 4, go to state up left
	jmp 	main_end				; go to main end after state 4

main_s5:
	cmp 	#05				 		; check if state 5
	bne 	main_s6			 		; if not state 5 go to else
	jsr 	state_jump_right 	  	; if state 5, go to state up right
	jmp 	main_end				; go to main end after state 5

main_s6:
	cmp 	#06				 		; check if state 6
	bne 	main_s7			 		; if not state 6 go to else
	jsr 	state_fall	 	  	; if state 6, go to state falling
	jmp 	main_end				; go to main end after state 6

main_s7:
	cmp 	#07				 		; check if state 7
	bne 	main_end				; if not state 7 go to else

	; not implemented - TO-DO: player attack
	;jsr 	state_attack			; if state 7, go to state attack

main_end:
	jmp 	main_start


;
; STATES
;
enter_idle_state:
	lda 	#0				 	 	; load idle state
	sta 	state			 	  	; enter idle state
	rts

enter_fall_state:
	lda 	#6
	sta 	state
	rts


state_idle:
	jsr 	load_sprite_player_idle
	jsr 	draw_player
	rts


state_left:
	jsr 	load_sprite_player_left
	jsr 	move_left
	jsr		wait_long_delay

	rts


state_right:
	jsr 	load_sprite_player_right
	jsr 	move_right
	jsr		wait_long_delay

	rts


state_jump:
	lda 	#4 						; move up 4 times
	sta 	move_loop_counter

state_jump_loop:
	jsr 	move_up			 		; move player upwards
	jsr 	wait_long_delay

	dec 	move_loop_counter
	bne 	state_jump_loop

state_jump_end:
	jsr 	enter_fall_state		; transition to falling state

	rts


state_jump_left:
	jsr 	load_sprite_player_left
	jsr		move_up

	lda 	#3 						; move up left 4 times
	sta 	move_loop_counter

state_jump_left_loop:
	jsr 	move_up_left
	jsr 	wait_long_delay

	dec 	move_loop_counter
	bne 	state_jump_left_loop

state_jump_left_end:
	jsr 	enter_fall_state		; transition to falling state

	rts


state_jump_right:
	jsr 	load_sprite_player_right
	jsr		move_up

	lda 	#3 						; move up right 4 times
	sta 	move_loop_counter

state_jump_right_loop:
	jsr 	move_up_right
	jsr		wait_long_delay

	dec 	move_loop_counter
	bne 	state_jump_right_loop

state_jump_right_end:
	jsr 	enter_fall_state		; transition to falling state

	rts


state_fall:
	jsr 	load_sprite_player_idle
	jsr 	move_down
	jsr		wait_long_delay

	rts


state_attack:
	rts


;
; PLAYER MOVEMENT
;

; Move player left by 1
move_left:
	ldx 	player_x				; load player x
	cpx 	min_x_offset			; left border collision?
	beq 	left_collided	 	  	; move invalid?

	dec 	player_x 				; decrease player_x by 1 to inspect space to the left
	jsr 	check_collision	 		; check square left of player
	inc 	player_x 				; increase player_x by 1 to restore to original value
	cmp 	platform_tile	 	  	; is a platform?
	beq 	left_collided	 	  	; prevent player from moving through

	cmp     fly_one
  beq     left_catched_one

  cmp     fly_two
  beq     left_catched_two

	jsr 	erase_player	 		; set blank tile

	dec 	player_x				; player_x-=1
	jsr 	draw_player	 			; set current location to player, i.e. draws player

	jsr 	check_ground_collision  ; check square below player
	cmp 	platform_tile	 	  	; is a platform?
	bne 	walked_over_left_ledge  ; start falling if no floor or platform below

left_collided:
	rts

left_catched_one:
	jsr     increment_score
	jsr     erase_fly_one
	rts

left_catched_two:
	jsr     increment_score
	jsr     erase_fly_two
	rts

walked_over_left_ledge:		 		; start falling if no floor or platform below
	jsr 	enter_fall_state		; transition to falling state
	rts


; Move player right by 1
move_right:
	ldx 	player_x				; load player x
	cpx 	max_x_offset			; right boarder collision?
	beq 	right_collided	 	 	; move invalid?

	inc 	player_x 				; increase player_x by 1 to inspect space to the right
	jsr 	check_collision	 		; check square above player
	dec 	player_x 				; decrease player_x by 1 to restore to original value
	cmp 	platform_tile	 	  	; is a platform?
	beq 	right_collided	 	 	; prevent player from moving through

	cmp     fly_one
	beq     right_catched_one

  cmp     fly_two
	beq     right_catched_two


	jsr 	erase_player	 		; set blank tile

	inc 	player_x				; player_x+=1
	jsr 	draw_player	 			; set current location to player, i.e. draws player

	jsr 	check_ground_collision  ; check square below player
	cmp 	platform_tile	 	  	; is a platform?
	bne 	walked_over_right_ledge ; start falling if no floor or platform below

right_collided:
	rts

right_catched_one:
	jsr     increment_score
	jsr     erase_fly_one
	rts

right_catched_two:
	jsr     increment_score
	jsr     erase_fly_two
	rts

walked_over_right_ledge:
	jsr 	enter_fall_state		; transition to falling state
	rts


; Move player up by 1
move_up:
	dec 	player_y 				; decrease player_y by 1 to inspect space above
	jsr 	check_collision	 		; check square above player
	inc 	player_y 				; increase player_y by 1 to restore to original value
	cmp 	platform_tile	 	  	; is a platform?
	beq 	roof_collided	 	  	; prevent player from moving through

	cmp     fly_one
  beq     roof_catched_one

  cmp     fly_two
  beq     roof_catched_two

	jsr 	erase_player	 		; set blank tile
	dec 	player_y				; player_y-=1
	jsr 	draw_player	 			; set current location to player, i.e. draws player
	rts

roof_collided:
	rts

roof_catched_one:
	jsr     increment_score
	jsr     erase_fly_one
	rts

roof_catched_two:
	jsr     increment_score
	jsr     erase_fly_two
	rts

; Move player up by 1, and left by 1
move_up_left:
	ldx 	player_x				; load player x
	cpx 	min_x_offset			; left boarder collision?
	beq 	upleft_collided	 		; move invalid?
	dec 	player_y 				; decrease player_y by 1 to inspect space above
	dec 	player_x 				; decrease player_x by 1 to inspect space to the left
	jsr 	check_collision	 		; check square left of player
	inc 	player_y 				; increase player_y by 1 to restore to original value
	inc 	player_x 				; increase player_x by 1 to restore to original value
	cmp 	platform_tile	 	  	; is a platform?
	beq 	upleft_collided	 		; prevent player from moving through

	cmp     fly_one
  beq     upleft_catched_one

	cmp     fly_two
  beq     upleft_catched_two

	jsr 	erase_player	 		; set blank tile
	dec 	player_y 				; player_y-=1
	dec 	player_x 				; player_x-=1
	jsr 	draw_player	 			; set current location to player, i.e. draws player

upleft_collided:
	rts

upleft_catched_one:
	jsr     increment_score
	jsr     erase_fly_one
	rts

upleft_catched_two:
	jsr     increment_score
	jsr     erase_fly_two
	rts

; Move player up by 1, and right by 1
move_up_right:
	ldx 	player_x				; load player x
	cpx 	max_x_offset			; right boarder collision?
	beq 	upright_collided		; move invalid?
	dec 	player_y 				; decrease player_y by 1 to inspect space above
	inc 	player_x 				; increase player_x by 1 to inspect space to the right
	jsr 	check_collision	 		; check square right of player
	inc 	player_y 				; increase player_y by 1 to restore to original value
	dec 	player_x 				; decrease player_x by 1 to restore to original value
	cmp 	platform_tile	 	  	; is a platform?
	beq 	upright_collided		; prevent player from moving through

	cmp     fly_one
	beq     upright_catched_one

	cmp     fly_two
	beq     upright_catched_two

	jsr 	erase_player	 		; set blank tile
	dec 	player_y 				; player_y-=1
	inc 	player_x 				; player_x+=1
	jsr 	draw_player	 			; set current location to player, i.e. draws player

upright_collided:
	rts

upright_catched_one:
	jsr     increment_score
	jsr     erase_fly_one
	rts

upright_catched_two:
	jsr     increment_score
	jsr     erase_fly_two
	rts

; Move player down by 1
move_down:
	jsr 	check_ground_collision  ; check square below player
	cmp 	platform_tile	 	  	; is a platform?
	beq 	down_collided	 	 	; collision if below is a platform tile

	cmp     fly_one
	beq     down_catched_one

	cmp     fly_two
	beq     down_catched_two

	jsr 	erase_player	 		; set blank tile

	inc 	player_y 				; player_y += 1
	jsr 	draw_player	 			; set current location to player, i.e. draws player
	rts

down_collided:
	jsr 	enter_idle_state
	rts

down_catched_one:
	jsr     increment_score
	jsr     erase_fly_one
	jsr     enter_idle_state
	rts

down_catched_two:
	jsr     increment_score
	jsr     erase_fly_two
	jsr     enter_idle_state
	rts

; Get character at current player location
check_collision:
	lda 	player_x				; load xcoord
	sta 	cursor_x				; store xcoord
	lda 	player_y				; load ycoord
	sta 	cursor_y				; store ycoord
	jsr 	get_character	 	  	; find current tile on screen
	lda 	character		 	  	; load current tile on screen
	rts

; Get character 1 below player location (x, y + 1)
check_ground_collision:
	inc 	player_y 				; increase player_y by 1 to inspect space below

	lda 	player_x				; load xcoord
	sta 	cursor_x				; store xcoord
	lda 	player_y				; load ycoord
	sta 	cursor_y				; store ycoord
	jsr 	get_character	 	  	; find current tile on screen

	dec 	player_y 				; decrease player_y by 1 to restore to original value

	lda 	character		 	  	; load current tile on screen
	rts


; UTILITY FUNCTIONS

; Displays the player at their current x, y
draw_player:
	lda 	player_x				; load xcoord
	sta 	cursor_x				; store xcoord
	lda 	player_y				; load ycoord
	sta 	cursor_y				; store ycoord
	lda 	player_graphic	 	 	; load player graphic
	sta 	character		 	  	; store player graphic
	lda 	player_colour 			; load player colour
	sta 	colour			 	 	; store player colour
	jsr 	place_character	 		; draw to screen

	rts


; Removes the player graphic.
; Usually called before moving the player
erase_player:
	lda 	player_graphic
	sta 	prev_player_graphic

	lda 	#32
	sta 	player_graphic
	jsr 	draw_player

	lda 	prev_player_graphic
	sta 	player_graphic

	rts

erase_fly_one:
	lda     fly_one
	sta     prev_fly_one

	lda     #32
	sta     fly_one
	jsr     init_fly_one

	lda     prev_fly_one
	sta     fly_one

erase_fly_two:
	lda     fly_two
	sta     prev_fly_two

	lda     #32
	sta     fly_two
	jsr     init_fly_two

	lda     prev_fly_two
	sta     fly_two

increment_score:
	rts

; Waits in an 85x85 busy loop
wait_short_delay:
	lda 	#85
	sta 	delay_time
	jsr 	set_delay

	rts


; Waits in an 125x125 busy loop
wait_long_delay:
	lda 	#125
	sta 	delay_time
	jsr 	set_delay

	rts


; Busy loop that waits delay_time^2 cycles
set_delay:
	ldx 	delay_time		 	 	; load number of busy cycles

set_delay_outer:
	ldy 	delay_time		 	 	; total number of cycles equals to delay_time squared

set_delay_inner:
	dey					 			; y -= 1
	;cpy 	#0				 	 	; y = 0 ?
	bne 	set_delay_inner			; go back decrement loop

	dex 					 	 	; x -= 1
	;cpx 	#0				 	 	; x = 0 ?
	bne 	set_delay_outer			; go back to main loop

busy_loop_exit:
	rts

; Hard Coded Map
init_map:
	ldy 	#0						; load y with 0 counter

init_map_loop:
	lda 	platform_tile	 	  	; load graphic 'T'
	sta 	$1F76,y			 		; display graphic 'T'
	sta 	$1F21,y			 		; display graphic 'T'
	sta 	$1ECC,y			 		; display graphic 'T'
	sta 	$1E71,y			 		; display graphic 'T'
	sta 	$1E7C,y			 		; display graphic 'T'
	sta 	$1ED1,y			 		; display graphic 'T'
	sta 	$1F2C,y			 		; display graphic 'T'
	sta 	$1F87,y			 		; display graphic 'T'

	lda 	#0				 	 	; load color black
	sta 	$9776,y			 		; set platform color to black
	sta 	$9721,y			 		; set platform color to black
	sta 	$96CC,y			 		; set platform color to black
	sta 	$9671,y			 		; set platform color to black
	sta 	$967C,y			 		; set platform color to black
	sta 	$96D1,y			 		; set platform color to black
	sta 	$972C,y			 		; set platform color to black
	sta 	$9787,y			 		; set platform color to black

	iny					 			; y += 1
	cpy 	#4				 	 	; creates platforms of size 4
	bne 	init_map_loop			; loop until platform stretches end to end

	rts

; Creates a floor across the bottom
init_floor:
	ldx 	#0
	stx 	cursor_x

	ldx 	#21
	stx 	cursor_y

	lda 	#20				 		; load 'T'
	sta 	character

	lda 	#2				 	 	; load color red
	sta 	colour

init_floor_loop:
	jsr 	place_character
	inc 	cursor_x
	lda 	cursor_x
	cmp 	#22
	bne 	init_floor_loop	 		; loop until floor stretches end to end
	rts

init_fly_one:
	ldy     #0                                              ; load y with 0 counter

init_fly_one_loop:
	lda     fly_one                                 ; load graphic Z
	sta     $1E67,y                                 ; display graphic Z
  lda     #1                                      ; load colour white
	sta     $9767,y                                 ; set fly colour to white

	rts

init_fly_two:
	ldy     #0                                      ; load y with 0 counter

init_fly_two_loop:
	lda     fly_two                                 ; load graphic U
	sta     $1F60,y                                 ; display graphic
	lda     #1                                      ; load colour white
	sta     $9660,y                                 ; set fly colour to white

	rts

; Changes state based off of previous state and current key pressed
; Utilizes the transition table heavily
update_state:
	lda 	#0				 	 	; initialize a to 0
	ldy 	state			 	  	; initialize y to state

update_state_offset:
	cpy 	#00				 		; might not be needed
	beq 	update_state_offset_end
	dey
	clc
	adc 	num_states
	jmp 	update_state_offset

update_state_offset_end:
	sta 	state_offset			; state_offset = state * num_states
	ldx 	#0				 	 	; x = 0

update_state_inner:
	txa
	clc
	adc 	state_offset
	tay					 			; y = state_offset + x
	lda 	transition_table,y 	 	; a = transition_table[y] (transition_table[state][x])
	cmp 	$00C5			 	  	; compare a to current held key
	beq 	update_state_outer 	 	; if (a == held key) then exit loop
	inx					 			; x += 1
	cpx 	num_states		 	 	; check if (x == num_states)
	bne 	update_state_inner 	 	; if not then keep going
	rts					 			; if no transition found, stay in current state

update_state_outer:
	stx 	state			 	  	; current x is new state
	rts


; Utility function for place_character and get_character
; Finds the screen and colour page that the cursor x and y are on
;
; See page 271 of guide for screen map
get_character_page:
	lda 	cursor_x
	sta 	cursor_x_new 			; setup temp cursor
	lda 	cursor_y
	sta 	cursor_y_new 			; setup temp cursor
	clc
	cmp 	#12
	bcc 	pc_ylt_12		 	  	; cursor_y less than 12
	lda 	#$1f 					; coords y >= 12 have character page 1f
	sta 	character_page
	lda 	#$97 					; coords y >= 12 have colour page 97
	sta 	colour_page

	lda 	cursor_y_new
	sec 							; clear carry before subtraction
	sbc 	#12
	sta 	cursor_y_new			; cursor_y_new -= 12

	lda 	cursor_x_new
	clc 							; set carry before add
	adc 	#8
	sta 	cursor_x_new 			; cursor_x_new += 8
	jmp 	pc_offset

pc_ylt_12:
	cmp 	#11
	bne 	pc_ylt_11		 	  	; y less than 11

	lda 	cursor_x
	cmp 	#14
	bcc 	pc_xlt_14		 	  	; y = 11, x less than 14

	; y = 11, x >= 14
	lda 	#$1f 					; when y = 11, x >= 14 then character page 1f
	sta 	character_page
	lda 	#$97					; when y = 11, x >= 14 then colour page 97
	sta 	colour_page

	lda 	cursor_x
	sec
	sbc 	#14
	sta 	cursor_x_new			; cursor_x_new -= 14

	lda 	#0
	sta 	cursor_y_new			; cursor_y_new = 0
	jmp 	pc_offset

pc_xlt_14:
pc_ylt_11:
	lda 	#$1e 					; (y < 11 or (y == 11 and x < 14) then character page 1e)
	sta 	character_page
	lda 	#$96					; (y < 11 or (y == 11 and x < 14) then colour page 96)
	sta 	colour_page

pc_offset:
	ldy 	#0
	lda 	#0

pc_offset_loop:
	cpy 	cursor_y_new
	beq 	pc_offset_loop_exit
	clc
	adc 	#22						; a += 22
	iny
	jmp 	pc_offset_loop

pc_offset_loop_exit:
	clc
	adc 	cursor_x_new
	sta 	pc_vertical_offset 		; pc_vertical_offset = cursor_x_new + (row_length * cursor_y_new)
	rts


; function to place a character at an x, and y
place_character:
	jsr 	get_character_page
	lda 	#00
	sta 	$00
	lda 	character_page
	sta 	$01
	ldy 	pc_vertical_offset
	lda 	character
	sta 	($00),y
	lda 	#00
	sta 	$00
	lda 	colour_page
	sta 	$01
	ldy 	pc_vertical_offset
	lda 	colour
	sta 	($00),y
	rts


; function to get a character at an x, and y
get_character:
	jsr 	get_character_page
	lda 	#00
	sta 	$00
	lda 	character_page
	sta 	$01
	ldy 	pc_vertical_offset
	lda 	($00),y
	sta 	character
	rts


; Changes the player to the idle sprite
load_sprite_player_idle:
	lda 	#23
	sta 	player_graphic	 	 	; w = 23 = idle
	rts


; Changes the player to the left sprite
load_sprite_player_right:
	lda 	#24
	sta 	player_graphic	 	 	; x = 24 = right
	rts


; Changes the player to the right sprite
load_sprite_player_left:
	lda 	#25
	sta 	player_graphic	 	 	; y = 25 = left
	rts

;
; VARIABLES
;

; Variables for state machine
state:					 	 		; stores current state
	dc.b 	#6

num_states:				 	 		; amount of states
	dc.b 	#8

state_offset:						; offset for transition table
	dc.b 	#0

; an n x n table to represent state transitions
; 	State machine can have n states (such that n*n < 256-n)
;		- this restriction comes from using a single register to index an n x n table
; 	Each state can have one key to transition from state a to state b
; 	Can have final states with no exit transitions
transition_table:
	; idle
	dc.b 	#64, #17, #18, #32, #48, #49, #16, #32

	; left
	dc.b 	#64, #17, #18, #9, #32, #49, #16, #32

	; right
	dc.b 	#64, #17, #18, #9, #48, #32, #16, #32

	; up
	dc.b 	#64, #16, #16, #9, #16, #16, #16, #16

	; up left
	dc.b 	#64, #16, #16, #16, #48, #16, #16, #16

	; up right
	dc.b 	#64, #16, #16, #16, #16, #49, #16, #16

	; falling state
	dc.b 	#16, #16, #16, #16, #16, #16, #16, #16

	; attack state
	dc.b 	#16, #16, #16, #16, #16, #16, #16, #16

	;key 64 is NO KEY 	(no other key is pressed)
	;key 9  is W
	;key 17 is A
	;key 18 is D
	;key 48 is Q
	;key 49 is E
	;key 32 is SPACE
	;key 16 is NONE 	(not bound to anything)

; Variables for get_character and place_character
colour:
	dc.b 	#0

character:
	dc.b 	#0

cursor_x:
	dc.b 	#10

cursor_y:
	dc.b 	#10

cursor_x_new:
	dc.b 	#0

cursor_y_new:
	dc.b 	#0

pc_vertical_offset:
	dc.b 	#0

character_page:
	dc.b 	#$1e

colour_page:
	dc.b 	#$96


; Player variables
player_x:
	dc.b 	#10

player_y:
	dc.b 	#10

player_colour:
	dc.b	#05

prev_player_graphic:
	dc.b 	#24

player_graphic:
	dc.b 	#24

platform_tile:
	dc.b 	#20

min_x_offset:
	dc.b 	#0

max_x_offset:
	dc.b 	#21

move_loop_counter:
	dc.b	#0

; Busy loop variable
delay_time:
	dc.b 	#0

fly_one:
  dc.b    #26

prev_fly_one:
	dc.b    #26

fly_two:
	dc.b    #21

prev_fly_two:
	dc.b    #21

;
; SPRITES
;
spr_frog_idle:
	dc.b 	#$00, #$66, #$5A, #$DB, #$FF, #$66, #$FF, #$E7

spr_frog_right:
	dc.b 	#$36, #$6D, #$6D, #$FF, #$FF, #$FC, #$DA, #$65

spr_frog_left:
	dc.b 	#$6C, #$B6, #$B6, #$FF, #$FF, #$3F, #$5B, #$A6

spr_blank:
	dc.b 	#$00, #$00, #$00, #$00, #$00, #$00, #$00, #$00

spr_solid:
	dc.b 	#$FF, #$FF, #$FD, #$FD, #$7A, #$7A, #$1C, #$1C 		; Stalactite?
	;dc.b 	#$FF, #$81, #$81, #$81, #$81, #$81, #$81, #$FF 		; Cube

spr_fly1:
    dc.b    #$00, #$28, #$10, #$00, #$00, #$00, #$00, #$00

spr_fly2:
    dc.b    #$00, #$00, #$28, #$10, #$00, #$00, #$00, #$00

spr_frog_right_eat:
		dc.b    #$36, #$6D, #$6D, #$FF, #$F0, #$FF, #$DA, #$65

spr_frog_left_eat:
		dc.b    #$6C, #$B6, #$B6, #$FF, #$0F, #$FF, #$5B, #$A6
