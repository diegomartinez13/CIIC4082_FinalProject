.include "constants.inc"
.include "header.inc"
.import Unpack0, Unpack1, Unpack2, Unpack3

.segment "ZEROPAGE"
sleeping: .res 1

;variables
changebg: .res 1
controller: .res 1
scroll: .res 1

temp: .res 1
temp_1: .res 1
temp_tile: .res 1
temp_addr: .res 1

map_select: .res 1

ppuctrl_settings: .res 1
.exportzp controller, temp, map_select
.export nametable0, nametable1, nametable2, nametable3, nt0_length, nt1_length, nt2_length, nt3_length
.exportzp temp_1, temp_tile, temp_addr

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
  LDA #0  ; NES screen is 256 pixels wide (0-255)
  STA scroll 

  ; Write a pallette to the PPU
  LDX PPUSTATUS ; Clear VBlank flag
  LDX #$3f ; load the X register with the hex value $3f
  STX PPUADDR ; store the X register in the memory location $2006
  LDX #$00 ; load the X register with the hex value $00
  STX PPUADDR ; store the X register in the memory location $2006
  load_pallette:
    LDA pallettes, X ; Load the accumulator with the value at the address of pallettes + X
    STA PPUDATA ; store the accumulator in the memory location $2007
    INX ; Increment the X register
    CPX #$20 ; Compare the X register to the hex value $20 (32)
    BNE load_pallette ; Branch if not equal
  
  load_stages:
    LDA map_select
    CMP #$00
    BEQ stage1          ; Load Stage 1 if A is not pressed
    JMP stage2          ; If pressed, load stage 2

  stage1:
    ; Load stage 1 part 1
    LDX PPUSTATUS
    JSR Unpack0   ; unpack nametable for part 1
    JSR Unpack1   ; unpack nametable for part 2
    JMP vblankwait

  stage2:
    ; Load stage 2 part 1
    LDX PPUSTATUS
    JSR Unpack2   ; unpack nametable for part 1
    JSR Unpack3   ; unpack nametable for part 2
    JMP vblankwait

  vblankwait: ; wait for another vblank before continuing
    BIT PPUSTATUS
    BPL vblankwait

    LDA #%10001000  ; turn on NMIs, sprites use first pattern table
    STA ppuctrl_settings
    STA PPUCTRL
    LDA #%00011110  ; turn on screen
    STA PPUMASK

  mainloop:
    JSR read_controller ; Read the controller

    ;update tiles after the DMA transfer
    JSR update_background

    JSR update_map_select

  update_sleep:
    INC sleeping
    sleep:
      LDA sleeping
      BNE sleep

      JMP mainloop
.endproc

.proc update_map_select
  LDA controller       ; Load the controller state
  AND #BTN_A           ; Mask all bits except for the A button
  BEQ exit             ; If A button is not pressed, exit

  LDA map_select       ; Load the current value of map_select
  BEQ prepare_stage2   ; If map_select is 0, prepare to switch to stage 2
  CMP #$01
  BEQ prepare_stage1   ; If map_select is 1, prepare to switch to stage 1
  JMP exit

prepare_stage2:
  JSR update_stage2    ; Call subroutine to update to stage 2
  LDA #$01
  STA map_select       ; Update map_select to indicate stage 2
  JMP exit

prepare_stage1:
  JSR update_stage1    ; Call subroutine to update to stage 1
  LDA #$00
  STA map_select       ; Update map_select to indicate stage 1
  JMP exit

update_stage2:
  LDA #$00
  STA PPUCTRL
  STA PPUMASK

  JSR Unpack2          ; unpack nametable for part 1
  JSR Unpack3          ; unpack nametable for part 2

  LDA #%10001000       ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110       ; Turn on rendering, show sprites and background
  STA PPUMASK
  RTS                  ; Return from subroutine

