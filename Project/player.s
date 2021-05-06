; Contains functions for moving the player (frog)

; Moves the player left
move_left:
    ldx     player_x                ; load player x
    cpx     min_x_offset            ; left border collision?
    beq     left_collided           ; move invalid?
    dec     player_x                ; decrease player_x by 1 to inspect space to the left
    jsr     check_collision         ; check square left of player
    inc     player_x                ; increase player_x by 1 to restore to original value
    cmp     platform_tile           ; is a platform?
    beq     left_collided           ; prevent player from moving through
    jsr     erase_player            ; set blank tile
    dec     player_x                ; player_x-=1
    jsr     draw_player             ; set current location to player, i.e. draws player
    jsr     check_ground_collision  ; check square below player
    cmp     platform_tile           ; is a platform?
    bne     walked_over_left_ledge  ; start falling if no floor or platform below
left_collided:
    rts
walked_over_left_ledge:             ; start falling if no floor or platform below
    lda     state                   ; load state
    cmp     #1                      ; compare
    bne     left_collided           ; return
    jsr     enter_fall_state        ; transition to falling state
    rts

; Moves the player right
move_right:
    ldx     player_x                ; load player x
    cpx     max_x_offset            ; right boarder collision?
    beq     right_collided          ; move invalid?
    inc     player_x                ; increase player_x by 1 to inspect space to the right
    jsr     check_collision         ; check square above player
    dec     player_x                ; decrease player_x by 1 to restore to original value
    cmp     platform_tile           ; is a platform?
    beq     right_collided          ; prevent player from moving through 
    jsr     erase_player            ; set blank tile
    inc     player_x                ; player_x+=1
    jsr     draw_player             ; set current location to player, i.e. draws player
    jsr     check_ground_collision  ; check square below player
    cmp     platform_tile           ; is a platform?
    bne     walked_over_right_ledge ; start falling if no floor or platform below
right_collided:
    rts
walked_over_right_ledge:
    lda     state                   ; load state
    cmp     #2                      ; compare 
    bne     right_collided          ; return
    jsr     enter_fall_state        ; transition to falling state
    rts

; Moves the player up
move_up:
    dec     player_y                ; decrease player_y by 1 to inspect space above
    jsr     check_collision         ; check square above player
    inc     player_y                ; increase player_y by 1 to restore to original value
    cmp     platform_tile           ; is a platform?
    beq     roof_collided           ; prevent player from moving through
    jsr     erase_player            ; set blank tile
    dec     player_y                ; player_y-=1
    jsr     draw_player             ; set current location to player, i.e. draws player
roof_collided:
    rts

; Moves the player down
move_down:
    inc     player_y
    jsr     check_collision         ; check square below player
    dec     player_y
    cmp     platform_tile           ; is a platform?
    beq     down_collided           ; collision if below is a platform tile
    cmp     lava_tile               ; is lava?
    beq     lava_collided           ; collision if below is a lava tile
    jsr     erase_player            ; set blank tile
    inc     player_y                ; player_y += 1
    jsr     draw_player             ; set current location to player, i.e. draws player
    rts
down_collided:
    jsr     enter_idle_state        ; transition to idle state
    rts
lava_collided:
    jsr     check_heart             ; check lives remaining
    rts

; Get character at current player location
check_collision:
    lda     player_x                ; load xcoord
    sta     cursor_x                ; store xcoord
    lda     player_y                ; load ycoord
    sta     cursor_y                ; store ycoord
    jsr     get_character           ; find current tile on screen
    lda     character               ; load current tile on screen
    sta     collider                ; store collision object
    cmp     fly_graphic             ; is a fly?
    bne     check_fly_collision_end ; do nothing
    jsr     erase_fly               ; erase eaten fly
check_fly_collision_end:
    rts

; Get character 1 below player location (x, y + 1)
check_ground_collision:
    inc     player_y                ; increase player_y by 1 to inspect space below
    lda     player_x                ; load xcoord
    sta     cursor_x                ; store xcoord
    lda     player_y                ; load ycoord
    sta     cursor_y                ; store ycoord
    jsr     get_character           ; find current tile on screen
    dec     player_y                ; decrease player_y by 1 to restore to original value
    lda     character               ; load current tile on screen
    rts

; UTILITY FUNCTIONS

; Displays the player at their current x and y coordinates
draw_player:
    lda     player_x                ; load xcoord
    sta     cursor_x                ; store xcoord
    lda     player_y                ; load ycoord
    sta     cursor_y                ; store ycoord

    jsr     get_character           ; get the character
    lda     character               ; where the player is
    sta     collider                ; about to be drawn to

    lda     player_graphic          ; load player graphic
    sta     character               ; store player graphic
    lda     col_player 				; load player colour
    sta     colour                  ; store player colour
    jsr     place_character         ; draw to screen

    lda     collider                ; if the player overwrites
    cmp     fly_graphic             ; a fly graphic then make
    bne     draw_player_end         ; a new fly, else continue

    ; fly_count is 2 right now but there is only one fly on the screen
    ; because drawing the player overwrote the fly graphic
    dec     fly_count               ; fly_count -= 1
    jsr     respawn_flies           ; place a fly somewhere else

draw_player_end:
    rts

; Removes the player graphic, usually called before moving the player
erase_player:
    lda     player_graphic          ; load player graphic
    sta     prev_player_graphic     ; store previous player graphic
    lda     #32                     ; blank tile
    sta     player_graphic          ; store player graphic
    jsr     draw_player             ; draw blank to erase player
    lda     prev_player_graphic     ; load previous player graphic
    sta     player_graphic          ; store player graphic
    rts

; Respawns the player at the specified spawning coordinates
reset_player:
    jsr     erase_player            ; erase player from screen
    lda     #5                      ; load x
    sta     player_x                ; store x
    lda     #0                      ; load y
    sta     player_y                ; store y
    jsr     draw_player             ; spawn player
    rts

; Changes the player to the idle sprite
load_sprite_player_idle:
    lda     #33                     ; load idle sprite
    sta     player_graphic          ; w = 23 = idle
    rts

; Changes the player to the right sprite
load_sprite_player_right:
    lda     #34                     ; load right sprite
    sta     player_graphic          ; x = 24 = right
    rts

; Changes the player to the left sprite
load_sprite_player_left:
    lda     #35                     ; load left sprite
    sta     player_graphic          ; y = 25 = left
    rts

; Player variables
player_x:
    dc.b    #5

player_y:
    dc.b    #0

prev_player_graphic:
    dc.b    #24          

player_graphic:
    dc.b    #33

platform_tile:
    dc.b    #37

lava_tile:
    dc.b    #41

min_x_offset:
    dc.b     #0
    
max_x_offset:
    dc.b    #21
