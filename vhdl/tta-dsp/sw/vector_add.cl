/* dot.cl */
__attribute__((reqd_work_group_size(4, 1, 1)))
kernel void
vector_add (global const int *a, global const int *b, global int *c) 
{
  int gid = get_global_id(0);
  c[gid]  = a[gid] + b[gid];
} 

