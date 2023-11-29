.include "constants.inc"

.segment "ZEROPAGE"
player2_x:                            .res 1
player2_y:                            .res 1
player2_dir:                          .res 1
player2_state:                        .res 1
player2_is_looking:                   .res 1
player2_remaining_lifes:              .res 1
player2_prev_dir:                     .res 1
player2_prev_state:                   .res 1
current_sprite_2:                     .res 1
counter_to_change_between_sprites_2:  .res 1 ; variable to know how fast will change between sprite, for example, between the two running sprites
current_height_while_jumping_2:       .res 1
did_player2_collide:                  .res 1
.exportzp player2_x, player2_y, player2_state, player2_dir, player2_is_looking

.importzp pad2, player_x, player_y

.segment "CODE"
.export player2_init
.proc player2_init
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDX #$00
  LDY #$4a
  LDA #%01
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

  JSR init_player2_state
  JSR tick_player2_state
  JSR init_player2_position

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.export player2_tick
.proc player2_tick
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA
  
  JSR set_flip_attribute_2
  JSR tick_player2_state
  JSR check_button_2
  JSR tick_player2_position

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc check_button_2
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player2_state
  AND #PLAYER_IS_DEAD_STATE
  BEQ check_left
  JMP done_checking
check_left:
  LDA pad2        ; Load button presses
  AND #BTN_LEFT   ; Filter out all but Left
  BEQ check_right ; If result is zero, left not pressed

  LDA #LOOKING_LEFT
  STA player2_is_looking

  LDA #PLAYER_IS_MOVING_LEFT
  STA player2_dir

  JSR check_left_collision_2

  LDA did_player2_collide
  AND #PLAYER_COLLIDES
  BNE check_right

  LDA #PLAYER_RUNNING_STATE
  STA player2_state

  JMP done_checking

check_right:
  LDA pad2
  AND #BTN_RIGHT
  BEQ check_up

  LDA #LOOKING_RIGHT
  STA player2_is_looking

  LDA #PLAYER_IS_MOVING_RIGHT
  STA player2_dir

  JSR check_right_collision_2

  LDA did_player2_collide
  AND #PLAYER_COLLIDES
  BNE check_up

  LDA #PLAYER_RUNNING_STATE
  STA player2_state

  JMP done_checking

check_up:
  LDA pad2
  AND #BTN_UP
  BEQ check_down

  LDA #PLAYER_IS_MOVING_UP
  STA player2_dir

  LDA #PLAYER_RUNNING_STATE
  STA player2_state

  JMP done_checking

check_down:
  LDA pad2
  AND #BTN_DOWN
  BEQ check_A_button
  
  LDA #PLAYER_IS_MOVING_DOWN
  STA player2_dir

  LDA #PLAYER_RUNNING_STATE
  STA player2_state

  JMP done_checking

check_A_button:
  LDA pad2
  AND #BTN_A
  BEQ check_B_button

  LDA #PLAYER_JUMPING_STATE
  STA player2_state

  JMP done_checking
  
check_B_button:
  LDA pad2
  AND #BTN_B
  BEQ not_button_pressed

  LDA #PLAYER_ATTACKING_STATE
  STA player2_state

  JMP done_checking

not_button_pressed:
  LDA #PLAYER_NOT_MOVING
  STA player2_dir

  LDA #PLAYER_STILL_STATE
  STA player2_state

done_checking:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc set_flip_attribute_2
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDX #$00
  LDY #$00
load_attributes:
  LDA player2_is_looking
  CLC
  ADC #%01
  STA $0226, Y
  INY
  INY
  INY
  INY
  INX
  CPX #$09

  BNE load_attributes

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc init_player2_position
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #184
  STA player2_y
  LDA #208
  STA player2_x

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc tick_player2_position
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  JSR check_if_player2_is_jumping
  JSR check_if_player2_in_vehicle_range

  LDA player2_state
  AND #PLAYER_ATTACKING_STATE
  BNE done


check_left:
  LDA player2_prev_dir
  AND #PLAYER_IS_MOVING_LEFT
  BEQ check_right

  LDA player2_x
  SEC
  SBC #PLAYER_SPEED

  CMP #LEFT_WALL
  BCC check_right
  STA player2_x

  JMP done

check_right:
  LDA player2_prev_dir
  AND #PLAYER_IS_MOVING_RIGHT
  BEQ check_up

  LDA player2_x
  CLC
  ADC #PLAYER_SPEED

  CMP #RIGHT_WALL
  BCS check_up
  STA player2_x

  JMP done

check_up:
  LDA player2_prev_dir
  AND #PLAYER_IS_MOVING_UP
  BEQ check_down

  LDA player2_prev_state
  AND #PLAYER_JUMPING_STATE
  BNE done

  LDA player2_y
  SEC
  SBC #PLAYER_SPEED
      
  CMP #UP_LIMIT
  BCC check_down
  STA player2_y

  JMP done

