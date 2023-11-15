.include "constants.inc"
.include "header.inc"


.segment "CODE"
.proc irq_handler
  RTI
.endproc


.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
	LDA #$00
	STA $2005
	STA $2005
  RTI
.endproc

.import reset_handler
.import draw_background
.import load_sprites

.export main
.proc main

 JSR load_main_palette

 JSR draw_background

 JSR load_sprites

vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever

.endproc

.proc load_main_palette
  ; seek to the start of palette memory ($3F00-$3F1F)
  ldx #$3F
  stx PPUADDR
  ldx #$00
  stx PPUADDR
copypalloop:
  lda palettes,x
  sta PPUDATA
  inx
  cpx #32
  bcc copypalloop
  rts

.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
  .byte $3e, $00, $10, $27
  .byte $3e, $10, $30, $27
  .byte $3e, $11, $10, $27
  .byte $3e, $11, $10, $27

  .byte $3e, $30, $36, $3e
  .byte $3e, $30, $36, $3e
  .byte $3e, $30, $36, $3e
  .byte $3e, $30, $36, $3e

.segment "CHR"
.incbin "007.chr"