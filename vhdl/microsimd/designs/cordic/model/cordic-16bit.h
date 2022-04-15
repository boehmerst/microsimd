//Cordic in 16 bit signed fixed point math
//Function is valid for arguments in range -pi/2 -- pi/2
//for values pi/2--pi: value = half_pi-(theta-half_pi) and similarly for values -pi---pi/2
//
// 1.0 = 8192
// 1/k = 0.6072529350088812561694
// pi = 3.1415926536897932384626
//Constants
#define cordic_1K 0x0000136E
#define half_pi 0x00003243
#define MUL 8192.000000
#define CORDIC_NTAB 16
#define ovflw_mask ((int)(-1) >> (8*sizeof(int) - 16))
int cordic_ctab [] = {0x00001922, 0x00000ED6, 0x000007D7, 0x000003FB, 0x000001FF, 0x00000100, 0x00000080, 0x00000040, 0x00000020, 0x00000010, 0x00000008, 0x00000004, 0x00000002, 0x00000001, 0x00000000, 0x00000000, };

int cordic_sra(int vec, unsigned int shift)
{
  int result = vec >> shift;
  int interm = vec >> (shift-1);
  if( (interm == -1) && (shift != 0) ) {
    return 0;
  }
  else {
    return result;
  }
}

void cordic_rot(int theta, int *s, int *c, int n)
{
  int k, d, tx, ty, tz;
  int x=cordic_1K,y=0,z=theta;
  n = (n>CORDIC_NTAB) ? CORDIC_NTAB : n;
  for (k=0; k<n; ++k)
  {
    d = z>>15;
    //get sign. for other architectures, you might want to use the more portable version
    //d = z>=0 ? 0 : -1;
    tx = x - ((cordic_sra(y, k) ^ d) - d);
    ty = y + ((cordic_sra(x, k) ^ d) - d);
    tz = z - ((cordic_ctab[k] ^ d) - d);
    x = tx & ovflw_mask; y = ty & ovflw_mask; z = tz & ovflw_mask;
  }  
 *c = x; *s = y;
}

void cordic_vec(int *y, int *x, int *z, int n)
{
  int k, d, tx, ty, tz;
  int x_int = *x, y_int = *y, z_int = *z;
  n = (n>CORDIC_NTAB) ? CORDIC_NTAB : n;
  for (k=0; k<n; ++k)
  {
    d = y_int >= 0 ? -1 : 0;
    tx = x_int - ((cordic_sra(y_int, k) ^ d) - d);
    ty = y_int + ((cordic_sra(x_int, k) ^ d) - d);
    tz = z_int - ((cordic_ctab[k] ^ d) - d);
    x_int = tx & ovflw_mask; y_int = ty & ovflw_mask; z_int = tz & ovflw_mask;
  }
  *x = x_int; *y = y_int; *z = z_int;
}
