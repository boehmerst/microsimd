#ifndef DRIVER_HIBI_HIBI_H
#define DRIVER_HIBI_HIBI_H

#include "types.h"

#define FSL0_WR(addr, val) __asm__  ( "ncput %0, rfsl0\n"    \
                                                  "nput  %1, rfsl0\n"   \
                                                  :                     \
                                                  : "r"(addr), "r"(val) \
                                                  :  )

#define FSL0_RD(addr, val) __asm__ __volatile__ ( "ncput %1, rfsl0\n"    \
                                                  "nget  %0, rfsl0\n"    \
                                                  : "=r"(val)            \
                                                  : "r"(addr) )

extern const uint32_t hibi_table[];


typedef enum
{
  HIBI_IDLE                = 0,
  HIBI_WR_DATA             = 2,
  HIBI_WR_PRIO_DATA        = 3,
  HIBI_RD_DATA             = 4,
  HIBI_RD_PRIO_DATA        = 5,
  HIBI_RD_DATA_LINKED      = 6,
  HIBI_RD_PRIO_DATA_LINKED = 7,
  HIBI_WR_DATA_NOPOST      = 8,
  HIBI_WR_PRIO_DATA_NOPOST = 9,
  HIBI_WR_DATA_COND        = 10,
  HIBI_WR_PRIO_DATA_COND   = 11,
  HIBI_LOCK                = 13,
  HIBI_WR_DATA_LOCKED      = 15,
  HIBI_RD_DATA_LOCKED      = 17,
  HIBI_UNLOCK              = 19,
  HIBI_WR_CFG              = 21,
  HIBI_RD_CFG              = 23,
  HIBI_END_OF_LIST
} HibiComm;


inline uint32_t get_cpu_addr(const uint32_t id) {
  return hibi_table[id];
}

inline uint32_t get_pif_addr() {
  return hibi_table[2];
}

inline uint32_t get_mem_addr() {
  return hibi_table[3];
}

#endif // DRIVER_HIBI_HIBI_H

