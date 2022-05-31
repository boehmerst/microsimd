-------------------------------------------------------------------------------
-- Title      : hibi_dma
-- Project    :
-------------------------------------------------------------------------------
-- File       : hibi_dma.vhd
-- Author     : deboehse
-- Company    : private
-- Created    : 
-- Last update: 
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: automated generated do not edit manually
-------------------------------------------------------------------------------
-- Copyright (c) 2013 Stephan Böhmer
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
--             1.0      SBo     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library microsimd;
use microsimd.hibi_link_pkg.all;

library work;
use work.hibi_dma_pkg.all;
use work.hibi_dma_regif_types_pkg.all;
use work.hibi_dma_regfile_pkg.all;

entity hibi_dma is
  generic (
    log2_burst_length_g : integer range 2 to 5 := 4
  );
  port (
    clk_i             : in  std_ulogic;
    reset_n_i         : in  std_ulogic;
    en_i              : in  std_ulogic;
    init_i            : in  std_ulogic;
    ext_gif_req_i     : in  hibi_dma_gif_req_t;
    ext_gif_rsp_o     : out hibi_dma_gif_rsp_t;
    gpio_o            : out hibi_dma_HIBI_DMA_GPIO_reg2logic_t;
    gpio_i            : in  hibi_dma_HIBI_DMA_GPIO_logic2reg_t;
    gpio_dir_o        : out hibi_dma_HIBI_DMA_GPIO_DIR_reg2logic_t;
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
    agent_msg_rxrsp_i : in  agent_rxrsp_t;
    status_o          : out hibi_dma_status_arr_t
  );
end entity hibi_dma;

architecture rtl of hibi_dma is

  signal regifi0_gif_rsp    : hibi_dma_gif_rsp_t;
  signal regifi0_reg2logic  : hibi_dma_reg2logic_t;

  signal ctrli0_gif_req     : hibi_dma_gif_req_t;
  signal logic2reg          : hibi_dma_logic2reg_t;

  signal muxi0_m0_gif_rsp   : hibi_dma_gif_rsp_t;
  signal muxi0_gif_req      : hibi_dma_gif_req_t;

  type chain_array_t is array(natural range 0 to hibi_dma_channels_c-1) of std_ulogic_vector(hibi_dma_channels_c-1 downto 0);
  signal chain_mask      : chain_array_t;
  signal chain_trigger   : std_ulogic_vector(hibi_dma_channels_c-1 downto 0);
  signal chain_start     : std_ulogic_vector(hibi_dma_channels_c-1 downto 0);
  signal chain_busy      : std_ulogic_vector(hibi_dma_channels_c-1 downto 0);
  signal chaini0_start   : std_ulogic_vector(hibi_dma_channels_c-1 downto 0);
  signal chaini0_trigger : std_ulogic_vector(hibi_dma_channels_c-1 downto 0);

  signal dma_en             : std_ulogic;
  signal dma_init           : std_ulogic;
  signal dma_cfg            : hibi_dma_cfg_arr_t;
  signal dma_ctrl           : hibi_dma_ctrl_arr_t;

  signal dmai0_status       : hibi_dma_status_arr_t;

