library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tech;
use tech.tech_constants_pkg.all;

entity sp_async_mem is
  generic (
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clk_i  : in  std_logic;
    we_i   : in  std_logic;
    addr_i : in  std_logic_vector(addr_width_g-1 downto 0);
    di_i   : in  std_logic_vector(data_width_g-1 downto 0);
    do_o   : out std_logic_vector(data_width_g-1 downto 0)
  );
end entity sp_async_mem;

architecture struct of sp_async_mem is
begin
-------------------------------------------------------------------------------
-- just to make sure the technology is supported
-------------------------------------------------------------------------------
assert( target_tech_c = tech_behave_c or
        target_tech_c = tech_xilinx_c ) report "unsupported technology"
        severity failure;

-------------------------------------------------------------------------------
-- conditionally instanciate behavioural memory
-------------------------------------------------------------------------------
behave: if target_tech_c = tech_behave_c generate
  memi0: entity tech.sp_async_mem_beh
    generic map (
      addr_width_g => addr_width_g,
      data_width_g => data_width_g
    )
    port map (
      clk  => clk_i,
      we   => we_i,
      addr => addr_i,
      di   => di_i,
      do   => do_o
    );
end generate behave;

-------------------------------------------------------------------------------
-- conditionally instanciate xilinx memory (xst support behavioural)
-------------------------------------------------------------------------------
xilinx: if target_tech_c = tech_xilinx_c generate
  memi0: entity tech.sp_async_mem_beh
    generic map (
      addr_width_g => addr_width_g,
      data_width_g => data_width_g
    )
    port map (
      clk  => clk_i,
      we   => we_i,
      addr => addr_i,
      di   => di_i,
      do   => do_o
    );
end generate xilinx;

end architecture struct;
