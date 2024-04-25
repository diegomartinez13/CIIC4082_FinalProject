.include "constants.inc"
.include "header.inc"

.segment "ZEROPAGE"
;player1 variables 
player_x: .res 1
player_y: .res 1
player_dir: .res 1
player_frame_counter: .res 1
player_walkstate: .res 1

;player1 sprites
player_UL: .res 1
player_UR: .res 1
player_DL: .res 1
player_DR: .res 1

;controller variables
controller: .res 1

;collision variables
temp_collision: .res 1


;nametable variables
nametabe_select: .res 1

;scroll
scroll: .res 1
ppuctrl_settings: .res 1

sleeping: .res 1
.exportzp player_x, player_y, player_dir, player_frame_counter, player_walkstate
.exportzp player_UL, player_UR, player_DL, player_DR
.exportzp controller
.exportzp temp_collision, nametabe_select
.exportzp scroll, ppuctrl_settings

.segment "CODE"
.proc irq_handler ; Interrupt Request,
  RTI
.endproc

.import read_controller

.proc nmi_handler ; Non-Maskable Interrupt,
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ;copy sprite data to OAM
  LDA #$00 ; Load the accumulator with the hex value $00
  STA OAMADDR ; Set OAM address to $00. store the accumulator in the memory location $2003
  LDA #$02 ; Load the accumulator with the hex value $02
  STA OAMDMA ; This tells the PPU to initiate a high-speed transfer of the 256 bytes from $0200-$02ff into OAM
  
  ;set PPUCTRL
  LDA ppuctrl_settings
  STA PPUCTRL

  ;set scroll values
  LDA scroll ; X scroll first
  STA PPUSCROLL
  LDA #$00 ; Y scroll
  STA PPUSCROLL

  ;all done
  LDA #$00
  STA sleeping

  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTI ; Return from interrupt
.endproc

.import reset_handler

.export main
.proc main
  LDA #$00  ; NES screen is 256 pixels wide (0-255)
  STA scroll

  LDA #$00
  STA nametabe_select

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

load_background:
  ; Stage 1 Textures
  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$04
	STA PPUADDR
	LDX #$30       ; wall 1
	STX PPUDATA
  ; Stage 1 Textures
  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$24
	STA PPUADDR
	LDX #$30       ; wall 1
	STX PPUDATA
  ; Stage 1 Textures
  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$05
	STA PPUADDR
	LDX #$30       ; wall 1
	STX PPUDATA
  ; Stage 1 Textures
  LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$25
	STA PPUADDR
	LDX #$30       ; wall 1
	STX PPUDATA



  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$84
	STA PPUADDR
	LDX #$31      ; wall 2
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$a4
	STA PPUADDR
	LDX #$31      ; wall 2
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$85
	STA PPUADDR
	LDX #$31      ; wall 2
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$a5
	STA PPUADDR
	LDX #$31      ; wall 2
	STX PPUDATA

  ; Stage 1 Attributes
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$f1
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  ; Stage 2 Attributes
	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$e9
	STA PPUADDR
	LDA #%11111111
	STA PPUDATA

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Stage 1 Textures
  LDA PPUSTATUS
	LDA #$24
	STA PPUADDR
	LDA #$04
	STA PPUADDR
	LDX #$30       ; wall 1
	STX PPUDATA
  ; Stage 1 Textures
  LDA PPUSTATUS
	LDA #$24
	STA PPUADDR
	LDA #$24
	STA PPUADDR
	LDX #$30       ; wall 1
	STX PPUDATA
  ; Stage 1 Textures
  LDA PPUSTATUS
	LDA #$24
	STA PPUADDR
	LDA #$05
	STA PPUADDR
	LDX #$30       ; wall 1
	STX PPUDATA
  ; Stage 1 Textures
  LDA PPUSTATUS
	LDA #$24
	STA PPUADDR
	LDA #$25
	STA PPUADDR
	LDX #$30       ; wall 1
	STX PPUDATA



  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$84
	STA PPUADDR
	LDX #$31      ; wall 2
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$a4
	STA PPUADDR
	LDX #$31      ; wall 2
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$85
	STA PPUADDR
	LDX #$31      ; wall 2
	STX PPUDATA

  LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$a5
	STA PPUADDR
	LDX #$31      ; wall 2
	STX PPUDATA

  ; Stage 1 Attributes
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$f1
	STA PPUADDR
	LDA #%01010101
	STA PPUDATA

  ; Stage 2 Attributes
	LDA PPUSTATUS
	LDA #$27
	STA PPUADDR
	LDA #$e9
	STA PPUADDR
	LDA #%11111111
	STA PPUDATA

