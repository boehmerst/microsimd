#ifndef DRIVER_HIBI_HIBI_LINK_H
#define DRIVER_HIBI_HIBI_LINK_H

#include "types.h"

extern const uint32_t hibi_txmsg_channel;
extern const uint32_t hibi_rxmsg_channel;

// hibi_send_b
void hibi_send_b(uint32_t hibi_addr, const void* data, size_t len);

// hibi_send_prio_b
void hibi_send_prio_b(uint32_t hibi_addr, const void* data, size_t len);

// hibi_recv_b
void hibi_recv_b(void* data, size_t len);

// hibi_read_prio_b
void hibi_read_prio_b(uint32_t hibi_addr, void* data);

static inline uint32_t get_txmsg_channel() {
  return hibi_txmsg_channel;
}

static inline uint32_t get_rxmsg_channel() {
  return hibi_rxmsg_channel;
}

#endif // DRIVER_HIBI_HIBI_LINK_H

