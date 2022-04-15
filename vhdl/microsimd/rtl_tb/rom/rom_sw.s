
 SB R20, R0, R4
 SB R20, R0, R5
 SB R20, R0, R6
 SB R20, R0, R7
 SH R20, R0, R4
 SH R20, R0, R6
 SW R20, R0, R4
 NOP
 NOP
 IMM $FFFF            ; Set IMM to negative
 ADDI R1, R20, $1000  ; Imm value must be negative: R1 = FFFF1000 + 0000F0F1 = 000000F1
 IMM 0                ; Set IMM to zero
 ADDI R1, R20, $F000  ; Imm value must be positive: R1 = 0000F000 + 0000F0F1 = 0001E0F1
 SWI R1, R10, 0       ; Fwd on REG D
 NOP
 IMM $FFFF            ; Set IMM to negative
 ADDI R1, R20, $1000  ; Imm value must be positive: R1 = FFFF1000 + 0000F0F1 = 000000F1
 NOP
 SWI R1, R10, 0       ; Store F1 to MEM[R10]
 