check_down:
  LDA player2_prev_dir
  AND #PLAYER_IS_MOVING_DOWN
  BEQ done
  
  LDA player2_prev_state
  AND #PLAYER_JUMPING_STATE
  BNE done

  LDA player2_y
  CLC
  ADC #PLAYER_SPEED
      
  CMP #DOWN_LIMIT
  BCS done
  STA player2_y


done:
  LDA player2_dir
  STA player2_prev_dir
  JSR update_pos_2

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc check_if_player2_is_jumping
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player2_state
  AND #PLAYER_JUMPING_STATE
  BEQ done

Going_down:
  LDA player2_dir
  AND #PLAYER_IS_MOVING_DOWN
  BEQ Going_up

  LDA player2_y
  CLC
  ADC #JUMP_SPEED
  STA player2_y

  JMP done
Going_up:
  LDA player2_y
  SEC
  SBC #JUMP_SPEED
  STA player2_y

done:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc check_if_player2_in_vehicle_range
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

;   LDA player2_prev_state
;   AND #PLAYER_JUMPING_STATE
;   BEQ done

  LDA player2_dir
  AND #PLAYER_IS_MOVING_DOWN
  BEQ done

  LDA #CAR_LEFT_LIMIT ; check if player x position in bigger than the car left part
  CMP player2_x
  BCS done

  LDA #CAR_RIGHT_LIMIT
  CMP player2_x
  BCC done

  LDA #CAR_UP_LIMIT
  CMP player2_y
  BNE done

  LDA #PLAYER_STILL_STATE
  STA player2_prev_state
  STA player2_state

  LDA #PLAYER_NOT_MOVING
  STA player2_dir
  STA player2_prev_dir
  JMP done

done:

check_left_vehicle_limit:
  LDA #CAR_LEFT_LIMIT
  CMP player2_x
  BCC check_right_vehicle_limit 

  LDA player2_state
  AND #PLAYER_JUMPING_STATE
  BNE check_right_vehicle_limit 

  LDA player2_y
  CMP #UP_LIMIT
  BCS check_right_vehicle_limit 
  
  LDA player2_y
  CLC
  ADC #JUMP_SPEED
  STA player2_y

check_right_vehicle_limit: 
  LDA #CAR_RIGHT_LIMIT
  CMP player2_x
  BCS done_checking

  LDA player2_state
  AND #PLAYER_JUMPING_STATE
  BNE done_checking

  LDA player2_y
  CMP #UP_LIMIT
  BCS done_checking

  LDA player2_y
  CLC
  ADC #JUMP_SPEED
  STA player2_y

done_checking:

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_pos_2
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

   ; first row
  LDA player2_y
  STA $0224
  LDA player2_x
  STA $0227
  LDA player2_y
  STA $0228
  LDA player2_x
  CLC
  ADC #$08
  STA $022b
  LDA player2_y
  STA $022c
  LDA player2_x
  CLC
  ADC #$10
  STA $022f

  ; second row
  LDA player2_y
  CLC
  ADC #$08
  STA $0230
  LDA player2_x
  STA $0233
  LDA player2_y
  CLC
  ADC #$08
  STA $0234
  LDA player2_x
  CLC
  ADC #$08
  STA $0237
  LDA player2_y
  CLC
  ADC #$08
  STA $0238
  LDA player2_x
  CLC
  ADC #$10
  STA $023b

  ; third row
  LDA player2_y
  CLC
  ADC #$10
  STA $023c
  LDA player2_x
  STA $023f
  LDA player2_y
  CLC
  ADC #$10
  STA $0240
  LDA player2_x
  CLC
  ADC #$08
  STA $0243
  LDA player2_y
  CLC
  ADC #$10
  STA $0244
  LDA player2_x
  CLC
  ADC #$10
  STA $0247

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc init_player2_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #PLAYER_STILL_STATE
  STA player2_state
  STA player2_prev_state

  LDA #LOOKING_LEFT
  STA player2_is_looking

  LDA #PLAYER_STILL_SPRITES
  STA current_sprite_2

  LDA #PLAYER_MAX_LIFES
  STA player2_remaining_lifes

  LDA #$00
  STA current_height_while_jumping_2

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.export tick_player2_state
.proc tick_player2_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player2_dir         ; store the direction of the player before some states like jumping change it
  STA player2_prev_dir

  JSR draw_player2_life


  LDA player2_prev_state
  AND #PLAYER_JUMPING_STATE
  BEQ finish_jumping
  LDA #PLAYER_JUMPING_STATE
  STA player2_state

finish_jumping:
  LDA player2_prev_state
  AND #PLAYER_ATTACKING_STATE
  BEQ finish_attacking
  LDA #PLAYER_ATTACKING_STATE
  STA player2_state

