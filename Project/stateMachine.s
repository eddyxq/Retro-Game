; Changes state based off of current state and current key pressed
; Utilizes the transition table heavily
update_state:
    lda     #0                      ; a = 0 (used as sum of offset)
    ldy     state                   ; y = state (used as loop counter)

update_state_offset:
    cpy     #00
    beq     update_state_offset_end ; if (y == 0) then exit
    dey                             ; y -= 1
    clc                             ; clear carry
    adc     num_states              ; a += num_states
    jmp     update_state_offset     ; jump to loop condition

update_state_offset_end:
    sta     state_offset            ; state_offset = state * num_states
    ldx     #0                      ; x = 0

update_state_inner:
    txa                             ; a = x
    clc                             ; clear carry
    adc     state_offset            ; a += state_offset
    tay                             ; y = state_offset + x
    lda     transition_table,y      ; a = transition_table[y] (transition_table[state][x])
    cmp     $00C5                   ; compare a to current held key
    beq     update_state_outer      ; if (a == held key) then exit loop
    inx                             ; x += 1
    cpx     num_states              ; check if (x == num_states)
    bne     update_state_inner      ; if not then keep going
    rts                             ; if no transition found, stay in current state

update_state_outer:
    stx     state                   ; current x is new state
    rts


; main state machine loop
run_state_machine:
    lda     state                   ; load state

rsm_s0:
    cmp     #00                     ; check if state 0
    bne     rsm_s1                  ; if not state 0 go to else if
    jsr     state_idle              ; if state 0, execute state idle
    jmp     rsm_end                 ; go to main end after state 0

rsm_s1:
    cmp     #01                     ; check if state 1
    bne     rsm_s2                  ; if not state 1 go to else if
    jsr     state_left              ; if state 1, go to state left
    jmp     rsm_end                 ; go to main end after state 1

rsm_s2:
    cmp     #02                     ; check if state 2
    bne     rsm_s3                  ; if not state 2 go to else
    jsr     state_right             ; if state 2, go to state right
    jmp     rsm_end                 ; go to main end after state 2

rsm_s3:
    cmp     #03                     ; check if state 3
    bne     rsm_s4                  ; if not state 3 go to else
    jsr     state_jump              ; if state 3, go to state up
    jmp     rsm_end                 ; go to main end after state 3

rsm_s4:
    cmp     #04                     ; check if state 4
    bne     rsm_s5                  ; if not state 4 go to else
    jsr     state_jump_left         ; if state 4, go to state up left
    jmp     rsm_end                 ; go to main end after state 4

rsm_s5:
    cmp     #05                     ; check if state 5
    bne     rsm_s6                  ; if not state 5 go to else
    jsr     state_jump_right        ; if state 5, go to state up right
    jmp     rsm_end                 ; go to main end after state 5

rsm_s6:
    cmp     #06                     ; check if state 6
    bne     rsm_end                  ; if not state 6 go to else
    jsr     state_fall              ; if state 6, go to state falling

rsm_end:
    rts

;
; STATES
;

enter_idle_state:
    lda     #0                      ; load idle state
    sta     state                   ; enter idle state
    rts


enter_fall_state:
    lda     #6                      ; load fall state
    sta     state                   ; store fall state
    rts


state_idle:
    jsr     load_sprite_player_idle ; load idle sprite
    jsr     draw_player             ; draw player
    rts


state_left:
    jsr     load_sprite_player_left ; load left sprite
    jsr     draw_player             ; draw player
    jsr     move_left               ; move left
    rts


state_right:
    jsr     load_sprite_player_right; load right sprite
    jsr     draw_player             ; draw player
    jsr     move_right              ; move right
    rts


state_jump:
    lda     move_loop_counter       ; load counter
    cmp     #0                      ; loop finished?
    bne     state_jump_loop         ; jump
    lda     #4                      ; move up 4 times
    sta     move_loop_counter       ; update counter
    jsr     play_jump_sound         ; play jump sfx
state_jump_loop:
    jsr     move_up                 ; move player upwards
    dec     move_loop_counter
    bne     state_jump_end
    jsr     enter_fall_state        ; transition to falling state
state_jump_end:
    rts


state_jump_left:
    lda     move_loop_counter       ; load counter
    cmp     #0                      ; loop finished?
    bne     state_jump_left_loop    ; jump left
    jsr     load_sprite_player_left ; load left sprite
    jsr     move_up                 ; move up
    lda     #3                      ; move up left 3 times
    sta     move_loop_counter       ; update counter
    jsr     play_jump_sound         ; play jump sfx

state_jump_left_loop:
    jsr     move_up                 ; moves up one square
    jsr     move_left               ; moves left one square
    dec     move_loop_counter       ; loop amount moved by the number specified in accmulator
    bne     state_jump_left_end     ; loop done?
    jsr     move_left               ; move one extra spot at the end
    jsr     enter_fall_state        ; transition to falling state
state_jump_left_end:
    rts


state_jump_right:
    lda     move_loop_counter       ; load counter
    cmp     #0                      ; loop finished?
    bne     state_jump_right_loop   ; jump right
    jsr     load_sprite_player_right; load right sprite
    jsr     move_up                 ; move up
    lda     #3                      ; move up right 4 times
    sta     move_loop_counter       ; store counter
    jsr     play_jump_sound         ; play jump sfx


state_jump_right_loop:
    jsr     move_up                 ; moves up one square
    jsr     move_right              ; moves right one square
    dec     move_loop_counter       ; loop amount moved by the number specified in accumulator
    bne     state_jump_right_end    ; loop done?
    jsr     move_right              ; moves one extra spot at the end
    jsr     enter_fall_state        ; transition to falling state
state_jump_right_end:
    rts


state_fall:
    jsr     move_down               ; moves the player downwards when they are in fall state
    rts


;
; VARIABLES
;

move_loop_counter:
    dc.b    #0                      ; counter for loops

; Variables for state machine
state:                              ; stores current state
    dc.b    #6

num_states:                         ; amount of states
    dc.b    #7

state_offset:                       ; offset for transition table
    dc.b    #0

; an n x n table to represent state transitions
;     State machine can have n states (such that n*n < 256-n)
;        - this restriction comes from using a single register to index an n x n table
;     Each state can have one key to transition from state a to state b
;     Can have final states with no exit transitions
;
;     This could have been optimized better
;     It was originally designed with the idea that
;     there would be more transitions however we
;     decided to lock the player into states
;     
;     Could be fixed with RLE or creating a more fluid
;     movement system
transition_table:
    ; idle
    dc.b     #64, #17, #18, #32, #16, 16, #16

    ; left
    dc.b     #64, #17, #18, #16, #32, #16, #16

    ; right
    dc.b     #64, #17, #18, #16, #16, #32, #16

    ; up
    dc.b     #16, #16, #16, #16, #16, #16, #16

    ; up left
    dc.b     #16, #16, #16, #16, #16, #16, #16

    ; up right
    dc.b     #16, #16, #16, #16, #16, #16, #16

    ; falling state
    dc.b     #16, #16, #16, #16, #16, #16, #16
    
    ;key 64 is NO KEY     (no key is currently pressed)
    ;key 9  is W
    ;key 17 is A
    ;key 18 is D
    ;key 48 is Q
    ;key 49 is E
    ;key 32 is SPACE
    ;key 16 is NONE     (not bound to anything)