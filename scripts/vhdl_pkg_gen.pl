#!/usr/bin/perl
use Getopt::Long;
use File::Basename;
use FileHandle;
use strict;

#my $data_base;
my $addr_width;
my @data_base_arr;

# command line options table
my %option = 
  ( 'database'     => { 'string' => 'database|db=s{1,}', 'ref' => \@data_base_arr,  'help' => 'Specify database to use'     },
    'addr_width'   => { 'string' => 'addr_width|aw=i',   'ref' => \$addr_width,     'help' => 'Specify address width'       },
    'help'         => { 'string' => 'help|?',            'ref' => \&help,           'help' => 'Show help'                   },
  );

# handle command line options
GetOptions( $option{'database'}    {'string'} => $option{'database'}    {'ref'},
            $option{'addr_width'}  {'string'} => $option{'addr_width'}  {'ref'},
            $option{'help'}        {'string'} => $option{'help'}        {'ref'},
          ) or die;

my $data_base = $data_base_arr[0];
die "no database specified" if not defined($data_base);
die "no address width specified" if not defined($addr_width);

# join all sub databases
my $desc = [];
foreach my $db (@data_base_arr) {
  my $dc = do $db;
  
  foreach my $ref (@$dc) {
    push(@$desc, $ref);
  }
}

my $timestamp = localtime();
my $user      = $ENV{'USER'};
my $host      = $ENV{'HOSTNAME'};

my $osfh      = new FileHandle;
open($osfh, "echo \$OSTYPE|");
my $ostype    = <$osfh>;

my $fh = new FileHandle;
my ($base, $path, $suffix) = fileparse($data_base, ".pl");
open($fh, ">$base" . "_regfile_pkg.vhd") or die "could not create $base.vhd\n";

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
my $package   = $base . "_regfile_pkg";
my $ctrl_type = $base . "_regfile_ctrl_t";

print $fh
"library ieee;\n" .
"use ieee.std_logic_1164.all;\n" .
"use ieee.numeric_std.all;\n" .
"\n" .
"package $package is\n" .
"\n" .
"type $ctrl_type is record\n" .
"  wr : std_ulogic;\n" .
"  rd : std_ulogic;\n" .
"end record $ctrl_type;\n" .
"\n";

# generate registers

my @reg2logic;
my @logic2reg;

