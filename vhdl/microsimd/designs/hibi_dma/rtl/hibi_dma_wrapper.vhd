library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library microsimd;
use microsimd.core_pkg.all;

library work;
use work.hibi_link_pkg.all;
use work.hibi_dma_pkg.all;
use work.hibi_dma_regif_types_pkg.all;
use work.hibi_dma_regfile_pkg.all;

entity hibi_dma_wrapper is
  generic (
    log2_burst_length_g : integer range 2 to 5  := 4
  );
  port (
    clk_i             : in  std_ulogic;
    reset_n_i         : in  std_ulogic;
    en_i              : in  std_ulogic;
    init_i            : in  std_ulogic;
    gpio_i            : in  std_ulogic_vector(15 downto 0);
    fsl_sel_i         : in  std_ulogic;
    fsl_req_i         : in  fsl_req_t;
    fsl_rsp_o         : out fsl_rsp_t;
    mem_req_o         : out hibi_dma_mem_req_t;
    mem_rsp_i         : in  hibi_dma_mem_rsp_t;
    mem_wait_i        : in  std_ulogic;
    agent_txreq_o     : out agent_txreq_t;
    agent_txrsp_i     : in  agent_txrsp_t;
    agent_rxreq_o     : out agent_rxreq_t;
    agent_rxrsp_i     : in  agent_rxrsp_t;
    agent_msg_txreq_o : out agent_txreq_t;
    agent_msg_txrsp_i : in  agent_txrsp_t;
    agent_msg_rxreq_o : out agent_rxreq_t;
    agent_msg_rxrsp_i : in  agent_rxrsp_t
  );
end entity hibi_dma_wrapper;

architecture rtl of hibi_dma_wrapper is

  signal dmai0_status   : hibi_dma_status_arr_t;
  signal dmai0_gif_rsp  : hibi_dma_gif_rsp_t;
  signal fsli0_gif_req  : hibi_dma_gif_req_t;
  signal dmai0_gpio     : hibi_dma_HIBI_DMA_GPIO_reg2logic_t;
  signal dmai0_gpio_dir : hibi_dma_HIBI_DMA_GPIO_DIR_reg2logic_t;
  signal gpioi0_gpio    : hibi_dma_HIBI_DMA_GPIO_logic2reg_t;

