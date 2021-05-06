; Contains functions for the audio

play_song:
    ldx     note_index          ; load index of note to play
    lda     song,x              ; load time/note pair using index
    tax                         ; transfer time/note pair to x so we do not need to load again
    and     #$0F                ; isolate note index
    tay
    lda     notes,y             ; load note associated with index
    sta     $900B               ; play note
    txa
    and     #$F0                ; isolate note time
    sta     delay_time
    jsr     set_delay           ; wait in busy loop (n^2)
    lda     #0
    sta     $900B               ; release note
    lda     #$10
    sta     delay_time
    jsr     set_delay           ; wait in busy loop (80 * 255)
    inc     note_index          ; note_index += 1
    lda     note_index          ; accumulator = note_index (for compare)
    cmp     song_end            ; note_index == song_end?
    bne     end                 ; jump to end to prevent index reset
play_song_check_loop:
    lda     #0
    sta     note_index          ; loop song back to first note
end:
    rts


stop_song:
    lda     #0                  ; load 0
    sta     $900B               ; store 
    sta     note_index          ; update index
    rts


; VARIABLES

note_index:                     ; index for current note
    dc.b    #0

song_end:                       ; length of song array (max 255 notes)
    dc.b    #54

; song compression
; array of notes used in song
notes:
    dc.b    #0      ; rest  0
    dc.b    #201    ; D1    1
    dc.b    #203    ; E1b   2
    dc.b    #209    ; F1    3
    dc.b    #215    ; G1    4
    dc.b    #219    ; A2    5
    dc.b    #221    ; B2b   6
    dc.b    #225    ; C2    7
    dc.b    #212    ; F1#   8
    dc.b    #228    ; D2    9

            ; page 97 for value of notes
            ; first nibble = note length (n*16*255 in busy loop)
            ; second nibble = note index (in notes array)
song:       ; array of notes
    ; measure 1
    dc.b     #$C4
    dc.b     #$55
    ; 2

    ; measure 2
    dc.b     #$B6
    dc.b     #$55
    dc.b     #$54
    ; 5

    ; measure 3
    dc.b     #$55
    dc.b     #$54
    dc.b     #$55
    dc.b     #$56
    ; 9

    ; measure 4
    dc.b     #$B2
    dc.b     #$B1
    ; 11

    ; measure 5
    dc.b     #$64
    dc.b     #$35
    dc.b     #$64
    dc.b     #$45
    dc.b     #$46
    dc.b     #$45
    dc.b     #$44
    dc.b     #$48
    ; 19

    ; measure 6
    dc.b     #$64
    dc.b     #$35
    dc.b     #$64
    dc.b     #$45
    dc.b     #$B9
    ; 24

    ; measure 7
    dc.b     #$64
    dc.b     #$35
    dc.b     #$64
    dc.b     #$45
    dc.b     #$46
    dc.b     #$45
    dc.b     #$44
    dc.b     #$48
    ; 32

    ; measure 8
    dc.b     #$44
    dc.b     #$48
    dc.b     #$44
    dc.b     #$45
    dc.b     #$74
    dc.b     #$78
    ; 38

    ; measure 9
    dc.b     #$69
    dc.b     #$67
    dc.b     #$46
    dc.b     #$45
    ; 42

    ; measure 10
    dc.b     #$69
    dc.b     #$E7
    ; 44

    ; measure 11
    dc.b     #$69
    dc.b     #$67
    dc.b     #$46
    dc.b     #$45
    ; 48

    ; measure 12
    dc.b     #$46
    dc.b     #$45
    dc.b     #$46
    dc.b     #$47
    dc.b     #$56
    dc.b     #$55
    ; 54