update_stage1:
  LDA #$00
  STA PPUCTRL
  STA PPUMASK
  LDX PPUSTATUS        ; Read PPU status to clear VBLANK flag
  JSR Unpack0          ; unpack nametable for part 1
  JSR Unpack1          ; unpack nametable for part 2

  LDA #%10001000       ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110       ; Turn on rendering, show sprites and background
  STA PPUMASK
  RTS                  ; Return from subroutine

exit:
  RTS                  ; Return from subroutine
.endproc

.proc update_background
  ; check if the background needs to be changed to the left
  LDA controller
  AND #BTN_LEFT
  BEQ not_left

  LDA scroll
  CMP #0
  BEQ not_left
  INC scroll

  not_left:
    ; check if the background needs to be changed to the right
    LDA controller
    AND #BTN_RIGHT
    BEQ not_right

    LDA scroll
    CMP #255
    BEQ not_right
    DEC scroll

  not_right:
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
pallettes:
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

;Stage 1 part 1
nametable0:
  ;Packaged nametable. Every byte represents 4 2x2 tile blocks in a row
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
  .byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30
  .byte $30,$00,$00,$00,$00,$00,$00,$00,$30,$30,$30,$30,$00,$00,$00,$30
  .byte $30,$00,$30,$30,$30,$30,$00,$00,$00,$30,$00,$00,$32,$30,$00,$30
  .byte $30,$00,$00,$00,$00,$32,$30,$00,$00,$30,$00,$00,$30,$00,$00,$30
  .byte $30,$00,$30,$30,$00,$30,$30,$00,$00,$30,$00,$00,$30,$00,$30,$30
  .byte $30,$00,$00,$30,$00,$00,$30,$00,$32,$32,$00,$00,$30,$32,$30,$33
  .byte $30,$30,$30,$30,$30,$00,$00,$00,$00,$30,$00,$00,$30,$32,$00,$33
  .byte $30,$00,$00,$00,$00,$00,$00,$30,$00,$30,$30,$00,$30,$30,$30,$33
  .byte $30,$00,$30,$32,$30,$00,$00,$30,$00,$30,$30,$00,$00,$00,$00,$30
  .byte $30,$00,$30,$00,$30,$30,$00,$30,$00,$30,$30,$30,$30,$30,$00,$30
  .byte $30,$00,$30,$00,$30,$30,$00,$30,$00,$30,$30,$30,$30,$30,$00,$30
  .byte $30,$00,$30,$30,$30,$32,$32,$30,$00,$00,$00,$30,$30,$30,$32,$30
  .byte $30,$33,$00,$00,$00,$32,$32,$30,$30,$30,$00,$00,$00,$32,$32,$30
  .byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30
nt0end: 
  nt0_length = nt0end-nametable0


;Stage 1 part 2
nametable1:
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
  .byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30
  .byte $30,$00,$00,$00,$00,$00,$30,$30,$30,$30,$30,$32,$32,$00,$00,$33
  .byte $30,$30,$30,$30,$30,$32,$32,$32,$00,$30,$30,$32,$32,$00,$00,$33
  .byte $30,$00,$32,$32,$00,$00,$30,$30,$00,$30,$30,$32,$32,$00,$00,$33
  .byte $30,$00,$30,$30,$30,$00,$30,$30,$00,$30,$30,$30,$30,$00,$00,$30
  .byte $33,$32,$30,$00,$00,$00,$30,$30,$00,$00,$32,$30,$30,$30,$00,$30
  .byte $33,$00,$00,$00,$30,$30,$30,$30,$00,$30,$30,$00,$00,$32,$32,$30
  .byte $33,$32,$30,$00,$00,$00,$32,$32,$00,$30,$30,$00,$00,$30,$00,$30
  .byte $30,$00,$30,$30,$30,$00,$32,$32,$00,$00,$30,$00,$30,$30,$00,$30
  .byte $30,$00,$00,$00,$30,$00,$00,$30,$30,$00,$30,$30,$30,$00,$00,$30
  .byte $30,$00,$30,$00,$30,$00,$30,$30,$30,$00,$00,$32,$00,$00,$00,$30
  .byte $30,$00,$30,$00,$00,$32,$32,$00,$30,$00,$30,$32,$30,$30,$30,$30
  .byte $30,$00,$30,$00,$30,$30,$30,$00,$30,$00,$00,$32,$32,$32,$30,$30
  .byte $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30

