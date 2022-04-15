library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tech;
use tech.tech_constants_pkg.all;

entity dp_2wr_sync_mem is
  generic (
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clka_i  : in  std_logic;
    clkb_i  : in  std_logic;
    ena_i   : in  std_logic;
    enb_i   : in  std_logic;
    wea_i   : in  std_logic;
    web_i   : in  std_logic;
    addra_i : in  std_logic_vector(addr_width_g-1 downto 0);
    addrb_i : in  std_logic_vector(addr_width_g-1 downto 0);
    dia_i   : in  std_logic_vector(data_width_g-1 downto 0);
    dib_i   : in  std_logic_vector(data_width_g-1 downto 0);
    doa_o   : out std_logic_vector(data_width_g-1 downto 0);
    dob_o   : out std_logic_vector(data_width_g-1 downto 0)
  );
end entity dp_2wr_sync_mem;

architecture struct of dp_2wr_sync_mem is
begin
-------------------------------------------------------------------------------
-- just to make sure the technology is supported
-------------------------------------------------------------------------------
assert( target_tech_c = tech_behave_c     or
        target_tech_c = tech_xilinx_c     or
        target_tech_c = tech_infineon_c ) report "unsupported technology"
        severity failure;

-------------------------------------------------------------------------------
-- conditionally instanciate behavioural memory
-------------------------------------------------------------------------------
behave: if target_tech_c = tech_behave_c generate
  memi0: entity tech.dp_2wr_sync_mem_beh
    generic map (
      addr_width_g => addr_width_g,
      data_width_g => data_width_g
    )
    port map (
      clka  => clka_i,  -- : in  std_logic;
      clkb  => clkb_i,  -- : in  std_logic;
      ena   => ena_i,   -- : in  std_logic;
      enb   => enb_i,   -- : in  std_logic;
      wea   => wea_i,   -- : in  std_logic;
      web   => web_i,   -- : in  std_logic;
      addra => addra_i, -- : in  std_logic_vector(addr_width_g downto 0);
      addrb => addrb_i, -- : in  std_logic_vector(addr_width_g downto 0);
      dia   => dia_i,   -- : in  std_logic_vector(data_width_g downto 0);
      dib   => dib_i,   -- : in  std_logic_vector(data_width_g downto 0);
      doa   => doa_o,   -- : out std_logic_vector(data_width_g downto 0);
      dob   => dob_o    -- : out std_logic_vector(data_width_g downto 0)
    );
end generate behave;

-------------------------------------------------------------------------------
-- conditionally instanciate xilinx memory (xst supports behavioural)
-------------------------------------------------------------------------------
xilinx: if target_tech_c = tech_xilinx_c generate
  memi0: entity tech.dp_2wr_sync_mem_beh
    generic map (
      addr_width_g => addr_width_g,
      data_width_g => data_width_g
    )
    port map (
      clka  => clka_i,  -- : in  std_logic;
      clkb  => clkb_i,  -- : in  std_logic;
      ena   => ena_i,   -- : in  std_logic;
      enb   => enb_i,   -- : in  std_logic;
      wea   => wea_i,   -- : in  std_logic;
      web   => web_i,   -- : in  std_logic;
      addra => addra_i, -- : in  std_logic_vector(addr_width_g downto 0);
      addrb => addrb_i, -- : in  std_logic_vector(addr_width_g downto 0);
      dia   => dia_i,   -- : in  std_logic_vector(data_width_g downto 0);
      dib   => dib_i,   -- : in  std_logic_vector(data_width_g downto 0);
      doa   => doa_o,   -- : out std_logic_vector(data_width_g downto 0);
      dob   => dob_o    -- : out std_logic_vector(data_width_g downto 0)
    );
end generate xilinx;

end architecture struct;

