#ifndef LIBC_H
#define LIBC_H

#include <stdarg.h>

// Typedefs
typedef unsigned int   uint32;
typedef unsigned short uint16;
typedef unsigned char  uint8;

// Memory Access

#define MemoryRead(A) (*(volatile uint32*)(A))
#define MemoryWrite(A,V) *(volatile uint32*)(A)=(V)


//#define printf     xil_printf
//#define scanf

#ifndef NULL
#define NULL (void*)0
#endif

#define isprint(c) (' '<=(c)&&(c)<='~')
#define isspace(c) ((c)==' '||(c)=='\t'||(c)=='\n'||(c)=='\r')
#define isdigit(c) ('0'<=(c)&&(c)<='9')
#define islower(c) ('a'<=(c)&&(c)<='z')
#define isupper(c) ('A'<=(c)&&(c)<='Z')
#define isalpha(c) (islower(c)||isupper(c))
#define isalnum(c) (isalpha(c)||isdigit(c))

char *strchr(const char* str, int ch);
char *strcpy(char *dst, const char *src);
char *strncpy(char *dst, const char *src, int count);
char *strcat(char *dst, const char *src);
char *strncat(char *dst, const char *src, int count);
int   strcmp(const char *string1, const char *string2);
int   strncmp(const char *string1, const char *string2, int count);
char *strstr(const char *string, const char *find);
int   strlen(const char *string);
void *memcpy(void *dst, const void *src, unsigned long bytes);
void *memmove(void *dst, const void *src, unsigned long bytes);
int   memcmp(const void *cs, const void *ct, unsigned long bytes);
void *memset(void *dst, int c, unsigned long bytes);
int   abs(int n);
int   rand(void);
void  srand(unsigned int seed);
long  strtol(const char *s, char **end, int base);
int   atoi(const char *s);
char *itoa(int num, char *dst, int base);

int printf(const char* format, ...);
int sprintf(char *s, const char *format, ...);
int sscanf(const char *s, const char *format, ...);

int vsprintf(char *s, const char *format, va_list va);

int stoi(const char* str);

#endif //LIBC_H

