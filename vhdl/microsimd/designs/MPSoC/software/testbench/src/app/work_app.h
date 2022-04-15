#ifndef APP_WORK_APP_H
#define APP_WORK_APP_H

#include "types.h"

extern const uint32_t msg_abort;

void work_app();

static inline uint32_t abort_msg() {
  return msg_abort;
}

#endif

