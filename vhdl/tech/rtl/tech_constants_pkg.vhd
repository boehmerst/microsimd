library ieee;
use ieee.std_logic_1164.all;

package tech_constants_pkg is
-------------------------------------------------------------------------------
-- constants to distinguish between different technologies
-------------------------------------------------------------------------------
constant tech_behave_c   : integer := 0;
constant tech_xilinx_c   : integer := 1;
constant tech_altera_c   : integer := 2;
constant tech_lattice_c  : integer := 3;
constant tech_asic_c     : integer := 4;
constant tech_infineon_c : integer := 5;

-------------------------------------------------------------------------------
-- modify according to targeted technology
-------------------------------------------------------------------------------
constant target_tech_c  : integer := tech_behave_c;

end package tech_constants_pkg;

