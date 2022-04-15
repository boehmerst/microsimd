#!/usr/bin/perl

use strict;

###############################################################################
# Database Description
###############################################################################

my $ref_cfg = {
  offset => 0x00,
  name   => 'HIBI_CFG',
  desc   => 'confic register',
  fld    => [
    { name => 'en',    slc => [0,  0],  type => 'rw',  rst => 0x00,  desc => 'enable' },
    { name => 'comm',  slc => [4,  8],  type => 'xw',  rst => 0x00,  desc => 'hibi command' },
    { name => 'av',    slc => [12,12],  type => 'xw',  rst => 0x00,  desc => 'address valid (1 addr 0 data)' },  
  ]
};

my $ref_stat = {
  offset => 0x01,
  name   => 'HIBI_STAT',
  desc   => 'status register',
  fld    => [
    { name => 'en',    slc => [0,  0],  type => 'ro',  rst => 0x00,  desc => 'enable' },
    { name => 'comm',  slc => [4,  8],  type => 'xr',  rst => 0x00,  desc => 'hibi command' },
    { name => 'av',    slc => [12,12],  type => 'xr',  rst => 0x00,  desc => 'address valid (1 addr 0 data)' },
    { name => 'valid', slc => [13,13],  type => 'xr',  rst => 0x00,  desc => 'valid rx data available' },
  ]
};

my $ref_wdata = {
  offset => 0x02,
  name   => 'HIBI_TX',
  desc   => 'hibi tx data',
  fld    => [
    { name => 'data', slc => [0,31], type => 'xw',  rst => 0x00,  desc => 'hibi data to be transmitted' },
  ]
};

my $ref_rdata = {
  offset => 0x03,
  name   => 'HIBI_RX',
  desc   => 'hibi rx data',
  fld    => [
    { name => 'data', slc => [0,31], type => 'xr',  rst => 0x0, desc => 'hibi data being received' },
  ]
};

my $descriptor = [
  $ref_cfg,
  $ref_stat,
  $ref_wdata,
  $ref_rdata
];

