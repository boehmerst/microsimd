library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.func_pkg.all;

package vec_data_pkg is

  subtype vec_low  is natural range CFG_VREG_SLICES/2-1 downto 0;
  subtype vec_high is natural range CFG_VREG_SLICES-1 downto CFG_VREG_SLICES/2;

  subtype byte0 is natural range  7 downto  0;
  subtype byte1 is natural range 15 downto  8;
  subtype byte2 is natural range 23 downto 16;
  subtype byte3 is natural range 31 downto 24;

  subtype word0 is natural range 15 downto  0;
  subtype word1 is natural range 31 downto 16;
  
  subtype double0 is natural range 31 downto 0;
  
  type vec_data_t is array(natural range CFG_VREG_SLICES-1 downto 0) of std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
  constant dflt_vec_data_c : vec_data_t := (others=>(others=>'0'));
  
  function insert(vec : vec_data_t; idx : std_ulogic_vector; data : std_ulogic_vector) return vec_data_t;
  function extract(vec : vec_data_t; idx : std_ulogic_vector) return std_ulogic_vector;
  
  function set_byte(vec : vec_data_t; idx : unsigned; data : std_ulogic_vector(7 downto 0)) return vec_data_t;
  function set_word(vec : vec_data_t; idx : unsigned; data : std_ulogic_vector(15 downto 0)) return vec_data_t;
  function set_double(vec : vec_data_t; idx : unsigned; data : std_ulogic_vector(31 downto 0)) return vec_data_t;
  
  function get_byte(vec : vec_data_t; idx : unsigned) return std_ulogic_vector;
  function get_word(vec : vec_data_t; idx : unsigned) return std_ulogic_vector;
  function get_double(vec : vec_data_t; idx : unsigned) return std_ulogic_vector;
  
  function to_std(vec : vec_data_t) return std_ulogic_vector;
  function to_vec(vec : std_ulogic_vector) return vec_data_t;
  function "and" (i1, i2 : vec_data_t) return vec_data_t;
  function "or"  (i1, i2 : vec_data_t) return vec_data_t;
  function "xor" (i1, i2 : vec_data_t) return vec_data_t;
  function "not" (i1 : vec_data_t) return vec_data_t;
  
end package vec_data_pkg;

package body vec_data_pkg is
  ------------------------------------------------------------------------------
  -- insert std_ulogic_vector as an element
  ------------------------------------------------------------------------------
  function insert(vec : vec_data_t; idx : std_ulogic_vector; data : std_ulogic_vector) return vec_data_t is
    variable index  : integer range 0 to CFG_VREG_SLICES-1;
    variable result : vec_data_t;
  begin
-- pragma translate_off
    result := vec;
    if(notx(idx)) then
-- pragma translate_on
      index         := to_integer(unsigned(idx(log2ceil(CFG_VREG_SLICES)-1 downto 0)));
      result(index) := data;
-- pragma translate_off
    end if;
-- pragma translate_on
    return result;
  end function insert;
  
  ------------------------------------------------------------------------------
  -- extract a std_ulogic_vector element
  ------------------------------------------------------------------------------
  function extract(vec : vec_data_t; idx : std_ulogic_vector) return std_ulogic_vector is
    variable index  : integer range 0 to CFG_VREG_SLICES-1;
    variable result : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
  begin
-- pragma translate_off
    result := (others=>'0');
    if(notx(idx)) then
-- pragma translate_on
      index  := to_integer(unsigned(idx(log2ceil(CFG_VREG_SLICES)-1 downto 0)));
      result := vec(index);
-- pragma translate_off
    end if;
-- pragma translate_on
    return result;
  end function extract;
  
  ------------------------------------------------------------------------------
  -- get byte
  ------------------------------------------------------------------------------
  function get_byte(vec : vec_data_t; idx : unsigned) return std_ulogic_vector is
    variable index  : integer range 0 to CFG_VREG_SLICES*CFG_DMEM_WIDTH/8-1;
    variable as_std : std_ulogic_vector(CFG_VREG_SLICES*CFG_DMEM_WIDTH-1 downto 0);
    variable result : std_ulogic_vector(7 downto 0);
  begin
