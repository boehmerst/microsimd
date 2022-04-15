#include "hibi.h"
#include "hibi_pif.h"
#include "hibi_link.h"
#include "types.h"

static const uint32_t HIBI_TXPIF_CFG_OFFSET    = 0x14;
static const uint32_t HIBI_TRIG_CTRL_OFFSET    = 0x15;
static const uint32_t HIBI_PIF_CTRL_OFFSET     = 0x16;
static const uint32_t HIBI_TXPIF_STATUS_OFFSET = 0x17;

void
hibi_pif_txen() {
  const uint32_t txen = 0x10;
  hibi_send_prio_b(get_pif_addr() | HIBI_PIF_CTRL_OFFSET, &txen, 1);
}

void
hibi_pif_rxen() {
  const uint32_t rxen = 0x20;
  hibi_send_prio_b(get_pif_addr() | HIBI_PIF_CTRL_OFFSET, &rxen, 1);
}

void
hibi_pif_txcfg(const uint32_t hsize, const uint32_t vsize) {
  const uint32_t cfg = (vsize << 16) | hsize;
  hibi_send_prio_b(get_pif_addr() | HIBI_TXPIF_CFG_OFFSET, &cfg, 1);
}

static inline void hibi_pif_trigger(const uint32_t tr) {
  const uint32_t trigger = tr;
  hibi_send_prio_b(get_pif_addr() | HIBI_TRIG_CTRL_OFFSET, &trigger, 1);
}

void
hibi_pif_fe() {
  hibi_pif_trigger(2);
}

void
hibi_pif_le() {
  hibi_pif_trigger(1);
}

