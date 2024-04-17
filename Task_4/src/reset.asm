.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, player_walkstate, player_frame_counter, player_dir
.importzp player_UL, player_UR, player_DL, player_DR
.importzp controller

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
  SEI             ; Set Interrupt Ignore Bit
  CLD             ; Clear Decimal Mode bit
  LDX #$40
  STX $4017
  LDX #$FF
  TXS
  INX
  STX PPUCTRL     ; Turn off NMI
  STX PPUMASK     ; Disable rendering on startup
  STX $4010
  BIT PPUSTATUS
vblankwait:       ; Checks PPU status until reset is done
  BIT PPUSTATUS   
  BPL vblankwait

	LDX #$00
	LDA #$FF
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

; zero page variables initialization
  ;player position
  LDA #$50
  STA player_x
  LDA #$80
  STA player_y
  
  ;player direction
  LDA #$00
  STA player_dir
  ;player walkstate (00 = standing, 01 = walking right, 02 = walking left, 03 = walking up, 04 = walking down)
  
  LDA #$00
  STA player_walkstate

  ;player looking right (starting position)
  LDA #$08
  STA player_UL
  LDA #$09
  STA player_UR
  LDA #$0a
  STA player_DL
  LDA #$0b
  STA player_DR

  ; ;player looking left
  ; LDA #$1a
  ; STA player_L_UL
  ; LDA #$1b
  ; STA player2_L_UR
  ; LDA #$1c
  ; STA player2_L_DL
  ; LDA #$1d
  ; STA player2_L_DR

  ; ;player looking up

  ; LDA #$10
  ; STA player_U_UL
  ; LDA #$11
  ; STA player_U_UR
  ; LDA #$28
  ; STA player_U_DL
  ; LDA #$29
  ; STA player_U_DR

  ; ;player looking down
  ; LDA #$22
  ; STA player_D_UL
  ; LDA #$23
  ; STA player_D_UR
  ; LDA #$2a
  ; STA player_D_DL
  ; LDA #$2b
  ; STA player_D_DR

  ;player frame counter (used for animation)
  LDA #$00
  STA player_frame_counter

  JMP main
.endproc