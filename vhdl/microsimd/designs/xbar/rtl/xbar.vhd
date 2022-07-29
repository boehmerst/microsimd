library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library general;
use general.general_function_pkg.all;

library microsimd;
use microsimd.xbar_pkg.all;

entity xbar is
  generic (
    log2_wsize_g   : integer := 10;
    nr_mst_g       : integer :=  4;
    nr_slv_g       : integer :=  4
  );
  port (
    clk_i          : in  std_ulogic;
    reset_n_i      : in  std_ulogic;
    en_i           : in  std_ulogic;
    init_i         : in  std_ulogic;
    xbar_mst_req_i : in  xbar_req_arr_t(0 to nr_mst_g-1);
    xbar_mst_rsp_o : out xbar_rsp_arr_t(0 to nr_mst_g-1);
    xbar_slv_rsp_i : in  xbar_rsp_arr_t(0 to nr_slv_g-1);
    xbar_slv_req_o : out xbar_req_arr_t(0 to nr_slv_g-1);
    wait_req_o     : out std_ulogic
  );
end entity xbar;

architecture rtl of xbar is
  ------------------------------------------------------------------------------
  -- address decoding
  ------------------------------------------------------------------------------
  function addr_decode(addr : std_ulogic_vector(addr_width_c-1 downto 0)) return std_ulogic_vector is
    variable sel_bin  : std_ulogic_vector(log2ceil(nr_slv_g)-1 downto 0);
    variable addr_sel : std_ulogic_vector(nr_slv_g-1 downto 0);
  begin
    sel_bin         := addr(log2ceil(nr_slv_g)+log2_wsize_g-1 downto log2_wsize_g);

    slv0: for i in 0 to nr_slv_g-1 loop
      if(sel_bin = std_ulogic_vector(to_unsigned(i, sel_bin'length))) then
        addr_sel(i) := '1';
      else
        addr_sel(i) := '0';
      end if;
    end loop slv0;

    return addr_sel;
  end function addr_decode;

  ------------------------------------------------------------------------------
  -- number of bits set
  ------------------------------------------------------------------------------
  function nr_bits_set(vec : std_ulogic_vector) return unsigned is
    variable count : unsigned(log2ceil(vec'length) downto 0);
  begin
    count := (others=>'0');
    cnt_bits0: for i in 0 to vec'length-1 loop
      if(vec(i) = '1') then
        count := count + 1;
      end if;
    end loop cnt_bits0;
    return count;
  end function nr_bits_set;

  ------------------------------------------------------------------------------
  -- select master
  ------------------------------------------------------------------------------
  function sel_mst(mst: std_ulogic_vector) return std_ulogic_vector is
    variable result : std_ulogic_vector(mst'length-1 downto 0);
  begin
    result := (others=>'0');
    sel0: for i in 0 to mst'length-1 loop
      if(mst(i) = '1') then
        result(i) := '1';
        exit;
      end if;
    end loop sel0;
    return result;
  end function sel_mst;

  ------------------------------------------------------------------------------
  -- to binary
  ------------------------------------------------------------------------------
  function to_bin(mst: std_ulogic_vector) return integer is
    variable result : integer range 0 to mst'length-1;
  begin
    result := 0;
    bin0: for i in 0 to mst'length-1 loop
      if(mst(i) = '1') then
        result := i;
      end if;
    end loop bin0;
    return result;
  end function to_bin;


  type slv_sel_t is array(natural range 0 to nr_mst_g-1) of std_ulogic_vector(nr_slv_g-1 downto 0);
  constant dflt_slv_c : slv_sel_t := (others=>(others=>'0'));

  type mst_req_t is array(natural range 0 to nr_slv_g-1) of std_ulogic_vector(nr_mst_g-1 downto 0);
  constant dflt_mst_req_c : mst_req_t := (others=>(others=>'0'));

  type state_t is (single, multiple);
  type state_array_t is array(natural range 0 to nr_slv_g-1) of state_t;

  type reg_t is record
    state        : state_array_t;
    req_latch    : xbar_req_arr_t(0 to nr_mst_g-1);
    rsp_latch    : xbar_rsp_arr_t(0 to nr_mst_g-1);
    slv_wait_req : std_ulogic_vector(nr_slv_g-1 downto 0);
    wait_req     : std_ulogic;
    mst_req      : mst_req_t;
    curr_mst     : mst_req_t;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    state        => (others => single),
    req_latch    => (others => dflt_xbar_req_c),
    rsp_latch    => (others => dflt_xbar_rsp_c),
    slv_wait_req => (others => '0'),
    wait_req     => '0',
    mst_req      => dflt_mst_req_c,
    curr_mst     => dflt_mst_req_c
  );

  signal r, rin : reg_t;

begin
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, xbar_mst_req_i, xbar_slv_rsp_i) is
    variable v                : reg_t;
    variable slv_sel          : slv_sel_t;
    variable mst_req          : mst_req_t;
    variable xbar_mst_req_mux : xbar_req_arr_t(0 to nr_mst_g-1);
    variable xbar_mst_rsp_mux : xbar_rsp_arr_t(0 to nr_mst_g-1);
    variable xbar_slv_req_mux : xbar_req_arr_t(0 to nr_slv_g-1);
  begin
    v := r;

    ----------------------------------------------------------------------------
    -- request latch and mux
    ----------------------------------------------------------------------------  
    latch: for i in 0 to nr_mst_g-1 loop
      if(r.wait_req = '0') then
        v.req_latch(i) := xbar_mst_req_i(i);
      elsif(r.wait_req = '1' and xbar_mst_req_i(i).ctrl.en = '1' and r.req_latch(i).ctrl.en = '0') then
        v.req_latch(i) := xbar_mst_req_i(i);
      end if;
    end loop latch;
    
    xbar_mst_req_mux := v.req_latch;
    
    ----------------------------------------------------------------------------
    -- address decoder
    ----------------------------------------------------------------------------
    slv_sel := (others => (others => '0'));

    slv_sel0: for i in 0 to nr_mst_g-1 loop
      --slv_sel(i)      := (others=>'0');
      if(xbar_mst_req_mux(i).ctrl.en = '1') then
        slv_sel(i)    := addr_decode(xbar_mst_req_mux(i).ctrl.addr);
      end if;
      mst_req0: for j in 0 to nr_slv_g-1 loop
       mst_req(j)(i) := slv_sel(i)(j);
      end loop mst_req0;
    end loop slv_sel0;

    ----------------------------------------------------------------------------
    -- FSM
    ----------------------------------------------------------------------------
    slv_fsm0: for j in 0 to nr_slv_g-1 loop
      case v.state(j) is
        when single   => v.curr_mst(j)         := sel_mst(mst_req(j));
                         if(nr_bits_set(mst_req(j)) > 1) then
                           v.state(j)          := multiple;
                           v.mst_req(j)        := mst_req(j) and not v.curr_mst(j);
                           v.slv_wait_req(j)   := '1';
                         end if;

        when multiple => if(nr_bits_set(r.mst_req(j)) /= 0) then
                           v.curr_mst(j)       := sel_mst(r.mst_req(j));
                           v.mst_req(j)        := r.mst_req(j) and not v.curr_mst(j);
                           if(nr_bits_set(r.mst_req(j)) = 1) then
                             v.slv_wait_req(j) := '0';
                           end if;
                         else
                           v.state(j)          := single;
                           v.curr_mst(j)       := sel_mst(mst_req(j));
                           if(nr_bits_set(mst_req(j)) > 1) then
                             v.state(j)        := multiple;
                             v.curr_mst(j)     := sel_mst(mst_req(j));
                             v.mst_req(j)      := mst_req(j) and not v.curr_mst(j);
                             v.slv_wait_req(j) := '1';
                           end if;
                         end if;

        when others   => v.state(j)            := single;
      end case;
    end loop slv_fsm0;

    ----------------------------------------------------------------------------
    -- slave request mux
    ----------------------------------------------------------------------------
    slv_req_mux0: for j in 0 to nr_slv_g-1 loop
      xbar_slv_req_mux(j)           := xbar_mst_req_mux(to_bin(v.curr_mst(j)));

      if(slv_sel(to_bin(v.curr_mst(j)))(j) /= '1') then
        xbar_slv_req_mux(j).ctrl.en := '0';
      end if;

      xbar_slv_req_mux(j).ctrl.addr := std_ulogic_vector(resize(unsigned(xbar_mst_req_mux(to_bin(v.curr_mst(j))).ctrl.addr(log2_wsize_g-1 downto 0)), 
                                         xbar_slv_req_mux(j).ctrl.addr'length));
    end loop slv_req_mux0;

    ----------------------------------------------------------------------------
    -- result latch / mux
    ----------------------------------------------------------------------------
    res_latch0: for i in 0 to nr_mst_g-1 loop
      curr_mst0: for j in 0 to nr_slv_g-1 loop
        if(r.curr_mst(j)(i) = '1') then
          v.rsp_latch(i) := xbar_slv_rsp_i(j);
        end if;
      end loop curr_mst0;   
    end loop res_latch0;

    xbar_mst_rsp_mux     := v.rsp_latch;
    if(r.wait_req = '1') then
      xbar_mst_rsp_mux   := r.rsp_latch;
    end if;

    ----------------------------------------------------------------------------
    -- generate global wait if one slave detects multiple requests
    ----------------------------------------------------------------------------
    v.wait_req           := '0';
    if(unsigned(v.slv_wait_req) /= 0) then
      v.wait_req         := '1';
    end if;

    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    wait_req_o     <= r.wait_req;
    xbar_slv_req_o <= xbar_slv_req_mux;
    xbar_mst_rsp_o <= xbar_mst_rsp_mux;

    rin <= v;
  end process comb0;

  ------------------------------------------------------------------------------
  -- sync0
  ------------------------------------------------------------------------------
  sync0: process(clk_i, reset_n_i) is
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

