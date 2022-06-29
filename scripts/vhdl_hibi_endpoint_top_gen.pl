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
my $channels        =  4;
my $hostif;
my $chaining;
my $gpio;

# command line options table
my %option = 
  ( 'entity'           => { 'string' => 'entity|e=s',             'ref' => \$entity,          'help' => 'Specify entity name'                },
    'lib'              => { 'string' => 'lib|l=s',                'ref' => \$lib,             'help' => 'Specify library name'               },
    'channels'         => { 'string' => 'channels|ch=i',          'ref' => \$channels,        'help' => 'Specify number of channels'         },
    'hostif'           => { 'string' => 'hostif|hi',              'ref' => \$hostif,          'help' => 'DMA has external host interface'    },
    'chaining'         => { 'string' => 'chaining|chn',           'ref' => \$chaining,        'help' => 'Support for chaining DMA transfers' },
    'gpio'             => { 'string' => 'gpio|g',                 'ref' => \$gpio,            'help' => 'Support for GPIO'                   },
    'help'             => { 'string' => 'help|?',                 'ref' => \&help,            'help' => 'Show help'                          },
  ); 

# handle command line options
GetOptions( $option{'entity'}          {'string'} => $option{'entity'}          {'ref'},
            $option{'lib'}             {'string'} => $option{'lib'}             {'ref'},
            $option{'channels'}        {'string'} => $option{'channels'}        {'ref'},
            $option{'hostif'}          {'string'} => $option{'hostif'}          {'ref'},
            $option{'chaining'}        {'string'} => $option{'chaining'}        {'ref'},
	    $option{'gpio'}            {'string'} => $option{'gpio'}            {'ref'},	    
            $option{'help'}            {'string'} => $option{'help'}            {'ref'},    
          ) or die;

# generate gif mux
if(defined($hostif)) {
  my$file_name = $entity . "_gif_mux.vhd";
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
"library $lib;\n" .
"use $lib" . ".$entity" . "_regif_types_pkg.all;\n" .
"\n" .
"entity $entity" ."_gif_mux is\n" .
"  port (\n" .
"    clk_i         : in  std_ulogic;\n" .
"    reset_n_i     : in  std_ulogic;\n" .
"    en_i          : in  std_ulogic;\n" .
"    init_i        : in  std_ulogic;\n" .
"    m0_gif_req_i  : in  $entity" . "_gif_req_t;\n" .
"    m0_gif_rsp_o  : out $entity" . "_gif_rsp_t;\n" .
"    m1_gif_req_i  : in  $entity" . "_gif_req_t;\n" .
"    m1_gif_rsp_o  : out $entity" . "_gif_rsp_t;\n" .
"    mux_gif_req_o : out $entity" . "_gif_req_t;\n" .
"    mux_gif_rsp_i : in  $entity" . "_gif_rsp_t\n" .
"  );\n" .
"end entity $entity" . "_gif_mux;\n" .
"\n" .
"architecture rtl of $entity" . "_gif_mux is\n" .
"\n" .
"  type reg_t is record\n" .
"    state   : std_ulogic;\n" .
"    mux_sel : std_ulogic;\n" .
"  end record reg_t;\n" .
"  constant dflt_reg_c : reg_t :=(\n" .
"    state   => '0',\n" .
"    mux_sel => '0'\n" .
"  );\n" .
"\n" .
"  signal r, rin : reg_t;\n" .
"\n" .
"begin\n" .
"  ------------------------------------------------------------------------------\n" .
"  -- comb0\n" .
"  ------------------------------------------------------------------------------\n" .
"  comb0: process(r, m0_gif_req_i, m1_gif_req_i) is\n" .
"    variable v         : reg_t;\n" .
"    variable m0_req_en : std_ulogic;\n" .
"    variable m1_req_en : std_ulogic;\n" .
"  begin\n" .
"    v := r;\n" .
"\n" .    
"    m0_req_en := m0_gif_req_i.rd or m0_gif_req_i.wr;\n" .
"    m1_req_en := m1_gif_req_i.rd or m1_gif_req_i.wr;\n" .
"\n" .    
"    ----------------------------------------------------------------------------\n" .
"    -- this is a simplified mux that strictely assumes the slave to respond\n" .
"    -- in the following clock cycle\n" .
"    -- master zero is served first in case of competing requests\n" .
"    -- master one is expected to hold its request active while being stalled\n" .
"    ----------------------------------------------------------------------------\n" .
"    case v.state is\n" .
"      when '0'    => v.mux_sel   := '0';\n" .
"                     v.state     := '0';\n" .
"\n" .                     
"                     if(m0_req_en = '0' and m1_req_en = '1') then\n" .
"                       v.mux_sel := '1';\n" .
"                     end if;\n" .
"\n" .                     
"                     if(m0_req_en = '1' and m1_req_en = '1') then\n" .
"                       v.state   := '1';\n" .
"                     end if;\n" .
"\n" .      
"      when '1'    => v.mux_sel   := '1';\n" .
"                     v.state     := '0';\n" .
"\n" .      
"      when others => null;\n" .
"    end case;\n" .
"\n" .    
"    rin <= v;\n" .
"  end process comb0;\n" .
"\n" .  
"  mux_gif_req_o      <= m0_gif_req_i when rin.mux_sel = '0' else  m1_gif_req_i;\n" .
"\n" .  
"  m0_gif_rsp_o.rdata <= mux_gif_rsp_i.rdata;\n" .
"  m1_gif_rsp_o.rdata <= mux_gif_rsp_i.rdata;\n" .
"\n" .  
"  m0_gif_rsp_o.ack   <= mux_gif_rsp_i.ack when r.mux_sel = '0' else '0';\n" .
"  m1_gif_rsp_o.ack   <= mux_gif_rsp_i.ack when r.mux_sel = '1' else '0';\n" .
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

close($fh);
}


