.include "constants.inc"

.segment "ZEROPAGE"
.importzp pad1
.importzp pad2

.segment "CODE"
.export read_controller1, read_controller2
.proc read_controller1
  PHA
  TXA
  PHA
  PHP

  ; write a 1, then a 0, to CONTROLLER1
  ; to latch button states
  LDA #$01
  STA CONTROLLER1
  LDA #$00
  STA CONTROLLER1

  LDA #%00000001
  STA pad1

get_buttons:
  LDA CONTROLLER1 ; Read next button's state
  LSR A           ; Shift button state right, into carry flag
  ROL pad1        ; Rotate button state from carry flag
                  ; onto right side of pad1
                  ; and leftmost 0 of pad1 into carry flag
  BCC get_buttons ; Continue until original "1" is in carry flag

  PLP
  PLA
  TAX
  PLA
  RTS
.endproc

.export read_controller2
.proc read_controller2
  PHA
  TXA
  PHA
  PHP

  ; write a 1, then a 0, to CONTROLLER2
  ; to latch button states
  LDA #$01
  STA CONTROLLER2
  LDA #$00
  STA CONTROLLER2

  LDA #%00000001
  STA pad2

get_buttons:
  LDA CONTROLLER2 ; Read next button's state
  LSR A           ; Shift button state right, into carry flag
  ROL pad2        ; Rotate button state from carry flag
                  ; onto right side of pad1
                  ; and leftmost 0 of pad1 into carry flag
  BCC get_buttons ; Continue until original "1" is in carry flag

  PLP
  PLA
  TAX
  PLA
  RTS
.endproc