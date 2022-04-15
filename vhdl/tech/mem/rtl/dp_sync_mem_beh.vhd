library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dp_sync_mem_beh is
  generic (
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clk     : in  std_logic;
    we      : in  std_logic;
    sp_addr : in  std_logic_vector(addr_width_g-1 downto 0);
    dp_addr : in  std_logic_vector(addr_width_g-1 downto 0);
    di      : in  std_logic_vector(data_width_g-1 downto 0);
    spo     : out std_logic_vector(data_width_g-1 downto 0);
    dpo     : out std_logic_vector(data_width_g-1 downto 0)
  );
end entity dp_sync_mem_beh;

architecture beh of dp_sync_mem_beh is

constant entries : integer := (2**addr_width_g);
type ram_type is array (entries-1 downto 0) of std_logic_vector (data_width_g-1 downto 0);
signal RAM: ram_type;
signal read_a    : std_logic_vector(addr_width_g-1 downto 0);
signal read_dpra : std_logic_vector(addr_width_g-1 downto 0);


begin
  mem: process(clk)
    begin
      if rising_edge(clk) then
        if (we = '1') then
          RAM(to_integer(unsigned(sp_addr))) <= di;
        end if;
        read_a    <= sp_addr;
        read_dpra <= dp_addr;
      end if;
  end process mem;

  spo <= RAM(to_integer(unsigned(sp_addr)));
  dpo <= RAM(to_integer(unsigned(dp_addr)));

end architecture beh;

