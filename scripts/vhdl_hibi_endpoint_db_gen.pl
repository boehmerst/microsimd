#!/usr/bin/perl
use Getopt::Long;
use File::Basename;
use FileHandle;
use strict;

my $timestamp = localtime();
my $user      = $ENV{'USER'};
my $host      = $ENV{'HOSTNAME'};

my $entity          = "hibi_dma";
my $hibi_addr_width = 16;
my $mem_addr_width  = 32;
my $count_width     = 10;
my $channels        =  4;
my $chaining;
my $gpio;

# command line options table
my %option = 
  ( 'entity'           => { 'string' => 'entity|e=s',             'ref' => \$entity,          'help' => 'Specify entity name'                },
    'hibi_addr_width'  => { 'string' => 'hibi_addr_width|haw=i',  'ref' => \$hibi_addr_width, 'help' => 'Specify hibi address width'         },
    'mem_addr_width'   => { 'string' => 'mem_addr_width|maw=i',   'ref' => \$mem_addr_width,  'help' => 'Specify memory address width'       },
    'count_width'      => { 'string' => 'count_width|cnt=i',      'ref' => \$count_width,     'help' => 'Specify transfer counter width'     },
    'channels'         => { 'string' => 'channels|ch=i',          'ref' => \$channels,        'help' => 'Specify number of channels'         },
    'chaining'         => { 'string' => 'chaining|chn',           'ref' => \$chaining,        'help' => 'Support for chaining DMA transfers' },
    'gpio'             => { 'string' => 'gpio|g',                 'ref' => \$gpio,            'help' => 'Support for GPIO'                   },
    'help'             => { 'string' => 'help|?',                 'ref' => \&help,            'help' => 'Show help'                          },
  );

# handle command line options
GetOptions( $option{'entity'}          {'string'} => $option{'entity'}          {'ref'},
            $option{'hibi_addr_width'} {'string'} => $option{'hibi_addr_width'} {'ref'},
            $option{'mem_addr_width'}  {'string'} => $option{'mem_addr_width'}  {'ref'},
            $option{'count_width'}     {'string'} => $option{'count_width'}     {'ref'},
            $option{'channels'}        {'string'} => $option{'channels'}        {'ref'},
            $option{'chaining'}        {'string'} => $option{'chaining'}        {'ref'},
	    $option{'gpio'}            {'string'} => $option{'gpio'}            {'ref'},
            $option{'help'}            {'string'} => $option{'help'}            {'ref'},          
          ) or die;


die "count width must be less than 16" if $count_width > 15;

my $file_name = $entity . ".pl";
my $fh = new FileHandle;
open($fh, ">$file_name") or die "could not create $file_name\n";


# generate Header
print $fh
"#-------------------------------------------------------------------------------\n" .
"#-- Title      : $entity\n" .
"#-- Project    :\n" .
"#-------------------------------------------------------------------------------\n" .
"#-- File       : $file_name\n" .
"#-- Author     : $user\n" .
"#-- Company    : private\n" .
"#-- Created    : \n" .
"#-- Last update: \n" .
"#-- Platform   : \n" .
"#-- Standard   : VHDL'93\n" .
"#-------------------------------------------------------------------------------\n" .
"#-- Description: automated generated do not edit manually\n" .
"#-------------------------------------------------------------------------------\n" .
"#-- Copyright (c) 2013 Stephan Böhmer\n" .
"#-------------------------------------------------------------------------------\n" .
"#-- Revisions  :\n" .
"#-- Date        Version  Author  Description\n" .
"#--             1.0      SBo     Created\n" .
"#-------------------------------------------------------------------------------\n\n";

print $fh
"#!/usr/bin/perl\n" .
"\n" .
"use strict;\n" .
"\n";

# control register
printf $fh (
  "my \$ref_ctrl = {\n  offset => 0x00,\n");
