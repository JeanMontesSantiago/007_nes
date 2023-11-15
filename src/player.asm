.include "constants.inc"

.segment "ZEROPAGE"
frames:                 .res 1
current_running_sprite: .res 1
player_x:               .res 1
player_y:               .res 1
player_dir:             .res 1
.exportzp frames, current_running_sprite, player_x, player_y, player_dir
.importzp pad1

.segment "CODE"
.export player_tick
.proc player_tick
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; ; Increaces X by one to denote
;   LDA frames
;   INC frames
;   CMP #$10
;   BCC not_reset_frames

;   LDA #$00
;   STA frames

;   LDA current_running_sprite
;   INC current_running_sprite
;   CMP #$01
;   BCC not_reset_frames

;   LDA #$00
;   STA current_running_sprite

not_reset_frames:

  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed
  DEC player_x  ; If the branch is not taken, move player left
check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  INC player_x
check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down
  DEC player_y
check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ done_checking
  INC player_y
done_checking:

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
  
;   LDX current_running_sprite
;   CPX #$00
;   BEQ load_sprite_running_0

;   LDX #$00
; load_sprite_running_1:
;   LDA sprite_running,X
;   STA $0200,X
;   INX
;   CPX #$24
;   BNE load_sprite_running_1

;   JMP done_drawing

;   LDX #$00
;   load_sprite_running_0:
;   LDA sprite_start_running,X
;   STA $0200,X
;   INX
;   CPX #$24
;   BNE load_sprite_running_0

LDA #$06
STA $0201
LDA #$07
STA $0205
LDA #$08
STA $0209

LDA #22
STA $020d
LDA #23
STA $0211
LDA #24
STA $0215

LDA #38
STA $0219
LDA #39
STA $021d
LDA #40
STA $0221

  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  LDA player_y
  STA $0208
  LDA player_x
  CLC
  ADC #$10
  STA $020b

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  STA $020f

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $0210
  LDA player_x
  CLC
  ADC #$08
  STA $0213

  ; bottom right tile (x + 16, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $0214
  LDA player_x
  CLC
  ADC #$10
  STA $0217

    ; bottom left tile (y + 16):
  LDA player_y
  CLC
  ADC #$10
  STA $0218
  LDA player_x
  STA $021b

  ; bottom right tile (x + 8, y + 16)
  LDA player_y
  CLC
  ADC #$10
  STA $021c
  LDA player_x
  CLC
  ADC #$08
  STA $021f

  ; bottom right tile (x + 16, y + 16)
  LDA player_y
  CLC
  ADC #$10
  STA $0220
  LDA player_x
  CLC
  ADC #$10
  STA $0223
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

