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
my $hibi_addr_width = 16;
my $mem_addr_width  = 32;
my $mem_data_width  = 32;
my $count_width     = 10;

# command line options table
my %option = 
  ( 'entity'           => { 'string' => 'entity|e=s',             'ref' => \$entity,          'help' => 'Specify entity name'            },
    'lib'              => { 'string' => 'lib|l=s',                'ref' => \$lib,             'help' => 'Specify library name'           },
    'hibi_addr_width'  => { 'string' => 'hibi_addr_width|haw=i',  'ref' => \$hibi_addr_width, 'help' => 'Specify hibi address width'     },
    'mem_addr_width'   => { 'string' => 'mem_addr_width|maw=i',   'ref' => \$mem_addr_width,  'help' => 'Specify memory address width'   },
    'mem_data_width'   => { 'string' => 'mem_data_width|mdw=i',   'ref' => \$mem_data_width,  'help' => 'Specify memory data width'      },    
    'count_width'      => { 'string' => 'count_width|cnt=i',      'ref' => \$count_width,     'help' => 'Specify transfer counter width' },
    'help'             => { 'string' => 'help|?',                 'ref' => \&help,            'help' => 'Show help'                      },
  ); 

# handle command line options
GetOptions( $option{'entity'}          {'string'} => $option{'entity'}          {'ref'},
            $option{'lib'}             {'string'} => $option{'lib'}             {'ref'},
            $option{'hibi_addr_width'} {'string'} => $option{'hibi_addr_width'} {'ref'},
            $option{'mem_addr_width'}  {'string'} => $option{'mem_addr_width'}  {'ref'},
            $option{'mem_data_width'}  {'string'} => $option{'mem_data_width'}  {'ref'},
            $option{'count_width'}     {'string'} => $option{'count_width'}     {'ref'},
            $option{'help'}            {'string'} => $option{'help'}            {'ref'},    
          ) or die;


my $file_name = $entity . "_core.vhd";
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

print $fh "use $lib" . ".$entity" . "_pkg.all;\n";

print $fh
"\n" .
"entity $entity" . "_core is\n" .
"  generic (\n" .
"    log2_burst_length_g : integer range 2 to 8 := 4\n" .
"  );\n" .
"  port (\n" .
"    clk_i         : in  std_ulogic;\n" .
"    reset_n_i     : in  std_ulogic;\n" .
"    init_i        : in  std_ulogic;\n" .
"    en_i          : in  std_ulogic;\n" .
"    ctrl_i        : in  $entity" . "_ctrl_arr_t;\n" .
"    cfg_i         : in  $entity" . "_cfg_arr_t;\n" .
"    status_o      : out $entity" . "_status_arr_t;\n" .
"    mem_req_o     : out $entity" . "_mem_req_t;\n" .
"    mem_rsp_i     : in  $entity" . "_mem_rsp_t;\n" .
"    mem_wait_i    : in  std_ulogic;\n" .    
"    agent_txreq_o : out agent_txreq_t;\n" .
"    agent_txrsp_i : in  agent_txrsp_t;\n" .
"    agent_rxreq_o : out agent_rxreq_t;\n" .
"    agent_rxrsp_i : in  agent_rxrsp_t\n" .    
"  );\n" .
"end entity $entity" . "_core;\n" .
"\n" .
"architecture rtl of $entity" . "_core is\n" .

