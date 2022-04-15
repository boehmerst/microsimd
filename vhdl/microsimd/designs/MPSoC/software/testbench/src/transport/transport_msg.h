#ifndef TRANSPORT_TRANSPORT_MSG_H
#define TRANSPORT_TRANSPORT_MSG_H

#include "types.h"

typedef struct
{
  uint32_t  endpoint;
  size_t    size;
  uint32_t* buf;
} TransportMsg;

typedef void         (*PushFunc)(TransportMsg);
typedef TransportMsg (*PopFunc)();
typedef Bool         (*QueryFunc)();

typedef struct
{
  PushFunc  push;
  PopFunc   pop;
  PopFunc   peek;
  QueryFunc is_empty;
  QueryFunc is_full;
}TransportMsgBuf;

typedef TransportMsgBuf TransportMsgHandle;
typedef TransportMsgHandle* TransportMsgHamdleTable[4];

#endif

