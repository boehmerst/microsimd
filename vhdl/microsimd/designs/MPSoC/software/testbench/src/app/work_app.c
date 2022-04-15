#include "work_app.h"
#include "driver/hibi/hibi_dma.h"
#include "driver/hibi/hibi_link.h"
#include "driver/cpu/cpu.h"

#define BUFFER_SIZE 352

static volatile unsigned char buffer1[2][BUFFER_SIZE] __attribute__((section(".mem2")));
static volatile unsigned char buffer2[2][BUFFER_SIZE] __attribute__((section(".mem2")));

void init()
{
  



}



/* work_app */
void work_app() 
{

  buffer1[0][0] = 1;
  buffer2[0][0] = 1;
}

