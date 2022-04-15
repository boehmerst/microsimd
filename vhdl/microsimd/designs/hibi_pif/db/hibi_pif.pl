#!/usr/bin/perl

use strict;

###############################################################################
# Database Description
###############################################################################

my $ref_cfg = {
  offset => 0x14,
  name   => 'HIBI_TXPIF_CFG',
  desc   => 'config register',
  fld    => [
    { name => 'hsize',    slc => [0,   8],  type => 'rw',  rst => 0x00,  desc => 'hsize' },
    { name => 'vsize',    slc => [16, 24],  type => 'rw',  rst => 0x00,  desc => 'vsize' },
  ]
};

my $ref_trig = {
  offset => 0x15,
  name   => 'HIBI_TRIG_CTRL',
  desc   => 'trigger register',
  fld    => [
    { name => 'le',       slc => [0, 0],    type => 'xw',  rst => 0x00,  desc => 'le trigger' },
    { name => 'fe',       slc => [1, 1],    type => 'xw',  rst => 0x00,  desc => 'fe trigger' },
  ]
};

my $ref_ctrl = {
  offset => 0x16,
  name   => 'HIBI_PIF_CTRL',
  desc   => 'control register',
  fld    => [
    { name => 'txen',     slc => [4, 4],    type => 'rw',  rst => 0x00,  desc => 'tx enable'  },
    { name => 'rxen',     slc => [5, 5],    type => 'rw',  rst => 0x00,  desc => 'rx enable'  },
  ]
};

my $ref_status = {
  offset => 0x17,
  name   => 'HIBI_TXPIF_STATUS',
  desc   => 'status register',
  fld    => [
    { name => 'busy',     slc => [0, 0],    type => 'ro',  rst => 0x00,  desc => 'busy status'  },
    { name => 'hsync',    slc => [1, 1],    type => 'ro',  rst => 0x00,  desc => 'hsync status' },
    { name => 'vsync',    slc => [2, 2],    type => 'ro',  rst => 0x00,  desc => 'vsync status' },
  ]
};

my $descriptor = [
  $ref_cfg,
  $ref_trig,
  $ref_ctrl,
  $ref_status,
];

