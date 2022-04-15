library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.func_pkg.all;
use work.core_pkg.all;
use work.config_pkg.all;
use work.vec_data_pkg.all;

entity simd_mul is
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;
    en_i      : in  std_ulogic;
    init_i    : in  std_ulogic;
    start_i   : in  std_ulogic;
    mul_i     : in  simd_mul_in_t;
    mul_o     : out simd_mul_out_t;
    ready_o   : out std_ulogic
  );
end entity simd_mul;

architecture rtl of simd_mul is

  type state_t is (idle, load, unload, done, ready);

  type count_t is record
    load      : unsigned(2 downto 0);
    unload    : unsigned(2 downto 0);
  end record count_t;
  constant dflt_count_c : count_t :=(
    load      => (others=>'0'),
    unload    => (others=>'0')
  );

  type reg_t is record
    state     : state_t;
    ready     : std_ulogic;
    calc      : std_ulogic;
    count     : count_t;
    mul_start : std_ulogic;
    data      : vec_data_t;
    mul_a     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    mul_b     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    mul_c     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    state     => idle,
    ready     => '1',
    calc      => '0',
    count     => dflt_count_c,
    mul_start => '0',
    data      => dflt_vec_data_c,
    mul_a     => (others=>'0'),
    mul_b     => (others=>'0'),
    mul_c     => (others=>'0')
  );

  signal mult      : mul32_in_t;
  signal muli0_mul : mul32_out_t;
  
  signal r, rin    : reg_t;

