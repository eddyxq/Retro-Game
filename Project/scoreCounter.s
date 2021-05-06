; Contains functions for the game score counter


; Draws the score text at the score_label_x and _y
draw_score_text:
    lda     score_label_x                 ; load score label x
    sta     cursor_x                      ; move cursor x to score label x
    lda     score_label_y                 ; load score label y
    sta     cursor_y                      ; move cursor y to score label y
    ldx     #0                            ; load #0
    stx     score_text_offset             ; move score text offset x to #0

draw_score_text_loop:    
    ldx     score_text_offset             ; load score text offset x
    lda     score_text,x                  ; move score text x to score text offset
    sta     character                     ; store score text
    lda     #1                            ; white
    sta     colour                        ; store colour white
    jsr     place_character               ; place character
    inc     score_text_offset             ; score text offset + 1
    inc     cursor_x                      ; cursor_x + 1
    lda     score_text_offset             ; load score text offset
    cmp     #6                            ; check if it is #6
    bne     draw_score_text_loop          ; if not, draw score text loop
    rts    
    

; Draws the current score to the screen
; 100s digit is at y=0, x=score_digit_x
; 10s  digit is at y=0, x=score_digit_x+1
; 1s   digit is at y=0, x=score_digit_x+2
draw_score_number:
    lda     score_label_x                 ; load score label x
    clc
    adc     #6                            ; add #6 to score label x
    sta     cursor_x                      ; set cursor x
    lda     score_label_y                 ; load score label y
    sta     cursor_y                      ; set cursor y
    lda     #1                            ; white
    sta     colour                        ; store colour white

    ; hundreds place
    lda     player_score_100              ; load player score 100

    clc
    adc     #48                           ; number offset
    sta     character                     ; store character
    jsr     place_character               ; place digit

    ; tens place
    inc     cursor_x                      ; move cursor over one to the right
    
    lda     player_score                  ; load player score
    and     #$F0                          ; Get higher 4 bits

    ; lsr 4 times to save memory (less bytes than a loop)
    lsr
    lsr
    lsr
    lsr

    clc
    adc     #48                           ; number offset
    sta     character                     ; store digit
    jsr     place_character               ; place digit

    ; ones place
    inc     cursor_x                      ; move cursor over one to the right
    lda     player_score                  ; load player score
    and     #$0F                          ; get the lower 4 bits

    clc
    adc     #48                           ; number offset
    sta     character                     ; store digit
    jsr     place_character               ; place digit

    rts

; Increments the score using BCD for 3 digits
; then redraws the score
increment_score:
    jsr     play_eat_sound          ; play eat sound
    lda     player_score            ; get current score
    cmp     #$99                    ; check if its 0x99 
    beq     inc_player_score_100    ; if it is, inc player score 100
bcd_add:
    clc                             ; clear carry 
    sed                             ; set decimal mode for bcd addition
    adc     #1                      ; inc a by 1 in bcd
    cld                             ; clear decimal mode
    sta     player_score            ; put new score back in score
    jsr     draw_score_number       ; show updated score numbers
    rts
inc_player_score_100:
    lda     player_score_100        ; load player score 100
    cmp     #9                      ; check if it is #9
    beq     increment_score_exit    ; if it is, increment score exit
    inc     player_score_100        ; player score 100 + 1
    jmp     bcd_add                 ; bcd add
increment_score_exit:
    rts


reset_score:
    lda     #0                      ; load #0
    sta     player_score            ; move player score to #0
    sta     player_score_100        ; move player score 100 to #0
    sta     score_label_y           ; move score label y to #0
    lda     #13                     ; load #13
    sta     score_label_x           ; move score label x to #13
    rts


; Variables for score text
score_text:
    dc.b    #19     ; S 
    dc.b    #3      ; C 
    dc.b    #15     ; O 
    dc.b    #18     ; R 
    dc.b    #5      ; E 
    dc.b    #58     ; :

score_text_offset:
    dc.b    #0

score_label_x:
    dc.b    #13

score_label_y:
    dc.b    #0

player_score_100:
    dc.b    #0

player_score:
    dc.b    #0
