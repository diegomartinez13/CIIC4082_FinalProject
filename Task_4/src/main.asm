.include "constants.inc"
.include "header.inc"
.import Unpack0, Unpack1, Unpack2, Unpack3

.segment "ZEROPAGE"
;player1 variables 
;player_x: .res 1
;player_y: .res 1
;player_dir: .res 1
;player_frame_counter: .res 1
;player_walkstate: .res 1

;player1 sprites
;player_UL: .res 1
;player_UR: .res 1
;player_DL: .res 1
;player_DR: .res 1

;variables
changebg: .res 1
controller: .res 1
scroll: .res 1
myb: .res 1
mxb: .res 1
index: .res 1
curbit: .res 1
curtile: .res 1
nxtblk: .res 1
btcnt: .res 1
addrhi: .res 1
row: .res 1
temp: .res 1

;ppuctrl_sett: .res 1
.exportzp controller, myb, mxb, index, curbit, curtile, nxtblk, btcnt, addrhi, row, temp
.export nametable0, nametable1, nametable2, nametable3, nt0_length, nt1_length, nt2_length, nt3_length

.segment "CODE"
.proc irq_handler ; Interrupt Request,
  RTI
.endproc

.import read_controller

.proc nmi_handler ; Non-Maskable Interrupt,
  LDA #$00        
  STA OAMADDR     ; Prep OAM for memory transfer at byte 0
  LDA #$02
  STA OAMDMA      ; Transfer memory page ($0200-$02ff) to OAM
  LDA #$00
  
  JSR read_controller

  ;LDA scroll
  ;CMP #$00 ; check if the end of the nametable was reached
  ;BNE set_scroll

  ;LDA ppuctrl_sett
  ;EOR #%00000001 ; flip bit 0 to its opposite
	;STA ppuctrl_settings
	;STA PPUCTRL
	;LDA #255
	;STA scroll

;set_scroll:
  ;LDA scroll
  ;STA PPUSCROLL ; set X scroll and leave Y untouched since it will remain static

  LDX #$00
  STX PPUSCROLL   ;Set scroll positions
  STX PPUSCROLL

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

  LDX #0
load_palettes:      ; Iterate until all palettes are loaded 
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20          ; Max 32 colors in palettes
  BNE load_palettes
  
vblankwait: ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

load_stages:
  ;LDA controller      ; Read and load controller state
  ;AND #$01            ; check A button state specifically
  ;BEQ stage1          ; Load Stage 1 if A is not pressed
  ;JMP stage2          ; If pressed, load stage 2

  stage1:
    ;Load stage 1 part 1
    LDX PPUSTATUS
    JSR Unpack0   ; unpack nametable for part 1

      LDA #$c0
      load_attributes1:
        LDX PPUSTATUS
        LDY #$23
        STY PPUADDR
        STA PPUADDR
        LDX #%01010101
        STX PPUDATA
        CLC
        ADC #$01
        CMP #$00
        BNE load_attributes1

  LDA #%10001000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc

<<<<<<< HEAD
.proc player_update
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; check if player is moving
  LDA controller ; load controller input
  AND #BTN_LEFT ; mask out all but the left button
  BEQ check_right ; if the left button is not pressed, check the right button
  ; if the branch not taken, we are moving left
  JSR player_move_left ; start moving left
  DEC player_x  ; If the branch is not taken, move player left
check_right:
  LDA controller
  AND #BTN_RIGHT
  BEQ check_up
  JSR player_move_right
  INC player_x
check_up:
  LDA controller
  AND #BTN_UP
  BEQ check_down
  JSR player_move_up
  DEC player_y
check_down:
  LDA controller
  AND #BTN_DOWN
  BEQ done_checking
  JSR player_move_down
  INC player_y
