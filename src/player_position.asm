.include "constants.inc"

.segment "ZEROPAGE"

.importzp player_x, player_y, player_state, player_prev_state, player_dir

.segment "CODE"
PLAYER_SPEED    = 2
LEFT_WALL       = 4
RIGHT_WALL      = 230
UP_LIMIT        = 160
DOWN_LIMIT      = 210

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

  LDA player_dir
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
  LDA player_dir
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
  LDA player_dir
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
  LDA player_dir
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
JSR update_pos

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