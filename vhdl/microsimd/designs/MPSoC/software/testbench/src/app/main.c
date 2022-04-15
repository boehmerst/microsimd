#include "driver/cpu/cpu.h"
#include "work_app.h"
#include "ctrl_app.h"

#include "driver/hibi/hibi_link.h"
#include "driver/hibi/hibi_dma.h"
#include "driver/hibi/remote_dma.h"

#include "types.h"


int main() {
  cpu_init();
  hibi_dma_enable(1);
    
  if(get_cpu_id() == 0) {
    //ctrl_app();
    
    /*
    const uint32_t buf[] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}; 
    
    remote_dma_enable(get_mem_addr(), true);
    remote_dma_recv(get_mem_addr(), 0, 0, countof(buf), 0);
    
    remote_dma_enable(get_cpu_addr(get_cpu_id()), 1);
    remote_dma_tx_setup(get_cpu_addr(get_cpu_id()), 2, get_mem_addr(), &buf[0], countof(buf)/2, 0);
    remote_dma_tx_setup(get_cpu_addr(get_cpu_id()), 3, get_mem_addr(), &buf[5], countof(buf)/2, 0);  
    remote_dma_chain(get_cpu_addr(get_cpu_id()), 3, DMA_CHANNEL_TWO_MSK);
    remote_dma_start(get_cpu_addr(get_cpu_id()), DMA_CHANNEL_TWO_MSK | DMA_CHANNEL_THREE_MSK);
    */
    
    uint32_t test = 0xaffedead;
    
    FSL0_WR(5, &test);
    __memory_barrier();
    
   
    while(1);
    
  }
  else {
    //work_app();
  }
  
  return 0;
}

