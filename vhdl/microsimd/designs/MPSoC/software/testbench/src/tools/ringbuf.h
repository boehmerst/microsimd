/******************************************************************************/
/* This is a generic ring buffer. Do not include directly since it is limited */
/* to one and only one buffer instance. Use a wrapper file around this for    */
/* each and every buffer you need in your design!                             */
/* e.g.: out_buf.h                                                            */
/* #define T unsigned char                                                    */
/* #include "ringbuf.h"                                                       */
/*                                                                            */
/******************************************************************************/
#ifndef RINGBUF_H
#define RINGBUF_H

#include "types.h"

typedef struct RingBuf
{
  T* const          mMem;            // pointer to the actual buffer
  volatile uint32_t mReadPos;        // read position
  volatile uint32_t mWritePos;       // write position
  uint32_t          N;               // buffer size
}RingBuf;

static T mem[((uint32_t)1 << BUFFER_SIZE_POW_2)];
static RingBuf buf =
{
  //Memory area, Read Pos, Write Pos, Size
  mem, 0, 0, BUFFER_SIZE_POW_2
};

inline static bool isFull();
inline static void incPos(volatile uint32_t* pos);
inline static bool isEmpty();
inline static bool isFull();


inline static void push(T item)
{
  buf.mMem[buf.mWritePos] = item;
  
  if(!isFull())
  {
    incPos(&buf.mWritePos);
  }
}

inline static void pushBuf(const T* items, uint32_t len)
{
  for (uint32_t i=0; i<len; i++)
  {
    push(items[i]);
  }
}

inline static T pop()
{
  const T item = buf.mMem[buf.mReadPos];

  if (!isEmpty())
  {
    incPos(&buf.mReadPos);
  }

	return item;
}

inline static T peek()
{
  const T item = buf.mMem[buf.mReadPos];

  return item;
}

inline static void clear()
{
  buf.mWritePos = buf.mReadPos;
}

inline static bool isEmpty()
{
  return buf.mReadPos == buf.mWritePos;
}

inline static bool isFull()
{
  uint32_t next_pos = buf.mWritePos;

  incPos(&next_pos);

  return next_pos == buf.mReadPos;
}

inline static uint32_t getUsed()
{
  if(buf.mWritePos >= buf.mReadPos)
  {
    return buf.mWritePos - buf.mReadPos;
  }
  else
  {
    return ((1<<(buf.N)) - buf.mReadPos) + buf.mWritePos;
  }
}

inline static uint32_t getFree()
{
  return (1<<(buf.N)) - getUsed();
}

inline static void incPos(volatile uint32_t* pos)
{
  const uint32_t old_pos = *pos;
  const uint32_t new_pos = (old_pos+1) & ((1<<(buf.N))-1);

  *pos = new_pos;
}

#endif

