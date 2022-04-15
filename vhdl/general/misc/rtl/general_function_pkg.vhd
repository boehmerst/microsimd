library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- package general_function_pkg
-------------------------------------------------------------------------------
package general_function_pkg is

function log2ceil( n : natural ) return natural;
function bin2gray( signal bin : in  std_logic_vector) return std_logic_vector;
function gray2bin( signal gray : in  std_logic_vector) return std_logic_vector;
function max(a, b : in integer) return integer;
function min(a, b : in integer) return integer;
function count_ones(vec : in std_ulogic_vector) return natural;
function count_zeros(vec : in std_ulogic_vector) return natural;

end package general_function_pkg;

-------------------------------------------------------------------------------
-- package body general_function_pkg
-------------------------------------------------------------------------------
package body general_function_pkg is

--function log2ceil (n : natural) return natural is
--  variable n_bit : unsigned(31 downto 0);
--begin
--  if n = 0 then
--    return 0;
--  end if;
--  n_bit := to_unsigned(n-1,32);
--  for i in 31 downto 0 loop
--    if n_bit(i) = '1' then
--      return i+1;
--    end if;
--  end loop;  -- i
--  return 1;
--end log2ceil;

function log2ceil  (n : natural ) return natural is
  variable n_bit : unsigned(31 downto 0);
begin
   for i in 0 to integer'high loop
      if (2**i >= n) then
         return i;
      end if;
   end loop;
end log2ceil;

function bin2gray( signal bin  : in  std_logic_vector
                 ) return std_logic_vector is
  variable gray  : std_logic_vector(bin'range);
begin
  for i in 0 to bin'left-1 loop
    gray(i)       := bin(i) xor bin(i+1);
  end loop;
  gray(gray'left) := bin(bin'left);
  return gray;
end bin2gray;

function gray2bin( signal gray : in  std_logic_vector
                 ) return std_logic_vector is
  variable bin  : std_logic_vector(gray'range);
begin
  bin(bin'left) := gray(gray'left);
  for i in gray'left-1 downto 0 loop
    bin(i)      := bin(i+1) xor gray(i);
  end loop;
  return bin;
end gray2bin;

function max(a, b : in integer) return integer is
begin
  if(a > b) then
    return a;
  else
    return b;
  end if;
end function max;

function min(a, b : in integer) return integer is
begin
  if(a < b) then
    return a;
  else
    return b;
  end if;
end function min;

function count_ones(vec : in std_ulogic_vector) return natural is
  variable cnt : natural;
begin
  cnt := 0;
  cnt0: for i in vec'range loop
    if(vec(i) = '1') then
      cnt := cnt + 1;
    end if;
  end loop cnt0;
  return cnt;
end function count_ones;

function count_zeros(vec : in std_ulogic_vector) return natural is
  variable cnt : natural;
begin
  cnt := 0;
  cnt0: for i in vec'range loop
    if(vec(i) = '0') then
      cnt := cnt + 1;
    end if;
  end loop cnt0;
  return cnt;
end function count_zeros;


end package body general_function_pkg;

