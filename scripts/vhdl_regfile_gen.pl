#!/usr/bin/perl
use Getopt::Long;
use File::Basename;
use FileHandle;
use strict;

my $reset_level       = '0';
my $reset_name        = "reset_n_i";
my $dflt_read_pattern = "(others=>'0')";
my $target_lib        = "work";
my $data_base;
my $addr_width;
my $reg_width;
my @data_base_arr;

# command line options table
my %option = 
  ( 'database'     => { 'string' => 'database|db=s{1,}',  'ref' => \@data_base_arr,      'help' => 'Specify database to use'      },
    'addr_width'   => { 'string' => 'addr_width|aw=i',    'ref' => \$addr_width,         'help' => 'Specify address width'        },
    'data_width'   => { 'string' => 'data_width|dw=i',    'ref' => \$reg_width,          'help' => 'Specify register data width'  },
    'lib'          => { 'string' => 'lib|l=s',            'ref' => \$target_lib,         'help' => 'Specify target library'       },
    'reset_level'  => { 'string' => 'reset_level|rst=s',  'ref' => \$reset_level,        'help' => 'Specify reset level'          },
    'reset_name'   => { 'string' => 'reset_name|rn=s',    'ref' => \$reset_name,         'help' => 'Specify reset name'           },
    'read_pattern' => { 'string' => 'read_pattern|rp=s',  'ref' => \$dflt_read_pattern,  'help' => 'Specify default read pattern' },
    'help'         => { 'string' => 'help|?',             'ref' => \&help,               'help' => 'Show help'                    },
  );

# handle command line options
GetOptions( $option{'database'}     {'string'} => $option{'database'}      {'ref'},
            $option{'addr_width'}   {'string'} => $option{'addr_width'}    {'ref'},
            $option{'data_width'}   {'string'} => $option{'data_width'}    {'ref'},
            $option{'lib'}          {'string'} => $option{'lib'}           {'ref'},
            $option{'reset_level'}  {'string'} => $option{'reset_level'}   {'ref'},
            $option{'reset_name'}   {'string'} => $option{'reset_name'}    {'ref'},
            $option{'read_pattern'} {'string'} => $option{'read_pattern'}  {'ref'},
            $option{'help'}         {'string'} => $option{'help'}          {'ref'},                
          ) or die;

my $data_base = $data_base_arr[0];
die "no address width specified" if not defined($addr_width);
die "no data width specified" if not defined($reg_width);

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
open($fh, ">$base" . "_regfile.vhd") or die "could not create $base.vhd\n";

# generate Header and library stuff
print $fh
"-------------------------------------------------------------------------------\n" .
"-- Title      : $base" . "_regfile\n" .
"-- Project    :\n" .
"-------------------------------------------------------------------------------\n" .
"-- File       : $base" . "_regfile.vhd\n" .
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
"-------------------------------------------------------------------------------\n" .
"\n" .
"library ieee;\n" .
"use ieee.std_logic_1164.all;\n" .
"use ieee.numeric_std.all;\n" .
"\n" .
"library $target_lib;\n" .
"use $target_lib.$base" . "_regif_types_pkg.all;\n" .
"use $target_lib.$base" . "_regfile_pkg.all;\n" .
"\n" .
"--pragma translate_off\n" .
"library std;\n" .
"use std.textio.all;\n" .
"\n" .
"library $target_lib;\n" .
"use $target_lib.txt_util.all;\n" .
"--pragma translate_on\n" .
"\n";

# count the number of slices based on types to find out which ports our entity needs
my $need_reg2logic = 0;
my $need_logic2reg = 0;

foreach my $reg (@$desc)
{
  foreach my $fld (@{$$reg{fld}})
  {
    # slices that require reg2logic
    if(($$fld{type} eq 'rw') || ($$fld{type} eq 'xw') || ($$fld{type} eq 'xrw'))
    {
      $need_reg2logic = 1;
    }
    
    # slices that require logic2reg
    if(($$fld{type} eq 'ro') || ($$fld{type} eq 'xr') || ($$fld{type} eq 'xrw'))
    {
      $need_logic2reg = 1;
    }
  }
}

