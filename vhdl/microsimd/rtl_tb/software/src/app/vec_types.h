#ifndef APP_VEC_TYPES_H
#define APP_VEC_TYPES_H

/******************************************************************************/
/* integer vector type definitions                                            */
/******************************************************************************/
typedef union
{
  unsigned int all;
  int          i32;
} vec32i32;

typedef struct
{
  vec32i32 low;
  vec32i32 high;
} vec64i32;

typedef union
{
  unsigned int all;
  short        i16[2];
} vec32i16;

typedef struct
{
  vec32i16 low;
  vec32i16 high;
} vec64i16;

typedef union
{
  unsigned int all;
  char         i8[4];
} vec32i8;

typedef struct
{
  vec32i8 low;
  vec32i8 high;
} vec64i8;

/******************************************************************************/
/* unsigned integer vector type definitions                                   */
/******************************************************************************/
typedef union
{
  unsigned int all;
  unsigned int u32;
} vec32u32;

typedef struct
{
  vec32u32 low;
  vec32u32 high;
} vec64u32;

typedef union
{
  unsigned int   all;
  unsigned short u16[2];
} vec32u16;

typedef struct
{
  vec32u16 low;
  vec32u16 high;
} vec64u16;

typedef union
{
  unsigned int  all;
  unsigned char u8[4];
} vec32u8;

typedef struct
{
  vec32u8 low;
  vec32u8 high;
} vec64u8;

/******************************************************************************/
/* signed integer vector type definitions                                     */
/******************************************************************************/
typedef union
{
  unsigned int all;
  signed int   s32;
} vec32s32;

typedef struct
{
  vec32s32 low;
  vec32s32 high;
} vec64s32;

typedef struct
{
  unsigned int   all;
  unsigned short s16[2];
} vec32s16;

typedef struct
{
  vec32s16 low;
  vec32s16 high;
} vec64s16;

typedef struct
{
  unsigned int all;
  signed char  s8[4];
} vec32s8;

typedef struct
{
  vec32s8 low;
  vec32s8 high;
} vec64s8;

#endif // APP_VEC_TYPES_H
