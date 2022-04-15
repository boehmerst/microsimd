
 LW  R1, R3, R4 ; --> R1 = 0x0EF
 ADD R5, R1, R2 ; --> R5 = 0x0F1 => HZD + WB FWD A
 ADD R1, R1, R2 ; --> R1 = 0x0F1 => WB FWD A
 ADD R1, R1, R3 ; --> R1 = 0x0F4 => EX FWD A
 ADD R1, R1, R4 ; --> R1 = 0x0F8 => EX FWD A
 NOP
 ADD R1, R1, R5 ; --> R1 = 0x1E9 => WB FWD A
 NOP
 NOP
 LW  R1, R3, R4 ; --> R1 = 0x0EF
 ADD R5, R2, R1 ; --> R5 = 0x0F1 => HZD + WB FWD B
 ADD R1, R2, R1 ; --> R1 = 0x0F1 => WB FWD B
 ADD R1, R3, R1 ; --> R1 = 0x0F4 => EX FWD B
 ADD R1, R4, R1 ; --> R1 = 0x0F8 => EX FWD B
 NOP
 ADD R1, R5, R1 ; --> R1 = 0x1E9 => WB FWD B