"  constant max_burst_length_c : integer := 2**log2_burst_length_g;\n" .
"\n" .
"  type buffer_t is array(natural range 0 to max_burst_length_c-1) of std_ulogic_vector($entity" . "_mem_data_width_c-1 downto 0);\n" .
"\n" .
"  type mem_req_t is record\n" .
"    addr        : unsigned($entity" . "_mem_addr_width_c-1 downto 0);\n" .
"    we          : std_ulogic;\n" .
"    en          : std_ulogic;\n" .
"  end record mem_req_t;\n" .
"  constant dflt_mem_req_c : mem_req_t :=(\n" .
"    addr        => (others=>'0'),\n" .
"    we          => '0',\n" .
"    en          => '0'\n" .
"  );\n".
"\n" .
"  type channel_context_t is record\n" .
"    pull_count      : unsigned($entity" . "_count_width_c-1 downto 0);\n" .
"    push_count      : unsigned($entity" . "_count_width_c-1 downto 0);\n" .
"    burst_count     : unsigned(log2_burst_length_g downto 0);\n" .
"    buffer_index    : unsigned(log2_burst_length_g-1 downto 0);\n" .
"    mem_req         : mem_req_t;\n" .
"  end record channel_context_t;\n" .
"  constant dflt_channel_context_c : channel_context_t :=(\n" .
"    pull_count      => (others=>'0'),\n" .
"    push_count      => (others=>'0'),\n" .
"    burst_count     => (others=>'0'),\n" .
"    buffer_index    => (others=>'0'),\n" .
"    mem_req         => dflt_mem_req_c\n" .
"  );\n" .
"\n" .
"  type channel_t is record\n" .
"    data_buffer     : buffer_t;\n" .
"    context         : channel_context_t;\n" .
"    active          : std_ulogic;\n" .
"    status          : $entity" . "_status_t;\n" .
"  end record channel_t;\n" .
"  constant dflt_channel_c : channel_t :=(\n" .
"    data_buffer     => (others=>(others=>'0')),\n" .
"    context         => dflt_channel_context_c,\n" .
"    active          => '0',\n" .
"    status          => dflt_$entity" . "_status_c\n" .
"  );\n" .
"\n" .
"  type channel_arr_t is array(natural range 0 to $entity" . "_channels_c-1) of channel_t;\n" .
"  constant dflt_channel_arr_c : channel_arr_t := (others=>dflt_channel_c);\n" .
"\n" .  
"  type tx_state_t is (tx_idle, context_switch, wait_pull_mem, pull_mem, last_pull_mem, wait_push_hibi, push_hibi);\n" .
"  type rx_state_t is (rx_idle, wait_pull_hibi, pull_hibi, wait_push_mem, push_mem, last_push_mem, rx_error);\n" .
"\n" .
"  type rx_t is record\n" .
"    state        : rx_state_t;\n" .
"    context      : channel_context_t;\n" .   
"    hibi_rxreq   : agent_rxreq_t;\n" .
"    curr_channel : std_ulogic_vector(log2ceil($entity" . "_channels_c)-1 downto 0);\n" .
"    lock_mem     : std_ulogic;\n" .
"  end record rx_t;\n" .
"  constant dflt_rx_c : rx_t :=(\n" .
"    state        => rx_idle,\n" .
"    context      => dflt_channel_context_c,\n" .
"    hibi_rxreq   => dflt_agent_rxreq_c,\n" .
"    curr_channel => (others=>'0'),\n" .
"    lock_mem     => '0'\n" .
"  );\n" .
"\n" .  
"  type tx_t is record\n" .
"    state      : tx_state_t;\n" .
"    context    : channel_context_t;\n" .
"    hibi_txreq : agent_txreq_t;\n" .
"    lock_mem   : std_ulogic;\n" .
"    mem_ack    : std_ulogic;\n" .
"  end record tx_t;\n" .
"  constant dflt_tx_c : tx_t :=(\n" .
"    state      => tx_idle,\n" .
"    context    => dflt_channel_context_c,\n" .
"    hibi_txreq => dflt_agent_txreq_c,\n" .
"    lock_mem   => '0',\n" .
"    mem_ack    => '0'\n" .
"  );\n" .
"\n" .
"  type reg_t is record\n" .
"    tx       : tx_t;\n" .
"    rx       : rx_t;\n" .
"    channels : channel_arr_t;\n" .
"    data     : std_ulogic_vector($entity" . "_mem_data_width_c-1 downto 0);\n" .
"  end record reg_t;\n" .
"  constant dflt_reg_c : reg_t :=(\n" .
"    tx       => dflt_tx_c,\n" .
"    rx       => dflt_rx_c,\n" .
"    channels => dflt_channel_arr_c,\n" .
"    data     => (others=>'0')\n" .
"  );\n" .
"\n" .
"  ------------------------------------------------------------------------------\n" .
"  -- return all active tx channels\n" .
"  ------------------------------------------------------------------------------\n" .
"  function get_tx_channels(ch : channel_arr_t) return std_ulogic_vector is\n" .
"    variable active : std_ulogic_vector($entity" . "_channels_c-1 downto 0);\n" .
"  begin\n" .
"    act: for i in 0 to $entity" . "_channels_c-1 loop\n" .
"      active(i) := ch(i).active and not ch(i).context.mem_req.we;\n" .
"    end loop act;\n" .
"    return active;\n" .
"  end function get_tx_channels;\n" .
"\n" .  
"  ------------------------------------------------------------------------------\n" .
"  -- return all active rx channels\n" .
"  ------------------------------------------------------------------------------\n" .
"  function get_rx_channels(ch : channel_arr_t) return std_ulogic_vector is\n" .
"    variable active : std_ulogic_vector($entity" . "_channels_c-1 downto 0);\n" .
"  begin\n" .
"    act: for i in 0 to $entity" . "_channels_c-1 loop\n" .
"      active(i) := ch(i).active and ch(i).context.mem_req.we;\n" .
"    end loop act;\n" .
"    return active;\n" .
"  end function get_rx_channels;\n" .
"\n" .  
"  ------------------------------------------------------------------------------\n" .
"  -- return binary version of onehot input\n" .
"  ------------------------------------------------------------------------------\n" .
"  function onehot_to_bin(onehot : std_ulogic_vector) return integer is\n" .
"  begin\n" .
"    bin0: for i in onehot'range loop\n" .
"      if(onehot(i) = '1') then\n" .
"        return i;\n" .
"      end if;\n" .
"    end loop bin0;\n" .
"    return 0;\n" .
"  end function onehot_to_bin;\n" .
"\n" .  
"  ------------------------------------------------------------------------------\n" .
"  -- return highest priority bit number that is set\n" .
"  ------------------------------------------------------------------------------\n" .
"  function lsb_set(vec : std_ulogic_vector) return std_ulogic_vector is\n" .
"    variable result : std_ulogic_vector(log2ceil(vec'length)-1 downto 0);\n" .
"  begin\n" .
"    result := (others=>'0');\n" .
"    lsb0: for i in vec'range loop\n" .
"      if(vec(i) = '1') then\n" .
"        result := std_ulogic_vector(to_unsigned(i, result'length));\n" .
"        exit;\n" .
"      end if;\n" .
"    end loop lsb0;\n" .
"    return result;\n" .
"  end function lsb_set;\n" .
"\n" .
"  signal tx_arbi0_grant : std_ulogic_vector($entity" . "_channels_c-1 downto 0);\n" .
"  signal tx_arb_req     : std_ulogic_vector($entity" . "_channels_c-1 downto 0);\n" .
"  signal tx_arb_ack     : std_ulogic;\n" .
"\n" .  
"  signal r, rin         : reg_t;\n" .
"\n" .
"begin\n" .
"  ------------------------------------------------------------------------------\n" .
"  -- tx channel arbiter\n" .
"  ------------------------------------------------------------------------------\n" .
"  tx_arbi0: entity microsimd.round_robin_arb\n" .
"    generic map (\n" .
"      cnt_g =>  $entity" . "_channels_c\n" .
"    )\n" .
"    port map (\n" .
"      clk_i     => clk_i,\n" .
"      reset_n_i => reset_n_i,\n" .
"      en_i      => en_i,\n" .
"      init_i    => init_i,\n" .
"      req_i     => tx_arb_req,\n" .
"      ack_i     => tx_arb_ack,\n" .
"      grant_o   => tx_arbi0_grant\n" .
"    );\n" .
"\n" .
"  ------------------------------------------------------------------------------\n" .
"  -- comb0\n" .
"  ------------------------------------------------------------------------------\n" .
"  comb0: process(r, cfg_i, ctrl_i, mem_rsp_i, mem_wait_i, agent_txrsp_i, agent_rxrsp_i, tx_arbi0_grant) is\n" .
"    variable v               : reg_t;\n" .
"    variable v_tx_arb_req    : std_ulogic_vector($entity" . "_channels_c-1 downto 0);\n" .
"    variable v_tx_arb_ack    : std_ulogic;\n" .
"    variable tx_channel      : integer range 0 to $entity" . "_channels_c-1;\n" .
"    variable rx_channel      : integer range 0 to $entity" . "_channels_c-1;\n" .
"    variable next_rx_channel : integer range 0 to $entity" . "_channels_c-1;\n" .
"    variable mem_req         : mem_req_t;\n" .
"    variable status          : $entity" . "_status_arr_t;\n" .
"  begin\n" .
"    v := r;\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- currently selected rx and tx channel\n" .
"    ----------------------------------------------------------------------------\n" .
"    tx_channel     := onehot_to_bin(tx_arbi0_grant);\n" .
"    rx_channel     := to_integer(unsigned(r.rx.curr_channel));\n" .
"\n" .
"    ----------------------------------------------------------------------------\n" .
"    -- write to internal data buffer MEM --> BUF (tx channel)\n" .
"    ----------------------------------------------------------------------------\n" .
"    if(mem_wait_i = '0') then\n" .
"      v.tx.mem_ack                := r.tx.context.mem_req.en;\n" .
"      if(r.tx.mem_ack = '1') then\n" .
"        v.channels(tx_channel).data_buffer(to_integer(r.tx.context.buffer_index))\n" .
"                                                      := mem_rsp_i.dat;\n" .
"        v.tx.context.buffer_index := r.tx.context.buffer_index + 1;\n" .
"        v.tx.context.pull_count   := r.tx.context.pull_count - 1;\n" .
"        v.tx.context.burst_count  := r.tx.context.burst_count - 1;\n" .
"      end if;\n" .
"    end if;\n" .
"\n" .
"    ----------------------------------------------------------------------------\n" .
"    -- write to internal data buffer HIBI --> BUF (rx channel)\n" .
"    ----------------------------------------------------------------------------\n" .
"    if(r.rx.hibi_rxreq.re = '1' and agent_rxrsp_i.av = '0') then\n" .
"      v.channels(rx_channel).data_buffer(to_integer(r.rx.context.buffer_index))\n" .
"                                  := agent_rxrsp_i.data;\n" .
"      v.rx.context.buffer_index   := r.rx.context.buffer_index + 1;\n" .
"      v.rx.context.pull_count     := r.rx.context.pull_count - 1;\n" .
"      v.rx.context.burst_count    := r.rx.context.burst_count - 1;\n" .                              
"    end if;\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- read / ack from internal data buffer HIBI <-- BUF (tx channel)\n" .
"    ----------------------------------------------------------------------------\n" .
"    if(r.tx.hibi_txreq.we = '1' and r.tx.hibi_txreq.av = '0') then\n" .
"      v.tx.context.buffer_index   := r.tx.context.buffer_index + 1;\n" .
"      v.tx.context.push_count     := r.tx.context.push_count - 1;\n" .
"      v.tx.context.burst_count    := r.tx.context.burst_count - 1;\n" .
"    end if;\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- read / ack from internal data buffer MEM <-- BUF (rx channel)\n" .
"    ----------------------------------------------------------------------------\n" .
"    if(mem_wait_i = '0') then\n" .
"      if(r.rx.context.mem_req.en = '1') then\n" .
"        v.rx.context.buffer_index   := r.rx.context.buffer_index + 1;\n" .
"        v.rx.context.push_count     := r.rx.context.push_count - 1;\n" .
"        v.rx.context.burst_count    := r.rx.context.burst_count - 1;\n" .
"      end if;\n" .
"    end if;\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- mark each channel being started as active and store direction\n" .
"    ----------------------------------------------------------------------------\n" .
"    act0: for i in 0 to $entity" . "_channels_c-1 loop\n" .
"      if(ctrl_i(i).start = '1' and unsigned(cfg_i(i).count) /= 0) then\n" .
"        v.channels(i).active                := '1';\n" .
"        v.channels(i).status.busy           := '1';\n" .
"        v.channels(i).context.pull_count    := unsigned(cfg_i(i).count);\n" .
"        v.channels(i).context.push_count    := unsigned(cfg_i(i).count);\n" .
"        v.channels(i).context.mem_req.addr  := unsigned(cfg_i(i).mem_addr);\n" .
"        v.channels(i).context.mem_req.we    := not cfg_i(i).direction;\n" .
"\n" .        
"        v.channels(i).context.burst_count   := to_unsigned(max_burst_length_c,  v.channels(i).context.burst_count'length);\n" .
"        if(unsigned(cfg_i(i).count) < max_burst_length_c) then\n" .
"          v.channels(i).context.burst_count := unsigned(cfg_i(i).count(v.channels(i).context.burst_count'range));\n" .
"        end if;\n" .
"      end if;\n" .
"    end loop act0;\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- generate arbitration request\n" .
"    ----------------------------------------------------------------------------\n" .
"    v_tx_arb_ack := '0';\n" .
"    v_tx_arb_req := get_tx_channels(r.channels);\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- channel DMA tx-fsm\n" .
"    ----------------------------------------------------------------------------\n" .
"    case v.tx.state is\n" .
"      when tx_idle         => if(unsigned(v_tx_arb_req) /= 0) then\n" .             
"                                v.tx.state                  := context_switch;\n" .
"                              end if;\n" .
"\n" .                              
"      when context_switch  => v.tx.context                  := v.channels(tx_channel).context;\n" .
"\n" .      
"                              v.tx.context.burst_count      := to_unsigned(max_burst_length_c, v.tx.context.burst_count'length);\n" .
"                              if(v.tx.context.pull_count < max_burst_length_c) then\n" .
"                                v.tx.context.burst_count    := v.tx.context.pull_count(v.tx.context.burst_count'range);\n" .
"                              end if;\n" .
"\n" .                                
"                              v.tx.state                    := pull_mem;\n" .
"                              v.tx.context.mem_req.en       := '1';\n" .
"                              v.tx.lock_mem                 := '1';\n" .
"\n" .                               
"                              if(mem_wait_i = '1' or r.rx.lock_mem = '1') then\n" .
"                                v.tx.state                  := wait_pull_mem;\n" .
"                                v.tx.context.mem_req.en     := '0';\n" .
"                                v.tx.lock_mem               := '0';\n" .
"                              end if;\n" .
"\n" .                
"      when wait_pull_mem   => if(mem_wait_i = '0' and r.rx.lock_mem = '0') then\n" .
"                                v.tx.state                  := pull_mem;\n" .
"                                v.tx.context.mem_req.en     := '1';\n" .
"                                v.tx.lock_mem               := '1';\n" . 
"                              end if;\n" .
"\n" .    
"      when pull_mem        => if(mem_wait_i = '0') then\n" .
"                                if(cfg_i(tx_channel).const_addr = '0') then\n" .
"                                  v.tx.context.mem_req.addr := r.tx.context.mem_req.addr + 4;\n" .
"                                end if;\n" .
"\n" .
"                                if(v.tx.context.burst_count = 1) then\n" .
"                                  v.tx.state                := last_pull_mem;\n" .
"                                  v.tx.context.mem_req.en   := '0';\n" .
"                                  v.tx.lock_mem             := '0';\n" .
"                                end if;\n" .
"                              end if;\n" .
"\n" .                              
"      when last_pull_mem   => if(mem_wait_i = '0') then\n" .
"                                v.tx.hibi_txreq.we          := '1';\n" .
"                                v.tx.hibi_txreq.av          := '1';\n" .
"                                v.tx.hibi_txreq.comm        := cfg_i(tx_channel).cmd;\n" .
"                                v.tx.state                  := push_hibi;\n" .
"\n" .
"                                v.tx.context.buffer_index   := (others=>'0');\n" .
"                                v.tx.context.burst_count    := to_unsigned(max_burst_length_c, v.tx.context.burst_count'length);\n" .
"                                if(v.tx.context.push_count < max_burst_length_c) then\n" .
"                                  v.tx.context.burst_count  := v.tx.context.push_count(v.tx.context.burst_count'range);\n" .
"                                end if;\n" .
"\n" .                               
"                                if(agent_txrsp_i.full = '1') then\n" .
"                                  v.tx.state                := wait_push_hibi;\n" .
"                                  v.tx.hibi_txreq.we        := '0';\n" .
"                                end if;\n" .
"                              end if;\n" .
"\n" .    
"      when wait_push_hibi  => if(agent_txrsp_i.full = '0') then\n" .
"                                v.tx.state                  := push_hibi;\n" .
"                                v.tx.hibi_txreq.we          := '1';\n" .
"                              end if;\n" .
"\n" .
"      when push_hibi       => v.tx.hibi_txreq.av            := '0';\n" .
"\n" .      
"                              if(agent_txrsp_i.full = '1' or (r.tx.hibi_txreq.we = '1' and agent_txrsp_i.almost_full = '1')) then\n" .
"                                v.tx.hibi_txreq.we          := '0';\n" .
"                              else\n" .
"                                v.tx.hibi_txreq.we          := '1';\n" .
"                              end if;\n" .
"\n" .                             
"                              --------------------------------------------------\n" .
"                              -- deassert active one cycle before last transfer\n" .
"                              -- as it must be deasserted before the arbiter ack\n" .
"                              --------------------------------------------------\n" .
"                              if(v.tx.context.burst_count = 1 and v.tx.context.push_count = 1) then\n" .
"                                v.channels(tx_channel).active        := '0';\n" .
"                              end if;\n" .
"\n" .                              
"                              if(v.tx.context.burst_count = 0) then\n" .
"                                v.tx.context.buffer_index            := (others=>'0');\n" .
"                                v.channels(tx_channel).context       := v.tx.context;\n" .
"                                v.tx.state                           := context_switch;\n" .
"                                v.tx.hibi_txreq.we                   := '0';\n" .
"                                v_tx_arb_ack                         := '1';\n" .
"\n" .                                 
"                                if(v.tx.context.push_count = 0) then\n" .
"                                  v.channels(tx_channel).status.busy := '0';\n" .
"                                  v.channels(tx_channel).active      := '0';\n" .
"                                  v.tx.state                         := tx_idle;\n" .
"                                end if;\n" .
"                              end if;\n" .
"\n" .                                 
"      when others          => null;\n" .
"    end case;\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- channel DMA rx-fsm\n" .
"    ----------------------------------------------------------------------------\n" .
"    next_rx_channel := to_integer(unsigned(agent_rxrsp_i.data(v.rx.curr_channel'range)));\n" .
"\n" .    
"    case v.rx.state is\n" .
"      when rx_idle         => if(unsigned(get_rx_channels(r.channels)) /= 0) then\n" .
"                                v.rx.curr_channel             := lsb_set(get_rx_channels(r.channels));\n" .
"                                v.rx.context                  := r.channels(to_integer(unsigned(v.rx.curr_channel))).context;\n" .
"\n" .                                
"                                if(agent_rxrsp_i.empty = '1') then\n" .
"                                  v.rx.state                  := wait_pull_hibi;\n" .
"                                  v.rx.hibi_rxreq.re          := '0';\n" .
"                                else\n" .
"                                  v.rx.state                  := pull_hibi;\n" .
"                                  v.rx.hibi_rxreq.re          := '1';\n" .
"                                end if;\n" .
"                              end if;\n" .
"\n" .                              
"      when wait_pull_hibi  => if(agent_rxrsp_i.empty = '0') then\n" .
"                                v.rx.state                    := pull_hibi;\n" .
"                                v.rx.hibi_rxreq.re            := '1';\n" .
"                              end if;\n" .
"\n" .                              
"      when pull_hibi       => if(agent_rxrsp_i.empty = '1' or (r.rx.hibi_rxreq.re = '1' and agent_rxrsp_i.almost_empty = '1')) then\n" .
"                                v.rx.hibi_rxreq.re            := '0';\n" .
"                              else\n" .
"                                v.rx.hibi_rxreq.re            := '1';\n" .
"                              end if;\n" .
"\n" .                              
"                              if(agent_rxrsp_i.av = '1') then\n" .
"                                v.rx.curr_channel                := agent_rxrsp_i.data(v.rx.curr_channel'range);\n" .
"\n" .                                
"                                if(v.channels(next_rx_channel).context.mem_req.we = '0') then\n" .
"                                  v.rx.state                     := rx_error;\n" .
"                                end if;\n" .
"\n" .                               
"                                if(v.rx.curr_channel /= r.rx.curr_channel) then\n" .
"                                  v.channels(rx_channel).context := r.rx.context;\n" .
"                                  v.rx.context                   := r.channels(next_rx_channel).context;\n" .
"                                end if;\n" .
"                              else\n" .
"                                if(v.rx.context.burst_count = 0) then\n" .
"                                  v.rx.state                     := push_mem;\n" .
"                                  v.rx.hibi_rxreq                := dflt_agent_rxreq_c;\n" .
"                                  v.rx.context.mem_req.en        := '1';\n" .
"                                  v.rx.lock_mem                  := '1';\n" .
"\n" .                                 
"                                  if(mem_wait_i = '1' or v.tx.lock_mem = '1' or r.tx.lock_mem = '1') then\n" .
"                                    v.rx.state                   := wait_push_mem;\n" .
"                                    v.rx.context.mem_req.en      := '0';\n" .
"                                    v.rx.lock_mem                := '0';\n" .
"                                  end if;\n" .
"\n" .                                 
"                                  v.rx.context.buffer_index      := (others=>'0');\n" .
"                                  v.rx.context.burst_count       := to_unsigned(max_burst_length_c, v.rx.context.burst_count'length);\n" .
"                                  if(v.rx.context.push_count < max_burst_length_c) then\n" .
"                                    v.rx.context.burst_count     := v.rx.context.push_count(v.rx.context.burst_count'range);\n" .
"                                  end if;\n" .
"                                end if;\n" .
"                              end if;\n" .
"\n" .                              
"      when wait_push_mem   => if(mem_wait_i = '0' and v.tx.lock_mem = '0' and r.tx.lock_mem = '0') then\n" .
"                                v.rx.state                    := push_mem;\n" .
"                                v.rx.context.mem_req.en       := '1';\n" .
"                                v.rx.lock_mem                 := '1';\n" .
"                              end if;\n" .
"\n" .                            
"      when push_mem        => if(mem_wait_i = '0') then\n" .
"                                if(cfg_i(rx_channel).const_addr = '0') then\n" .
"                                  v.rx.context.mem_req.addr   := r.rx.context.mem_req.addr + 4;\n" .
"                                end if;\n" .
"\n" .                             
"                                if(v.rx.context.burst_count = 0) then\n" .
"                                  v.rx.state                  := pull_hibi;\n" .
"                                  v.rx.hibi_rxreq.re          := '1';\n" .
"                                  v.rx.context.mem_req.en     := '0';\n" .
"                                  v.rx.lock_mem               := '0';\n" .
"\n" .                             
"                                  v.rx.context.buffer_index   := (others=>'0');\n" .    
"                                  v.rx.context.burst_count    := to_unsigned(max_burst_length_c, v.rx.context.burst_count'length);\n" .
"                                  if(v.rx.context.pull_count < max_burst_length_c) then\n" .
"                                    v.rx.context.burst_count  := v.rx.context.pull_count(v.rx.context.burst_count'range);\n" .
"                                  end if;\n" .
"\n" .                                                                  
"                                  if(agent_rxrsp_i.empty = '1') then\n" .
"                                    v.rx.state                := wait_pull_hibi;\n" .
"                                    v.rx.hibi_rxreq.re        := '0';\n" .
"                                  end if;\n" .
"\n" .                                 
"                                  if(v.rx.context.push_count = 0) then\n" .
"                                    v.rx.state                := rx_idle;\n" .
"                                    v.rx.context.mem_req      := dflt_mem_req_c;\n" .
"\n" .
"                                    v.channels(rx_channel).status.busy := '0';\n" .
"                                    v.channels(rx_channel).active      := '0';\n" .
"                                  end if;\n" .
"                                end if;\n" .
"                              end if;\n" .
"\n" .                             
"      when rx_error        => --TODO: disable all rx channels and return to idle\n" . 
"                              --v.rx.state                             := rx_idle;\n" .
"                              v.rx.hibi_rxreq.re                       := '0';\n" .
"                              v.channels(rx_channel).status.busy       := '0';\n" .
"                              v.channels(rx_channel).active            := '0';\n" .
"\n" .
"      when others          => null;\n" .
"    end case;\n" .
"\n" .
"    ----------------------------------------------------------------------------\n" .
"    -- mem rx data multiplexing\n" .
"    ----------------------------------------------------------------------------\n" .
"    v.data                 := v.channels(rx_channel).data_buffer(to_integer(v.rx.context.buffer_index));\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- hibi tx data multiplexing\n" .
"    ----------------------------------------------------------------------------\n" .
"    v.tx.hibi_txreq.data   := v.channels(tx_channel).data_buffer(to_integer(v.tx.context.buffer_index));\n" .
"    if(v.tx.hibi_txreq.av = '1') then\n" .
"      v.tx.hibi_txreq.data := std_ulogic_vector(resize(unsigned(cfg_i(tx_channel).hibi_addr), v.tx.hibi_txreq.data'length));\n" .
"    end if;\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- memory request mux\n" .
"    ----------------------------------------------------------------------------\n" .
"    if(r.tx.lock_mem = '1') then\n" .
"      mem_req := r.tx.context.mem_req;\n" .
"    else\n" .
"      mem_req := r.rx.context.mem_req;\n" .
"    end if;\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- channel status assignment\n" .
"    ----------------------------------------------------------------------------\n" .
"    status0: for i in 0 to $entity" . "_channels_c-1 loop\n" .
"      status(i) := r.channels(i).status;\n" .
"    end loop status0;\n" .
"\n" .
"    ----------------------------------------------------------------------------\n" .
"    -- drive tx arbiter\n" .
"    ----------------------------------------------------------------------------\n" .
"    tx_arb_req     <= v_tx_arb_req;\n" .
"    tx_arb_ack     <= v_tx_arb_ack;\n" .
"\n" .
"    ----------------------------------------------------------------------------\n" .
"    -- drive module output\n" .
"    ----------------------------------------------------------------------------\n" .
"    status_o       <= status;\n" .
"\n" .    
"    agent_txreq_o  <= r.tx.hibi_txreq;\n" .
"    agent_rxreq_o  <= r.rx.hibi_rxreq;\n" .
"\n" .
"    mem_req_o      <= (adr =>std_ulogic_vector(mem_req.addr), we => mem_req.we, ena => mem_req.en, dat => r.data);\n" .
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