vblankwait: ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
    STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

  mainloop:
    JSR read_controller ; Read the controller

    ;update tiles after the DMA transfer
    JSR player_update
    JSR draw_player

  update_sleep:
    INC sleeping
    sleep:
      LDA sleeping
      BNE sleep

      JMP mainloop
.endproc

.proc player_update
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  ; check if player is moving left
  LDA controller ; load controller input
  AND #BTN_LEFT ; mask out all but the left button
  BEQ check_right ; if the left button is not pressed, check the right button
  ; if the branch not taken, we are moving left
  LDA player_x ; load player x pos into accumulator
  SEC
  SBC #$01 ; subtract 1 from player x
  STA player_x ; store player x pos back into memory

  BCC change_nametable0
  JMP no_change_nametable0
change_nametable0:
  LDA #$00
  STA nametabe_select
no_change_nametable0:
  ;check for collision
  ;top left corner
  LDX player_x
  LDA player_y
  CLC
  ADC #$01 ; add 1 to player y
  TAY

  JSR check_collision
  BEQ not_colliding_top_left ; if the branch is taken, we are not colliding
  ; if the branch is not taken, we are colliding
  INC player_x ; cancel the move left
  JMP check_right ; check the right button
not_colliding_top_left:
  ;bottom left corner
  LDX player_x
  LDA player_y ; load player y pos into accumulator
  CLC
  ADC #$10 ; add 16 to player y 
  TAY ; store player y pos in Y register

  JSR check_collision
  BEQ not_colliding_left ; if the branch is taken, we are not colliding
  ; if the branch is not taken, we are colliding
  INC player_x ; cancel the move left
  BEQ check_right ; check the right button
not_colliding_left:
  ; LDA scroll
  ; CMP #$00
  ; BEQ check_right
  DEC scroll ; move the screen to the right
  ; DEC scroll ; move the screen to the right
  ; DEC scroll ; move the screen to the right
  ; DEC scroll ; move the screen to the right
  ; DEC scroll ; move the screen to the right
  ; DEC scroll ; move the screen to the right
  ; DEC scroll ; move the screen to the right
  ; DEC scroll ; move the screen to the right
  JSR player_move_left ; start animation moving left

check_right:
  LDA controller
  AND #BTN_RIGHT
  BEQ check_up ; if the right button is not pressed, check the up button
  ; if the branch is not taken, we are moving right
  LDA player_x
  CLC
  ADC #$01
  STA player_x
  
  BCS change_nametable1
  JMP no_change_nametable1

change_nametable1:
  LDA #$01
  STA nametabe_select
no_change_nametable1:
  ;check for collision
  LDA player_x ; load player x pos into accumulator
  CLC
  ADC #$0F ; add 7 to player x pos
  TAX ; store player x pos in X register

  LDA player_y
  CLC
  ADC #$01
  TAY

  JSR check_collision
  BEQ not_colliding_top_right ; if the branch is taken, we are not colliding
  ; if the branch is not taken, we are colliding
  DEC player_x ; cancel the move right
  JMP check_up ; check the up button
not_colliding_top_right:
  ;bottom right corner
  LDA player_x ; load player x pos into accumulator
  CLC
  ADC #$0F ; add 15 to player x pos
  TAX ; store player x pos in X register
  LDA player_y ; load player y pos into accumulator
  CLC
  ADC #$10 ; add 16 to player y pos
  TAY ; store player y pos in Y register

  JSR check_collision
  BEQ not_colliding_right ; if the branch is taken, we are not colliding
  ; if the branch is not taken, we are colliding
  DEC player_x ; cancel the move right
  BEQ check_up ; check the up button
