.include "constants.inc"

.segment "ZEROPAGE"
.importzp player1_x, player1_y
.importzp player2_x, player2_y
.importzp player3_x, player3_y
.importzp player4_x, player4_y

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
  JMP main

; zero page variables initialization
;player 1
  LDA #$70
  STA player1_x
  LDA #$40
  STA player1_y
  
  ; LDA #$00
  ; STA player1_dir
  ; LDA #$00
  ; STA player1_walkstate

;player 2
  LDA #$80
  STA player2_x
  LDA #$50
  STA player2_y

;   LDA #$02
;   STA player2_dir
;   LDA #$00
;   STA player2_walkstate



  ;player 3
  LDA #$90
  STA player3_x
  LDA #$60
  STA player3_y

;   LDA #$03
;   STA player3_dir
;   LDA #$00
;   STA player3_walkstate

  ;player 4
  STA player4_x
  LDA #$a0
  STA player4_y
  LDA #$70
  
;   STA player4_dir
;   LDA #$00
;   STA player4_walkstate

;   LDA #$00
;   STA player1_frame_counter
;   STA player2_frame_counter
;   STA player3_frame_counter
;   STA player4_frame_counter
  JMP main
.endproc