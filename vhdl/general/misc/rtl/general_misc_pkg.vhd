library ieee;
use ieee.std_logic_1164.all;

package general_misc_pkg is

component gen_count_async_set is
  generic (
    width_g : natural
  );
  port (
    reset_n   : in  std_logic;
    clk_i     : in  std_logic;
    set_n_i   : in  std_logic;
    clear_n_i : in  std_logic;
    en_i      : in  std_logic;
    count_o   : out std_logic_vector(width_g-1 downto 0)
  );
end component gen_count_async_set;

component graycount is
  generic (
    counter_width_g : integer
  );
  port (
    clk     : in  std_logic;
    ena_i   : in  std_logic;
    clear_i : in  std_logic;
    count_o : out std_logic_vector (counter_width_g-1 downto 0)
  );
end component graycount;

component edgedetect is
  generic (
    edge_g  : in string := "rising"
  );
  port (
    clk_i   : in  std_logic;
    reset_i : in  std_logic;
    d_i     : in  std_logic;
    d_o     : out std_logic
  );
end component edgedetect;

end package general_misc_pkg;
