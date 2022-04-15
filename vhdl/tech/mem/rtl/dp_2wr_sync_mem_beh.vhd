library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dp_2wr_sync_mem_beh is
  generic (
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clka  : in std_logic;
    clkb  : in std_logic;
    ena   : in std_logic;
    enb   : in std_logic;
    wea   : in std_logic;
    web   : in std_logic;
    addra : in std_logic_vector(addr_width_g-1 downto 0);
    addrb : in std_logic_vector(addr_width_g-1 downto 0);
    dia   : in std_logic_vector(data_width_g-1 downto 0);
    dib   : in std_logic_vector(data_width_g-1 downto 0);
    doa   : out std_logic_vector(data_width_g-1 downto 0);
    dob   : out std_logic_vector(data_width_g-1 downto 0)
  );
end entity dp_2wr_sync_mem_beh;

architecture beh of dp_2wr_sync_mem_beh is

constant entries : integer := 2**addr_width_g;

type memory_t is protected
  procedure       write(addr : in std_logic_vector(addr_width_g-1 downto 0); data : in std_logic_vector(data_width_g-1 downto 0));
  impure function read(addr: in std_logic_vector(addr_width_g-1 downto 0)) return std_logic_vector;
end protected memory_t;

type memory_t is protected body
  type ram_type_t is array (entries-1 downto 0) of std_logic_vector(data_width_g-1 downto 0);
  
  variable ram : ram_type_t;

  procedure write(addr : in std_logic_vector(addr_width_g-1 downto 0); data : in std_logic_vector(data_width_g-1 downto 0)) is
  begin
    ram(to_integer(unsigned(addr))) := data;
  end procedure write;

  impure function read(addr: in std_logic_vector(addr_width_g-1 downto 0)) return std_logic_vector is
  begin
    return ram(to_integer(unsigned(addr)));
  end function read;
end protected body memory_t;

shared variable ram : memory_t;

begin
  -----------------------------------------------------------------------------
  -- memory port a
  -----------------------------------------------------------------------------
  porta: process(clka)
  begin
    if rising_edge(clka) then
      if wea = '1' then
        ram.write(addra, dia);
      end if;
      doa <= ram.read(addra);
    end if;
  end process porta;

  -----------------------------------------------------------------------------
  -- memory port b
  -----------------------------------------------------------------------------
  portb: process(clkb)
  begin
    if rising_edge(clkb) then
      if web = '1' then
        ram.write(addrb, dib);
      end if;
      dob <= ram.read(addrb);
    end if;
  end process portb;

end architecture beh;

