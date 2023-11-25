.include "constants.inc"

.segment "ZEROPAGE"
frames:                         .res 1
current_running_sprite:         .res 1
player_x:                       .res 1
player_y:                       .res 1
player_dir:                     .res 1
player_state:                   .res 1
player_is_looking:              .res 1
.exportzp frames, current_running_sprite, player_x, player_y, player_dir, player_is_looking, player_state
.importzp pad1

.segment "CODE"

.import init_player_state
.import tick_player_state

.export player_init
.proc player_init
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  JSR init_player_state
  JSR tick_player_state

  LDA #184
  STA player_y
  LDA #112
  STA player_x

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc


.export player_tick
.proc player_tick
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  JSR check_button
  JSR set_flip_attribute
  JSR update_pos
  JSR tick_player_state

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc check_button
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed

  LDA #LOOKING_LEFT
  STA player_is_looking

  LDA #4         ; check left wall
  CMP player_x
  BCS check_right

  DEC player_x  ; If the branch is not taken, move player left
  LDA #PLAYER_RUNNING_STATE
  STA player_state

  JMP done_checking

check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up

  LDA #LOOKING_RIGHT
  STA player_is_looking

  LDA #224      ; check right wall
  CMP player_x
  BCC check_up

  INC player_x
  LDA #PLAYER_RUNNING_STATE
  STA player_state

  JMP done_checking

check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down

  LDA #160        
  CMP player_y
  BCS check_down

  LDA player_state
  AND #PLAYER_JUMPING_STATE
  BNE done_checking
  
  DEC player_y
  LDA #PLAYER_RUNNING_STATE
  STA player_state

  JMP done_checking

check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ check_A_button
  
  LDA #208
  CMP player_y
  BCC check_A_button

  LDA player_state
  AND #PLAYER_JUMPING_STATE
  BNE done_checking

  INC player_y
  LDA #PLAYER_RUNNING_STATE
  STA player_state

  JMP done_checking

check_A_button:
  LDA pad1
  AND #BTN_A
  BEQ check_B_button

  LDA #PLAYER_JUMPING_STATE
  STA player_state

  JMP done_checking
  
check_B_button:
  LDA pad1
  AND #BTN_B
  BEQ not_button_pressed

  LDA #PLAYER_IS_DEAD_STATE
  STA player_state

  JMP done_checking

not_button_pressed:
  LDA #PLAYER_STILL_STATE
  STA player_state

done_checking:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc


.proc update_pos
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
   ; first row
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

  ; second row
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  STA $020f
  LDA player_y
  CLC
  ADC #$08
  STA $0210
  LDA player_x
  CLC
  ADC #$08
  STA $0213
  LDA player_y
  CLC
  ADC #$08
  STA $0214
  LDA player_x
  CLC
  ADC #$10
  STA $0217

  ; third row
  LDA player_y
  CLC
  ADC #$10
  STA $0218
  LDA player_x
  STA $021b
  LDA player_y
  CLC
  ADC #$10
  STA $021c
  LDA player_x
  CLC
  ADC #$08
  STA $021f
  LDA player_y
  CLC
  ADC #$10
  STA $0220
  LDA player_x
  CLC
  ADC #$10
  STA $0223

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_state

.endproc

.proc set_flip_attribute
  LDX #$00
  LDY #$00
load_attributes:
  LDA player_is_looking
  STA $0202, Y
  INY
  INY
  INY
  INY
  INX
  CPX #$09

  BNE load_attributes
.endproc