printf $fh
  "  name   => 'HIBI_DMA_CTRL',\n" .
  "  desc   => 'control register',\n" .
  "  fld    => [\n" .
  "    { name => 'en',    slc => [0,  0],  type => 'rw',  rst => 0x00,  desc => 'enable' },\n" .
  "  ]\n" .
  "};\n" .
  "\n";

# status register
printf $fh (
  "my \$ref_stat = {\n  offset => 0x01,\n");
printf $fh
  "  name   => 'HIBI_DMA_STATUS',\n" .
  "  desc   => 'status register',\n" .
  "  fld    => [\n";

for(my $i = 0; $i < $channels; $i++) {
  printf $fh (
    "  { name => 'busy$i" . "',    slc => [%d,  %d],  type => 'ro',  rst => 0x00,  desc => 'transfer ongoing' },\n", $i, $i);
}

printf $fh
  "  ]\n" .
  "};\n" .
  "\n";

# trigger register
printf $fh (
  "my \$ref_trig = {\n  offset => 0x02,\n");
printf $fh
  "  name   => 'HIBI_DMA_TRIGGER',\n" .
  "  desc   => 'trigger register',\n" .
  "  fld    => [\n";

for(my $i = 0; $i < $channels; $i++) {
  printf $fh (
    "  { name => 'start$i" . "',    slc => [%d,  %d],  type => 'xw',  rst => 0x00,  desc => 'start' },\n", $i, $i);
}

printf $fh
  "  ]\n" .
  "};\n" .
  "\n";

# channel register
for(my $i = 0; $i < $channels; $i++) {
  printf $fh (
    "my \$ref_cfg$i = {\n  offset => 0x%02x,\n", 4*$i+3);
  printf $fh
    "  name   => 'HIBI_DMA_CFG$i" . "',\n" .
    "  desc   => 'configuration register',\n" .
    "  fld    => [\n";
  printf $fh (
    "    { name => 'count',      slc => [0,  %d],  type => 'rw',  rst => 0x00,  desc => 'number of transfers'                  },\n", $count_width-1);
  printf $fh
    "    { name => 'direction',  slc => [15, 15],  type => 'rw',  rst => 0x01,  desc => 'direction (\\\'0\\\' -> rx, \\\'1\\\' -> tx)' },\n" .
    "    { name => 'hibi_cmd',   slc => [16, 20],  type => 'rw',  rst => 0x02,  desc => 'hibi command to use for transfer'     },\n" .
    "    { name => 'const_addr', slc => [21, 21],  type => 'rw',  rst => 0x00,  desc => 'constant mem address'                 },\n" .
    "  ]\n" .
    "};\n" .
    "\n";

  printf $fh (
    "my \$ref_dma_addr$i = {\n  offset => 0x%02x,\n", 4*$i+3+1);
  printf $fh
    "  name   => 'HIBI_DMA_MEM_ADDR$i" . "',\n" .
    "  desc   => 'memory address',\n" .
    "  fld    => [\n";
  printf $fh ("    { name => 'addr',    slc => [0, %d],  type => 'rw',  rst => 0x00,  desc => 'memory address' },\n", $mem_addr_width-1);
  printf $fh
"  ]\n" .
"};\n" .
"\n";

  printf $fh (
    "my \$ref_hibi_addr$i = {\n  offset => 0x%02x,\n", 4*$i+3+2);
  printf $fh
    "  name   => 'HIBI_DMA_HIBI_ADDR$i" . "',\n" .
    "  desc   => 'hibi address',\n" .
    "  fld    => [\n";
  printf $fh (
    "    { name => 'addr',    slc => [0, %d],  type => 'rw',  rst => 0x00,  desc => 'hibi address' },\n", $hibi_addr_width-1);
  printf $fh
    "  ]\n" .
    "};\n" .
    "\n";

  if(defined($chaining)) {
    printf $fh (
      "my \$ref_trig_mask$i = {\n  offset => 0x%02x,\n", 4*$i+3+3);
    printf $fh
      "  name   => 'HIBI_DMA_TRIGGER_MASK$i" . "',\n" .
      "  desc   => 'trigger mask for DMA chaining',\n" .
      "  fld    => [\n";
    printf $fh ("    { name => 'mask',    slc => [0, %d],  type => 'rw',  rst => 0x00,  desc => 'trigger mask'},\n", $channels-1);
    printf $fh
      "  ]\n" .
      "};\n" .
      "\n";  
  }
}


