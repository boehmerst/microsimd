#include "transport_rx_buf.h"

#define T TransportMsg
#define BUFFER_SIZE_POW_2 4
#include "tools/ringbuf.h"


static TransportMsgBuf handle =
{
  push,
  pop,
  peek,
  isEmpty,
  isFull
};

TransportMsgBuf* transport_buf0_get_handle()
{
  return &handle;
}

