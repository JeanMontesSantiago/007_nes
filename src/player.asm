.include "constants.inc"

.segment "ZEROPAGE"
frames:                 .res 1
current_running_sprite: .res 1
.exportzp frames, current_running_sprite

.segment "CODE"
.export player_tick
.proc player_tick
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Increaces X by one to denote
  LDA frames
  INC frames
  CMP #$10
  BCC not_reset_frames

  LDA #$00
  STA frames

  LDA current_running_sprite
  INC current_running_sprite
  CMP #$01
  BCC not_reset_frames

  LDA #$00
  STA current_running_sprite

not_reset_frames:
  JSR draw_running_animation

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_running_animation
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  
  LDX current_running_sprite
  CPX #$00
  BEQ load_sprite_running_0

  LDX #$00
load_sprite_running_1:
  LDA sprite_running,X
  STA $0200,X
  INX
  CPX #$24
  BNE load_sprite_running_1

  JMP done_drawing

  LDX #$00
  load_sprite_running_0:
  LDA sprite_start_running,X
  STA $0200,X
  INX
  CPX #$24
  BNE load_sprite_running_0

done_drawing:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

sprite_start_running:
  .byte 184, 03, 00, 112
  .byte 184, 04, 00, 120
  .byte 184, 05, 00, 128
  .byte 192, 19, 00, 112
  .byte 192, 20, 00, 120
  .byte 192, 21, 00, 128
  .byte 200, 35, 00, 112
  .byte 200, 36, 00, 120
  .byte 200, 37, 00, 128

sprite_running:
  .byte 184, 06, 00, 112
  .byte 184, 07, 00, 120
  .byte 184, 08, 00, 128
  .byte 192, 22, 00, 112
  .byte 192, 23, 00, 120
  .byte 192, 24, 00, 128
  .byte 200, 38, 00, 112
  .byte 200, 39, 00, 120
  .byte 200, 40, 00, 128

