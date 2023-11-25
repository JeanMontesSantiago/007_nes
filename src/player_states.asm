.include "constants.inc"

.segment "ZEROPAGE"
player_prev_state:                  .res 1
current_sprite:                     .res 1
counter_to_change_between_sprites:  .res 1 ; variable to know how fast will change between sprite, for example, between the two running sprites
current_height_while_jumping:       .res 1
.importzp player_is_looking, player_x, player_y, player_state

.segment "CODE"
; Constants to help the inner working of the states
CHANGE_SPRITE_COUNTER    = 05
MAX_HEIGHT_FOR_JUMP      = 32

; Initialice all variables need it to use for the diference states
.export init_player_state
.proc init_player_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #PLAYER_STILL_STATE
  STA player_state
  STA player_prev_state

  LDA #LOOKING_LEFT
  STA player_is_looking

  LDA #PLAYER_STILL_SPRITES
  STA current_sprite

  LDA #$00
  STA current_height_while_jumping

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.export tick_player_state
.proc tick_player_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player_prev_state
  AND #PLAYER_JUMPING_STATE
  BEQ check_still_state
  LDA #PLAYER_JUMPING_STATE
  STA player_state

  LDA player_prev_state
  AND #PLAYER_IS_DEAD_STATE
  BEQ check_still_state
  LDA #PLAYER_IS_DEAD_STATE
  STA player_state

check_still_state:
  LDA player_state
  AND #PLAYER_STILL_STATE
  BEQ check_running_state

  JSR player_is_still_state
  JMP done

check_running_state:
  LDA player_state
  AND #PLAYER_RUNNING_STATE
  BEQ check_jumping_state

  JSR player_is_running_state
  JMP done

check_jumping_state:
  LDA player_state
  AND #PLAYER_JUMPING_STATE
  BEQ check_dead_state

  JSR player_is_jumping_state
  JMP done

check_dead_state:
  JSR player_is_dead_state
  JMP done

done:
  LDA player_state
  STA player_prev_state

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player_is_still_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #PLAYER_STILL_SPRITES
  STA current_sprite
  JSR draw_player_state

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player_is_running_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #CHANGE_SPRITE_COUNTER              ; check to restart the state machine 
  CLC
  ADC #CHANGE_SPRITE_COUNTER
  CMP counter_to_change_between_sprites
  BEQ reset

  LDA counter_to_change_between_sprites
  CMP #CHANGE_SPRITE_COUNTER
  BCS running_sprite_2

running_sprite_1: 
  LDA #PLAYER_START_RUNNING_SPRITES
  STA current_sprite
  INC counter_to_change_between_sprites
  JMP done

running_sprite_2:
  LDA #PLAYER_RUNNING_SPRITES
  STA current_sprite
  INC counter_to_change_between_sprites
  JMP done

reset:
  LDA #$00
  STA counter_to_change_between_sprites

done:
  JSR draw_player_state

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player_is_jumping_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #MAX_HEIGHT_FOR_JUMP
  CLC
  ADC #MAX_HEIGHT_FOR_JUMP
  CMP current_height_while_jumping
  BEQ reset

  LDA #PLAYER_JUMPING_STATE
  STA player_state
  LDA #PLAYER_JUMPING_SPRITES
  STA current_sprite
  LDA current_height_while_jumping
  CMP #MAX_HEIGHT_FOR_JUMP
  BCC Going_down

Going_up:
  INC player_y
  INC current_height_while_jumping
  JMP done

Going_down:
  DEC player_y
  INC current_height_while_jumping
  JMP done

reset:
  LDA #$00
  STA current_height_while_jumping
  LDA #PLAYER_STILL_STATE
  STA player_state

done:
  JSR draw_player_state

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player_is_hurted_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player_is_dead_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #PLAYER_IS_DEAD_STATE
  STA player_state
  LDA #PLAYER_DEAD_SPRITES
  STA current_sprite
  JSR draw_player_state

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_player_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDX #$00
  LDY #$00

  LDA player_is_looking
  AND #LOOKING_LEFT
  BEQ load_sprite_right

  LDA current_sprite
  CLC
  ADC #$02
load_sprite_left:
  STA $0201, Y
  INY 
  INY
  INY
  INY
  SEC 
  SBC #$01

  STA $0201, Y
  INY 
  INY
  INY
  INY
  SEC
  SBC #$01

  STA $0201, Y
  INY 
  INY
  INY
  INY
  INX
  CLC
  ADC #18

  CPX #$03
  BNE load_sprite_left

  JMP done


load_sprite_right:
  LDA current_sprite

load_sprite_right_loop:
  CLC
  STA $0201, Y
  INY 
  INY
  INY
  INY
  ADC #$01

  STA $0201, Y
  INY 
  INY
  INY
  INY
  ADC #$01

  STA $0201, Y
  INY 
  INY
  INY
  INY
  INX
  ADC #14

  CPX #$03
  BNE load_sprite_right_loop

done:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc