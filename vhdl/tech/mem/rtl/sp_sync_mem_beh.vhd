library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity sp_sync_mem_beh is
  generic (
    file_name_g  : string := "rom.txt";
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clk  : in  std_logic;
    we   : in  std_logic;
    en   : in  std_logic;
    addr : in  std_logic_vector(addr_width_g-1 downto 0);
    di   : in  std_logic_vector(data_width_g-1 downto 0);
    do   : out std_logic_vector(data_width_g-1 downto 0)
  );
end entity sp_sync_mem_beh;

architecture beh of sp_sync_mem_beh is

constant entries : integer := (2**addr_width_g);
type ram_type is array (entries-1 downto 0) of std_logic_vector (data_width_g-1 downto 0);

-------------------------------------------------------------------------------
-- mem_init
-------------------------------------------------------------------------------
procedure mem_init(variable RAM : inout ram_type) is
  file     readfile      : text open read_mode is file_name_g;
  variable vecline       : line;

  variable add_ulv       : std_logic_vector(addr_width_g-1 downto 0);
  variable var_ulv       : std_logic_vector(data_width_g-1 downto 0);

  variable add_int       : natural := 0;
  variable address_base  : string(3 downto 1) := "BIN";
  variable data_base     : string(3 downto 1) := "BIN";
begin
      if(file_name_g /= "none") then
        readline(readfile, vecline);
        read(vecline, address_base);
        readline (readfile, vecline);
        read(vecline, data_base);
      
      while not endfile(readfile) loop
        readline(readfile, vecline);
        -----------------------------------------------------------------------
        -- read address
        -----------------------------------------------------------------------
        case address_base is

          when "BIN" => read(vecline, add_ulv);
                        add_int := to_integer(unsigned(add_ulv));

          when others => assert false report "Mismatch in 1st line of input file, "&
                                "address_base should be BIN, OCT or HEX" severity failure;
        end case;
        -----------------------------------------------------------------------
        -- read data
        -----------------------------------------------------------------------
        case data_base is
          when "BIN"  => read(vecline, var_ulv);
          when others => assert false report "Mismatch in 2nd line of input file, "&
                                "data_base should be BIN, OCT or HEX" severity failure;
        end case;
        
        if(add_int > entries-1) then
          assert false report "Address out of range while filling memory" severity failure;
        else
          RAM(add_int) := var_ulv;
        end if;
       end loop;
       assert false report "Memory filling successfull" severity note;
    end if;
end procedure mem_init;

begin
  -----------------------------------------------------------------------------
  -- mem
  -----------------------------------------------------------------------------
  mem: process(clk) is
    variable RAM          : ram_type;
    variable readcontents : boolean := true;
  begin
    -- initialize memory array
    if(readcontents = true) then
      mem_init(RAM);
      readcontents := false;
    end if;

    -- ram functionality
    if rising_edge(clk) then
      if en = '1' then
        if we = '1' then
          RAM(to_integer(unsigned(addr))) := di;
        end if;
          do <= RAM(to_integer(unsigned(addr)));
      end if;
    end if;
  end process mem;

end architecture beh;


