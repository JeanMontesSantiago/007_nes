.include "constants.inc"

.segment "ZEROPAGE"
.importzp frames, current_running_sprite

.segment "CODE"
.import main
.import player_tick

.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$00
  STX PPUCTRL
  STX PPUMASK

vblankwait:
  BIT PPUSTATUS
  BPL vblankwait

	LDX #$00
	LDA #$ff
clear_oam:
	STA $0200,X ; set sprite y-positions off the screen
	INX
	INX
	INX
	INX
	BNE clear_oam

vblankwait2:
	BIT PPUSTATUS
	BPL vblankwait2

	LDA #$00
	STA frames
	LDA #$00
	STA current_running_sprite

  JMP main
.endproc