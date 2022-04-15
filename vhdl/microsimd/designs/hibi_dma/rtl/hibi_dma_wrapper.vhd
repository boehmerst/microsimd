library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library microsimd;
use microsimd.core_pkg.all;
use microsimd.hibi_link_pkg.all;
use microsimd.hibi_dma_pkg.all;
use microsimd.hibi_dma_regif_types_pkg.all;

entity hibi_dma_wrapper is
  generic (
    log2_burst_length_g : integer range 2 to 5 := 4
  );
  port (
    clk_i             : in  std_ulogic;
    reset_n_i         : in  std_ulogic;
    en_i              : in  std_ulogic;
    init_i            : in  std_ulogic;
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

  signal dmai0_status  : hibi_dma_status_arr_t;
  signal dmai0_gif_rsp : hibi_dma_gif_rsp_t;
  signal fsli0_gif_req : hibi_dma_gif_req_t;

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

end architecture rtl;

