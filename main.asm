; number format
; siid dddd
; signed 8-bit fixed point number
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

SETUPSCREEN
        ; starts at $0400+16 until $0400
        LDA #00
        LDX #16
        LDY #16
SCREENLOOP
        ADC #01
        CPY 16
        BNE SECONDLINE
        BCS SECONDLINE
        STA $0400,X ; first  line
        JMP EXECUTELINE
SECONDLINE
        CPY 15
        BNE THIRDLINE
        BCS THIRDLINE
        STA $0428,X ; first  line
        JMP EXECUTELINE
THIRDLINE
EXECUTELINE
        DEX
        BEQ SCREENEND
        DEY
        JMP SCREENLOOP
        ; will create 16x16 character grid in the middle of the screen
SCREENEND
        RTS

; main loop
MAIN
        ;LDA     #04
        ;STA     temp
        ;LDA     #01
        JSR     SETUPSCREEN
        ;STA     $D020
        JMP     MAIN