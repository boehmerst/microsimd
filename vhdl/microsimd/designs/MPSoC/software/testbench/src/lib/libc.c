#include "libc.h"

char*
strchr(const char* str, int ch)
{
  char* p = (char*)str;
  char  c = ch & 0xff;

  while(*p != c)
  {
    if(*p == 0)
    {
      return 0;
    }
    p++;
  }

  return p;
}



char*
strcpy(char *dst, const char *src)
{
   char *dstSave=dst;
   int c;
   do
   {
      c = *dst++ = *src++;
   } while(c);
   return dstSave;
}


char*
strncpy(char *dst, const char *src, int count)
{
   int c=1;
   char *dstSave=dst;
   while(count-- > 0 && c)
      c = *dst++ = *src++;
   *dst = 0;
   return dstSave;
}


char*
strcat(char *dst, const char *src)
{
   int c;
   char *dstSave=dst;
   while(*dst)
      ++dst;
   do
   {
      c = *dst++ = *src++;
   } while(c);
   return dstSave;
}


char*
strncat(char *dst, const char *src, int count)
{
   int c=1;
   char *dstSave=dst;
   while(*dst && --count > 0)
      ++dst;
   while(--count > 0 && c)
      c = *dst++ = *src++;
   *dst = 0;
   return dstSave;
}


int
strcmp(const char *string1, const char *string2)
{
   int diff, c;
   for(;;)
   {
      diff = *string1++ - (c = *string2++);
      if(diff)
         return diff;
      if(c == 0)
         return 0;
   }
}


int
strncmp(const char *string1, const char *string2, int count)
{
   int diff, c;
   while(count-- > 0)
   {
      diff = *string1++ - (c = *string2++);
      if(diff)
         return diff;
      if(c == 0)
         return 0;
   }
   return 0;
}


char*
strstr(const char *string, const char *find)
{
   int i;
   for(;;)
   {
      for(i = 0; string[i] == find[i] && find[i]; ++i) ;
      if(find[i] == 0)
         return (char*)string;
      if(*string++ == 0)
         return 0;
   }
}


int
strlen(const char *string)
{
   const char *base=string;
   while(*string++) ;
   return string - base - 1;
}


void*
memcpy(void *dst, const void *src, unsigned long bytes)
{
   if(((uint32)dst | (uint32)src | bytes) & 3)
   {
      uint8 *Dst = (uint8*)dst, *Src = (uint8*)src;
      while((int)bytes-- > 0)
         *Dst++ = *Src++;
   }
   else
   {
      uint32 *Dst32 = (uint32*)dst, *Src32 = (uint32*)src;
      bytes >>= 2;
      while((int)bytes-- > 0)
         *Dst32++ = *Src32++;
   }
   return dst;
}


void*
memmove(void *dst, const void *src, unsigned long bytes)
{
   uint8 *Dst = (uint8*)dst;
   uint8 *Src = (uint8*)src;
   if(Dst < Src)
   {
      while((int)bytes-- > 0)
         *Dst++ = *Src++;
   }
   else
   {
      Dst += bytes;
      Src += bytes;
      while((int)bytes-- > 0)
         *--Dst = *--Src;
   }
   return dst;
}


int
memcmp(const void *cs, const void *ct, unsigned long bytes)
{
   uint8 *Dst = (uint8*)cs;
   uint8 *Src = (uint8*)ct;
   int diff;
   while((int)bytes-- > 0)
   {
      diff = *Dst++ - *Src++;
      if(diff)
         return diff;
   }
   return 0;
}


void*
memset(void *dst, int c, unsigned long bytes)
{
   uint8 *Dst = (uint8*)dst;
   while((int)bytes-- > 0)
      *Dst++ = (uint8)c;
   return dst;
}


int
abs(int n)
{
   return n>=0 ? n : -n;
}


static uint32 Rand1=0x1f2bcda3, Rand2=0xdeafbeef, Rand3=0xc5134306;

