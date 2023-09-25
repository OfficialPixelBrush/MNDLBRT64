; number format
; siid dddd
; signed 8-bit fixed point number
; bitmap screen
; 10 SYS8192

*=$0801

        BYTE    $0B, $08, $0A, $00, $9E, $38, $31, $39, $32, $00, $00, $00

MEMORYSETUP = $D018
CHARACTERSET = $3000

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
;
; signed division routine
; big shoutout to this page
; http://6502.org/tutorials/compare_instructions.html
SIGNEDDIVIDE          ; A / temp
        PHA
        LDA     #00
        STA     counter
        PLA
SIGNEDDIVIDELOOP
        CMP     temp    ; check if temp < A
        BMI     SIGNEDDIVIDEEND; if it is, end < A
        BEQ     SIGNEDDIVIDEEND; if it is, end
        SBC     temp    ; if it isn't subtract
        INC     counter ; increment counter
        JMP     SIGNEDDIVIDELOOP; return to check
SIGNEDDIVIDEEND                ; if division complete
        STA     temp    ; store Remainder in temp
        LDA     counter ; Store divison result in A
        RTS

;
; unsigned division routine
; big shoutout to this page
; http://6502.org/tutorials/compare_instructions.html
UNSIGNEDDIVIDE          ; A / temp
        PHA
        LDA     #00
        STA     counter
        PLA
UNSIGNEDDIVIDELOOP
        CMP     temp    ; check if temp < A
        BCC     UNSIGNEDDIVIDEEND; if it is, end < A
        BEQ     UNSIGNEDDIVIDEEND; if it is, end
        SBC     temp    ; if it isn't subtract
        INC     counter ; increment counter
        JMP     UNSIGNEDDIVIDELOOP; return to check
UNSIGNEDDIVIDEEND                ; if division complete
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

;
; draw box of characters
SCREENFILL
        LDX #00
        LDY #00
SCREENLOOP ; Self modifying code to ADC #40 to the address?
        TYA
        STA $0400,x

        ADC #16
        STA $0428,x

        ADC #16
        STA $0450,x

        ADC #16
        STA $0478,x

        ADC #16
        STA $04A0,x

        ADC #16
        STA $04C8,x

        ADC #16
        STA $04F0,x

        ADC #16
        STA $0518,x

        ADC #16
        STA $0540,x

        ADC #16
        STA $0568,x

        ADC #16
        STA $0590,x

        ADC #16
        STA $05B8,x

        ADC #16
        STA $05E0,x

        ADC #16
        STA $0608,x

        ADC #16
        STA $0630,x

        ADC #16
        STA $0658,x

        ADC #17
        TAY
; check if all collumns have been drawn
        INX
        TXA
        CMP #16
        BNE SCREENLOOP
        RTS 

; draw pixel routine
DRAWPIXEL
        ; 
        ;  Xx Yy
        ;  || ||
        ;  vv vv
        ;
        ; $3Y Xy x <- Pixel in Character
        ;  || ||
        ;  || |+----> Line in Character
        ;  || +-----> Horizontal Tile
        ;  |+-------> Vertical Tile
        ;  +--------> Address
        ;
        ; 0011:0YYY YXXX:Xyyy ; 0xxx
        ; 
        ; e.g.
        ; $3015 = 0x01th Character of 0x00th line, 5th sub-line
        ; max Pixels of 0-127!!
        ; do the upper byte
        LDA yPixel
        LSR A
        LSR A
        LSR A
        LSR A
        LSR A
        ORA #48 ; 0x30
        STA MODIFYTHIS+2
        ; lower Byte
        LDA #0
        ROR ; shift Carry into A
        ORA xPixel
        AND #248 ; 1111 1000
        STA temp
        LDA yPixel
        AND #7   ; 0000 0111
        ORA temp
        STA MODIFYTHIS+1
        ; 
        LDA #85 ; 0101 0101
MODIFYTHIS
        ;JSR MANDELBROT
        STA CHARACTERSET
        ;STA CHARACTERSET
        ; WILL REQUIRE SELF MODIFYING CODE
        ; will draw whichever pixel is currently being pointed at
        ; by xPixel & yPixel
        ; probably something where it's CMP'd with a minimum value, then
        ; bitshift left of the relevant line, OR #01,
        ; until the character line is finished
        RTS

MANDELBROT
        LDX #00
MANDELLOOP
        INC yPixel
        JSR DRAWPIXEL
        INX
        BNE MANDELLOOP
        RTS

*=$2000
; main loop
MAIN
        LDA #00   ; load 0(Black)
        STA $D020 ; change Border to Black
        STA $D021 ; change bg0 to Black
        ; redefine character set location
        LDA MEMORYSETUP
        AND #240
        ORA #12
        STA MEMORYSETUP
        ; fill screen with characters
        JSR SCREENFILL
        ; draw that shit
        JSR MANDELBROT
        ;JSR DRAWPIXEL
        JMP     FREEZE

FREEZE
        JMP FREEZE