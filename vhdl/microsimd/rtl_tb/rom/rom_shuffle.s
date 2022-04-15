
          NOP
          NOP
          NOP
          NOP
          
          ORI   R1, R0, DATAV0
          ORI   R2, R0, DATAV1
          ORI   R3, R0, DATAV2
          ORI   R4, R0, DATAV3          
      
          VLDR  V0, R1, 0          
          VLDR  V2, R2, 0
          VLDR  V8, R4, 0
          
          ;VADD.W.i8 V8, V8, V8   
          
          VSHUF   V0,  V2,  10001110001000
          ;VSHUF   V6,  V8, 100001110001000
          
          VLDR  V6, R3, 0
          
          VADD.W.i32 V0, V0, V0
              
          NOP
          NOP
          NOP
          NOP
    
DATAV0:   DC  $00001111
          DC  $00002222
          
DATAV1:   DC  $00003333
          DC  $00004444
          
DATAV2:   DC  $00005555
          DC  $00006666
          
DATAV3:   DC  $00007777
          DC  $00008888
