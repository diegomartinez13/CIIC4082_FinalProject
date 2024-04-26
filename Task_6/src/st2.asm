.include "constants.inc"
.import nametable2
.importzp temp_addr, temp_1, temp
.segment "CODE"

.export Unpack2
.proc Unpack2
	LDX #$00
	STX temp

	LDA #$10        ; Load the low byte 
	STA temp_addr       ; Store low byte
	LDA #$00        ; Load the high byte 
	STA temp_addr+1     ; Store high byte

	LDA #$00
	STA temp_1

  LDA PPUSTATUS
  LDA #$20
  STA PPUADDR    
  LDA #$00
  STA PPUADDR  

  OuterLoop:
  LDY #$00

  LoopAgain:   
  LDX temp
  Loop:  
    LDA nametable2,X       
    STA PPUDATA 
    LDA nametable2,X       
    STA PPUDATA    
    INX           
    CPX temp_addr 
    BNE Loop
  INY
  CPY #$02
  BNE LoopAgain
  
  LDA temp_addr       ; Load the low byte 
  CLC             ; Clear the carry flag before addition
  ADC #$10      ; Add 16 to the accumulator
  STA temp_addr       ; Store the result 

  LDA temp_addr+1     ; Load the high byte 
  ADC #$00        ; Add any carry from the previous addition
  STA temp_addr+1     ; Store the result 

  STX temp

  LDA temp_1
  CLC       ; Clear the carry flag to ensure clean addition
  ADC #$01  ; Add with carry the value 1 to the accumulator
  STA temp_1

  CMP #$0F 
  BEQ END

  JMP OuterLoop

  END:
	LDX #$00
	LDA PPUSTATUS    ; Reset the address latch
	LDA #$23         ; High byte of $23C0
	STA PPUADDR
	LDA #$C0         ; Low byte of $23C0
	STA PPUADDR

  load_attributes:
  LDX #%11111111
  STX PPUDATA
  CLC
  ADC #$01
  CMP #$00
  BNE load_attributes
  
  RTS
.endproc