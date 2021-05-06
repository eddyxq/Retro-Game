; Contains functions for procedurally generating a new random level 

; initilizes the stage by creating flies, platforms, and lava
create_map:
    lda     #20
    sta     delay_time

    jsr     init_platforms          ; display platforms
    jsr     respawn_flies           ; Set random fly spawn locations
    jsr     init_fly                ; display flies
    jsr     init_lava               ; display floor
    rts

init_platforms:
    ldx     #18                     ; first row of platforms
    stx     cursor_y                ; store y coord of first row
    ldx     #4                      ; first row of platforms
    stx     cursor_x                ; store x coord of first row
    jsr     draw_platform_row       ; randomly generate platforms for first row
    ldx     #14                     ; second row of platforms
    stx     cursor_y                ; store y coord of second row
    ldx     #1                      ; second row of platforms
    stx     cursor_x                ; store x coord of second row
    jsr     draw_platform_row       ; randomly generate platforms for second row
    ldx     #10                     ; third row of platforms
    stx     cursor_y                ; store y coord of third row
    ldx     #4                      ; third row of platforms
    stx     cursor_x                ; store x coord of third row
    jsr     draw_platform_row       ; randomly generate platforms for third row
    ldx     #6                      ; fourth row of platforms
    stx     cursor_y                ; store y coord of fourth row
    ldx     #1                      ; fourth row of platforms
    stx     cursor_x                ; store x coord of fourth row
    jsr     draw_platform_row       ; randomly generate platforms for fourth row
    rts

draw_platform_row:
    lda     platform_tile           ; load platform tile
    sta     character               ; store tile to character
    lda     #7                      ; load yellow
    sta     colour                  ; store color
    
init_platforms_loop:
    lda     #7                      ; load reset rand_max to original value
    sta     rand_max                ; store original value to use as counter again
    jsr     place_character         ; places one platform to ensure minimum platform size is always >=2
    inc     cursor_x                ; increment x to place second block next to first block
    
pcg_loop:
    jsr     play_platform_sound
    jsr     set_delay
    jsr     stop_jump_sound
    jsr     set_delay

    dec     rand_max                ; rand_max-=1
    jsr     place_character         ; places two platforms to ensure minimum platform size is >=2
    inc     cursor_x                ; x+=1
    jsr     get_rand_num            ; generate a new random number
    lda     rand_num                ; load random number
    cmp     rand_max                ; rand num == counter?
    beq     skip_platform           ; go to skip_platform
    lda     rand_max                ; load rand_max
    cmp     #1                      ; ==1?
    bne     pcg_loop                ; loop again
    
skip_platform:
    inc     cursor_x                ; creates a space of 3 blocks between each platform
    inc     cursor_x                ; creates a space of 3 blocks between each platform
    inc     cursor_x                ; creates a space of 3 blocks between each platform
    lda     cursor_x                ; load x
    cmp     #17                     ; <17?
    bcc     init_platforms_loop     ; loop until lava stretches end to end
    rts
    
; Creates a floor across the bottom
init_lava:
    ldx     #0                      ; start from left side of screen
    stx     cursor_x                ; store x
    ldx     #22                     ; create lava at the bottom of the screen
    stx     cursor_y                ; store y
    lda     lava_tile               ; load lava tile
    sta     character               ; store lava character
    lda     #2                      ; load color red
    sta     colour                  ; store color

init_lava_loop:
    jsr     place_character         ; place lava tile
    inc     cursor_x                ; x+=1
    lda     cursor_x                ; load x
    cmp     #22                     ; 22 blocks is the screen width
    bne     init_lava_loop          ; loop until lava stretches end to end
    rts
    
create_platform_below_player:
    lda     platform_tile           ; load platform tile
    sta     character               ; store tile to character
    lda     #7                      ; load yellow
    sta     colour                  ; store color
    lda     player_x                ; load player x
    sta     cursor_x                ; store x
    lda     player_y                ; load player y
    sta     cursor_y                ; store y
    inc     cursor_y                ; y+=1 to get position below player
    jsr     place_character         ; spawn platform under player so he does not fall through
    dec     cursor_x                ; x-=1
    jsr     place_character         ; spawn platform left of player so platform size is three
    inc     cursor_x                ; x+=1
    inc     cursor_x                ; x+=1
    jsr     place_character         ; spawn platform right of player so platform size is three
    rts
   
get_rand_num:
    lda     $9014                   ; load random byte
    and     #$7                     ; and with 111 to get last 3 bits
    sta     rand_num                ; store
    lda     #0                      ; load 0
    clc                             ; clear
    adc     rand_num                ; add
    sta     rand_num                ; store 
    rts

rand_num:                           ; variable containing the randomly generated number
    dc.b    #0
    
rand_max:                           ; max value of the random number, used as a counter
    dc.b    #7
