.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
;player1 variables 
player1_x: .res 1
player1_y: .res 1

;player2 variables
player2_x: .res 1
player2_y: .res 1

;player3 variables
player3_x: .res 1
player3_y: .res 1

;player4 variables
player4_x: .res 1
player4_y:.res 1

.exportzp player1_x, player1_y
.exportzp player2_x, player2_y
.exportzp player3_x, player3_y
.exportzp player4_x, player4_y

.segment "CODE"
.proc irq_handler ; Interrupt Request,
  RTI
.endproc

.proc nmi_handler ; Non-Maskable Interrupt,
  LDA #$00        
  STA OAMADDR     ; Prep OAM for memory transfer at byte 0
  LDA #$02
  STA OAMDMA      ; Transfer memory page ($0200-$02ff) to OAM

	JSR draw_players

	LDA #$00
	STA $2005
	STA $2005
  RTI
.endproc

.import reset_handler

.export main
.proc main
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR

load_palettes:      ; Iterate until all palettes are loaded 
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20          ; Max 32 colors in palettes
  BNE load_palettes

vblankwait: ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc

.proc draw_players
  ;Save values on stack
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ;Player 1: tiles
  LDA #$08
  STA $0201
  LDA #$09
  STA $0205
  LDA #$0a
  STA $0209
  LDA #$0b
  STA $020d

  ;Player 2: tiles
  LDA #$1a
  STA $0211
  LDA #$1b
  STA $0215
  LDA #$1c
  STA $0219
  LDA #$1d
  STA $021d

  ;Player 3: tiles
  LDA #$10
  STA $0221
  LDA #$11
  STA $0225
  LDA #$28
  STA $0229
  LDA #$29
  STA $022d

  ;Player 4: tiles
  LDA #$22
  STA $0231
  LDA #$23
  STA $0235
  LDA #$2a
  STA $0239
  LDA #$2b
  STA $023d

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  ;player 1
  STA $0202
  STA $0206
  STA $020a
  STA $020e
  ;player 2
  STA $0212
  STA $0216
  STA $021a
  STA $021e
  ;player 3
  STA $0222
  STA $0226
  STA $022a
  STA $022e
  ;player 4
  STA $0232
  STA $0236
  STA $023a
  STA $023e

  ;Player 1 position
  ; top left tile:
  LDA player1_y
  STA $0200
  LDA player1_x
  STA $0203
  ; top right tile (x + 8):
  LDA player1_y
  STA $0204
  LDA player1_x
  CLC
  ADC #$08
  STA $0207
  ; bottom left tile (y + 8):
  LDA player1_y
  CLC
  ADC #$08
  STA $0208
  LDA player1_x
  STA $020b
  ; bottom right tile (x + 8, y + 8)
  LDA player1_y
  CLC
  ADC #$08
  STA $020c
  LDA player1_x
  CLC
  ADC #$08
  STA $020f

  ;Player 2 position
  ; top left tile:
  LDA player2_y
  STA $0210
  LDA player2_x
  STA $0213
  ; top right tile (x + 8):
  LDA player2_y
  STA $0214
  LDA player2_x
  CLC
  ADC #$08
  STA $0217
  ; bottom left tile (y + 8):
  LDA player2_y
  CLC
  ADC #$08
  STA $0218
  LDA player2_x
  STA $021b
  ; bottom right tile (x + 8, y + 8)
  LDA player2_y
  CLC
  ADC #$08
  STA $021c
  LDA player2_x
  CLC
  ADC #$08
  STA $021f

  ; Player 3 position
  ; top left tile:
  LDA player3_y
  STA $0220
  LDA player3_x
  STA $0223
  ; top right tile (x + 8):
  LDA player3_y
  STA $0224
  LDA player3_x
  CLC
  ADC #$08
  STA $0227
  ; bottom left tile (y + 8):
  LDA player3_y
  CLC
  ADC #$08
  STA $0228
  LDA player3_x
  STA $022b
  ; bottom right tile (x + 8, y + 8)
  LDA player3_y
  CLC
  ADC #$08
  STA $022c
  LDA player3_x
  CLC
  ADC #$08
  STA $022f

  ; Player 4 position
  ; top left tile:
  LDA player4_y
  STA $0230
  LDA player4_x
  STA $0233
  ; top right tile (x + 8):
  LDA player4_y
  STA $0234
  LDA player4_x
  CLC
  ADC #$08
  STA $0237
  ; bottom left tile (y + 8):
  LDA player4_y
  CLC
  ADC #$08
  STA $0238
  LDA player4_x
  STA $023b
  ; bottom right tile (x + 8, y + 8)
  LDA player4_y
  CLC
  ADC #$08
  STA $023c
  LDA player4_x
  CLC
  ADC #$08
  STA $023f

  ;Retrieve values from stack
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
; Background Palettes
.byte $0f, $00, $10, $20    ; black, dark gray, gray, white
.byte $0f, $07, $17, $18    ; black, brown, light brown, puke green
.byte $0f, $0b, $19, $2a    ; black, dark green, green, neon green
.byte $0f, $01, $13, $05    ; black, dark blue, purple, dark rose

; Sprite Palettes 
.byte $0f, $00, $10, $20    ; black, dark gray, gray, white
.byte $0f, $16, $27, $19    ; black, sunset orange, light orange, green
.byte $0f, $1c, $2c, $3c    ; black, navy blue, light blue, sky blue
.byte $0f, $06, $38, $17    ; black, dark red, cream, light brown

.segment "CHR"
.incbin "graphics.chr"