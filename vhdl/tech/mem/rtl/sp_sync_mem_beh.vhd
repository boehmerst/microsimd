library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

--library std;
use std.textio.all;

entity sp_sync_mem_beh is
  generic (
    file_name_g  : string := "rom.txt";
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clk_i  : in  std_ulogic;
    we_i   : in  std_ulogic;
    en_i   : in  std_ulogic;
    addr_i : in  std_ulogic_vector(addr_width_g-1 downto 0);
    di_i   : in  std_ulogic_vector(data_width_g-1 downto 0);
    do_o   : out std_ulogic_vector(data_width_g-1 downto 0)
  );
end entity sp_sync_mem_beh;

architecture beh of sp_sync_mem_beh is

constant entries : integer := (2**addr_width_g);
type ram_type is array (entries-1 downto 0) of std_ulogic_vector (data_width_g-1 downto 0);

-------------------------------------------------------------------------------
-- mem_init
-------------------------------------------------------------------------------
procedure mem_init(variable RAM : inout ram_type) is
  file     readfile       : text open read_mode is file_name_g;
  variable vecline        : line;

  variable add_ulv        : std_ulogic_vector(addr_width_g-1 downto 0);
  variable var_ulv        : std_ulogic_vector(data_width_g-1 downto 0);

  variable add_int        : natural   := 0;
  variable addr_indicator : character := ' ';
begin
  if(file_name_g /= "none") then
    readline(readfile, vecline);

    read(vecline, addr_indicator);
    assert addr_indicator = '@' report "Incorrect address indicator: expecting @address" severity failure;

    hread(vecline, add_ulv);

    add_int := to_integer(unsigned(add_ulv));
        	      
    while not endfile(readfile) loop
      -----------------------------------------------------------------------
      -- read data
      -----------------------------------------------------------------------
      readline(readfile, vecline);
      hread(vecline, var_ulv);

      if(add_int > entries-1) then
        assert false report "Address out of range while filling memory" severity failure;
      else
        RAM(add_int) := var_ulv;
        add_int      := add_int + 1;
      end if;
    end loop;
    assert false report "Memory filling successfull" severity note;
  end if;
end procedure mem_init;

begin
  -----------------------------------------------------------------------------
  -- mem
  -----------------------------------------------------------------------------
  mem: process(clk_i) is
    variable RAM          : ram_type;
    variable readcontents : boolean := true;
  begin
    -- initialize memory array
    if(readcontents = true) then
      mem_init(RAM);
      readcontents := false;
    end if;

    -- ram functionality
    if rising_edge(clk_i) then
      if en_i = '1' then
        if we_i = '1' then
          RAM(to_integer(unsigned(addr_i))) := di_i;
        end if;
          do_o <= RAM(to_integer(unsigned(addr_i)));
      end if;
    end if;
  end process mem;

end architecture beh;


