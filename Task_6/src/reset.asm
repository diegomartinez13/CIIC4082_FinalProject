.include "constants.inc"

.segment "ZEROPAGE"
.importzp player_x, player_y, player_walkstate, player_frame_counter, player_dir
.importzp player_UL, player_UR, player_DL, player_DR
.importzp controller
.importzp nametable_select, level_select, clock_frame_counter, clock_timmer

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
  ;clock initialization
  LDA #$00
  STA clock_frame_counter

  LDA #$60
  STA clock_timmer

  ;nametable select
  LDA #$00
  STA nametable_select

  ;level select
  LDA #$00
  STA level_select

  ; ;player position depending on the level
  ; LDA level_select
  ; CMP #$01
  ; BEQ level2

  LDA #$10
  STA player_x
  LDA #$cF
  STA player_y
  ; JMP player_direction

  ; level2:
  ; LDA #$10
  ; STA player_x
  ; LDA #$1F
  ; STA player_y

  player_direction:
  
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

  ;player frame counter (used for animation)
  LDA #$00
  STA player_frame_counter

  JMP main
.endproc