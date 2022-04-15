#include "hibi.h"
#include "hibi_link.h"
#include "hibi_dma.h"
#include "remote_dma.h"

static const uint32_t HIBI_DMA_CTRL_OFFSET          = 0x00;
static const uint32_t HIBI_DMA_STATUS_OFFSET        = 0x01;
static const uint32_t HIBI_DMA_TRIGGER_OFFSET       = 0x02;

static const uint32_t HIBI_DMA_CFG0_OFFSET          = 0x04;
static const uint32_t HIBI_DMA_MEM_ADDR0_OFFSET     = 0x05;
static const uint32_t HIBI_DMA_HIBI_ADDR0_OFFSET    = 0x06;
static const uint32_t HIBI_DMA_TRIGGER_MASK0_OFFSET = 0x07;


/* remote_dma_enable */
void
remote_dma_enable(const uint32_t remote_hibi_addr, const uint32_t ena)
{
  hibi_send_prio_b(remote_hibi_addr | HIBI_DMA_CTRL_OFFSET, &ena, 1);
}

/* remode_dma_send */
void
remote_dma_send(const uint32_t remote_hibi_addr, const uint32_t ch, const uint32_t hibi_dest, const uint32_t* const mem, const uint32_t count, const bool const_src)
{
  remote_dma_tx_setup(remote_hibi_addr, ch, hibi_dest, mem, count, const_src);
  remote_dma_start(remote_hibi_addr, 1 << ch);
}

/* remode_dma_rec */
void
remote_dma_recv(const uint32_t remote_hibi_addr, const uint32_t ch, uint32_t* const mem, const uint32_t count, const bool const_dest)
{
  remote_dma_rx_setup(remote_hibi_addr, ch, mem, count, const_dest);  
  remote_dma_start(remote_hibi_addr, 1 << ch);
}

/* remote_dma_wait */
void
remote_dma_wait(const uint32_t remote_hibi_addr, const uint32_t mask)
{
  uint32_t status;
  
  do
  {
    hibi_read_prio_b(remote_hibi_addr | get_rxmsg_channel(), &status);
  } while(status & mask);
}

/* remode_dma_send */
void
remote_dma_tx_setup(const uint32_t remote_hibi_addr, const uint32_t ch, const uint32_t hibi_dest, const uint32_t* const mem, const uint32_t count, const bool const_src)
{
  const uint32_t offset  = (ch << 2);
  const uint32_t cfg = (const_src << 21) | (HIBI_WR_DATA << 16) | (1 << 15) | count;
  hibi_send_prio_b(remote_hibi_addr | (HIBI_DMA_CFG0_OFFSET + offset), &cfg, 1);
  
  const uint32_t mem_addr = (uint32_t)mem;
  hibi_send_prio_b(remote_hibi_addr | (HIBI_DMA_MEM_ADDR0_OFFSET + offset), &mem_addr, 1);
  
  const uint32_t hibi_addr = hibi_dest;
  hibi_send_prio_b(remote_hibi_addr | (HIBI_DMA_HIBI_ADDR0_OFFSET + offset), &hibi_addr, 1);
}

/* remode_dma_rec */
void
remote_dma_rx_setup(const uint32_t remote_hibi_addr, const uint32_t ch, uint32_t* const mem, const uint32_t count, const bool const_dest)
{
  const uint32_t offset  = (ch << 2);
  const uint32_t cfg = (const_dest << 21) | (HIBI_RD_DATA << 16) | count;
  hibi_send_prio_b(remote_hibi_addr | (HIBI_DMA_CFG0_OFFSET + offset), &cfg, 1);
  
  const uint32_t mem_addr = (uint32_t)mem;
  hibi_send_prio_b(remote_hibi_addr | (HIBI_DMA_MEM_ADDR0_OFFSET + offset), &mem_addr, 1);
}

/* remote_dma_start */
void
remote_dma_start(const uint32_t remote_hibi_addr, const uint32_t channel_mask)
{
  hibi_send_prio_b(remote_hibi_addr | HIBI_DMA_TRIGGER_OFFSET, &channel_mask, 1);
}

/* remote_dma_chain */
void
remote_dma_chain(const uint32_t remote_hibi_addr, const uint32_t ch, const uint32_t chain_mask)
{
  const uint32_t offset  = (ch << 2); 
  hibi_send_prio_b(remote_hibi_addr | (HIBI_DMA_TRIGGER_MASK0_OFFSET + offset), &chain_mask, 1);
}

