; test program that changes background to green and purple by pressing A or D
  
        processor 6502	;specify 6502 processor
        org $1001	;beginning of our memory

        dc.w    nextstmt
        dc.w    10
        dc.b    158, "4109"
        dc.b    0

nextstmt
        dc.w    0
        jsr     $e55f   ;clear
loop
        lda     $00c5	;check if key is pressed
        cmp     #18     ;if it is A
        beq     purple	;go to purple
        cmp     #17     ;if it is D
        beq     green	;go to green
        jmp     loop	

purple
        lda     #65     ;load A
        lda     #29     ;green
        sta     $900F   ;set screen
        jmp     loop	;go to loop

green
        lda     #68     ;load D
        lda     #28     ;purple
        sta     $900F   ;set screen
        jmp     loop	;go to loop

        rts             ;return
