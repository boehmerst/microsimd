library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.func_pkg.all;
use work.config_pkg.all;
use work.vec_data_pkg.all;

entity custom_inst0 is
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;
    en_i      : in  std_ulogic;
    init_i    : in  std_ulogic;
    start_i   : in  std_ulogic;
    mode_i    : in  std_ulogic;
    veca_i    : in  vec_data_t;
    vecb_i    : in  vec_data_t;
    resulta_o : out vec_data_t;
    resultb_o : out vec_data_t;
    ready_o   : out std_ulogic
  );
end entity custom_inst0;

architecture rtl of custom_inst0 is
  -----------------------------------------------------------------------------
  -- mode encoding
  -----------------------------------------------------------------------------
  constant mode_rot_c : std_ulogic := '0';
  constant mode_vec_c : std_ulogic := '1';

  -----------------------------------------------------------------------------
  -- static cordic configuration
  -----------------------------------------------------------------------------
  constant headroom_c          : natural := 2;
  constant vec_width_c         : integer := CFG_DMEM_WIDTH/2;
  constant phase_width_c       : integer := CFG_DMEM_WIDTH/2;
  constant phase_magnitude_c   : integer := 3;
  constant nr_stages_c         : integer := CFG_DMEM_WIDTH/2;
  constant cordic_register_c   : std_ulogic_vector(nr_stages_c-1 downto 0) := "0010010010010010";
  
  -----------------------------------------------------------------------------
  -- constants to control FSM
  -----------------------------------------------------------------------------
  constant vec_per_simd_c      : natural := (CFG_VREG_SLICES*CFG_DMEM_WIDTH)/(CFG_DMEM_WIDTH/2);
  constant int_load_cycles_c   : natural := vec_per_simd_c;
  constant int_delay_cycles_c  : natural := count_ones(cordic_register_c) - int_load_cycles_c;
  constant int_unload_cycles_c : natural := int_load_cycles_c;
  
  constant counter_width_c     : natural := log2ceil(max(int_load_cycles_c, int_delay_cycles_c));

  constant load_cycles_c       : unsigned(counter_width_c-1 downto 0) := to_unsigned(int_load_cycles_c-1,   counter_width_c);
  constant delay_cycles_c      : unsigned(counter_width_c-1 downto 0) := to_unsigned(int_delay_cycles_c-1,  counter_width_c);
  constant unload_cycles_c     : unsigned(counter_width_c-1 downto 0) := to_unsigned(int_unload_cycles_c-1, counter_width_c);

  constant std_zero_c          : std_ulogic := '0';

  -----------------------------------------------------------------------------
  -- barrel shift left
  -----------------------------------------------------------------------------
  function shift_left(v : in std_ulogic_vector; shift : in natural) return std_ulogic_vector is
    variable shifted : std_ulogic_vector(v'length-1 downto 0);
  begin
    shifted := v(v'left-shift downto 0) & (shift-1 downto 0 => '0');
    return shifted;
  end function shift_left;

  -----------------------------------------------------------------------------
  -- arithmetic barrel shift right
  -----------------------------------------------------------------------------
  function arith_shift_right(v : in std_ulogic_vector; shift : in natural) return std_ulogic_vector is
    variable result : std_ulogic_vector(v'length-1 downto 0);
  begin
    result := (v'left downto v'left-shift => v(v'left)) & v(v'left-1 downto shift);

    if(shift /= 0 and shift /= v'length-1) then -- round arg < -0.5 -> 0 
      if(v = (v'left-1 downto shift => '1') and v(shift-1) = '1') then
        result := (others=>'0');
      end if;
    end if;
    return result;
  end function arith_shift_right;

  -----------------------------------------------------------------------------
  -- normalize input data
  -----------------------------------------------------------------------------
  procedure normalize(x, y : inout std_ulogic_vector; xnorm, ynorm : out std_ulogic_vector; shift : out unsigned) is
    variable signx      : std_ulogic;
    variable signy      : std_ulogic;
    variable xrev       : std_ulogic_vector(0 to x'length-headroom_c-1);
    variable yrev       : std_ulogic_vector(0 to y'length-headroom_c-1);
    variable ishift     : natural range 0 to x'length-headroom_c-1;
  begin
    signx := x(x'left);
    signy := y(y'left);

    xrev  := x(x'left-headroom_c downto 0); -- skip headroom
    yrev  := y(y'left-headroom_c downto 0); -- skip headroom

    --assert x(x'left downto x'left-headroom_c-x(x'left downto x'left)'length) = (x'left downto x'left-headroom_c-x(x'left downto x'left)'length => signx) report
    --  "Vector x violates headroom thus cannot be normalized" severity error;
    --assert y(y'left downto y'left-headroom_c-y(y'left downto y'left)'length) = (y'left downto y'left-headroom_c-y(y'left downto y'left)'length => signy) report
    --  "Vector y violates headroom thus cannot be normalized" severity error;

    cnt: for i in 1 to xrev'length-1 loop
      if(xrev(i) = x(x'left) and yrev(i) = y(y'left)) then
        ishift := i;
      end if;
    end loop cnt;

    shift := to_unsigned(ishift, log2ceil(x'length-headroom_c));
    xnorm := shift_left(x, ishift);
    ynorm := shift_left(y, ishift);
  end procedure normalize;

  type shift_array_t  is array(natural range<>) of unsigned(log2ceil(vec_width_c-headroom_c)-1 downto 0);
  type result_array_t is array(natural range<>) of vec_data_t;
  type state_t is (idle, load, delay, unload, done);
  
  type reg_t is record
    state   : state_t;
    count   : unsigned(counter_width_c-1 downto 0);
    ready   : std_ulogic;
    result  : result_array_t(0 to 1);
    core_en : std_ulogic;
    shift   : shift_array_t(0 to vec_per_simd_c-1);
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    state   => idle,
    count   => (others=>'0'),
    ready   => '1',
    result  => (others=>dflt_vec_data_c),
    core_en => '0',
    shift   => (others=>(others=>'0'))
  );

  signal core_xin   : std_ulogic_vector(vec_width_c-1 downto 0);
  signal core_yin   : std_ulogic_vector(vec_width_c-1 downto 0);
  signal core_zin   : std_ulogic_vector(phase_width_c-1 downto 0);
  signal core_mode  : std_ulogic;
  signal core_en    : std_ulogic;
  
  signal cordici0_x : std_ulogic_vector(vec_width_c-1 downto 0);
  signal cordici0_y : std_ulogic_vector(vec_width_c-1 downto 0);
  signal cordici0_z : std_ulogic_vector(phase_width_c-1 downto 0);
  
  signal r, rin     : reg_t;

begin
  ------------------------------------------------------------------------------
  -- cordic_core (last stage is not registered)
  ------------------------------------------------------------------------------
  cordici0: entity work.cordic_core
    generic map (
      vec_width_g       => vec_width_c,
      phase_width_g     => phase_width_c,
      phase_magnitude_g => phase_magnitude_c,
      nr_stages_g       => nr_stages_c,
      register_g        => cordic_register_c
    )
    port map (
      clk_i     => clk_i,
      reset_n_i => reset_n_i,
      en_i      => core_en,
      init_i    => std_zero_c,
      mode_i    => core_mode,
      x_i       => core_xin,
      y_i       => core_yin,
      z_i       => core_zin,
      x_o       => cordici0_x,
      y_o       => cordici0_y,
      z_o       => cordici0_z
    );
    
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, mode_i, start_i, veca_i, vecb_i, cordici0_x, cordici0_y, cordici0_z) is
    variable v     : reg_t;
    variable xin   : std_ulogic_vector(vec_width_c-1 downto 0);
    variable yin   : std_ulogic_vector(vec_width_c-1 downto 0);
    variable zin   : std_ulogic_vector(vec_width_c-1 downto 0);
    variable xnorm : std_ulogic_vector(vec_width_c-1 downto 0);
    variable ynorm : std_ulogic_vector(vec_width_c-1 downto 0);
  begin
    v := r;
    
    assert delay_cycles_c+1 > 0 report "Current implementation requires delay_cycles_c grater than zero"
      severity failure;
    
    ----------------------------------------------------------------------------
    -- NOTE: implies delay_cycles_c > 0
    ----------------------------------------------------------------------------
    case v.state is
      when idle   => if(start_i = '1') then
                       v.state   := load;
                       v.count   := load_cycles_c;
                       v.ready   := '0';
                       v.core_en := '1';
                     end if;
        
      when load   => if(r.count = 0) then
                       v.state   := delay;
                       v.count   := delay_cycles_c;
                     else
                       v.count   := r.count - 1;
                     end if;
        
      when delay  => if(r.count = 0) then
                       v.state   := unload;
                       v.count   := unload_cycles_c;
                     else
                       v.count   := r.count - 1;
                     end if;
        
      when unload => v.count     := r.count - 1;
                     if(v.count = 0) then
                       v.state   := done;
                       v.ready   := '1';
                       v.core_en := '0';
                     end if;
        
      when done   => v.state     := idle;
        
      when others => null;
    end case;
    
    ----------------------------------------------------------------------------
    -- normalize x and y input data
    ----------------------------------------------------------------------------
    xin := get_word(veca_i, v.count(log2ceil(vec_per_simd_c)-1 downto 0));
    yin := get_word(vecb_i, v.count(log2ceil(vec_per_simd_c)-1 downto 0));
    zin := get_word(vecb_i, v.count(log2ceil(vec_per_simd_c)-1 downto 0));
    normalize(xin, yin, xnorm, ynorm, v.shift(to_integer(v.count(log2ceil(vec_per_simd_c)-1 downto 0))));

    ----------------------------------------------------------------------------
    -- store results
    ----------------------------------------------------------------------------
    if(mode_i = mode_vec_c) then   
      v.result(0) := set_word(r.result(0), v.count(log2ceil(vec_per_simd_c)-1 downto 0), 
                      arith_shift_right(cordici0_x, to_integer(r.shift(to_integer(v.count(log2ceil(vec_per_simd_c)-1 downto 0))))));

      v.result(1) := set_word(r.result(1), v.count(log2ceil(vec_per_simd_c)-1 downto 0), cordici0_z);
    else
      v.result(0) := set_word(r.result(0), v.count(log2ceil(vec_per_simd_c)-1 downto 0), 
                      arith_shift_right(cordici0_y, to_integer(r.shift(to_integer(v.count(log2ceil(vec_per_simd_c)-1 downto 0))))));

      v.result(1) := set_word(r.result(1), v.count(log2ceil(vec_per_simd_c)-1 downto 0), cordici0_x);
    end if;

    ----------------------------------------------------------------------------
    -- drive cordic core
    ----------------------------------------------------------------------------
    core_xin  <= xnorm;
    core_yin  <= ynorm;
    core_zin  <= zin;
    core_mode <= mode_i;
    core_en   <= v.core_en;
    
    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    ready_o   <= r.ready;
    resulta_o <= r.result(0);
    resultb_o <= r.result(1);
    
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

