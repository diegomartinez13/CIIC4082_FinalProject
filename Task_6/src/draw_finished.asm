.include "constants.inc"
.importzp temp, temp_1, temp_addr, nametable_select, game_over, victory
.import nametable_gameover, nametable_victory
.segment "CODE"

.export draw_finished
.proc draw_finished
  ; erase the screen attributes
    LDX #$00
    LDA PPUSTATUS    ; Reset the address latch
    LDA #$23         ; High byte of $23C0
    STA PPUADDR
    LDA #$C0         ; Low byte of $23C0
    STA PPUADDR

    load_attributes:
    LDX #%00000000
    STX PPUDATA
    CLC
    ADC #$01
    CMP #$00
    BNE load_attributes
    
    LDX #$00
    STX temp

    LDA #$10        ; Load the low byte 
    STA temp_addr       ; Store low byte
    LDA #$00        ; Load the high byte (0, since 10 is less than 256)
    STA temp_addr+1     ; Store high byte

    LDA #$00
    STA temp_1

    ;check if gameover or victory
    LDA game_over
    CMP #$01
    BEQ draw_gameover
    LDA victory
    CMP #$01
    BEQ draw_victory
    RTS

  draw_gameover:
    ;check nametable_select
    LDA nametable_select
    CMP #$00
    BEQ draw_gameover_0
    JMP draw_gameover_1

  draw_gameover_0:
    LDA PPUSTATUS
    LDA #$20
    STA PPUADDR    
    LDA #$00
    STA PPUADDR
    JMP OuterLoop_gameover
  draw_gameover_1:
    LDA PPUSTATUS
    LDA #$24
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    OuterLoop_gameover:
    LDY #$00

    LoopAgain_gameover:   
    LDX temp
    Loop_gameover:  
      LDA nametable_gameover,X       
      STA PPUDATA 
      LDA nametable_gameover,X       
      STA PPUDATA    
      INX           
      CPX temp_addr 
      BNE Loop_gameover
    INY
    CPY #$02
    BNE LoopAgain_gameover
    
    LDA temp_addr       ; Load the low byte of ztemp
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

    JMP OuterLoop_gameover

  
  draw_victory:
    ;check nametable_select
    LDA nametable_select
    CMP #$00
    BEQ draw_victory_0
    JMP draw_victory_1

  draw_victory_0:
    LDA PPUSTATUS
    LDA #$20
    STA PPUADDR    
    LDA #$00
    STA PPUADDR
    JMP OuterLoop_victory
  draw_victory_1:
    LDA PPUSTATUS
    LDA #$24
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    OuterLoop_victory:
    LDY #$00

    LoopAgain_victory:   
    LDX temp
    Loop_victory:  
      LDA nametable_victory,X       
      STA PPUDATA 
      LDA nametable_victory,X       
      STA PPUDATA    
      INX           
      CPX temp_addr 
      BNE Loop_victory
    INY
    CPY #$02
    BNE LoopAgain_victory
    
    LDA temp_addr       ; Load the low byte of ztemp
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

    JMP OuterLoop_victory

  END:
  RTS
.endproc
