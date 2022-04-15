#include "types.h"
#include "vec_types.h"
#include "vec_operands.h"

/******************************************************************************/
/* integer vector addition                                                    */
/******************************************************************************/
static inline vec32i8
_vsub32i8_(vec32i8 opa, vec32i8 opb)
{
  vec32i8 res;
  res.i8[0] = opa.i8[0] - opb.i8[0];
  res.i8[1] = opa.i8[1] - opb.i8[1];
  res.i8[2] = opa.i8[2] - opb.i8[2];
  res.i8[3] = opa.i8[3] - opb.i8[3];
  return res;
}

static inline vec32i8
_vsub32i8_simd_(vec32i8 opa, vec32i8 opb)
{
  vec32i8 res;
  
  asm( "vmov    v0, %1, 0;"
       "vmov    v0, %2, 1;"
       "vsub.i8 n0, n1, n0;"
       "vmovs   %0, v0, 0;"
         : "=r"(res.all)
         : "r"(opa.all), "r"(opb.all) );
  return res;
}

static inline vec64i8
_vsub64i8_(vec64i8 opa, vec64i8 opb)
{
  vec64i8 res;
  res.low  = _vsub32i8_(opa.low,  opb.low);
  res.high = _vsub32i8_(opa.high, opb.high);
  return res;
}

static inline vec64i8
_vsub64i8_simd_(vec64i8 opa, vec64i8 opb)
{
  vec64i8 res;
  
  asm( "vmov    v0, %2, 0;"
       "vmov    v0, %3, 1;"
       "vmov    v1, %4, 0;"
       "vmov    v1, %5, 1;"
       "vsub.i8 w0, w1, w0;"
       "vmovs   %0, v0, 0;"
       "vmovs   %1, v0, 1;"
         : "=r"(res.low.all), "=r"(res.high.all)
         : "r"(opa.low.all), "r"(opa.high.all), "r"(opb.low.all), "r"(opb.high.all) );
  return res;
}


static inline vec32i16
_vsub32i16_(vec32i16 opa, vec32i16 opb)
{
  vec32i16 res;
  res.i16[0] = opa.i16[0] - opb.i16[0];
  res.i16[1] = opa.i16[1] - opb.i16[1];
  return res;
}

static inline vec32i16
_vsub32i16_simd_(vec32i16 opa, vec32i16 opb)
{
  vec32i16 res;
  
  // just little more complex in terms of which narrow regs are used
  asm( "vmov     v0, %1, 0;"
       "vmov     v1, %2, 1;"
       "vsub.i16 n1, n3, n0;"
       "vmovs    %0, v0, 1;"
         : "=r"(res.all)
         : "r"(opa.all), "r"(opb.all) );
  return res;
}

static inline vec64i16
_vsub64i16_(vec64i16 opa, vec64i16 opb)
{
  vec64i16 res;
  res.low  = _vsub32i16_(opa.low,  opb.low);
  res.high = _vsub32i16_(opa.high, opb.high);
  return res; 
}

static inline vec64i16
_vsub64i16_simd_(vec64i16 opa, vec64i16 opb)
{
  vec64i16 res;
  
  asm( "vmov     v0, %2, 0;"
       "vmov     v0, %3, 1;"
       "vmov     v1, %4, 0;"
       "vmov     v1, %5, 1;"
       "vsub.i16 w0, w1, w0;"
       "vmovs    %0, v0, 0;"
       "vmovs    %1, v0, 1;"
         : "=r"(res.low.all), "=r"(res.high.all)
         : "r"(opa.low.all), "r"(opa.high.all), "r"(opb.low.all), "r"(opb.high.all) );
  return res;
}

static inline vec32i32
_vsub32i32_(vec32i32 opa, vec32i32 opb)
{
  vec32i32 res;
  res.i32 = opa.i32 - opb.i32;
  return res;
}