not_colliding_right:
  LDA scroll
  CMP #$FF
  BEQ check_up
  INC scroll ; move the screen to the left
  ; INC scroll ; move the screen to the left
  ; INC scroll ; move the screen to the left
  ; INC scroll ; move the screen to the left
  ; INC scroll ; move the screen to the left
  ; INC scroll ; move the screen to the left
  ; INC scroll ; move the screen to the left
  ; INC scroll ; move the screen to the left
  JSR player_move_right

check_up:
  LDA controller
  AND #BTN_UP
  BEQ check_down ; if the up button is not pressed, check the down button
  ; if the branch is not taken, we are moving up
  DEC player_y ; move player up

  ;check for collision
  ;up left corner
  LDX player_x
  LDA player_y
  CLC
  ADC #$01
  TAY

  JSR check_collision
  BEQ not_colliding_up_left ; if the branch is taken, we are not colliding
  ; if the branch is not taken, we are colliding
  INC player_y ; cancel the move up
  JMP check_down ; check the down button
not_colliding_up_left:
  ;up right corner
  LDA player_x ; load player x pos into accumulator
  CLC
  ADC #$0F; add 7 to player x pos
  TAX
  LDA player_y
  CLC
  ADC #$01
  TAY

  JSR check_collision
  BEQ not_colliding_up ; if the branch is taken, we are not colliding
  ; if the branch is not taken, we are colliding
  INC player_y ; cancel the move up
  JMP check_down ; check the down button
not_colliding_up:
  JSR player_move_up

check_down:
  LDA controller
  AND #BTN_DOWN
  BEQ done_checking ; if the down button is not pressed, we are done checking
  ; if the branch is not taken, we are moving down
  INC player_y ; move player down

  ;check for collision
  ;down left corner
  LDX player_x
  LDA player_y ; load player y pos into accumulator
  CLC
  ADC #$10 ; add 16 to player y pos
  TAY ; store player y pos in Y register

  JSR check_collision
  BEQ not_colliding_down_left; if the branch is taken, we are not colliding
  ; if the branch is not taken, we are colliding
  DEC player_y ; cancel the move down
  JMP done_checking ; done checking
not_colliding_down_left:
  ;down right corner
  LDA player_x ; load player x pos into accumulator
  CLC
  ADC #$0F ; add 7 to player x pos
  TAX ; store player x pos in X register
  LDA player_y ; load player y pos into accumulator
  CLC
  ADC #$10 ; add 16 to player y pos
  TAY ; store player y pos in Y register

  JSR check_collision
  BEQ not_colliding_down ; if the branch is taken, we are not colliding
  ; if the branch is not taken, we are colliding
  DEC player_y ; cancel the move down
  JMP done_checking ; done checking
not_colliding_down:
  JSR player_move_down
  JMP done_checking
done_checking:
  PLA ; Done with updates, restore registers
  TAY ; and return to where we called this
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc check_collision
check_collision:
  ; check for collisions
  TXA ; save player x in accumulator (x/64 = tile x)
  LSR
  LSR
  LSR
  LSR
  LSR
  LSR ; X = X / 64

  STA temp_collision ; store player x in temp_collision

  TYA ; save player y in accumulator (y/8 * 4 = tile y)
  LSR
  LSR
  LSR ; Y = Y / 8
  ASL
  ASL ; Y = Y * 4

  CLC
  ADC temp_collision ; X + Y
  TAY ; store Byte index in Y register

  TXA ; get player x back in accumulator (x/8 AND %0111 = bit mask index)
  LSR
  LSR
  LSR ; X = X / 8
  AND #%0111 ; X = X AND %0111
  TAX ; store bit mask index in X register

  LDA nametabe_select
  CMP #$01
  BEQ check_collision_map2

  LDA CollitionMap1, Y ; load byte from coalition map
  AND BitMask, x ; AND byte with bit mask
  RTS ; return from subroutine
  check_collision_map2:
  LDA CollitionMap2, y ; load byte from coalition map
  AND BitMask, x ; AND byte with bit mask
  RTS ; return from subroutine
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