my $file_name = $entity . ".vhd";
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
"library microsimd;\n" .
"use microsimd.hibi_link_pkg.all;\n" .
"\n";

if(!($lib eq "microsimd")) {
  print $fh "library $lib;\n";
}

print $fh "use $lib" . ".$entity" . "_pkg.all;\n";
print $fh "use $lib" . ".$entity" . "_regif_types_pkg.all;\n";
print $fh "use $lib" . ".$entity" . "_regfile_pkg.all;\n";

print $fh
"\n" .
"entity $entity is\n" .
"  generic (\n" .
"    log2_burst_length_g : integer range 2 to 5 := 4\n" .
"  );\n" .
"  port (\n" .
"    clk_i             : in  std_ulogic;\n" .
"    reset_n_i         : in  std_ulogic;\n" .
"    en_i              : in  std_ulogic;\n" .
"    init_i            : in  std_ulogic;\n";

if(defined($hostif)) {
  print $fh
"    ext_gif_req_i     : in  $entity" . "_gif_req_t;\n" .
"    ext_gif_rsp_o     : out $entity" . "_gif_rsp_t;\n";
}

if(defined($gpio)) {
  print $fh
"    gpio_o            : out $entity" . "_HIBI_DMA_GPIO_reg2logic_t;\n" .
"    gpio_i            : in  $entity" . "_HIBI_DMA_GPIO_logic2reg_t;\n" .
"    gpio_dir_o        : out $entity" . "_HIBI_DMA_GPIO_DIR_reg2logic_t;\n";
}

print $fh
"    mem_req_o         : out $entity" . "_mem_req_t;\n" .
"    mem_rsp_i         : in  $entity" . "_mem_rsp_t;\n" .
"    mem_wait_i        : in  std_ulogic;\n" .
"    agent_txreq_o     : out agent_txreq_t;\n" .
"    agent_txrsp_i     : in  agent_txrsp_t;\n" .
"    agent_rxreq_o     : out agent_rxreq_t;\n" .
"    agent_rxrsp_i     : in  agent_rxrsp_t;\n" .
"    agent_msg_txreq_o : out agent_txreq_t;\n" .
"    agent_msg_txrsp_i : in  agent_txrsp_t;\n" .
"    agent_msg_rxreq_o : out agent_rxreq_t;\n" .
"    agent_msg_rxrsp_i : in  agent_rxrsp_t;\n" .
"    status_o          : out $entity" . "_status_arr_t\n" .
"  );\n" .
"end entity $entity;\n" .
"\n".
"architecture rtl of $entity is\n" .
"\n" .
"  signal regifi0_gif_rsp    : $entity" . "_gif_rsp_t;\n" .
"  signal regifi0_reg2logic  : $entity" . "_reg2logic_t;\n" .
"\n" .  
"  signal ctrli0_gif_req     : $entity" . "_gif_req_t;\n" .
"  signal logic2reg          : $entity" . "_logic2reg_t;\n" .
"\n";  

