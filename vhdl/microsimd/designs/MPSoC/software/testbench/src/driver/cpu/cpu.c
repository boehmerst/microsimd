#include "types.h"
#include "cpu.h"
#include "driver/hibi/hibi.h"
#include "driver/hibi/hibi_link.h"

uint32_t cpu_id  = 0;

/******************************************************************************/
/* cpu_init                                                                   */
/******************************************************************************/
void cpu_init()
{
  static bool initialized = 0;
  
  if(!initialized) {
    asm volatile ("vmovs %0, w0, 0\n"
                   : "=r"(cpu_id)
                   : ); 
    initialized = 1;
  }
}

/******************************************************************************/
/* sync_cpu                                                                   */
/******************************************************************************/
void sync_cpu(const uint32_t mask)
{
  /* send sync message to all (include "this") CPUs */
  for(uint32_t i=0; i<NR_SYSTEM_CPUS; ++i) {
    if(mask & (1 << i)) {
      const uint32_t tx_msg = i;
      hibi_send_b(get_cpu_addr(i), &tx_msg, 1);
    }
  }
  
  /* send sync message to all (include "this") CPUs */
  for(uint32_t i=0; i<NR_SYSTEM_CPUS; ++i) {
    if(mask & (1 << i)) {
      uint32_t rx_msg;
      // TODO: we do not check the message contend!
      hibi_recv_b(&rx_msg, 1);
    }
  } 
}

