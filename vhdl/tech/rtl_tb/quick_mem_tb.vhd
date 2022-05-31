library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tech;
use tech.tech_constants_pkg.all;
use tech.mem_pkg.all;

entity quick_mem_tb is
end entity quick_mem_tb;

architecture beh of quick_mem_tb is

signal sim_done                : boolean   := false;
signal clk                     : std_logic := '0';
signal reset_n                 : std_logic := '0';
constant clk_cycle_c           : time      := 10 ns;

constant rom_size_c            : integer   := 8;
constant data_width_c          : integer   := 32;

signal we   : std_logic := '0';
signal addr : std_logic_vector(rom_size_c-2-1 downto 0) := (others => '0');
signal di   : std_logic_vector(data_width_c-1 downto 0) := (others => '0');
signal do   : std_logic_vector(data_width_c-1 downto 0) := (others => '0');

begin
  -----------------------------------------------------------------------------
  -- clock and reset
  -----------------------------------------------------------------------------
  clk     <= not clk after clk_cycle_c/2 when sim_done = false;
  reset_n <= '1' after 500 ns;


  memi0: entity tech.sp_sync_mem_beh
    generic map (
      file_name_g  => "mem.in",
      addr_width_g => rom_size_c-2,
      data_width_g => data_width_c
    )
    port map (
      clk_i  => clk,
      we_i   => we,
      en_i   => '1',
      addr_i => addr,
      di_i   => di,
      do_o   => do
    );


  stim0: process is
  begin
    wait until reset_n = '1';

    wait until rising_edge(clk);
    addr <= std_logic_vector(to_unsigned(0, addr'length));

    wait until rising_edge(clk);
    addr <= std_logic_vector(to_unsigned(1, addr'length));

    wait until rising_edge(clk);
    addr <= std_logic_vector(to_unsigned(2, addr'length));

    wait until rising_edge(clk);
    addr <= std_logic_vector(to_unsigned(3, addr'length));

    wait until rising_edge(clk);
    addr <= std_logic_vector(to_unsigned(4, addr'length));


    wait for 100 us;
    sim_done <= true;
    assert false report "simulation finished successfully!" severity failure;
  end process stim0;


end architecture beh;



