.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
;player1 variables 
player1_x: .res 1
player1_y: .res 1
player1_dir: .res 1
player1_frame_counter: .res 1
player1_walkstate: .res 1

;player1 sprites
player1_UL: .res 1
player1_UR: .res 1
player1_DL: .res 1
player1_DR: .res 1

;player2 variables
player2_x: .res 1
player2_y: .res 1
player2_dir: .res 1
player2_frame_counter: .res 1
player2_walkstate: .res 1

;player2 sprites
player2_UL: .res 1
player2_UR: .res 1
player2_DL: .res 1
player2_DR: .res 1

;player3 variables
player3_x: .res 1
player3_y: .res 1
player3_dir: .res 1
player3_frame_counter: .res 1
player3_walkstate: .res 1

;player3 sprites
player3_UL: .res 1
player3_UR: .res 1
player3_DL: .res 1
player3_DR: .res 1

;player4 variables
player4_x: .res 1
player4_y:.res 1
player4_dir: .res 1
player4_frame_counter: .res 1
player4_walkstate: .res 1

;player4 sprites
player4_UL: .res 1
player4_UR: .res 1
player4_DL: .res 1
player4_DR: .res 1

.exportzp player1_x, player1_y, player1_dir, player1_frame_counter, player1_walkstate
.exportzp player2_x, player2_y, player2_dir, player2_frame_counter, player2_walkstate
.exportzp player3_x, player3_y, player3_dir, player3_frame_counter, player3_walkstate
.exportzp player4_x, player4_y, player4_dir, player4_frame_counter, player4_walkstate
.exportzp player1_UL, player1_UR, player1_DL, player1_DR
.exportzp player2_UL, player2_UR, player2_DL, player2_DR
.exportzp player3_UL, player3_UR, player3_DL, player3_DR
.exportzp player4_UL, player4_UR, player4_DL, player4_DR

.segment "CODE"
.proc irq_handler ; Interrupt Request,
  RTI
.endproc

.proc nmi_handler ; Non-Maskable Interrupt,
  LDA #$00        
  STA OAMADDR     ; Prep OAM for memory transfer at byte 0
  LDA #$02
  STA OAMDMA      ; Transfer memory page ($0200-$02ff) to OAM

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

.proc player1_update
  PHP ; Save values on stack
  PHA
  TXA
  PHA
  TYA
  PHA
  
  ; checkimg counter for player 1 for smooth animation
  LDA player1_frame_counter
  CMP #$08
  BNE player1_frame_counter_increment
  ;reset frame counter
  LDA #$00
  STA player1_frame_counter

  ;update player 1 walkstate (state machine for player 1 walking animation)
  LDA player1_walkstate
  CMP #$00
  BEQ player1_move_right_step1
  CMP #$01
  BEQ player1_move_right_step2
  CMP #$02
  BEQ player1_move_right_step3
  CMP #$03
  BEQ player1_move_left_step4
player1_move_right_step1:
  ;player1 looking right sprites
  LDA #$04
  STA player1_UL
  LDA #$05
  STA player1_UR
  LDA #$06
  STA player1_DL
  LDA #$07
  STA player1_DR
  ;update player 1 walkstate
  LDA #$01
  STA player1_walkstate
  JMP exit_player1_update
player1_move_right_step2:
  ;player1 looking right sprites
  LDA #$08
  STA player1_UL
  LDA #$09
  STA player1_UR
  LDA #$0a
  STA player1_DL
  LDA #$0b
  STA player1_DR
  ;update player 1 walkstate
  LDA #$02
  STA player1_walkstate
  JMP exit_player1_update
player1_move_right_step3:
  ;player1 looking right sprites
  LDA #$0c
  STA player1_UL
  LDA #$0d
  STA player1_UR
  LDA #$0e
  STA player1_DL
  LDA #$0f
  STA player1_DR
  ;update player 1 walkstate
  LDA #$03
  STA player1_walkstate
  JMP exit_player1_update
player1_move_left_step4:
  ;player1 looking right sprites
  LDA #$08
  STA player1_UL
  LDA #$09
  STA player1_UR
  LDA #$0a
  STA player1_DL
  LDA #$0b
  STA player1_DR
  ;update player 1 walkstate
  LDA #$00
  STA player1_walkstate
  JMP exit_player1_update

;increment player 1 frame counter
player1_frame_counter_increment:
  LDA player1_frame_counter
  CLC
  ADC #$01
  STA player1_frame_counter

exit_player1_update:
  ;Retrieve values from stack
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player2_update
  PHP ; Save values on stack
  PHA
  TXA
  PHA
  TYA
  PHA
  
  ;Player 2 movement
  LDA player2_frame_counter
  CMP #$08
  BNE player2_frame_counter_increment
  ;reset frame counter
  LDA #$00
  STA player2_frame_counter
  ;update player 2 direction
