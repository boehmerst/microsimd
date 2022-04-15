#ifndef DRIVER_HIBI_HIBI_PIF_H
#define DRIVER_HIBI_HIBI_PIF_H

#include "types.h"

void hibi_pif_txen();
void hibi_pif_rxen();
void hibi_pif_txcfg(uint32_t hsize, uint32_t vsize);
void hibi_pif_fe();
void hibi_pif_le();

#endif // DRIVER_HIBI_HIBI_PIF_H

