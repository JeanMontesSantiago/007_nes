.include "constants.inc"

.export draw_background
.proc draw_background

  LDX PPUSTATUS
  LDX #$20
  STX PPUADDR
  LDX #$00
  STX PPUADDR 
load_background_1:
	LDA Background, X
	STA PPUDATA
	INX
	CPX #$00
	BNE load_background_1

load_background_2:
	LDA Background + 256, X
	STA PPUDATA
	INX
	CPX #$00
	BNE load_background_2

load_background_3:
	LDA Background + 512, X
	STA PPUDATA
	INX
	CPX #$00
	BNE load_background_3

load_background_4:
	LDA Background + 768, X
	STA PPUDATA
	INX
	CPX #$c3
	BNE load_background_4

LDA PPUSTATUS
LDA #$23
STA PPUADDR
LDA #$C0
STA PPUADDR
LDX #$00
load_attribute_table:
	LDA Attribute_Table, X
	STA PPUDATA
	INX
	CPX #32
	BNE load_attribute_table

  rts

  Background:
	.byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $0f,$1d,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$00,$1c,$00,$00,$00
	.byte $00,$00,$00,$00,$1d,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $0f,$0f,$0f,$04,$05,$06,$07,$1c,$0f,$0f,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $1d,$0f,$0f,$14,$15,$16,$17,$0f,$0f,$0f,$1d,$00,$00,$00,$00,$00
	.byte $00,$1c,$00,$00,$00,$1c,$00,$00,$00,$1c,$00,$00,$1c,$00,$00,$00
	.byte $0f,$0f,$0f,$24,$25,$26,$27,$0f,$1d,$00,$00,$00,$00,$1d,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1c,$00,$00,$00
	.byte $0f,$0f,$0f,$34,$35,$36,$37,$0f,$0f,$00,$0f,$00,$0f,$00,$0f,$00
	.byte $00,$00,$00,$0f,$00,$1c,$0f,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$01,$0f,$03,$0f,$0f,$0f,$0f,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
	.byte $00,$01,$02,$03,$0f,$0f,$0f,$0f,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f
	.byte $10,$0f,$0f,$13,$0f,$1d,$0f,$0f,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f
	.byte $10,$11,$12,$13,$0f,$0f,$0f,$0f,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f
	.byte $20,$0f,$0f,$23,$0f,$0f,$0f,$0f,$28,$29,$2a,$2b,$2c,$2d,$2e,$2f
	.byte $20,$21,$22,$23,$0f,$0f,$0f,$1d,$28,$29,$2a,$2b,$2c,$2d,$2e,$2f
	.byte $30,$0f,$32,$33,$0f,$0f,$0f,$0f,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f
	.byte $30,$31,$32,$33,$0f,$0f,$0f,$0f,$38,$39,$3a,$3b,$3c,$3d,$3e,$3f
	.byte $40,$0f,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
	.byte $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$4d,$4e,$4f
	.byte $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5a,$5b,$5c,$5d,$5e,$5f
	.byte $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5a,$5b,$5c,$5d,$5e,$5f
	.byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e,$6f
	.byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e,$6f
	.byte $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f
	.byte $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f
	.byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8d,$8e,$8f
	.byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8d,$8e,$8f
	.byte $90,$91,$92,$93,$94,$95,$96,$97,$78,$99,$9a,$9b,$9c,$9d,$9e,$9f
	.byte $90,$91,$92,$93,$94,$95,$96,$97,$78,$99,$9a,$9b,$9c,$9d,$9e,$9f
	.byte $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f
	.byte $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f
	.byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8d,$8e,$8f
	.byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8d,$8e,$8f
	.byte $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f
	.byte $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7a,$7b,$7c,$7d,$7e,$7f
	.byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8d,$8e,$8f
	.byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8a,$8b,$8c,$8d,$8e,$8f
	.byte $b0,$b1,$b2,$b3,$b0,$b1,$b2,$b3,$a4,$a5,$a6,$a7,$a6,$a6,$a6,$a6
	.byte $a6,$a8,$a9,$aa,$ab,$bc,$bd,$be,$bf,$b0,$b1,$b2,$b3,$b0,$b1,$b2
	.byte $b0,$b1,$b2,$bc,$bd,$be,$bf,$b3,$b4,$b5,$b6,$b7,$b7,$b6,$b8,$b6
	.byte $b8,$b6,$b9,$ba,$bb,$b0,$b1,$b2,$b3,$b0,$b1,$b2,$bc,$bd,$be,$bf
	.byte $f4,$f4,$f4,$f4,$f4,$f4,$f4,$f4,$c4,$c5,$c6,$c7,$c8,$c9,$f4,$cb
	.byte $f4,$cc,$cd,$ca,$cc,$cd,$f4,$f4,$f4,$f4,$f4,$f4,$f4,$f4,$f4,$f4
	.byte $d4,$d5,$d6,$d7,$d8,$d9,$da,$db,$d2,$d3,$d5,$d6,$d7,$d8,$d9,$da
	.byte $db,$dc,$dd,$db,$dc,$dd,$d4,$d5,$d6,$d7,$d5,$d6,$d7,$d8,$d9,$da
	.byte $e4,$e5,$e6,$e7,$e8,$e9,$ea,$eb,$e2,$e3,$e5,$e6,$e7,$e8,$e9,$ea
	.byte $eb,$ec,$ed,$eb,$ec,$ed,$e4,$e5,$e6,$e7,$e5,$e6,$e7,$e8,$e9,$ea
	.byte $f4,$f5,$f6,$f7,$f8,$f9,$fa,$fb,$f2,$f3,$f5,$f6,$f7,$f8,$f9,$fa
	.byte $fb,$fc,$fd,$fb,$fc,$fd,$f4,$f5,$f6,$f7,$f5,$f6,$f7,$f8,$f9,$fa
	.byte $c0,$c1,$c2,$c3,$f4,$f4,$cc,$cd,$ce,$cf,$c1,$c2,$c3,$f4,$f1,$f4
	.byte $f4,$f4,$cc,$cd,$ce,$c0,$c1,$c2,$cb,$cc,$cd,$ce,$f4,$f4,$f4,$f4
	.byte $d0,$d1,$d2,$d3,$d4,$db,$dc,$dd,$de,$df,$d1,$d2,$d3,$d4,$d5,$d6
	.byte $d7,$db,$dc,$dd,$de,$d0,$d1,$d2,$db,$dc,$dd,$de,$d6,$d7,$d8,$d9
	.byte $e0,$e1,$e2,$e3,$e4,$eb,$ec,$ed,$ee,$ef,$e1,$e2,$e3,$e4,$e5,$e6
	.byte $e7,$eb,$ec,$ed,$ee,$e0,$e1,$e2,$eb,$ec,$ed,$ee,$e6,$e7,$e8,$e9
	.byte $f0,$f1,$f2,$f3,$f4,$fb,$fc,$fd,$fe,$ff,$f1,$f2,$f3,$f4,$f5,$f6
	.byte $f7,$fb,$fc,$fd,$fe,$f0,$f1,$f2,$fb,$fc,$fd,$fe,$f6,$f7,$f8,$f9
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

Attribute_Table:
	.byte %10101010, %10101010, %10101010, %11111111, %11111111, %11111111, %11111111, %11111111
	.byte %10101010, %10101010, %10101010, %11111111, %11111111, %11111111, %11111111, %11111111
	.byte %10101010, %10101010, %10101010, %11111111, %11111111, %11111111, %11111111, %11111111
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000

.endproc