player2_move_left:
  ;animation player 2 moving left (state machine for player 2 walking animation)
  LDA player2_walkstate
  CMP #$00
  BEQ player2_move_left_step1
  CMP #$01
  BEQ player2_move_left_step2
  CMP #$02
  BEQ player2_move_left_step3
  CMP #$03
  BEQ player2_move_left_step4
  player2_move_left_step1:
  ;player2 looking left sprites
  LDA #$16
  STA player2_UL
  LDA #$17
  STA player2_UR
  LDA #$18
  STA player2_DL
  LDA #$19
  STA player2_DR
  ;update player 2 walkstate
  LDA #$01
  STA player2_walkstate
  JMP exit_player2_update
  player2_move_left_step2:
  ;player2 looking left sprites
  LDA #$1a
  STA player2_UL
  LDA #$1b
  STA player2_UR
  LDA #$1c
  STA player2_DL
  LDA #$1d
  STA player2_DR
  ;update player 2 walkstate
  LDA #$02
  STA player2_walkstate
  JMP exit_player2_update
  player2_move_left_step3:
  ;player2 looking left sprites
  LDA #$1e
  STA player2_UL
  LDA #$1f
  STA player2_UR
  LDA #$20
  STA player2_DL
  LDA #$21
  STA player2_DR
  ;update player 2 walkstate
  LDA #$03
  STA player2_walkstate
  JMP exit_player2_update
  player2_move_left_step4:
  ;player2 looking left sprites
  LDA #$1a
  STA player2_UL
  LDA #$1b
  STA player2_UR
  LDA #$1c
  STA player2_DL
  LDA #$1d
  STA player2_DR
  ;update player 2 walkstate
  LDA #$00
  STA player2_walkstate
  JMP exit_player2_update

;increment player 2 frame counter
player2_frame_counter_increment:
  LDA player2_frame_counter
  CLC
  ADC #$01
  STA player2_frame_counter

exit_player2_update:
  ;Retrieve values from stack
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player3_update
  PHP ; Save values on stack
  PHA
  TXA
  PHA
  TYA
  PHA
  
  ;Player 3 movement
  LDA player3_frame_counter
  CMP #$08
  BNE player3_frame_counter_increment
  ;reset frame counter
  LDA #$00
  STA player3_frame_counter
  ;update player 3 direction
player3_move_up:
  ;animation player 3 moving up (state machine for player 3 walking animation)
  LDA player3_walkstate
  CMP #$00
  BEQ player3_move_up_step1
  CMP #$01
  BEQ player3_move_up_step2
  CMP #$02
  BEQ player3_move_up_step3
  CMP #$03
  BEQ player3_move_up_step4
  player3_move_up_step1:
  ;player3 looking up sprites
  LDA #$10
  STA player3_UL
  LDA #$11
  STA player3_UR
  LDA #$12
  STA player3_DL
  LDA #$13
  STA player3_DR
  ;update player 3 walkstate
  LDA #$01
  STA player3_walkstate
  JMP exit_player3_update
  player3_move_up_step2:
  ;player3 looking up sprites
  LDA #$10
  STA player3_UL
  LDA #$11
  STA player3_UR
  LDA #$28
  STA player3_DL
  LDA #$29
  STA player3_DR
  ;update player 3 walkstate
  LDA #$02
  STA player3_walkstate
  JMP exit_player3_update
  player3_move_up_step3:
  ;player3 looking up sprites
  LDA #$10
  STA player3_UL
  LDA #$11
  STA player3_UR
  LDA #$14
  STA player3_DL
  LDA #$15
  STA player3_DR
  ;update player 3 walkstate
  LDA #$00
  STA player3_walkstate
  JMP exit_player3_update
  player3_move_up_step4:
  ;player3 looking up sprites
  LDA #$10
  STA player3_UL
  LDA #$11
  STA player3_UR
  LDA #$28
  STA player3_DL
  LDA #$29
  STA player3_DR

  ;update player 3 walkstate
  LDA #$00
  STA player3_walkstate
  JMP exit_player3_update

;increment player 3 frame counter
player3_frame_counter_increment:
  LDA player3_frame_counter
  CLC
  ADC #$01
  STA player3_frame_counter

exit_player3_update:
  ;Retrieve values from stack
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player4_update
  PHP ; Save values on stack
  PHA
  TXA
  PHA
  TYA
  PHA
  
  ;Player 4 movement
  LDA player4_frame_counter
  CMP #$08
  BNE player4_frame_counter_increment
  ;reset frame counter
  LDA #$00
  STA player4_frame_counter
  ;update player 4 direction
player4_move_down:
  ;animation player 4 moving down (state machine for player 4 walking animation)
  LDA player4_walkstate
  CMP #$00
  BEQ player4_move_down_step1
  CMP #$01
  BEQ player4_move_down_step2
  CMP #$02
  BEQ player4_move_down_step3
  CMP #$03
  BEQ player4_move_down_step4
  player4_move_down_step1:
  ;player4 looking down sprites
  LDA #$22
  STA player4_UL
  LDA #$23
  STA player4_UR
  LDA #$24
  STA player4_DL
  LDA #$25
  STA player4_DR
  ;update player 4 walkstate
  LDA #$01
  STA player4_walkstate
  JMP exit_player4_update
  player4_move_down_step2:
  ;player4 looking down sprites
  LDA #$22
  STA player4_UL
  LDA #$23
  STA player4_UR
  LDA #$2a
  STA player4_DL
  LDA #$2b
  STA player4_DR
  ;update player 4 walkstate
  LDA #$02
  STA player4_walkstate
  JMP exit_player4_update
  player4_move_down_step3:
  ;player4 looking down sprites
  LDA #$22
  STA player4_UL
  LDA #$23
  STA player4_UR
  LDA #$26
  STA player4_DL
  LDA #$27
  STA player4_DR
  ;update player 4 walkstate
  LDA #$00
  STA player4_walkstate
  JMP exit_player4_update
  player4_move_down_step4:
  ;player4 looking down sprites
  LDA #$22
  STA player4_UL
  LDA #$23
  STA player4_UR
  LDA #$2a
  STA player4_DL
  LDA #$2b
  STA player4_DR

  ;update player 4 walkstate
  LDA #$00
  STA player4_walkstate
  JMP exit_player4_update

;increment player 4 frame counter
player4_frame_counter_increment:
  LDA player4_frame_counter
  CLC
  ADC #$01
  STA player4_frame_counter

exit_player4_update:
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