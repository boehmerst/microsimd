#ifndef DRIVER_HIBI_REMOTE_DMA
#define DRIVER_HIBI_REMOTE_DMA

#include "types.h"

typedef enum {
  DMA_CHANNEL_ZERO_MSK  = 1,
  DMA_CHANNEL_ONE_MSK   = 2,
  DMA_CHANNEL_TWO_MSK   = 4,
  DMA_CHANNEL_THREE_MSK = 8
} DmaChannelMask;

/* remote_dma_enable      */
/* enable remote hibi DMA */
void remote_dma_enable(uint32_t remote_hibi_addr, uint32_t ena);

/* remode_dma_send        */
/* send date via hibi bus */
void remote_dma_send(uint32_t remote_hibi_addr, uint32_t ch, uint32_t hibi_dest, const uint32_t* mem, uint32_t count, bool const_src);

/* remode_dma_rec             */
/* receive date from hibi bus */
void remote_dma_recv(uint32_t remote_hibi_addr, uint32_t ch, uint32_t* mem, uint32_t count, bool const_dest);

/* remote_dma_wait                   */
/* wait for the remote dma to finish */
void remote_dma_wait(uint32_t remote_hibi_addr, uint32_t mask);

/* remode_dma_send        */
/* send date via hibi bus */
void remote_dma_tx_setup(uint32_t remote_hibi_addr, uint32_t ch, uint32_t hibi_dest, const uint32_t* mem, uint32_t count, bool const_src);

/* remode_dma_rec             */
/* receive date from hibi bus */
void remote_dma_rx_setup(uint32_t remote_hibi_addr, uint32_t ch, uint32_t* mem, uint32_t count, bool const_dest);

/* remote_dma_start                                 */
/* start a previously configured remote dma channel */
void remote_dma_start(uint32_t remote_hibi_addr, uint32_t ch);

/* remote_dma_chain                            */
/* configure remote DMA channels to be chained */
void remote_dma_chain(uint32_t remote_hibi_addr, uint32_t ch, uint32_t chain_mask);


#endif

