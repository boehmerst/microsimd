library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tech;
use tech.tech_constants_pkg.all;

entity sp_sync_mem is
  generic (
    file_name_g  : string := "none";
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clk_i  : in  std_logic;
    we_i   : in  std_logic_vector(data_width_g/8-1 downto 0);
    en_i   : in  std_logic;
    addr_i : in  std_logic_vector(addr_width_g-1 downto 0);
    di_i   : in  std_logic_vector(data_width_g-1 downto 0);
    do_o   : out std_logic_vector(data_width_g-1 downto 0)
  );
end entity sp_sync_mem;

architecture struct of sp_sync_mem is
begin
-------------------------------------------------------------------------------
-- just to make sure the technology is supported
-------------------------------------------------------------------------------
assert( target_tech_c = tech_behave_c or
        target_tech_c = tech_xilinx_c or
	target_tech_c = tech_sky130_c) report "unsupported technology"
        severity failure;

-------------------------------------------------------------------------------
-- TODO: add byte access or implement two versions
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- conditionally instanciate behavioural memory
-------------------------------------------------------------------------------
behave: if target_tech_c = tech_behave_c generate
  memi0: entity tech.sp_sync_mem_beh
    generic map (
      file_name_g  => file_name_g,
      addr_width_g => addr_width_g,
      data_width_g => data_width_g
    )
    port map (
      clk_i  => clk_i,
      we_i   => we_i(0),
      en_i   => en_i,
      addr_i => addr_i,
      di_i   => di_i,
      do_o   => do_o
    );
end generate behave;

-------------------------------------------------------------------------------
-- conditionally instanciate xilinx memory
-------------------------------------------------------------------------------
xilinx: if target_tech_c = tech_xilinx_c generate
  memi0: entity tech.sp_sync_mem_beh
    generic map (
      addr_width_g => addr_width_g,
      data_width_g => data_width_g
    )
    port map (
      clk_i  => clk_i,
      we_i   => we_i(0),
      en_i   => en_i,
      addr_i => addr_i,
      di_i   => di_i,
      do_o   => do_o
    );
end generate xilinx;

-------------------------------------------------------------------------------
-- conditionally instantiate sky130
-------------------------------------------------------------------------------
sky130: if target_tech_c = tech_sky130_c generate
  wrap: block is
    constant addr_width_c : positive := 9;
    constant data_width_c : positive := 32;

    signal addr0  : std_ulogic_vector(addr_width_c-1   downto 0);
    signal din0   : std_ulogic_vector(data_width_c-1   downto 0);
    signal dout0  : std_ulogic_vector(data_width_c-1   downto 0);
    signal wmask0 : std_ulogic_vector(data_width_c/8-1 downto 0); 
    signal web0   : std_ulogic;
    signal csb0   : std_ulogic;

  begin
    assert addr0'length = addr_i'length report "Memory size missmatch, truncation or wraparound will happen" severity warning;
    assert din0'length = di_i'length report "Memory width missmatch, truncation or extention will happen" severity warning;

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
  end block wrap;
end generate sky130;

end architecture struct;

