.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
;player1 variables 
player1_x .res 1
player1_y .res 1
player1_dir .res 1
player1_frame_counter .res 1
;player1 sprite indexes
player1_UL .res 1
player1_UR .res 1
player1_DL .res 1
player1_DR .res 1

;player2 variables
player2_x .res 1
player2_y .res 1
player2_dir .res 1
player2_frame_counter .res 1
;player2 sprite indexes
player2_UL .res 1
player2_UR .res 1
player2_DL .res 1
player2_DR .res 1

;player3 variables
player3_x .res 1
player3_y .res 1
player3_dir .res 1
player3_frame_counter .res 1
;player3 sprite indexes
player3_UL .res 1
player3_UR .res 1
player3_DL .res 1
player3_DR .res 1

;player4 variables
player4_x .res 1
player4_y .res 1
player4_dir .res 1
player4_frame_counter .res 1
;player4 sprite indexes
player4_UL .res 1
player4_UR .res 1
player4_DL .res 1
player4_DR .res 1
.exportzp player1_x, player1_y, player1_dir, player1_frame_counter, player1_UL, player1_UR, player1_DL, player1_DR
.exportzp player2_x, player2_y, player2_dir, player2_frame_counter, player2_UL, player2_UR, player2_DL, player2_DR
.exportzp player3_x, player3_y, player3_dir, player3_frame_counter, player3_UL, player3_UR, player3_DL, player3_DR
.exportzp player4_x, player4_y, player4_dir, player4_frame_counter, player4_UL, player4_UR, player4_DL, player4_DR

.segment "CODE"
.proc irq_handler ; Interrupt Request,
  RTI
.endproc

.proc nmi_handler ; Non-Maskable Interrupt,
  LDA #$00        
  STA OAMADDR     ; Prep OAM for memory transfer at byte 0
  LDA #$02
  STA OAMDMA      ; Transfer memory page ($0200-$02ff) to OAM

	;update and draw players
	JSR player1_update
	JSR player2_update
	JSR player3_update
	JSR player4_update
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
  LDA player1_UL
  STA $0201
  LDA player1_UR
  STA $0205
  LDA player1_DL
  STA $0209
  LDA player1_DR
  STA $020d

  ;Player 2: tiles
  LDA player2_UL
  STA $0211
  LDA player2_UR
  STA $0215
  LDA player2_DL
  STA $0219
  LDA player2_DR
  STA $021d

  ;Player 3: tiles
  LDA player3_UL
  STA $0221
  LDA player3_UR
  STA $0225
  LDA player3_DL
  STA $0229
  LDA player3_DR
  STA $022d

  ;Player 4: tiles
  LDA player4_UL
  STA $0231
  LDA player4_UR
  STA $0235
  LDA player4_DL
  STA $0239
  LDA player4_DR
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

sprites:
; Standing Right
.byte $40, $04, $01, $40
.byte $40, $05, $01, $48
.byte $48, $06, $01, $40
.byte $48, $07, $01, $48

; Walk Right 1 (Stepping frame)
.byte $40, $08, $01, $50
.byte $40, $09, $01, $58
.byte $48, $0a, $01, $50
.byte $48, $0b, $01, $58

; Walk Right 2 (Push frame)
.byte $40, $0c, $01, $60
.byte $40, $0d, $01, $68
.byte $48, $0e, $01, $60
.byte $48, $0f, $01, $68

; Walk Up 1
.byte $40, $10, $01, $70
.byte $40, $11, $01, $78
.byte $48, $12, $01, $70
.byte $48, $13, $01, $78

; Walk Up 2
.byte $50, $10, $01, $40
.byte $50, $11, $01, $48
.byte $58, $14, $01, $40
.byte $58, $15, $01, $48

; Standing left 
.byte $50, $16, $01, $50
.byte $50, $17, $01, $58
.byte $58, $18, $01, $50
.byte $58, $19, $01, $58

; Walk Left 1 (Stepping frame)
.byte $50, $1a, $01, $60
.byte $50, $1b, $01, $68
.byte $58, $1c, $01, $60
.byte $58, $1d, $01, $68

; Walk Left 2 (Push frame)
.byte $50, $1e, $01, $70
.byte $50, $1f, $01, $78
.byte $58, $20, $01, $70
.byte $58, $21, $01, $78

; Walk Down 1 
.byte $60, $22, $01, $40
.byte $60, $23, $01, $48
.byte $68, $24, $01, $40
.byte $68, $25, $01, $48

; Walk Down 2 
.byte $60, $22, $01, $50
.byte $60, $23, $01, $58
.byte $68, $26, $01, $50
.byte $68, $27, $01, $58

.segment "CHR"
.incbin "graphics.chr"