.include "constants.inc"

.segment "ZEROPAGE"
player_prev_state:                  .res 1
current_sprite:                     .res 1
counter_to_change_between_sprites:  .res 1 ; variable to know how fast will change between sprite, for example, between the two running sprites
current_height_while_jumping:       .res 1
.importzp player_is_looking, player_x, player_y, player_state, player_dir, player_prev_dir, player_is_looking, player_remaining_lifes
.exportzp player_prev_state

.segment "CODE"



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

  LDA #PLAYER_MAX_LIFES
  STA player_remaining_lifes

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

  LDA player_dir         ; store the direction of the player before some states like jumping change it
  STA player_prev_dir

  JSR draw_player_life


  LDA player_prev_state
  AND #PLAYER_JUMPING_STATE
  BEQ finish_jumping
  LDA #PLAYER_JUMPING_STATE
  STA player_state

finish_jumping:
  LDA player_prev_state
  AND #PLAYER_ATTACKING_STATE
  BEQ finish_attacking
  LDA #PLAYER_ATTACKING_STATE
  STA player_state

finish_attacking:
  LDA player_prev_state
  AND #PLAYER_HURT_STATE
  BEQ check_still_state
  LDA #PLAYER_HURT_STATE
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
  BEQ check_attacking_state

  JSR player_is_jumping_state
  JMP done

check_attacking_state:
  LDA player_state
  AND #PLAYER_ATTACKING_STATE
  BEQ check_hurt_state

  JSR player_is_attacking_state
  JMP done

check_hurt_state:
  LDA player_state
  AND #PLAYER_HURT_STATE
  BEQ check_dead_state

  JSR player_is_hurted_state
  JMP done

check_dead_state:
  LDA player_state
  AND #PLAYER_IS_DEAD_STATE
  BEQ done

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

  LDA #$00
  STA current_height_while_jumping

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
  BCC Going_up

Going_down:
  LDA #PLAYER_IS_MOVING_DOWN
  STA player_dir

  LDA current_height_while_jumping
  CLC
  ADC #JUMP_SPEED
  STA current_height_while_jumping

  JMP done
Going_up:
  LDA current_height_while_jumping
  CLC
  ADC #JUMP_SPEED
  STA current_height_while_jumping

  LDA #PLAYER_IS_MOVING_UP
  STA player_dir

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

.proc player_is_attacking_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #CHANGE_SPRITE_COUNTER              ; check to restart the state machine when counter is three times he change_sprite_counter constant
  CLC
  ADC #CHANGE_SPRITE_COUNTER
  CLC
  ADC #CHANGE_SPRITE_COUNTER
  CMP counter_to_change_between_sprites
  BEQ reset

  LDA #PLAYER_ATTACKING_STATE
  STA player_state

  LDA #PLAYER_ATTACKING_STATE
  STA current_sprite

  LDA #CHANGE_SPRITE_COUNTER             ; state 3 when counter is 2/3 of change sprite counter sprite
  CLC
  ADC #CHANGE_SPRITE_COUNTER
  CMP counter_to_change_between_sprites
  BCC attacking_sprite_3 ; check

  LDA #CHANGE_SPRITE_COUNTER
  CMP counter_to_change_between_sprites
  BCC attacking_sprite_2

attacking_sprite_1: 
  LDA #PLAYER_START_ATTACK_SPRITES
  STA current_sprite
  INC counter_to_change_between_sprites
  JMP done

attacking_sprite_2:
  LDA #PLAYER_ATTACKING_SPRITES
  STA current_sprite
  INC counter_to_change_between_sprites
  JMP done

attacking_sprite_3:
  LDA #PLAYER_START_ATTACK_SPRITES
  STA current_sprite
  INC counter_to_change_between_sprites
  JMP done

reset:
  LDA #PLAYER_STILL_STATE
  STA player_state
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

.export player_is_hurted_state
.proc player_is_hurted_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #CHANGE_SPRITE_COUNTER              ; check to restart the state machine when counter is three times he change_sprite_counter constant
  CLC
  ADC #CHANGE_SPRITE_COUNTER
  CLC
  ADC #CHANGE_SPRITE_COUNTER
  CLC
  ADC #CHANGE_SPRITE_COUNTER
  CMP counter_to_change_between_sprites
  BEQ reset

  LDA #PLAYER_HURT_STATE
  STA player_state

  LDA #PLAYER_HURTED_SPRITES
  STA current_sprite

  LDX #$00
  LDY #$00

  LDA counter_to_change_between_sprites
  LSR A
  bcc is_even

  LDA #%10
  CLC
  ADC player_is_looking