print $fh 
"entity $base" . "_regfile is\n" .
"  port (\n" .
"    clk_i       : in  std_ulogic;\n" .
"    $reset_name   : in  std_ulogic;\n" .
"    gif_req_i   : in  $base" . "_gif_req_t;\n" .
"    gif_rsp_o   : out $base" . "_gif_rsp_t;\n";

if($need_logic2reg == 1)
{
  print $fh "    logic2reg_i : in  $base" . "_logic2reg_t";
  if($need_reg2logic == 1)
  {
    print $fh ";\n";
  }
}

if($need_reg2logic == 1)
{
  print $fh "    reg2logic_o : out $base" . "_reg2logic_t\n"; 
}

print $fh 
"  );\n" .
"end entity $base" . "_regfile;\n" .
"\n" .
"architecture rtl of $base" . "_regfile is\n" .
"\n" .
"--pragma translate_off\n" .
"  constant enable_msg_c  : boolean := true;\n" .
"  constant module_name_c : string  := \"$base" ."_regfile\";\n" .
"--pragma translate_on\n" .
"\n";

# declare any rw signal
foreach my $reg (@$desc)
{
  foreach my $fld (@{$$reg{fld}})
  {
    my $done = 0;
    
    # slices that require reg2logic
    if($$fld{type} eq 'rw')
    {
      $done = 1;
      print $fh "  signal $$reg{name} " . ": $base" . "_" . $$reg{name} . "_rw_t;\n";
    }
    
    last if $done == 1;
  }
}

print $fh "\nbegin\n";

foreach my $reg (@$desc)
{  
  ########################################################################################################
  ## handle rw related logic
  ########################################################################################################
  my $need_rw = 0;

  foreach my $fld (@{$$reg{fld}})
  {
    # slices that need rw
    if($$fld{type} eq 'rw')
    {
      $need_rw = 1;
      last if $need_rw == 1;
    }
  }

  if($need_rw == 1)
  {
    print $fh
    "  -------------------------------------------------------------------------------\n" .
    "  --  $$reg{name} write logic (internally located register)\n" .
    "  -------------------------------------------------------------------------------\n" .
    "  $$reg{name}_rw: process(clk_i, $reset_name) is\n" .
    "--pragma translate_off\n" .
    "    variable wr : line;\n" .
    "--pragma translate_on\n" .
    "  begin\n" .
    "    if($reset_name = '$reset_level') then\n" .
    "      $$reg{name} <= dflt_$base" ."_$$reg{name}_c;\n" .
    "    elsif(rising_edge(clk_i)) then\n" .
    "      if(gif_req_i.addr = addr_offset_$$reg{name}_slv_c and gif_req_i.wr = '1') then\n";
  
    foreach my $fld (@{$$reg{fld}})
    {
      if($$fld{type} eq "rw")
      {
        if($$fld{slc}[1] == $$fld{slc}[0])
        {
          print $fh "        $$reg{name}.$$fld{name} <= gif_req_i.wdata($$fld{slc}[0]);\n";
        }
        else
        {
          print $fh "        $$reg{name}.$$fld{name} <= gif_req_i.wdata($$fld{slc}[1] downto $$fld{slc}[0]);\n";
        }
      }
    }
  
    # debug message
    print $fh "--pragma translate_off\n" .
              "        if(enable_msg_c) then\n" .
              "          write(wr, string'(\"Time: \"));\n" .
              "          write(wr, now);\n" .
              "          write(wr, string'(\" (\") & module_name_c & string'(\") $$reg{name} write access: \"));\n" .
              "          writeline(output, wr);\n";
            
    foreach my $fld (@{$$reg{fld}})
    {
      if($$fld{type} eq "rw")
      {
        print $fh "          write(wr, string'(\"  -> $$fld{name}: \") &\n";
    
        if($$fld{slc}[1] == $$fld{slc}[0])
        {
          print $fh "          std_ulogic'image(gif_req_i.wdata($$fld{slc}[0])));\n" .
                    "          writeline(output, wr);\n";
        }
        else
        {
          print $fh "          string'(\"0x\") & hstr(std_logic_vector(gif_req_i.wdata($$fld{slc}[1] downto $$fld{slc}[0]))) );\n" .
                    "          writeline(output, wr);\n";
        }
      }
    } 
         
    print $fh "        end if;\n" .
              "--pragma translate_on\n";
  
    print $fh
    "      end if;\n" .
    "    end if;\n" .
    "  end process $$reg{name}_rw;\n" .
    "  reg2logic_o.$$reg{name}.rw <= $$reg{name};\n";
  }
  print $fh "\n";

  ##################################################################################################################
  # handle register access control decoding
  ##################################################################################################################
  print $fh
  "  -------------------------------------------------------------------------------\n" .
  "  -- $$reg{name} access control decoding\n" .
  "  -------------------------------------------------------------------------------\n" .
  "  reg2logic_o.$$reg{name}.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_$$reg{name}_slv_c else '0';\n" .
  "  reg2logic_o.$$reg{name}.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_$$reg{name}_slv_c else '0';\n";
  
  ########################################################################################################
  ## handle xw, xrw, xr related stuff
  ########################################################################################################      
  foreach my $fld (@{$$reg{fld}})
  {
    if(($$fld{type} eq 'xw') || ($$fld{type} eq 'xrw'))
    {
      if($$fld{slc}[0] == $$fld{slc}[1])
      {
        print $fh "  reg2logic_o.$$reg{name}.xw.$$fld{name} <= gif_req_i.wdata($$fld{slc}[0]);\n";
      }
      else
      {
        print $fh "  reg2logic_o.$$reg{name}.xw.$$fld{name} <= gif_req_i.wdata($$fld{slc}[1] downto $$fld{slc}[0]);\n";
      }
    }
  }
  print $fh "\n";
}

