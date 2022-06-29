library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

entity sky130_sram_2kbyte_1rw1r_32x512_8 is
  -- pragma translate_off
  -- NOTE: We do this to avoid 'GHDL --synth' to change module name because of generics
  generic (
    file_name_g : string := "none"
  );
  -- pragma translate_on
  port (
    vccd1  : inout std_ulogic := '1';
    vssd1  : inout std_ulogic := '1';

    clk0   : in    std_ulogic;
    csb0   : in    std_ulogic;
    web0   : in    std_ulogic;
    wmask0 : in    std_ulogic_vector( 3 downto 0);
    addr0  : in    std_ulogic_vector( 8 downto 0);
    din0   : in    std_ulogic_vector(31 downto 0);
    dout0  : out   std_ulogic_vector(31 downto 0);

    clk1   : in    std_ulogic;
    csb1   : in    std_ulogic;
    addr1  : in    std_ulogic_vector( 8 downto 0);
    dout1  : out   std_ulogic_vector(31 downto 0)
  );
end entity sky130_sram_2kbyte_1rw1r_32x512_8;


architecture beh of sky130_sram_2kbyte_1rw1r_32x512_8 is

  constant T_HOLD   : time := 1 ps;
  constant T_DELAY  : time := 3 ps;

  signal csb0_reg   : std_ulogic;
  signal web0_reg   : std_ulogic;
  signal wmask0_reg : std_ulogic_vector(wmask0'length-1 downto 0);
  signal addr0_reg  : std_ulogic_vector(addr0'length-1  downto 0);
  signal din0_reg   : std_ulogic_vector(din0'length-1   downto 0);

  signal dout0_int  : std_logic_vector(din0'length-1 downto 0);
  signal dout1_int  : std_logic_vector(din0'length-1 downto 0);

  signal csb1_reg   : std_ulogic;
  signal addr1_reg  : std_ulogic_vector(addr1'length-1  downto 0);

  constant entries  : integer := (2**addr0'length);
  type ram_t is array(entries-1 downto 0) of std_ulogic_vector(din0'length-1 downto 0);

  -------------------------------------------------------------------------------
  -- mem_init
  -------------------------------------------------------------------------------
  -- pragma translate_off
  procedure mem_init(signal RAM : inout ram_t) is
    file     readfile       : text open read_mode is file_name_g;
    variable vecline        : line;

    variable add_ulv        : std_ulogic_vector(din0'length-1 downto 0);
    variable var_ulv        : std_ulogic_vector(din0'length-1 downto 0);

    variable add_int        : natural   := 0;
    variable addr_indicator : character := ' ';
  begin
    readline(readfile, vecline);

    read(vecline, addr_indicator);
    assert addr_indicator = '@' report "Incorrect address indicator: expecting @address" severity failure;

    hread(vecline, add_ulv);
    add_int := to_integer(unsigned(add_ulv));
        	      
    while not endfile(readfile) loop
      ----------------------------------------------------------------------
      -- read data
      -----------------------------------------------------------------------
      readline(readfile, vecline);
      hread(vecline, var_ulv);

      if(add_int > entries-1) then
        assert false report "Address out of range while filling memory" severity failure;
      else
        ram(add_int) <= var_ulv;
        add_int      := add_int + 1;
      end if;
    end loop;
    assert false report "Memory filling successfull" severity note;
  end procedure mem_init;
  -- pragma translate_on

  constant random_pattern_c : std_ulogic_vector(din0'length-1 downto 0) := std_ulogic_vector(resize(unsigned'(X"DEADBEAFAFFEDEAD"), din0'length));

  -- TODO: this is to stop annoying conversion warnings but might hide bugs
  signal mem : ram_t := (others => random_pattern_c);

begin
  -----------------------------------------------------------------------------
  -- register port0 inputs
  -----------------------------------------------------------------------------
  reg0: process(clk0) is
  begin
    if rising_edge(clk0) then
      csb0_reg   <= csb0;
      web0_reg   <= web0;
      wmask0_reg <= wmask0;
      addr0_reg  <= addr0;
      din0_reg   <= din0;
    end if;
  end process reg0;

  -----------------------------------------------------------------------------
  -- register port1 inputs
  -----------------------------------------------------------------------------
  reg1: process(clk1) is
  begin
    if rising_edge(clk1) then
      csb1_reg   <= csb1;
      addr1_reg  <= addr1;
    end if;
  end process reg1;

  -----------------------------------------------------------------------------
  -- memory write port 0
  -----------------------------------------------------------------------------
  write0: process(clk0) is
    variable readcontents : boolean := true;
  begin
    -- pragma translate_off
    if(readcontents = true and file_name_g /= "none") then
      mem_init(mem);
    end if;
    readcontents := false;
    -- pragma translate_on

    if rising_edge(clk0) then
      if(csb0_reg = '0' and web0_reg = '0') then
	if wmask0_reg(0) = '1' then
          mem(to_integer(unsigned(addr0_reg)))( 7 downto  0) <= din0_reg( 7 downto  0);
        end if;	
	if wmask0_reg(1) = '1' then
          mem(to_integer(unsigned(addr0_reg)))(15 downto  8) <= din0_reg(15 downto  8);
	end if;
	if wmask0_reg(2) = '1' then
          mem(to_integer(unsigned(addr0_reg)))(23 downto 16) <= din0_reg(23 downto 16);
	end if;
	if wmask0_reg(3) = '1' then
          mem(to_integer(unsigned(addr0_reg)))(31 downto 24) <= din0_reg(31 downto 24);
	end if;
      end if;
    end if;
    
  end process write0;

  -----------------------------------------------------------------------------
  -- memory read port 0
  -----------------------------------------------------------------------------
  read0: process(clk0) is
  begin
    if falling_edge(clk0) then
      if(csb0_reg = '0' and web0_reg = '1') then
        dout0_int <= mem(to_integer(unsigned(addr0_reg))) after T_DELAY;
      end if;
    elsif rising_edge(clk0) then
      dout0_int <= random_pattern_c after T_HOLD;
    end if;
  end process read0;

  -----------------------------------------------------------------------------
  -- memory read port 1
  -----------------------------------------------------------------------------
  read1: process(clk1) is
  begin
    if falling_edge(clk1) then
      if(csb1_reg = '0') then
        dout1_int <= mem(to_integer(unsigned(addr1_reg))) after T_DELAY;
      end if;
    elsif rising_edge(clk1) then
      dout1_int <= random_pattern_c after T_HOLD;
    end if;
  end process read1;

  dout0 <= std_ulogic_vector(dout0_int);
  dout1 <= std_ulogic_vector(dout1_int);

end architecture beh;

