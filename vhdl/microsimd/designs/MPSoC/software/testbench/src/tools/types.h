#ifndef TOOLS_TYPES_H
#define TOOLS_TYPES_H

typedef unsigned long long uint64_t;
typedef unsigned long      uint32_t;
typedef unsigned short     uint16_t;
typedef unsigned char      uint8_t;

typedef long   int32_t;
typedef short  int16_t;
typedef char   int8_t;

typedef unsigned long bool;
typedef unsigned long Bool;
typedef unsigned long size_t;

typedef	unsigned char   uchar_t;
typedef	unsigned short	ushort_t;
typedef	unsigned int    uint_t;
typedef	unsigned long   ulong_t;

typedef char  char_t;
typedef short	short_t;
typedef int   int_t;
typedef long  long_t;

typedef uint32_t size_t;

#define true (1)
#define false (0)

#define asm __asm__
#define countof(T) ( sizeof(T)/sizeof(T[0]) )

#define __memory_barrier() __asm__ __volatile__ ("" ::: "memory")
#define forget(x) __asm__ __volatile__("":"=m"(x):"m"(x));


#endif // TOOLS_TYPES_H

