*=$1000
MAIN
        LDA #00
LOOP
        INX
        STA $0400,x
        JMP LOOP