if(defined($hostif)) {
  print $fh
"  signal muxi0_m0_gif_rsp   : $entity" . "_gif_rsp_t;\n" .
"  signal muxi0_gif_req      : $entity" . "_gif_req_t;\n" .
"\n";
}

if(defined($chaining)) {
  print $fh
"  type chain_array_t is array(natural range 0 to $entity" . "_channels_c-1) of std_ulogic_vector($entity" . "_channels_c-1 downto 0);\n" .
"  signal chain_mask      : chain_array_t;\n" .
"  signal chain_trigger   : std_ulogic_vector($entity" . "_channels_c-1 downto 0);\n" .
"  signal chain_start     : std_ulogic_vector($entity" . "_channels_c-1 downto 0);\n" .
"  signal chain_busy      : std_ulogic_vector($entity" . "_channels_c-1 downto 0);\n" .
"  signal chaini0_start   : std_ulogic_vector($entity" . "_channels_c-1 downto 0);\n" .
"  signal chaini0_trigger : std_ulogic_vector($entity" . "_channels_c-1 downto 0);\n" .
"\n";
}

print $fh
"  signal dma_en             : std_ulogic;\n" .
"  signal dma_init           : std_ulogic;\n" .
"  signal dma_cfg            : $entity" . "_cfg_arr_t;\n" .
"  signal dma_ctrl           : $entity" . "_ctrl_arr_t;\n" .
"\n" .  
"  signal dmai0_status       : $entity" . "_status_arr_t;\n" .
"\n" .
"begin\n" .
"  ------------------------------------------------------------------------------\n" .
"  -- hibi dma register file\n" .
"  ------------------------------------------------------------------------------\n" .
"  regifi0: entity $lib" . "." . "$entity" . "_regfile\n" .
"    port map (\n" .
"      clk_i       => clk_i,\n" .
"      reset_n_i   => reset_n_i,\n";

if(defined($hostif)) {
  print $fh
"      gif_req_i   => muxi0_gif_req,\n";
}
else {
  print $fh
"      gif_req_i   => ctrli0_gif_req,\n";
}

print $fh
"      gif_rsp_o   => regifi0_gif_rsp,\n" .
"      logic2reg_i => logic2reg,\n" .
"      reg2logic_o => regifi0_reg2logic\n" .
"    );\n" .
"\n";


print $fh
"  ------------------------------------------------------------------------------\n" .
"  -- hibi dma chaining\n" .
"  ------------------------------------------------------------------------------\n";
for(my $i = 0; $i < $channels; $i++) {
  print $fh 
"  chain_mask($i)    <= regifi0_reg2logic.HIBI_DMA_TRIGGER_MASK$i.rw.mask;\n" .
"  chain_start($i)   <= regifi0_reg2logic.HIBI_DMA_TRIGGER.c.wr and regifi0_reg2logic.HIBI_DMA_TRIGGER.xw.start$i;\n" .
"  chain_busy($i)    <= dmai0_status($i).busy;\n" .
"\n";
}

print $fh
"  chaini0: for i in 0 to $entity" . "_channels_c-1 generate\n" .
"    chain_trigger(i) <= chaini0_trigger(i);\n" .
"\n" .
"    trigi0: entity microsimd.$entity" ."_trigger\n" .
"      generic map (\n" .
"        $entity" . "_channels_g => $entity" . "_channels_c\n" .
"      )\n" .
"      port map (\n" .
"        clk_i     => clk_i,\n" .
"        reset_n_i => reset_n_i,\n" .
"        en_i      => dma_en,\n" .
"        init_i    => dma_init,\n" . 
"        start_i   => chain_start(i),\n" .
"        busy_i    => chain_busy(i),\n" .
"        trigger_i => chain_trigger,\n" .
"        mask_i    => chain_mask(i),\n" .
"        trigger_o => chaini0_trigger(i),\n" .
"        start_o   => chaini0_start(i)\n" .
"      );\n" .
"  end generate chaini0;\n" .
"\n";

