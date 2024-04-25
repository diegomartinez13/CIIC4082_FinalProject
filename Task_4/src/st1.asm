.include "constants.inc"
.import nametable1, nt1_length
.segment "CODE"

.export Unpack1
.proc Unpack1
  LDX #0               ; Index for packed data
  LDY #0               ; Initialize counter for length check

loop1:
  LDA nametable1, X   ; Load a byte of packed data
  INX
  INY

  ; Decode each pair 
  LSR A
  LSR A
  TAX                  ; Save the first tile to X
  JSR decode1           ; Decode and optionally compare
  TXA                  ; Restore A from X

  LSR A
  LSR A
  TAX
  JSR decode1
  TXA

  LSR A
  LSR A
  TAX
  JSR decode1
  TXA

  LSR A
  LSR A
  TAX
  JSR decode1

  CPX nt1_length  ; Check if finished
  BCC loop1

  RTS

decode1:
  ; Map X (2-bit value) to a tile, print or store for comparison
  ; Example mapping
  CPX #%00
  BEQ is_empty
  CPX #%01
  BEQ is_wall
  CPX #%10
  BEQ is_transparent
  CPX #%11
  BEQ is_block

is_empty:
  LDA #$00
  STA PPUDATA
  RTS
is_wall:
  LDA #$30
  STA PPUDATA
  RTS
is_transparent:
  LDA #$32
  STA PPUDATA
  RTS
is_block:
  LDA #$33
  STA PPUDATA
  RTS
.endproc