int
rand(void)
{
   int shift;
   Rand1 += 0x13423123 + Rand2;
   Rand2 += 0x2312fdea + Rand3;
   Rand3 += 0xf2a12de1;
   shift = Rand3 & 31;
   Rand1 = (Rand1 << (32 - shift)) | (Rand1 >> shift);
   Rand3 ^= Rand1;
   shift = (Rand3 >> 8) & 31;
   Rand2 = (Rand2 << (32 - shift)) | (Rand2 >> shift);
   return Rand1;
}


void
srand(unsigned int seed)
{
   Rand1 = seed;
}


long
strtol(const char *s, char **end, int base)
{
   int i;
   unsigned long ch, value=0, neg=0;

   if(s[0] == '-')
   {
      neg = 1;
      ++s;
   }
   if(s[0] == '0' && s[1] == 'x')
   {
      base = 16;
      s += 2;
   }
   for(i = 0; i <= 8; ++i)
   {
      ch = *s++;
      if('0' <= ch && ch <= '9')
         ch -= '0';
      else if('A' <= ch && ch <= 'Z')
         ch = ch - 'A' + 10;
      else if('a' <= ch && ch <= 'z')
         ch = ch - 'a' + 10;
      else
         break;
      value = value * base + ch;
   }
   if(end)
      *end = (char*)s - 1;
   if(neg)
      value = -(int)value;
   return value;
}


int
atoi(const char *s)
{
   return strtol(s, 0, 10);
}


char*
itoa(int num, char *dst, int base)
{
   int digit, negate=0, place;
   char c, text[20];

   if(base == 10 && num < 0)
   {
      num = -num;
      negate = 1;
   }
   text[16] = 0;
   for(place = 15; place >= 0; --place)
   {
      digit = (unsigned int)num % (unsigned int)base;
      if(num == 0 && place < 15 && base == 10 && negate)
      {
         c = '-';
         negate = 0;
      }
      else if(digit < 10)
         c = (char)('0' + digit);
      else
         c = (char)('a' + digit - 10);
      text[place] = c;
      num = (unsigned int)num / (unsigned int)base;
      if(num == 0 && negate == 0)
         break;
   }
   strcpy(dst, text + place);
   return dst;
}


int
sprintf(char *s, const char *format, ...)
{
   int argv[8];
   int argc=0, width, length;
   char f, text[20], fill;

   va_list va;
   va_start( va, format );

   argv[0] = va_arg(va, int); argv[1] = va_arg(va, int); argv[2] = va_arg(va, int); argv[3] = va_arg(va, int);
   argv[4] = va_arg(va, int); argv[5] = va_arg(va, int); argv[6] = va_arg(va, int); argv[7] = va_arg(va, int);

   va_end(va);

   for(;;)
   {
      f = *format++;

      if(f == 0)
      {
         return argc;
      }

      if(f == '%')
      {
         width = 0;
         fill = ' ';
         f = *format++;
         while('0' <= f && f <= '9')
         {
            width = width * 10 + f - '0';
            f = *format++;
         }
         if(f == '.')
         {
            fill = '0';
            f = *format++;
         }
         if(f == 0)
            return argc;

         if(f == 'd' || f=='i')
         {
            memset(s, fill, width);
            itoa(argv[argc++], text, 10);
            length = (int)strlen(text);
            if(width < length)
               width = length;
            strcpy(s + width - length, text);
         }
         else if(f == 'x' || f == 'f')
         {
            memset(s, '0', width);
            itoa(argv[argc++], text, 16);
            length = (int)strlen(text);
            if(width < length)
               width = length;
            strcpy(s + width - length, text);
         }
         else if(f == 'c')
         {
            *s++ = (char)argv[argc++];
            *s = 0;
         }
         else if(f == 's')
         {
            length = strlen((char*)argv[argc]);
            if(width > length)
            {
               memset(s, ' ', width - length);
               s += width - length;
            }
            strcpy(s, (char*)argv[argc++]);
         }
         s += strlen(s);
      }
      else
      {
         if(f == '\n')
         {
            *s++ = '\r';
         }

         *s++ = f;
         if(f == '\r' && *format == '\n')
         {
            *s++ = *format++;
         }
      }
      *s = 0;
   }
}


