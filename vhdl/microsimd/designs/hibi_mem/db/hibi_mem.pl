#-------------------------------------------------------------------------------
#-- Title      : hibi_mem
#-- Project    :
#-------------------------------------------------------------------------------
#-- File       : hibi_mem.pl
#-- Author     : deboehse
#-- Company    : private
#-- Created    : 
#-- Last update: 
#-- Platform   : 
#-- Standard   : VHDL'93
#-------------------------------------------------------------------------------
#-- Description: automated generated do not edit manually
#-------------------------------------------------------------------------------
#-- Copyright (c) 2013 Stephan Böhmer
#-------------------------------------------------------------------------------
#-- Revisions  :
#-- Date        Version  Author  Description
#--             1.0      SBo     Created
#-------------------------------------------------------------------------------

#!/usr/bin/perl

use strict;

my $ref_ctrl = {
  offset => 0x00,
  name   => 'HIBI_DMA_CTRL',
  desc   => 'control register',
  fld    => [
    { name => 'en',    slc => [0,  0],  type => 'rw',  rst => 0x00,  desc => 'enable' },
  ]
};

my $ref_stat = {
  offset => 0x01,
  name   => 'HIBI_DMA_STATUS',
  desc   => 'status register',
  fld    => [
  { name => 'busy0',    slc => [0,  0],  type => 'ro',  rst => 0x00,  desc => 'transfer ongoing' },
  { name => 'busy1',    slc => [1,  1],  type => 'ro',  rst => 0x00,  desc => 'transfer ongoing' },
  { name => 'busy2',    slc => [2,  2],  type => 'ro',  rst => 0x00,  desc => 'transfer ongoing' },
  { name => 'busy3',    slc => [3,  3],  type => 'ro',  rst => 0x00,  desc => 'transfer ongoing' },
  ]
};

my $ref_trig = {
  offset => 0x02,
  name   => 'HIBI_DMA_TRIGGER',
  desc   => 'trigger register',
  fld    => [
  { name => 'start0',    slc => [0,  0],  type => 'xw',  rst => 0x00,  desc => 'start' },
  { name => 'start1',    slc => [1,  1],  type => 'xw',  rst => 0x00,  desc => 'start' },
  { name => 'start2',    slc => [2,  2],  type => 'xw',  rst => 0x00,  desc => 'start' },
  { name => 'start3',    slc => [3,  3],  type => 'xw',  rst => 0x00,  desc => 'start' },
  ]
};

my $ref_cfg0 = {
  offset => 0x03,
  name   => 'HIBI_DMA_CFG0',
  desc   => 'configuration register',
  fld    => [
    { name => 'count',      slc => [0,  9],  type => 'rw',  rst => 0x00,  desc => 'number of transfers'                  },
    { name => 'direction',  slc => [15, 15],  type => 'rw',  rst => 0x01,  desc => 'direction (\'0\' -> rx, \'1\' -> tx)' },
    { name => 'hibi_cmd',   slc => [16, 20],  type => 'rw',  rst => 0x02,  desc => 'hibi command to use for transfer'     },
    { name => 'const_addr', slc => [21, 21],  type => 'rw',  rst => 0x00,  desc => 'constant mem address'                 },
  ]
};

my $ref_dma_addr0 = {
  offset => 0x04,
  name   => 'HIBI_DMA_MEM_ADDR0',
  desc   => 'memory address',
  fld    => [
    { name => 'addr',    slc => [0, 8],  type => 'rw',  rst => 0x00,  desc => 'memory address' },
  ]
};

my $ref_hibi_addr0 = {
  offset => 0x05,
  name   => 'HIBI_DMA_HIBI_ADDR0',
  desc   => 'hibi address',
  fld    => [
    { name => 'addr',    slc => [0, 15],  type => 'rw',  rst => 0x00,  desc => 'hibi address' },
  ]
};

my $ref_trig_mask0 = {
  offset => 0x06,
  name   => 'HIBI_DMA_TRIGGER_MASK0',
  desc   => 'trigger mask for DMA chaining',
  fld    => [
    { name => 'mask',    slc => [0, 3],  type => 'rw',  rst => 0x00,  desc => 'trigger mask'},
  ]
};

my $ref_cfg1 = {
  offset => 0x07,
  name   => 'HIBI_DMA_CFG1',
  desc   => 'configuration register',
  fld    => [
    { name => 'count',      slc => [0,  9],  type => 'rw',  rst => 0x00,  desc => 'number of transfers'                  },
    { name => 'direction',  slc => [15, 15],  type => 'rw',  rst => 0x01,  desc => 'direction (\'0\' -> rx, \'1\' -> tx)' },
    { name => 'hibi_cmd',   slc => [16, 20],  type => 'rw',  rst => 0x02,  desc => 'hibi command to use for transfer'     },
    { name => 'const_addr', slc => [21, 21],  type => 'rw',  rst => 0x00,  desc => 'constant mem address'                 },
  ]
};

