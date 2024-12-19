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
px
        BYTE    $00
py
        BYTE    $00
iterations
        BYTE    $00
x
        BYTE    $00
y
        BYTE    $00

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

; siii dddd

MANDELBROT
        ; py = -2.0
        LDA #-64
        STA py
        
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
        ; draw that shit
        JSR MANDELBROT
        ;JSR DRAWPIXEL
        JMP     FREEZE

FREEZE
        JMP FREEZE