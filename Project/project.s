;This program is a retro 2D platformer game created for the VIC-20.

;Try to earn as much score as possible by moving around and eatting flies while 
;not falling down into the lava.

;Keyboard Controls:
;   Move the frog left and right with the 'A' and 'D' keys respectively
;   Jump and navigate menu screens with the 'space bar' key
;   Press 'return' key to manually restart the game


; CODE MAIN STARTS HERE

    processor 6502                  ; specify 6502 processor
    org      $1001                  ; beginning of our memory
    dc.w     nextstmt
    dc.w     10
    dc.b     158, "4109"
    dc.b     0

nextstmt:
    dc.w     0
        

; This is where assembly execution begins
game_start:
    ; change character memory to $1C00 / 7168 (our memory)
    lda     #$ff                    ; 255 designates $1C00 as start of character memory
    sta     $9005

    jsr     initialize_sound        ; initialize sound

    ; creates our character map by loading all game characters
    jsr     load_all_game_characters


; INITIALIZATION
reset_game:
    ; set screen colour and screen border colour
    ; See page 214-217
    lda     #%00001001              ; XXXX Y ZZZ (white border, black screen)
    sta     $900f
    jsr     draw_start_screen       ; draw start screen

    ; default values (can change these/make them not hardcoded)
    jsr     reset_player            ; move player to starting location
    jsr     reset_score             ; reset score to 0
    lda     #6                      ; falling state
    sta     state
    lda     #0                      ; load 0
    sta     game_over               ; store game over (0 = false)
    lda     #3
    sta     heart_score             ; init to 3 lives
    lda     #10
    sta     tenth_fly               ; reset tenth_fly to 10
    jsr     soft_reset
    lda     timestop_delay_max      ; load timestop delay max
    sta     timestop_delay          ; move timestop delay to timestop delay max
    lda     move_delay_max          ; load move delay max
    sta     move_delay              ; move move delay to move delay max


; Main Game Loop
main_start:
    lda     game_over               ; game over
    cmp     #1                      ; =1?
    beq     main_game_end           ; main game end


main_tsd:
    dec     timestop_delay          ; timestop_delay -= 1
    bne     main_check_exit         ; if > 0, goto main_check_exit
    lda     timestop_delay_max      ; load timestop_delay_max
    sta     timestop_delay          ; reset timestop_delay to timestop_delay_max


main_md:
    jsr     update_state            ; update current state based off of previous state and key press
    jsr     animation_tick          ; animation tick
    jsr     sound_tick              ; sound tick
    dec     move_delay              ; move_delay -= 1 
    bne     main_check_exit         ; if > 0, goto max_check_exit
    lda     move_delay_max          ; load move_delay_max
    sta     move_delay              ; reset move_delay  to move_delay_max
    jsr     run_state_machine       ; run state machine


main_check_exit:
    lda     $00C5
    cmp     #15                     ; RETURN
    bne     main_start              ; main start
    jmp     reset_game              ; reset game


main_game_end:
    jsr     stop_death_sound        ; stop death sound
    jsr     draw_end_screen         ; draw end screen
    jmp     reset_game              ; reset game


main_end:
    rts


; include all the files below
    INCLUDE "player.s"
    INCLUDE "fly.s"
    INCLUDE "pcg.s"
    INCLUDE "stateMachine.s"
    INCLUDE "characterSet.s"
    INCLUDE "screenMemory.s"
    INCLUDE "scoreCounter.s"
    INCLUDE "startScreen.s"
    INCLUDE "endScreen.s"
    INCLUDE "heart.s"
    INCLUDE "animation.s"
    INCLUDE "sound.s"
    INCLUDE "music.s"
    INCLUDE "respawnFly.s"


; Waits in an 125x125 busy loop
wait_long_delay:
    lda     #125                    ; load #125  
    sta     delay_time              ; move delay time to 125
    jsr     set_delay               ; set delay
    rts


; Busy loop that waits delay_time^2 cycles
set_delay:
    ldx     delay_time              ; load number of busy cycles
set_delay_outer:
    ldy     #255                    ; total number of cycles equals to delay_time squared
set_delay_inner:
    nop                             ; 3 no ops to create longer loop
    nop                             ; 3 no ops to create longer loop
    nop                             ; 3 no ops to create longer loop
    dey                             ; y -= 1
    bne     set_delay_inner         ; go back decrement loop
    dex                             ; x -= 1
    bne     set_delay_outer         ; go back to main loop
set_delay_exit:
    rts


soft_reset:
    jsr     stop_jump_sound         ; stop jump sound being played
    jsr     $e55f                   ; clear screen
    jsr     reset_fly_count         ; Reset fly count for respawning
    jsr     draw_score_text         ; draw score text
    jsr     draw_score_number       ; draw score number
    jsr     draw_heart_text         ; draw heart text
    jsr     draw_heart_number       ; draw heart number
    jsr     draw_player             ; init player
    jsr     create_map              ; create map
    jsr     play_jump_sound         ; generation end sound
    jsr     erase_player            ; erase player
    rts

;
; Variables
;

; Busy loop variable
delay_time:
    dc.b     #125

; inner loop
; delay that nothing happens
timestop_delay_max:
    dc.b     #60

; outer loop
; delay that everything but player
; movement happens
move_delay_max:
    dc.b     #40

timestop_delay:
    dc.b     #0

move_delay:
    dc.b     #0

;
; COLOURS
;
col_player:
    dc.b     #5         ; green

col_platform:
    dc.b     #7         ; yellow

col_fly:
    dc.b     #1         ; white
