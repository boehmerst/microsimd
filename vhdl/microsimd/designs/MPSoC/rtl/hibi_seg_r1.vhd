library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library microsimd;
use microsimd.hibi_link_pkg.all;
use microsimd.func_pkg.all;

library hibi;
use hibi.hibiv3_pkg.all;

entity hibi_seg_r1 is
  generic (
    id_width_g          : integer :=  4;
    addr_width_g        : integer := 32;
    data_width_g        : integer := 32;
    comm_width_g        : integer :=  5;
    counter_width_g     : integer := 16;
    rel_agent_freq_g    : integer :=  1;
    rel_bus_freq_g      : integer :=  1;
    arb_type_g          : integer :=  3;
    fifo_sel_g          : integer :=  0;
    rx_fifo_depth_g     : integer :=  4;
    rx_msg_fifo_depth_g : integer :=  4;
    tx_fifo_depth_g     : integer :=  4;
    tx_msg_fifo_depth_g : integer :=  4;
    max_send_g          : integer := 40;
    n_cfg_pages_g       : integer :=  1;
    n_time_slots_g      : integer :=  0;
    keep_slot_g         : integer :=  0;
    n_extra_params_g    : integer :=  1;
    cfg_re_g            : integer :=  1;
    cfg_we_g            : integer :=  1;
    debug_width_g       : integer :=  0;
    n_agents_g          : integer :=  4;
    separate_addr_g     : integer :=  0
  );
  port (
    clk_i               : in  std_logic;
    reset_n_i           : in  std_logic;
    agent_txreq_i       : in  agent_txreq_array_t(0 to n_agents_g-1);
    agent_txrsp_o       : out agent_txrsp_array_t(0 to n_agents_g-1);
    agent_rxreq_i       : in  agent_rxreq_array_t(0 to n_agents_g-1);
    agent_rxrsp_o       : out agent_rxrsp_array_t(0 to n_agents_g-1);
    agent_msg_txreq_i   : in  agent_txreq_array_t(0 to n_agents_g-1);
    agent_msg_txrsp_o   : out agent_txrsp_array_t(0 to n_agents_g-1);
    agent_msg_rxreq_i   : in  agent_rxreq_array_t(0 to n_agents_g-1);
    agent_msg_rxrsp_o   : out agent_rxrsp_array_t(0 to n_agents_g-1)    
  );
end entity hibi_seg_r1;

architecture rtl of hibi_seg_r1 is
  -----------------------------------------------------------------------------
  -- hibi addresses need to be adapted -> move to configuration package
  -----------------------------------------------------------------------------
  type hibi_addr_array_t is array (0 to 3) of integer;
  constant hibi_addresses_c : hibi_addr_array_t :=(
    16#1000#, 16#3000#, 16#5000#, 16#7000#
  );

  type comm_array_t is array(natural range 0 to n_agents_g-1) of std_logic_vector(comm_width_g-1 downto 0);
  type data_array_t is array(natural range 0 to n_agents_g-1) of std_logic_vector(data_width_g-1 downto 0);
  type addr_array_t is array(natural range 0 to n_agents_g-1) of std_logic_vector(addr_width_g-1 downto 0);

  -----------------------------------------------------------------------------
  -- wrapper to agent output signals
  -----------------------------------------------------------------------------
  signal wrapi0_agent_comm             : comm_array_t;
  signal wrapi0_agent_data             : data_array_t;
  signal wrapi0_agent_addr             : addr_array_t;
  signal wrapi0_agent_full             : std_logic_vector(n_agents_g-1 downto 0);
  signal wrapi0_agent_almost_full      : std_logic_vector(n_agents_g-1 downto 0);
  signal wrapi0_agent_empty            : std_logic_vector(n_agents_g-1 downto 0);
  signal wrapi0_agent_almost_empty     : std_logic_vector(n_agents_g-1 downto 0);
  signal wrapi0_agent_av               : std_logic_vector(n_agents_g-1 downto 0);
  signal wrapi0_agent_msg_comm         : comm_array_t;
  signal wrapi0_agent_msg_data         : data_array_t;
  signal wrapi0_agent_msg_addr         : addr_array_t;
  signal wrapi0_agent_msg_full         : std_logic_vector(n_agents_g-1 downto 0);
  signal wrapi0_agent_msg_almost_full  : std_logic_vector(n_agents_g-1 downto 0);
  signal wrapi0_agent_msg_empty        : std_logic_vector(n_agents_g-1 downto 0);
  signal wrapi0_agent_msg_almost_empty : std_logic_vector(n_agents_g-1 downto 0);
  signal wrapi0_agent_msg_av           : std_logic_vector(n_agents_g-1 downto 0);

  -----------------------------------------------------------------------------
  -- wrapper to bus output signals
  -----------------------------------------------------------------------------
  signal wrapi0_bus_comm          : comm_array_t;
  signal wrapi0_bus_data          : data_array_t;
  signal wrapi0_bus_av            : std_logic_vector(n_agents_g-1 downto 0);
  signal wrapi0_bus_full          : std_logic_vector(n_agents_g-1 downto 0);
  signal wrapi0_bus_lock          : std_logic_vector(n_agents_g-1 downto 0);

  -----------------------------------------------------------------------------
  -- bus to wrapper signals (OR-bus)
  -----------------------------------------------------------------------------
  signal busi0_comm               : std_logic_vector(comm_width_g-1 downto 0);
  signal busi0_data               : std_logic_vector(data_width_g-1 downto 0);
  signal busi0_av                 : std_logic;
  signal busi0_full               : std_logic;
  signal busi0_lock               : std_logic;

