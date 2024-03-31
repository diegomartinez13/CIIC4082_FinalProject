.include "constants.inc"

.segment "ZEROPAGE"
.importzp player1_x, player1_y, player2_x, player2_y, player3_x, player3_y, player4_x, player4_y
.importzp player1_walkstate, player2_walkstate, player3_walkstate, player4_walkstate
.importzp player1_frame_counter, player2_frame_counter, player3_frame_counter, player4_frame_counter
.importzp player1_UL, player1_UR, player1_DL, player1_DR
.importzp player2_UL, player2_UR, player2_DL, player2_DR
.importzp player3_UL, player3_UR, player3_DL, player3_DR
.importzp player4_UL, player4_UR, player4_DL, player4_DR

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
;player 1
  LDA #$50
  STA player1_x
  LDA #$80
  STA player1_y
  
  LDA #$00
  STA player1_walkstate

  LDA #$08
  STA player1_UL
  LDA #$09
  STA player1_UR
  LDA #$0a
  STA player1_DL
  LDA #$0b

;player 2
  LDA #$60
  STA player2_x
  LDA #$80
  STA player2_y

  LDA #$00
  STA player2_walkstate

  LDA #$1a
  STA player2_UL
  LDA #$1b
  STA player2_UR
  LDA #$1c
  STA player2_DL
  LDA #$1d
  STA player2_DR

  ;player 3
  LDA #$70
  STA player3_x
  LDA #$80
  STA player3_y

  LDA #$00
  STA player3_walkstate

  LDA #$10
  STA player3_UL
  LDA #$11
  STA player3_UR
  LDA #$28
  STA player3_DL
  LDA #$29
  STA player3_DR

  ;player 4
  LDA #$80
  STA player4_x
  LDA #$80
  STA player4_y
  
  LDA #$00
  STA player4_walkstate

  LDA #$22
  STA player4_UL
  LDA #$23
  STA player4_UR
  LDA #$2a
  STA player4_DL
  LDA #$2b
  STA player4_DR

  LDA #$00
  STA player1_frame_counter
  STA player2_frame_counter
  STA player3_frame_counter
  STA player4_frame_counter
  JMP main
.endproc