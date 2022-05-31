library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tech;

-- TODO: move to HIBI lib
library microsimd;
use microsimd.hibi_link_pkg.all;

library work;
use work.wishbone_pkg.all;
use work.hibi_wishbone_bridge_pkg.all;
use work.hibi_wishbone_bridge_regfile_pkg.all;
use work.hibi_wishbone_bridge_regif_types_pkg.all;

entity hibi_wishbone_bridge_wrapper is
  generic (
    log2_burst_length_g : integer range 2 to 5 := 4
  );
  port (
    clk_i              : in  std_ulogic;
    reset_n_i          : in  std_ulogic;
    en_i               : in  std_ulogic;
    init_i             : in  std_ulogic;
    wb_req_i           : in  wb_req_t;
    wb_rsp_o           : out wb_rsp_t;
    agent_core_en_o    : out std_ulogic_vector(3 downto 0);
    agent_core_init_o  : out std_ulogic_vector(3 downto 0);
    agent_logic_en_o   : out std_ulogic_vector(3 downto 0);
    agent_logic_init_o : out std_ulogic_vector(3 downto 0);
    agent_txreq_o      : out agent_txreq_t;
    agent_txrsp_i      : in  agent_txrsp_t;
    agent_rxreq_o      : out agent_rxreq_t;
    agent_rxrsp_i      : in  agent_rxrsp_t;
    agent_msg_txreq_o  : out agent_txreq_t;
    agent_msg_txrsp_i  : in  agent_txrsp_t;
    agent_msg_rxreq_o  : out agent_rxreq_t;
    agent_msg_rxrsp_i  : in  agent_rxrsp_t
  );
end entity hibi_wishbone_bridge_wrapper;

architecture rtl of hibi_wishbone_bridge_wrapper is

  signal bridgei0_status   : hibi_wishbone_bridge_status_arr_t;
  signal bridgei0_gif_rsp  : hibi_wishbone_bridge_gif_rsp_t;

  signal bridgei0_gpio     : hibi_wishbone_bridge_HIBI_DMA_GPIO_reg2logic_t;
  signal bridgei0_gpio_dir : hibi_wishbone_bridge_HIBI_DMA_GPIO_DIR_reg2logic_t;
  signal gpioi0_gpio       : hibi_wishbone_bridge_HIBI_DMA_GPIO_logic2reg_t;

  signal memi0_gif_rsp     : hibi_wishbone_bridge_gif_rsp_t;

  type   gif_bus_t         is (bridge, mem);

  signal host_gif_req      : hibi_wishbone_bridge_gif_req_arr_t(0 to 1);
  signal host_gif_rsp      : hibi_wishbone_bridge_gif_rsp_arr_t(0 to 1);

  signal bridgei0_mem_req  : hibi_wishbone_bridge_mem_req_t;
  signal host_mem_req      : hibi_wishbone_bridge_mem_req_t;

  signal memi0_port_a_rsp  : hibi_wishbone_bridge_mem_rsp_t;
  signal memi0_port_b_rsp  : hibi_wishbone_bridge_mem_rsp_t;

  signal mem_wait          : std_ulogic;

