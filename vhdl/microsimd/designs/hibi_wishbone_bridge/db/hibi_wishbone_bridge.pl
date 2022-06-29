#-------------------------------------------------------------------------------
#-- Title      : hibi_wishbone_bridge
#-- Project    :
#-------------------------------------------------------------------------------
#-- File       : hibi_wishbone_bridge.pl
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
  ]
};

my $ref_trig = {
  offset => 0x02,
  name   => 'HIBI_DMA_TRIGGER',
  desc   => 'trigger register',
  fld    => [
  { name => 'start0',    slc => [0,  0],  type => 'xw',  rst => 0x00,  desc => 'start' },
  { name => 'start1',    slc => [1,  1],  type => 'xw',  rst => 0x00,  desc => 'start' },
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
    { name => 'addr',    slc => [0, 2],  type => 'rw',  rst => 0x00,  desc => 'memory address' },
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
    { name => 'mask',    slc => [0, 1],  type => 'rw',  rst => 0x00,  desc => 'trigger mask'},
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
    { name => 'addr',    slc => [0, 2],  type => 'rw',  rst => 0x00,  desc => 'memory address' },
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
    { name => 'mask',    slc => [0, 1],  type => 'rw',  rst => 0x00,  desc => 'trigger mask'},
  ]
};

my $ref_gpio = {
  offset =>  0x0b,
  name  => 'HIBI_DMA_GPIO',
  desc  => 'general purpose I/O',
  fld   => [
    { name => 'GPIO_0',    slc => [ 0,  0], type => 'xrw', rst => 0x00, desc => 'GPIO0'},
    { name => 'GPIO_1',    slc => [ 1,  1], type => 'xrw', rst => 0x00, desc => 'GPIO1'},
    { name => 'GPIO_2',    slc => [ 2,  2], type => 'xrw', rst => 0x00, desc => 'GPIO2'},
    { name => 'GPIO_3',    slc => [ 3,  3], type => 'xrw', rst => 0x00, desc => 'GPIO3'},
    { name => 'GPIO_4',    slc => [ 4,  4], type => 'xrw', rst => 0x00, desc => 'GPIO4'},
    { name => 'GPIO_5',    slc => [ 5,  5], type => 'xrw', rst => 0x00, desc => 'GPIO5'},
    { name => 'GPIO_6',    slc => [ 6,  6], type => 'xrw', rst => 0x00, desc => 'GPIO6'},
    { name => 'GPIO_7',    slc => [ 7,  7], type => 'xrw', rst => 0x00, desc => 'GPIO7'},
    { name => 'GPIO_8',    slc => [ 8,  8], type => 'xrw', rst => 0x00, desc => 'GPIO8'},
    { name => 'GPIO_9',    slc => [ 9,  9], type => 'xrw', rst => 0x00, desc => 'GPIO9'},
    { name => 'GPIO_A',    slc => [10, 10], type => 'xrw', rst => 0x00, desc => 'GPIOA'},
    { name => 'GPIO_B',    slc => [11, 11], type => 'xrw', rst => 0x00, desc => 'GPIOB'},
    { name => 'GPIO_C',    slc => [12, 12], type => 'xrw', rst => 0x00, desc => 'GPIOC'},
    { name => 'GPIO_D',    slc => [13, 13], type => 'xrw', rst => 0x00, desc => 'GPIOD'},
    { name => 'GPIO_E',    slc => [14, 14], type => 'xrw', rst => 0x00, desc => 'GPIOE'},
    { name => 'GPIO_F',    slc => [15, 15], type => 'xrw', rst => 0x00, desc => 'GPIOF'},

  ]
};

my $ref_gpio_dir = {
  offset => 0x0c,
  name  => 'HIBI_DMA_GPIO_DIR',
  desc  => 'general purpose I/O',
  fld   => [
    { name => 'GPIO_0',    slc => [ 0,  0], type => 'rw', rst => 0x00, desc => 'GPIO0'},
    { name => 'GPIO_1',    slc => [ 1,  1], type => 'rw', rst => 0x00, desc => 'GPIO1'},
    { name => 'GPIO_2',    slc => [ 2,  2], type => 'rw', rst => 0x00, desc => 'GPIO2'},
    { name => 'GPIO_3',    slc => [ 3,  3], type => 'rw', rst => 0x00, desc => 'GPIO3'},
    { name => 'GPIO_4',    slc => [ 4,  4], type => 'rw', rst => 0x00, desc => 'GPIO4'},
    { name => 'GPIO_5',    slc => [ 5,  5], type => 'rw', rst => 0x00, desc => 'GPIO5'},
    { name => 'GPIO_6',    slc => [ 6,  6], type => 'rw', rst => 0x00, desc => 'GPIO6'},
    { name => 'GPIO_7',    slc => [ 7,  7], type => 'rw', rst => 0x00, desc => 'GPIO7'},
    { name => 'GPIO_8',    slc => [ 8,  8], type => 'rw', rst => 0x00, desc => 'GPIO8'},
    { name => 'GPIO_9',    slc => [ 9,  9], type => 'rw', rst => 0x00, desc => 'GPIO9'},
    { name => 'GPIO_A',    slc => [10, 10], type => 'rw', rst => 0x00, desc => 'GPIOA'},
    { name => 'GPIO_B',    slc => [11, 11], type => 'rw', rst => 0x00, desc => 'GPIOB'},
    { name => 'GPIO_C',    slc => [12, 12], type => 'rw', rst => 0x00, desc => 'GPIOC'},
    { name => 'GPIO_D',    slc => [13, 13], type => 'rw', rst => 0x00, desc => 'GPIOD'},
    { name => 'GPIO_E',    slc => [14, 14], type => 'rw', rst => 0x00, desc => 'GPIOE'},
    { name => 'GPIO_F',    slc => [15, 15], type => 'rw', rst => 0x00, desc => 'GPIOF'},

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
  $ref_gpio,
  $ref_gpio_dir,
];

