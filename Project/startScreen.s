; Contains functions for displaying the menu screen

draw_start_screen:
    jsr     $e55f                       ; Clear screen
    jsr     draw_center_graphic         ; draw frog and platforms
    jsr     draw_game_name              ; draw game name
    jsr     draw_press_space            ; draw press space
    jsr     wait_long_delay             ; run busy loop
    jsr     key_input_loop              ; check if space is pressed and play song
    jsr     stop_song                   ; user wants to play, stop song
    rts


draw_game_name:
    ; Set cursor_x and cursor_y to the x and y screen coordinates of where printing starts 
    lda     game_name_label_x           ; load game name label x
    sta     cursor_x                    ; move cursor x to game name label x
    lda     game_name_label_y           ; load game name label y
    sta     cursor_y                    ; move cursor y to game name label y
    lda     #1                          ; white
    sta     colour                      ; store colour white
    ldx     #0                          ; load 
    stx     game_name_text_offset       ; store game name text offset


; Prints "Jim's Purgatory"
draw_game_name_loop:
    ldx     game_name_text_offset       ; load game name text offset
    lda     game_name_text,x            ; load game name text 
    sta     character                   ; store game name text
    jsr     place_character             ; place game name text
    inc     game_name_text_offset       ; game name text offset + 1
    inc     cursor_x                    ; cursor x + 1
    lda     game_name_text_offset       ; load game name text offset
    cmp     #15                         ; check if it is 15
    bne     draw_game_name_loop         ; if not, keep drawing the title
    rts


; Prints "press space to start"
draw_press_space:
    lda     press_space_text_label_x    ; load press space text label x
    sta     cursor_x                    ; move cursor x to press space text label x
    lda     press_space_text_label_y    ; load press space text label y
    sta     cursor_y                    ; move cursor y to press space text label y
    lda     #1                          ; white
    sta     colour                      ; store colour
    ldx     #0                          ; load
    stx     game_name_text_offset       ; store game name text offset


draw_press_space_loop:
    ldx     game_name_text_offset       ; load game name text offset
    lda     press_space_text,x          ; load press space text
    sta     character                   ; store press space text
    jsr     place_character             ; place press space text
    inc     game_name_text_offset       ; game name text offset + 1
    inc     cursor_x                    ; cursor x + 1
    lda     game_name_text_offset       ; load game text offset
    cmp     #19                         ; check if it is 19
    bne     draw_press_space_loop       ; if not, keep drawing press space text
    rts


; wait for user to press <space> to rts
key_input_loop:
    jsr     play_song                   ; play song
    lda     $00c5                       ; Check for key press
    cmp     #32                         ; Check if its space
    bne     key_input_loop              ; if not, wait for key press
    rts

draw_center_graphic:
    lda     #11                         ; load
    sta     cursor_x                    ; move cursor x to #11
    sta     cursor_y                    ; move cursor y to #11
    lda     col_player                  ; load player colour
    sta     colour                      ; store colour
    lda     player_graphic              ; load player graphic
    sta     character                   ; store player graphic
    jsr     place_character             ; place player graphic
    lda     col_platform                ; load platform colour
    sta     colour                      ; store colour
    lda     platform_tile               ; load platform tile
    sta     character                   ; store platform tile
    dec     cursor_x                    ; cursor x - 1
    inc     cursor_y                    ; cursor y + 1
    jsr     place_character             ; place platform
    inc     cursor_x                    ; cursor x + 1
    jsr     place_character             ; place platform
    inc     cursor_x                    ; cursor x + 1
    jsr     place_character             ; place platform
    rts

game_name_text:
    dc.b	#10	; J
    dc.b	#9	; I
    dc.b	#13	; M
    dc.b	#39	; '
    dc.b	#19	; S
    dc.b	#32	; space
    dc.b	#16	; P
    dc.b	#21	; U
    dc.b	#18	; R	
    dc.b	#7	; G
    dc.b	#1	; A
    dc.b	#20	; T
    dc.b	#15	; O
    dc.b	#18	; R
    dc.b	#25	; Y

press_space_text:
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
    dc.b	#19	;S
    dc.b	#20	;T
    dc.b	#1	;A
    dc.b	#18	;R
    dc.b	#20	;T
    
game_name_label_x:
    dc.b	#3

game_name_label_y:
    dc.b	#5

game_name_text_offset:
    dc.b 	#0

press_space_text_label_x:
    dc.b 	#1

press_space_text_label_y:
    dc.b	#18
