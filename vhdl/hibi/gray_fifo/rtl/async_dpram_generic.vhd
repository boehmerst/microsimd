library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity async_dpram_generic is
  generic (
    addrw_g : integer := 5;
    dataw_g : integer := 32
  );
  port (
    rd_clk     : in  std_logic;
    wr_clk     : in  std_logic;
    wr_en_in   : in  std_logic;
    data_in    : in  std_logic_vector(dataw_g-1 downto 0);
    data_out   : out std_logic_vector(dataw_g-1 downto 0);
    rd_addr_in : in  std_logic_vector(addrw_g-1 downto 0);
    wr_addr_in : in  std_logic_vector(addrw_g-1 downto 0)
  );
end entity async_dpram_generic;

architecture rtl of async_dpram_generic is

  type mem_t is array (0 to 2**addrw_g - 1) of std_logic_vector(dataw_g-1 downto 0);

  signal memory           : mem_t;
  signal wr_addr, rd_addr : integer;
  signal data_out_r       : std_logic_vector(dataw_g-1 downto 0);
  
begin  -- architecture rtl

  wr_addr  <= to_integer (unsigned(wr_addr_in));
  rd_addr  <= to_integer (unsigned(rd_addr_in));
  data_out <= data_out_r;

  wr : process (wr_clk) is
  begin  -- process write
    if rising_edge(wr_clk) then         -- rising clock edge
      if (wr_en_in = '1') then
        memory(wr_addr) <= data_in;
      end if;
    end if;
  end process wr;
--      data_out_r <= memory(rd_addr);
  rd : process (rd_clk) is
  begin  -- process rd
    if rising_edge(rd_clk) then
      data_out_r <= memory(rd_addr);
    end if;
  end process rd;

end architecture rtl;

