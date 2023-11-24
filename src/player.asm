.include "constants.inc"

.segment "ZEROPAGE"
frames:                         .res 1
current_running_sprite:         .res 1
player_x:                       .res 1
player_y:                       .res 1
player_dir:                     .res 1
player_status:                  .res 1
player_is_looking:              .res 1
time_between_player_status:     .res 1
player_height_while_jumping:    .res 1
is_jumping_flag:                .res 1
current_sprite:                 .res 1
.exportzp frames, current_running_sprite, player_x, player_y, player_dir
.importzp pad1

.segment "CODE"

.export player_init
.proc player_init
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA #$00
  STA is_jumping_flag

  LDA #$00
  STA player_height_while_jumping

  LDA #PLAYER_IS_STILL
  STA player_status

  LDA #STILL_SPRITES
  STA current_sprite

  LDA #LOOKING_RIGHT
  STA player_is_looking

  LDA #$05
  STA time_between_player_status

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

  JSR jump ; tick if is jumping
  JSR check_button
  JSR check_physics
  JSR draw_animation



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


  JSR is_running
  JMP done_checking

check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  LDA #LOOKING_RIGHT
  STA player_is_looking

  LDA #224
  CMP player_x
  BCC check_up
  INC player_x

  JSR is_running
  JMP done_checking


check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down

  LDA #160        
  CMP player_y
  BCS check_down

  LDA is_jumping_flag
  AND #JUMP_GOING_DOWN
  BNE check_down

  LDA is_jumping_flag
  AND #JUMP_GOING_UP
  BNE check_down
  
  LDA #136
  CMP player_y
  BEQ check_A_button

  DEC player_y

  JSR is_running
  JMP done_checking

check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ check_A_button
  LDA is_jumping_flag
  AND #JUMP_GOING_DOWN
  BNE check_A_button
  LDA is_jumping_flag
  AND #JUMP_GOING_UP
  BNE check_A_button
  LDA #136
  CMP player_y
  BEQ check_A_button


  LDA #208
  CMP player_y
  BCC done_checking
  INC player_y

  JSR is_running
  JMP done_checking

check_A_button:
  LDA pad1
  AND #BTN_A
  BEQ check_B_button


  LDA is_jumping_flag
  AND #%00000000
  BNE already_jumping
  LDA #JUMP_GOING_UP
  STA is_jumping_flag

already_jumping:
  JSR jump

  JMP done_checking
  
check_B_button:
  LDA pad1
  AND #BTN_B
  BEQ not_running

  LDA #PLAYER_IS_DEAD
  STA player_status

  JMP done_checking

not_running:
  LDA #PLAYER_IS_STILL
  STA player_status

done_checking:


  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_animation
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  JSR update_pos
  JSR set_flip_attribute

  LDA is_jumping_flag  ; check if is jumping, if it is then it will only load the jump sprite
  AND #JUMP_GOING_DOWN
  BNE load_is_jumping
  LDA is_jumping_flag
  AND #JUMP_GOING_UP
  BNE load_is_jumping


  LDA player_status       ; Load button presses
  AND #PLAYER_IS_STILL   ; Filter out all but Left
  BEQ check_is_starting_to_run ; If result is zero, left not pressed

load_still_sprite:
  LDA player_status
  AND #PLAYER_IS_STILL
  BEQ check_is_starting_to_run
  LDA #STILL_SPRITES
  JMP done_drawing

load_is_jumping:
  LDA #JUMPING_SPRITES
  JMP done_drawing
  
check_is_starting_to_run:
  LDA player_status       ; Load button presses
  AND #PLAYER_START_RUNNING   ; Filter out all but Left
  BEQ check_is_running ; If result is zero, left not pressed
  LDA #START_RUNNING_SPRITES
  JMP done_drawing

check_is_running:
  LDA player_status
  AND #PLAYER_RUNNING
  BEQ check_is_starting_to_attack
  LDA #RUNNING_SPRITES
  JMP done_drawing

check_is_starting_to_attack:
  LDA player_status
  AND #PLAYER_START_ATTACKING
  BEQ check_is_attacking
  LDA #START_ATTACK_SPRITES
  JMP done_drawing

check_is_attacking:
  LDA player_status
  AND #PLAYER_ATTACKING
  BEQ check_is_getting_hurt
  LDA #ATTACKING_SPRITES
  JMP done_drawing

check_is_getting_hurt:
  LDA player_status
  AND #PLAYER_HURT
  BEQ check_is_dead
  LDA #HURTED_SPRITES
  JMP done_drawing

check_is_dead:
  LDA player_status
  AND #PLAYER_IS_DEAD
  BEQ done_drawing
  LDA #DEAD_SPRITES

done_drawing:
  LDX #$00
  LDY #$00

  PHA
  LDA player_is_looking
  AND #LOOKING_LEFT
  PLA
  BEQ load_sprite_right

  CLC
  ADC #$02
load_sprite_flipped:
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
  BNE load_sprite_flipped
  JMP done

load_sprite_right:
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
  BNE load_sprite_right


done:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc is_running
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  DEC time_between_player_status
  BNE done_checking

  LDA #$05
  STA time_between_player_status

  LDA #PLAYER_IS_STILL
  AND player_status
  BEQ start_to_running
  ASL player_status
  ASL player_status
  JMP done_checking

start_to_running:
  LDA #PLAYER_START_RUNNING
  AND player_status
  BEQ change_to_running
  ASL player_status
  JMP done_checking

change_to_running:
  LSR player_status

done_checking:


  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc jump
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA


decrease_height:
  LDA is_jumping_flag
  AND #JUMP_GOING_DOWN
  BEQ increase_height

  LDA #00
  CMP player_height_while_jumping
  BCS reset
  DEC player_height_while_jumping

  INC player_y

JMP done_jumping


reset:
  LDA #$00
  STA player_height_while_jumping
  STA is_jumping_flag

increase_height:
  LDA is_jumping_flag
  AND #JUMP_GOING_UP
  BEQ done_jumping

  LDA #MAX_JUMP_HEIGHT
  CMP player_height_while_jumping
  BCC going_down
  
  INC player_height_while_jumping
  DEC player_y
  JMP done_jumping

going_down:  
  LDA #JUMP_GOING_DOWN
  STA is_jumping_flag

done_jumping:

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

.proc check_physics
  LDA #56 ; verifica si ya no esta encima del carro y deja caer al sprite
  CMP player_x
  BCS player_is_outside_the_car_range

  LDA #144
  CMP player_x
  BCC player_is_outside_the_car_range

  LDA #136
  CMP player_y
  BNE done_checking

  LDA #JUMP_GOING_DOWN
  AND is_jumping_flag
  BEQ done_checking

  LDA #$00
  STA player_height_while_jumping

  JMP done_checking

player_is_outside_the_car_range:

  LDA is_jumping_flag
  AND #JUMP_GOING_DOWN
  BNE done_checking
  LDA is_jumping_flag
  AND #JUMP_GOING_UP
  BNE done_checking

  LDA #160
  CMP player_y
  BCC done_checking
  INC player_y
  
done_checking:

.endproc
