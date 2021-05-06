draw_heart_text:
    lda     heart_sign_x          ; load heart sign x
    sta     cursor_x              ; move cursor x to heart sign x
    lda     sign_y                ; load sign y
    sta     cursor_y              ; move cursor y to sign y
    lda     #2                    ; red
    sta     colour                ; store colour red
    lda     heart_sign            ; load heart sign 
    sta     character             ; store heart sign
    jsr     place_character       ; place heart sign

    lda     cross_sign_x          ; load cross sign x
    sta     cursor_x              ; move cursor x to cursor x
    lda     sign_y                ; load sign y
    sta     cursor_y              ; move cursor y to sign y
    lda     #1                    ; white
    sta     colour                ; store colour white
    lda     cross_sign            ; load cross sign
    sta     character             ; store cross sign
    jsr     place_character       ; place cross sign

    rts


draw_heart_number:
    lda    num_sign_x             ; load num sign x
    sta    cursor_x               ; move cursor x to num sign x
    lda    sign_y                 ; load sign y
    sta    cursor_y               ; move cursor y to sign y
    lda    #1                     ; white
    sta    colour                 ; store colour white
    lda    heart_score            ; load heart score
    and    #$0F
    clc
    adc    #48
    sta    character              ; store heart score

    jsr    place_character        ; place heart score

    rts


check_heart:
    jsr     play_death_sound      ; play death sound
    lda     heart_score           ; load heart score
    cmp     #1                    ; is it 1?
    bne     check_heart_dec       ; if not, decrease heart score by 1

    lda     #1                     
    sta     game_over             ; if it is, game over
    jmp     check_heart_exit      ; exit

check_heart_dec:
    dec     heart_score           ; heart score - 1
    jsr     draw_heart_number     ; update heart score 
    jsr     reset_player          ; reset and continue the game
    
check_heart_exit:
    rts


heart_score:
    dc.b    #3

game_over:
    dc.b    #0

heart_text_offset:
   dc.b     #0

heart_sign_x:
   dc.b     #1

sign_y:
   dc.b     #0

heart_sign:
   dc.b     #42

cross_sign:
   dc.b     #43

cross_sign_x:
   dc.b     #2

num_sign_x:
   dc.b     #3