begin
  -----------------------------------------------------------------------------
  -- generate wrapper
  -----------------------------------------------------------------------------
  wrap_gen0 : for i in 0 to n_agents_g-1 generate
   wrapi0: entity hibi.hibi_wrapper_r1
     generic map (
       id_g                => i+1,
       addr_g              => hibi_addresses_c(i),
       inv_addr_en_g       => 0,
       id_width_g          => id_width_g,
       addr_width_g        => addr_width_g,
       data_width_g        => data_width_g,
       separate_addr_g     => separate_addr_g,
       comm_width_g        => comm_width_g,
       counter_width_g     => counter_width_g,
       rel_agent_freq_g    => rel_agent_freq_g,
       rel_bus_freq_g      => rel_bus_freq_g,
       arb_type_g          => arb_type_g,
       fifo_sel_g          => fifo_sel_g,
       rx_fifo_depth_g     => rx_fifo_depth_g,
       rx_msg_fifo_depth_g => rx_msg_fifo_depth_g,
       tx_fifo_depth_g     => tx_fifo_depth_g,
       tx_msg_fifo_depth_g => tx_msg_fifo_depth_g,
       prior_g             => i+1,
       max_send_g          => max_send_g,
       n_agents_g          => n_agents_g,
       n_cfg_pages_g       => n_cfg_pages_g,
       n_time_slots_g      => n_time_slots_g,
       keep_slot_g         => keep_slot_g,
       n_extra_params_g    => n_extra_params_g,
       cfg_re_g            => cfg_re_g,
       cfg_we_g            => cfg_we_g,
       debug_width_g       => debug_width_g
     )
     port map (
       bus_clk             => clk_i,
       agent_clk           => clk_i,
       bus_sync_clk        => clk_i,
       agent_sync_clk      => clk_i,
       rst_n               => reset_n_i,
       bus_comm_in         => busi0_comm,
       bus_data_in         => busi0_data,
       bus_full_in         => busi0_full,
       bus_lock_in         => busi0_lock,
       bus_av_in           => busi0_av,
       
       agent_comm_in       => std_logic_vector(agent_txreq_i(i).comm),
       agent_data_in       => std_logic_vector(agent_txreq_i(i).data),
       agent_av_in         => std_logic(agent_txreq_i(i).av),
       agent_we_in         => std_logic(agent_txreq_i(i).we),
       agent_re_in         => std_logic(agent_rxreq_i(i).re),
       
       agent_msg_comm_in   => std_logic_vector(agent_msg_txreq_i(i).comm),
       agent_msg_data_in   => std_logic_vector(agent_msg_txreq_i(i).data),
       agent_msg_av_in     => std_logic(agent_msg_txreq_i(i).av),
       agent_msg_we_in     => std_logic(agent_msg_txreq_i(i).we),
       agent_msg_re_in     => std_logic(agent_msg_rxreq_i(i).re),       
       
       bus_comm_out        => wrapi0_bus_comm(i),
       bus_data_out        => wrapi0_bus_data(i),
       bus_full_out        => wrapi0_bus_full(i),
       bus_lock_out        => wrapi0_bus_lock(i),
       bus_av_out          => wrapi0_bus_av(i),
       
       agent_comm_out      => wrapi0_agent_comm(i),
       agent_data_out      => wrapi0_agent_data(i),
       agent_av_out        => wrapi0_agent_av(i),
       agent_full_out      => wrapi0_agent_full(i),
       agent_one_p_out     => wrapi0_agent_almost_full(i),
       agent_empty_out     => wrapi0_agent_empty(i),
       agent_one_d_out     => wrapi0_agent_almost_empty(i),
       
       agent_msg_comm_out  => wrapi0_agent_msg_comm(i),
       agent_msg_data_out  => wrapi0_agent_msg_data(i),
       agent_msg_av_out    => wrapi0_agent_msg_av(i),
       agent_msg_full_out  => wrapi0_agent_msg_full(i),
       agent_msg_one_p_out => wrapi0_agent_msg_almost_full(i),
       agent_msg_empty_out => wrapi0_agent_msg_empty(i),
       agent_msg_one_d_out => wrapi0_agent_msg_almost_empty(i)       
       -- synthesis translate_off
       ,
       debug_out           => open,
       debug_in            => (others => '0')
       -- synthesis translate_on
    );

    agent_txrsp_o(i)     <= bind_link( wrapi0_agent_full(i), wrapi0_agent_almost_full(i) );
    agent_rxrsp_o(i)     <= bind_link( wrapi0_agent_av(i), wrapi0_agent_data(i),
                                       wrapi0_agent_comm(i), wrapi0_agent_empty(i),
                                       wrapi0_agent_almost_empty(i) );
                                   
    agent_msg_txrsp_o(i) <= bind_link( wrapi0_agent_msg_full(i), wrapi0_agent_msg_almost_full(i) );
    agent_msg_rxrsp_o(i) <= bind_link( wrapi0_agent_msg_av(i), wrapi0_agent_msg_data(i),
                                       wrapi0_agent_msg_comm(i), wrapi0_agent_msg_empty(i),
                                       wrapi0_agent_msg_almost_empty(i) );                                   
              
  end generate wrap_gen0;

  -----------------------------------------------------------------------------
  -- the actual hibi-bus
  -----------------------------------------------------------------------------
  busi0: block is
    type trnsp_data_array_t is array(0 to data_width_g-1) of std_logic_vector(n_agents_g-1 downto 0);
    type trnsp_comm_array_t is array(0 to comm_width_g-1) of std_logic_vector(n_agents_g-1 downto 0);

    signal trnsp_bus_data : trnsp_data_array_t;
    signal trnsp_bus_comm : trnsp_comm_array_t;
  begin
    ---------------------------------------------------------------------------
    -- we need to transpose the bus signals from the wrappers
    ---------------------------------------------------------------------------
    trnsp_bus0: for j in 0 to n_agents_g-1 generate
      -------------------------------------------------------------------------
      -- transpose data bus
      -------------------------------------------------------------------------
      i: for i in 0 to data_width_g-1 generate
        trnsp_bus_data(i)(j) <= wrapi0_bus_data(j)(i);
      end generate i;

      -------------------------------------------------------------------------
      -- transpose comm bus
      -------------------------------------------------------------------------
      k: for k in 0 to comm_width_g-1 generate
        trnsp_bus_comm(k)(j) <= wrapi0_bus_comm(j)(k);
      end generate k;      
    end generate trnsp_bus0;

    ---------------------------------------------------------------------------
    -- or reduce the transposed data and comm bus
    ---------------------------------------------------------------------------
    or_red_data : for i in 0 to data_width_g-1 generate
      busi0_data(i) <= v_or(std_ulogic_vector(trnsp_bus_data(i)));
    end generate or_red_data;

    or_red_comm : for i in 0 to comm_width_g-1 generate
      busi0_comm(i) <= v_or(std_ulogic_vector(trnsp_bus_comm(i)));
    end generate or_red_comm;

    ---------------------------------------------------------------------------
    -- or reduce lock, av and full
    ---------------------------------------------------------------------------
    busi0_av   <= v_or(std_ulogic_vector(wrapi0_bus_av));
    busi0_lock <= v_or(std_ulogic_vector(wrapi0_bus_lock));
    busi0_full <= v_or(std_ulogic_vector(wrapi0_bus_full));

  end block busi0;

end architecture rtl;

