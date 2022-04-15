#ifndef DRIVER_HIBI_HIBI_DMA_H
#define DRIVER_HIBI_HIBI_DMA_H

#include "types.h"
#include "hibi.h"


/* hibi_dma_enable*/
void
hibi_dma_enable(uint32_t ena);

/* hibi_dma_send          */
/* send date via hibi bus */
void
hibi_dma_send(uint32_t ch, uint32_t hibi_dest, const uint32_t* mem, uint32_t count);

/* hibi_dma_rec               */
/* receive date from hibi bus */
void
hibi_dma_rec(uint32_t ch, uint32_t* mem, uint32_t count);


#endif // DRIVER_HIBI_HIBI_DMA_H

