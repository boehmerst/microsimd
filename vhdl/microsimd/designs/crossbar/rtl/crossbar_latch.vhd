library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.crossbar_pkg.all;

entity crossbar_latch is
  generic (
    nr_mst_g  : positive
  );
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;
    en_i      : in  std_ulogic;
    init_i    : in  std_ulogic;
    mst_req_i : in  xbar_req_arr_t(0 to nr_mst_g-1);
    mst_rsp_o : out xbar_rsp_arr_t(0 to nr_mst_g-1);
    slv_rsp_i : in  xbar_rsp_arr_t(0 to nr_mst_g-1)
 );
end entity crossbar_latch;

architecture rtl of crossbar_latch is

  type mst_rsp_data_arr_t is array(natural range 0 to nr_mst_g-1) of std_ulogic_vector(dflt_xbar_rsp_c.rdata'range);

  type reg_t is record
    mst_rsp : mst_rsp_data_arr_t;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    mst_rsp => (others=>(others=>'0'))
  );
  
  signal r, rin : reg_t;
  
begin
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, mst_req_i, slv_rsp_i) is
    variable v             : reg_t;
    variable rsp_mux       : mst_rsp_data_arr_t;
    variable global_ready : std_ulogic; 
  begin
    v := r;
    
    ----------------------------------------------------------------------------
    -- generate a global_ready, latch any slave response and mux accordingly
    ----------------------------------------------------------------------------
    global_ready       := '1';
    and_reduce0: for slv in 0 to nr_mst_g-1 loop
      global_ready     := global_ready and slv_rsp_i(slv).ready;
      if(slv_rsp_i(slv).ready = '1') then
        v.mst_rsp(slv) := slv_rsp_i(slv).rdata;
      end if;
    end loop and_reduce0;
    
    rsp_mux            := v.mst_rsp;
    if(global_ready = '0') then
      rsp_mux          := r.mst_rsp;
    end if;
    
    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    assign0: for mst in 0 to nr_mst_g-1 loop
      mst_rsp_o(mst) <= (rdata => rsp_mux(mst), ready => global_ready);
    end loop assign0;
    
    rin <= v;
  end process comb0;

  ------------------------------------------------------------------------------
  -- sync0
  ------------------------------------------------------------------------------
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
end architecture rtl;