-- pragma translate_off
    result := (others=>'0');
    if(notx(std_ulogic_vector(idx))) then
-- pragma translate_on
      as_std := to_std(vec);
      index  := to_integer(idx);
      result := as_std(8*(index+1)-1 downto 8*index);
-- pragma translate_off
    end if;
-- pragma translate_on
    return result;
  end function get_byte;
  
  ------------------------------------------------------------------------------
  -- get word
  ------------------------------------------------------------------------------
  function get_word(vec : vec_data_t; idx : unsigned) return std_ulogic_vector is
    variable index  : integer range 0 to CFG_VREG_SLICES*CFG_DMEM_WIDTH/16-1;
    variable as_std : std_ulogic_vector(CFG_VREG_SLICES*CFG_DMEM_WIDTH-1 downto 0);
    variable result : std_ulogic_vector(15 downto 0);
  begin
-- pragma translate_off
    result := (others=>'0');
    if(notx(std_ulogic_vector(idx))) then
-- pragma translate_on
      as_std := to_std(vec);
      index  := to_integer(idx);
      result := as_std(16*(index+1)-1 downto 16*index);
-- pragma translate_off
    end if;
-- pragma translate_on    
    return result;
  end function get_word;  
 
  ------------------------------------------------------------------------------
  -- get double word
  ------------------------------------------------------------------------------
  function get_double(vec : vec_data_t; idx : unsigned) return std_ulogic_vector is
    variable index  : integer range 0 to CFG_VREG_SLICES*CFG_DMEM_WIDTH/32-1;
    variable as_std : std_ulogic_vector(CFG_VREG_SLICES*CFG_DMEM_WIDTH-1 downto 0);
    variable result : std_ulogic_vector(31 downto 0);
  begin
-- pragma translate_off
    result := (others=>'0');
    if(notx(std_ulogic_vector(idx))) then
-- pragma translate_on
      as_std := to_std(vec);
      index  := to_integer(idx);
      result := as_std(32*(index+1)-1 downto 32*index);
-- pragma translate_off
    end if;
-- pragma translate_on    
    return result;
  end function get_double;
  
  ------------------------------------------------------------------------------
  -- set byte
  ------------------------------------------------------------------------------
  function set_byte(vec : vec_data_t; idx : unsigned; data : std_ulogic_vector(7 downto 0)) return vec_data_t is
    variable index  : integer range 0 to CFG_VREG_SLICES*CFG_DMEM_WIDTH/8-1;
    variable as_std : std_ulogic_vector(CFG_VREG_SLICES*CFG_DMEM_WIDTH-1 downto 0);
    variable result : vec_data_t;
  begin
-- pragma translate_off
    result := dflt_vec_data_c;
    if(notx(std_ulogic_vector(idx))) then
-- pragma translate_on
      as_std := to_std(vec);
      index  := to_integer(idx);
      as_std(8*(index+1)-1 downto 8*index) := data;
      result := to_vec(as_std);
-- pragma translate_off
    end if;
-- pragma translate_on
    return result;
  end function set_byte;
  
  ------------------------------------------------------------------------------
  -- set word
  ------------------------------------------------------------------------------  
  function set_word(vec : vec_data_t; idx : unsigned; data : std_ulogic_vector(15 downto 0)) return vec_data_t is
    variable index  : integer range 0 to CFG_VREG_SLICES*CFG_DMEM_WIDTH/16-1;
    variable as_std : std_ulogic_vector(CFG_VREG_SLICES*CFG_DMEM_WIDTH-1 downto 0);
    variable result : vec_data_t;
  begin
-- pragma translate_off
    result := dflt_vec_data_c;
    if(notx(std_ulogic_vector(idx))) then
