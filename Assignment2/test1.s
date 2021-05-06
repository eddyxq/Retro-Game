; test program that trys to get a random seed and number
; failed test
; On page 171 of the reference guide it says location 008B to 008F
; was a RND seed value. I thought I would try to load them in and
; see what values they give. Not sure why they always give the same value.
; I am assuming this is not the way to generate a random.

    processor 6502              ;specify 6502 processor
    org     $1001               ;beginning of our memory
    dc.w    nextstmt
    dc.w    10
    dc.b    158, "4109"
    dc.b    0
nextstmt
    dc.w    0

; experiementing to see in the debugger what happens if I load a RND seed value
loop
    lda $008B           ;load seed
    ldx $008C           ;load seed
    ldy $008D           ;load seed
    jmp loop            ;infinite loop
