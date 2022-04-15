#include "hibi_dma.h"
#include "types.h"

static const uint32_t HIBI_DMA_CTRL_OFFSET       = 0x00;
static const uint32_t HIBI_DMA_STATUS_OFFSET     = 0x01;
static const uint32_t HIBI_DMA_TRIGGER_OFFSET    = 0x02;
static const uint32_t HIBI_DMA_CFG0_OFFSET       = 0x04;

/* hibi_dma_enable*/
void
hibi_dma_enable(const uint32_t ena)
{
  const uint32_t addr = HIBI_DMA_CTRL_OFFSET;
  FSL0_WR(addr, ena);
}

/* hibi_dma_send */
void
hibi_dma_send(const uint32_t ch, const uint32_t hibi_dest, const uint32_t* const mem, const uint32_t count)
{
  const uint32_t offset  = (ch << 2);
  const uint32_t addr    = HIBI_DMA_CFG0_OFFSET  + offset;
  const uint32_t cfg     = (HIBI_WR_DATA << 16) | (1 << 15) | count;
  const uint32_t trigger = 1 << ch;

  FSL0_WR(addr, cfg);
  FSL0_WR(addr+1, (uint32_t)mem);
  FSL0_WR(addr+2, hibi_dest);
  FSL0_WR(HIBI_DMA_TRIGGER_OFFSET, trigger);
}

/* hibi_dma_rec */
void
hibi_dma_rec(const uint32_t ch, uint32_t* const  mem, const uint32_t count)
{
  const uint32_t offset  = (ch << 2);
  const uint32_t addr    = HIBI_DMA_CFG0_OFFSET  + offset;
  const uint32_t trigger = (1 << ch);

  FSL0_WR(addr, count);
  FSL0_WR(addr+1, (uint32_t)mem);
  FSL0_WR(HIBI_DMA_TRIGGER_OFFSET, trigger);
}