-- pragma translate_on
      as_std := to_std(vec);
      index  := to_integer(idx);
      as_std(16*(index+1)-1 downto 16*index) := data;
      result := to_vec(as_std);
-- pragma translate_off
    end if;
-- pragma translate_on
    return result;  
  end function set_word;
  
  ------------------------------------------------------------------------------
  -- set double
  ------------------------------------------------------------------------------  
  function set_double(vec : vec_data_t; idx : unsigned; data : std_ulogic_vector(31 downto 0)) return vec_data_t is
    variable index  : integer range 0 to CFG_VREG_SLICES*CFG_DMEM_WIDTH/32-1;
    variable as_std : std_ulogic_vector(CFG_VREG_SLICES*CFG_DMEM_WIDTH-1 downto 0);
    variable result : vec_data_t;
  begin
-- pragma translate_off
    result := dflt_vec_data_c;
    if(notx(std_ulogic_vector(idx))) then
-- pragma translate_on
      as_std := to_std(vec);
      index  := to_integer(idx);
      as_std(32*(index+1)-1 downto 32*index) := data;
      result := to_vec(as_std);
-- pragma translate_off
    end if;
-- pragma translate_on
    return result;    
  end function set_double;
   
  ------------------------------------------------------------------------------
  -- convert vec_data_t to std_logic_vector
  ------------------------------------------------------------------------------
  function to_std(vec : vec_data_t) return std_ulogic_vector is
    variable result : std_ulogic_vector(CFG_VREG_SLICES*CFG_DMEM_WIDTH-1 downto 0);
  begin
    assign: for i in 0 to CFG_VREG_SLICES-1 loop
	    result(CFG_DMEM_WIDTH*(i+1)-1 downto CFG_DMEM_WIDTH*i) := vec(i);
	  end loop assign;
	  return result;
  end function to_std;
  
  ------------------------------------------------------------------------------
  -- convert std_logic_vector to vec_data_t
  ------------------------------------------------------------------------------
  function to_vec(vec : std_ulogic_vector) return vec_data_t is
    variable result : vec_data_t;
  begin
    assign: for i in 0 to CFG_VREG_SLICES-1 loop
	    result(i) := vec(CFG_DMEM_WIDTH*(i+1)-1 downto CFG_DMEM_WIDTH*i);
	  end loop assign;
	  return result;
  end function to_vec;
  
  ------------------------------------------------------------------------------
  -- vector "and" operator
  ------------------------------------------------------------------------------
  function "and" (i1, i2 : vec_data_t) return vec_data_t is
    variable result : vec_data_t;
  begin
    assign0: for i in 0 to CFG_VREG_SLICES-1 loop
      result(i) := i1(i) and i2(i);
    end loop assign0;
    return result;
  end function "and";

  ------------------------------------------------------------------------------
  -- vector "or" operator
  ------------------------------------------------------------------------------
  function "or" (i1, i2 : vec_data_t) return vec_data_t is
    variable result : vec_data_t;
  begin
    assign0: for i in 0 to CFG_VREG_SLICES-1 loop
      result(i) := i1(i) or i2(i);
    end loop assign0;
    return result;
  end function "or";
  
  ------------------------------------------------------------------------------
  -- vector "xor" operator
  ------------------------------------------------------------------------------
  function "xor" (i1, i2 : vec_data_t) return vec_data_t is
    variable result : vec_data_t;
  begin
    assign0: for i in 0 to CFG_VREG_SLICES-1 loop
      result(i) := i1(i) xor i2(i);
    end loop assign0;
    return result;
  end function "xor";

  ------------------------------------------------------------------------------
  -- vector "and" operator
  ------------------------------------------------------------------------------
  function "not" (i1 : vec_data_t) return vec_data_t is
    variable result : vec_data_t;
  begin
    assign0: for i in 0 to CFG_VREG_SLICES-1 loop
      result(i) := not i1(i);
    end loop assign0;
    return result;
  end function "not";
  
end package body vec_data_pkg;

