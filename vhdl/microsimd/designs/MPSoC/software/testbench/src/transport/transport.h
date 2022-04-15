#ifndef TRANSPORT_TRANSPORT_H
#define TRANSPORT_TRANSPORT_H

#include "types.h"

#define MAX_BUFFER_SIZE 16
#define MAX_RX_CHANNELS  2
#define MAX_TX_CHANNELS  2
#define MAX_NODES        3

typedef enum
{
  TRANSPORT_OK   = 0,
  TRANSPORT_EOB  = 1,
  TRANSPORT_BUSY = 2,
} TransportStatus;

void 
transport_init(const uint32_t node_id);

uint32_t
transport_create_endpoint(uint32_t port);

uint32_t
transport_get_endpoint(uint32_t node_id, uint32_t port);

TransportStatus
transport_send_msg_b(uint32_t receive_endpoint, size_t size, uint32_t* buffer);

TransportStatus
transport_send_msg_nb(uint32_t receive_endpoint, size_t size, uint32_t* buffer);

TransportStatus
transport_receive_msg_b(const uint32_t sending_endpoint, size_t size, uint32_t* const buffer);

TransportStatus
transport_receive_msg_nb(const uint32_t sending_endpoint, size_t size, uint32_t* const buffer);

void
transport_rx();

TransportStatus
transport_tx();


#endif // TRANSPORT_TRANSPORT_H

