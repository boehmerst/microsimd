#ifndef TRANSPORT_TRANSPORT_RX_BUF_H
#define TRANSPORT_TRANSPORT_RX_BUF_H

#include "types.h"
#include "transport_msg.h"

void transport_rx_buf_init();
TransportMsgBuf* transport_rx_buf_get_handle(uint32_t nr);

#endif // TRANSPORT_TRANSPORT_RX_BUF_H

