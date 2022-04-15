#!/usr/bin/perl

use strict;

my $ref_sp0 = {
  offset => 0x00,
  name   => 'SCRATCHPAD0',
  desc   => 'scratchpad register',
  fld    => [
    { name => 'scratch',    slc => [0,  3],  type => 'rw',  rst => 0x00,  desc => 'reg' },
  ]
};

my $ref_sp1 = {
  offset => 0x01,
  name   => 'SCRATCHPAD1',
  desc   => 'scratchpad register',
  fld    => [
    { name => 'scratch',    slc => [0,  3],  type => 'rw',  rst => 0x00,  desc => 'reg' },
  ]
};

my $ref_gpin1 = {
  offset => 0x02,
  name   => 'GPIN0',
  desc   => 'input register',
  fld    => [
    { name => 'input',    slc => [0,  1],  type => 'ro',  rst => 0x00,  desc => 'reg' },
  ]
};

my $ref_gpin2 = {
  offset => 0x03,
  name   => 'GPIN1',
  desc   => 'input register',
  fld    => [
    { name => 'input',    slc => [0,  1],  type => 'ro',  rst => 0x00,  desc => 'reg' },
  ]
};


my $descriptor = [
  $ref_sp0,
  $ref_sp1,
  $ref_gpin1,
  $ref_gpin2,
];