begin
  ------------------------------------------------------------------------------
  -- Note:
  -- currently we have internal memory from which the hibi agents can 
  -- transmit data to / from other agents
  -- we also have a config space (regifile) that can be accessed by agents 
  -- using hibi messages. however, the interfaces are not unified and we need
  -- arbitration to access the memory and the config space concurrently from 
  -- a host. in case of the memory we even use a dual port one for now
  --
  -- TODO: unify interfaces (mem vs. gif vs. host protocol) and use one arbiter
  -- / bus to access the memory, config and potentially peripherels.
  ------------------------------------------------------------------------------


  ------------------------------------------------------------------------------
  -- hibi bridge DMA unit
  ------------------------------------------------------------------------------
  bridgei0: entity work.hibi_wishbone_bridge
    generic map (
      log2_burst_length_g => log2_burst_length_g
    )
    port map (
      clk_i             => clk_i,
      reset_n_i         => reset_n_i,
      en_i              => en_i,
      init_i            => init_i,
      ext_gif_req_i     => host_gif_req(gif_bus_t'pos(bridge)),
      ext_gif_rsp_o     => bridgei0_gif_rsp,
      gpio_o            => bridgei0_gpio,
      gpio_i            => gpioi0_gpio,
      gpio_dir_o        => bridgei0_gpio_dir,
      mem_req_o         => bridgei0_mem_req,
      mem_rsp_i         => memi0_port_b_rsp,
      mem_wait_i        => mem_wait,
      agent_txreq_o     => agent_txreq_o,
      agent_txrsp_i     => agent_txrsp_i,
      agent_rxreq_o     => agent_rxreq_o,
      agent_rxrsp_i     => agent_rxrsp_i,
      agent_msg_txreq_o => agent_msg_txreq_o,
      agent_msg_txrsp_i => agent_msg_txrsp_i,
      agent_msg_rxreq_o => agent_msg_rxreq_o,
      agent_msg_rxrsp_i => agent_msg_rxrsp_i,
      status_o          => bridgei0_status
    );
    
  -----------------------------------------------------------------------------
  -- wishbone host interface
  -----------------------------------------------------------------------------
  host_gif_rsp(gif_bus_t'pos(bridge)) <= bridgei0_gif_rsp;
  host_gif_rsp(gif_bus_t'pos(mem))    <= memi0_gif_rsp;

  hostifi0: entity work.wb2gif
    generic map (
      reset_level_g => '0'
    )
    port map (
      wb_clk_i     => clk_i,
      wb_reset_i   => reset_n_i,
      en_i         => en_i,
      init_i       => init_i,
      wb_req_i     => wb_req_i,
      wb_rsp_o     => wb_rsp_o,
      gif_req_o    => host_gif_req,
      gif_rsp_i    => host_gif_rsp
    );

    ---------------------------------------------------------------------------
    -- dual port buffer
    ---------------------------------------------------------------------------
    host_mem_req.we     <= host_gif_req(gif_bus_t'pos(mem)).wr;
    host_mem_req.ena    <= host_gif_req(gif_bus_t'pos(mem)).wr or host_gif_req(gif_bus_t'pos(mem)).rd;
    
    host_mem_req.adr    <= std_ulogic_vector(resize(unsigned(host_gif_req(gif_bus_t'pos(mem)).addr),  host_mem_req.adr'length));
    host_mem_req.dat    <= std_ulogic_vector(resize(unsigned(host_gif_req(gif_bus_t'pos(mem)).wdata), host_mem_req.dat'length));
    memi0_gif_rsp.rdata <= std_ulogic_vector(resize(unsigned(memi0_port_a_rsp.dat), memi0_gif_rsp.rdata'length));

    reg0: entity tech.reg port map (clk_i, reset_n_i, en_i, init_i, host_mem_req.ena, memi0_gif_rsp.ack);

    memi0: entity work.dual_port_buffer
      generic map (
        data_width_g => hibi_wishbone_bridge_mem_data_width_c,
	addr_width_g => hibi_wishbone_bridge_mem_addr_width_c-2
      )
      port map (
        clk_i        => clk_i,
	reset_n_i    => reset_n_i,
	en_i         => en_i,
	init_i       => init_i,
	port_a_req_i => host_mem_req,
	port_a_rsp_o => memi0_port_a_rsp,
	port_b_req_i => bridgei0_mem_req,
	port_b_rsp_o => memi0_port_b_rsp
      );

    mem_wait <= '0';

    ---------------------------------------------------------------------------
    -- GPIO logic implementation (simple feedback of GPIO out to GPIO in)
    ---------------------------------------------------------------------------
    gpioi0: block is
      type reg_t is record
	gpio : hibi_wishbone_bridge_HIBI_DMA_GPIO_xw_t;
      end record reg_t;
      constant dflt_reg_c : reg_t :=(
        gpio => (GPIO_0 => '0', GPIO_1 => '0', GPIO_2 => '0', GPIO_3 => '0',
                 GPIO_4 => '0', GPIO_5 => '0', GPIO_6 => '0', GPIO_7 => '0',
	         GPIO_8 => '0', GPIO_9 => '0', GPIO_A => '0', GPIO_B => '0',
	         GPIO_C => '0', GPIO_D => '0', GPIO_E => '0', GPIO_F => '0')
      );

      signal r, rin : reg_t;

    begin
      comb0: process (r, bridgei0_gpio_dir, bridgei0_gpio) is
	variable v : reg_t;
      begin
	v := r;

        if bridgei0_gpio.c.wr = '1' then
	  v.gpio := bridgei0_gpio.xw;
	end if;

	-- TODO: unfortunately this has to be adapted manually
	--       unless the regfile generator provides conversion functions record to std_ulogic_vector
	gpioi0_gpio.xr     <= (GPIO_0 => r.gpio.GPIO_0, GPIO_1 => r.gpio.GPIO_1, GPIO_2 => r.gpio.GPIO_2, GPIO_3 => r.gpio.GPIO_3,
                               GPIO_4 => r.gpio.GPIO_4, GPIO_5 => r.gpio.GPIO_5, GPIO_6 => r.gpio.GPIO_6, GPIO_7 => r.gpio.GPIO_7,
                               GPIO_8 => r.gpio.GPIO_8, GPIO_9 => r.gpio.GPIO_9, GPIO_A => r.gpio.GPIO_A, GPIO_B => r.gpio.GPIO_B,
                               GPIO_C => r.gpio.GPIO_C, GPIO_D => r.gpio.GPIO_D, GPIO_E => r.gpio.GPIO_E, GPIO_F => r.gpio.GPIO_F);

	agent_core_en_o    <= (0 => r.gpio.GPIO_0, 1 => r.gpio.GPIO_1, 2 => r.gpio.GPIO_2, 3 => r.gpio.GPIO_3);
	agent_logic_en_o   <= (0 => r.gpio.GPIO_4, 1 => r.gpio.GPIO_5, 2 => r.gpio.GPIO_6, 3 => r.gpio.GPIO_7);

	agent_core_init_o  <= (0 => r.gpio.GPIO_8, 1 => r.gpio.GPIO_9, 2 => r.gpio.GPIO_A, 3 => r.gpio.GPIO_B);
	agent_logic_init_o <= (0 => r.gpio.GPIO_C, 1 => r.gpio.GPIO_D, 2 => r.gpio.GPIO_E, 3 => r.gpio.GPIO_F);

	rin <= v;
      end process comb0;

      sync0: process (clk_i, reset_n_i) is
      begin
	if reset_n_i = '0' then
	  r <= dflt_reg_c;
	elsif rising_edge(clk_i) then
	  if en_i = '1' then
	    if init_i = '1' then
	      r <= dflt_reg_c;
	    else
	      r <= rin;
	    end if;
	  end if;
	end if;
      end process sync0;

    end block gpioi0; 

end architecture rtl;

