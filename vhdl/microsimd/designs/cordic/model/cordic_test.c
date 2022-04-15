#include "cordic-16bit-new.h"
#include <math.h> // for testing only!
#include <stdio.h>

#ifndef M_PI
#define M_PI           3.14159265358979323846
#endif

int main(int argc, char **argv)
{
    //int i, j;
    //int MUL_12 = (1<<(12-1));
    //int MUL_16 = (1<<(16-1));
    
    //for(i=0;i<50;i++)
    //{
    //  for(j=0;j<50;j++)
    //  {
    //    double dy = i/50.0;
    //    double dx = j/50.0;
       
        int y = 0x1FE0; //(dy)*MUL;
        int x = 0x1FE0; //(dx)*MUL;
        int z = 0x0000;; //(0.0)*MUL;
        
        cordic_vec(&y, &x, &z, 16);

        printf("result: 0x%04x, 0x%04x\n", x, z);
        
     //   const double fpatan = z/MUL;
     //   const double datan  = atan2(dy, dx);
        
     //   printf("%1.10f : %1.10f : %d\n", fpatan, datan, (int)((fpatan-datan)*MUL));
     // }
   // }
}