my $gpio_offset = 4*$channels+3;

if(defined($gpio)) {
  printf $fh (
    "my \$ref_gpio = {\n  offset =>  0x%02x,\n", $gpio_offset);
  printf $fh
    "  name  => 'HIBI_DMA_GPIO',\n" .
    "  desc  => 'general purpose I/O',\n" .
    "  fld   => [\n";
  print $fh "    { name => 'GPIO_0',    slc => [ 0,  0], type => 'xrw', rst => 0x00, desc => 'GPIO0'},\n" .
            "    { name => 'GPIO_1',    slc => [ 1,  1], type => 'xrw', rst => 0x00, desc => 'GPIO1'},\n" .
	    "    { name => 'GPIO_2',    slc => [ 2,  2], type => 'xrw', rst => 0x00, desc => 'GPIO2'},\n" .
	    "    { name => 'GPIO_3',    slc => [ 3,  3], type => 'xrw', rst => 0x00, desc => 'GPIO3'},\n" .
            "    { name => 'GPIO_4',    slc => [ 4,  4], type => 'xrw', rst => 0x00, desc => 'GPIO4'},\n" .
            "    { name => 'GPIO_5',    slc => [ 5,  5], type => 'xrw', rst => 0x00, desc => 'GPIO5'},\n" .
	    "    { name => 'GPIO_6',    slc => [ 6,  6], type => 'xrw', rst => 0x00, desc => 'GPIO6'},\n" .
	    "    { name => 'GPIO_7',    slc => [ 7,  7], type => 'xrw', rst => 0x00, desc => 'GPIO7'},\n" .
            "    { name => 'GPIO_8',    slc => [ 8,  8], type => 'xrw', rst => 0x00, desc => 'GPIO8'},\n" .
            "    { name => 'GPIO_9',    slc => [ 9,  9], type => 'xrw', rst => 0x00, desc => 'GPIO9'},\n" .
	    "    { name => 'GPIO_A',    slc => [10, 10], type => 'xrw', rst => 0x00, desc => 'GPIOA'},\n" .
	    "    { name => 'GPIO_B',    slc => [11, 11], type => 'xrw', rst => 0x00, desc => 'GPIOB'},\n" .
            "    { name => 'GPIO_C',    slc => [12, 12], type => 'xrw', rst => 0x00, desc => 'GPIOC'},\n" .
            "    { name => 'GPIO_D',    slc => [13, 13], type => 'xrw', rst => 0x00, desc => 'GPIOD'},\n" .
	    "    { name => 'GPIO_E',    slc => [14, 14], type => 'xrw', rst => 0x00, desc => 'GPIOE'},\n" .
	    "    { name => 'GPIO_F',    slc => [15, 15], type => 'xrw', rst => 0x00, desc => 'GPIOF'},\n" .
	    "\n";
  printf $fh
    "  ]\n" .
    "};\n" .
    "\n";  


  printf $fh (
    "my \$ref_gpio_dir = {\n  offset => 0x%02x,\n", $gpio_offset+1);
  printf $fh
    "  name  => 'HIBI_DMA_GPIO_DIR',\n" .
    "  desc  => 'general purpose I/O',\n" .
    "  fld   => [\n";
  print $fh "    { name => 'GPIO_0',    slc => [ 0,  0], type => 'rw', rst => 0x00, desc => 'GPIO0'},\n" .
            "    { name => 'GPIO_1',    slc => [ 1,  1], type => 'rw', rst => 0x00, desc => 'GPIO1'},\n" .
	    "    { name => 'GPIO_2',    slc => [ 2,  2], type => 'rw', rst => 0x00, desc => 'GPIO2'},\n" .
	    "    { name => 'GPIO_3',    slc => [ 3,  3], type => 'rw', rst => 0x00, desc => 'GPIO3'},\n" .
            "    { name => 'GPIO_4',    slc => [ 4,  4], type => 'rw', rst => 0x00, desc => 'GPIO4'},\n" .
            "    { name => 'GPIO_5',    slc => [ 5,  5], type => 'rw', rst => 0x00, desc => 'GPIO5'},\n" .
	    "    { name => 'GPIO_6',    slc => [ 6,  6], type => 'rw', rst => 0x00, desc => 'GPIO6'},\n" .
	    "    { name => 'GPIO_7',    slc => [ 7,  7], type => 'rw', rst => 0x00, desc => 'GPIO7'},\n" .
            "    { name => 'GPIO_8',    slc => [ 8,  8], type => 'rw', rst => 0x00, desc => 'GPIO8'},\n" .
            "    { name => 'GPIO_9',    slc => [ 9,  9], type => 'rw', rst => 0x00, desc => 'GPIO9'},\n" .
	    "    { name => 'GPIO_A',    slc => [10, 10], type => 'rw', rst => 0x00, desc => 'GPIOA'},\n" .
	    "    { name => 'GPIO_B',    slc => [11, 11], type => 'rw', rst => 0x00, desc => 'GPIOB'},\n" .
            "    { name => 'GPIO_C',    slc => [12, 12], type => 'rw', rst => 0x00, desc => 'GPIOC'},\n" .
            "    { name => 'GPIO_D',    slc => [13, 13], type => 'rw', rst => 0x00, desc => 'GPIOD'},\n" .
	    "    { name => 'GPIO_E',    slc => [14, 14], type => 'rw', rst => 0x00, desc => 'GPIOE'},\n" .
	    "    { name => 'GPIO_F',    slc => [15, 15], type => 'rw', rst => 0x00, desc => 'GPIOF'},\n" .
	    "\n";
  printf $fh
    "  ]\n" .
    "};\n" .
    "\n";  
}