done_checking:
  PLA ; Done with updates, restore registers
  TAY ; and return to where we called this
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc draw_player
  ;Save values on stack
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ;Player : tiles
  LDA player_UL
  STA $0201
  LDA player_UR
  STA $0205
  LDA player_DL
  STA $0209
  LDA player_DR
  STA $020d

  ; write player tile attributes
  ; use palette 01
  LDA #$01
  STA $0202
  STA $0206
  STA $020a
  STA $020e


  ;Player position
  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203
  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207
  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b
  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f


  ;Retrieve values from stack
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player_move_right
  PHP ; Save values on stack
  PHA
  TXA
  PHA
  TYA
  PHA
  
  ; checkimg counter for player for smooth animation
  LDA player_frame_counter
  CMP #$08
  BNE player_frame_counter_increment
  ;reset frame counter
  LDA #$00
  STA player_frame_counter

  ;update player walkstate (state machine for player walking animation)
  LDA player_walkstate
  CMP #$00
  BEQ player_move_right_step1
  CMP #$01
  BEQ player_move_right_step2
  CMP #$02
  BEQ player_move_right_step3
  CMP #$03
  BEQ player_move_left_step4
player_move_right_step1:
  ;player1 looking right sprites
  LDA #$04
  STA player_UL
  LDA #$05
  STA player_UR
  LDA #$06
  STA player_DL
  LDA #$07
  STA player_DR
  ;update player walkstate
  LDA #$01
  STA player_walkstate
  JMP exit_player_move_right
player_move_right_step2:
  ;player1 looking right sprites
  LDA #$08
  STA player_UL
  LDA #$09
  STA player_UR
  LDA #$0a
  STA player_DL
  LDA #$0b
  STA player_DR
  ;update player walkstate
  LDA #$02
  STA player_walkstate
  JMP exit_player_move_right
player_move_right_step3:
  ;player1 looking right sprites
  LDA #$0c
  STA player_UL
  LDA #$0d
  STA player_UR
  LDA #$0e
  STA player_DL
  LDA #$0f
  STA player_DR
  ;update player walkstate
  LDA #$03
  STA player_walkstate
  JMP exit_player_move_right
player_move_left_step4:
  ;player1 looking right sprites
  LDA #$08
  STA player_UL
  LDA #$09
  STA player_UR
  LDA #$0a
  STA player_DL
  LDA #$0b
  STA player_DR
  ;update player walkstate
  LDA #$00
  STA player_walkstate
  JMP exit_player_move_right

;increment player frame counter
player_frame_counter_increment:
  LDA player_frame_counter
  CLC
  ADC #$01
  STA player_frame_counter

exit_player_move_right:
  ;Retrieve values from stack
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player_move_left
  PHP ; Save values on stack
  PHA
  TXA
  PHA
  TYA
  PHA
  
  ; checkimg counter for player for smooth animation
  LDA player_frame_counter
  CMP #$08
  BNE player_frame_counter_increment
  ;reset frame counter
  LDA #$00
  STA player_frame_counter
  ;update player direction
player_move_left:
  ;animation player moving left (state machine for player walking animation)
  LDA player_walkstate
  CMP #$00
  BEQ player_move_left_step1
  CMP #$01
  BEQ player_move_left_step2
  CMP #$02
  BEQ player_move_left_step3
  CMP #$03
  BEQ player_move_left_step4
  player_move_left_step1:
  ;player looking left sprites
  LDA #$16
  STA player_UL
  LDA #$17
  STA player_UR
  LDA #$18
  STA player_DL
  LDA #$19
  STA player_DR
  ;update player walkstate
  LDA #$01
  STA player_walkstate
  JMP exit_player_move_left
  player_move_left_step2:
  ;player looking left sprites
  LDA #$1a
  STA player_UL
  LDA #$1b
  STA player_UR
  LDA #$1c
  STA player_DL
  LDA #$1d
  STA player_DR
  ;update player walkstate
  LDA #$02
  STA player_walkstate
  JMP exit_player_move_left
  player_move_left_step3:
  ;player looking left sprites
  LDA #$1e
  STA player_UL
  LDA #$1f
  STA player_UR
  LDA #$20
  STA player_DL
  LDA #$21
  STA player_DR
  ;update player walkstate
  LDA #$03
  STA player_walkstate
  JMP exit_player_move_left
  player_move_left_step4:
  ;player looking left sprites
  LDA #$1a
  STA player_UL
  LDA #$1b
  STA player_UR
  LDA #$1c
  STA player_DL
  LDA #$1d
  STA player_DR
  ;update player walkstate
  LDA #$00
  STA player_walkstate
  JMP exit_player_move_left

;increment player frame counter
player_frame_counter_increment:
  LDA player_frame_counter
  CLC
  ADC #$01
  STA player_frame_counter