print $fh
"  ------------------------------------------------------------------------------\n" .
"  -- hibi dma core\n" .
"  ------------------------------------------------------------------------------\n" .
"  status_o <= dmai0_status;\n" .
"\n" .
"  dmai0: entity $lib" . "." . "$entity" . "_core\n" .
"    generic map (\n" .
"      log2_burst_length_g => log2_burst_length_g\n" .
"    )\n" .
"    port map (\n" .
"      clk_i         => clk_i,\n" .
"      reset_n_i     => reset_n_i,\n" .
"      en_i          => dma_en,\n" .
"      init_i        => dma_init,\n" .
"      cfg_i         => dma_cfg,\n" .
"      ctrl_i        => dma_ctrl,\n" .
"      mem_req_o     => mem_req_o,\n" .
"      mem_rsp_i     => mem_rsp_i,\n" .
"      mem_wait_i    => mem_wait_i,\n" .
"      agent_txreq_o => agent_txreq_o,\n" .
"      agent_txrsp_i => agent_txrsp_i,\n" .
"      agent_rxreq_o => agent_rxreq_o,\n" .
"      agent_rxrsp_i => agent_rxrsp_i,\n" .
"      status_o      => dmai0_status\n" .
"    );\n" .
"\n" .    
"  ----------------------------------------------------------------------------\n" .
"  -- hibi_mem_ctrl\n" .
"  ----------------------------------------------------------------------------\n" .
"  ctrli0: entity $lib" . "." . "$entity" . "_ctrl\n" .
"    port map (\n" .
"      clk_i              => clk_i,\n" .
"      reset_n_i          => reset_n_i,\n" .
"      init_i             => init_i,\n" .
"      en_i               => en_i,\n" .
"      gif_req_o          => ctrli0_gif_req,\n";

if(defined($hostif)) {
  print $fh
"      gif_rsp_i          => muxi0_m0_gif_rsp,\n";
}
else {
  print $fh
"      gif_rsp_i          => regifi0_gif_rsp,\n";
}

print $fh
"      agent_msg_txreq_o  => agent_msg_txreq_o,\n" .
"      agent_msg_txrsp_i  => agent_msg_txrsp_i,\n" .
"      agent_msg_rxreq_o  => agent_msg_rxreq_o,\n" .
"      agent_msg_rxrsp_i  => agent_msg_rxrsp_i\n" .
"  );\n" .
"\n";

if(defined($hostif)) {
  print $fh
"  -----------------------------------------------------------------------------\n" .
"  -- gif mux interface\n" .
"  -----------------------------------------------------------------------------\n" .
"  muxi0: entity $lib" . "." . "$entity" . "_gif_mux\n" .
"    port map (\n" .
"      clk_i         => clk_i,\n" .
"      reset_n_i     => reset_n_i,\n" .
"      en_i          => en_i,\n" .
"      init_i        => init_i,\n" .
"      m0_gif_req_i  => ctrli0_gif_req,\n" .
"      m0_gif_rsp_o  => muxi0_m0_gif_rsp,\n" .
"      m1_gif_req_i  => ext_gif_req_i,\n" .
"      m1_gif_rsp_o  => ext_gif_rsp_o,\n" .
"      mux_gif_req_o => muxi0_gif_req,\n" .
"      mux_gif_rsp_i => regifi0_gif_rsp\n" .
"    );\n" .
"\n";
}

