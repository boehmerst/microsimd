library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package hibi_seg_r1_pkg is
  -----------------------------------------------------------------------------
  -- hibi address space of the r1 segment
  -----------------------------------------------------------------------------
  type hibi_addr_array_t is array (0 to 3) of integer;
    constant hibi_addresses_c : hibi_addr_array_t :=(
    16#0000#, 16#1000#, 16#2000#, 16#3000#
  );

end package hibi_seg_r1_pkg;

