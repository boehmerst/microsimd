library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.core_pkg.all;
use work.func_pkg.all;
use work.vec_data_pkg.all;

package simd_addsub32_pkg is

  constant simd_alu_add_c : std_ulogic := '0';
  constant simd_alu_sub_c : std_ulogic := '1';

  -----------------------------------------------------------------------------
  -- 32 bit add_sub with signed and unsigned saturation
  -----------------------------------------------------------------------------
  function simd_addsub32( a, b : std_ulogic_vector(31 downto 0); 
                          mode : simd_addsub_t; 
                          size : simd_size_t; 
                          dt   : simd_data_t;
                          sat  : std_ulogic) return std_ulogic_vector;

end package simd_addsub32_pkg;

package body simd_addsub32_pkg is

  type alu_flags_t is record
    carry              : std_ulogic;
    signed_pos_ovflw   : std_ulogic;
    signed_neg_ovflw   : std_ulogic;
    unsigned_pos_ovflw : std_ulogic;
    unsigned_neg_ovflw : std_ulogic;
  end record alu_flags_t;
  constant dflt_alu_flags_c : alu_flags_t :=(
    carry              => '0',
    signed_pos_ovflw   => '0',
    signed_neg_ovflw   => '0',
    unsigned_pos_ovflw => '0',
    unsigned_neg_ovflw => '0'
  );

  type add8_return_t is record
    sum                : std_ulogic_vector(7 downto 0);
    flags              : alu_flags_t;
  end record add8_return_t;
  constant dflt_add8_return_c : add8_return_t :=(
    sum                => (others=>'0'),
    flags              => dflt_alu_flags_c
  );

  type add8_return_arr_t is array(natural range 3 downto 0) of add8_return_t;
  
  -----------------------------------------------------------------------------
  -- 8 bit add_sub with signed and unsigned overflow detection
  -----------------------------------------------------------------------------
  function add8( a, b : std_ulogic_vector(7 downto 0); 
                 c    : std_ulogic; 
                 mode : simd_addsub_t) return add8_return_t is
    variable ain    : unsigned(7 downto 0);
    variable bin    : unsigned(7 downto 0);
    variable sum    : unsigned(7 downto 0);
    variable cin    : unsigned(0 downto 0);
    variable result : add8_return_t;
    variable bits   : std_ulogic_vector(2 downto 0);
  begin
    result          := dflt_add8_return_c;

    ain             := unsigned(a);
    bin             := unsigned(b);
    cin(0)          := c;

    sum             := ain + bin + cin;
    bits            := sum(7) & ain(7) & bin(7);

    case(bits) is
      when "001" | "010" | "011" | "111" 
                  => result.flags.carry := '1';
      when others => result.flags.carry := '0';
    end case;
    
    if(mode = ADD) then
      result.flags.unsigned_pos_ovflw := result.flags.carry;
    elsif(mode = SUB) then
      result.flags.unsigned_neg_ovflw := not result.flags.carry;
    end if;

    --result.flags.unsigned_pos_ovflw := result.flags.carry and not mode; -- only add can cause pos unsigned overflow    
    --result.flags.unsigned_neg_ovflw := not result.flags.carry and mode; -- only sub can cause neg unsigned overflow

    result.flags.signed_pos_ovflw   := bits(2)     and not bits(1) and not bits(0);
    result.flags.signed_neg_ovflw   := not bits(2) and bits(1)     and bits(0);

    result.sum                      := std_ulogic_vector(sum); 

    return result;
  end function add8;
  
  -----------------------------------------------------------------------------
  -- 8 bit unsigned saturation on each result + concatenation
  -----------------------------------------------------------------------------
  function usat8(res : add8_return_arr_t) return std_ulogic_vector is
    variable result_vec : std_ulogic_vector(31 downto 0);
  begin
    ---------------------------------------------------------------------------
    -- handle each byte individually
    ---------------------------------------------------------------------------
    sat: for i in 0 to 3 loop
      if(res(i).flags.unsigned_pos_ovflw = '1') then
        result_vec((i+1)*8-1 downto i*8) := x"FF";
      elsif(res(i).flags.unsigned_neg_ovflw = '1') then
        result_vec((i+1)*8-1 downto i*8) := x"00";
      else
        result_vec((i+1)*8-1 downto i*8) := res(i).sum;
      end if;
    end loop sat;
    return result_vec;
  end function usat8;
  
  -----------------------------------------------------------------------------
  -- 8 bit signed saturation on each result + concatenation
  -----------------------------------------------------------------------------
  function ssat8(res : add8_return_arr_t) return std_ulogic_vector is
    variable result_vec : std_ulogic_vector(31 downto 0);
  begin
    ---------------------------------------------------------------------------
    -- handle each byte individually
    ---------------------------------------------------------------------------  
    sat: for i in 0 to 3 loop
      if(res(i).flags.signed_pos_ovflw = '1') then
        result_vec((i+1)*8-1 downto i*8) := x"7F";
      elsif(res(i).flags.signed_neg_ovflw = '1') then
        result_vec((i+1)*8-1 downto i*8) := x"80";
      else
        result_vec((i+1)*8-1 downto i*8) := res(i).sum;
      end if;
    end loop sat;
    return result_vec;
  end function ssat8;

  -----------------------------------------------------------------------------
  -- 16 bit unsigned saturation on each result + concatenation
  -----------------------------------------------------------------------------
  function usat16(res : add8_return_arr_t) return std_ulogic_vector is
    variable result_vec : std_ulogic_vector(31 downto 0);
  begin
    ---------------------------------------------------------------------------
    -- word 0
    ---------------------------------------------------------------------------  
    if(res(1).flags.unsigned_pos_ovflw = '1') then
      result_vec(15 downto 0) := x"FFFF";
    elsif(res(1).flags.unsigned_neg_ovflw = '1') then
      result_vec(15 downto 0) := x"0000";
    else
      result_vec(15 downto 0) := res(1).sum & res(0).sum;
    end if;
    ---------------------------------------------------------------------------
    -- word 1
    ---------------------------------------------------------------------------  
    if(res(3).flags.unsigned_pos_ovflw = '1') then
      result_vec(31 downto 16) := x"FFFF";
    elsif(res(3).flags.unsigned_neg_ovflw = '1') then
      result_vec(31 downto 16) := x"0000";
    else
      result_vec(31 downto 16) := res(3).sum & res(2).sum;
    end if;    
    return result_vec;
  end function usat16;
  
  -----------------------------------------------------------------------------
  -- 16 bit signed saturation on each result + concatenation
  -----------------------------------------------------------------------------
  function ssat16(res : add8_return_arr_t) return std_ulogic_vector is
    variable result_vec : std_ulogic_vector(31 downto 0);
  begin
    ---------------------------------------------------------------------------
    -- word 0
    ---------------------------------------------------------------------------  
    if(res(1).flags.signed_pos_ovflw = '1') then
      result_vec(15 downto 0) := x"7FFF";
    elsif(res(1).flags.signed_neg_ovflw = '1') then
      result_vec(15 downto 0) := x"8000";
    else
      result_vec(15 downto 0) := res(1).sum & res(0).sum;
    end if;
    ---------------------------------------------------------------------------
    -- word 1
    ---------------------------------------------------------------------------  
    if(res(3).flags.signed_pos_ovflw = '1') then
      result_vec(31 downto 16) := x"7FFF";
    elsif(res(3).flags.signed_neg_ovflw = '1') then
      result_vec(31 downto 16) := x"8000";
    else
      result_vec(31 downto 16) := res(3).sum & res(2).sum;
    end if;    
    return result_vec;
  end function ssat16;
  
  -----------------------------------------------------------------------------
  -- 32 bit unsigned saturation on each result + concatenation
  -----------------------------------------------------------------------------
  function usat32(res : add8_return_arr_t) return std_ulogic_vector is
    variable result_vec : std_ulogic_vector(31 downto 0);
  begin
    if(res(3).flags.unsigned_pos_ovflw = '1') then
      result_vec := x"FFFFFFFF";
    elsif(res(3).flags.unsigned_neg_ovflw = '1') then
      result_vec := x"00000000";
    else
      result_vec := res(3).sum & res(2).sum & res(1).sum & res(0).sum;
    end if;
    return result_vec;
  end function usat32;
  
  -----------------------------------------------------------------------------
  -- 32 bit signed saturation on each result + concatenation
  -----------------------------------------------------------------------------
  function ssat32(res : add8_return_arr_t) return std_ulogic_vector is
    variable result_vec : std_ulogic_vector(31 downto 0);
  begin
    if(res(3).flags.signed_pos_ovflw = '1') then
      result_vec := x"7FFFFFFF";
    elsif(res(3).flags.signed_neg_ovflw = '1') then
      result_vec := x"80000000";
    else
      result_vec := res(3).sum & res(2).sum & res(1).sum & res(0).sum;
    end if;
    return result_vec;
  end function ssat32;
  
  -----------------------------------------------------------------------------
  -- concatenation
  -----------------------------------------------------------------------------
  function concat(res : add8_return_arr_t) return std_ulogic_vector is
    variable result_vec : std_ulogic_vector(31 downto 0);
  begin
    result_vec := res(3).sum & res(2).sum & res(1).sum & res(0).sum;
    return result_vec;
  end function concat;  
    
  -----------------------------------------------------------------------------
  -- 32 bit add_sub with signed and unsigned saturation
  -----------------------------------------------------------------------------
  function simd_addsub32( a, b : std_ulogic_vector(31 downto 0); 
                          mode : simd_addsub_t; 
                          size : simd_size_t; 
                          dt   : simd_data_t;
                          sat  : std_ulogic) return std_ulogic_vector is
    variable alu_cin_en     : std_ulogic_vector( 3 downto 0);
    variable alu_upos_ovflw : std_ulogic_vector( 3 downto 0);
    variable alu_uneg_ovflw : std_ulogic_vector( 3 downto 0);
    variable alu_spos_ovflw : std_ulogic_vector( 3 downto 0);
    variable alu_sneg_ovflw : std_ulogic_vector( 3 downto 0);
    variable carry_in       : std_ulogic;
    variable alu_res        : add8_return_arr_t;
    variable result         : std_ulogic_vector(31 downto 0);
  begin
    ---------------------------------------------------------------------------
    -- carry in enable decoding
    ---------------------------------------------------------------------------
    case(size) is
      when BYTE   => alu_cin_en(0) := '0';
                     alu_cin_en(1) := '0';
                     alu_cin_en(2) := '0';
                     alu_cin_en(3) := '0';

      when WORD   => alu_cin_en(0) := '0';
                     alu_cin_en(1) := '1';
                     alu_cin_en(2) := '0';
                     alu_cin_en(3) := '1';

      when others => alu_cin_en(0) := '0';
                     alu_cin_en(1) := '1';
                     alu_cin_en(2) := '1';
                     alu_cin_en(3) := '1';
    end case;

    ---------------------------------------------------------------------------
    -- 4x8 Bit carry chained 32 Bit ALU
    --------------------------------------------------------------------------
    alu: for i in 0 to 3 loop
      carry_in     := '0';
      if(alu_cin_en(i) = '1') then
        if(i /= 0) then
          carry_in := alu_res(i-1).flags.carry;
        end if;
      else
        if(mode = SUB) then
          carry_in := '1';
        end if;
      end if;




      alu_res(i)   := add8(a(8*(i+1)-1 downto 8*i), b(8*(i+1)-1 downto 8*i), carry_in, mode);
    end loop alu;

    ---------------------------------------------------------------------------
    -- conditionally saturate result based on vector size and data type
    ---------------------------------------------------------------------------
    result := concat(alu_res);
    if(sat = '1') then
      case(size) is
        when BYTE   =>  if(dt = U) then
                          result := usat8(alu_res);
                        else
                          result := ssat8(alu_res);
                        end if;

        when WORD   =>  if(dt = U) then
                          result := usat16(alu_res);
                        else
                          result := ssat16(alu_res);
                        end if;

        when others =>  if(dt = U) then
                          result := usat32(alu_res);
                        else
                          result := ssat32(alu_res);
                        end if;
      end case;
    end if;
    return result;
  end function simd_addsub32;

end package body simd_addsub32_pkg;