begin
  ------------------------------------------------------------------------------
  -- 32x32 multiplier core including accumulator
  ------------------------------------------------------------------------------
  muli0: entity work.mul32x32
    port map (
      clk_i     => clk_i,
      reset_n_i => reset_n_i,
      en_i      => en_i,
      init_i    => init_i,
      mul_i     => mult,
      mul_o     => muli0_mul
  );
  
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, mul_i, muli0_mul) is
    variable v        : reg_t;
    variable byte_a   : std_ulogic_vector( 7 downto 0);
    variable byte_b   : std_ulogic_vector( 7 downto 0);
    variable byte_c   : std_ulogic_vector( 7 downto 0);
    variable word_a   : std_ulogic_vector(15 downto 0);
    variable word_b   : std_ulogic_vector(15 downto 0);
    variable word_c   : std_ulogic_vector(15 downto 0);
  begin
    v := r;
    
    ----------------------------------------------------------------------------
    -- FSM
    ----------------------------------------------------------------------------
    case(v.state) is
      when idle   => if(start_i = '1') then
                       v.state            := load;
                       v.ready            := '0';
                       v.mul_start        := '1';
                       
                       case(mul_i.size) is
                         when BYTE   => 
                           v.count.load   := "111";
                           v.count.unload := "111";
                         when WORD   => 
                           v.count.load   := "011";
                           v.count.unload := "011";
                         when others => 
                           v.count.load   := "001";
                           v.count.unload := "001";
                       end case;
                       
                       case(mul_i.size) is
                         when BYTE   => 
                           byte_a         := get_byte(mul_i.op_a, v.count.load);
                           byte_b         := get_byte(mul_i.op_b, v.count.load);
                           byte_c         := get_byte(mul_i.op_c, v.count.load);
                       
                           if(mul_i.dt = S) then
                             v.mul_a      := sign_extend(byte_a, byte_a(7), v.mul_a'length);
                             v.mul_b      := sign_extend(byte_b, byte_b(7), v.mul_b'length);
                             v.mul_c      := sign_extend(byte_c, byte_c(7), v.mul_c'length);
                           else
                             v.mul_a      := sign_extend(byte_a, '0', v.mul_a'length);
                             v.mul_b      := sign_extend(byte_b, '0', v.mul_b'length);
                             v.mul_c      := sign_extend(byte_c, '0', v.mul_c'length);
                           end if;
                       
                         when WORD   => 
                           word_a         := get_word(mul_i.op_a, v.count.load(1 downto 0));
                           word_b         := get_word(mul_i.op_b, v.count.load(1 downto 0));
                           word_c         := get_word(mul_i.op_c, v.count.load(1 downto 0));
                       
                           if(mul_i.dt = S) then
                             v.mul_a      := sign_extend(word_a, word_a(15), v.mul_a'length);
                             v.mul_b      := sign_extend(word_b, word_b(15), v.mul_b'length);
                             v.mul_c      := sign_extend(word_c, word_c(15), v.mul_c'length);
                           else
                             v.mul_a      := sign_extend(word_a, '0', v.mul_a'length);
                             v.mul_b      := sign_extend(word_b, '0', v.mul_b'length);
                             v.mul_c      := sign_extend(word_c, '0', v.mul_c'length);
                           end if;
        
                         when others => 
                           v.mul_a        := get_double(mul_i.op_a, v.count.load(0 downto 0));
                           v.mul_b        := get_double(mul_i.op_b, v.count.load(0 downto 0));
                           v.mul_c        := get_double(mul_i.op_c, v.count.load(0 downto 0));
                        end case;
                       
                     end if;
      
      when load   => v.count.load         := v.count.load - 1;
                     case(mul_i.size) is

                       when BYTE   => 
                         byte_a           := get_byte(mul_i.op_a, v.count.load);
                         byte_b           := get_byte(mul_i.op_b, v.count.load);
                         byte_c           := get_byte(mul_i.op_c, v.count.load);
                       
                         if(mul_i.dt = S) then
                           v.mul_a        := sign_extend(byte_a, byte_a(7), v.mul_a'length);
                           v.mul_b        := sign_extend(byte_b, byte_b(7), v.mul_b'length);
                           v.mul_c        := sign_extend(byte_c, byte_c(7), v.mul_c'length);
                         else
                           v.mul_a        := sign_extend(byte_a, '0', v.mul_a'length);
                           v.mul_b        := sign_extend(byte_b, '0', v.mul_b'length);
                           v.mul_c        := sign_extend(byte_c, '0', v.mul_c'length);
                         end if;
                       
                       when WORD   => 
                         word_a           := get_word(mul_i.op_a, v.count.load(1 downto 0));
                         word_b           := get_word(mul_i.op_b, v.count.load(1 downto 0));
                         word_c           := get_word(mul_i.op_c, v.count.load(1 downto 0));
                       
                         if(mul_i.dt = S) then
                           v.mul_a        := sign_extend(word_a, word_a(15), v.mul_a'length);
                           v.mul_b        := sign_extend(word_b, word_b(15), v.mul_b'length);
                           v.mul_c        := sign_extend(word_c, word_c(15), v.mul_c'length);
                         else
                           v.mul_a        := sign_extend(word_a, '0', v.mul_a'length);
                           v.mul_b        := sign_extend(word_b, '0', v.mul_b'length);
                           v.mul_c        := sign_extend(word_c, '0', v.mul_c'length);
                         end if;
        
                       when others => 
                         v.mul_a          := get_double(mul_i.op_a, v.count.load(0 downto 0));
                         v.mul_b          := get_double(mul_i.op_b, v.count.load(0 downto 0));
                         v.mul_c          := get_double(mul_i.op_c, v.count.load(0 downto 0));
                     end case;
                       
                     if(v.count.load = 0) then
                       v.state            := unload;
                     end if;
                     
                     
                     if(muli0_mul.valid = '1') then
                       v.count.unload     := r.count.unload - 1;
                       
                       case(mul_i.size) is
                         when BYTE   => 
                           v.data         := set_byte(r.data, r.count.unload, muli0_mul.result(byte0)); 
                         when WORD   => 
                           v.data         := set_word(r.data, r.count.unload(1 downto 0), muli0_mul.result(word0));
                         when others => 
                           v.data         := set_double(r.data, r.count.unload(0 downto 0), muli0_mul.result(double0));
                       end case;
                     end if;
      
      when unload => v.count.unload       := r.count.unload - 1;
                     v.mul_start          := '0';
                     
                     if(r.count.unload = 0) then
                       v.state            := done;
                       v.ready            := '1';
                     end if;
                       
                     case(mul_i.size) is
                       when BYTE   => 
                         v.data           := set_byte(r.data, r.count.unload, muli0_mul.result(byte0)); 
                       when WORD   => 
                         v.data           := set_word(r.data, r.count.unload(1 downto 0), muli0_mul.result(word0));
                       when others => 
                         v.data           := set_double(r.data, r.count.unload(0 downto 0), muli0_mul.result(double0));
                     end case;
      
      when done   => v.state              := idle;

      when others => null;
    end case;
    
    ----------------------------------------------------------------------------
    -- drive multiplier
    ----------------------------------------------------------------------------
    mult.start   <= r.mul_start;
    mult.op_a    <= r.mul_a;
    mult.op_b    <= r.mul_b;
    mult.acc     <= std_ulogic_vector(resize(signed(r.mul_c), mult.acc'length));
    mult.long    <= mul_i.long;
    mult.op      <= mul_i.op;    
    mult.mac     <= mul_i.mac;
    mult.sign    <= mul_i.dt;
    
    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    mul_o.result <= r.data;
    ready_o      <= r.ready;
    
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

