.include "constants.inc"
.importzp myb, mxb, index, curbit, curtile, nxtblk, btcnt, addrhi, row, temp
.import nametable0, nt0_length
.segment "CODE"

.export Unpack0
.proc Unpack0
  LDX #0               ; MEGAindex for packed data in nametable
  STX nxtblk           ; Keeps track of tiles to be printed
  STX btcnt            ; Keeps track of how many bytes have been processed
  STX row              ; Keeps track of how many rows have been completed

  LDA #$20             
  STA PPUADDR          ; Set PPUADDR to start of nametable
  STA addrhi           ; Stores Hi bit of PPUADDR since it will be manipulated for printing
  LDA #$00          
  STA PPUADDR          ; Lo bit of PPUADDR

outerloop0:
  TXA
  CMP #61
  BEQ jump

  TXA  
  LSR
  LSR
  STA myb              ; Divide X by 4 to obtain MYb index

  TXA
  AND #$03
  STA mxb              ; Performs X % 4 to obtain MXb index

  LDA myb
  ASL
  ASL
  ASL
  ASL
  ASL
  ASL
  STA myb              ; Perform 64 * MYb

  LDA mxb
  ASL
  ASL
  ASL
  STA mxb              ; Perform 8 * MXb

  LDA mxb
  ADC myb              ; Perform MYb + MXb
  STA index            ; Result is the index of the first tile of the byte
  JMP inloop0

jump:
  JMP exit

inloop0:
    LDA nametable0, X  ; Load byte X and obtain block 0
    AND #%11000000     ; Isolate first bit pair by masking
    LSR A
    LSR A
    LSR A
    LSR A
    STA curbit         ; Store bit for decoding process
    JSR decode0

    LDA nametable0, X  ; Load byte X and obtain block 1
    AND #%00110000     ; Isolate second bit pair by masking
    LSR A
    LSR A
    STA curbit         ; Store bit for decoding process
    JSR decode0

    LDA nametable0, X  ; Load byte X and obtain block 2
    AND #%00001100     ; Isolate third bit pair by masking 
    LSR A
    STA curbit         ; Store bit for decoding process
    JSR decode0

    LDA nametable0, X  ; Load byte X and obtain block 3
    AND #%00000011     ; Isolate fourth bit pair by masking
    STA curbit         ; Store bit for decoding process
    JSR decode0

    LDY btcnt
    INY                ; Once 4 bits are processed, we have completed 1 byte
    STY btcnt
    CPY #4             ; Compare amount of processed bytes with #4
    BEQ setcntrs       ; If 4 have been processed, we reset and modify some counters
    JMP inloop0        ; If not yet, restart inner loop

setcntrs:
    LDY #0
    STY btcnt          ; Reset btcnt to #0
    LDY row
    INY                ; with a row completed, increase its counter
    STY row

    LDA nxtblk         ; Load next block to be processed. At row 0, next block would start at 32
    CLC
    ADC #$20           ; Add 32 to block index to set address to start of next row
    STA nxtblk

    LDA row            
    AND #$03           ; After adding 1 to row, perform row % 4
    CMP #0              
    BEQ setaddr        ; If 4 rows have been completed, we must change the hi bit of PPUADDR
    INX                ; Once completed, increase MEGAindex X for next iteration
    JMP outerloop0

setaddr:
    LDY addrhi         
    INY                ; Load hi bit of address and add 1
    STY PPUADDR        ; Store in PPUADDR
    STY addrhi         ; Store in variable for later use
    LDY nxtblk         
    STY PPUADDR        ; Store lo bit in PPUADDR
    RTS

decode0:
  ; Map X (2-bit value) to a tile, print or store for comparison
  ; Example mapping
  LDA curbit
  CMP #%00
  BEQ is_empty
  CMP #%01
  BEQ is_wall
  CMP #%10
  BEQ is_transparent
  CMP #%11
  BEQ is_block
  RTS

is_empty:
  LDA #$30
  JMP print
is_wall:
  LDA #$30
  JMP print
is_transparent:
  LDA #$32
  JMP print
is_block:
  LDA #$33
  JMP print

print:
  STA PPUDATA          ; Print the first byte of the tile
  LDY nxtblk           ; Load the next block to be processed
  STY curtile          ; Store the current tile
  INY                  ; Increment to get the address of the next tile
  STA PPUDATA          ; Print the second byte of the tile
  INY                  ; Increment to move to the next byte of the next tile
  STY nxtblk           ; Store the next block to be processed

  LDY addrhi           ; Load the high byte of the address
  CLC
  ADC #32              ; Increment it by 32 (since each row has 32 tiles)
  TAY
  STY PPUADDR          ; Store the updated high byte of the address

  LDA curtile          ; Load the current tile index
  STA temp             ; Store it temporarily
  STY PPUADDR          ; Store the high byte of the address
  LDY temp             ; Reload the current tile index
  STA PPUDATA          ; Print the first byte of the next tile
  STA PPUDATA          ; Print the second byte of the next tile

  LDY addrhi           ; Load the high byte of the address again
  STY PPUADDR          ; Store it
  LDY nxtblk           ; Load the next block to be processed again
  STY PPUADDR          ; Store it
  RTS                  ; Return from the subroutine

exit:
  RTS
.endproc
