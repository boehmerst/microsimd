#!/usr/bin/perl
use Getopt::Long;
use File::Basename;
use FileHandle;
use strict;

my $timestamp = localtime();
my $user      = $ENV{'USER'};
my $host      = $ENV{'HOSTNAME'};

my $entity   = "hibi_dma";
#my $channels = 4;

# command line options table
my %option = 
  ( 'entity'   => { 'string' => 'entity|e=s',    'ref' => \$entity,    'help' => 'Specify entity name'        },
#    'channels' => { 'string' => 'channels|ch=i', 'ref' => \$channels,  'help' => 'Specify number of channels' },    
    'help'     => { 'string' => 'help|?',        'ref' => \&help,      'help' => 'Show help'                  },
  ); 
  
# handle command line options
GetOptions( $option{'entity'}   {'string'} => $option{'entity'}   {'ref'},
#            $option{'channels'} {'string'} => $option{'channels'} {'ref'},            
            $option{'help'}     {'string'} => $option{'help'}     {'ref'},    
          ) or die;

my $file_name = $entity . "_trigger.vhd";
my $fh = new FileHandle;
open($fh, ">$file_name") or die "could not create $file_name\n";   

# generate Header
print $fh
"-------------------------------------------------------------------------------\n" .
"-- Title      : $entity\n" .
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
"entity $entity" . "_trigger is\n" .
"  generic (\n" .
"    $entity" . "_channels_g : natural\n" .
"  );\n" .
"  port (\n" .
"    clk_i     : in  std_ulogic;\n" .
"    reset_n_i : in  std_ulogic;\n" .
"    init_i    : in  std_ulogic;\n" .
"    en_i      : in  std_ulogic;\n" .
"    start_i   : in  std_ulogic;\n" .
"    busy_i    : in  std_ulogic;\n" .
"    trigger_i : in  std_ulogic_vector($entity" . "_channels_g-1 downto 0);\n" .
"    mask_i    : in  std_ulogic_vector($entity" . "_channels_g-1 downto 0);\n" .
"    trigger_o : out std_ulogic;\n" .
"    start_o   : out std_ulogic\n" .
"  );\n" .
"end entity $entity" . "_trigger;\n" .
"\n" .
"architecture rtl of $entity" . "_trigger is\n" .
"\n" .
"  type state_t is (idle, started, triggered, running);\n" .
"\n" .  
"  type reg_t is record\n" .
"    state   : state_t;\n" .
"    start   : std_ulogic;\n" .
"    events  : std_ulogic_vector($entity" . "_channels_g-1 downto 0);\n" .
"    trigger : std_ulogic;\n" .
"  end record reg_t;\n" .
"  constant dflt_reg_c : reg_t :=(\n" .
"    state   => idle,\n" .
"    start   => '0',\n" .
"    events  => (others=>'0'),\n" .
"    trigger => '0'\n" .
"  );\n" .
"\n" .
"  signal r, rin : reg_t;\n" .
"\n" .
"begin\n" .
"  ------------------------------------------------------------------------------\n" .
"  -- comb0\n" .
"  ------------------------------------------------------------------------------\n" .
"  comb0: process(r, start_i, trigger_i, mask_i, busy_i) is\n" .
"    variable v     : reg_t;\n" .
"    variable match : std_ulogic;\n" .
"  begin\n" .
"    v := r;\n" .
"\n" .    
"    v.start   := '0';\n" .
"    v.trigger := '0';\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- conditionally latch event\n" .
"    ----------------------------------------------------------------------------\n" .
"    set0: for i in trigger_i'range loop\n" .
"      if(trigger_i(i) = '1') then\n" .
"        v.events(i) := mask_i(i);\n" .
"      end if;\n" .
"    end loop set0;\n" .
 "\n" .
"    ----------------------------------------------------------------------------\n" .
"    -- signal matching event\n" .
"    ----------------------------------------------------------------------------\n" .
"    match   := '0';\n" .
"    if(v.events = mask_i) then\n" .
"      match := '1';\n" .
"    end if;\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- control FSM\n" .
"    ----------------------------------------------------------------------------\n" .
"    fsm0: case r.state is\n" .
"      when idle      => if(start_i = '1') then\n" .
"                          if(match = '1') then\n" .
"                            v.state  := triggered;\n" .
"                            v.start  := '1';\n" .
"                          else\n" .
"                            v.state  := started;\n" .
"                          end if;\n" .
"                        end if;\n" .
"\n" .
"      when started   => if(match = '1') then\n" .
"                          v.state   := triggered;\n" .
"                          v.start   := '1';\n" .
"                        end if;\n" .
"\n" .      
"      when triggered => if(busy_i = '1') then\n" .
"                          v.state := running;\n" .
"                        end if;\n" .
"\n" .
"      when running   => if(busy_i = '0') then\n" .
"                          v.state   := idle;\n" .
"                          v.trigger := '1';\n" .
"                          v.events  := (others=>'0');\n" .
"                        end if;\n" .
"\n" .
"      when others    => null;\n" .
"    end case fsm0;\n" .
"\n" .
"    ----------------------------------------------------------------------------\n" .
"    -- drive module output\n" .
"    ----------------------------------------------------------------------------\n" .
"    trigger_o <= r.trigger;\n" .
"    start_o   <= r.start;\n" .
"\n" .
"    rin <= v;\n" .
"  end process comb0;\n" .
"\n" .
"  ------------------------------------------------------------------------------\n" .
"  -- sync0\n" .
"  ------------------------------------------------------------------------------\n" .
"  sync0: process(reset_n_i, clk_i) is\n" .
"  begin\n" .
"    if(reset_n_i = '0') then\n" .
"      r <= dflt_reg_c;\n" .
"    elsif(rising_edge(clk_i)) then\n" .
"      if(en_i = '1') then\n" .
"        if(init_i = '1') then\n" .
"          r <= dflt_reg_c;\n" .
"        else\n" .
"          r <= rin;\n" .
"        end if;\n" .
"      end if;\n" .
"    end if;\n" .
"  end process sync0;\n" .
"\n" .  
"end architecture rtl;\n" .
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

