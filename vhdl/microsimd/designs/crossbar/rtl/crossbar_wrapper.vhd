library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.crossbar_pkg.all;
use work.core_pkg.all;

entity crossbar_wrapper is
  generic (
    nr_slv_g      : positive;
    log2_window_g : positive range 1 to xbar_addr_width_c-2
  );
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;
    en_i      : in  std_ulogic;
    init_i    : in  std_ulogic;
    imem_i    : in  imem_out_t;    
    imem_o    : out imem_in_t;
    dmem_i    : in  scu_dmem_out_t;    
    dmem_o    : out scu_dmem_in_t;
    wait_n_o  : out std_ulogic;
    slv_req_o : out xbar_req_arr_t(0 to nr_slv_g-1);
    slv_rsp_i : in  xbar_rsp_arr_t(0 to nr_slv_g-1)
  );
end entity crossbar_wrapper;

architecture rtl of crossbar_wrapper is
  type xbar_mst_t is (imst, dmst);
  
  constant nr_mst_c : positive := xbar_mst_t'pos(xbar_mst_t'right)+1;
  
  signal xbar_mst_req    : xbar_req_arr_t(0 to nr_mst_c-1);
  signal latchi0_mst_rsp : xbar_rsp_arr_t(0 to nr_mst_c-1);
  signal xbari0_mst_rsp  : xbar_rsp_arr_t(0 to nr_mst_c-1);
  
begin
  ------------------------------------------------------------------------------
  -- data type and I/O mapping
  ------------------------------------------------------------------------------
  wait_n_o <= latchi0_mst_rsp(xbar_mst_t'pos(imst)).ready;
  assert latchi0_mst_rsp(xbar_mst_t'pos(imst)).ready = latchi0_mst_rsp(xbar_mst_t'pos(dmst)).ready
    report "Instruction master ready should equal data master ready" severity error;
  
  xbar_mst_req(xbar_mst_t'pos(imst)).addr  <= imem_i.adr;
  xbar_mst_req(xbar_mst_t'pos(imst)).sel   <= (others=>'1');
  xbar_mst_req(xbar_mst_t'pos(imst)).wr    <= '0';
  xbar_mst_req(xbar_mst_t'pos(imst)).en    <= imem_i.ena;
  xbar_mst_req(xbar_mst_t'pos(imst)).wdata <= (others=>'0');

  xbar_mst_req(xbar_mst_t'pos(dmst)).addr  <= dmem_i.adr;
  xbar_mst_req(xbar_mst_t'pos(dmst)).sel   <= dmem_i.sel;
  xbar_mst_req(xbar_mst_t'pos(dmst)).wr    <= dmem_i.we;
  xbar_mst_req(xbar_mst_t'pos(dmst)).en    <= dmem_i.ena;
  xbar_mst_req(xbar_mst_t'pos(dmst)).wdata <= dmem_i.dat;
  
  imem_o.dat <= latchi0_mst_rsp(xbar_mst_t'pos(imst)).rdata;
  dmem_o.dat <= latchi0_mst_rsp(xbar_mst_t'pos(dmst)).rdata;

  ------------------------------------------------------------------------------
  -- crossbar_latch since cpu IM and DM are not totally independent
  ------------------------------------------------------------------------------
  latchi0: entity work.crossbar_latch
    generic map (
      nr_mst_g => nr_mst_c
    )
    port map (
      clk_i     => clk_i,
      reset_n_i => reset_n_i,
      en_i      => en_i,
      init_i    => init_i,
      mst_req_i => xbar_mst_req,
      mst_rsp_o => latchi0_mst_rsp,
      slv_rsp_i => xbari0_mst_rsp
    );
    
  ------------------------------------------------------------------------------
  -- crossbar
  ------------------------------------------------------------------------------
  xbari0: entity work.crossbar
    generic map (    
      nr_mst_g      => nr_mst_c,
      nr_slv_g      => nr_slv_g,
      log2_window_g => log2_window_g
    )
    port map (
      clk_i     => clk_i,
      reset_n_i => reset_n_i,
      en_i      => en_i,
      init_i    => init_i,
      mst_req_i => xbar_mst_req,
      mst_rsp_o => xbari0_mst_rsp,
      slv_req_o => slv_req_o,
      slv_rsp_i => slv_rsp_i
    );

end architecture rtl;