exit_player_move_left:
  ;Retrieve values from stack
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player_move_up
  PHP ; Save values on stack
  PHA
  TXA
  PHA
  TYA
  PHA
  
  ;Player movement
  LDA player_frame_counter
  CMP #$08
  BNE player_frame_counter_increment
  ;reset frame counter
  LDA #$00
  STA player_frame_counter
  ;update player direction
  ;animation player moving up (state machine for player walking animation)
  LDA player_walkstate
  CMP #$00
  BEQ player_move_up_step1
  CMP #$01
  BEQ player_move_up_step2
  CMP #$02
  BEQ player_move_up_step3
  CMP #$03
  BEQ player_move_up_step4
  player_move_up_step1:
  ;player looking up sprites
  LDA #$10
  STA player_UL
  LDA #$11
  STA player_UR
  LDA #$12
  STA player_DL
  LDA #$13
  STA player_DR
  ;update player walkstate
  LDA #$01
  STA player_walkstate
  JMP exit_player_move_up
  player_move_up_step2:
  ;player looking up sprites
  LDA #$10
  STA player_UL
  LDA #$11
  STA player_UR
  LDA #$28
  STA player_DL
  LDA #$29
  STA player_DR
  ;update player walkstate
  LDA #$02
  STA player_walkstate
  JMP exit_player_move_up
  player_move_up_step3:
  ;player looking up sprites
  LDA #$10
  STA player_UL
  LDA #$11
  STA player_UR
  LDA #$14
  STA player_DL
  LDA #$15
  STA player_DR
  ;update player walkstate
  LDA #$00
  STA player_walkstate
  JMP exit_player_move_up
  player_move_up_step4:
  ;player looking up sprites
  LDA #$10
  STA player_UL
  LDA #$11
  STA player_UR
  LDA #$28
  STA player_DL
  LDA #$29
  STA player_DR

  ;update player walkstate
  LDA #$00
  STA player_walkstate
  JMP exit_player_move_up

;increment player frame counter
player_frame_counter_increment:
  LDA player_frame_counter
  CLC
  ADC #$01
  STA player_frame_counter

exit_player_move_up:
  ;Retrieve values from stack
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc player_move_down
  PHP ; Save values on stack
  PHA
  TXA
  PHA
  TYA
  PHA
  
  ;Player movement down
  LDA player_frame_counter
  CMP #$08
  BNE player_frame_counter_increment
  ;reset frame counter
  LDA #$00
  STA player_frame_counter
  ;update player direction
  ;animation player moving down (state machine for player walking animation)
  LDA player_walkstate
  CMP #$00
  BEQ player_move_down_step1
  CMP #$01
  BEQ player_move_down_step2
  CMP #$02
  BEQ player_move_down_step3
  CMP #$03
  BEQ player_move_down_step4
  player_move_down_step1:
  ;player looking down sprites
  LDA #$22
  STA player_UL
  LDA #$23
  STA player_UR
  LDA #$24
  STA player_DL
  LDA #$25
  STA player_DR
  ;update player walkstate
  LDA #$01
  STA player_walkstate
  JMP exit_player_move_down
  player_move_down_step2:
  ;player4 looking down sprites
  LDA #$22
  STA player_UL
  LDA #$23
  STA player_UR
  LDA #$2a
  STA player_DL
  LDA #$2b
  STA player_DR
  ;update player walkstate
  LDA #$02
  STA player_walkstate
  JMP exit_player_move_down
  player_move_down_step3:
  ;player looking down sprites
  LDA #$22
  STA player_UL
  LDA #$23
  STA player_UR
  LDA #$26
  STA player_DL
  LDA #$27
  STA player_DR
  ;update player  walkstate
  LDA #$00
  STA player_walkstate
  JMP exit_player_move_down
  player_move_down_step4:
  ;player looking down sprites
  LDA #$22
  STA player_UL
  LDA #$23
  STA player_UR
  LDA #$2a
  STA player_DL
  LDA #$2b
  STA player_DR

  ;update player walkstate
  LDA #$00
  STA player_walkstate
  JMP exit_player_move_down

;increment player frame counter
player_frame_counter_increment:
  LDA player_frame_counter
  CLC
  ADC #$01
  STA player_frame_counter

