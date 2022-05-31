use strict;

my $ref_cpu_en = {
  offset => 0x0c,
  name   => 'HIBI_CPU_ENABLE',
  desc   => 'cpu enable',
  fld    => [
    { name => 'en',    slc => [0,  0],  type => 'rw',  rst => 0x00,  desc => 'enable' },
  ]
};


my $descriptor = [
  $ref_cpu_en,
];

