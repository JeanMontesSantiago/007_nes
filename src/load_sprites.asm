.include "constants.inc"


.export load_sprites
.proc load_sprites
  LDX #$00
  load_sprite_1:
  LDA sprite_standing,X
  STA $0200,X
  INX
  CPX #$24
  BNE load_sprite_1

  LDX #$00
  load_sprite_2:
  LDA sprite_standing_flip,X
  STA $0224,X
  INX
  CPX #$24
  BNE load_sprite_2

  LDX #$00
  load_sprite_3:
  LDA sprite_running,X
  STA $0248,X
  INX
  CPX #$24
  BNE load_sprite_3

  LDX #$00
  load_sprite_4:
  LDA sprite_running_flip,X
  STA $026c,X
  INX
  CPX #$24
  BNE load_sprite_4

  LDX #$00
  load_sprite_5:
  LDA sprite_attack,X
  STA $0290,X
  INX
  CPX #$24
  BNE load_sprite_5

  LDX #$00
  load_sprite_6:
  LDA sprite_attack_flip,X
  STA $02b4,X
  INX
  CPX #$24
  BNE load_sprite_6

  LDX #$00
  load_sprite_7:
  LDA sprite_dead,X
  STA $02d8,X
  INX
  CPX #$24
  BNE load_sprite_7

rts

sprite_standing:
  .byte 16, 00, 01, 24
  .byte 16, 01, 01, 32
  .byte 16, 02, 01, 40
  .byte 24, 16, 01, 24
  .byte 24, 17, 01, 32
  .byte 24, 18, 01, 40
  .byte 32, 32, 01, 24
  .byte 32, 33, 01, 32
  .byte 32, 34, 01, 40

sprite_standing_flip:
  .byte 16, 00, 64, 64
  .byte 16, 01, 64, 56
  .byte 16, 02, 64, 48
  .byte 24, 16, 64, 64
  .byte 24, 17, 64, 56
  .byte 24, 18, 64, 48
  .byte 32, 32, 64, 64
  .byte 32, 33, 64, 56
  .byte 32, 34, 64, 48

sprite_running:
  .byte 40, 06, 00, 24
  .byte 40, 07, 00, 32
  .byte 40, 08, 00, 40
  .byte 40, 22, 00, 24
  .byte 48, 23, 00, 32
  .byte 48, 24, 00, 40
  .byte 56, 38, 00, 24
  .byte 56, 39, 00, 32
  .byte 56, 40, 00, 40

sprite_running_flip:
  .byte 40, 06, 64, 64
  .byte 40, 07, 64, 56
  .byte 40, 08, 64, 48
  .byte 40, 22, 64, 64
  .byte 48, 23, 64, 56
  .byte 48, 24, 64, 48
  .byte 56, 38, 64, 64
  .byte 56, 39, 64, 56
  .byte 56, 40, 64, 48

sprite_attack:
  .byte 64,  51, 00, 24
  .byte 64,  52, 00, 32
  .byte 64,  53, 00, 40
  .byte 72,  67, 00, 24
  .byte 72,  68, 00, 32
  .byte 72,  69, 00, 40
  .byte 80, 83, 00, 24
  .byte 80, 84, 00, 32
  .byte 80, 85, 00, 40

  sprite_attack_flip:
  .byte 64,  51, 64, 64
  .byte 64,  52, 64, 56
  .byte 64,  53, 64, 48
  .byte 72,  67, 64, 64
  .byte 72,  68, 64, 56
  .byte 72,  69, 64, 48
  .byte 80, 83, 64, 64
  .byte 80, 84, 64, 56
  .byte 80, 85, 64, 48

sprite_dead:
  .byte 88,  54, 00, 48
  .byte 88,  55, 00, 56
  .byte 88,  56, 00, 64
  .byte 96,  70, 00, 48
  .byte 96,  71, 00, 56
  .byte 96,  72, 00, 64
  .byte 104, 86, 00, 48
  .byte 104, 87, 00, 56
  .byte 104, 88, 00, 64
.endproc

