#include "transport_msg.h"

extern TransportMsgBuf* transport_buf0_get_handle();
extern TransportMsgBuf* transport_buf1_get_handle();
extern TransportMsgBuf* transport_buf2_get_handle();
extern TransportMsgBuf* transport_buf3_get_handle();

static TransportMsgHamdleTable sTransportRxBuffers;

void
transport_rx_buf_init()
{
  sTransportRxBuffers[0] = transport_buf0_get_handle();
  sTransportRxBuffers[1] = transport_buf1_get_handle();
  sTransportRxBuffers[2] = transport_buf2_get_handle();
  sTransportRxBuffers[3] = transport_buf3_get_handle();
}

TransportMsgBuf* 
transport_rx_buf_get_handle(uint32_t nr)
{
  return sTransportRxBuffers[nr];
}