nt1end:
  nt1_length = nt1end-nametable1

;Stage 1 attributes
attributes1:
  .byte %01010101, %01010101, %01010101, %01010101
  .byte %01010101, %01010101, %01010101, %01010101
  .byte %01010101, %01010101, %01010101, %01010101
  .byte %01010101, %01010101, %01010101, %01010101
  
;Stage 2 part 1
nametable2:
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
  .byte $35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35
  .byte $35,$38,$35,$37,$37,$00,$00,$35,$35,$35,$35,$35,$00,$00,$00,$35
  .byte $35,$00,$35,$37,$37,$00,$00,$00,$00,$00,$35,$00,$37,$37,$00,$35
  .byte $35,$00,$35,$35,$35,$35,$00,$35,$35,$37,$00,$00,$35,$35,$00,$35
  .byte $35,$37,$00,$35,$00,$00,$00,$35,$35,$00,$37,$37,$00,$35,$35,$35
  .byte $35,$00,$37,$35,$35,$35,$35,$35,$35,$00,$00,$35,$00,$00,$35,$35
  .byte $35,$35,$00,$35,$00,$00,$35,$00,$35,$35,$37,$35,$35,$00,$00,$35
  .byte $35,$35,$37,$37,$37,$00,$35,$00,$37,$37,$37,$35,$35,$35,$37,$35
  .byte $35,$35,$35,$35,$35,$00,$35,$35,$35,$35,$37,$35,$35,$35,$37,$35
  .byte $35,$00,$00,$00,$35,$00,$00,$00,$37,$00,$00,$35,$35,$00,$00,$35
  .byte $35,$37,$35,$35,$35,$35,$35,$37,$37,$35,$35,$35,$35,$00,$00,$35
  .byte $35,$37,$35,$35,$37,$00,$00,$37,$00,$00,$35,$35,$35,$35,$00,$38
  .byte $35,$37,$00,$00,$37,$00,$35,$35,$35,$00,$00,$37,$37,$35,$35,$35
  .byte $35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35
nt2end:
  nt2_length = nt2end-nametable2

;Stage 2 part 2
nametable3:
  .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 
  .byte $35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35
  .byte $35,$38,$00,$37,$37,$00,$00,$00,$00,$00,$37,$37,$00,$37,$37,$35
  .byte $35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$37,$35
  .byte $35,$00,$35,$00,$37,$00,$00,$35,$00,$37,$35,$35,$35,$00,$37,$35
  .byte $35,$00,$35,$00,$37,$35,$00,$35,$35,$37,$37,$00,$00,$00,$00,$35
  .byte $35,$00,$37,$37,$37,$35,$00,$35,$35,$35,$35,$35,$35,$37,$35,$35
  .byte $35,$00,$35,$35,$35,$35,$37,$37,$37,$00,$37,$00,$35,$37,$35,$35
  .byte $35,$00,$35,$00,$37,$37,$37,$35,$35,$00,$37,$35,$35,$00,$00,$35
  .byte $35,$00,$35,$00,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$00,$35
  .byte $35,$00,$35,$00,$35,$35,$35,$00,$00,$00,$35,$35,$35,$35,$37,$35
  .byte $35,$00,$35,$00,$37,$00,$00,$00,$35,$00,$35,$37,$35,$37,$37,$35
  .byte $38,$00,$35,$00,$37,$35,$35,$35,$35,$00,$35,$37,$35,$37,$00,$35
  .byte $35,$37,$37,$00,$35,$35,$00,$00,$35,$00,$00,$37,$37,$37,$00,$35
  .byte $35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35,$35
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