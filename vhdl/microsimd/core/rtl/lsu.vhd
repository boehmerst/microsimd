library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.func_pkg.all;
use work.core_pkg.all;
use work.vec_data_pkg.all;

entity lsu is
  port (
    clk_i       : in  std_ulogic;
    reset_n_i   : in  std_ulogic;
    init_i      : in  std_ulogic;
    wait_n_i    : in  std_ulogic;
    core_dmem_i : in  dmem_out_t;
    core_dmem_o : out dmem_in_t;
    lsu_dmem_o  : out scu_dmem_out_t;
    lsu_dmem_i  : in  scu_dmem_in_t;
    wait_n_o    : out std_ulogic
  );
end entity lsu;

architecture rtl of lsu is
  type reg_t is record
    count    : unsigned(log2ceil(CFG_VREG_SLICES)-1 downto 0);
    idx      : unsigned(log2ceil(CFG_VREG_SLICES)-1 downto 0);
    req      : scu_dmem_out_t;
    valid    : std_ulogic;
    --TODO: use same reg for read and write!
    vec_data : vec_data_t;
    latch    : vec_data_t;
    vec_req  : std_ulogic;
    sel      : std_ulogic_vector(1 downto 0);
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    count    => (others=>'0'),
    idx      => (others=>'0'),
    req      => dflt_scu_dmem_out_c,
    valid    => '1',
    vec_data => dflt_vec_data_c,
    latch    => dflt_vec_data_c,
    vec_req  => '0',
    sel      => "00"
  );
  
  signal r, rin : reg_t;
  
begin
  -----------------------------------------------------------------------------
  -- module output
  -----------------------------------------------------------------------------
  lsu_dmem_o           <= rin.req;
  core_dmem_o.scu.dat  <= lsu_dmem_i.dat;
  core_dmem_o.simd.dat <= rin.vec_data;
  wait_n_o             <= r.valid and wait_n_i;
  
  -----------------------------------------------------------------------------
  -- comb0
  -----------------------------------------------------------------------------
  comb0: process(r, core_dmem_i, lsu_dmem_i) is
    variable v         : reg_t;
  begin
    v := r;
    
    ---------------------------------------------------------------------------
    -- dmem request (scalar or vector) coming in ...
    ---------------------------------------------------------------------------   
    if(r.vec_req = '0') then
      if(core_dmem_i.scu.ena = '1') then
        v.req.adr   := core_dmem_i.scu.adr;
        v.req.dat   := core_dmem_i.scu.dat;
        v.req.we    := core_dmem_i.scu.we;
        v.req.sel   := core_dmem_i.scu.sel and (core_dmem_i.scu.we & core_dmem_i.scu.we & core_dmem_i.scu.we & core_dmem_i.scu.we);
        
      elsif(core_dmem_i.simd.ena = '1' and (core_dmem_i.simd.sel(0) xor core_dmem_i.simd.sel(1)) = '1') then
        -- TODO: special case working for 2 vector slices only
        v.req.adr   := core_dmem_i.simd.adr;
        v.req.we    := core_dmem_i.simd.we;
        v.req.sel   := (others=>core_dmem_i.simd.we);
        v.sel       := core_dmem_i.simd.sel;
                
        if(core_dmem_i.simd.sel(0) = '1') then
          v.req.dat := core_dmem_i.simd.dat(0);
        else
          v.req.dat := core_dmem_i.simd.dat(1);
        end if;
                
      elsif(core_dmem_i.simd.ena = '1' and (core_dmem_i.simd.sel(0) and core_dmem_i.simd.sel(1)) = '1') then
        v.sel       := core_dmem_i.simd.sel;
        v.vec_req   := '1';
        v.valid     := '0';
        v.req.adr   := core_dmem_i.simd.adr;
        v.req.dat   := core_dmem_i.simd.dat(0);
        v.req.we    := core_dmem_i.simd.we;
        v.req.sel   := (others=>core_dmem_i.simd.we);
        v.latch     := core_dmem_i.simd.dat;
      end if;
    end if;
    
    ---------------------------------------------------------------------------
    -- process further memory beats
    ---------------------------------------------------------------------------
    if(r.vec_req = '1') then
      v.vec_data(to_integer(r.idx)) := lsu_dmem_i.dat;
      
      v.req.adr     := std_ulogic_vector(unsigned(r.req.adr) + 4);
      v.idx         := r.idx + 1;
      v.count       := r.count + 1;
      v.req.dat     := r.latch(to_integer(v.idx));
      
      if(v.count = CFG_VREG_SLICES-1) then
        v.valid     := '1';
      end if;
      
      if(r.count = CFG_VREG_SLICES-1) then
        v.vec_req   := '0';
        v.idx       := (others=>'0');
        ------------------------------------------------------------------------
        -- check for next transfer (scalar or vector)
        ------------------------------------------------------------------------
        if(core_dmem_i.scu.ena = '1') then
          v.req.adr   := core_dmem_i.scu.adr;
          v.req.dat   := core_dmem_i.scu.dat;
          v.req.we    := core_dmem_i.scu.we;
          v.req.sel   := core_dmem_i.scu.sel and (core_dmem_i.scu.we & core_dmem_i.scu.we & core_dmem_i.scu.we & core_dmem_i.scu.we);
        
        elsif(core_dmem_i.simd.ena = '1' and (core_dmem_i.simd.sel(0) xor core_dmem_i.simd.sel(1)) = '1') then
          v.req.adr   := core_dmem_i.simd.adr;
          v.req.we    := core_dmem_i.simd.we;
          v.req.sel   := (others=>core_dmem_i.simd.we);
          v.sel       := core_dmem_i.simd.sel;
                
          if(core_dmem_i.simd.sel(0) = '1') then
            v.req.dat := core_dmem_i.simd.dat(0);
          else
            v.req.dat := core_dmem_i.simd.dat(1);
          end if;
                
        elsif(core_dmem_i.simd.ena = '1' and (core_dmem_i.simd.sel(0) and core_dmem_i.simd.sel(1)) = '1') then
          v.sel       := core_dmem_i.simd.sel;
          v.vec_req   := '1';
          v.valid     := '0';
          v.req.adr   := core_dmem_i.simd.adr;
          v.req.dat   := core_dmem_i.simd.dat(0);
          v.req.we    := core_dmem_i.simd.we;
          v.req.sel   := (others=>core_dmem_i.simd.we);
          v.latch     := core_dmem_i.simd.dat;
        end if;
      end if;
    end if;
    
    v.req.ena                       := v.vec_req or core_dmem_i.scu.ena;
    
    if(r.sel = "11" ) then
      v.vec_data(CFG_VREG_SLICES-1) := lsu_dmem_i.dat;
    elsif(r.sel(0) = '1') then
      v.vec_data(0)                 := lsu_dmem_i.dat;
    else
      v.vec_data(1)                 := lsu_dmem_i.dat;
    end if;
      
    rin <= v;
  end process comb0;
  
  -----------------------------------------------------------------------------
  -- sync0
  -----------------------------------------------------------------------------
  sync0: process(clk_i, reset_n_i) is
  begin
    if(reset_n_i = '0') then
      r <= dflt_reg_c;
    elsif(rising_edge(clk_i)) then
      if(wait_n_i = '1') then
        if(init_i = '1') then
          r <= dflt_reg_c;
        else
          r <= rin;
        end if;
      end if;
    end if;
  end process sync0;  
  
end architecture rtl;

