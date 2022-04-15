
 BRI   12     ; --> PC=3(*4)
 BRID  16     ; --> PC=5(*4)
 NOP
 BRLID R1, 12 ; --> R1=PC=6(*4)
 NOP
 BRA   R31    ; --> PC=8(*4)
 BRAD  R4     ; --> PC=1(*4)
 NOP
 BRALD R0     ; --> R1=PC=0(*4)
 NOP
 
; Execution order: 0-3-6-1-5-8-...