CollitionMap1:
  .byte %11111111, %11111111, %11111111, %11111111 ;0
  .byte %11111111, %11111111, %11111111, %11111111 ;1
  .byte %11111111, %11111111, %11111111, %11111111 ;2
  .byte %11111111, %11111111, %11111111, %11111111 ;3
  .byte %11000000, %00000000, %11111111, %00000011 ;4
  .byte %11000000, %00000000, %11111111, %00000011 ;5
  .byte %11001111, %11110000, %00110000, %00110011 ;6
  .byte %11001111, %11110000, %00110000, %00110011 ;7
  .byte %11000000, %00001100, %00110000, %11000011 ;8
  .byte %11000000, %00001100, %00110000, %11000011 ;9

  .byte %11001111, %00111100, %00110000, %11001111 ;10
  .byte %11001111, %00111100, %00110000, %11001111 ;11
  .byte %11000011, %00001100, %00000000, %11001111 ;12
  .byte %11000011, %00001100, %00000000, %11001111 ;13
  .byte %11111111, %11000000, %00110000, %11000000 ;14
  .byte %11111111, %11000000, %00110000, %11000000 ;15
  .byte %11000000, %00000011, %00111100, %11111111 ;16
  .byte %11000000, %00000011, %00111100, %11111111 ;17
  .byte %11001100, %11000011, %00111100, %00000011 ;18
  .byte %11001100, %11000011, %00111100, %00000011 ;19

  .byte %11001100, %11000011, %00111111, %11110011 ;20
  .byte %11001100, %11110011, %00111111, %11110011 ;21
  .byte %11001100, %11110011, %00111111, %11110011 ;22
  .byte %11001100, %11110011, %00111111, %11110011 ;23
  .byte %11001111, %11000011, %00111111, %11110011 ;24
  .byte %11001111, %11000011, %00000011, %11110011 ;25
  .byte %11000000, %00000011, %00000000, %00000011 ;26
  .byte %11000000, %00000011, %11110000, %00000011 ;27
  .byte %11111111, %11111111, %11111111, %11111111 ;28
  .byte %11111111, %11111111, %11111111, %11111111 ;29


CollitionMap2:
  .byte %11111111, %11111111, %11111111, %11111111 ;0
  .byte %11111111, %11111111, %11111111, %11111111 ;1
  .byte %11111111, %11111111, %11111111, %11111111 ;2
  .byte %11111111, %11111111, %11111111, %11111111 ;3
  .byte %11000000, %00001111, %11111100, %00000011
  .byte %11000000, %00001111, %11111100, %00000011
  .byte %11111111, %11000000, %00111100, %00000000
  .byte %11111111, %11000000, %00111100, %00000000
  .byte %11000000, %00001111, %00111100, %00000011
  .byte %11000000, %00001111, %00111100, %00000011

  .byte %11001111, %11001111, %00111111, %11000011
  .byte %11001111, %11001111, %00111111, %11000011
  .byte %11001100, %00001111, %00000011, %11110011
  .byte %11001100, %00001111, %00000011, %11110011
  .byte %00000000, %11111111, %00111100, %00000011
  .byte %00000000, %11111111, %00111100, %00000011
  .byte %11001100, %00000000, %00111100, %00110011
  .byte %11001100, %00000000, %00111100, %00110011
  .byte %11001111, %11000000, %00001100, %11110011
  .byte %11001111, %11000000, %00001100, %11110011

  .byte %11000000, %11000011, %11001111, %11000011
  .byte %11000000, %11000011, %11001111, %11000011
  .byte %11001100, %11001111, %11000000, %00000011
  .byte %11001100, %11001111, %11000000, %00000011
  .byte %11001100, %00000000, %11001100, %11111111
  .byte %11001100, %00000000, %11001100, %11111111
  .byte %11001100, %11111100, %11000000, %00001111
  .byte %11001100, %11111100, %11000000, %00001111
  .byte %11111111, %11111111, %11111111, %11111111
  .byte %11111111, %11111111, %11111111, %11111111



BitMask:
  .byte %10000000
  .byte %01000000
  .byte %00100000
  .byte %00010000
  .byte %00001000
  .byte %00000100
  .byte %00000010
  .byte %00000001

.segment "CHR"
.incbin "graphics.chr"