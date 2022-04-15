library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fileio_pkg is

  type fileio_mode_t is (read, write, compare);
  type fileio_container_t is array(natural range<>) of std_logic_vector(31 downto 0);
  type fileio_status_t is (empty, full);

end package fileio_pkg;

