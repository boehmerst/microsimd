#!/usr/bin/perl
use Getopt::Long;
use File::Basename;
use FileHandle;
use strict;

# import database -> just for naming
my $data_base;
my $addr_width;
my $reg_width;
my @data_base_arr;

# command line options table
my %option = 
  ( 'database'     => { 'string' => 'database|db=s{1,}', 'ref' => \@data_base_arr, 'help' => 'Specify database to use'     },
    'addr_width'   => { 'string' => 'addr_width|aw=i',   'ref' => \$addr_width,    'help' => 'Specify address width'       },
    'data_width'   => { 'string' => 'data_width|dw=i',   'ref' => \$reg_width,     'help' => 'Specify register data width' },
    'help'         => { 'string' => 'help|?',            'ref' => \&help,          'help' => 'Show help'                   },
  );

# handle command line options
GetOptions( $option{'database'}    {'string'} => $option{'database'}    {'ref'},
            $option{'addr_width'}  {'string'} => $option{'addr_width'}  {'ref'},
            $option{'data_width'}  {'string'} => $option{'data_width'}  {'ref'},
            $option{'help'}        {'string'} => $option{'help'}        {'ref'},
          ) or die;

my $data_base = $data_base_arr[0];
die "no address width specified" if not defined($addr_width);
die "no data width specified" if not defined($reg_width);

my $timestamp = localtime();
my $user      = $ENV{"USER"};
my $host      = $ENV{"HOSTNAME"};

my $osfh      = new FileHandle;
open($osfh, "echo \$OSTYPE|");
my $ostype    = <$osfh>;

my $fh = new FileHandle;
my ($base, $path, $suffix) = fileparse($data_base, ".pl");
open($fh, ">$base" . "_regif_types_pkg.vhd") or die "could not create $base.vhd\n";

# generate Header
print $fh
"-------------------------------------------------------------------------------\n" .
"-- Title      : $base\n" .
"-- Project    :\n" .
"-------------------------------------------------------------------------------\n" .
"-- File       : $base.vhd\n" .
"-- Author     : Stephan Böhmer\n" .
"-- Company    : private\n" .
"-- Created    : \n" .
"-- Last update: \n" .
"-- Platform   : \n" .
"-- Standard   : VHDL'93\n" .
"-------------------------------------------------------------------------------\n" .
"-- Description: automated generated do not edit manually\n" .
"-------------------------------------------------------------------------------\n" .
"-- Copyright (c) 2011 Stephan Böhmer\n" .
"-------------------------------------------------------------------------------\n" .
"-- Revisions  :\n" .
"-- Date        Version  Author  Description\n" .
"--             1.0      SBo     Created\n" .
"-------------------------------------------------------------------------------\n\n";

# generate package definition
my $package  = $base . "_regif_types_pkg";
my $req_type = $base . "_gif_req_t";
my $rsp_type = $base . "_gif_rsp_t";

print $fh
"library ieee;\n" .
"use ieee.std_logic_1164.all;\n" .
"use ieee.numeric_std.all;\n" .
"\n" .
"package $package is\n" .
"\n" .
"constant $base" . "_addr_width_c : integer := $addr_width;\n" .
"constant $base" . "_data_width_c : integer := $reg_width;\n" .
"\n" .
"type $req_type is record\n" .
"  addr  : std_ulogic_vector($base" . "_addr_width_c-1 downto 0);\n" .
"  wdata : std_ulogic_vector($base" . "_data_width_c-1 downto 0);\n" .
"  wr    : std_ulogic;\n" .
"  rd    : std_ulogic;\n" .
"end record $req_type;\n" .
"constant dflt_$base" . "_gif_req_c : $req_type :=(\n" .
"  addr  => (others=>'0'),\n" .
"  wdata => (others=>'0'),\n" .
"  wr    => '0',\n" .
"  rd    => '0'\n" .
");" .
"\n\n" .
"type $base" . "_gif_req_arr_t is array(natural range <>) of $req_type;" . 
"\n\n" .
"type $rsp_type is record\n" .
"  rdata : std_ulogic_vector($base" . "_data_width_c-1 downto 0);\n" .
"  ack   : std_ulogic;\n" .
"end record $rsp_type;\n" .
"constant dflt_$base" . "_gif_rsp_c : $rsp_type :=(\n" .
"  rdata => (others=>'0'),\n" .
"  ack   => '0'\n" .
");" .
"\n\n" .
"type $base" . "_gif_rsp_arr_t is array(natural range <>) of $rsp_type;" .
"\n\n" .
"end package $package;\n" .
"\n";


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





