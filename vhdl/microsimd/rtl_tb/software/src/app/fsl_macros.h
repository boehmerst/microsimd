#ifndef FSL_MACROS_H
#define FSL_MACROS_H

#define FSL0_WR(addr, val) __asm__  ( "ncput %0, rfsl0\n"   \
                                      "nput  %1, rfsl0\n"   \
                                      :                     \
                                      : "r"(addr), "r"(val) \
                                      :  )

#define FSL0_RD(addr, val) __asm__ __volatile__ ( "ncput %1, rfsl0\n"    \
                                                  "nget  %0, rfsl0\n"    \
                                                  : "=r"(val)            \
                                                  : "r"(addr) )

#endif //FSL_MACROS_H

