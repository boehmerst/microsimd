
 ORI      R1, R0, 2048
 ORI      R2, R0, 10

 SW       R2, R1, R0

 NOP
 NOP

 IMM      $DEAD
 ORI      R2, R0, $BEAF
 VMOVA.W  V0, R2
 VSTR.W   V0, R2, 0

 NOP
 NOP
 NOP

