#include "types.h"
#include "fsl_macros.h"

extern int verify_vaddi8();
extern int verify_vaddi16();
extern int verify_vaddi32();
extern int verify_vsubi8();
extern int verify_vsubi16();
extern int verify_vsubi32();

// NOTE: we do not use startup code, so we need to ensure _start() to be at 0x0000 
//  -> functions before _start() must be of type inline!
static inline void ack_msg(const Bool success, const uint32_t num)
{
  const uint32_t per_success_addr = 0x0;
  const uint32_t per_success_data = success ? 0x1 : 0x3;
  FSL0_WR(per_success_addr, per_success_data);
  __memory_barrier();
  
  const uint32_t per_testnum_addr = 0x1;
  const uint32_t per_testnum_data = num;
  FSL0_WR(per_testnum_addr, per_testnum_data);
  __memory_barrier(); 
}

static inline void exit()
{
  const uint32_t per_success_addr  = 0x0;
  const uint32_t per_success_data  = 0xF;
  FSL0_WR(per_success_addr, per_success_data);
  __memory_barrier();
  
  const uint32_t per_testnum_addr = 0x1;
  const uint32_t per_testnum_data = 0xF;
  FSL0_WR(per_testnum_addr, per_testnum_data);
  __memory_barrier();
  while(1);
}


int main()
{
  ack_msg(verify_vaddi8(),  0);
  ack_msg(verify_vaddi16(), 1);
  ack_msg(verify_vaddi32(), 2);
  ack_msg(verify_vaddi8(),  3);
  ack_msg(verify_vsubi16(), 4);
  ack_msg(verify_vsubi32(), 5); 
  exit();
  return 0;
}


