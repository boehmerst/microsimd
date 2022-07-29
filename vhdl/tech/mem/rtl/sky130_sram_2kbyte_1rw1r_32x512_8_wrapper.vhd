library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sky130_sram_2kbyte_1rw1r_32x512_8_wrapper is
  -- pragma translate_off
  generic (
    file_name_g  : string := "none";
    addr_width_g : integer;
    data_width_g : integer
  );
  -- pragma translate_on
  port (
    clk_i  : in  std_logic;
    we_i   : in  std_logic_vector(data_width_g/8-1 downto 0);
    en_i   : in  std_logic;
    addr_i : in  std_logic_vector(addr_width_g-1 downto 0);
    di_i   : in  std_logic_vector(data_width_g-1 downto 0);
    do_o   : out std_logic_vector(data_width_g-1 downto 0)
  );
end entity sky130_sram_2kbyte_1rw1r_32x512_8_wrapper;

architecture beh of sky130_sram_2kbyte_1rw1r_32x512_8_wrapper is

  constant addr_width_c : positive := 9;
  constant data_width_c : positive := 32;

  signal addr0  : std_ulogic_vector(addr_width_c-1   downto 0);
  signal din0   : std_ulogic_vector(data_width_c-1   downto 0);
  signal dout0  : std_ulogic_vector(data_width_c-1   downto 0);
  signal wmask0 : std_ulogic_vector(data_width_c/8-1 downto 0); 
  signal web0   : std_ulogic;
  signal csb0   : std_ulogic;

begin

  addr0 <= std_logic_vector(resize(unsigned(addr_i), addr0'length));
  din0  <= std_logic_vector(resize(unsigned(di_i),   din0'length));
  do_o  <= std_logic_vector(resize(unsigned(dout0),  do_o'length));

  web0   <= not (we_i(0) or we_i(1) or we_i(2) or we_i(3));
  csb0   <= not en_i;
  wmask0 <= we_i;

  memi0: entity work.sky130_sram_2kbyte_1rw1r_32x512_8
    -- pragma translate_off
    generic map (
      file_name_g => file_name_g
    )
    -- pragma translate_on
    port map (
      clk0   => clk_i,
      csb0   => csb0,
      web0   => web0,
      wmask0 => wmask0,
      addr0  => addr0,
      din0   => din0,
      dout0  => dout0,
      clk1   => clk_i,
      csb1   => '1',
      addr1  => (others=>'0'),
      dout1  => open
    );

end architecture beh;