my $ref_dma_addr1 = {
  offset => 0x08,
  name   => 'HIBI_DMA_MEM_ADDR1',
  desc   => 'memory address',
  fld    => [
    { name => 'addr',    slc => [0, 8],  type => 'rw',  rst => 0x00,  desc => 'memory address' },
  ]
};

my $ref_hibi_addr1 = {
  offset => 0x09,
  name   => 'HIBI_DMA_HIBI_ADDR1',
  desc   => 'hibi address',
  fld    => [
    { name => 'addr',    slc => [0, 15],  type => 'rw',  rst => 0x00,  desc => 'hibi address' },
  ]
};

my $ref_trig_mask1 = {
  offset => 0x0a,
  name   => 'HIBI_DMA_TRIGGER_MASK1',
  desc   => 'trigger mask for DMA chaining',
  fld    => [
    { name => 'mask',    slc => [0, 3],  type => 'rw',  rst => 0x00,  desc => 'trigger mask'},
  ]
};

my $ref_cfg2 = {
  offset => 0x0b,
  name   => 'HIBI_DMA_CFG2',
  desc   => 'configuration register',
  fld    => [
    { name => 'count',      slc => [0,  9],  type => 'rw',  rst => 0x00,  desc => 'number of transfers'                  },
    { name => 'direction',  slc => [15, 15],  type => 'rw',  rst => 0x01,  desc => 'direction (\'0\' -> rx, \'1\' -> tx)' },
    { name => 'hibi_cmd',   slc => [16, 20],  type => 'rw',  rst => 0x02,  desc => 'hibi command to use for transfer'     },
    { name => 'const_addr', slc => [21, 21],  type => 'rw',  rst => 0x00,  desc => 'constant mem address'                 },
  ]
};

my $ref_dma_addr2 = {
  offset => 0x0c,
  name   => 'HIBI_DMA_MEM_ADDR2',
  desc   => 'memory address',
  fld    => [
    { name => 'addr',    slc => [0, 8],  type => 'rw',  rst => 0x00,  desc => 'memory address' },
  ]
};

my $ref_hibi_addr2 = {
  offset => 0x0d,
  name   => 'HIBI_DMA_HIBI_ADDR2',
  desc   => 'hibi address',
  fld    => [
    { name => 'addr',    slc => [0, 15],  type => 'rw',  rst => 0x00,  desc => 'hibi address' },
  ]
};

my $ref_trig_mask2 = {
  offset => 0x0e,
  name   => 'HIBI_DMA_TRIGGER_MASK2',
  desc   => 'trigger mask for DMA chaining',
  fld    => [
    { name => 'mask',    slc => [0, 3],  type => 'rw',  rst => 0x00,  desc => 'trigger mask'},
  ]
};

my $ref_cfg3 = {
  offset => 0x0f,
  name   => 'HIBI_DMA_CFG3',
  desc   => 'configuration register',
  fld    => [
    { name => 'count',      slc => [0,  9],  type => 'rw',  rst => 0x00,  desc => 'number of transfers'                  },
    { name => 'direction',  slc => [15, 15],  type => 'rw',  rst => 0x01,  desc => 'direction (\'0\' -> rx, \'1\' -> tx)' },
    { name => 'hibi_cmd',   slc => [16, 20],  type => 'rw',  rst => 0x02,  desc => 'hibi command to use for transfer'     },
    { name => 'const_addr', slc => [21, 21],  type => 'rw',  rst => 0x00,  desc => 'constant mem address'                 },
  ]
};

my $ref_dma_addr3 = {
  offset => 0x10,
  name   => 'HIBI_DMA_MEM_ADDR3',
  desc   => 'memory address',
  fld    => [
    { name => 'addr',    slc => [0, 8],  type => 'rw',  rst => 0x00,  desc => 'memory address' },
  ]
};

my $ref_hibi_addr3 = {
  offset => 0x11,
  name   => 'HIBI_DMA_HIBI_ADDR3',
  desc   => 'hibi address',
  fld    => [
    { name => 'addr',    slc => [0, 15],  type => 'rw',  rst => 0x00,  desc => 'hibi address' },
  ]
};

my $ref_trig_mask3 = {
  offset => 0x12,
  name   => 'HIBI_DMA_TRIGGER_MASK3',
  desc   => 'trigger mask for DMA chaining',
  fld    => [
    { name => 'mask',    slc => [0, 3],  type => 'rw',  rst => 0x00,  desc => 'trigger mask'},
  ]
};

my $descriptor = [
  $ref_ctrl,
  $ref_stat,
  $ref_trig,
  $ref_cfg0,
  $ref_dma_addr0,
  $ref_hibi_addr0,
  $ref_trig_mask0,
  $ref_cfg1,
  $ref_dma_addr1,
  $ref_hibi_addr1,
  $ref_trig_mask1,
  $ref_cfg2,
  $ref_dma_addr2,
  $ref_hibi_addr2,
  $ref_trig_mask2,
  $ref_cfg3,
  $ref_dma_addr3,
  $ref_hibi_addr3,
  $ref_trig_mask3,
];