//TODO reuse upper code
int
vsprintf(char *s, const char *format, va_list va)
{
   int argv[8];
   int argc=0, width, length;
   char f, text[20], fill;

   argv[0] = va_arg(va, int); argv[1] = va_arg(va, int); argv[2] = va_arg(va, int); argv[3] = va_arg(va, int);
   argv[4] = va_arg(va, int); argv[5] = va_arg(va, int); argv[6] = va_arg(va, int); argv[7] = va_arg(va, int);

   *s = 0;

   for(;;)
   {
      f = *format++;

      if(f == 0)
      {
    	  return argc;
      }
      else if(f == '%')
      {
         width = 0;
         fill = ' ';
         f = *format++;
         while('0' <= f && f <= '9')
         {
            width = width * 10 + f - '0';
            f = *format++;
         }
         if(f == '.')
         {
            fill = '0';
            f = *format++;
         }
         if(f == 0)
            return argc;

         if(f == 'd')
         {
            memset(s, fill, width);
            itoa(argv[argc++], text, 10);
            length = (int)strlen(text);
            if(width < length)
               width = length;
            strcpy(s + width - length, text);
         }
         else if(f == 'x' || f == 'f')
         {
            memset(s, '0', width);
            itoa(argv[argc++], text, 16);
            length = (int)strlen(text);
            if(width < length)
               width = length;
            strcpy(s + width - length, text);
         }
         else if(f == 'c')
         {
            *s++ = (char)argv[argc++];
            *s = 0;
         }
         else if(f == 's')
         {
            length = strlen((char*)argv[argc]);
            if(width > length)
            {
               memset(s, ' ', width - length);
               s += width - length;
            }
            strcpy(s, (char*)argv[argc++]);
         }
         s += strlen(s);
      }
      else
      {
         if(f == '\n')
         {
            *s++ = '\r';
         }

         *s++ = f;

         if(f == '\r' && *format == '\n')
         {
            *s++ = *format++;
         }
      }

      *s = 0;
   }
}



int
sscanf(const char *s, const char *format,...)
{
   int argv[8];
   int argc=0;
   char f, *ptr;

   va_list va;
   va_start( va, format );

   argv[0] = va_arg(va, int); argv[1] = va_arg(va, int); argv[2] = va_arg(va, int); argv[3] = va_arg(va, int);
   argv[4] = va_arg(va, int); argv[5] = va_arg(va, int); argv[6] = va_arg(va, int); argv[7] = va_arg(va, int);

   va_end(va);

   for(;;)
   {
      if(*s == 0)
         return argc;
      f = *format++;
      if(f == 0)
         return argc;
      else if(f == '%')
      {
         while(isspace(*s))
            ++s;
         f = *format++;
         if(f == 0)
            return argc;
         if(f == 'd')
            *(int*)argv[argc++] = strtol(s, (char**)&s, 10);
         else if(f == 'x')
            *(int*)argv[argc++] = strtol(s, (char**)&s, 16);
         else if(f == 'c')
            *(char*)argv[argc++] = *s++;
         else if(f == 's')
         {
            ptr = (char*)argv[argc++];
            while(!isspace(*s))
               *ptr++ = *s++;
            *ptr = 0;
         }
      }
      else
      {
         while(*s && *s != f)
            ++s;
         if(*s)
            ++s;
      }
   }
}

int stoi(const char* str)
{
  int value = 0;
  
  //check if hex
  if(str[1] == 'x')
  {
    sscanf(&str[2], "%x", &value);
  }
  else
  {
    sscanf(&str[0], "%d", &value);
  }
  
  return value;
}

