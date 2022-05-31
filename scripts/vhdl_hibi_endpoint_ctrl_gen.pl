#!/usr/bin/perl
use Getopt::Long;
use File::Basename;
use FileHandle;
use strict;

my $timestamp = localtime();
my $user      = $ENV{'USER'};
my $host      = $ENV{'HOSTNAME'};

my $entity          = "hibi_dma";
my $lib             = "work";

# command line options table
my %option = 
  ( 'entity'  => { 'string' => 'entity|e=s',  'ref' => \$entity,  'help' => 'Specify entity name'   },
    'lib'     => { 'string' => 'lib|l=s',     'ref' => \$lib,     'help' => 'Specify library name'  },
    'help'    => { 'string' => 'help|?',      'ref' => \&help,    'help' => 'Show help'             },
  ); 

# handle command line options
GetOptions( $option{'entity'}  {'string'} => $option{'entity'}  {'ref'},
            $option{'lib'}     {'string'} => $option{'lib'}     {'ref'},
            $option{'help'}    {'string'} => $option{'help'}    {'ref'},    
          ) or die;
    
my $file_name = $entity . "_ctrl.vhd";
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
"library general;\n" .
"use general.general_function_pkg.all;\n" .
"\n" .
"library microsimd;\n" .
"use microsimd.hibi_link_pkg.all;\n";

if(!($lib eq "microsimd"))
{
  print $fh "library $lib;\n";
}

print $fh "use $lib" . ".$entity" . "_regif_types_pkg.all;\n";

print $fh
"\n" .
"entity $entity" . "_ctrl is\n" .
"  port (\n" .
"    clk_i              : in  std_ulogic;\n" .
"    reset_n_i          : in  std_ulogic;\n" .
"    init_i             : in  std_ulogic;\n" .
"    en_i               : in  std_ulogic;\n" .
"    gif_req_o          : out $entity" . "_gif_req_t;\n" .
"    gif_rsp_i          : in  $entity" . "_gif_rsp_t;\n" .
"    agent_msg_txreq_o  : out agent_txreq_t;\n" .
"    agent_msg_txrsp_i  : in  agent_txrsp_t;\n" .
"    agent_msg_rxreq_o  : out agent_rxreq_t;\n" .
"    agent_msg_rxrsp_i  : in  agent_rxrsp_t\n" .
"  );\n" .
"end entity $entity" . "_ctrl;\n" .
"\n" .
"architecture rtl of $entity" . "_ctrl is\n" .
"\n" .
"  type state_t is (idle, delay, wr_data, rd_src, rd_addr, rd_data);\n" .
"\n" .  
"  type reg_t is record\n" .
"    state      : state_t;\n" .
"    gif_req    : $entity" . "_gif_req_t;\n" .
"    hibi_rxreq : agent_rxreq_t;\n" .
"    hibi_txreq : agent_txreq_t;\n" .
"  end record reg_t;\n" .
"  constant dflt_reg_c : reg_t :=(\n" .
"    state      => idle,\n" .
"    gif_req    => dflt_$entity" ."_gif_req_c,\n" .
"    hibi_rxreq => dflt_agent_rxreq_c,\n" .
"    hibi_txreq => dflt_agent_txreq_c\n" .
"  );\n" .
"\n" .  
"  signal r, rin : reg_t;\n" .
"\n" .
"begin\n" .
"  ------------------------------------------------------------------------------\n" .
"  -- comb0\n" .
"  ------------------------------------------------------------------------------\n" .
"  comb0: process(r, gif_rsp_i, agent_msg_txrsp_i, agent_msg_rxrsp_i) is\n" .
"    variable v: reg_t;\n" .
"  begin\n" .
"    v := r;\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- control FSM\n" .
"    ----------------------------------------------------------------------------\n" .
"    v.hibi_txreq.we     := '0';\n" .
"    v.hibi_rxreq.re     := '0';\n" .
"    v.gif_req.wr        := '0';\n" .
"    v.gif_req.rd        := '0';\n" .
"\n" .    
"    case(r.state) is\n" .
"      when idle    => if(agent_msg_rxrsp_i.empty = '0') then\n" .
"                        v.hibi_rxreq.re     := '1';\n" .
"                        v.state             := delay;\n" .
"                      end if;\n" .
"\n" .                                            
"      when delay   => if(agent_msg_rxrsp_i.empty = '1' or (r.hibi_rxreq.re = '1' and agent_msg_rxrsp_i.almost_empty = '1')) then\n" .
"                        v.hibi_rxreq.re     := '0';\n" .
"                      else\n" .
"                        v.hibi_rxreq.re     := '1';\n" .
"                        if(agent_msg_rxrsp_i.av = '1') then\n" .
"                          v.gif_req.addr    := agent_msg_rxrsp_i.data(v.gif_req.addr'range);\n" .
"                          if(agent_msg_rxrsp_i.comm = hibi_wr_prio_data_c) then\n" .
"                            v.state         := wr_data;\n" .
"                          elsif(agent_msg_rxrsp_i.comm = hibi_rd_prio_data_c) then\n" .
"                            v.state         := rd_src;\n" .
"                            v.gif_req.rd    := '1';\n" .
"                          end if;\n" .
"                        end if;\n" .
"                      end if;\n" .
"\n" .                                       
"      when wr_data => v.state               := idle;\n" .
"                      v.gif_req.wdata       := agent_msg_rxrsp_i.data(v.gif_req.wdata'range);\n" .
"                      v.gif_req.wr          := '1';\n" .
"                      v.hibi_rxreq.re       := '0';\n" .
"\n" .                      
"      when rd_src  => v.hibi_txreq.data     := agent_msg_rxrsp_i.data;\n" .
"                      v.state               := rd_data;\n" .
"\n" .                      
"                      -- NOTE: we awnser with hibi_wr_data_c on prio read requests\n" .
"                      if(agent_msg_txrsp_i.full = '0') then\n" .
"                        v.hibi_txreq.we     := '1';\n" .
"                        v.hibi_txreq.comm   := hibi_wr_data_c;\n" .
"                        v.hibi_txreq.av     := '1';\n" .
"                      end if;\n" .
"\n" .                      
"      when rd_data => v.hibi_txreq.av       := '0';\n" .
"                      if(agent_msg_txrsp_i.full = '1' or (r.hibi_txreq.we = '1' and agent_msg_txrsp_i.almost_full = '1')) then\n" .
"                        v.hibi_txreq.we     := '0';\n" .
"                      else\n" .
"                        v.hibi_txreq.we     := '1';\n" .
"                        v.hibi_txreq.data   := std_ulogic_vector(resize(unsigned(gif_rsp_i.rdata), v.hibi_txreq.data'length));\n" .
"                        v.state             := idle;\n" .
"                      end if;\n" .
"\n" .      
"      when others  => null;\n" .
"    end case;\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- drive module output\n" .
"    ----------------------------------------------------------------------------\n" .
"    agent_msg_txreq_o <= r.hibi_txreq;\n" .
"    agent_msg_rxreq_o <= r.hibi_rxreq;\n" .
"    gif_req_o         <= r.gif_req; \n" .
"\n" .    
"    rin <= v;\n" .
"  end process comb0;\n" .
"\n" .  
"  ------------------------------------------------------------------------------\n" .
"  -- sync0\n" .
"  ------------------------------------------------------------------------------\n" .
"  sync0: process(clk_i, reset_n_i) is\n" .
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