static inline vec32i32
_vsub32i32_simd_(vec32i32 opa, vec32i32 opb)
{
  vec32i32 res;
  
  asm( "vmov     v0, %1, 0;"
       "vmov     v0, %2, 1;"
       "vsub.i32 n0, n1, n0;"
       "vmovs    %0, v0, 0;"
         : "=r"(res.all)
         : "r"(opa.all), "r"(opb.all) );
  return res;
}

static inline vec64i32
_vsub64i32_(vec64i32 opa, vec64i32 opb)
{
  vec64i32 res;
  res.low  = _vsub32i32_(opa.low,  opb.low);
  res.high = _vsub32i32_(opa.high, opb.high);
  return res;
}

static inline vec64i32
_vsub64i32_simd_(vec64i32 opa, vec64i32 opb)
{
  vec64i32 res;
  
  asm( "vmov     v0, %2, 0;"
       "vmov     v0, %3, 1;"
       "vmov     v1, %4, 0;"
       "vmov     v1, %5, 1;"
       "vsub.i32 w0, w1, w0;"
       "vmovs    %0, v0, 0;"
       "vmovs    %1, v0, 1;"
         : "=r"(res.low.all), "=r"(res.high.all)
         : "r"(opa.low.all), "r"(opa.high.all), "r"(opb.low.all), "r"(opb.high.all) );
  return res;
}


