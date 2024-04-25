.include "constants.inc"
.import nametable3, nt3_length
.segment "CODE"

.export Unpack3
.proc Unpack3
  LDX #0               ; Index for packed data
  LDY #0               ; Initialize counter for length check

loop3:
  LDA nametable3, X   ; Load a byte of packed data
  INX
  INY

  ; Decode each pair 
  LSR A
  LSR A
  TAX                  ; Save the first tile to X
  JSR decode3           ; Decode and optionally compare
  TXA                  ; Restore A from X

  LSR A
  LSR A
  TAX
  JSR decode3
  TXA

  LSR A
  LSR A
  TAX
  JSR decode3
  TXA

  LSR A
  LSR A
  TAX
  JSR decode3

  CPX nt3_length  ; Check if finished
  BCC loop3

  RTS

decode3:
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
  LDA #$35
  STA PPUDATA
  RTS
is_transparent:
  LDA #$37
  STA PPUDATA
  RTS
is_block:
  LDA #$38
  STA PPUDATA
  RTS
.endproc