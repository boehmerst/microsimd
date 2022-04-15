library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tech;
use tech.tech_constants_pkg.all;

entity dp_sync_mem is
  generic (
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clk_i     : in  std_logic;
    we_i      : in  std_logic;
    sp_addr_i : in  std_logic_vector(addr_width_g-1 downto 0);
    dp_addr_i : in  std_logic_vector(addr_width_g-1 downto 0);
    di_i      : in  std_logic_vector(data_width_g-1 downto 0);
    spo_o     : out std_logic_vector(data_width_g-1 downto 0);
    dpo_o     : out std_logic_vector(data_width_g-1 downto 0)
  );
end entity dp_sync_mem;

architecture struct of dp_sync_mem is
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
  memi0: entity tech.dp_sync_mem_beh
    generic map (
      addr_width_g => addr_width_g,
      data_width_g => data_width_g
    )
    port map (
      clk     => clk_i,     --: in  std_logic;
      we      => we_i,      --: in  std_logic;
      sp_addr => sp_addr_i, --: in  std_logic_vector(addr_width_g-1 downto 0);
      dp_addr => dp_addr_i, --: in  std_logic_vector(addr_width_g-1 downto 0);
      di      => di_i,      --: in  std_logic_vector(data_width_g-1 downto 0);
      spo     => spo_o,     --: out std_logic_vector(data_width_g-1 downto 0);
      dpo     => dpo_o      --: out std_logic_vector(data_width_g-1 downto 0)
    );
end generate behave;

-------------------------------------------------------------------------------
-- conditionally instanciate xilinx memory (xst supports behavioural)
-------------------------------------------------------------------------------
xilinx: if target_tech_c = tech_xilinx_c generate
  memi0: entity tech.dp_sync_mem_beh
    generic map (
      addr_width_g => addr_width_g,
      data_width_g => data_width_g
    )
    port map (
      clk     => clk_i,     --: in  std_logic;
      we      => we_i,      --: in  std_logic;
      sp_addr => sp_addr_i, --: in  std_logic_vector(addr_width_g-1 downto 0);
      dp_addr => dp_addr_i, --: in  std_logic_vector(addr_width_g-1 downto 0);
      di      => di_i,      --: in  std_logic_vector(data_width_g-1 downto 0);
      spo     => spo_o,     --: out std_logic_vector(data_width_g-1 downto 0);
      dpo     => dpo_o      --: out std_logic_vector(data_width_g-1 downto 0)
    );
end generate xilinx;

end architecture struct;