finish_attacking:
  LDA player2_prev_state
  AND #PLAYER_HURT_STATE
  BEQ check_still_state
  LDA #PLAYER_HURT_STATE
  STA player2_state

check_still_state:
  LDA player2_state
  AND #PLAYER_STILL_STATE
  BEQ check_running_state

  JSR player2_is_still_state
  JMP done

check_running_state:
  LDA player2_state
  AND #PLAYER_RUNNING_STATE
  BEQ check_jumping_state

  JSR player2_is_running_state
  JMP done

check_jumping_state:
  LDA player2_state
  AND #PLAYER_JUMPING_STATE
  BEQ check_attacking_state

  JSR player2_is_jumping_state
  JMP done

check_attacking_state:
  LDA player2_state
  AND #PLAYER_ATTACKING_STATE
  BEQ check_hurt_state

  JSR player2_is_attacking_state
  JMP done

check_hurt_state:
  LDA player2_state
  AND #PLAYER_HURT_STATE
  BEQ check_dead_state

  JSR player2_is_hurted_state
  JMP done

check_dead_state:
  LDA player2_state
  AND #PLAYER_IS_DEAD_STATE
  BEQ done

  JSR player2_is_dead_state
  JMP done

done:
  LDA player2_state
  STA player2_prev_state

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player2_is_still_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$00
  STA current_height_while_jumping_2

  LDA #PLAYER_STILL_SPRITES
  STA current_sprite_2
  JSR draw_player2_state

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player2_is_running_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #CHANGE_SPRITE_COUNTER              ; check to restart the state machine 
  CLC
  ADC #CHANGE_SPRITE_COUNTER
  CMP counter_to_change_between_sprites_2
  BEQ reset

  LDA counter_to_change_between_sprites_2
  CMP #CHANGE_SPRITE_COUNTER
  BCS running_sprite_2

running_sprite_1: 
  LDA #PLAYER_START_RUNNING_SPRITES
  STA current_sprite_2
  INC counter_to_change_between_sprites_2
  JMP done

running_sprite_2:
  LDA #PLAYER_RUNNING_SPRITES
  STA current_sprite_2
  INC counter_to_change_between_sprites_2
  JMP done

reset:
  LDA #$00
  STA counter_to_change_between_sprites_2

done:
  JSR draw_player2_state

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player2_is_jumping_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #MAX_HEIGHT_FOR_JUMP
  CLC
  ADC #MAX_HEIGHT_FOR_JUMP
  CMP current_height_while_jumping_2
  BEQ reset

  LDA #PLAYER_JUMPING_STATE
  STA player2_state

  LDA #PLAYER_JUMPING_SPRITES
  STA current_sprite_2
  
  LDA current_height_while_jumping_2
  CMP #MAX_HEIGHT_FOR_JUMP
  BCC Going_up

Going_down:
  LDA #PLAYER_IS_MOVING_DOWN
  STA player2_dir

  LDA current_height_while_jumping_2
  CLC
  ADC #JUMP_SPEED
  STA current_height_while_jumping_2

  JMP done
Going_up:
  LDA current_height_while_jumping_2
  CLC
  ADC #JUMP_SPEED
  STA current_height_while_jumping_2

  LDA #PLAYER_IS_MOVING_UP
  STA player2_dir

  JMP done
reset:
  LDA #$00
  STA current_height_while_jumping_2
  LDA #PLAYER_STILL_STATE
  STA player2_state

done:
  JSR draw_player2_state

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player2_is_attacking_state
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
  CMP counter_to_change_between_sprites_2
  BEQ reset

  LDA #PLAYER_ATTACKING_STATE
  STA player2_state

  LDA #PLAYER_ATTACKING_STATE
  STA current_sprite_2

  LDA #CHANGE_SPRITE_COUNTER             ; state 3 when counter is 2/3 of change sprite counter sprite
  CLC
  ADC #CHANGE_SPRITE_COUNTER
  CMP counter_to_change_between_sprites_2
  BCC attacking_sprite_3 ; check

  LDA #CHANGE_SPRITE_COUNTER
  CMP counter_to_change_between_sprites_2
  BCC attacking_sprite_2

attacking_sprite_1: 
  LDA #PLAYER_START_ATTACK_SPRITES
  STA current_sprite_2
  INC counter_to_change_between_sprites_2
  JMP done

attacking_sprite_2:
  LDA #PLAYER_ATTACKING_SPRITES
  STA current_sprite_2
  INC counter_to_change_between_sprites_2
  JMP done

attacking_sprite_3:
  LDA #PLAYER_START_ATTACK_SPRITES
  STA current_sprite_2
  INC counter_to_change_between_sprites_2
  JMP done

reset:
  LDA #PLAYER_STILL_STATE
  STA player2_state
  LDA #$00
  STA counter_to_change_between_sprites_2

