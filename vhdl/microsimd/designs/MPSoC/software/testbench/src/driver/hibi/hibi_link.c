#include "hibi.h"
#include "hibi_link.h"
#include "driver/cpu/cpu.h"

const uint32_t HIBI_DMA_CTRL_OFFSET       = 0x00;
const uint32_t HIBI_DMA_STATUS_OFFSET     = 0x01;
const uint32_t HIBI_DMA_TRIGGER_OFFSET    = 0x02;

const uint32_t HIBI_DMA_CFG0_OFFSET       = 0x04;
const uint32_t HIBI_DMA_MEM_ADDR0_OFFSET  = 0x05;
const uint32_t HIBI_DMA_HIBI_ADDR0_OFFSET = 0x06;

const uint32_t HIBI_DMA_CFG1_OFFSET       = 0x08;
const uint32_t HIBI_DMA_MEM_ADDR1_OFFSET  = 0x09;
const uint32_t HIBI_DMA_HIBI_ADDR1_OFFSET = 0x0A;

const uint32_t hibi_txmsg_channel = 0;
const uint32_t hibi_rxmsg_channel = 1;

inline void
hibi_wait_link(const uint32_t ch)
{
  const uint32_t    mask = 1 << ch;
  const uint32_t    addr = HIBI_DMA_STATUS_OFFSET;
  volatile uint32_t result;
  
  do
  {
    FSL0_RD(addr, result);
  }while(result & mask);
}

// hibi_send_nb
inline void
__hibi_send_nb__(const uint32_t hibi_addr, const void* const data, const size_t len)
{  
  /* configure local DMA channel 0 to transmit payload */
  const uint32_t cfg     = (HIBI_WR_DATA << 16) | (1 << 15) | len;
  const uint32_t trigger = 1;

  FSL0_WR(HIBI_DMA_CFG0_OFFSET,       cfg);
  FSL0_WR(HIBI_DMA_MEM_ADDR0_OFFSET,  data);
  FSL0_WR(HIBI_DMA_HIBI_ADDR0_OFFSET, hibi_addr);
  
  __memory_barrier();
  FSL0_WR(HIBI_DMA_TRIGGER_OFFSET,    trigger);
}

// hibi_send_b
void
hibi_send_b(const uint32_t hibi_addr, const void* const data, const size_t len)
{
  __hibi_send_nb__(hibi_addr, data, len);
  hibi_wait_link(hibi_txmsg_channel);
}

// hibi_send_prio_nb
inline void
__hibi_send_prio_nb__(const uint32_t hibi_addr, const void* const data, const size_t len)
{  
  /* configure local DMA channel 0 to transmit payload */
  const uint32_t cfg     = (HIBI_WR_PRIO_DATA << 16) | (1 << 15) | len;
  const uint32_t trigger = 1;

  FSL0_WR(HIBI_DMA_CFG0_OFFSET,       cfg);
  FSL0_WR(HIBI_DMA_MEM_ADDR0_OFFSET,  data);
  FSL0_WR(HIBI_DMA_HIBI_ADDR0_OFFSET, hibi_addr);
  
  __memory_barrier();
  FSL0_WR(HIBI_DMA_TRIGGER_OFFSET,    trigger);
}

// hibi_send_prio_b
void
hibi_send_prio_b(const uint32_t hibi_addr, const void* const data, const size_t len)
{
  __hibi_send_prio_nb__(hibi_addr, data, len);
  hibi_wait_link(hibi_txmsg_channel);
}

// hibi_recv_nb
inline void
__hibi_recv_nb__(void* const data, const size_t len)
{
   /* configure local DMA channel 1 to receive payload */
  const uint32_t cfg     = len;
  const uint32_t trigger = 2;

  FSL0_WR(HIBI_DMA_CFG1_OFFSET,       cfg);
  FSL0_WR(HIBI_DMA_MEM_ADDR1_OFFSET,  data);
  FSL0_WR(HIBI_DMA_TRIGGER_OFFSET,    trigger); 
}

// hibi_recv_b
void
hibi_recv_b(void* const data, const size_t len)
{
  __hibi_recv_nb__(data, len);
  hibi_wait_link(hibi_rxmsg_channel);
}

// hibi_read_nb
inline void
__hibi_read_prio_nb__(const uint32_t hibi_addr, void* const data)
{
  const uint32_t len         = 1;
  const uint32_t cfg         = (HIBI_RD_PRIO_DATA << 16) | (1 << 15) | len;
  const uint32_t return_addr = get_cpu_addr(get_cpu_id()) | hibi_rxmsg_channel;  
  const uint32_t trigger     = 1;

  FSL0_WR(HIBI_DMA_CFG0_OFFSET,       cfg);
  FSL0_WR(HIBI_DMA_MEM_ADDR0_OFFSET,  return_addr);
  FSL0_WR(HIBI_DMA_HIBI_ADDR0_OFFSET, hibi_addr);
  FSL0_WR(HIBI_DMA_TRIGGER_OFFSET,    trigger);
  
  __hibi_recv_nb__(data, len);
}

// hibi_read_b
void
hibi_read_prio_b(const uint32_t hibi_addr, void* const data) 
{
  __hibi_read_prio_nb__(hibi_addr, data);
  hibi_wait_link(hibi_rxmsg_channel);
}

