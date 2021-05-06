; this is for animations of the lava and fly sprites
; 
; animated sprites use Run Length Encoding
; for repeated bytes of $00 and $FF


animation_tick:
    ; limits frames per second
	dec 	animation_timer         ; animation_timer -= 1
	bne 	animation_tick_end      ; if animation_timer > 0, exit
	jsr 	update_lava_frame       ; switch lava frame
	jsr 	update_fly_frame        ; switch fly frame
	lda 	animation_timer_max     ; load animation_timer_max
	sta 	animation_timer         ; reset timer
animation_tick_end:
	rts


update_lava_frame:
	lda 	frame_lava_offset       ; get current byte
	sta 	frame_offset            ; store for offset
	lda 	#<spr_lava              ; lower byte of sprite
	sta 	$00                     ; 0 page for indirect addr
	lda 	#>spr_lava              ; higher byte of sprite
	sta 	$01                     ; 0 page for indirect addr
	lda 	#$48                    ; lower byte of character sheet
	sta 	$02                     ; 0 page for indirect addr
	lda 	#$1D                    ; higher byte of character sheet
	sta 	$03                     ; 0 page for indirect addr
	jsr 	load_frame              ; replace character with new frame
	lda 	frame_offset            ; load frame offset
	cmp		frame_lava_max          ; check if it is frame lava max
	bne 	update_lava_frame_end   ; if not, update lava frame end
	lda 	#0                      ; loop animation
update_lava_frame_end:           
	sta 	frame_lava_offset       ; store frame lava offset
	rts


update_fly_frame:
	lda 	frame_fly_offset        ; get current frame
	sta 	frame_offset            ; store for offset
	lda 	#<spr_fly               ; lower byte of sprite
	sta 	$00                     ; 0 page for indirect addr
	lda 	#>spr_fly               ; higher byte of sprite
	sta 	$01                     ; 0 page for indirect addr
	lda 	#$30                    ; lower byte of character sheet
	sta 	$02                     ; 0 page for indirect addr
	lda 	#$1D                    ; higher byte of character sheet
	sta 	$03                     ; 0 page for indirect addr
	jsr 	load_frame              ; replace character with new frame
    lda 	frame_offset            ; load frame offset
	cmp		frame_fly_max           ; check if it is frame fly max
	bne 	update_fly_frame_end    ; if not, update fly frame end
	lda 	#0                      ; loop animation
update_fly_frame_end:
	sta 	frame_fly_offset        ; store frame fly offset
	rts


; stores current frame into character sheet
; place sprite address in $00, $01
; place character sheet address in $02, $03
; place sprite frame offset in frame_offset

; frame_offset indexes loading
; x register indexes storing
load_frame:
	ldx 	#0                      ; clear x register so we don't index
load_frame_loop:
	ldy 	frame_offset            ; get frame_offset for indexing
	lda 	($00),y                 ; load byte of current frame
	sta 	frame_byte              ; store byte of current frame to save
	inc 	frame_offset            ; increment byte to load next
	cmp 	#$FF                    ; =$FF?
	beq 	rle_run                 ; check if run of $FF
	cmp 	#$00                    ; =$00?
	beq 	rle_run                 ; check if run of $00
	jmp 	rle_loop                ; not a run of data


rle_run:
	ldy 	frame_offset            ; load pre-incremented offset
	lda 	($00),y                 ; get length of run
	sta 	rle_length              ; store for looping
	inc 	frame_offset            ; increment byte to load next


rle_loop:
	txa                             ; transfer x to y for proper addr. mode
	tay                             ; y = x
	lda 	frame_byte              ; load byte of current
	sta 	($02),y                 ; store in our character sheet
	inx                             ; pre-increment before any branch
	lda 	rle_length              ; load length
	cmp 	#0                      ; =0?
	beq 	rle_loop_end            ; if not a run, then skip rle_loop
	dec 	rle_length              ; decrement length
	bne 	rle_loop                ; check if run is over, if not then loop
rle_loop_end:
	cpx 	#8
	bne 	load_frame_loop         ; check if reached max bytes to store
load_frame_end:
	rts


;
; Variables
;


; used within load_frame
; to loop for length of run
rle_length:
	dc.b 	#0

; time between frames
; set to 1 so one dec instruction
; sets to 0 for beq
animation_timer:
	dc.b 	#1

; value to reset timer to
animation_timer_max:
	dc.b 	#100


; local var to load_frame
; current byte to store
frame_byte:
	dc.b 	#0

; offset of frame from frame 0
frame_offset:
	dc.b	#0


; LAVA VARIABLES
; current bytes of lava sprite
frame_lava_offset:
 	dc.b 	#0

; total bytes of lava sprite [0,n]
frame_lava_max:
	dc.b 	#42


; FLY VARIABLES
; current bytes of fly sprite
frame_fly_offset:
 	dc.b 	#0

; total bytes of fly sprite [0,n]
frame_fly_max:
	dc.b 	#24
