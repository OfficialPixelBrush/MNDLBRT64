; number format
; siid dddd
; signed 8-bit fixed point number
; bitmap screen

*=$1000
; variables
temp
        BYTE    $00
temp2
        BYTE    $00
counter
        BYTE    $00
xPixel
        BYTE    $00
yPixel
        BYTE    $00
iterations
        BYTE    $00
pixelcounter
        BYTE    $00
cx
        BYTE    $00
cy
        BYTE    $00
zx
        BYTE    $00
zy
        BYTE    $00
iterator
        BYTE    $00
*=$2000
;
; jump to main loop
START
        JMP     MAIN
;
; division routine
; big shoutout to this page
; http://6502.org/tutorials/compare_instructions.html
DIVIDE          ; A / temp
        PHA
        LDA     #00
        STA     counter
        PLA
DIVIDELOOP
        CMP     temp    ; check if temp < A
        BMI     DIVIDEEND; if it is, end < A
        BEQ     DIVIDEEND; if it is, end
        SBC     temp    ; if it isn't subtract
        INC     counter ; increment counter
        JMP     DIVIDELOOP; return to check
DIVIDEEND                ; if division complete
        STA     temp    ; store Remainder in temp
        LDA     counter ; Store divison result in A
        RTS
;
; multiplication routine
; could be made more efficient by checking which one is smaller beforehand
MULTIPLY        ; A*temp
        STA temp2
MULTIPLYLOOP
        DEC temp        ; decrement temp
        BEQ MULTIPLYEND ; check if temp == 0
        ADC temp2
        JMP MULTIPLYLOOP 
MULTIPLYEND
        RTS
; draw pixel routine
DRAWPIXEL
        ; will draw whichever pixel is currently being pointed at
        ; by xPixel & yPixel
        ; probably something where it's CMP'd with a minimum value, then
        ; bitshift left of the relevant line, OR #01,
        ; until the character line is finished
        RTS

SCREENFILL
        LDX #15
        LDY #00
        
SCREENLOOP
        TYA
        STA $0400,x

        INY
        TYA
        STA $0428,x

        INY
        TYA
        STA $0450,x

        INY
        TYA
        STA $0478,x

        INY
        TYA
        STA $04A0,x

        INY
        TYA
        STA $04C8,x

        INY
        TYA
        STA $04F0,x

        INY
        TYA
        STA $0518,x

        INY
        TYA
        STA $0540,x

        INY
        TYA
        STA $0568,x

        INY
        TYA
        STA $0590,x

        INY
        TYA
        STA $05B8,x

        INY
        TYA
        STA $05E0,x

        INY
        TYA
        STA $0608,x

        INY
        TYA
        STA $0630,x

        INY
        TYA
        STA $0658,x

        INY
; check if all collumns have been drawn
        DEX
        BPL SCREENLOOP    
        RTS 

; main loop
MAIN
        LDA #00   ; load 0(Black)
        STA $D020 ; change Border to Black
        STA $D021 ; change bg0 to Black
        JSR SCREENFILL
        JMP     FREEZE

FREEZE
        JMP FREEZE