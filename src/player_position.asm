.include "constants.inc"

.segment "ZEROPAGE"
player_prev_dir:    .res 1
.importzp player_x, player_y, player_state, player_prev_state, player_dir
.exportzp player_prev_dir

.segment "CODE"
PLAYER_SPEED        = 2

LEFT_WALL           = 4
RIGHT_WALL          = 230
UP_LIMIT            = 160
DOWN_LIMIT          = 210

CAR_LEFT_LIMIT      = 56
CAR_RIGHT_LIMIT     = 144
CAR_UP_LIMIT        = 136
CAR_DOWN_LIMIT      = 168

.export init_player_position
.proc init_player_position
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

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

.export tick_player_position
.proc tick_player_position
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  JSR check_if_player_is_jumping
  JSR check_if_player_in_vehicle_range


check_left:
  LDA player_prev_dir
  AND #PLAYER_IS_MOVING_LEFT
  BEQ check_right

  LDA player_x
  SEC
  SBC #PLAYER_SPEED

  CMP #LEFT_WALL
  BCC check_right
  STA player_x

  JMP done

check_right:
  LDA player_prev_dir
  AND #PLAYER_IS_MOVING_RIGHT
  BEQ check_up

  LDA player_x
  CLC
  ADC #PLAYER_SPEED

  CMP #RIGHT_WALL
  BCS check_up
  STA player_x

  JMP done

check_up:
  LDA player_prev_dir
  AND #PLAYER_IS_MOVING_UP
  BEQ check_down

  LDA player_prev_state
  AND #PLAYER_JUMPING_STATE
  BNE done

  LDA player_y
  SEC
  SBC #PLAYER_SPEED
      
  CMP #UP_LIMIT
  BCC check_down
  STA player_y

  JMP done

check_down:
  LDA player_prev_dir
  AND #PLAYER_IS_MOVING_DOWN
  BEQ done
  
  LDA player_prev_state
  AND #PLAYER_JUMPING_STATE
  BNE done

  LDA player_y
  CLC
  ADC #PLAYER_SPEED
      
  CMP #DOWN_LIMIT
  BCS done
  STA player_y


done:
  LDA player_dir
  STA player_prev_dir
  JSR update_pos

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc check_if_player_is_jumping
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA player_state
  AND #PLAYER_JUMPING_STATE
  BEQ done

Going_down:
  LDA player_dir
  AND #PLAYER_IS_MOVING_DOWN
  BEQ Going_up

  LDA player_y
  CLC
  ADC #JUMP_SPEED
  STA player_y

  JMP done
Going_up:
  LDA player_y
  SEC
  SBC #JUMP_SPEED
  STA player_y

done:
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc check_if_player_in_vehicle_range
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

;   LDA player_prev_state
;   AND #PLAYER_JUMPING_STATE
;   BEQ done

  LDA player_dir
  AND #PLAYER_IS_MOVING_DOWN
  BEQ done

  LDA #CAR_LEFT_LIMIT ; check if player x position in bigger than the car left part
  CMP player_x
  BCS done

  LDA #CAR_RIGHT_LIMIT
  CMP player_x
  BCC done

  LDA #CAR_UP_LIMIT
  CMP player_y
  BNE done

  LDA #PLAYER_STILL_STATE
  STA player_prev_state
  STA player_state

  LDA #PLAYER_NOT_MOVING
  STA player_dir
  STA player_prev_dir
  JMP done

done:

check_left_vehicle_limit:
  LDA #CAR_LEFT_LIMIT
  CMP player_x
  BCC check_right_vehicle_limit 

  LDA player_state
  AND #PLAYER_JUMPING_STATE
  BNE check_right_vehicle_limit 

  LDA player_y
  CMP #UP_LIMIT
  BCS check_right_vehicle_limit 
  
  LDA player_y
  CLC
  ADC #JUMP_SPEED
  STA player_y

check_right_vehicle_limit: 
  LDA #CAR_RIGHT_LIMIT
  CMP player_x
  BCS done_checking

  LDA player_state
  AND #PLAYER_JUMPING_STATE
  BNE done_checking

  LDA player_y
  CMP #UP_LIMIT
  BCS done_checking

  LDA player_y
  CLC
  ADC #JUMP_SPEED
  STA player_y

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