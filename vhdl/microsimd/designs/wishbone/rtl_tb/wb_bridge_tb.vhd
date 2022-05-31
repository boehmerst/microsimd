library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.crossbar_pkg.all;
use work.wishbone_pkg.all;

entity wb_bridge_tb is
end entity wb_bridge_tb;


architecture beh of wb_bridge_tb is

  signal sim_done       : boolean   := false;
  signal clk            : std_logic := '0';
  signal reset_n        : std_logic := '0';
  constant clk_cycle_c  : time      := 10 ns;

  constant data_width_c : positive  := 32;
  constant mem_size_c   : positive  := 8;

  type xbar_mst_t       is (mst0, mst1);
  type xbar_slv_t       is (mem0, mem1);

  signal dut_wb_req     : wb_req_arr_t(0 to 1) := (others => dflt_wb_req_c);
  signal dut_wb_rsp     : wb_rsp_arr_t(0 to 1);

  signal xbar_mst_req   : xbar_req_arr_t(0 to 1);
  signal xbar_mst_rsp   : xbar_rsp_arr_t(0 to 1);

  signal xbar_slv_req   : xbar_req_arr_t(0 to 1);
  signal xbar_slv_rsp   : xbar_rsp_arr_t(0 to 1);

begin
  ------------------------------------------------------------------------------
  -- clock and reset
  ------------------------------------------------------------------------------
  clk     <= not clk after clk_cycle_c/2 when sim_done = false;
  reset_n <= '1' after 500 ns;


  -----------------------------------------------------------------------------
  -- bridge 0
  -----------------------------------------------------------------------------
  duti0: entity work.wb_bridge
    generic map (
      reset_level_g => '0'
    )
    port map (
      wb_clk_i   => clk,
      wb_reset_i => reset_n,
      en_i       => '1',
      init_i     => '0',
      wb_req_i   => dut_wb_req(xbar_mst_t'pos(mst0)),
      wb_rsp_o   => dut_wb_rsp(xbar_mst_t'pos(mst0)),
      mem_req_o  => xbar_mst_req(xbar_mst_t'pos(mst0)),
      mem_rsp_i  => xbar_mst_rsp(xbar_mst_t'pos(mst0))
    );


  -----------------------------------------------------------------------------
  -- bridge 0
  -----------------------------------------------------------------------------
  duti1: entity work.wb_bridge
    generic map (
      reset_level_g => '0'
    )
    port map (
      wb_clk_i   => clk,
      wb_reset_i => reset_n,
      en_i       => '1',
      init_i     => '0',
      wb_req_i   => dut_wb_req(xbar_mst_t'pos(mst1)),
      wb_rsp_o   => dut_wb_rsp(xbar_mst_t'pos(mst1)),
      mem_req_o  => xbar_mst_req(xbar_mst_t'pos(mst1)),
      mem_rsp_i  => xbar_mst_rsp(xbar_mst_t'pos(mst1))
    );


  -----------------------------------------------------------------------------
  -- xbar
  -----------------------------------------------------------------------------
  xbari0: entity work.crossbar
    generic map (
      nr_mst_g      => 2,
      nr_slv_g      => 2,
      log2_window_g => mem_size_c  -- TODO: check if 32 or 8 Bit value
    )
    port map (
      clk_i     => clk,
      reset_n_i => reset_n,
      en_i      => '1',  
      init_i    => '0',
      mst_req_i => xbar_mst_req,
      mst_rsp_o => xbar_mst_rsp,
      slv_req_o => xbar_slv_req,
      slv_rsp_i => xbar_slv_rsp
    );


  ------------------------------------------------------------------------------
  -- 32 bit memory 0
  ------------------------------------------------------------------------------
  mem_block0: block is
    signal mem_dat : std_ulogic_vector(data_width_c-1 downto 0); 
    signal mem_we  : std_ulogic_vector(3 downto 0);
    signal mem_en  : std_ulogic;
  begin   
    mem_we <= xbar_slv_req(xbar_slv_t'pos(mem0)).sel when xbar_slv_req(xbar_slv_t'pos(mem0)).wr = '1' else "0000";
    mem_en <= xbar_slv_req(xbar_slv_t'pos(mem0)).en;    

    memi0 : entity work.sram_4en
      generic map (
        data_width_g => data_width_c,
        addr_width_g => mem_size_c-2
      )
      port map (
        clk_i  => clk,
        wre_i  => mem_we,
        ena_i  => mem_en,
        addr_i => xbar_slv_req(xbar_slv_t'pos(mem0)).addr(mem_size_c-1 downto 2),
        dat_i  => xbar_slv_req(xbar_slv_t'pos(mem0)).wdata,
        dat_o  => mem_dat
      );
    
     xbar_slv_rsp(xbar_slv_t'pos(mem0)).rdata <= mem_dat;
     xbar_slv_rsp(xbar_slv_t'pos(mem0)).ready <= '1';
  end block mem_block0;


  ------------------------------------------------------------------------------
  -- 32 bit memory 1
  ------------------------------------------------------------------------------
  mem_block1: block is
    signal mem_dat : std_ulogic_vector(data_width_c-1 downto 0); 
    signal mem_we  : std_ulogic_vector(3 downto 0);
    signal mem_en  : std_ulogic;
  begin   
    mem_we <= xbar_slv_req(xbar_slv_t'pos(mem1)).sel when xbar_slv_req(xbar_slv_t'pos(mem1)).wr = '1' else "0000";
    mem_en <= xbar_slv_req(xbar_slv_t'pos(mem1)).en;

    memi0 : entity work.sram_4en
      generic map (
        data_width_g => data_width_c,
        addr_width_g => mem_size_c-2
      )
      port map (
        clk_i  => clk,
        wre_i  => mem_we,
        ena_i  => mem_en,
        addr_i => xbar_slv_req(xbar_slv_t'pos(mem1)).addr(mem_size_c-1 downto 2),
        dat_i  => xbar_slv_req(xbar_slv_t'pos(mem1)).wdata,
        dat_o  => mem_dat
      );
    
     xbar_slv_rsp(xbar_slv_t'pos(mem1)).rdata <= mem_dat;
     xbar_slv_rsp(xbar_slv_t'pos(mem1)).ready <= '1';
  end block mem_block1;

  
  ------------------------------------------------------------------------------
  -- stimuli
  ------------------------------------------------------------------------------
  stim0: process is
  begin
    wait until reset_n = '1';
    wait until rising_edge(clk);


    dut_wb_req(xbar_mst_t'pos(mst0)).stb  <= '1';
    dut_wb_req(xbar_mst_t'pos(mst0)).cyc  <= '1';
    dut_wb_req(xbar_mst_t'pos(mst0)).sel  <= "1111";

    dut_wb_req(xbar_mst_t'pos(mst0)).adr  <= std_logic_vector(to_unsigned(64, dut_wb_req(xbar_mst_t'pos(mst0)).adr'length));
    dut_wb_req(xbar_mst_t'pos(mst0)).we   <= '1';
    dut_wb_req(xbar_mst_t'pos(mst0)).dat  <= x"abcdabcd";

    wait until rising_edge(clk);
    wait until rising_edge(clk);
    dut_wb_req(xbar_mst_t'pos(mst0)) <= dflt_wb_req_c;

    -- quit simulation
    wait for 100 us;
    sim_done <= true;
    assert false report "Simulation finished successfully!" severity failure;
    wait;
  end process stim0;


end architecture beh;


