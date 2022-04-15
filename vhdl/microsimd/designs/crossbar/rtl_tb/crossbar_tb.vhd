library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library osvvm;
use osvvm.CoveragePkg.all;

library work;
use work.func_pkg.all;
use work.crossbar_util_pkg.all;
use work.crossbar_pkg.all;

entity crossbar_tb is
end entity crossbar_tb;

architecture beh of crossbar_tb is
  constant clk_cycle_c           : time       := 10 ns;
  signal sim_done                : boolean    := false;
  signal clk                     : std_ulogic := '0';
  signal reset_n                 : std_ulogic := '0';
  
  constant nr_mst_c              : integer := 4;
  constant nr_slv_c              : integer := 8;
  constant log2_window_c         : integer := 6;
  constant cov_goal_c            : integer := 1000;
  constant max_requests_c        : integer := 16;
  
  type mst_index_t is (master0, master1);
  type slv_index_t is (slave0,  slave1);
  
  signal mst_req                 : xbar_req_arr_t(0 to nr_mst_c-1) := (others => dflt_xbar_req_c);
  signal slv_rsp                 : xbar_rsp_arr_t(0 to nr_slv_c-1);
  signal duti0_mst_rsp           : xbar_rsp_arr_t(0 to nr_mst_c-1);
  signal duti0_slv_req           : xbar_req_arr_t(0 to nr_slv_c-1);
  
