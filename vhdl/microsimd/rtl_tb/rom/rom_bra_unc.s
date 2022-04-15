
 BR    R12     ; --> PC=3(*4)
 BRD   R16     ; --> PC=5(*4)
 NOP
 BRLD  R1, R12 ; --> R1=PC=6(*4)
 NOP
 BRA   R31     ; --> PC=8(*4)
 BRAD  R4      ; --> PC=1(*4)
 NOP
 BRALD R1, R0  ; --> R1=PC=0(*4)
 NOP
 
; Execution order: 0-3-6-1-5-8-...