#descriptor
printf $fh
"my \$descriptor = [\n" .
"  \$ref_ctrl,\n" .
"  \$ref_stat,\n" .
"  \$ref_trig,\n";

for(my $i = 0; $i < $channels; $i++) {
  printf $fh
    "  \$ref_cfg$i" . ",\n" .
    "  \$ref_dma_addr$i" . ",\n" .
    "  \$ref_hibi_addr$i" . ",\n";

  if(defined($chaining)) {
    print $fh
      "  \$ref_trig_mask$i" . ",\n";
  }
}

if(defined($gpio)) {
print $fh
"  \$ref_gpio,\n" .
"  \$ref_gpio_dir,\n";
}

print $fh
"];\n" .
"\n";


close($fh);

# help
sub help
{
  my $max_length = 0;

  print "usage: $0 [OPTION]\n\n";

  # find maximum string length
  foreach my $cmd (keys(%option))
  {
    my @alias  = split(/[\|,=]/, $option{$cmd}{'string'});
    my $string = "--" . $alias[0] . ", -" . $alias[1] . ",";
    $max_length = length($string) if length($string) > $max_length;
  }

  # print out aligned
  foreach my $cmd (sort(keys(%option)))
  {
    my @alias  = split(/[\|,=,+]/, $option{$cmd}{'string'});
    my $string = "--" . $alias[0] . ", -" . $alias[1] . ",";
    my $length = length($string);
    my $space  = ' 'x($max_length - $length);

    print "$string $space $option{$cmd}{'help'}\n";
  }

  exit 1;
}

