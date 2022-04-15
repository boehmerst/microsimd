library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.func_pkg.all;

entity mul_inferred is
  generic (
    a_width_g    : positive;
    b_width_g    : positive;
    num_stages_g : positive := 1
  );
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;
    en_i      : in  std_ulogic;
    init_i    : in  std_ulogic;
    sign_i    : in  std_ulogic;
    a_i       : in  std_ulogic_vector(a_width_g-1 downto 0);
    b_i       : in  std_ulogic_vector(b_width_g-1 downto 0);
    product_o : out std_ulogic_vector(a_width_g + b_width_g-1 downto 0)
  );
end entity mul_inferred;

architecture rtl of mul_inferred is

  subtype resw_t is  std_ulogic_vector(a_width_g + b_width_g-1 downto 0);
  type pipe_t is array (num_stages_g-1 downto 0) of resw_t;
  constant dflt_pipe_c : pipe_t := (others=>(others=>'0'));
  
  type reg_t is record
    pipe : pipe_t;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    pipe => dflt_pipe_c
  );
  
  signal r, rin : reg_t;

begin
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, sign_i, a_i, b_i) is
    variable v    : reg_t;
    variable prod : resw_t;
  begin
    v := r;
    
    prod := mixed_mul(a_i, b_i, sign_i);
    
    if(num_stages_g = 1) then
      v.pipe(v.pipe'left) := prod;
    else
      v.pipe              := v.pipe(v.pipe'left-1 downto 0) & prod;
    end if;
    
    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    product_o <= r.pipe(r.pipe'left);
    
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

