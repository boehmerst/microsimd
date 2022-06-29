library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tech;

library microsimd;
use microsimd.config_pkg.all;
use microsimd.core_pkg.all;
use microsimd.func_pkg.all;
use microsimd.vec_data_pkg.all;
use microsimd.hibi_link_pkg.all;
use microsimd.hibi_dma_pkg.all;
use microsimd.xbar_pkg.all;

entity cpu is
  port (
    clk_i             : in  std_ulogic;
    reset_n_i         : in  std_ulogic;
    hart_id_i         : in  std_ulogic_vector(15 downto 0);
    core_en_i         : in  std_ulogic;
    core_init_i       : in  std_ulogic;
    irq_i             : in  std_ulogic;
    agent_en_i        : in  std_ulogic;
    agent_init_i      : in  std_ulogic;
    agent_txreq_o     : out agent_txreq_t;
    agent_txrsp_i     : in  agent_txrsp_t;
    agent_rxreq_o     : out agent_rxreq_t;
    agent_rxrsp_i     : in  agent_rxrsp_t;
    agent_msg_txreq_o : out agent_txreq_t;
    agent_msg_txrsp_i : in  agent_txrsp_t;
    agent_msg_rxreq_o : out agent_rxreq_t;
    agent_msg_rxrsp_i : in  agent_rxrsp_t
  );
end entity cpu;

architecture rtl of cpu is
    
  constant nr_slv_c              : integer   := 3;
  constant nr_mst_c              : integer   := 3;
  
  type xbar_mst_t is (imst, dmst, dma);
  type xbar_slv_t is (mem0, mem1, mem2);

  constant nr_mem_blocks_c       : integer   := xbar_slv_t'pos(xbar_slv_t'right)+1;
  constant mem_block_size_c      : integer   := log2ceil(512);
  constant ram_size_c            : integer   := log2ceil(nr_mem_blocks_c * 512);
  
  signal imem                    : imem_in_t;
  signal dmem                    : dmem_in_t;
  signal wait_n                  : std_ulogic;
  
  signal corei0_imem             : imem_out_t;
  signal corei0_dmem             : dmem_out_t;
  signal corei0_fsl_sel          : std_ulogic_vector(CFG_NR_FSL-1 downto 0);
  signal corei0_fsl_req          : fsl_req_t;
  
  signal dma_mem_rsp             : hibi_dma_mem_rsp_t;
  signal hibi_dmai0_mem_req      : hibi_dma_mem_req_t;
  
  signal hibi_linki0_fsl_rsp     : fsl_rsp_t;
  signal fsl_rsp                 : fsl_rsp_array_t(0 to CFG_NR_FSL-1);
  signal hibi_dmai0_fsl_rsp      : fsl_rsp_t;

  signal xbar_mst_req            : xbar_req_arr_t(0 to nr_mst_c-1);
  signal xbar_slv_rsp            : xbar_rsp_arr_t(0 to nr_slv_c-1);
  signal xbari0_mst_rsp          : xbar_rsp_arr_t(0 to nr_mst_c-1);
  signal xbari0_slv_req          : xbar_req_arr_t(0 to nr_slv_c-1);
  signal xbari0_wait_req         : std_ulogic;

begin
  ------------------------------------------------------------------------------
  -- 32/64 bit microsimd core
  ------------------------------------------------------------------------------ 
  fsl_rsp(fsl_slave_t'pos(hibi_dma_fsl))   <= hibi_dmai0_fsl_rsp;
  
  imem.dat     <= xbari0_mst_rsp(xbar_mst_t'pos(imst)).rdata;
  dmem.scu.dat <= xbari0_mst_rsp(xbar_mst_t'pos(dmst)).rdata;
  dmem.simd    <= dflt_vec_dmem_in_c;        -- since we use internal LSU
  wait_n       <= not xbari0_wait_req and core_en_i;
  
  corei0: entity microsimd.core
    generic map (
      use_lsu_g        => true,
      use_barrel_g     => true,  
      use_hw_mul_g     => true,
      use_irq_g        => false
    )
    port map (
      clk_i            => clk_i,                       
      reset_n_i        => reset_n_i,
      init_i           => core_init_i,
      irq_i            => irq_i,
      wait_n_i         => wait_n,
      imem_o           => corei0_imem,
      imem_i           => imem,
      dmem_o           => corei0_dmem,
      dmem_i           => dmem,
      fsl_sel_o        => corei0_fsl_sel,
      fsl_req_o        => corei0_fsl_req,
      fsl_rsp_i        => fsl_rsp
    );
    
  ------------------------------------------------------------------------------
  -- hibi dma
  ------------------------------------------------------------------------------
  dma_mem_rsp.dat <= xbari0_mst_rsp(xbar_mst_t'pos(dma)).rdata;
  
  hibi_dmai0: entity microsimd.hibi_dma_wrapper
    generic map (
      log2_burst_length_g => 3
    )
    port map (
      clk_i             => clk_i,
      reset_n_i         => reset_n_i,
      en_i              => agent_en_i,
      init_i            => agent_init_i,
      gpio_i            => hart_id_i,
      fsl_sel_i         => corei0_fsl_sel(fsl_slave_t'pos(hibi_dma_fsl)),
      fsl_req_i         => corei0_fsl_req,
      fsl_rsp_o         => hibi_dmai0_fsl_rsp,    
      mem_req_o         => hibi_dmai0_mem_req,
      mem_rsp_i         => dma_mem_rsp,
      mem_wait_i        => xbari0_wait_req,
      agent_txreq_o     => agent_txreq_o,
      agent_txrsp_i     => agent_txrsp_i,
      agent_rxreq_o     => agent_rxreq_o,
      agent_rxrsp_i     => agent_rxrsp_i,
      agent_msg_txreq_o => agent_msg_txreq_o,
      agent_msg_txrsp_i => agent_msg_txrsp_i,
      agent_msg_rxreq_o => agent_msg_rxreq_o,
      agent_msg_rxrsp_i => agent_msg_rxrsp_i
    );

  ------------------------------------------------------------------------------
  -- memory xbar (vector memory transfers handled and serialized by core LSU)
  ------------------------------------------------------------------------------
  xbar_mst_req(xbar_mst_t'pos(imst)).ctrl.addr <= microsimd.core_pkg.align_adr(corei0_imem.adr, dflt_xbar_ctrl_c.addr'length, WORD);
  xbar_mst_req(xbar_mst_t'pos(imst)).ctrl.sel  <= (others => '1');
  xbar_mst_req(xbar_mst_t'pos(imst)).ctrl.wr   <= '0';
  xbar_mst_req(xbar_mst_t'pos(imst)).ctrl.en   <= corei0_imem.ena;
  xbar_mst_req(xbar_mst_t'pos(imst)).wdata     <= (others=>'0');

  xbar_mst_req(xbar_mst_t'pos(dmst)).ctrl.addr <= microsimd.core_pkg.align_adr(corei0_dmem.scu.adr, dflt_xbar_ctrl_c.addr'length, WORD);
  xbar_mst_req(xbar_mst_t'pos(dmst)).ctrl.sel  <= corei0_dmem.scu.sel;
  xbar_mst_req(xbar_mst_t'pos(dmst)).ctrl.wr   <= corei0_dmem.scu.we;
  xbar_mst_req(xbar_mst_t'pos(dmst)).ctrl.en   <= corei0_dmem.scu.ena;
  xbar_mst_req(xbar_mst_t'pos(dmst)).wdata     <= corei0_dmem.scu.dat;
  
  xbar_mst_req(xbar_mst_t'pos(dma)).ctrl.addr <= std_ulogic_vector(resize(unsigned(hibi_dmai0_mem_req.adr), dflt_xbar_ctrl_c.addr'length));
  xbar_mst_req(xbar_mst_t'pos(dma)).ctrl.sel  <= (others=>'1');
  xbar_mst_req(xbar_mst_t'pos(dma)).ctrl.wr   <= hibi_dmai0_mem_req.we;
  xbar_mst_req(xbar_mst_t'pos(dma)).ctrl.en   <= hibi_dmai0_mem_req.ena;
  xbar_mst_req(xbar_mst_t'pos(dma)).wdata     <= hibi_dmai0_mem_req.dat; 

  -----------------------------------------------------------------------------
  -- simple xvar for slaves that respond the next cycle e.g. SRAM
  -----------------------------------------------------------------------------
  xbari0: entity microsimd.xbar
    generic map (
      log2_wsize_g   => mem_block_size_c,
      nr_mst_g       => nr_mst_c,
      nr_slv_g       => nr_slv_c
    )
    port map (
      clk_i          => clk_i,
      reset_n_i      => reset_n_i,
      en_i           => agent_en_i,
      init_i         => agent_init_i,
      xbar_mst_req_i => xbar_mst_req,
      xbar_mst_rsp_o => xbari0_mst_rsp,
      xbar_slv_rsp_i => xbar_slv_rsp,
      xbar_slv_req_o => xbari0_slv_req,
      wait_req_o     => xbari0_wait_req
    );
    
  ------------------------------------------------------------------------------
  -- 32 bit memory 0
  ------------------------------------------------------------------------------
  mem_block0: block is
    signal mem_dat : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0); 
    signal mem_we  : std_ulogic_vector(3 downto 0);
    signal mem_en  : std_ulogic;
  begin   
    mem_we <= xbari0_slv_req(xbar_slv_t'pos(mem0)).ctrl.sel when xbari0_slv_req(xbar_slv_t'pos(mem0)).ctrl.wr = '1' else "0000";
    mem_en <= xbari0_slv_req(0).ctrl.en;

    memi0 : entity tech.sp_sync_mem
      generic map (
        data_width_g  => CFG_DMEM_WIDTH,
        addr_width_g  => mem_block_size_c
      )
      port map (
        clk_i  => clk_i,
        we_i   => mem_we,
        en_i   => mem_en,
        addr_i => xbari0_slv_req(xbar_slv_t'pos(mem0)).ctrl.addr(mem_block_size_c-1 downto 0),
        di_i   => xbari0_slv_req(xbar_slv_t'pos(mem0)).wdata,
        do_o   => mem_dat
      );
    
     xbar_slv_rsp(xbar_slv_t'pos(mem0)).rdata <= mem_dat;
  end block mem_block0;
   
  ------------------------------------------------------------------------------
  -- 32 bit memory 1
  ------------------------------------------------------------------------------
  mem_block1: block is
    signal mem_dat : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0); 
    signal mem_we  : std_ulogic_vector(3 downto 0);
    signal mem_en  : std_ulogic;
  begin   
    mem_we <= xbari0_slv_req(xbar_slv_t'pos(mem1)).ctrl.sel when xbari0_slv_req(xbar_slv_t'pos(mem1)).ctrl.wr = '1' else "0000";
    mem_en <= xbari0_slv_req(xbar_slv_t'pos(mem1)).ctrl.en;    

    memi0 : entity tech.sp_sync_mem
      generic map (
        data_width_g => CFG_DMEM_WIDTH,
        addr_width_g => mem_block_size_c
      )
      port map (
        clk_i  => clk_i,
        we_i   => mem_we,
        en_i   => mem_en,
        addr_i => xbari0_slv_req(xbar_slv_t'pos(mem1)).ctrl.addr(mem_block_size_c-1 downto 0),
        di_i   => xbari0_slv_req(xbar_slv_t'pos(mem1)).wdata,
        do_o   => mem_dat
      );
    
     xbar_slv_rsp(xbar_slv_t'pos(mem1)).rdata <= mem_dat;
  end block mem_block1;
  
  ------------------------------------------------------------------------------
  -- 32 bit memory 2
  ------------------------------------------------------------------------------
  mem_block2: block is
    signal mem_dat : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0); 
    signal mem_we  : std_ulogic_vector(3 downto 0);
    signal mem_en  : std_ulogic;
  begin   
    mem_we <= xbari0_slv_req(xbar_slv_t'pos(mem2)).ctrl.sel when xbari0_slv_req(xbar_slv_t'pos(mem2)).ctrl.wr = '1' else "0000";
    mem_en <= xbari0_slv_req(xbar_slv_t'pos(mem2)).ctrl.en;    

    memi0 : entity tech.sp_sync_mem
      generic map (
        data_width_g => CFG_DMEM_WIDTH,
        addr_width_g => mem_block_size_c
      )
      port map (
        clk_i  => clk_i,
        we_i   => mem_we,
        en_i   => mem_en,
        addr_i => xbari0_slv_req(xbar_slv_t'pos(mem2)).ctrl.addr(mem_block_size_c-1 downto 0),
        di_i   => xbari0_slv_req(xbar_slv_t'pos(mem2)).wdata,
        do_o   => mem_dat
      );
    
     xbar_slv_rsp(xbar_slv_t'pos(mem2)).rdata <= mem_dat;
  end block mem_block2;

end architecture rtl;

