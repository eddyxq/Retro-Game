; test program that shows a green heart and by pressing A, it adds a red heart

        processor 6502	;specify 6502 processor
        org $1001	;beginning of our memory

        dc.w    nextstmt
        dc.w    10
        dc.b    158, "4109"
        dc.b    0

nextstmt
        dc.w    0
	jsr	$e55f		;clear
       
heart
        lda 	#83		;heart
        sta 	$1fe4,x		;display heart 
        lda 	#5		;green
        sta 	$97e4,x		;set it to green 

loop
	lda	$00c5 		;key pressed
        cmp     #17     	;if it is A
        beq     print		;go to print
        jmp     loop		;go to loop

print   
	lda     #83             ;heart
        sta     $1fe4,x+1     	;display heart
        lda     #2              ;red
        sta     $97e4,x+1	;set it to red
	jmp	loop		;go to loop

	rts		        ;return
