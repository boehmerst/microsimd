library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.func_pkg.all;
use work.core_pkg.all;

entity mul32x32 is
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;
    en_i      : in  std_ulogic;
    init_i    : in  std_ulogic;
    mul_i     : in  mul32_in_t;
    mul_o     : out mul32_out_t
  );
end entity mul32x32;

architecture rtl of mul32x32 is

  type acc_pipe_t is array(natural range 0 to 1) of std_ulogic_vector(31 downto 0);
  
  type flags_t is record
    byte   : std_ulogic;
    word   : std_ulogic;
    double : std_ulogic;
  end record flags_t;

  type reg_t is record
    valid_pipe : std_ulogic_vector(2 downto 0);
    sign       : std_ulogic_vector(1 downto 0);
    ready      : std_ulogic;
    acc_pipe   : acc_pipe_t;
    acc_result : std_ulogic_vector(63 downto 0);
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    valid_pipe => (others=>'0'),
    sign       => (others=>'0'),
    ready      => '0',
    acc_pipe   => (others=>(others=>'0')),
    acc_result => (others=>'0')
  );
  
  signal mult_a        : std_ulogic_vector(31 downto 0);
  signal mult_b        : std_ulogic_vector(31 downto 0);
  signal muli0_product : std_ulogic_vector(63 downto 0);
  
  signal r, rin : reg_t;

