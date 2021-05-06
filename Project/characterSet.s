; File for sprite loading

; Places sprites into character memory
load_all_game_characters:
    jsr     load_game_sprites       ; load game sprites
    jsr     load_letters            ; load letters
    jsr     load_numbers            ; load numbers
    inc     game_sprites_counter    ; game sprites counter + 1
    lda     game_sprites_counter    ; load game sprites counter
    cmp     #8                      ; check if it is #8
    bne     load_all_game_characters; if not, load all game characters
    rts


load_game_sprites:
    ; character offsets calculated with
    ; 0x1c00 + (n * 8)
    ; [33, 39), [40,47] are symbols (can replace them without harm) (39 is apostophre)
    ; remaining addresses: $1D40, $1D60, $1D68, $1D70, $1D78
    ldx     game_sprites_counter    ; get row offset for sprites

    lda     spr_frog_idle,x         ; load x byte of sprite
    sta     $1D08,x                 ; replace 33 character

    lda     spr_frog_right,x        ; load x byte of sprite
    sta     $1D10,x                 ; replace 34 character

    lda     spr_frog_left,x         ; load x byte of sprite
    sta     $1D18,x                 ; replace 35 character

    lda     spr_blank,x             ; load x byte of sprite
    sta     $1D00,x                 ; replace 36 character
    
    lda     spr_solid,x             ; load x byte of sprite
    sta     $1D28,x                 ; replace 37 character

    lda     spr_fly,x               ; load x byte of sprite
    sta     $1D30,x                 ; replace 38 character

    lda     spr_lava,x              ; load x byte of sprite
    sta     $1D48,x                 ; replace 41 character

    lda     spr_heart,x             ; load x byte of sprite
    sta     $1D50,x                 ; replace 42 character

    lda     spr_cross,x             ; load x byte of sprite
    sta     $1D58,x                 ; replace 43 character

    rts


load_letters:
	ldx 	game_sprites_counter    ; get row offset for sprites
    lda     $81d0,x                 ; Load : from standard characters
    sta     $1dd0,x                 ; Store in our character set
    lda 	$8138,x 				; Load apostophre from standard characters
    sta 	$1d38,x 				; Store in our character set
	ldy 	#26 					; loop counter for letters [0-26], [A-Z]
load_letters_loop:
	lda 	$8008,x 				; load current letter from standard characters
	sta 	$1C08,x 				; store current letter in our character set
	txa                             ; transfer x to a
	clc                             ; clear
	adc 	#8 						; x += 8 (this changes the current offset to the next letter)
	tax                             ; transfer x to a
	dey 							; y -= 1
	bne 	load_letters_loop 		; still have not copied letter Z over
	rts


load_numbers:
    ldx     game_sprites_counter    ; get row offset for sprites
    ldy     #10                     ; loop counter for numbers [0-9]

load_numbers_loop:
    lda     $8180,x                 ; load current number from standard characters
    sta     $1d80,x                 ; store current number in our character set
    txa                             ; transfer x to a
    clc                             ; clear
    adc     #8                      ; x += 8 (this changes the current offset to the next number)
    tax                             ; transfer x to a          
    dey                             ; y -= 1
    bne     load_numbers_loop 		; still have not copied number 9 over
    rts


; Variables for loading game sprites

game_sprites_counter:
    dc.b    #0

;
; SPRITES
;
spr_frog_idle:
    dc.b     #$00, #$66, #$5A, #$DB, #$FF, #$66, #$FF, #$E7

spr_frog_right:
    dc.b     #$36, #$6D, #$6D, #$FF, #$FF, #$FC, #$DA, #$65

spr_frog_left:
    dc.b     #$6C, #$B6, #$B6, #$FF, #$FF, #$3F, #$5B, #$A6

spr_blank:
    dc.b     #$00, #$00, #$00, #$00, #$00, #$00, #$00, #$00

spr_solid:
    dc.b     #$FF, #$FF, #$FD, #$FD, #$7A, #$7A, #$1C, #$1C

; animated sprite uses
; RLE on $00 bytes
spr_fly:
    dc.b    #$00, #$01, #$28, #$10, #$00, #$05             ; frame 0
    dc.b    #$00, #$02, #$28, #$10, #$00, #$04             ; frame 1
    dc.b    #$00, #$03, #$28, #$10, #$00, #$03             ; frame 2
    dc.b    #$00, #$02, #$28, #$10, #$00, #$04             ; frame 3

spr_heart:
    dc.b    #$00, #$6C, #$FE, #$FA, #$FA, #$7C, #$38, #$10

spr_cross:
    dc.b    #$00, #$00, #$44, #$28, #$10, #$28, #$44, #$00

; animated sprite uses
; RLE on $00 and $FF bytes
spr_lava:
    dc.b     #$00, #$01, #$60, #$FC, #$FF, #$05            ; frame 0
    dc.b     #$00, #$01, #$78, #$FE, #$FF, #$05            ; frame 1
    dc.b     #$00, #$01, #$3C, #$FE, #$FF, #$05            ; frame 2
    dc.b     #$00, #$01, #$1E, #$7F, #$FF, #$05            ; frame 3
    dc.b     #$00, #$01, #$07, #$9F, #$FF, #$05            ; frame 4
    dc.b     #$00, #$01, #$C1, #$E7, #$FF, #$05            ; frame 5
    dc.b     #$00, #$01, #$E0, #$F9, #$FF, #$05            ; frame 6
