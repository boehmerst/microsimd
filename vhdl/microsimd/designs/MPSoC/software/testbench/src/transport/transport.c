#include "transport.h"
#include "transport_rx_buf.h"
#include "transport_tx_buf.h"
#include "driver/hibi/hibi_link.h"
#include "libc.h"

typedef struct
{
  uint32_t         current_length;
  uint32_t         total_length;
  uint32_t         endpoint;
  TransportMsgBuf* msg_buf;
  uint32_t         buffer[MAX_BUFFER_SIZE];
} TransportRxItem;

typedef struct
{
  uint32_t         current_length;
  uint32_t         total_length;
  uint32_t         endpoint;
  uint32_t         buffer[MAX_BUFFER_SIZE];
} TransportTxItem;

typedef TransportRxItem TransportRxBufferTable[MAX_RX_CHANNELS];
typedef TransportTxItem TransportTxBufferTable[MAX_TX_CHANNELS];

static TransportRxBufferTable sTransportRxBuffer;
static TransportTxBufferTable sTransportTxBuffer;
static TransportRxItem*       sRxItem;
static TransportTxItem*       sTxItem;

typedef enum
{
  idle = 0,
  transfer,
} TransportTxState;

static uint32_t         sMyNodeId;
static TransportTxState sTxState;
static const uint32_t   sHibiAddrTable[MAX_NODES] = {0x1000, 0x3000, 0x5000};

// transport_init
void
transport_init(const uint32_t node_id)
{
  sRxItem   = &sTransportRxBuffer[0];
  sTxItem   = &sTransportTxBuffer[0];
  sTxState  = idle;
  sMyNodeId = node_id;
  
  transport_rx_buf_init();
  
  for(int i=0; i<MAX_RX_CHANNELS; ++i) {
    
    sTransportRxBuffer[i].current_length = 0;
    sTransportRxBuffer[i].total_length   = 1;
    sTransportRxBuffer[i].endpoint       = 0;
    sTransportRxBuffer[i].msg_buf        = transport_rx_buf_get_handle(i);
  }
  
  for(int i=0; i<MAX_TX_CHANNELS; ++i) {
    sTransportTxBuffer[i].current_length = 0;
    sTransportTxBuffer[i].total_length   = 1;
    sTransportRxBuffer[i].endpoint       = 0;
  }
  
}

// transport_create_endpoint
uint32_t
transport_create_endpoint(const uint32_t port)
{
  return (sMyNodeId << 16) | port;
}

// transport_get_endpoint
uint32_t
transport_get_endpoint(const uint32_t node_id, const uint32_t port)
{
  return (node_id << 16) | port;
}

// transport_send_msg_b
TransportStatus
transport_send_msg_b(uint32_t receive_endpoint, size_t size, uint32_t* buffer)
{
  const TransportMsgBuf* const msg_buf = transport_tx_buf_get_handle();
  const TransportMsg msg = {.endpoint = receive_endpoint, .size = size, .buf = buffer};
  
  while(msg_buf->is_full()) {
    transport_tx();
  }  
  msg_buf->push(msg);
  
  while(transport_tx() == TRANSPORT_BUSY)
  {}
  
  return TRANSPORT_OK;
}

// transport_send_msg_nb
TransportStatus
transport_send_msg_nb(uint32_t receive_endpoint, size_t size, uint32_t* buffer)
{
  const TransportMsgBuf* const msg_buf = transport_tx_buf_get_handle();
  const TransportMsg msg = {.endpoint = receive_endpoint, .size = size, .buf = buffer};
  
  if(msg_buf->is_full()) {
    return TRANSPORT_EOB;
  }
  msg_buf->push(msg);
  return TRANSPORT_OK;
}

// transport_receive_msg_b
TransportStatus
transport_receive_msg_b(const uint32_t sending_endpoint, size_t size, uint32_t* const buffer)
{ 
  const uint32_t port = sending_endpoint & 0xFF;
  const TransportMsgBuf* const msg_buf = sTransportRxBuffer[port].msg_buf;
  
  /* TODO: implies no data arrives before port is established -> need to check in transport_rx */
  sTransportRxBuffer[port].total_length = size;
  
  while(msg_buf->is_empty()) {
    transport_rx();
  };
  
  const TransportMsg msg = msg_buf->pop();
  memcpy((void*)buffer, (void*)msg.buf, (msg.size << 2));

  return TRANSPORT_OK;
}

// transport_receive_msg_nb
TransportStatus
transport_receive_msg_nb(const uint32_t sending_endpoint, size_t size, uint32_t* const buffer)
{
  const uint32_t port = sending_endpoint & 0xFF;
  const TransportMsgBuf* const msg_buf = sTransportRxBuffer[port].msg_buf;
  
  /* TODO: implies no data arrives before port is established -> need to check in transport_rx */
  sTransportRxBuffer[port].total_length = size;
  
  if(msg_buf->is_empty()) {
    return TRANSPORT_EOB;
  }
  
  const TransportMsg msg = msg_buf->pop();
  memcpy((void*)buffer, (void*)msg.buf, (msg.size << 2));

  return TRANSPORT_OK;
}

// transport_rx
// TODO: must only be called if a receive was setup before
void
transport_rx()
{
  while(1) {
    HibiComm comm;
    uint32_t data;
    Bool     av;
  
    if(!_hibi_receive_raw_nb_(&comm, &av, &data)) {
      return;
    }
    
    if(av == 1) {
      const uint32_t channel = data & 0xFF;
      sRxItem = &sTransportRxBuffer[channel];
    }
    else {
      sRxItem->buffer[sRxItem->current_length++] = data;
      if(sRxItem->current_length == sRxItem->total_length) {
        const TransportMsg msg = {.endpoint = sRxItem->endpoint, .size = sRxItem->total_length, .buf = &sRxItem->buffer[0]};
        
        /* TODO what if buffer is full? */
        sRxItem->msg_buf->push(msg);
        sRxItem->current_length = 0;
      }
    }
  }
}

// transport_tx
TransportStatus
transport_tx()
{
  const TransportMsgBuf* const msg_buf = transport_tx_buf_get_handle();
  uint32_t hibi_addr;
  
  while(1) {
    
    switch(sTxState)
    {
      case idle:
          if(msg_buf->is_empty()) {
            return TRANSPORT_OK;
          }
          
          const TransportMsg msg = msg_buf->pop();
          sTxItem  = &sTransportTxBuffer[msg.endpoint & 0xFF];
          sTxItem->endpoint     = msg.endpoint;
          sTxItem->total_length = msg.size;
          
          memcpy((void*)sTxItem->buffer, (void*)msg.buf, (msg.size << 2));
          sTxState = transfer;
      case transfer:
        hibi_addr = sHibiAddrTable[sTxItem->endpoint >> 16] | (sTxItem->endpoint & 0xFF);
        
        if(_hibi_send_raw_nb_(HIBI_WR_PRIO_DATA, 1, hibi_addr)) {
          return TRANSPORT_BUSY;
        }
        
        while(sTxItem->current_length < sTxItem->total_length) {
          if(_hibi_push_raw_nb_(sTxItem->buffer[sTxItem->current_length])) {
            return TRANSPORT_BUSY;
          }
          
          sTxItem->current_length++;
        }
        
        sTxItem->current_length = 0;
        sTxState                = idle;
        break;
      default:
        break;
    } 
  } 
}


