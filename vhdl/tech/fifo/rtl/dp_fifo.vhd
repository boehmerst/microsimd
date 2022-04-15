library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tech;
use tech.tech_constants_pkg.all;

entity dp_fifo is
  generic (
    data_width_g : integer;
    addr_width_g : integer
  );
  port (
    -- Reading port.
    data_o  : out std_logic_vector(data_width_g-1 downto 0);
    empty_o : out std_logic;
    rd_i    : in  std_logic;
    rclk_i  : in  std_logic;
    -- Writing port.
    data_i  : in  std_logic_vector(data_width_g-1 downto 0);
    full_o  : out std_logic;
    wr_i    : in  std_logic;
    wclk_i  : in  std_logic;
 	 
    clear_i : in  std_logic
  );
end entity dp_fifo;

architecture struct of dp_fifo is
begin
-------------------------------------------------------------------------------
-- just to make sure the technology is supported
-------------------------------------------------------------------------------
assert( target_tech_c = tech_behave_c ) 
        report "unsupported or untested technology"
        severity failure;

-------------------------------------------------------------------------------
-- conditionally instanciate behavioural memory
-------------------------------------------------------------------------------
behave: if target_tech_c = tech_behave_c generate
  memi0: entity tech.dp_fifo_beh
    generic map (
      data_width_g => data_width_g,
      addr_width_g => addr_width_g
    )
    port map (
      data_o  => data_o,  --: out std_logic_vector(data_width_g-1 downto 0);
      empty_o => empty_o, --: out std_logic;
      rd_i    => rd_i,    --: in  std_logic;
      rclk_i  => rclk_i,  --: in  std_logic;
      data_i  => data_i,  --: in  std_logic_vector(data_width_g-1 downto 0);
      full_o  => full_o,  --: out std_logic;
      wr_i    => wr_i,    --: in  std_logic;
      wclk_i  => wclk_i,  --: in  std_logic;
      clear_i => clear_i  --: in  std_logic
    );
end generate behave;

end architecture struct;