int 
verify_vsubi8()
{
  /****************************************************************************/
  /* 8 bit narrow vector addition (integer, no saturation)                    */
  /****************************************************************************/
  for(int i=0; i<countof(int8_table); ++i) {
    for(int j=0; j<countof(int8_table); ++ j) {
      const int8_t opa = int8_table[i];
      const int8_t opb = int8_table[j];
          
      vec32i8 opa_32; vec32i8 opb_32; vec32i8 res_32; vec32i8 res_32_simd;
          
      opa_32      = (vec32i8) {.i8 = {0, 0, 0, opa}};
      opb_32      = (vec32i8) {.i8 = {0, 0, 0, opb}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
     
      opa_32      = (vec32i8) {.i8 = {0, 0, opa, 0}};
      opb_32      = (vec32i8) {.i8 = {0, 0, opb, 0}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
               
      opa_32      = (vec32i8) {.i8 = {0, 0, opa, opa}};
      opb_32      = (vec32i8) {.i8 = {0, 0, opb, opb}};
      res_32      = _vsub32i8_(opa_32, opb_32);
          
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
          
      opa_32      = (vec32i8) {.i8 = {0, opa, 0, 0}};
      opb_32      = (vec32i8) {.i8 = {0, opb, 0, 0}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
          
      opa_32      = (vec32i8) {.i8 = {0, opa, 0, opa}};
      opb_32      = (vec32i8) {.i8 = {0, opb, 0, opb}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
          
      opa_32      = (vec32i8) {.i8 = {0, opa, opa, 0}};
      opb_32      = (vec32i8) {.i8 = {0, opb, opb, 0}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
            
      opa_32      = (vec32i8) {.i8 = {0, opa, opa, opa}};
      opb_32      = (vec32i8) {.i8 = {0, opb, opb, opb}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
          
      opa_32      = (vec32i8) {.i8 = {opa, 0, 0, 0}};
      opb_32      = (vec32i8) {.i8 = {opb, 0, 0, 0}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }      
          
      opa_32      = (vec32i8) {.i8 = {opa, 0, 0, opa}};
      opb_32      = (vec32i8) {.i8 = {opb, 0, 0, opb}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
          
      opa_32      = (vec32i8) {.i8 = {opa, 0, opa, 0}};
      opb_32      = (vec32i8) {.i8 = {opb, 0, opb, 0}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
          
      opa_32      = (vec32i8) {.i8 = {opa, 0, opa, opa}};
      opb_32      = (vec32i8) {.i8 = {opb, 0, opb, opb}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
          
      opa_32      = (vec32i8) {.i8 = {opa, opa, 0, 0}};
      opb_32      = (vec32i8) {.i8 = {opb, opb, 0, 0}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
          
      opa_32      = (vec32i8) {.i8 = {opa, opa, 0, opa}};
      opb_32      = (vec32i8) {.i8 = {opb, opb, 0, opb}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
          
      opa_32      = (vec32i8) {.i8 = {opa, opa, opa, 0}};
      opb_32      = (vec32i8) {.i8 = {opb, opb, opb, 0}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
          
      opa_32      = (vec32i8) {.i8 = {opa, opa, opa, opa}};
      opb_32      = (vec32i8) {.i8 = {opb, opb, opb, opb}};
      res_32      = _vsub32i8_(opa_32, opb_32);
      res_32_simd = _vsub32i8_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
    }
  }
  
  /****************************************************************************/
  /* 8 bit wide vector addition (integer, no saturation)                      */
  /****************************************************************************/
  for(int i=0; i<countof(int8_table); ++i) {
    for(int j=0; j<countof(int8_table); ++j) { 
      const int8_t opa = int8_table[i];
      const int8_t opb = int8_table[j];
          
      vec64i8 opa_64; vec64i8 opb_64; vec64i8 res_64; vec64i8 res_64_simd;      
              
      opa_64      = (vec64i8) {.high = {.i8 = {opa, 0, 0, 0}}, .low = {.i8 = {0, 0, 0, opa}}};
      opb_64      = (vec64i8) {.high = {.i8 = {opb, 0, 0, 0}}, .low = {.i8 = {0, 0, 0, opb}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
      
      
      opa_64      = (vec64i8) {.high = {.i8 = {0, opa, 0, 0}}, .low = {.i8 = {0, 0, opa, 0}}};
      opb_64      = (vec64i8) {.high = {.i8 = {0, opb, 0, 0}}, .low = {.i8 = {0, 0, opb, 0}}};
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
      
      opa_64      = (vec64i8) {.high = {.i8 = {opa, opa, 0, 0}}, .low = {.i8 = {0, 0, opa, opa}}};
      opb_64      = (vec64i8) {.high = {.i8 = {opb, opb, 0, 0}}, .low = {.i8 = {0, 0, opb, opb}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
      
      opa_64      = (vec64i8) {.high = {.i8 = {0, 0, opa, 0}}, .low = {.i8 = {0, opa, 0, 0}}};
      opb_64      = (vec64i8) {.high = {.i8 = {0, 0, opb, 0}}, .low = {.i8 = {0, opb, 0, 0}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
                
      opa_64      = (vec64i8) {.high = {.i8 = {opa, 0, opa, 0}}, .low = {.i8 = {0, opa, 0, opa}}};
      opb_64      = (vec64i8) {.high = {.i8 = {opb, 0, opb, 0}}, .low = {.i8 = {0, opb, 0, opb}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
       
      opa_64      = (vec64i8) {.high = {.i8 = {0, opa, opa, 0}}, .low = {.i8 = {0, opa, opa, 0}}};
      opb_64      = (vec64i8) {.high = {.i8 = {0, opb, opb, 0}}, .low = {.i8 = {0, opb, opb, 0}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
          
      opa_64      = (vec64i8) {.high = {.i8 = {opa, opa, opa, 0}}, .low = {.i8 = {0, opa, opa, opa}}};
      opb_64      = (vec64i8) {.high = {.i8 = {opb, opb, opb, 0}}, .low = {.i8 = {0, opb, opb, opb}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
       
      opa_64      = (vec64i8) {.high = {.i8 = {0, 0, 0, opa}}, .low = {.i8 = {opa, 0, 0, 0}}};
      opb_64      = (vec64i8) {.high = {.i8 = {0, 0, 0, opb}}, .low = {.i8 = {opb, 0, 0, 0}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
       
      opa_64      = (vec64i8) {.high = {.i8 = {opa, 0, 0, opa}}, .low = {.i8 = {opa, 0, 0, opa}}};
      opb_64      = (vec64i8) {.high = {.i8 = {opb, 0, 0, opb}}, .low = {.i8 = {opb, 0, 0, opb}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
          
      opa_64      = (vec64i8) {.high = {.i8 = {0, opa, 0, opa}}, .low = {.i8 = {opa, 0, opa, 0}}};
      opb_64      = (vec64i8) {.high = {.i8 = {0, opb, 0, opb}}, .low = {.i8 = {opb, 0, opb, 0}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
          
      opa_64      = (vec64i8) {.high = {.i8 = {opa, opa, 0, opa}}, .low = {.i8 = {opa, 0, opa, opa}}};
      opb_64      = (vec64i8) {.high = {.i8 = {opb, opb, 0, opb}}, .low = {.i8 = {opb, 0, opb, opb}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
          
      opa_64      = (vec64i8) {.high = {.i8 = {0, 0, opa, opa}}, .low = {.i8 = {opa, opa, 0, 0}}};
      opb_64      = (vec64i8) {.high = {.i8 = {0, 0, opb, opb}}, .low = {.i8 = {opb, opb, 0, 0}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
      
      opa_64      = (vec64i8) {.high = {.i8 = {opa, 0, opa, opa}}, .low = {.i8 = {opa, opa, 0, opa}}};
      opb_64      = (vec64i8) {.high = {.i8 = {opb, 0, opb, opb}}, .low = {.i8 = {opb, opb, 0, opb}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
          
      opa_64      = (vec64i8) {.high = {.i8 = {0, opa, opa, opa}}, .low = {.i8 = {opa, opa, opa, 0}}};
      opb_64      = (vec64i8) {.high = {.i8 = {0, opb, opb, opb}}, .low = {.i8 = {opb, opb, opb, 0}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
       }
       
        
      opa_64      = (vec64i8) {.high = {.i8 = {opa, opa, opa, opa}}, .low = {.i8 = {opa, opa, opa, opa}}};
      opb_64      = (vec64i8) {.high = {.i8 = {opb, opb, opb, opb}}, .low = {.i8 = {opb, opb, opb, opb}}};   
      res_64      = _vsub64i8_(opa_64, opb_64);
      res_64_simd = _vsub64i8_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
    }
  }
  
  return 1;
}


int 
verify_vsubi16()
{
  /****************************************************************************/
  /* 16 bit narrow vector addition (integer, no saturation)                   */
  /****************************************************************************/
  for(int i=0; i<countof(int16_table); ++i) {
    for(int j=0; j<countof(int16_table); ++ j) {
      const int16_t opa = int16_table[i];
      const int16_t opb = int16_table[j];
          
      vec32i16 opa_32; vec32i16 opb_32; vec32i16 res_32; vec32i16 res_32_simd;
          
      opa_32      = (vec32i16) {.i16 = {0, opa}};
      opb_32      = (vec32i16) {.i16 = {0, opb}};
      res_32      = _vsub32i16_(opa_32, opb_32);
      res_32_simd = _vsub32i16_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
          
      opa_32      = (vec32i16) {.i16 = {opa, 0}};
      opb_32      = (vec32i16) {.i16 = {opb, 0}};
      res_32      = _vsub32i16_(opa_32, opb_32);
      res_32_simd = _vsub32i16_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
      
      opa_32      = (vec32i16) {.i16 = {opa, opa}};
      opb_32      = (vec32i16) {.i16 = {opb, opa}};
      res_32      = _vsub32i16_(opa_32, opb_32);
      res_32_simd = _vsub32i16_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }          
  
    }
  }
  
  /****************************************************************************/
  /* 16 bit wide vector addition (integer, no saturation)                   */
  /****************************************************************************/
  for(int i=0; i<countof(int16_table); ++i) {
    for(int j=0; j<countof(int16_table); ++ j) {
      const int16_t opa = int16_table[i];
      const int16_t opb = int16_table[j];
          
      vec64i16 opa_64; vec64i16 opb_64; vec64i16 res_64; vec64i16 res_64_simd;  
  
      opa_64      = (vec64i16) {.high = {.i16 = {opa, 0}}, .low = {.i16 = {0, opa}}};
      opb_64      = (vec64i16) {.high = {.i16 = {opb, 0}}, .low = {.i16 = {0, opb}}};   
      res_64      = _vsub64i16_(opa_64, opb_64);
      res_64_simd = _vsub64i16_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
      
      opa_64      = (vec64i16) {.high = {.i16 = {0, opa}}, .low = {.i16 = {opa, 0}}};
      opb_64      = (vec64i16) {.high = {.i16 = {0, opb}}, .low = {.i16 = {opb, 0}}};   
      res_64      = _vsub64i16_(opa_64, opb_64);
      res_64_simd = _vsub64i16_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }      
      
      opa_64      = (vec64i16) {.high = {.i16 = {opa, opa}}, .low = {.i16 = {opa, opa}}};
      opb_64      = (vec64i16) {.high = {.i16 = {opb, opb}}, .low = {.i16 = {opb, opb}}};   
      res_64      = _vsub64i16_(opa_64, opb_64);
      res_64_simd = _vsub64i16_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
    }
  }
      
  return 1;
}

int 
verify_vsubi32()
{
  /****************************************************************************/
  /* 32 bit narrow vector addition (integer, no saturation)                   */
  /****************************************************************************/
  for(int i=0; i<countof(int32_table); ++i) {
    for(int j=0; j<countof(int32_table); ++ j) {
      const int32_t opa = int32_table[i];
      const int32_t opb = int32_table[j];
          
      vec32i32 opa_32; vec32i32 opb_32; vec32i32 res_32; vec32i32 res_32_simd;
          
      opa_32      = (vec32i32) {.i32 = opa};
      opb_32      = (vec32i32) {.i32 = opb};
      res_32      = _vsub32i32_(opa_32, opb_32);
      res_32_simd = _vsub32i32_simd_(opa_32, opb_32);
          
      if(res_32.all != res_32_simd.all) {
        return 0;
      }
    }
  }
  
   for(int i=0; i<countof(int32_table); ++i) {
    for(int j=0; j<countof(int32_table); ++ j) {
      const int32_t opa = int32_table[i];
      const int32_t opb = int32_table[j];
          
      vec64i32 opa_64; vec64i32 opb_64; vec64i32 res_64; vec64i32 res_64_simd;
          
      opa_64      = (vec64i32) {.high = {.i32 = 0}, .low = {.i32 = opa}};
      opb_64      = (vec64i32) {.high = {.i32 = 0}, .low = {.i32 = opb}};
      res_64      = _vsub64i32_(opa_64, opb_64);
      res_64_simd = _vsub64i32_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
      
      opa_64      = (vec64i32) {.high = {.i32 = opa}, .low = {.i32 = 0}};
      opb_64      = (vec64i32) {.high = {.i32 = opb}, .low = {.i32 = 0}};
      res_64      = _vsub64i32_(opa_64, opb_64);
      res_64_simd = _vsub64i32_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }
      
      opa_64      = (vec64i32) {.high = {.i32 = opa}, .low = {.i32 = opa}};
      opb_64      = (vec64i32) {.high = {.i32 = opb}, .low = {.i32 = opb}};
      res_64      = _vsub64i32_(opa_64, opb_64);
      res_64_simd = _vsub64i32_simd_(opa_64, opb_64);
          
      if((res_64.low.all != res_64_simd.low.all) || (res_64.high.all != res_64_simd.high.all)) {
        return 0;
      }      
      
    }
  }
  
  return 1;
}

