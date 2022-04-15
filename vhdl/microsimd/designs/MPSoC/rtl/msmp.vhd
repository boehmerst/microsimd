library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library general;
use general.general_function_pkg.all;

library microsimd;
use microsimd.hibi_link_pkg.all;
use microsimd.hibi_pif_types_pkg.all;

library hibi;
use hibi.hibiv3_pkg.all;

entity msmp is
  generic (
    nr_cpus_g : integer range 2 to 8 := 2
  );
  port (
    clk_i      : in  std_ulogic;
    reset_n_i  : in  std_ulogic;
    pif_i      : in  hibi_pif_arr_t(0 to 1);
    pif_o      : out hibi_pif_arr_t(0 to 1)
  );
end entity msmp;

architecture rtl of msmp is

  constant id_width_c      : integer :=  6;
  constant max_send_c      : integer := 40;
  constant counter_width_c : integer := log2ceil(max_send_c);
  constant arb_type_c      : integer :=  0;
  constant tx_fifo_size_c  : integer :=  8;
  constant rx_fifo_size_c  : integer :=  8;
  constant nr_agents_c     : integer := nr_cpus_g + 2;

  signal agent_txreq       : agent_txreq_array_t(0 to nr_agents_c-1);
  signal agent_txrsp       : agent_txrsp_array_t(0 to nr_agents_c-1); 
  signal agent_rxreq       : agent_rxreq_array_t(0 to nr_agents_c-1);
  signal agent_rxrsp       : agent_rxrsp_array_t(0 to nr_agents_c-1);
  
  signal agent_msg_txreq   : agent_txreq_array_t(0 to nr_agents_c-1);
  signal agent_msg_txrsp   : agent_txrsp_array_t(0 to nr_agents_c-1); 
  signal agent_msg_rxreq   : agent_rxreq_array_t(0 to nr_agents_c-1);
  signal agent_msg_rxrsp   : agent_rxrsp_array_t(0 to nr_agents_c-1);
  
  signal rxpif_reset_n     : std_ulogic_vector(1 downto 0);

begin
  ------------------------------------------------------------------------------
  -- generate cpu's
  ------------------------------------------------------------------------------
  cpu_gen0: for i in 0 to nr_cpus_g-1 generate
    cpui: entity microsimd.cpu
      port map (
        clk_i             => clk_i,
        reset_n_i         => reset_n_i,
        en_i              => '1',
        init_i            => '0',
        irq_i             => '0',
        agent_txreq_o     => agent_txreq(i),
        agent_txrsp_i     => agent_txrsp(i),
        agent_rxreq_o     => agent_rxreq(i),
        agent_rxrsp_i     => agent_rxrsp(i),
        agent_msg_txreq_o => agent_msg_txreq(i),
        agent_msg_txrsp_i => agent_msg_txrsp(i),
        agent_msg_rxreq_o => agent_msg_rxreq(i),
        agent_msg_rxrsp_i => agent_msg_rxrsp(i)
      );
  end generate cpu_gen0;
  
  ------------------------------------------------------------------------------
  --  pif_hibi interface
  ------------------------------------------------------------------------------
  rxpif_reset_n <= (others=>reset_n_i);  --FIXME: need real reset generator
  
  pifi0: entity microsimd.hibi_pif
    generic map (
      log2_burst_length_g =>  3,
      nr_rxstreams_g      =>  2,
      nr_txstreams_g      =>  2      
    )
    port map (
      clk_i               => clk_i,
      reset_n_i           => reset_n_i,
      rxpif_reset_n_i     => rxpif_reset_n,
      pif_i               => pif_i,
      pif_o               => pif_o,
      agent_txreq_o       => agent_txreq(nr_cpus_g),
      agent_txrsp_i       => agent_txrsp(nr_cpus_g),
      agent_rxreq_o       => agent_rxreq(nr_cpus_g),
      agent_rxrsp_i       => agent_rxrsp(nr_cpus_g),
      agent_msg_txreq_o   => agent_msg_txreq(nr_cpus_g),
      agent_msg_txrsp_i   => agent_msg_txrsp(nr_cpus_g),
      agent_msg_rxreq_o   => agent_msg_rxreq(nr_cpus_g),
      agent_msg_rxrsp_i   => agent_msg_rxrsp(nr_cpus_g)
    );
    
  ------------------------------------------------------------------------------
  -- hibi_mem
  ------------------------------------------------------------------------------
  memi0: entity microsimd.hibi_mem_wrapper
    generic map (
      log2_burst_length_g => 3
    )
    port map (
      clk_i               => clk_i,
      reset_n_i           => reset_n_i,
      init_i              => '0',
      en_i                => '1',
      agent_txreq_o       => agent_txreq(nr_cpus_g+1),
      agent_txrsp_i       => agent_txrsp(nr_cpus_g+1),
      agent_rxreq_o       => agent_rxreq(nr_cpus_g+1),
      agent_rxrsp_i       => agent_rxrsp(nr_cpus_g+1),
      agent_msg_txreq_o   => agent_msg_txreq(nr_cpus_g+1),
      agent_msg_txrsp_i   => agent_msg_txrsp(nr_cpus_g+1),
      agent_msg_rxreq_o   => agent_msg_rxreq(nr_cpus_g+1),
      agent_msg_rxrsp_i   => agent_msg_rxrsp(nr_cpus_g+1)
    );

  ------------------------------------------------------------------------------
  -- hibi_v3 segment including r4 wrapper
  ------------------------------------------------------------------------------
  hibi_segi0: entity microsimd.hibi_seg_r1
    generic map (
      id_width_g          => id_width_c,
      addr_width_g        => hibi_addr_width_c,
      data_width_g        => hibi_data_width_c,
      comm_width_g        => hibi_comm_width_c,
      counter_width_g     => counter_width_c,
      rel_agent_freq_g    => 1,
      rel_bus_freq_g      => 1,
      arb_type_g          => arb_type_c,
      fifo_sel_g          => 0,
      rx_fifo_depth_g     => rx_fifo_size_c,
      rx_msg_fifo_depth_g => rx_fifo_size_c,
      tx_fifo_depth_g     => tx_fifo_size_c,
      tx_msg_fifo_depth_g => tx_fifo_size_c,
      max_send_g          => max_send_c,
      n_cfg_pages_g       => 1,
      n_time_slots_g      => 0,
      keep_slot_g         => 0,
      n_extra_params_g    => 1,
      cfg_re_g            => 0,
      cfg_we_g            => 1,
      debug_width_g       => 0,
      n_agents_g          => nr_agents_c,
      separate_addr_g     => 0
    )
    port map (
      clk_i               => clk_i,
      reset_n_i           => reset_n_i,
      agent_txreq_i       => agent_txreq,
      agent_txrsp_o       => agent_txrsp,
      agent_rxreq_i       => agent_rxreq,
      agent_rxrsp_o       => agent_rxrsp,
      agent_msg_txreq_i   => agent_msg_txreq,
      agent_msg_txrsp_o   => agent_msg_txrsp,
      agent_msg_rxreq_i   => agent_msg_rxreq,
      agent_msg_rxrsp_o   => agent_msg_rxrsp
    );

end architecture rtl;