print $fh
"  ------------------------------------------------------------------------------\n" .
"  -- regfile mapping\n" .
"  ------------------------------------------------------------------------------\n";
for(my $i = 0; $i < $channels; $i++) {
  print $fh "  logic2reg.HIBI_DMA_STATUS.ro.busy$i <= dmai0_status($i).busy;\n";
  
  if(defined($chaining)) {
    print $fh "  dma_ctrl($i).start                  <= chaini0_start($i);\n";
  }  
  else {
    print $fh "  dma_ctrl($i).start                  <= regifi0_reg2logic.HIBI_DMA_TRIGGER.c.wr and regifi0_reg2logic.HIBI_DMA_TRIGGER.xw.start$i;\n";
  }
  
  print $fh "  dma_cfg($i).hibi_addr               <= regifi0_reg2logic.HIBI_DMA_HIBI_ADDR$i.rw.addr;\n";
  print $fh "  dma_cfg($i).mem_addr                <= regifi0_reg2logic.HIBI_DMA_MEM_ADDR$i.rw.addr;\n";
  print $fh "  dma_cfg($i).count                   <= regifi0_reg2logic.HIBI_DMA_CFG$i.rw.count;\n";
  print $fh "  dma_cfg($i).direction               <= regifi0_reg2logic.HIBI_DMA_CFG$i.rw.direction;\n";
  print $fh "  dma_cfg($i).const_addr              <= regifi0_reg2logic.HIBI_DMA_CFG$i.rw.const_addr;\n";  
  print $fh "  dma_cfg($i).cmd                     <= regifi0_reg2logic.HIBI_DMA_CFG$i.rw.hibi_cmd;\n\n";  
}


if(defined($gpio)) {
  print $fh
"  gpio_o                  <= regifi0_reg2logic.HIBI_DMA_GPIO;\n" .
"  gpio_dir_o              <= regifi0_reg2logic.HIBI_DMA_GPIO_DIR;\n" .
"  logic2reg.HIBI_DMA_GPIO <= gpio_i;\n\n";
}


print $fh
"  ------------------------------------------------------------------------------\n" .
"  -- dma enable and init logic\n" .
"  ------------------------------------------------------------------------------\n" .
"  dma_en0: process(clk_i, reset_n_i) is\n" .
"  begin\n" .
"    if(reset_n_i = '0') then\n" .
"      dma_en <= '0';\n" .
"    elsif(rising_edge(clk_i)) then\n" .
"      dma_en <= regifi0_reg2logic.HIBI_DMA_CTRL.rw.en;\n" .
"    end if;\n" .
"  end process dma_en0;\n" .
"\n" .  
"  dma_init <= '1' when dma_en = '1' and regifi0_reg2logic.HIBI_DMA_CTRL.rw.en = '0' else '0';\n" .
"\n" .  
"end architecture rtl;\n" .
"\n";

close($fh);