begin
  ------------------------------------------------------------------------------
  -- DMA unit
  ------------------------------------------------------------------------------
  dmai0: entity microsimd.hibi_dma
    generic map (
      log2_burst_length_g => log2_burst_length_g
    )
    port map (
      clk_i             => clk_i,
      reset_n_i         => reset_n_i,
      en_i              => en_i,
      init_i            => init_i,
      ext_gif_req_i     => fsli0_gif_req,
      ext_gif_rsp_o     => dmai0_gif_rsp,
      gpio_o            => dmai0_gpio,
      gpio_i            => gpioi0_gpio,
      gpio_dir_o        => dmai0_gpio_dir,
      mem_req_o         => mem_req_o,
      mem_rsp_i         => mem_rsp_i,
      mem_wait_i        => mem_wait_i,
      agent_txreq_o     => agent_txreq_o,
      agent_txrsp_i     => agent_txrsp_i,
      agent_rxreq_o     => agent_rxreq_o,
      agent_rxrsp_i     => agent_rxrsp_i,
      agent_msg_txreq_o => agent_msg_txreq_o,
      agent_msg_txrsp_i => agent_msg_txrsp_i,
      agent_msg_rxreq_o => agent_msg_rxreq_o,
      agent_msg_rxrsp_i => agent_msg_rxrsp_i,
      status_o          => dmai0_status
    );
    
  ------------------------------------------------------------------------------
  -- FSL unit
  ------------------------------------------------------------------------------
  fsli0: entity microsimd.hibi_dma_fsl
    port map (
      clk_i        => clk_i,
      reset_n_i    => reset_n_i,
      en_i         => en_i,
      init_i       => init_i,
      sel_i        => fsl_sel_i,
      fsl_req_i    => fsl_req_i,
      fsl_rsp_o    => fsl_rsp_o,
      gif_req_o    => fsli0_gif_req,
      gif_rsp_i    => dmai0_gif_rsp,
      dma_status_i => dmai0_status
    );

    ---------------------------------------------------------------------------
    -- GPIO logic implementation (simple gpio input -> GPIO mapping)
    ---------------------------------------------------------------------------
    gpioi0: block is
      type reg_t is record
	gpio    : hibi_dma_HIBI_DMA_GPIO_xw_t;
      end record reg_t;
      constant dflt_reg_c : reg_t :=(
        gpio   => (GPIO_0 => '0', GPIO_1 => '0', GPIO_2 => '0', GPIO_3 => '0',
                   GPIO_4 => '0', GPIO_5 => '0', GPIO_6 => '0', GPIO_7 => '0',
	           GPIO_8 => '0', GPIO_9 => '0', GPIO_A => '0', GPIO_B => '0',
	           GPIO_C => '0', GPIO_D => '0', GPIO_E => '0', GPIO_F => '0')
      );

      signal r, rin : reg_t;

    begin
      comb0: process (r, dmai0_gpio_dir, dmai0_gpio, gpio_i) is
	variable v : reg_t;
      begin
	v := r;

        if dmai0_gpio.c.wr = '1' then
	  v.gpio := dmai0_gpio.xw;
	end if;

        gpioi0_gpio.xr.GPIO_0 <= r.gpio.GPIO_0 when dmai0_gpio_dir.rw.GPIO_0 = '1' else gpio_i(0);
        gpioi0_gpio.xr.GPIO_1 <= r.gpio.GPIO_1 when dmai0_gpio_dir.rw.GPIO_1 = '1' else gpio_i(1);
        gpioi0_gpio.xr.GPIO_2 <= r.gpio.GPIO_2 when dmai0_gpio_dir.rw.GPIO_2 = '1' else gpio_i(2);
        gpioi0_gpio.xr.GPIO_3 <= r.gpio.GPIO_3 when dmai0_gpio_dir.rw.GPIO_3 = '1' else gpio_i(3);

        gpioi0_gpio.xr.GPIO_4 <= r.gpio.GPIO_4 when dmai0_gpio_dir.rw.GPIO_4 = '1' else gpio_i(4);
        gpioi0_gpio.xr.GPIO_5 <= r.gpio.GPIO_5 when dmai0_gpio_dir.rw.GPIO_5 = '1' else gpio_i(5);
        gpioi0_gpio.xr.GPIO_6 <= r.gpio.GPIO_6 when dmai0_gpio_dir.rw.GPIO_6 = '1' else gpio_i(6);
        gpioi0_gpio.xr.GPIO_7 <= r.gpio.GPIO_7 when dmai0_gpio_dir.rw.GPIO_7 = '1' else gpio_i(7);

	gpioi0_gpio.xr.GPIO_8 <= r.gpio.GPIO_8 when dmai0_gpio_dir.rw.GPIO_8 = '1' else gpio_i(8);
        gpioi0_gpio.xr.GPIO_9 <= r.gpio.GPIO_9 when dmai0_gpio_dir.rw.GPIO_9 = '1' else gpio_i(9);
        gpioi0_gpio.xr.GPIO_A <= r.gpio.GPIO_A when dmai0_gpio_dir.rw.GPIO_A = '1' else gpio_i(10);
        gpioi0_gpio.xr.GPIO_B <= r.gpio.GPIO_B when dmai0_gpio_dir.rw.GPIO_B = '1' else gpio_i(11);

        gpioi0_gpio.xr.GPIO_C <= r.gpio.GPIO_C when dmai0_gpio_dir.rw.GPIO_C = '1' else gpio_i(12);
        gpioi0_gpio.xr.GPIO_D <= r.gpio.GPIO_D when dmai0_gpio_dir.rw.GPIO_D = '1' else gpio_i(13);
        gpioi0_gpio.xr.GPIO_E <= r.gpio.GPIO_E when dmai0_gpio_dir.rw.GPIO_E = '1' else gpio_i(14);
        gpioi0_gpio.xr.GPIO_F <= r.gpio.GPIO_F when dmai0_gpio_dir.rw.GPIO_F = '1' else gpio_i(15);


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