foreach my $reg (@$desc)
{
  my $addr_offset_integer_name  =  "addr_offset_" . $$reg{name} . "_integer_c";
  my $addr_offset_integer       = $$reg{offset};

  my $addr_offset_unsigned_name =  "addr_offset_" . $$reg{name} . "_unsigned_c";
  #my $addr_offset_unsigned      = "x\"" . sprintf("%08x", $addr_offset_integer) . "\"";

  my $addr_offset_slv_name      =  "addr_offset_" . $$reg{name} . "_slv_c";
  #my $addr_offset_slv           = "x\"" . sprintf("%08x", $addr_offset_integer) . "\"";
  
  my $addr_offset_slv = sprintf("%0$addr_width" ."b", $addr_offset_integer);

  print $fh 
"-------------------------------------------------------------------------------\n" .
"-- $$reg{name} register\n" .
"-------------------------------------------------------------------------------\n" .
"constant $addr_offset_integer_name  : integer := $addr_offset_integer;\n" .
"constant $addr_offset_unsigned_name : unsigned($addr_width-1 downto 0) := \"$addr_offset_slv\";\n" .
"constant $addr_offset_slv_name      : std_ulogic_vector($addr_width-1 downto 0) := \"$addr_offset_slv\";\n" .
"\n";

  # bit slice constands definition
  foreach my $fld (@{$$reg{fld}})
  {
    my $bit_offset_name = "bit_offset_" . $$reg{name} . "_" . $$fld{name} ."_c";
    my $bit_offset_val  = $$fld{slc}[0];

    print $fh "constant $bit_offset_name : integer := $bit_offset_val;\n";
  }

  print $fh "\n";
  
  my $regname  = $base . "_" . $$reg{name};
  my $dfltname = "dflt_" . $base . "_" . $$reg{name} . "_c";
  
  # count the number of slices based on types
  my $nr_rw_slc  = 0;
  my $nr_xrw_slc = 0;
  my $nr_xr_slc  = 0;
  my $nr_xw_slc  = 0;
  my $nr_ro_slc  = 0;
  
  foreach my $fld (@{$$reg{fld}})
  {
    # read-write type
    if($$fld{type} eq 'rw')
    {
      $nr_rw_slc++;
    }
    
    # extanded read-write type
    if($$fld{type} eq 'xrw')
    {
      $nr_xrw_slc++;
    }
    
    # extanded read type
    if($$fld{type} eq 'xr')
    {
      $nr_xr_slc++;
    }
    
    # extanded write type
    if($$fld{type} eq 'xw')
    {
      $nr_xw_slc++;
    }
    
    # extanded write type
    if($$fld{type} eq 'ro')
    {
      $nr_ro_slc++;
    }
  }

  #my @fields = @{$$reg{fld}};
  #my $nr_fields = $#fields;
    
  ###########################################################################################################
  ## rw container
  ###########################################################################################################
  if($nr_rw_slc != 0)
  {
    print $fh "type $regname" . "_rw_t is record\n";
    
    foreach my $fld (@{$$reg{fld}})
    {
      if($$fld{type} eq'rw')
      {
        if($$fld{slc}[1] == $$fld{slc}[0])
        {
          print $fh "  $$fld{name} : std_ulogic;\n";
        }
        else
        {
          # TODO: check for consistence 
          my $upper = $$fld{slc}[1] - $$fld{slc}[0];
          print $fh "  $$fld{name} : std_ulogic_vector($upper downto 0);\n";
        }
      }
    }   
    
    print $fh "end record $regname" . "_rw_t;\n";
    
    # default value
    print $fh "constant $dfltname : $regname" . "_rw_t :=(\n";
    
    my $index = 0;
    foreach my $fld (@{$$reg{fld}})
    {
      if($$fld{type} eq 'rw')
      {
        $index++;
        
        # TODO: check for exceeding the range
        my $nr_bits = $$fld{slc}[1] - $$fld{slc}[0] + 1;
        #my $val     = unpack("b$nr_bits", sprintf("%08x",$$fld{rst}));
        my $val     = sprintf("%0$nr_bits" . "b", $$fld{rst});
        
        if($index == $nr_rw_slc)
        {
          if($$fld{slc}[1] == $$fld{slc}[0])
          {
            print $fh "  $$fld{name} => " . "\'" . $val . "\'\n";
          }
          else
          {
            print $fh "  $$fld{name} => " . "\"" . $val . "\"\n";
          }
        }
        else
        {
          if($$fld{slc}[1] == $$fld{slc}[0])
          {
            print $fh "  $$fld{name} => " . "\'" . $val . "\',\n";
          }
          else
          {
           print $fh "  $$fld{name} => " . "\"" . $val . "\",\n";
          }
        }
      }
        
      last if ($index == $nr_rw_slc);
    }
    
    print $fh ");\n\n";
  }
  
  ###########################################################################################################
  ## xw container
  ###########################################################################################################
  if(($nr_xw_slc != 0) || ($nr_xrw_slc != 0))
  {
    print $fh "type $regname" . "_xw_t is record\n";

    foreach my $fld (@{$$reg{fld}})
    {
      if(($$fld{type} eq'xw') || ($$fld{type} eq'xrw'))
      {
        if($$fld{slc}[1] == $$fld{slc}[0])
        {
          print $fh "  $$fld{name} : std_ulogic;\n";
        }
        else
        {
          # TODO: check for consistence 
          my $upper = $$fld{slc}[1] - $$fld{slc}[0];
          print $fh "  $$fld{name} : std_ulogic_vector($upper downto 0);\n";
        }
      }
    }   
  
    print $fh "end record $regname" . "_xw_t;\n\n";
  }
  
  ###########################################################################################################
  ## xr container
  ###########################################################################################################
  if(($nr_xr_slc != 0) || ($nr_xrw_slc != 0))
  {
    print $fh "type $regname" . "_xr_t is record\n";
    
    foreach my $fld (@{$$reg{fld}})
    {
      if(($$fld{type} eq'xr') || ($$fld{type} eq'xrw'))
      {
        if($$fld{slc}[1] == $$fld{slc}[0])
        {
          print $fh "  $$fld{name} : std_ulogic;\n";
        }
        else
        {
          # TODO: check for consistence 
          my $upper = $$fld{slc}[1] - $$fld{slc}[0];
          print $fh "  $$fld{name} : std_ulogic_vector($upper downto 0);\n";
        }
      }
    }   
    
    print $fh "end record $regname" . "_xr_t;\n\n";
  }
  
  ###########################################################################################################
  ## ro container
  ###########################################################################################################
  if($nr_ro_slc != 0)
  {
    print $fh "type $regname" . "_ro_t is record\n";
    
    foreach my $fld (@{$$reg{fld}})
    {
      if($$fld{type} eq'ro')
      {
        if($$fld{slc}[1] == $$fld{slc}[0])
        {
          print $fh "  $$fld{name} : std_ulogic;\n";
        }
        else
        {
          # TODO: check for consistence 
          my $upper = $$fld{slc}[1] - $$fld{slc}[0];
          print $fh "  $$fld{name} : std_ulogic_vector($upper downto 0);\n";
        }
      }
    }   
    
    print $fh "end record $regname" . "_ro_t;\n\n";
  }
  
  ###########################################################################################################
  ## reg2logic container
  ###########################################################################################################
  print $fh "type $regname" . "_reg2logic_t is record\n";  
  print $fh "  c : $ctrl_type" . ";\n";
          
  if($nr_rw_slc != 0)
  {
    print $fh "  rw : $regname" . "_rw_t;\n";
  }
    
  if(($nr_xw_slc != 0) || ($nr_xrw_slc != 0))
  {
    print $fh "  xw : $regname" . "_xw_t;\n";
  }
    
  push(@reg2logic, ($$reg{name} . " : " . $regname . "_reg2logic_t;\n"));
    
  print $fh "end record $regname" . "_reg2logic_t;\n\n";
  
  ###########################################################################################################
  ## logic2reg container
  ###########################################################################################################
  if(($nr_xr_slc != 0) || ($nr_xrw_slc != 0) || ($nr_ro_slc != 0))
  {
    print $fh "type $regname" . "_logic2reg_t is record\n";
    
    if(($nr_xr_slc != 0) || ($nr_xrw_slc != 0))
    {
      print $fh "  xr : $regname" . "_xr_t;\n";
    }
    
    if(($nr_ro_slc != 0))
    {
      print $fh "  ro : $regname" . "_ro_t;\n";
    }
        
    push(@logic2reg, ($$reg{name} . " : " . $regname . "_logic2reg_t;\n"));
    
    print $fh "end record $regname" . "_logic2reg_t;\n\n";
  }
  
  
  ###########################################################################################################
  # debug print message
  ###########################################################################################################
  print "found register \"$$reg{name}\" with addr offset 0x" . sprintf("%04x",$$reg{offset}) . "\n";
  foreach my $fld (@{$$reg{fld}})
  {
    print " -> $$fld{name}, $$fld{desc}, Bit $$fld{slc}[0] to $$fld{slc}[0], $$fld{type}," .
      "reset value 0x" . sprintf("%04x",$$fld{rst}) . "\n";
  }
}

###########################################################################################################
## putting it all together
###########################################################################################################

print $fh 
"-------------------------------------------------------------------------------\n" .
"-- putting it all together\n" .
"-------------------------------------------------------------------------------\n";

if($#reg2logic > 0)
{
  print $fh "type $base" . "_reg2logic_t is record\n";
  foreach my $str (@reg2logic)
  {
    print $fh "  " . $str;
  }
  print $fh "end record $base" . "_reg2logic_t;\n\n";
}

if($#logic2reg > 0)
{
  print $fh "type $base" . "_logic2reg_t is record\n";
  foreach my $str (@logic2reg)
  {
    print $fh "  " . $str;
  }
  print $fh "end record $base" . "_logic2reg_t;\n\n";
}

print $fh "end package $package;\n";
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