if(defined($hostif)) {


  my $file_name = $entity . "_gif_mux.vhd";
  my $fh = new FileHandle;
  open($fh, ">$file_name") or die "could not create $file_name\n";


  print $fh
    "-------------------------------------------------------------------------------\n" .
    "-- Title      : $entity" . "_gif_mux\n" .
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
    "use ieee.numeric_std.all;\n\n" .

    "library $lib;\n" .
    "use $lib." . "$entity" . "_regif_types_pkg.all;\n\n";

  print $fh
    "entity " . "$entity" . "_gif_mux is\n" .
    "  port (\n" .
    "    clk_i         : in  std_ulogic;\n" .
    "    reset_n_i     : in  std_ulogic;\n" .
    "    en_i          : in  std_ulogic;\n" .
    "    init_i        : in  std_ulogic;\n" .
    "    m0_gif_req_i  : in  " . "$entity" . "_gif_req_t;\n" .
    "    m0_gif_rsp_o  : out " . "$entity" . "_gif_rsp_t;\n" .
    "    m1_gif_req_i  : in  " . "$entity" . "_gif_req_t;\n" .
    "    m1_gif_rsp_o  : out " . "$entity" . "_gif_rsp_t;\n" .
    "    mux_gif_req_o : out " . "$entity" . "_gif_req_t;\n" .
    "    mux_gif_rsp_i : in  " . "$entity" . "_gif_rsp_t\n" .
    "  );\n" .
    "end entity " . "$entity" . "_gif_mux;\n\n";

  print $fh
    "architecture rtl of " . "$entity" . "_gif_mux is\n" .
    "\n" .
    "  type reg_t is record\n" .
    "    state   : std_ulogic;\n" .
    "    mux_sel : std_ulogic;\n" .
    "    m1_req  : " . "$entity" . "_gif_req_t;\n" .
    "  end record reg_t;\n" .
    "  constant dflt_reg_c : reg_t :=(\n" .
    "    state   => '0',\n" .
    "    mux_sel => '0',\n" .
    "    m1_req  => dflt_" . "$entity" . "_gif_req_c\n" .
    "  );\n" .
    "\n" .
    "  signal r, rin : reg_t;\n" .
    "\n" .
    "begin\n";

  print $fh  
    "  ------------------------------------------------------------------------------\n" .
    "  -- comb0\n" .
    "  ------------------------------------------------------------------------------\n" .
    "  comb0: process(r, m0_gif_req_i, m1_gif_req_i) is\n" .
    "    variable v         : reg_t;\n" .
    "    variable m0_req_en : std_ulogic;\n" .
    "    variable m1_req_en : std_ulogic;\n" .
    "  begin\n" .
    "    v := r;\n" .
    "\n" .
    "    m0_req_en := m0_gif_req_i.rd or m0_gif_req_i.wr;\n" .
    "    m1_req_en := m1_gif_req_i.rd or m1_gif_req_i.wr;\n" .
    "\n" .
    "    -- NOTE: conditionally register m1 request, we do not reset the register\n" .
    "    --       because the output mux defaults to m0\n" .
    "    if m1_req_en = '1' then\n" .
    "      v.m1_req := m1_gif_req_i;\n" .
    "    end if;\n" .
    "\n" .
    "    ----------------------------------------------------------------------------\n" .
    "    -- this is a simplified mux that strictely assumes the slave to respond\n" .
    "    -- in the following clock cycle\n" .
    "    -- master zero is served first in case of competing requests\n" .
    "    -- master one request gets registered \n" .
    "    ----------------------------------------------------------------------------\n" .
    "    case v.state is\n" .
    "      when '0'    => v.mux_sel   := '0';\n" .
    "                     v.state     := '0';\n" .
    "\n" .
    "                     if(m0_req_en = '0' and m1_req_en = '1') then\n" .
    "                       v.mux_sel := '1';\n" .
    "                     end if;\n" .
    "\n" .
    "                     if(m0_req_en = '1' and m1_req_en = '1') then\n" .
    "                       v.state   := '1';\n" .
    "                     end if;\n" .
    "\n" .
    "      when '1'    => v.mux_sel   := '1';\n" .
    "                     v.state     := '0';\n" .
    "\n" .
    "      when others => null;\n" .
    "    end case;\n" .
    "\n" .
    "    rin <= v;\n".
    "  end process comb0;\n" .
    "\n" .
    "  mux_gif_req_o      <= m0_gif_req_i when rin.mux_sel = '0' else rin.m1_req;\n" .
    "\n" .
    "  m0_gif_rsp_o.rdata <= mux_gif_rsp_i.rdata;\n" .
    "  m1_gif_rsp_o.rdata <= mux_gif_rsp_i.rdata;\n" .
    "\n" .
    "  m0_gif_rsp_o.ack   <= mux_gif_rsp_i.ack when r.mux_sel = '0' else '0';\n" .
    "  m1_gif_rsp_o.ack   <= mux_gif_rsp_i.ack when r.mux_sel = '1' else '0';\n" .
    "\n";

  print $fh 
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



  close $fh
}




# help
sub help
{
  my $max_length = 0;

  print "usage: $0 [OPTION]\n\n";

  # find maximum string length
  foreach my $cmd (keys(%option)) {
    my @alias  = split(/[\|,=]/, $option{$cmd}{'string'});
    my $string = "--" . $alias[0] . ", -" . $alias[1] . ",";
    $max_length = length($string) if length($string) > $max_length;
  }

  # print out aligned
  foreach my $cmd (sort(keys(%option))) {
    my @alias  = split(/[\|,=,+]/, $option{$cmd}{'string'});
    my $string = "--" . $alias[0] . ", -" . $alias[1] . ",";
    my $length = length($string);
    my $space  = ' 'x($max_length - $length);

    print "$string $space $option{$cmd}{'help'}\n";
  }

  exit 1;
}

