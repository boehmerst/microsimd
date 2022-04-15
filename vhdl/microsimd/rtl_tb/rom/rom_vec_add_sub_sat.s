 ;-------------------------------------
 ; 8 bit saturation test1
 ;-------------------------------------
 IMM        $FFFF
 ORI        R1, R0, $FFFF
 VMOVA.W    V0, R1

 IMM        $0303
 ORI        R2, R0, $0303
 VMOVA.W    V2, R2

 VADD.W.I8  V4, V0, V2                   ; no saturation -> should overflow
 VQADD.W.U8 V6, V0, V2                   ; unsigned saturate -> should saturate to 0xFFFFFFF
 VQADD.W.S8 V8, V0, V2                   ; signed saturate -> sould not saturate
 
 VSUB.W.I8  V4, V0, V2                   ; should not saturation
 VQSUB.W.U8 V6, V0, V2                   ; should not saturation
 VQSUB.W.S8 V8, V0, V2                   ; should not saturation
 
 ;-------------------------------------
 ; 8 bit saturation test2
 ;-------------------------------------
 IMM        $0000
 ORI        R1, R0, $0000
 VMOVA.W    V0, R1

 VADD.W.I8  V4, V0, V2                   ; no saturation -> no overflow
 VQADD.W.U8 V6, V0, V2                   ; unsigned saturate -> no overflow
 VQADD.W.S8 V8, V0, V2                   ; signed saturate -> no overflow
 
 VSUB.W.I8  V4, V0, V2                   ; no saturation -> should overflow
 VQSUB.W.U8 V6, V0, V2                   ; unsigned saturate -> should saturate to 0x00000000
 VQSUB.W.S8 V8, V0, V2                   ; signed saturate -> should not saturate
 
 ;-------------------------------------
 ; 8 bit saturation test3
 ;-------------------------------------
 IMM        $7F7F
 ORI        R1, R0, $7F7F
 VMOVA.W    V0, R1
 
 VADD.W.I8  V4, V0, V2                   ; no saturation -> no overflow
 VQADD.W.U8 V6, V0, V2                   ; unsigned saturate -> no saturation
 VQADD.W.S8 V8, V0, V2                   ; signed saturate -> should saturate to 0x7F7F7F7F
 
 VSUB.W.I8  V4, V0, V2                   ; no saturation -> no oveflow
 VQSUB.W.U8 V6, V0, V2                   ; unsigned saturate -> should not saturate
 VQSUB.W.S8 V8, V0, V2                   ; signed saturate -> should not saturate
 
 ;-------------------------------------
 ; 8 bit saturation test4
 ;-------------------------------------
 IMM        $8080
 ORI        R1, R0, $8080
 VMOVA.W    V0, R1
 
 VADD.W.I8  V4, V0, V2                   ; no saturation -> no overflow
 VQADD.W.U8 V6, V0, V2                   ; unsigned saturate -> no saturation
 VQADD.W.S8 V8, V0, V2                   ; signed saturate -> no saturation
 
 VSUB.W.I8  V4, V0, V2                   ; no saturation -> no oveflow
 VQSUB.W.U8 V6, V0, V2                   ; unsigned saturate -> should not saturate
 VQSUB.W.S8 V8, V0, V2                   ; signed saturate -> should saturate to 0x80808080
 

 
 
 
 
 ;-------------------------------------
 ; 16 bit saturation test1
 ;-------------------------------------
 IMM         $FFFF
 ORI         R1, R0, $FFFF
 VMOVA.W     V0, R1

 IMM         $0003
 ORI         R2, R0, $0003
 VMOVA.W     V2, R2

 VADD.W.I16  V4, V0, V2                   ; no saturation -> should overflow
 VQADD.W.U16 V6, V0, V2                   ; unsigned saturate -> should saturate to 0xFFFFFFF
 VQADD.W.S16 V8, V0, V2                   ; signed saturate -> sould not saturate
 
 VSUB.W.I16  V4, V0, V2                   ; should not saturation
 VQSUB.W.U16 V6, V0, V2                   ; should not saturation
 VQSUB.W.S16 V8, V0, V2                   ; should not saturation
 
 ;-------------------------------------
 ; 16 bit saturation test2
 ;-------------------------------------
 IMM        $0000
 ORI        R1, R0, $0000
 VMOVA.W    V0, R1

 VADD.W.I16  V4, V0, V2                   ; no saturation -> no overflow
 VQADD.W.U16 V6, V0, V2                   ; unsigned saturate -> no overflow
 VQADD.W.S16 V8, V0, V2                   ; signed saturate -> no overflow
 
 VSUB.W.I16  V4, V0, V2                   ; no saturation -> should overflow
 VQSUB.W.U16 V6, V0, V2                   ; unsigned saturate -> should saturate to 0x00000000
 VQSUB.W.S16 V8, V0, V2                   ; signed saturate -> should not saturate
 
 ;-------------------------------------
 ; 16 bit saturation test3
 ;-------------------------------------
 IMM         $7FFF
 ORI         R1, R0, $7FFF
 VMOVA.W     V0, R1
 
 VADD.W.I16  V4, V0, V2                   ; no saturation -> no overflow
 VQADD.W.U16 V6, V0, V2                   ; unsigned saturate -> no saturation
 VQADD.W.S16 V8, V0, V2                   ; signed saturate -> should saturate to 0x7FF7FF
 
 VSUB.W.I16  V4, V0, V2                   ; no saturation -> no oveflow
 VQSUB.W.U16 V6, V0, V2                   ; unsigned saturate -> should not saturate
 VQSUB.W.S16 V8, V0, V2                   ; signed saturate -> should not saturate
 
 ;-------------------------------------
 ; 16 bit saturation test4
 ;-------------------------------------
 IMM        $8000
 ORI        R1, R0, $8000
 VMOVA.W    V0, R1
 
 VADD.W.I16  V4, V0, V2                   ; no saturation -> no overflow
 VQADD.W.U16 V6, V0, V2                   ; unsigned saturate -> no saturation
 VQADD.W.S16 V8, V0, V2                   ; signed saturate -> no saturation
 
 VSUB.W.I16  V4, V0, V2                   ; no saturation -> no oveflow
 VQSUB.W.U16 V6, V0, V2                   ; unsigned saturate -> should not saturate
 VQSUB.W.S16 V8, V0, V2                   ; signed saturate -> should saturate to 0x80008000
 

 
 
 
 
 ;-------------------------------------
 ; 32 bit saturation test1
 ;-------------------------------------
 IMM         $FFFF
 ORI         R1, R0, $FFFF
 VMOVA.W     V0, R1

 IMM         $0000
 ORI         R2, R0, $0003
 VMOVA.W     V2, R2

 VADD.W.I32  V4, V0, V2                   ; no saturation -> should overflow
 VQADD.W.U32 V6, V0, V2                   ; unsigned saturate -> should saturate to 0xFFFFFFF
 VQADD.W.S32 V8, V0, V2                   ; signed saturate -> sould not saturate
 
 VSUB.W.I32  V4, V0, V2                   ; should not saturation
 VQSUB.W.U32 V6, V0, V2                   ; should not saturation
 VQSUB.W.S32 V8, V0, V2                   ; should not saturation
 
 ;-------------------------------------
 ; 32 bit saturation test2
 ;-------------------------------------
 IMM        $0000
 ORI        R1, R0, $0000
 VMOVA.W    V0, R1

 VADD.W.I32  V4, V0, V2                   ; no saturation -> no overflow
 VQADD.W.U32 V6, V0, V2                   ; unsigned saturate -> no overflow
 VQADD.W.S32 V8, V0, V2                   ; signed saturate -> no overflow
 
 VSUB.W.I32  V4, V0, V2                   ; no saturation -> should overflow
 VQSUB.W.U32 V6, V0, V2                   ; unsigned saturate -> should saturate to 0x00000000
 VQSUB.W.S32 V8, V0, V2                   ; signed saturate -> should not saturate
 
 ;-------------------------------------
 ; 32 bit saturation test3
 ;-------------------------------------
 IMM         $7FFF
 ORI         R1, R0, $FFFF
 VMOVA.W     V0, R1
 
 VADD.W.I32  V4, V0, V2                   ; no saturation -> no overflow
 VQADD.W.U32 V6, V0, V2                   ; unsigned saturate -> no saturation
 VQADD.W.S32 V8, V0, V2                   ; signed saturate -> should saturate to 0x7FFFFF
 
 VSUB.W.I32  V4, V0, V2                   ; no saturation -> no oveflow
 VQSUB.W.U32 V6, V0, V2                   ; unsigned saturate -> should not saturate
 VQSUB.W.S32 V8, V0, V2                   ; signed saturate -> should not saturate
 
 ;-------------------------------------
 ; 32 bit saturation test4
 ;-------------------------------------
 IMM        $8000
 ORI        R1, R0, $0000
 VMOVA.W    V0, R1
 
 VADD.W.I32  V4, V0, V2                   ; no saturation -> no overflow
 VQADD.W.U32 V6, V0, V2                   ; unsigned saturate -> no saturation
 VQADD.W.S32 V8, V0, V2                   ; signed saturate -> no saturation
 
 VSUB.W.I32  V4, V0, V2                   ; no saturation -> no oveflow
 VQSUB.W.U32 V6, V0, V2                   ; unsigned saturate -> should not saturate
 VQSUB.W.S32 V8, V0, V2                   ; signed saturate -> should saturate to 0x80000000
 
 