exit_player_move_down:
  ;Retrieve values from stack
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

=======
>>>>>>> ced1dcf (Unfinished task 4)
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

tilemap:
  .byte %00 ; $00 empty space
  .byte %01 ; $30 wall block
  .byte %10 ; $32 bush block
  .byte %11 ; $33 goal block

;Stage 1 part 1
nametable0:
  ;Packaged nametable. Every byte represents 4 2x2 tile blocks in a row
  .byte %00000000,%00000000,%00000000,%00000000 
  .byte %01010101,%01010101,%01010101,%01010101
  .byte %01000000,%00000000,%01010101,%00000001
  .byte %01000101,%01010000,%00010000,%10010001
  .byte %01000000,%00100100,%00010000,%01000001
  .byte %01000101,%00010100,%00010000,%01000101
  .byte %01000001,%00000100,%10100000,%01100111
  .byte %01010101,%01000000,%00010000,%01100011
  .byte %01000000,%00000001,%00010100,%01010111
  .byte %01000110,%01000001,%00010100,%00000001
  .byte %01000100,%01010001,%00010101,%01010001
  .byte %01000100,%01010001,%00010101,%01010001
  .byte %01000101,%01101001,%00000001,%01011001
  .byte %01110000,%00101001,%01010000,%00101001
  .byte %01010101,%01010101,%01010101,%01010101
nt0end: 
  nt0_length = nt0end-nametable0
  ;Half-packaged. Every bit represents a 2x2 tile block
  ;.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
  ;.byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30
  ;.byte $30,$00,$00,$00,$00,$00,$00,$00,$30,$30,$30,$30,$00,$00,$00,$30
  ;.byte $30,$00,$30,$30,$30,$30,$00,$00,$00,$30,$00,$00,$32,$30,$00,$30
  ;.byte $30,$00,$00,$00,$00,$32,$30,$00,$00,$30,$00,$00,$30,$00,$00,$30
  ;.byte $30,$00,$30,$30,$00,$30,$30,$00,$00,$30,$00,$00,$30,$00,$30,$30
  ;.byte $30,$00,$00,$30,$00,$00,$30,$00,$32,$32,$00,$00,$30,$32,$30,$33
  ;.byte $30,$30,$30,$30,$30,$00,$00,$00,$00,$30,$00,$00,$30,$32,$00,$33
  ;.byte $30,$00,$00,$00,$00,$00,$00,$30,$00,$30,$30,$00,$30,$30,$30,$33
  ;.byte $30,$00,$30,$32,$30,$00,$00,$30,$00,$30,$30,$00,$00,$00,$00,$30
  ;.byte $30,$00,$30,$00,$30,$30,$00,$30,$00,$30,$30,$30,$30,$30,$00,$30
  ;.byte $30,$00,$30,$00,$30,$30,$00,$30,$00,$30,$30,$30,$30,$30,$00,$30
  ;.byte $30,$00,$30,$30,$30,$32,$32,$30,$00,$00,$00,$30,$30,$30,$32,$30
  ;.byte $30,$33,$00,$00,$00,$32,$32,$30,$30,$30,$00,$00,$00,$32,$32,$30
  ;.byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30

;Stage 1 part 2
nametable1:
  .byte %00000000,%00000000,%00000000,%00000000
  .byte %01010101,%01010101,%01010101,%01010101
  .byte %01000000,%00000101,%01010110,%10000011
  .byte %01010101,%01101010,%00010110,%10000011
  .byte %01001010,%00000101,%00010110,%10000011
  .byte %01000101,%01000101,%00010101,%01000001
  .byte %11100100,%00000101,%00001001,%01010001
  .byte %11000000,%01010101,%00010100,%00101001
  .byte %11100100,%00001010,%00010100,%00010001
  .byte %01000101,%01001010,%00000100,%01010001
  .byte %01000000,%01000001,%01000101,%01000001
  .byte %01000100,%01000101,%01000010,%00000001
  .byte %01000100,%00101000,%01000110,%01010101
  .byte %01000100,%01010100,%01000010,%10100101
  .byte %01010101,%01010101,%01010101,%01010101
