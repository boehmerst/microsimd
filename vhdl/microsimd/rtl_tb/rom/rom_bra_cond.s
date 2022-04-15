
 BEQ R1,  R4   ; --> PC=1(*4)
 BEQ R0,  R8   ; --> PC=3(*4)
 BLT R21, R12  ; --> PC=5(*4)
 BNE R1,  R21  ; --> PC=2(*4)
 BGT R0,  R12  ; --> PC=7(*4)
 BLE R0,  R21  ; --> PC=4(*4)
 BGT R1,  R22  ; --> PC=0(*4)
 BGE R1,  R21  ; --> PC=6(*4)
 
; Execution order: 0 -> 1 -> 3 -> 2 -> 5 -> 4 -> 7 -> 6 -> 0

