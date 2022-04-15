library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.crossbar_pkg.all;
use work.func_pkg.all;

entity crossbar is
  generic (
    nr_mst_g      : positive;
    nr_slv_g      : positive;
    log2_window_g : positive range 1 to xbar_addr_width_c-2
  );
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;
    en_i      : in  std_ulogic;
    init_i    : in  std_ulogic;    
    mst_req_i : in  xbar_req_arr_t(0 to nr_mst_g-1);
    mst_rsp_o : out xbar_rsp_arr_t(0 to nr_mst_g-1);
    slv_req_o : out xbar_req_arr_t(0 to nr_slv_g-1);
    slv_rsp_i : in  xbar_rsp_arr_t(0 to nr_slv_g-1)
  );
end entity crossbar;

architecture rtl of crossbar is
  ------------------------------------------------------------------------------
  -- address decoding
  ------------------------------------------------------------------------------
  function addr_decode(addr : std_ulogic_vector(xbar_addr_width_c-1 downto 0); sel : in std_ulogic) return std_ulogic_vector is
    variable sel_bin  : std_ulogic_vector(log2ceil(nr_slv_g)-1 downto 0);
    variable addr_sel : std_ulogic_vector(nr_slv_g-1 downto 0);
  begin
    sel_bin         := addr(log2ceil(nr_slv_g)+log2_window_g-1 downto log2_window_g);
    slv0: for i in 0 to nr_slv_g-1 loop
      if(sel_bin = std_ulogic_vector(to_unsigned(i, sel_bin'length))) then
        addr_sel(i) := sel;
      else
        addr_sel(i) := '0';
      end if;
    end loop slv0;
    return addr_sel;
  end function addr_decode;
  
  ------------------------------------------------------------------------------
  -- slave and master side array types
  ------------------------------------------------------------------------------
  type slv_vec_arr_t is array(natural range 0 to nr_slv_g-1) of std_ulogic_vector(nr_mst_g-1 downto 0);
  type mst_vec_arr_t is array(natural range 0 to nr_mst_g-1) of std_ulogic_vector(nr_slv_g-1 downto 0);
  type slv_arr_t     is array(natural range 0 to nr_slv_g-1) of std_ulogic;
  type mst_arr_t     is array(natural range 0 to nr_mst_g-1) of std_ulogic;
  
  type slv_val_arr_t is array(natural range 0 to nr_slv_g-1) of std_ulogic_vector(log2ceil(nr_mst_g)-1 downto 0);
  type mst_val_arr_t is array(natural range 0 to nr_mst_g-1) of std_ulogic_vector(log2ceil(nr_slv_g)-1 downto 0);
  
  ------------------------------------------------------------------------------
  -- transform slave to master matrix representation
  ------------------------------------------------------------------------------
  function transform(slv_vec : in slv_vec_arr_t) return mst_vec_arr_t is
    variable mst_vec : mst_vec_arr_t;
  begin
    slv0: for slv in 0 to slv_vec'high loop
      mst0: for mst in 0 to mst_vec'high loop
        mst_vec(mst)(slv) := slv_vec(slv)(mst);
      end loop mst0;
    end loop slv0;
    return mst_vec;
  end function transform;
  
  ------------------------------------------------------------------------------
  -- transform master to slave matrix representation
  ------------------------------------------------------------------------------
  function transform(mst_vec : in mst_vec_arr_t) return slv_vec_arr_t is
    variable slv_vec : slv_vec_arr_t;
  begin
    mst0: for mst in 0 to mst_vec'high loop
      slv0: for slv in 0 to slv_vec'high loop
        slv_vec(slv)(mst) := mst_vec(mst)(slv);
      end loop slv0;
    end loop mst0;
    return slv_vec;
  end function transform; 

  ------------------------------------------------------------------------------
  -- declare interconnects
  ------------------------------------------------------------------------------
  signal arb_req            : slv_vec_arr_t;
  signal arbi0_comb_grant   : slv_vec_arr_t;
  signal arbi0_grant        : slv_vec_arr_t;
  signal arb_rsp            : mst_vec_arr_t;
  signal arb_ack            : slv_arr_t;
  
  signal slv_sel            : mst_vec_arr_t;
  signal slv_sel_bin        : mst_val_arr_t;
  signal rsp_mux_seli0_sel  : mst_val_arr_t;
   
  signal mst_sel_bin        : slv_val_arr_t;
  signal grant_bin          : slv_val_arr_t;
  signal mst_req_mux        : xbar_req_arr_t(0 to nr_slv_g-1);
  signal slv_rsp_mux        : xbar_rsp_arr_t(0 to nr_mst_g-1);
  
  signal ready_in           : mst_arr_t;
  signal mst_ready_in       : slv_arr_t;
  signal grant_ready_in     : slv_arr_t;
  
  signal mst_ctrli0_slv_req : xbar_req_arr_t(0 to nr_mst_g-1);
  signal slv_ctrli0_mst_rsp : xbar_rsp_arr_t(0 to nr_slv_g-1);
  
begin
  ------------------------------------------------------------------------------
  -- master-side logic
  ------------------------------------------------------------------------------
  arb_rsp <= transform(arbi0_grant);
  
  master_sidei0: for mst in 0 to nr_mst_g-1 generate
    
    -- address decoder
    slv_sel(mst)     <= addr_decode(mst_ctrli0_slv_req(mst).addr, mst_ctrli0_slv_req(mst).en);
    slv_sel_bin(mst) <= msbset(slv_sel(mst));
    
    -- generate select for response multiplexor 
    rsp_mux_seli: block is
      port (
        clk_i       : in  std_ulogic;
        reset_n_i   : in  std_ulogic;
        en_i        : in  std_ulogic;
        init_i      : in  std_ulogic;
        sel_i       : in  std_ulogic_vector(log2ceil(nr_slv_g)-1 downto 0);
        sel_o       : out std_ulogic_vector(log2ceil(nr_slv_g)-1 downto 0);
        ready_i     : in  std_ulogic
      );
      
      port map (
        clk_i       => clk_i,
        reset_n_i   => reset_n_i,
        en_i        => en_i,
        init_i      => init_i,
        sel_i       => slv_sel_bin(mst),
        sel_o       => rsp_mux_seli0_sel(mst),
        ready_i     => slv_rsp_mux(mst).ready
      );
      
      type reg_t is record
        sel : std_ulogic_vector(sel_i'length-1 downto 0);
      end record reg_t;
      constant dflt_reg_c : reg_t :=(
        sel => (others=>'0')
      );
      
      signal r, rin : reg_t;
    begin
      --------------------------------------------------------------------------
      -- comb0
      --------------------------------------------------------------------------    
      comb0: process(r, sel_i, ready_i) is
        variable v : reg_t;
      begin
        v := r;
        if(ready_i = '1') then
          v.sel := sel_i;
        end if;
        sel_o <= r.sel;
        rin   <= v;
      end process comb0;
      
      --------------------------------------------------------------------------
      -- sync0
      --------------------------------------------------------------------------
      sync0: process(reset_n_i, clk_i) is
      begin
        if(reset_n_i = '0') then
          r <= dflt_reg_c;
        elsif(rising_edge(clk_i)) then
          if(en_i = '1') then
            if(init_i = '1') then
              r <= dflt_reg_c;
            else
              r <= rin;
            end if;
          end if;
        end if; 
      end process sync0;      
    end block rsp_mux_seli;
    
    -- response multiplexor
    slv_rsp_mux(mst) <= xbar_rsp_mux(slv_ctrli0_mst_rsp, rsp_mux_seli0_sel(mst));
    ready_in(mst)    <= slv_rsp_mux(mst).ready;
  
  
    -- master controller
    mst_ctrli: block is
      port (
        clk_i       : in  std_ulogic;
        reset_n_i   : in  std_ulogic;
        en_i        : in  std_ulogic;
        init_i      : in  std_ulogic;            
        mst_req_i   : in  xbar_req_t;
        mst_rsp_o   : out xbar_rsp_t;
        slv_req_o   : out xbar_req_t;
        slv_rsp_i   : in  xbar_rsp_t;
        arb_grant_i : in  std_ulogic
      );

      port map (
        clk_i       => clk_i,
        reset_n_i   => reset_n_i,
        en_i        => en_i,
        init_i      => init_i,
        mst_req_i   => mst_req_i(mst),
        mst_rsp_o   => mst_rsp_o(mst),
        slv_req_o   => mst_ctrli0_slv_req(mst),
        slv_rsp_i   => slv_rsp_mux(mst),
        arb_grant_i => v_or(arb_rsp(mst))
      );
       
      type reg_t is record
        latch : xbar_req_t;
      end record reg_t;
      constant dflt_reg_c : reg_t :=(
        latch => dflt_xbar_req_c
      );
      
      signal r, rin : reg_t;
    begin
      --------------------------------------------------------------------------
      -- comb0
      --------------------------------------------------------------------------
      comb0: process(r, mst_req_i, arb_grant_i, slv_rsp_i) is
        variable v     : reg_t;
        variable grant : std_ulogic;
      begin
        v := r;
        
        ------------------------------------------------------------------------
        -- latch request just in case access won't be granted
        ------------------------------------------------------------------------        
        grant := not r.latch.en or arb_grant_i;       
        if(grant = '1') then
          v.latch := mst_req_i;
        end if;
        
        ------------------------------------------------------------------------
        -- drive module output
        ------------------------------------------------------------------------
        slv_req_o       <= v.latch;
        mst_rsp_o.rdata <= slv_rsp_i.rdata;
        mst_rsp_o.ready <= slv_rsp_i.ready and grant;
        
        rin <= v;
      end process comb0;
      
      --------------------------------------------------------------------------
      -- sync0
      --------------------------------------------------------------------------
      sync0: process(reset_n_i, clk_i) is
      begin
        if(reset_n_i = '0') then
          r <= dflt_reg_c;
        elsif(rising_edge(clk_i)) then
          if(en_i = '1') then
            if(init_i = '1') then
              r <= dflt_reg_c;
            else
              r <= rin;
            end if;
          end if;
        end if; 
      end process sync0;
    end block mst_ctrli;
  end generate master_sidei0;
  
  ------------------------------------------------------------------------------
  -- slave-side logic
  ------------------------------------------------------------------------------
  arb_req <= transform(slv_sel);
     
  slave_sidei0: for slv in 0 to nr_slv_g-1 generate
  
    -- check if current address phase master is still busy with previous transfer
    mst_ready_in(slv) <= ready_in(to_integer(unsigned(mst_sel_bin(slv))));
  
    -- acknowledge arbitration if current data phase master is signaled ready
    grant_bin(slv)      <= msbset(arbi0_grant(slv));
    grant_ready_in(slv) <= ready_in(to_integer(unsigned(grant_bin(slv))));
    arb_ack(slv)        <= grant_ready_in(slv);
  
    arbi : entity work.round_robin_arb
      generic map (
        cnt_g        => nr_mst_g
      )
      port map (
        clk_i        => clk_i,
        reset_n_i    => reset_n_i,
        en_i         => en_i,
        init_i       => init_i,
        req_i        => arb_req(slv),
        ack_i        => arb_ack(slv),
        grant_comb_o => arbi0_comb_grant(slv),
        grant_o      => arbi0_grant(slv)
      );
      
    -- request mux to select currently granted master if any access is requested
    mst_sel_bin(slv)  <= msbset(arbi0_comb_grant(slv));
    mst_req_mux(slv)  <= xbar_req_mux(mst_ctrli0_slv_req, mst_sel_bin(slv), v_or(arb_req(slv)));
      
    -- slave controller
    slv_ctrli: block is
      port (
        clk_i       : in  std_ulogic;
        reset_n_i   : in  std_ulogic;
        en_i        : in  std_ulogic;
        init_i      : in  std_ulogic;
        mst_req_i   : in  xbar_req_t;
        mst_rsp_o   : out xbar_rsp_t;
        slv_req_o   : out xbar_req_t;
        slv_rsp_i   : in  xbar_rsp_t;
        mst_ready_i : in  std_ulogic
      );
      port map (
        clk_i       => clk_i,
        reset_n_i   => reset_n_i,
        en_i        => en_i,
        init_i      => init_i,
        mst_req_i   => mst_req_mux(slv),
        mst_rsp_o   => slv_ctrli0_mst_rsp(slv),
        slv_req_o   => slv_req_o(slv),
        slv_rsp_i   => slv_rsp_i(slv),
        mst_ready_i => mst_ready_in(slv)
      );
      
    begin
      --------------------------------------------------------------------------
      -- comb0
      --------------------------------------------------------------------------
      comb0: process(mst_req_i, slv_rsp_i, mst_ready_i) is
        variable slv_req : xbar_req_t;
        variable mst_rsp : xbar_rsp_t;
      begin
        ------------------------------------------------------------------------
        -- mask off request as long as master did not complete previous transfer
        ------------------------------------------------------------------------
        slv_req      := mst_req_i;
        if(mst_ready_i = '0') then
          slv_req.en := '0';
        end if;

        mst_rsp      := slv_rsp_i;
        
        ------------------------------------------------------------------------
        -- drive output
        ------------------------------------------------------------------------
        mst_rsp_o <= mst_rsp;
        slv_req_o <= slv_req;
      end process comb0;
    end block slv_ctrli;
  end generate slave_sidei0;

end architecture rtl;

