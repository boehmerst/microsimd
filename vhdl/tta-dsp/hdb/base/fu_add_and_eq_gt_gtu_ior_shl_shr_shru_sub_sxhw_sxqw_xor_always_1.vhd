library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.func_pkg.all;


entity fu_add_and_eq_gt_gtu_ior_shl_shr_shru_sub_sxhw_sxqw_xor_always_1 is
  generic (
    dataw  : integer := 32;
    shiftw : integer := 5
  );
  port (
    t1data   : in std_logic_vector (dataw-1 downto 0);
    t1opcode : in std_logic_vector (3 downto 0);
    t1load   : in std_logic;

    o1data   : in std_logic_vector (dataw-1 downto 0);
    o1load   : in std_logic;

    r1data   : out std_logic_vector (dataw-1 downto 0);
    glock    : in  std_logic;
    rstx     : in  std_logic;
    clk      : in  std_logic
  );
end entity fu_add_and_eq_gt_gtu_ior_shl_shr_shru_sub_sxhw_sxqw_xor_always_1;


architecture rtl of fu_add_and_eq_gt_gtu_ior_shl_shr_shru_sub_sxhw_sxqw_xor_always_1 is

  constant OPC_ADD  : natural range 0 to 12 :=  0;
  constant OPC_AND  : natural range 0 to 12 :=  1;
  constant OPC_EQ   : natural range 0 to 12 :=  2;
  constant OPC_GT   : natural range 0 to 12 :=  3;
  constant OPC_GTU  : natural range 0 to 12 :=  4;
  constant OPC_IOR  : natural range 0 to 12 :=  5;
  constant OPC_SHL  : natural range 0 to 12 :=  6;
  constant OPC_SHR  : natural range 0 to 12 :=  7;
  constant OPC_SHRU : natural range 0 to 12 :=  8;
  constant OPC_SUB  : natural range 0 to 12 :=  9; 
  constant OPC_SXHW : natural range 0 to 12 := 10;
  constant OPC_SXQW : natural range 0 to 12 := 11;
  constant OPC_XOR  : natural range 0 to 12 := 12;

  type reg_t is record
    o1data : std_logic_vector(dataw-1 downto 0);
    r1data : std_logic_vector(dataw-1 downto 0);
  end record reg_t;

  constant dflt_reg_c : reg_t := (
    o1data => (others => '0'),
    r1data => (others => '0')
  );

  signal clk_en : std_logic;
  signal r, rin : reg_t;

begin

  comb0: process(r, t1data, t1opcode, o1data, o1load) 
    variable v          : reg_t;
    variable opcode     : natural range 0 to 12;
    variable zero       : std_logic;
    variable sign_bits  : std_logic_vector(2 downto 0);
    variable carry      : std_logic;
    variable carry_out  : std_logic;
    variable overflow   : std_logic;
    variable negative   : std_logic;
    variable alu_src_a  : std_logic_vector(dataw-1 downto 0);
    variable alu_src_b  : std_logic_vector(dataw-1 downto 0);
    variable result_add : std_logic_vector(dataw-1 downto 0);
  begin
    v := r;

    if o1load = '1' then
      v.o1data  := o1data;
    end if;

    alu_src_a   := t1data;
    alu_src_b   := v.o1data;
    carry       := '0';

    opcode      := to_integer(unsigned(t1opcode));

    if (opcode = OPC_SUB) or (opcode = OPC_EQ) or (opcode = OPC_GT) or opcode = OPC_GTU then
      alu_src_b :=  not v.o1data;
      carry     := '1';
    end if;

    result_add  := add(alu_src_a, alu_src_b, carry);

    case(sign_bits) is
      when "001" | "010" | "011" | "111" 
                  => carry_out := '1';
      when others => carry_out := '0';
    end case;

    zero        := is_zero(result_add(result_add'left-1 downto 0));
    sign_bits   := result_add(result_add'left) & alu_src_a(alu_src_a'left) & alu_src_b(alu_src_b'left);
    negative    := result_add(result_add'left);
    overflow    := (    result_add(result_add'left) and not alu_src_a(alu_src_a'left) and not alu_src_b(alu_src_b'left)) or
                   (not result_add(result_add'left) and     alu_src_a(alu_src_a'left) and     alu_src_b(alu_src_b'left));

    case(sign_bits) is
      when "001" | "010" | "011" | "111" 
                  => carry_out := '1';
      when others => carry_out := '0';
    end case;

    if t1load = '1' then
      case opcode is
        when OPC_ADD  => v.r1data := result_add(dataw-1 downto 0);
        when OPC_AND  => v.r1data := alu_src_a and alu_src_b;
        when OPC_SUB  => v.r1data := result_add(dataw-1 downto 0);

        when OPC_EQ   => v.r1data := (0 => zero,                                     others => '0');
        when OPC_GT   => v.r1data := (0 => not zero and not (negative xor overflow), others => '0');
        when OPC_GTU  => v.r1data := (0 => not zero and carry_out,                   others => '0');

        when OPC_IOR  => v.r1data := alu_src_a or alu_src_b;
        when OPC_SHL  => v.r1data := shift_left( alu_src_b, alu_src_a(shiftw-1 downto 0)                           );
        when OPC_SHRU => v.r1data := shift_right(alu_src_b, alu_src_a(shiftw-1 downto 0), '0'                      );
        when OPC_SHR  => v.r1data := shift_right(alu_src_b, alu_src_a(shiftw-1 downto 0), alu_src_b(alu_src_b'left));

        when OPC_SXHW => v.r1data := sign_extend(alu_src_a(dataw/2-1 downto 0), alu_src_a(dataw/2-1), dataw);
        when OPC_SXQW => v.r1data := sign_extend(alu_src_a(dataw/4-1 downto 0), alu_src_a(dataw/4-1), dataw);
        when OPC_XOR  => v.r1data := alu_src_a xor alu_src_b;
        when others   => v.r1data := result_add;
      end case;
    end if;

    r1data <= r.r1data;

    rin    <= v;
  end process comb0;

  clk_en <= (not glock) and t1load;
  
  sync0: process(clk, rstx) 
  begin
    if rstx = '0' then
      r <= dflt_reg_c;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        r <= rin;
      end if;
    end if;
  end process sync0;


end architecture rtl;