nt1end:
  nt1_length = nt1end-nametable1

  ;.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
  ;.byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30
  ;.byte $30,$00,$00,$00,$00,$00,$30,$30,$30,$30,$30,$32,$32,$00,$00,$33
  ;.byte $30,$30,$30,$30,$30,$32,$32,$32,$00,$30,$30,$32,$32,$00,$00,$33
  ;.byte $30,$00,$32,$32,$00,$00,$30,$30,$00,$30,$30,$32,$32,$00,$00,$33
  ;.byte $30,$00,$30,$30,$30,$00,$30,$30,$00,$30,$30,$30,$30,$00,$00,$30
  ;.byte $33,$32,$30,$00,$00,$00,$30,$30,$00,$00,$32,$30,$30,$30,$00,$30
  ;.byte $33,$00,$00,$00,$30,$30,$30,$30,$00,$30,$30,$00,$00,$32,$32,$30
  ;.byte $33,$32,$30,$00,$00,$00,$32,$32,$00,$30,$30,$00,$00,$30,$00,$30
  ;.byte $30,$00,$30,$30,$30,$00,$32,$32,$00,$00,$30,$00,$30,$30,$00,$30
  ;.byte $30,$00,$00,$00,$30,$00,$00,$30,$30,$00,$30,$30,$30,$00,$00,$30
  ;.byte $30,$00,$30,$00,$30,$00,$30,$30,$30,$00,$00,$32,$00,$00,$00,$30
  ;.byte $30,$00,$30,$00,$00,$32,$32,$00,$30,$00,$30,$32,$30,$30,$30,$30
  ;.byte $30,$00,$30,$00,$30,$30,$30,$00,$30,$00,$00,$32,$32,$32,$30,$30
  ;.byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30

;Stage 1 attributes
attributes1:
  .byte %01010101, %01010101, %01010101, %01010101
  .byte %01010101, %01010101, %01010101, %01010101
  .byte %01010101, %01010101, %01010101, %01010101
  .byte %01010101, %01010101, %01010101, %01010101
  
;Stage 2 part 1
nametable2:
  .byte %00000000,%00000000,%00000000,%00000000
  .byte %01010101,%01010101,%01010101,%01010101
  .byte %01110110,%10000001,%01010101,%00000001
  .byte %01000110,%10000000,%00000100,%10100001
  .byte %01000101,%01010001,%01100000,%01010001
  .byte %01100001,%00000001,%01001010,%00010101
  .byte %01001001,%01010101,%01000001,%00000101
  .byte %01010001,%00000100,%01011001,%01000001
  .byte %01011010,%10000100,%10101001,%01011001
  .byte %01010101,%01000101,%01011001,%01011001
  .byte %01000000,%01000000,%10000001,%01000001
  .byte %01100101,%01010110,%10010101,%01000001
  .byte %01100101,%10000010,%00000101,%01010011
  .byte %01100000,%10000101,%01000010,%10010101
  .byte %01010101,%01010101,%01010101,%01010101
nt2end:
  nt2_length = nt2end-nametable2

;Stage 2 part 2
nametable3:
  .byte %00000000,%00000000,%00000000,%00000000
  .byte %01010101,%01010101,%01010101,%01010101
  .byte %01110010,%10000000,%00001010,%00101001
  .byte %01010101,%01010101,%01010101,%01011001
  .byte %01000100,%10000001,%00100101,%01001001
  .byte %01000100,%10010001,%01101000,%00000001
  .byte %01001010,%10010001,%01010101,%01100101
  .byte %01000101,%01011010,%10001000,%01100101
  .byte %01000100,%10101001,%01001001,%01000001
  .byte %01000100,%01010101,%01010101,%01010001
  .byte %01000100,%01010100,%00000101,%01011001
  .byte %01000100,%10000000,%01000110,%01101001
  .byte %11000100,%10010101,%01000110,%01100001
  .byte %01101000,%01010000,%01000010,%10100001
  .byte %01010101,%01010101,%01010101,%01010101
nt3end:
  nt3_length = nt3end-nametable3

;Stage 2 attributes
attributes2:
  .byte %10101010, %10101010, %10101010, %10101010
  .byte %10101010, %10101010, %10101010, %10101010
  .byte %10101010, %10101010, %10101010, %10101010
  .byte %10101010, %10101010, %10101010, %10101010

.segment "CHR"
.incbin "graphics.chr"