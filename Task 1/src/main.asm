.include "constants.inc"
.include "header.inc"

.segment "CODE"
.proc irq_handler ; Interrupt Request
  RTI
.endproc

.proc nmi_handler ; Non-Maskable Interrupt,
  LDA #$00        
  STA OAMADDR     ; Prep OAM for memory transfer at byte 0
  LDA #$02
  STA OAMDMA      ; Transfer memory page ($0200-$02ff) to OAM
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

  LDX #$00
load_sprites:       ; Iterate until all sprites are loaded 
  LDA sprites,X
  STA $0200,X
  INX
  CPX #$c0          ; Max 176 Sprites
  BNE load_sprites

load_background:    ; Background loading sequence
  ; Big particle
  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR
  LDA #$6b
  STA PPUADDR
  LDX #$2d          
  STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$57
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$23
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$52
	STA PPUADDR
	STX PPUDATA

  ; Scatter particles
	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$74
	STA PPUADDR
	LDX #$2e
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$43
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$5d
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$73
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$2f
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$f7
	STA PPUADDR
	STX PPUDATA

  ; Particle cluster
	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$f1
	STA PPUADDR
	LDX #$2f
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$a8
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$7a
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$44
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$7c
	STA PPUADDR
	STX PPUDATA

  ; Stage 1 Textures
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$e8
	STA PPUADDR
	LDX #$30       ; wall 1
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$e9
	STA PPUADDR
	LDX #$31      ; wall 2
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$ea
	STA PPUADDR
	LDX #$32      ; transparent tile
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$eb
	STA PPUADDR
	LDX #$33      ; background tile
	STX PPUDATA

  ; Extra block (End Goal block?)
  LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$ec
	STA PPUADDR
	LDX #$34      
	STX PPUDATA

  ; Stage 2 Textures
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$08
	STA PPUADDR
	LDX #$35      ; wall 1
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$09
	STA PPUADDR
	LDX #$36      ; wall 2
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0a
	STA PPUADDR
	LDX #$37      ; trasnparent tile
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0b
	STA PPUADDR
	LDX #$38      ; background tile
	STX PPUDATA

  ; Extra block 2
  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$0c
	STA PPUADDR
	LDX #$39
	STX PPUDATA

	; Stage 1 Attributes
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$da
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  ; Stage 2 Attributes
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$e2
	STA PPUADDR
	LDA #%11111111
	STA PPUDATA

  ; Extra block 1 attributes
  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$db
	STA PPUADDR
	LDA #%10101010
	STA PPUDATA

  ; Extra block 2 attributes
  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$e3
	STA PPUADDR
	LDA #%10101010
	STA PPUDATA

  ; Some Particle Attributes for variety
  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$cc
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$d0
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$ed
	STA PPUADDR
	LDA #%11111111
	STA PPUDATA

  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$d5
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

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

; Standing Up
.byte $50, $10, $01, $40
.byte $50, $11, $01, $48
.byte $58, $28, $01, $40
.byte $58, $29, $01, $48

; Walk Up 2
.byte $50, $10, $01, $50
.byte $50, $11, $01, $58
.byte $58, $14, $01, $50
.byte $58, $15, $01, $58

; Standing left 
.byte $50, $16, $01, $60
.byte $50, $17, $01, $68
.byte $58, $18, $01, $60
.byte $58, $19, $01, $68

; Walk Left 1 (Stepping frame)
.byte $50, $1a, $01, $70
.byte $50, $1b, $01, $78
.byte $58, $1c, $01, $70
.byte $58, $1d, $01, $78

; Walk Left 2 (Push frame)
.byte $60, $1e, $01, $40
.byte $60, $1f, $01, $48
.byte $68, $20, $01, $40
.byte $68, $21, $01, $48

; Walk Down 1 
.byte $60, $22, $01, $50
.byte $60, $23, $01, $58
.byte $68, $24, $01, $50
.byte $68, $25, $01, $58

; Walk Down 2 
.byte $60, $22, $01, $60
.byte $60, $23, $01, $68
.byte $68, $26, $01, $60
.byte $68, $27, $01, $68

; Standing Down
.byte $60, $22, $01, $70
.byte $60, $23, $01, $78
.byte $68, $2a, $01, $70
.byte $68, $2b, $01, $78

.segment "CHR"
.incbin "graphics.chr"