begin
  ------------------------------------------------------------------------------
  -- multiplier
  ------------------------------------------------------------------------------
  muli0: entity work.mul_inferred
    generic map (
      a_width_g    => 32,
      b_width_g    => 32,
      num_stages_g => 2
    )
    port map (
      clk_i        => clk_i,
      reset_n_i    => reset_n_i,
      en_i         => en_i,
      init_i       => init_i,
      sign_i       => '0',
      a_i          => mult_a,
      b_i          => mult_b,
      product_o    => muli0_product
    );
  
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, mul_i, muli0_product) is
    variable v          : reg_t;
    variable mul_a      : std_ulogic_vector(31 downto 0);
    variable mul_b      : std_ulogic_vector(31 downto 0);
    variable acc_a      : std_ulogic_vector(63 downto 0);
    variable acc_b      : std_ulogic_vector(63 downto 0);
    variable acc_result : std_ulogic_vector(63 downto 0);
    variable mul_result : std_ulogic_vector(31 downto 0);
    variable result     : std_ulogic_vector(63 downto 0);
    variable valid      : std_ulogic;
    variable ovflw      : mul32_flags_t;    
  begin
    v := r;
    
    ----------------------------------------------------------------------------
    -- internal delay pipes
    ----------------------------------------------------------------------------
    v.sign       := r.sign(r.sign'left-1 downto 0) & (mul_i.op_a(31) xor mul_i.op_b(31));
    v.valid_pipe := r.valid_pipe(r.valid_pipe'left-1 downto 0) & mul_i.start;
    
    v.acc_pipe   := mul_i.acc(31 downto 0) & r.acc_pipe(0 to r.acc_pipe'right-1);
    
    
    ----------------------------------------------------------------------------
    -- we internally use unsigned multiplication
    ----------------------------------------------------------------------------
    if(mul_i.op_a(31) = '1' and mul_i.sign = S) then
      mul_a      := std_ulogic_vector(not unsigned(mul_i.op_a) + 1);
    else
      mul_a      := mul_i.op_a;
    end if;
    
    if(mul_i.op_b(31) = '1' and mul_i.sign = S) then
      mul_b      := std_ulogic_vector(not unsigned(mul_i.op_b) + 1);
    else
      mul_b      := mul_i.op_b;
    end if;
    
    ----------------------------------------------------------------------------
    -- check overflow
    ----------------------------------------------------------------------------
    ovflw := dflt_mul32_flags_c;

    if(mul_i.sign = S) then
      -- actually doing unsigned multiply internally, and then negate on output as appropriate, 
      -- so if sign bit is set, then is overflow unless incoming signs differ and result is 2^(width-1)
      if( v_or(muli0_product(63 downto 32)) = '1' ) then
        ovflw.double := '1';
      elsif( muli0_product(31) = '1' and not (r.sign(r.sign'left) = '1' and v_or(muli0_product(30 downto 0)) = '0') ) then
        ovflw.double := '1';
      end if; 
    else
      ovflw.double   := v_or(muli0_product(63 downto 32));
    end if;
    
    if(mul_i.sign = S) then
      -- actually doing unsigned multiply internally, and then negate on output as appropriate, 
      -- so if sign bit is set, then is overflow unless incoming signs differ and result is 2^(width-1)
      if( v_or(muli0_product(63 downto 16)) = '1' ) then
        ovflw.word   := '1';
      elsif( muli0_product(15) = '1' and not (r.sign(r.sign'left) = '1' and v_or(muli0_product(14 downto 0)) = '0') ) then
        ovflw.word   := '1';
      end if; 
    else
      ovflw.word     := v_or(muli0_product(63 downto 16));
    end if;
    
    if(mul_i.sign = S) then
      -- actually doing unsigned multiply internally, and then negate on output as appropriate, 
      -- so if sign bit is set, then is overflow unless incoming signs differ and result is 2^(width-1)
      if( v_or(muli0_product(63 downto 8)) = '1' ) then
        ovflw.byte := '1';
      elsif( muli0_product(7) = '1' and not (r.sign(r.sign'left) = '1' and v_or(muli0_product(6 downto 0)) = '0') ) then
        ovflw.byte := '1';
      end if; 
    else
      ovflw.byte   := v_or(muli0_product(63 downto 8));
    end if;
    
    ----------------------------------------------------------------------------
    -- take sign into consideration
    ----------------------------------------------------------------------------
    if(r.sign(r.sign'left) = '1' and mul_i.sign = S) then
      mul_result := std_ulogic_vector(not unsigned(muli0_product(31 downto 0)) + 1);
    else
      mul_result := muli0_product(31 downto 0);
    end if;
    
    ----------------------------------------------------------------------------
    -- accumulattion supporting 64 bit non pipelined long
    ----------------------------------------------------------------------------
    if(mul_i.long = '1') then
      acc_a                 := mul_i.acc; 
    else
      acc_a(31 downto 0)    := r.acc_pipe(r.acc_pipe'left);
      
      if(mul_i.sign = S) then
        acc_a(63 downto 31) := (others=>r.acc_pipe(r.acc_pipe'left)(31));
      else
        acc_a(63 downto 31) := (others=>'0');
      end if;
      
    end if;
     
    acc_b(31 downto 0)      := mul_result;
      
    if(mul_i.sign = S) then
      acc_b(63 downto 31)   := (others=>mul_result(31));
    else
      acc_b(63 downto 31)   := (others=>'0');
    end if;
    
    if(mul_i.op = ADD) then
      acc_result := std_ulogic_vector(unsigned(acc_a) + unsigned(acc_b));
    else
      acc_result := std_ulogic_vector(unsigned(acc_a) - unsigned(acc_b));
    end if;
    
    v.acc_result := acc_result;
    
    ----------------------------------------------------------------------------
    -- result multiplexor
    ----------------------------------------------------------------------------
    if(mul_i.mac = '1') then
      result := r.acc_result;
      valid  := r.valid_pipe(r.valid_pipe'left);
    else
      result(31 downto 0)    := mul_result;
      
      if(mul_i.sign = S) then
        result(63 downto 31) := (others=>mul_result(31));
      else
        result(63 downto 31) := (others=>'0');
      end if;
      
      valid  := r.valid_pipe(r.valid_pipe'left-1);
    end if;
    
    ----------------------------------------------------------------------------
    -- drive multiplier
    ----------------------------------------------------------------------------
    mult_a <= mul_a;
    mult_b <= mul_b;
    
    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    mul_o.result <= result;
    mul_o.valid  <= valid;
    mul_o.ovflw  <= ovflw;
    
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