begin
  ------------------------------------------------------------------------------
  -- clock and reset
  ------------------------------------------------------------------------------
  clk     <= not clk after clk_cycle_c/2 when sim_done = false;
  reset_n <= '1' after 50 ns;
  
  ------------------------------------------------------------------------------
  -- 2x2 crossbar switch
  ------------------------------------------------------------------------------
  duti0: entity work.crossbar
    generic map (
      nr_mst_g      => nr_mst_c,
      nr_slv_g      => nr_slv_c,
      log2_window_g => log2_window_c
    )
    port map (
      clk_i     => clk,
      reset_n_i => reset_n,
      en_i      => '1',
      init_i    => '0',
      mst_req_i => mst_req,
      mst_rsp_o => duti0_mst_rsp,
      slv_req_o => duti0_slv_req,
      slv_rsp_i => slv_rsp
    );
    
  ------------------------------------------------------------------------------
  -- dummy slaves
  ------------------------------------------------------------------------------
  gen_slv0: for i in 0 to nr_slv_c-1 generate
    slvi: block is
      generic (
        size_g    : in positive;
        delay_g   : in natural
      );
      
      generic map (
        size_g    => log2_window_c,
        delay_g   => i
      );
      
      port (
        clk_i     : in  std_ulogic;
        reset_n_i : in  std_ulogic;
        en_i      : in  std_ulogic;
        init_i    : in  std_ulogic;
        slv_req_i : in  xbar_req_t;
        slv_rsp_o : out xbar_rsp_t := dflt_xbar_rsp_c
      );
      
      port map (
        clk_i     => clk,
        reset_n_i => reset_n,
        en_i      => '1',
        init_i    => '0',
        slv_req_i => duti0_slv_req(i),
        slv_rsp_o => slv_rsp(i)
      );
      
    begin
      --------------------------------------------------------------------------
      -- slave0
      --------------------------------------------------------------------------
      slave0: process is
        type slv_mem_t is array(natural range 0 to 2**size_g-1) of std_ulogic_vector(slv_req_i.wdata'range);
        
        variable req : xbar_req_t;
        variable mem : slv_mem_t := (others=>x"deadbeef");
      begin
        wait until clk'event and clk = '1';
        if slv_req_i.en = '1' then
          req := slv_req_i;
          slv_rsp_o.ready <= '0', '1' after delay_g * clk_cycle_c + 1 ps;
          wait for delay_g * clk_cycle_c + 1 ps;
          if(req.wr = '1') then
            mem(to_integer(unsigned(req.addr(size_g-1 downto 0)))) := req.wdata;
          else
            slv_rsp_o.rdata <= mem(to_integer(unsigned(req.addr(size_g-1 downto 0)))), (others=>'0') after clk_cycle_c;
          end if;
        end if;
        wait for 0 ns;
      end process slave0;
    end block slvi;
  end generate gen_slv0;
  
  ------------------------------------------------------------------------------
  -- stimuli
  ------------------------------------------------------------------------------
  gen_stim0: for i in 0 to nr_mst_c-1 generate
    stim0: process is
      constant nr_addr_c  : integer := 2**log2_window_c;
      
      type local_mem_t is array(natural range <>) of std_ulogic_vector(dflt_xbar_req_c.wdata'range);
      variable local_mem  : local_mem_t(0 to (nr_slv_c * 2**log2_window_c) - 1) := (others=>x"deadbeef");
      variable rdata_mem  : local_mem_t(0 to max_requests_c-1);
      
      variable addr       : std_ulogic_vector(log2ceil(nr_slv_c)+log2_window_c-1 downto 0) := (others => '0');
      variable wdata      : std_ulogic_vector(dflt_xbar_req_c.wdata'range)                 := (others => '0');
      variable rdata      : std_ulogic_vector(dflt_xbar_rsp_c.rdata'range)                 := (others => '0');
      
      variable requests   : xbar_req_arr_t(0 to max_requests_c-1);
      variable responses  : xbar_rsp_arr_t(0 to max_requests_c-1);
      
      variable transfer_cov     : CovPType;
      variable addr_int         : integer;
      variable wdata_int        : integer;
      variable wdata_cov        : CovPType;
      variable wr_int           : integer;
      variable slv_int          : integer;
      variable transfer_cnt_int : integer;
      variable transfer_cnt_cov : CovPType;
      
   begin
      transfer_cov.SetName("transfer_cov" & integer'image(i));
      transfer_cov.AddCross(cov_goal_c, GenBin(0, nr_slv_c-1), GenBin(0, 1), GenBin(i*nr_addr_c/nr_mst_c, (i+1)*nr_addr_c/nr_mst_c-1));   
      
      wdata_cov.SetName("wdata_cov" & integer'image(i));
      wdata_cov.AddBins(1, GenBin(nr_addr_c/nr_mst_c, integer'low, integer'high, 1));
   
      transfer_cnt_cov.SetName("transfer_cov" & integer'image(i));
      transfer_cnt_cov.AddBins(cov_goal_c, GenBin(1, max_requests_c));
   
      wait until reset_n = '1';
      wait until rising_edge(clk);  
      
      --------------------------------------------------------------------------
      -- run until coverage
      --------------------------------------------------------------------------
      cov_loop0: while( wdata_cov.isCovered(100.0)        = false or transfer_cov.isCovered(100.0) = false or
                        transfer_cnt_cov.isCovered(100.0) = false ) loop
      
        transfer_cnt_int := transfer_cnt_cov.RandCovPoint;
        transfer_cnt_cov.iCover(transfer_cnt_int);
      
        ------------------------------------------------------------------------
        -- fill request array
        ------------------------------------------------------------------------
        requests0: for j in 0 to transfer_cnt_int-1 loop
          (slv_int, wr_int, addr_int) := transfer_cov.RandCovPoint;
          wdata_int                   := wdata_cov.RandCovPoint;
                  
          addr(log2ceil(nr_slv_c)+log2_window_c-1 downto log2_window_c) := std_ulogic_vector(to_unsigned(slv_int,  log2ceil(nr_slv_c)));
          addr(log2_window_c-1 downto 0)                                := std_ulogic_vector(to_unsigned(addr_int, log2_window_c));
        
          wdata := std_ulogic_vector(to_signed(wdata_int, wdata'length));
          
          if(wr_int = 1) then
            local_mem(to_integer(unsigned(addr))) := wdata;
            requests(j)  := (addr => std_ulogic_vector(resize(unsigned(addr), requests(j).addr'length)), wdata => wdata, en => '1', wr => '1', sel => (others=>'1'));
          else
            rdata_mem(j) := local_mem(to_integer(unsigned(addr)));
            requests(j)  := (addr => std_ulogic_vector(resize(unsigned(addr), requests(j).addr'length)), wdata => wdata, en => '1', wr => '0', sel => (others=>'1'));
          end if;
          
          transfer_cov.iCover((slv_int, wr_int, addr_int));
          wdata_cov.iCover(wdata_int);                   
        end loop requests0;
        
        wait for 0.0 ps;
        
        ------------------------------------------------------------------------
        -- execute memory access
        ------------------------------------------------------------------------      
        mem_access(requests, responses, transfer_cnt_int, mst_req(i), duti0_mst_rsp(i), clk);
        
        ------------------------------------------------------------------------
        -- compare read results with expected value
        ------------------------------------------------------------------------
        compare0: for j in 0 to transfer_cnt_int-1 loop
          if(requests(j).wr = '0') then
            assert rdata_mem(j) = responses(j).rdata report "Incorrect response data at response: " 
              & integer'image(j) & " : " & integer'image(to_integer(signed(rdata_mem(j)))) & " expected wheras " 
                                         & integer'image(to_integer(signed(responses(j).rdata))) & " received" severity error;
          end if;
        end loop compare0;
        
        wait for 200 ns;
      end loop cov_loop0;

      if(i = mst_index_t'pos(master0)) then
        wait for 100 ns;
        assert false report "Simulation finished successfully!" severity failure;
      end if;
      wait;
    end process stim0;
  end generate gen_stim0;
  
end architecture beh;