begin
  ------------------------------------------------------------------------------
  -- hibi dma register file
  ------------------------------------------------------------------------------
  regifi0: entity work.hibi_dma_regfile
    port map (
      clk_i       => clk_i,
      reset_n_i   => reset_n_i,
      gif_req_i   => muxi0_gif_req,
      gif_rsp_o   => regifi0_gif_rsp,
      logic2reg_i => logic2reg,
      reg2logic_o => regifi0_reg2logic
    );

  ------------------------------------------------------------------------------
  -- hibi dma chaining
  ------------------------------------------------------------------------------
    chain_mask(0)    <= regifi0_reg2logic.HIBI_DMA_TRIGGER_MASK0.rw.mask;
    chain_start(0)   <= regifi0_reg2logic.HIBI_DMA_TRIGGER.c.wr and regifi0_reg2logic.HIBI_DMA_TRIGGER.xw.start0;
    chain_busy(0)    <= dmai0_status(0).busy;

    chain_mask(1)    <= regifi0_reg2logic.HIBI_DMA_TRIGGER_MASK1.rw.mask;
    chain_start(1)   <= regifi0_reg2logic.HIBI_DMA_TRIGGER.c.wr and regifi0_reg2logic.HIBI_DMA_TRIGGER.xw.start1;
    chain_busy(1)    <= dmai0_status(1).busy;

    chain_mask(2)    <= regifi0_reg2logic.HIBI_DMA_TRIGGER_MASK2.rw.mask;
    chain_start(2)   <= regifi0_reg2logic.HIBI_DMA_TRIGGER.c.wr and regifi0_reg2logic.HIBI_DMA_TRIGGER.xw.start2;
    chain_busy(2)    <= dmai0_status(2).busy;

    chain_mask(3)    <= regifi0_reg2logic.HIBI_DMA_TRIGGER_MASK3.rw.mask;
    chain_start(3)   <= regifi0_reg2logic.HIBI_DMA_TRIGGER.c.wr and regifi0_reg2logic.HIBI_DMA_TRIGGER.xw.start3;
    chain_busy(3)    <= dmai0_status(3).busy;

  chaini0: for i in 0 to hibi_dma_channels_c-1 generate
    chain_trigger(i) <= chaini0_trigger(i);

    trigi0: entity microsimd.hibi_dma_trigger
      generic map (
        hibi_dma_channels_g => hibi_dma_channels_c
      )
      port map (
        clk_i     => clk_i,
        reset_n_i => reset_n_i,
        en_i      => dma_en,
        init_i    => dma_init,
        start_i   => chain_start(i),
        busy_i    => chain_busy(i),
        trigger_i => chain_trigger,
        mask_i    => chain_mask(i),
        trigger_o => chaini0_trigger(i),
        start_o   => chaini0_start(i)
      );
  end generate chaini0;

  ------------------------------------------------------------------------------
  -- hibi dma core
  ------------------------------------------------------------------------------
  status_o <= dmai0_status;

  dmai0: entity work.hibi_dma_core
    generic map (
      log2_burst_length_g => log2_burst_length_g
    )
    port map (
      clk_i         => clk_i,
      reset_n_i     => reset_n_i,
      en_i          => dma_en,
      init_i        => dma_init,
      cfg_i         => dma_cfg,
      ctrl_i        => dma_ctrl,
      mem_req_o     => mem_req_o,
      mem_rsp_i     => mem_rsp_i,
      mem_wait_i    => mem_wait_i,
      agent_txreq_o => agent_txreq_o,
      agent_txrsp_i => agent_txrsp_i,
      agent_rxreq_o => agent_rxreq_o,
      agent_rxrsp_i => agent_rxrsp_i,
      status_o      => dmai0_status
    );

  ----------------------------------------------------------------------------
  -- hibi_mem_ctrl
  ----------------------------------------------------------------------------
  ctrli0: entity work.hibi_dma_ctrl
    port map (
      clk_i              => clk_i,
      reset_n_i          => reset_n_i,
      init_i             => init_i,
      en_i               => en_i,
      gif_req_o          => ctrli0_gif_req,
      gif_rsp_i          => muxi0_m0_gif_rsp,
      agent_msg_txreq_o  => agent_msg_txreq_o,
      agent_msg_txrsp_i  => agent_msg_txrsp_i,
      agent_msg_rxreq_o  => agent_msg_rxreq_o,
      agent_msg_rxrsp_i  => agent_msg_rxrsp_i
  );

  -----------------------------------------------------------------------------
  -- gif mux interface
  -----------------------------------------------------------------------------
  muxi0: entity work.hibi_dma_gif_mux
    port map (
      clk_i         => clk_i,
      reset_n_i     => reset_n_i,
      en_i          => en_i,
      init_i        => init_i,
      m0_gif_req_i  => ctrli0_gif_req,
      m0_gif_rsp_o  => muxi0_m0_gif_rsp,
      m1_gif_req_i  => ext_gif_req_i,
      m1_gif_rsp_o  => ext_gif_rsp_o,
      mux_gif_req_o => muxi0_gif_req,
      mux_gif_rsp_i => regifi0_gif_rsp
    );

  ------------------------------------------------------------------------------
  -- regfile mapping
  ------------------------------------------------------------------------------
  logic2reg.HIBI_DMA_STATUS.ro.busy0 <= dmai0_status(0).busy;
  dma_ctrl(0).start                  <= chaini0_start(0);
  dma_cfg(0).hibi_addr               <= regifi0_reg2logic.HIBI_DMA_HIBI_ADDR0.rw.addr;
  dma_cfg(0).mem_addr                <= regifi0_reg2logic.HIBI_DMA_MEM_ADDR0.rw.addr;
  dma_cfg(0).count                   <= regifi0_reg2logic.HIBI_DMA_CFG0.rw.count;
  dma_cfg(0).direction               <= regifi0_reg2logic.HIBI_DMA_CFG0.rw.direction;
  dma_cfg(0).const_addr              <= regifi0_reg2logic.HIBI_DMA_CFG0.rw.const_addr;
  dma_cfg(0).cmd                     <= regifi0_reg2logic.HIBI_DMA_CFG0.rw.hibi_cmd;

  logic2reg.HIBI_DMA_STATUS.ro.busy1 <= dmai0_status(1).busy;
  dma_ctrl(1).start                  <= chaini0_start(1);
  dma_cfg(1).hibi_addr               <= regifi0_reg2logic.HIBI_DMA_HIBI_ADDR1.rw.addr;
  dma_cfg(1).mem_addr                <= regifi0_reg2logic.HIBI_DMA_MEM_ADDR1.rw.addr;
  dma_cfg(1).count                   <= regifi0_reg2logic.HIBI_DMA_CFG1.rw.count;
  dma_cfg(1).direction               <= regifi0_reg2logic.HIBI_DMA_CFG1.rw.direction;
  dma_cfg(1).const_addr              <= regifi0_reg2logic.HIBI_DMA_CFG1.rw.const_addr;
  dma_cfg(1).cmd                     <= regifi0_reg2logic.HIBI_DMA_CFG1.rw.hibi_cmd;

  logic2reg.HIBI_DMA_STATUS.ro.busy2 <= dmai0_status(2).busy;
  dma_ctrl(2).start                  <= chaini0_start(2);
  dma_cfg(2).hibi_addr               <= regifi0_reg2logic.HIBI_DMA_HIBI_ADDR2.rw.addr;
  dma_cfg(2).mem_addr                <= regifi0_reg2logic.HIBI_DMA_MEM_ADDR2.rw.addr;
  dma_cfg(2).count                   <= regifi0_reg2logic.HIBI_DMA_CFG2.rw.count;
  dma_cfg(2).direction               <= regifi0_reg2logic.HIBI_DMA_CFG2.rw.direction;
  dma_cfg(2).const_addr              <= regifi0_reg2logic.HIBI_DMA_CFG2.rw.const_addr;
  dma_cfg(2).cmd                     <= regifi0_reg2logic.HIBI_DMA_CFG2.rw.hibi_cmd;

  logic2reg.HIBI_DMA_STATUS.ro.busy3 <= dmai0_status(3).busy;
  dma_ctrl(3).start                  <= chaini0_start(3);
  dma_cfg(3).hibi_addr               <= regifi0_reg2logic.HIBI_DMA_HIBI_ADDR3.rw.addr;
  dma_cfg(3).mem_addr                <= regifi0_reg2logic.HIBI_DMA_MEM_ADDR3.rw.addr;
  dma_cfg(3).count                   <= regifi0_reg2logic.HIBI_DMA_CFG3.rw.count;
  dma_cfg(3).direction               <= regifi0_reg2logic.HIBI_DMA_CFG3.rw.direction;
  dma_cfg(3).const_addr              <= regifi0_reg2logic.HIBI_DMA_CFG3.rw.const_addr;
  dma_cfg(3).cmd                     <= regifi0_reg2logic.HIBI_DMA_CFG3.rw.hibi_cmd;

  gpio_o                  <= regifi0_reg2logic.HIBI_DMA_GPIO;
  gpio_dir_o              <= regifi0_reg2logic.HIBI_DMA_GPIO_DIR;
  logic2reg.HIBI_DMA_GPIO <= gpio_i;

  ------------------------------------------------------------------------------
  -- dma enable and init logic
  ------------------------------------------------------------------------------
  dma_en0: process(clk_i, reset_n_i) is
  begin
    if(reset_n_i = '0') then
      dma_en <= '0';
    elsif(rising_edge(clk_i)) then
      dma_en <= regifi0_reg2logic.HIBI_DMA_CTRL.rw.en;
    end if;
  end process dma_en0;

  dma_init <= '1' when dma_en = '1' and regifi0_reg2logic.HIBI_DMA_CTRL.rw.en = '0' else '0';

end architecture rtl;

