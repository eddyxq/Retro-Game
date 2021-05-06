; test program that trys to get a random byte
; prints random garbage to the screen

; Building onto my first test, experiementing with other memory locations. 
; On page 171 of the reference guide it says location 9004 is the TV raster beam line. 
; My knowledge in graphics made me think that since it is constantly scanning, the 
; value inside should not be static so I thought it would be worth a try.

; I think I have successfully managed to get a random byte, next I need to figure out how
; to convert this byte into a random number.

    processor 6502              ;specify 6502 processor
    org     $1001               ;beginning of our memory
    dc.w    nextstmt
    dc.w    10
    dc.b    158, "4109"
    dc.b    0
nextstmt
    dc.w    0

loop
    lda $9004           ;load TV raster beam line
    jsr $ffd2 			;print	
    jmp loop            ;infinite loop