load_sprite_white_attribute_loop:
  STA $0202, Y
  INY 
  INY
  INY
  INY

  STA $0202, Y
  INY 
  INY
  INY
  INY

  STA $0202, Y
  INY 
  INY
  INY
  INY

  INX

  CPX #$03
  BNE load_sprite_white_attribute_loop
  JMP done

is_even:
  LDA #%00
  CLC
  ADC player_is_looking
load_sprite_normal_palette_loop:
  STA $0202, Y
  INY 
  INY
  INY
  INY

  STA $0202, Y
  INY 
  INY
  INY
  INY

  STA $0202, Y
  INY 
  INY
  INY
  INY
  
  INX

  CPX #$03
  BNE load_sprite_normal_palette_loop
  JMP done

reset:
  DEC player_remaining_lifes
  LDA #PLAYER_STILL_STATE
  STA player_state
  LDA #$00
  STA counter_to_change_between_sprites
  JSR check_remaining_lifes


done:
  LDA counter_to_change_between_sprites
  ASL A
  INC counter_to_change_between_sprites
  JSR draw_player_state

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

  LDA #CHANGE_SPRITE_COUNTER              ; check to restart the state machine when counter is three times he change_sprite_counter constant
  CLC
  ADC #CHANGE_SPRITE_COUNTER
  CLC
  ADC #CHANGE_SPRITE_COUNTER
  CLC
  ADC #CHANGE_SPRITE_COUNTER
  CMP counter_to_change_between_sprites
  BEQ draw_sprite


  LDA counter_to_change_between_sprites
  LSR A
  bcc is_even

  LDA #PLAYER_DEAD_SPRITES
  STA current_sprite


  JMP done

is_even:
  LDA #PLAYER_STILL_SPRITES
  STA current_sprite


done:
  LDA counter_to_change_between_sprites
  ASL A
  INC counter_to_change_between_sprites


draw_sprite:
  LDA #PLAYER_IS_DEAD_STATE
  STA player_state
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

.proc check_remaining_lifes
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player_remaining_lifes
  CMP #00
  BNE done


  JSR player_is_dead_state

done:

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_player_life
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

load_x_y_tiles:

  LDX #$00
  LDY #$b0
  LDA #HEARTS_Y_POSITION
load_hearts_y_position:
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

  CLC
  ADC #$08
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

  CLC
  ADC #$0a

  INX

  CPX #PLAYER_MAX_LIFES
  BNE load_hearts_y_position


  LDX #$00
  LDY #$b3
  LDA #HEARTS_X_POSITION
load_hearts_x_position:
  STA $0200, Y
  INY
  INY
  INY
  INY

  CLC
  ADC #$08
  STA $0200, Y
  INY
  INY
  INY
  INY

  SEC
  SBC #$08
  STA $0200, Y
  INY
  INY
  INY
  INY

  CLC
  ADC #$08
  STA $0200, Y
  INY
  INY
  INY
  INY

  SEC
  SBC #$08

  INX
  CPX #PLAYER_MAX_LIFES
  BNE load_hearts_x_position



  LDX #$00
  LDY #$b1
  LDA #FULL_HEART_SPRITES
load_remaining_hearts_tiles:
  STA $0200, Y
  INY
  INY
  INY
  INY

  CLC
  ADC #$01
  STA $0200, Y
  INY
  INY
  INY
  INY

  CLC
  ADC #15
  STA $0200, Y
  INY
  INY
  INY
  INY

  CLC
  ADC #$01
  STA $0200, Y
  INY
  INY
  INY
  INY

  INX
  LDA #FULL_HEART_SPRITES
  CPX player_remaining_lifes
  BNE load_remaining_hearts_tiles

check_empty_hearts:

  LDA player_remaining_lifes
  CMP #PLAYER_MAX_LIFES
  BEQ done

  LDX player_remaining_lifes
  LDA #EMPTY_HEART_SPRITES
load_empty_hearts_tiles:
  STA $0200, Y
  INY
  INY
  INY
  INY

  CLC
  ADC #$01
  STA $0200, Y
  INY
  INY
  INY
  INY

  CLC
  ADC #15
  STA $0200, Y
  INY
  INY
  INY
  INY

  CLC
  ADC #$01
  STA $0200, Y
  INY
  INY
  INY
  INY

  INX
  LDA #EMPTY_HEART_SPRITES
  CPX #PLAYER_MAX_LIFES
  BNE load_empty_hearts_tiles


done:

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc