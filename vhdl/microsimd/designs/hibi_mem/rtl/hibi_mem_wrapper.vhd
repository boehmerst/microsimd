library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library microsimd;
use microsimd.hibi_link_pkg.all;
use microsimd.hibi_mem_pkg.all;

entity hibi_mem_wrapper is
  generic (
    log2_burst_length_g : integer range 2 to 5 := 4
  );
  port (
    clk_i               : in  std_ulogic;
    reset_n_i           : in  std_ulogic; 
    init_i              : in  std_ulogic;
    en_i                : in  std_ulogic;
    agent_txreq_o       : out agent_txreq_t;
    agent_txrsp_i       : in  agent_txrsp_t;
    agent_rxreq_o       : out agent_rxreq_t;
    agent_rxrsp_i       : in  agent_rxrsp_t;
    agent_msg_txreq_o   : out agent_txreq_t;
    agent_msg_txrsp_i   : in  agent_txrsp_t;
    agent_msg_rxreq_o   : out agent_rxreq_t;
    agent_msg_rxrsp_i   : in  agent_rxrsp_t
  );
end entity hibi_mem_wrapper;

architecture rtl of hibi_mem_wrapper is

  signal memi0_mem_req : hibi_mem_mem_req_t;
  signal mem_rsp       : hibi_mem_mem_rsp_t;

begin
  ------------------------------------------------------------------------------
  -- hibi memory
  ------------------------------------------------------------------------------
  memi0: entity microsimd.hibi_mem
    generic map (
      log2_burst_length_g => 3
    )
    port map (
      clk_i               => clk_i,
      reset_n_i           => reset_n_i,
      init_i              => init_i,
      en_i                => en_i,
      mem_req_o           => memi0_mem_req,
      mem_rsp_i           => mem_rsp,
      mem_wait_i          => '0',
      agent_txreq_o       => agent_txreq_o,
      agent_txrsp_i       => agent_txrsp_i,
      agent_rxreq_o       => agent_rxreq_o,
      agent_rxrsp_i       => agent_rxrsp_i,
      agent_msg_txreq_o   => agent_msg_txreq_o,
      agent_msg_txrsp_i   => agent_msg_txrsp_i,
      agent_msg_rxreq_o   => agent_msg_rxreq_o,
      agent_msg_rxrsp_i   => agent_msg_rxrsp_i,
      status_o            => open
    );
    
  ----------------------------------------------------------------------------
  -- RAM
  ----------------------------------------------------------------------------
  mem_blocki0: block is
    signal mem_dat : std_ulogic_vector(hibi_mem_mem_data_width_c-1 downto 0); 
    signal mem_we  : std_ulogic_vector(3 downto 0);
    signal mem_en  : std_ulogic;
  begin   
    mem_we <= "1111" when memi0_mem_req.we = '1' else "0000";

    memi0 : entity microsimd.sram_4en
      generic map (
        data_width_g => hibi_mem_mem_data_width_c,
        addr_width_g => hibi_mem_mem_addr_width_c-2
      )
      port map (
        clk_i  => clk_i,
        wre_i  => mem_we,
        ena_i  => memi0_mem_req.ena,
        addr_i => memi0_mem_req.adr(hibi_mem_mem_addr_width_c-1 downto 2),
        dat_i  => memi0_mem_req.dat,
        dat_o  => mem_dat
      );
       
     mem_rsp.dat <= mem_dat;
  end block mem_blocki0;
        
end architecture rtl;

