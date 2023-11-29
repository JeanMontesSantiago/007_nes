.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
pad1:     .res 1
pad2:     .res 1
.exportzp pad1, pad2 
.importzp player_x, player_y, player2_x, player2_y, player_state, player2_state, player_dir, player2_dir, player_is_looking, player2_is_looking


.segment "CODE"

.import reset_handler
.import draw_background
.import load_sprites
.import init_player
.import player_tick
.import player2_tick
.import read_controller1
.import read_controller2
.import player_init
.import player2_init
.import player2_is_hurted_state
.import player_is_hurted_state



.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA
	LDA #$00



  JSR read_controller1
  JSR player_tick

  JSR read_controller2
  JSR player2_tick

  JSR check_if_player_was_hit

	STA $2005
	STA $2005
  RTI
.endproc

.export main
.proc main

 JSR load_main_palettes

 JSR draw_background
; Subrutina para cargar sprites en pantalla, para entregable 2 del Proyecto
;  JSR load_sprites
  JSR player2_init

 JSR player_init




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

.proc load_main_palettes
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


.proc check_if_player_was_hit
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  
check_player1:
  LDA player_state
  AND #PLAYER_ATTACKING_STATE
  BEQ check_player2

  LDA player2_y
  SEC
  SBC #12
  CMP player_y
  BCS check_player2

  LDA player2_y
  CLC
  ADC #08
  CMP player_y
  BCC check_player2

  LDA player_is_looking
  AND #LOOKING_LEFT
  BEQ is_looking_right

is_looking_left:
  LDA player_x  
  SEC
  SBC #36
  CMP player2_x
  BCS check_player2

  LDA player_x  
  CLC
  ADC #12
  CMP player2_x
  BCC check_player2

  JSR player2_is_hurted_state
  JMP check_player2

is_looking_right:
  LDA player_x  
  SEC
  SBC #12
  CMP player2_x
  BCS check_player2

  LDA player_x  
  CLC
  ADC #24
  CMP player2_x
  BCC check_player2

  JSR player2_is_hurted_state



check_player2:
  LDA player2_state
  AND #PLAYER_ATTACKING_STATE
  BEQ done

  LDA player_y
  SEC
  SBC #12
  CMP player2_y
  BCS done

  LDA player_y
  CLC
  ADC #08
  CMP player2_y
  BCC done

  LDA player2_is_looking
  AND #LOOKING_LEFT
  BEQ is_looking_right_2

is_looking_left_2:
  LDA player_x  
  SEC
  SBC #36
  CMP player2_x
  BCS done

  LDA player_x  
  CLC
  ADC #12
  CMP player2_x
  BCC done

  JSR player_is_hurted_state
  JMP done

is_looking_right_2:
  LDA player2_x  
  SEC
  SBC #12
  CMP player_x
  BCS done

  LDA player2_x  
  CLC
  ADC #24
  CMP player_x
  BCC done

  JSR player_is_hurted_state

done:

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
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
  .byte $3e, $30, $36, $0c
  .byte $3e, $30, $30, $30
  .byte $3e, $30, $36, $3e

.segment "CHR"
.incbin "007.chr"

