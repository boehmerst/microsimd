library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.xbar_2008_pkg.all;


entity xbar_2008_tb is
end entity xbar_2008_tb;

architecture beh of xbar_2008_tb is
  
  constant addr_width_c : integer    := 9;
  constant data_width_c : integer    := 32;
  constant sel_width_c  : integer    := data_width_c/8;

  constant nr_mst_c     : integer    := 2;
  constant nr_slv_c     : integer    := 2;

  constant clk_cycle_c  : time       := 10 ns;
  signal clk            : std_ulogic := '0';
  signal reset_n        : std_ulogic := '0';
  signal sim_done       : boolean    := false;

  subtype xbar_mst_req_arr_tb_t is xbar_req_arr_t(0 to nr_mst_c-1)(ctrl(addr(addr_width_c-1 downto 0), sel(sel_width_c-1 downto 0)), wdata(data_width_c-1 downto 0));
  subtype xbar_slv_req_arr_tb_t is xbar_req_arr_t(0 to nr_slv_c-1)(ctrl(addr(addr_width_c-1 downto 0), sel(sel_width_c-1 downto 0)), wdata(data_width_c-1 downto 0));

  subtype xbar_mst_rsp_arr_tb_t is xbar_rsp_arr_t(0 to nr_mst_c-1)(rdata(data_width_c-1 downto 0));
  subtype xbar_slv_rsp_arr_tb_t is xbar_rsp_arr_t(0 to nr_slv_c-1)(rdata(data_width_c-1 downto 0));

  signal mst_req : xbar_mst_req_arr_tb_t;
  signal mst_rsp : xbar_mst_rsp_arr_tb_t;

  signal slv_req : xbar_slv_req_arr_tb_t;
  signal slv_rsp : xbar_slv_rsp_arr_tb_t;

begin

  duti0: entity work.xbar_2008
    generic map (
      log2_wsize_g => 9
   )
    port map (
      clk_i      => clk,
      reset_n_i  => reset_n,
      en_i       => '1',
      init_i     => '0',
      mst_req_i  => mst_req,
      mst_rsp_o  => mst_rsp,
      slv_rsp_i  => slv_rsp,
      slv_req_o  => slv_req,
      wait_req_o => open
   );

  ------------------------------------------------------------------------------
  -- clock and reset
  ------------------------------------------------------------------------------
  clk           <= not clk after clk_cycle_c/2 when sim_done = false;
  reset_n       <= '1' after 500 ns;

   ------------------------------------------------------------------------------
  -- stimuli
  ------------------------------------------------------------------------------
  stim0: process is
  begin
    wait until reset_n = '1';
    wait until rising_edge(clk);
    
    wait for 2 us;

    -- quit simulation
    wait for 10 us;
    sim_done <= true;
    assert false report "Simulation finished successfully!" severity failure;
    wait;
  end process stim0;


end architecture beh;

