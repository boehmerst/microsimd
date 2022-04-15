#include "ctrl_app.h"
#include "work_app.h"
#include "driver/hibi/hibi.h"
#include "driver/hibi/hibi_link.h"
#include "driver/hibi/hibi_pif.h"
#include "driver/hibi/remote_dma.h"
#include "driver/cpu/cpu.h"

static const uint32_t hsize = 40;
static const uint32_t vsize = 20;


/* ctrl_app */
void ctrl_app() {
  /****************************************************************************/
  /* CPU0 code                                                                */
  /****************************************************************************/
  const uint32_t mem_rx_channel = 0;
  const uint32_t pif_tx_channel = 0;
  
  remote_dma_enable(get_pif_addr(), 1);
  remote_dma_recv(get_mem_addr(), mem_rx_channel, 0, 4*hsize*vsize, 0);
  remote_dma_send(get_pif_addr(), pif_tx_channel, get_mem_addr() | mem_rx_channel, 0, hsize, 1);
  hibi_pif_rxen();
  remote_dma_wait(get_mem_addr(), 1 << mem_rx_channel);
}

