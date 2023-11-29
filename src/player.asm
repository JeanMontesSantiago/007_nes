.include "constants.inc"

.segment "ZEROPAGE"
player_x:                       .res 1
player_y:                       .res 1
player_dir:                     .res 1
player_state:                   .res 1
player_is_looking:              .res 1
player_remaining_lifes:         .res 1
did_player_collide:             .res 1
.exportzp player_x, player_y, player_dir, player_is_looking, player_state, player_dir, player_is_looking, player_remaining_lifes

.importzp pad1, player2_x, player2_y

.segment "CODE"

.import init_player_state
.import tick_player_state
.import init_player_position
.import tick_player_position

.export player_init
.proc player_init
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDX #$00
  LDY #$b2
  LDA #$00
load_attributes:
  STA $0200, Y
  INY
  INY
  INY
  INY

  STA $0200, Y
  INY
  INY
  INY
  INY

  STA $0200, Y
  INY
  INY
  INY
  INY

  STA $0200, Y
  INY
  INY
  INY
  INY

  INX
  CPX #PLAYER_MAX_LIFES
  BNE load_attributes

  LDA #PLAYER_DO_NOT_COLLIDES
  STA did_player_collide

  JSR init_player_state
  JSR tick_player_state
  JSR init_player_position

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
  JSR tick_player_state
  JSR tick_player_position

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

  LDA player_state
  AND #PLAYER_IS_DEAD_STATE
  BEQ check_left
  JMP done_checking


check_left:
  LDA pad1        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed

  LDA #LOOKING_LEFT
  STA player_is_looking

  LDA #PLAYER_IS_MOVING_LEFT
  STA player_dir

  JSR check_left_collision

  LDA did_player_collide
  AND #PLAYER_COLLIDES
  BNE check_right

  LDA #PLAYER_RUNNING_STATE
  STA player_state

  JMP done_checking

check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up

  LDA #LOOKING_RIGHT
  STA player_is_looking

  LDA #PLAYER_IS_MOVING_RIGHT
  STA player_dir

  JSR check_right_collision

  LDA did_player_collide
  AND #PLAYER_COLLIDES
  BNE check_up

  LDA #PLAYER_RUNNING_STATE
  STA player_state

  JMP done_checking

check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down

  LDA #PLAYER_IS_MOVING_UP
  STA player_dir

  LDA #PLAYER_RUNNING_STATE
  STA player_state

  JMP done_checking

check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ check_A_button
  
  LDA #PLAYER_IS_MOVING_DOWN
  STA player_dir

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

  LDA #PLAYER_ATTACKING_STATE
  STA player_state

  JMP done_checking

not_button_pressed:
  LDA #PLAYER_NOT_MOVING
  STA player_dir

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

.proc check_left_collision
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player2_y
  SEC 
  SBC #24
  CMP player_y
  BCS do_not_collide

  LDA player2_y
  CLC 
  ADC #12
  CMP player_y
  BCC do_not_collide

  LDA player_x  ; check left collision
  SEC
  SBC #12
  CMP player2_x
  BNE do_not_collide

collide:
  LDA #PLAYER_COLLIDES
  STA did_player_collide
  JMP done

do_not_collide:
  LDA #PLAYER_DO_NOT_COLLIDES
  STA did_player_collide

done:

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc


.proc check_right_collision
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player2_y
  SEC 
  SBC #24
  CMP player_y
  BCS do_not_collide

  LDA player2_y
  CLC 
  ADC #12
  CMP player_y
  BCC do_not_collide

  LDA player_x  ; check left collision
  CLC
  ADC #12
  CMP player2_x
  BNE do_not_collide

collide:
  LDA #PLAYER_COLLIDES
  STA did_player_collide
  JMP done

do_not_collide:
  LDA #PLAYER_DO_NOT_COLLIDES
  STA did_player_collide

done:

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc


