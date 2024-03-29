#ifndef DRIVER_CPU
#define DRIVER_CPU

#include "types.h"

#define NR_SYSTEM_CPUS 2    

extern uint32_t cpu_id;

/******************************************************************************/
/* initialize CPU                                                             */
/******************************************************************************/  
void cpu_init();

/******************************************************************************/
/* get CPU id                                                                 */
/******************************************************************************/
inline uint32_t
get_cpu_id()
{
  return cpu_id;
}

/******************************************************************************/
/* synchronize with other CPUs                                                */
/******************************************************************************/
void sync_cpu(uint32_t mask);

#endif // DRIVER_CPU

