; Utility function for place_character and get_character
; Finds the screen and colour page that the cursor x and y are on
;
; See page 271 of guide for screen map
get_character_page:
    lda     cursor_x
    sta     cursor_x_new            ; setup temp cursor
    lda     cursor_y
    sta     cursor_y_new            ; setup temp cursor
    clc
    cmp     #12
    bcc     pc_ylt_12               ; cursor_y less than 12
    lda     #$1f                    ; coords y >= 12 have character page 1f
    sta     character_page             
    lda     #$97                    ; coords y >= 12 have colour page 97
    sta     colour_page
    
    lda     cursor_y_new             
    sec                             ; clear carry before subtraction
    sbc     #12                     
    sta     cursor_y_new            ; cursor_y_new -= 12
    
    lda     cursor_x_new
    clc                             ; set carry before add
    adc     #8
    sta     cursor_x_new            ; cursor_x_new += 8
    jmp     pc_offset

pc_ylt_12:
    cmp     #11
    bne     pc_ylt_11               ; y less than 11
    
    lda     cursor_x
    cmp     #14
    bcc     pc_xlt_14               ; y = 11, x less than 14
    
    ; y = 11, x >= 14
    lda     #$1f                    ; when y = 11, x >= 14 then character page 1f
    sta     character_page
    lda     #$97                    ; when y = 11, x >= 14 then colour page 97
    sta     colour_page

    lda     cursor_x
    sec
    sbc     #14
    sta     cursor_x_new            ; cursor_x_new -= 14

    lda     #0
    sta     cursor_y_new            ; cursor_y_new = 0
    jmp     pc_offset

pc_xlt_14:
pc_ylt_11:
    lda     #$1e                    ; (y < 11 or (y == 11 and x < 14) then character page 1e)
    sta     character_page
    lda     #$96                    ; (y < 11 or (y == 11 and x < 14) then colour page 96)
    sta     colour_page

pc_offset:
    ldy     #0
    lda     #0

pc_offset_loop:
    cpy     cursor_y_new
    beq     pc_offset_loop_exit
    clc
    adc     #22                     ; a += 22
    iny
    jmp     pc_offset_loop             

pc_offset_loop_exit:
    clc
    adc     cursor_x_new
    sta     pc_vertical_offset      ; pc_vertical_offset = cursor_x_new + (row_length * cursor_y_new)
    rts


; function to place a character at an x, and y
;
; set cursor_x, cursor_y, colour, and character
; before calling
;
; 0 <= cursor_x <= 21
; 0 <= cursor_y <= 22
place_character:
    jsr     get_character_page      ; get the screen memory page of cursor_x and cursor_y
    lda     #00                     ; a = 0
    sta     $00                     ; store low-order bytes for indirect addr.
    lda     colour_page             ; a = colour_page
    sta     $01                     ; store high-order bytes for indirect addr.
    ldy     pc_vertical_offset      ; load low-order offset
    lda     colour                  ; a = colour
    sta     ($00),y                 ; store colour at page colour_page, with offset pc_vertical_offset
    lda     #00                     ; a = 0
    sta     $00                     ; store low-order bytes for indirect addr.
    lda     character_page          ; a = character_page
    sta     $01                     ; store high-order bytes for indirect addr.
    ldy     pc_vertical_offset      ; load low-order offset
    lda     character               ; a = character
    sta     ($00),y                 ; store character at page character_page, with offset pc_vertical_offset
    rts


; function to get a character at an x, and y
;
; set cursor_x, and cursor_y before calling
;
; the character will be stored in character
;
; 0 <= cursor_x <= 21
; 0 <= cursor_y <= 22
get_character:
    jsr     get_character_page      ; get the screen memory page of cursor_x and cursor_y
    lda     #00                     ; a = 0
    sta     $00                     ; store low-order bytes for indirect addr.
    lda     character_page          ; a = character_page
    sta     $01                     ; store high-order bytes for indirect addr.
    ldy     pc_vertical_offset      ; load low-order offset
    lda     ($00),y                 ; a = character at page character_page, with offset pc_vertical_offset
    sta     character               ; character = a
    rts



; Variables for get_character and place_character
colour:
    dc.b    #0

character:
    dc.b    #0

cursor_x:
    dc.b    #10

cursor_y:
    dc.b    #10

cursor_x_new:
    dc.b    #0

cursor_y_new:
    dc.b    #0

pc_vertical_offset:
    dc.b    #0

character_page:
    dc.b    #$1e

colour_page:
    dc.b    #$96