done:
  JSR draw_player2_state

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.export player2_is_hurted_state
.proc player2_is_hurted_state
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
  CMP counter_to_change_between_sprites_2
  BEQ reset

  LDA #PLAYER_HURT_STATE
  STA player2_state

  LDA #PLAYER_HURTED_SPRITES
  STA current_sprite_2

  LDX #$00
  LDY #$00

  LDA counter_to_change_between_sprites_2
  LSR A
  bcc is_even

  LDA #%10
  CLC
  ADC player2_is_looking
load_sprite_white_attribute_loop:
  STA $0226, Y
  INY 
  INY
  INY
  INY

  STA $0226, Y
  INY 
  INY
  INY
  INY

  STA $0226, Y
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
  ADC player2_is_looking
load_sprite_normal_palette_loop:
  STA $0226, Y
  INY 
  INY
  INY
  INY

  STA $0226, Y
  INY 
  INY
  INY
  INY

  STA $0226, Y
  INY 
  INY
  INY
  INY
  
  INX

  CPX #$03
  BNE load_sprite_normal_palette_loop
  JMP done

reset:
  DEC player2_remaining_lifes
  LDA #PLAYER_STILL_STATE
  STA player2_state
  LDA #$00
  STA counter_to_change_between_sprites_2
  JSR check_remaining_lifes_2


done:
  LDA counter_to_change_between_sprites_2
  ASL A
  INC counter_to_change_between_sprites_2
  JSR draw_player2_state

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player2_is_dead_state
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
  CMP counter_to_change_between_sprites_2
  BEQ draw_sprite


  LDA counter_to_change_between_sprites_2
  LSR A
  bcc is_even

  LDA #PLAYER_DEAD_SPRITES
  STA current_sprite_2


  JMP done

is_even:
  LDA #PLAYER_STILL_SPRITES
  STA current_sprite_2


done:
  LDA counter_to_change_between_sprites_2
  ASL A
  INC counter_to_change_between_sprites_2


draw_sprite:
  LDA #PLAYER_IS_DEAD_STATE
  STA player2_state
  JSR draw_player2_state




  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_player2_state
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDX #$00
  LDY #$00

  LDA player2_is_looking
  AND #LOOKING_LEFT
  BEQ load_sprite_right

  LDA current_sprite_2
  CLC
  ADC #$02
load_sprite_left:
  STA $0225, Y
  INY 
  INY
  INY
  INY
  SEC 
  SBC #$01

  STA $0225, Y
  INY 
  INY
  INY
  INY
  SEC
  SBC #$01

  STA $0225, Y
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
  LDA current_sprite_2

load_sprite_right_loop:
  CLC
  STA $0225, Y
  INY 
  INY
  INY
  INY
  ADC #$01

  STA $0225, Y
  INY 
  INY
  INY
  INY
  ADC #$01

  STA $0225, Y
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

.proc check_remaining_lifes_2
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player2_remaining_lifes
  CMP #00
  BNE done


  JSR player2_is_dead_state

done:

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_player2_life
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

load_x_y_tiles:



  LDX #$00
  LDY #$48
  LDA #HEARTS_2_Y_POSITION
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
  LDY #$4b
  LDA #HEARTS_2_X_POSITION
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

  LDA player2_remaining_lifes
  CMP #$00
  BEQ check_empty_hearts

  LDX #$00
  LDY #$49
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
  CPX player2_remaining_lifes
  BNE load_remaining_hearts_tiles

check_empty_hearts:

  LDA player2_remaining_lifes
  CMP #PLAYER_MAX_LIFES
  BEQ done

  LDX player2_remaining_lifes
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

.proc check_left_collision_2
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player_y
  SEC 
  SBC #24
  CMP player2_y
  BCS do_not_collide

  LDA player_y
  CLC 
  ADC #12
  CMP player2_y
  BCC do_not_collide

  LDA player2_x  ; check left collision
  SEC
  SBC #12
  CMP player_x
  BNE do_not_collide

collide:
  LDA #PLAYER_COLLIDES
  STA did_player2_collide
  JMP done

do_not_collide:
  LDA #PLAYER_DO_NOT_COLLIDES
  STA did_player2_collide

done:

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc


.proc check_right_collision_2
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player_y
  SEC 
  SBC #24
  CMP player2_y
  BCS do_not_collide

  LDA player_y
  CLC 
  ADC #12
  CMP player2_y
  BCC do_not_collide

  LDA player2_x  ; check left collision
  CLC
  ADC #12
  CMP player_x
  BNE do_not_collide

collide:
  LDA #PLAYER_COLLIDES
  STA did_player2_collide
  JMP done

do_not_collide:
  LDA #PLAYER_DO_NOT_COLLIDES
  STA did_player2_collide

done:

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc