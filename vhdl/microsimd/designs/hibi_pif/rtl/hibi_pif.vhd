library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library general;
use general.general_function_pkg.all;

library microsimd;
use microsimd.hibi_link_pkg.all;
use microsimd.hibi_pif_types_pkg.all;
use microsimd.hibi_pif_dma_pkg.all;
use microsimd.hibi_pif_dma_regif_types_pkg.all;
use microsimd.hibi_pif_dma_regfile_pkg.all;

entity hibi_pif is
  generic (
    log2_burst_length_g : integer range 2 to 5 := 4;
    nr_rxstreams_g      : integer range 1 to 4 := 1;
    nr_txstreams_g      : integer range 1 to 4 := 1
  );
  port (
    clk_i               : in  std_ulogic;
    reset_n_i           : in  std_ulogic;
    rxpif_reset_n_i     : in  std_ulogic_vector(nr_rxstreams_g-1 downto 0);
    en_i                : in  std_ulogic;
    init_i              : in  std_ulogic;
    pif_i               : in  hibi_pif_arr_t(0 to nr_rxstreams_g-1);
    pif_o               : out hibi_pif_arr_t(0 to nr_txstreams_g-1);  
    agent_txreq_o       : out agent_txreq_t;
    agent_txrsp_i       : in  agent_txrsp_t;
    agent_rxreq_o       : out agent_rxreq_t;
    agent_rxrsp_i       : in  agent_rxrsp_t;
    agent_msg_txreq_o   : out agent_txreq_t;
    agent_msg_txrsp_i   : in  agent_txrsp_t;
    agent_msg_rxreq_o   : out agent_rxreq_t;
    agent_msg_rxrsp_i   : in  agent_rxrsp_t
  );
end entity hibi_pif;

architecture rtl of hibi_pif is

  signal rx_rxfifo_rsp       : hibi_pif_rxfifo_rsp_arr_t(0 to nr_rxstreams_g-1);
  signal tx_txfifo_rsp       : hibi_pif_txfifo_rsp_arr_t(0 to nr_txstreams_g-1); 
  signal fifoifi0_rxfifo_req : hibi_pif_rxfifo_req_arr_t(0 to nr_rxstreams_g-1);
  signal fifoifi0_txfifo_req : hibi_pif_txfifo_req_arr_t(0 to nr_txstreams_g-1);
  
  signal rx_en               : std_ulogic_vector(nr_rxstreams_g-1 downto 0);
  
  signal tx_en               : std_ulogic_vector(nr_txstreams_g-1 downto 0);
  signal tx_init             : std_ulogic_vector(nr_txstreams_g-1 downto 0);  
  signal tx_cfg              : hibi_pif_cfg_arr_t(0 to nr_txstreams_g-1);
  signal tx_ctrl             : hibi_pif_ctrl_arr_t(0 to nr_txstreams_g-1);
  signal tx_status           : hibi_pif_status_arr_t(0 to nr_txstreams_g-1);
  
  signal fifoif_en           : std_ulogic;
  signal fifoif_init         : std_ulogic;
  
  signal dmai0_mem_req       : hibi_pif_dma_mem_req_t;
  signal fifoifi0_mem_rsp    : hibi_pif_dma_mem_rsp_t;
  signal fifoifi0_mem_wait   : std_ulogic;
  
  signal regifi0_gif_rsp    : hibi_pif_dma_gif_rsp_t;
  signal regifi0_reg2logic  : hibi_pif_dma_reg2logic_t;

  signal ctrli0_gif_req     : hibi_pif_dma_gif_req_t;
  signal logic2reg          : hibi_pif_dma_logic2reg_t;
  
  signal dma_en             : std_ulogic;
  signal dma_init           : std_ulogic;
  signal dma_cfg            : hibi_pif_dma_cfg_arr_t;
  signal dma_ctrl           : hibi_pif_dma_ctrl_arr_t;

  signal dmai0_status       : hibi_pif_dma_status_arr_t;
 
begin
  ------------------------------------------------------------------------------
  -- rx units
  ------------------------------------------------------------------------------
  rx_gen: for i in 0 to nr_rxstreams_g-1 generate
    rxi: entity microsimd.hibi_pif_rx
      port map (
        clk_i          => clk_i,
        reset_n_i      => reset_n_i,
        en_i           => rx_en(i),
        pclk_reset_n_i => rxpif_reset_n_i(i),
        pif_i          => pif_i(i),
        rxfifo_req_i   => fifoifi0_rxfifo_req(i),
        rxfifo_rsp_o   => rx_rxfifo_rsp(i)
      );
  end generate rx_gen;
  
  ------------------------------------------------------------------------------
  -- tx unit
  ------------------------------------------------------------------------------
  tx_gen: for i in 0 to nr_rxstreams_g-1 generate
    txi: entity microsimd.hibi_pif_tx
      port map (
        clk_i        => clk_i,
        reset_n_i    => reset_n_i,
        en_i         => tx_en(i),
        init_i       => tx_init(i),
        cfg_i        => tx_cfg(i),
        ctrl_i       => tx_ctrl(i),
        status_o     => tx_status(i),
        pif_o        => pif_o(i),
        txfifo_req_i => fifoifi0_txfifo_req(i),
        txfifo_rsp_o => tx_txfifo_rsp(i)
      );
  end generate tx_gen;
  
  ------------------------------------------------------------------------------
  -- fifo interface
  ------------------------------------------------------------------------------
  fifoifi0: entity microsimd.hibi_pif_fifo_if
    generic map (
      nr_txstreams_g => nr_txstreams_g,
      nr_rxstreams_g => nr_rxstreams_g   
    )
    port map (
      clk_i        => clk_i,
      reset_n_i    => reset_n_i,
      en_i         => fifoif_en,
      init_i       => fifoif_init,
      mem_req_i    => dmai0_mem_req,
      mem_rsp_o    => fifoifi0_mem_rsp,
      mem_wait_o   => fifoifi0_mem_wait,
      txfifo_req_o => fifoifi0_txfifo_req,
      txfifo_rsp_i => tx_txfifo_rsp,
      rxfifo_req_o => fifoifi0_rxfifo_req,
      rxfifo_rsp_i => rx_rxfifo_rsp
    );
  
  ------------------------------------------------------------------------------
  -- regfile
  ------------------------------------------------------------------------------  
  regifi0: entity microsimd.hibi_pif_dma_regfile
    port map (
      clk_i       => clk_i,
      reset_n_i   => reset_n_i,
      gif_req_i   => ctrli0_gif_req,
      gif_rsp_o   => regifi0_gif_rsp,
      logic2reg_i => logic2reg,
      reg2logic_o => regifi0_reg2logic
    );
    
  ------------------------------------------------------------------------------
  -- hibi dma core
  ------------------------------------------------------------------------------
  dmai0: entity microsimd.hibi_pif_dma_core
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
      mem_req_o     => dmai0_mem_req,
      mem_rsp_i     => fifoifi0_mem_rsp,
      mem_wait_i    => fifoifi0_mem_wait,
      agent_txreq_o => agent_txreq_o,
      agent_txrsp_i => agent_txrsp_i,
      agent_rxreq_o => agent_rxreq_o,
      agent_rxrsp_i => agent_rxrsp_i,
      status_o      => dmai0_status
    );

  ------------------------------------------------------------------------------
  -- hibi_mem_ctrl
  ------------------------------------------------------------------------------
  ctrli0: entity microsimd.hibi_pif_dma_ctrl
    port map (
      clk_i              => clk_i,
      reset_n_i          => reset_n_i,
      init_i             => init_i,
      en_i               => en_i,
      gif_req_o          => ctrli0_gif_req,
      gif_rsp_i          => regifi0_gif_rsp,
      agent_msg_txreq_o  => agent_msg_txreq_o,
      agent_msg_txrsp_i  => agent_msg_txrsp_i,
      agent_msg_rxreq_o  => agent_msg_rxreq_o,
      agent_msg_rxrsp_i  => agent_msg_rxrsp_i
  );    
 
  ------------------------------------------------------------------------------
  -- regfile mapping
  ------------------------------------------------------------------------------
  logic2reg.HIBI_DMA_STATUS.ro.busy0    <= dmai0_status(0).busy;
  logic2reg.HIBI_TXPIF_STATUS.ro.busy   <= tx_status(0).busy;
  logic2reg.HIBI_TXPIF_STATUS.ro.vsync  <= tx_status(0).vsync;
  logic2reg.HIBI_TXPIF_STATUS.ro.hsync  <= tx_status(0).hsync;
  
  dma_ctrl(0).start                  <= regifi0_reg2logic.HIBI_DMA_TRIGGER.c.wr and regifi0_reg2logic.HIBI_DMA_TRIGGER.xw.start0;
  dma_cfg(0).hibi_addr               <= regifi0_reg2logic.HIBI_DMA_HIBI_ADDR0.rw.addr;
  dma_cfg(0).mem_addr                <= regifi0_reg2logic.HIBI_DMA_MEM_ADDR0.rw.addr;
  dma_cfg(0).count                   <= regifi0_reg2logic.HIBI_DMA_CFG0.rw.count;
  dma_cfg(0).direction               <= regifi0_reg2logic.HIBI_DMA_CFG0.rw.direction;
  dma_cfg(0).const_addr              <= regifi0_reg2logic.HIBI_DMA_CFG0.rw.const_addr;
  dma_cfg(0).cmd                     <= regifi0_reg2logic.HIBI_DMA_CFG0.rw.hibi_cmd;

  logic2reg.HIBI_DMA_STATUS.ro.busy1 <= dmai0_status(1).busy;
  dma_ctrl(1).start                  <= regifi0_reg2logic.HIBI_DMA_TRIGGER.c.wr and regifi0_reg2logic.HIBI_DMA_TRIGGER.xw.start1;
  dma_cfg(1).hibi_addr               <= regifi0_reg2logic.HIBI_DMA_HIBI_ADDR1.rw.addr;
  dma_cfg(1).mem_addr                <= regifi0_reg2logic.HIBI_DMA_MEM_ADDR1.rw.addr;
  dma_cfg(1).count                   <= regifi0_reg2logic.HIBI_DMA_CFG1.rw.count;
  dma_cfg(1).direction               <= regifi0_reg2logic.HIBI_DMA_CFG1.rw.direction;
  dma_cfg(1).const_addr              <= regifi0_reg2logic.HIBI_DMA_CFG1.rw.const_addr;
  dma_cfg(1).cmd                     <= regifi0_reg2logic.HIBI_DMA_CFG1.rw.hibi_cmd;

  logic2reg.HIBI_DMA_STATUS.ro.busy2 <= dmai0_status(2).busy;
  dma_ctrl(2).start                  <= regifi0_reg2logic.HIBI_DMA_TRIGGER.c.wr and regifi0_reg2logic.HIBI_DMA_TRIGGER.xw.start2;
  dma_cfg(2).hibi_addr               <= regifi0_reg2logic.HIBI_DMA_HIBI_ADDR2.rw.addr;
  dma_cfg(2).mem_addr                <= regifi0_reg2logic.HIBI_DMA_MEM_ADDR2.rw.addr;
  dma_cfg(2).count                   <= regifi0_reg2logic.HIBI_DMA_CFG2.rw.count;
  dma_cfg(2).direction               <= regifi0_reg2logic.HIBI_DMA_CFG2.rw.direction;
  dma_cfg(2).const_addr              <= regifi0_reg2logic.HIBI_DMA_CFG2.rw.const_addr;
  dma_cfg(2).cmd                     <= regifi0_reg2logic.HIBI_DMA_CFG2.rw.hibi_cmd;

  logic2reg.HIBI_DMA_STATUS.ro.busy3 <= dmai0_status(3).busy;
  dma_ctrl(3).start                  <= regifi0_reg2logic.HIBI_DMA_TRIGGER.c.wr and regifi0_reg2logic.HIBI_DMA_TRIGGER.xw.start3;
  dma_cfg(3).hibi_addr               <= regifi0_reg2logic.HIBI_DMA_HIBI_ADDR3.rw.addr;
  dma_cfg(3).mem_addr                <= regifi0_reg2logic.HIBI_DMA_MEM_ADDR3.rw.addr;
  dma_cfg(3).count                   <= regifi0_reg2logic.HIBI_DMA_CFG3.rw.count;
  dma_cfg(3).direction               <= regifi0_reg2logic.HIBI_DMA_CFG3.rw.direction;
  dma_cfg(3).const_addr              <= regifi0_reg2logic.HIBI_DMA_CFG3.rw.const_addr;
  dma_cfg(3).cmd                     <= regifi0_reg2logic.HIBI_DMA_CFG3.rw.hibi_cmd;
  
  tx_cfg(0).vsize                    <= regifi0_reg2logic.HIBI_TXPIF_CFG.rw.vsize;
  tx_cfg(0).hsize                    <= regifi0_reg2logic.HIBI_TXPIF_CFG.rw.hsize;
  
  tx_ctrl(0).fe                      <= regifi0_reg2logic.HIBI_TRIG_CTRL.xw.fe and regifi0_reg2logic.HIBI_TRIG_CTRL.c.wr;
  tx_ctrl(0).le                      <= regifi0_reg2logic.HIBI_TRIG_CTRL.xw.le and regifi0_reg2logic.HIBI_TRIG_CTRL.c.wr;
  
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
  
  fifoif_en   <= dma_en;
  fifoif_init <= dma_init; 
  
  ------------------------------------------------------------------------------
  -- pif eneble and init logic
  ------------------------------------------------------------------------------
  txpif_en0: process(clk_i, reset_n_i) is
  begin
    if(reset_n_i = '0') then
      tx_en <= (others=>'0');
      rx_en <= (others=>'0');
    elsif(rising_edge(clk_i)) then
      tx_en(0) <= regifi0_reg2logic.HIBI_PIF_CTRL.rw.txen;
      rx_en(0) <= regifi0_reg2logic.HIBI_PIF_CTRL.rw.rxen;      
    end if;    
  end process txpif_en0;  
  
  tx_init(0) <= '1' when tx_en(0) = '1' and regifi0_reg2logic.HIBI_PIF_CTRL.rw.txen = '0' else '0';
  
end architecture rtl;

