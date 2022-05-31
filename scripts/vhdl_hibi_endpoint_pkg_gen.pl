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
my $mem_data_width  = 32;
my $count_width     = 10;
my $channels        =  4;

# command line options table
my %option = 
  ( 'entity'           => { 'string' => 'entity|e=s',             'ref' => \$entity,          'help' => 'Specify entity name'            },
    'hibi_addr_width'  => { 'string' => 'hibi_addr_width|haw=i',  'ref' => \$hibi_addr_width, 'help' => 'Specify hibi address width'     },
    'mem_addr_width'   => { 'string' => 'mem_addr_width|maw=i',   'ref' => \$mem_addr_width,  'help' => 'Specify memory address width'   },
    'mem_data_width'   => { 'string' => 'mem_data_width|mdw=i',   'ref' => \$mem_data_width,  'help' => 'Specify memory data width'      },    
    'count_width'      => { 'string' => 'count_width|cnt=i',      'ref' => \$count_width,     'help' => 'Specify transfer counter width' },
    'channels'         => { 'string' => 'channels|ch=i',          'ref' => \$channels,        'help' => 'Specify number of channels'     },    
    'help'             => { 'string' => 'help|?',                 'ref' => \&help,            'help' => 'Show help'                      },
  );

# handle command line options
GetOptions( $option{'entity'}          {'string'} => $option{'entity'}          {'ref'},
            $option{'hibi_addr_width'} {'string'} => $option{'hibi_addr_width'} {'ref'},
            $option{'mem_addr_width'}  {'string'} => $option{'mem_addr_width'}  {'ref'},
            $option{'mem_data_width'}  {'string'} => $option{'mem_data_width'}  {'ref'},
            $option{'count_width'}     {'string'} => $option{'count_width'}     {'ref'},
            $option{'channels'}        {'string'} => $option{'channels'}        {'ref'},            
            $option{'help'}            {'string'} => $option{'help'}            {'ref'},    
          ) or die;
          
my $package  = $entity . "_pkg";
my $file_name = $package . ".vhd";

my $fh = new FileHandle;
open($fh, ">$file_name") or die "could not create $file_name\n";

# generate Header
print $fh
"-------------------------------------------------------------------------------\n" .
"-- Title      : $package\n" .
"-- Project    :\n" .
"-------------------------------------------------------------------------------\n" .
"-- File       : $file_name\n" .
"-- Author     : $user\n" .
"-- Company    : private\n" .
"-- Created    : \n" .
"-- Last update: \n" .
"-- Platform   : \n" .
"-- Standard   : VHDL'93\n" .
"-------------------------------------------------------------------------------\n" .
"-- Description: automated generated do not edit manually\n" .
"-------------------------------------------------------------------------------\n" .
"-- Copyright (c) 2013 Stephan Böhmer\n" .
"-------------------------------------------------------------------------------\n" .
"-- Revisions  :\n" .
"-- Date        Version  Author  Description\n" .
"--             1.0      SBo     Created\n" .
"-------------------------------------------------------------------------------\n\n";

print $fh
"library ieee;\n" .
"use ieee.std_logic_1164.all;\n" .
"use ieee.numeric_std.all;\n" .
"\n" .
"package $package is\n" .
"\n" .
"  constant $entity" . "_hibi_addr_width_c : natural := $hibi_addr_width" . ";\n" .
"  constant $entity" . "_mem_addr_width_c  : natural := $mem_addr_width"  . ";\n" .
"  constant $entity" . "_mem_data_width_c  : natural := $mem_data_width"  . ";\n" .
"  constant $entity" . "_count_width_c     : natural := $count_width"     . ";\n" .
"  constant $entity" . "_channels_c        : natural := $channels"        . ";\n" .
"\n" .
"  type $entity" . "_ctrl_t is record\n" .
"     start : std_ulogic;\n" .
"   end record $entity" ."_ctrl_t;\n" .
"\n" .
"  type $entity" . "_ctrl_arr_t is array(natural range 0 to $entity" . "_channels_c-1) of $entity" . "_ctrl_t;\n" .
"\n" .
"  type $entity" . "_cfg_t is record\n" .
"    hibi_addr  : std_ulogic_vector($entity" . "_hibi_addr_width_c-1 downto 0);\n" .
"    mem_addr   : std_ulogic_vector($entity" . "_mem_addr_width_c-1 downto 0);\n" .
"    count      : std_ulogic_vector($entity" . "_count_width_c-1 downto 0);\n" .
"    direction  : std_ulogic;\n" .
"    const_addr : std_ulogic;\n" .
"    cmd        : std_ulogic_vector(4 downto 0);\n" .
"  end record $entity" . "_cfg_t;\n" .
"  constant dflt_$entity" . "_cfg_c : $entity" . "_cfg_t :=(\n" .
"    hibi_addr  => (others=>'0'),\n" .
"    mem_addr   => (others=>'0'),\n" .
"    count      => (others=>'0'),\n" .
"    direction  => '0',\n" .
"    const_addr => '0',\n" .
"    cmd        => (others=>'0')\n" .
"  );\n" .
"\n" .
"  type $entity" . "_cfg_arr_t is array(natural range 0 to $entity" . "_channels_c-1) of $entity" . "_cfg_t;\n" .
"\n" .
"  type $entity" . "_status_t is record\n" .
"    busy  : std_ulogic;\n" .
"  end record $entity" . "_status_t;\n" .
"  constant dflt_$entity" . "_status_c : $entity" . "_status_t :=(\n" .
"    busy  => '0'\n" .
"  );\n" .
"\n" .
"  type $entity" . "_status_arr_t is array(natural range 0 to $entity" . "_channels_c-1) of $entity" . "_status_t;\n" .
"\n" .  
"  type $entity" . "_mem_req_t is record\n" .
"    adr : std_ulogic_vector($entity" . "_mem_addr_width_c-1 downto 0);\n" .
"    we  : std_ulogic;\n" .
"    ena : std_ulogic;\n" .
"    dat : std_ulogic_vector($entity" . "_mem_data_width_c-1 downto 0);\n" .
"  end record $entity" . "_mem_req_t;\n" .
"  constant dflt_$entity" . "_mem_req_c : $entity" . "_mem_req_t :=(\n" .
"    adr => (others=>'0'),\n" .
"    we  => '0',\n" .
"    ena => '0',\n" .
"    dat => (others=>'0')\n" .
"  );\n" .
"\n" .  
"  type $entity" . "_mem_rsp_t is record\n" .
"    dat  : std_ulogic_vector($entity" . "_mem_data_width_c-1 downto 0);\n" .
"  end record $entity" . "_mem_rsp_t;\n" .
"\n" .
"end package $package;\n";

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

  