##################################################################################################################
## handle read logic
##################################################################################################################
print $fh
"  -------------------------------------------------------------------------------\n" .
"  -- read logic\n" .
"  -------------------------------------------------------------------------------\n" .
"  read: process(clk_i, $reset_name) is\n" .
"  begin\n" .
"    if($reset_name = '$reset_level') then\n" .
"      gif_rsp_o.rdata <= (others=>'0');\n" .
"      gif_rsp_o.ack   <= '0';\n" .
"    elsif(rising_edge(clk_i)) then\n" .
"      gif_rsp_o.ack <= gif_req_i.rd or gif_req_i.wr;\n" .
"\n" .
"      if(gif_req_i.rd = '1') then\n" .
"        case(gif_req_i.addr) is\n";

foreach my $reg (@$desc)
{
  print $fh "          when addr_offset_$$reg{name}_slv_c =>\n" .
            "            gif_rsp_o.rdata <= (others=>'0');\n";
  
  foreach my $fld (@{$$reg{fld}})
  {
    my $src;

    if($$fld{type} eq "rw")
    {
      $src        = "$$reg{name}.$$fld{name}";
    }
    
    if($$fld{type} eq "ro")
    {
      $src        = "logic2reg_i.$$reg{name}.ro.$$fld{name}";
    }
      
    if(($$fld{type} eq "xr") || ($$fld{type} eq "xrw"))
    {
      $src        = "logic2reg_i.$$reg{name}.xr.$$fld{name}";
    }
      
    if($$fld{slc}[0] == $$fld{slc}[1])
    {
      if(!defined($src))
      {
        $src = "'0'";
      }
      print $fh "            gif_rsp_o.rdata($$fld{slc}[0]) <= $src;\n";
    }
    else
    {
      if(!defined($src))
      {
        $src = "(others=>'0')";
      }
      print $fh "            gif_rsp_o.rdata($$fld{slc}[1] downto $$fld{slc}[0]) <= $src;\n";
    }
  }
}

print $fh
"          when others =>\n" .
"            gif_rsp_o.rdata <= $dflt_read_pattern;\n" .
"        end case;\n" .
"      end if;\n" .
"    end if;\n" .
"  end process read;\n";


print $fh 
"\n" .
"end architecture rtl;\n";

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

