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

; zero page variables initialization
;player 1
  LDA #$50
  STA player1_x
  LDA #$80
  STA player1_y
  
  ; LDA #$00
  ; STA player1_dir
  ; LDA #$00
  ; STA player1_walkstate

;player 2
  LDA #$60
  STA player2_x
  LDA #$80
  STA player2_y

;   LDA #$02
;   STA player2_dir
;   LDA #$00
;   STA player2_walkstate



  ;player 3
  LDA #$70
  STA player3_x
  LDA #$80
  STA player3_y

;   LDA #$03
;   STA player3_dir
;   LDA #$00
;   STA player3_walkstate

  ;player 4
  LDA #$80
  STA player4_x
  LDA #$80
  STA player4_y
  
;   STA player4_dir
;   LDA #$00
;   STA player4_walkstate


  JMP main
.endproc