library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library general;
use general.general_function_pkg.log2ceil;

library microsimd;
use microsimd.hibi_pif_types_pkg.all;

entity mpsoc_tb is
end entity mpsoc_tb;

architecture beh of mpsoc_tb is

  constant nr_cols_c             : integer   := 40;
  constant nr_rows_c             : integer   := 30;
  
  constant lblank_c              : time      := 1 us;
  constant fblank_c              : time      := 100 us;
  
  constant clk_cycle_c           : time      := 10 ns;
  constant pif_clk_cycle_c       : time      := 15 ns;  

  signal sim_done                : boolean   := false;
  signal clk                     : std_logic := '0';
  signal reset                   : std_logic := '0';
  
  signal rxpif                   : hibi_pif_arr_t(0 to 1) := (others=>dflt_hibi_pif_c);

begin
  ------------------------------------------------------------------------------
  -- clock and reset
  ------------------------------------------------------------------------------
  clk           <= not clk after clk_cycle_c/2 when sim_done = false;
  rxpif(0).pclk <= not rxpif(0).pclk after pif_clk_cycle_c/2 when sim_done = false;
  reset         <= '1' after 500 ns;

  ------------------------------------------------------------------------------
  -- MPSoC
  ------------------------------------------------------------------------------
  duti0: entity microsimd.msmp
    generic map (
      nr_cpus_g  => 2
    )
    port map (
      clk_i      => clk,
      reset_n_i  => reset,
      pif_i      => rxpif,
      pif_o      => open
    );

  ------------------------------------------------------------------------------
  -- stimuli
  ------------------------------------------------------------------------------
  stim0: process is
    variable pix_count : integer := 0;
  begin
  
    wait until reset = '1';
    wait until rising_edge(clk);
    
    wait for 10 us;
    
    row_loop: for i in 0 to nr_rows_c-1 loop
      col_loop: for j in 0 to nr_cols_c-1 loop
        wait until falling_edge(rxpif(0).pclk);
        rxpif(0).vsync <= '1';
        rxpif(0).hsync <= '1';
        rxpif(0).data  <= std_ulogic_vector(unsigned(rxpif(0).data) + 1);
      end loop col_loop;
      
      wait until falling_edge(rxpif(0).pclk);
      rxpif(0).hsync   <= '0';
      wait for lblank_c;
    end loop row_loop;
    
    rxpif(0).vsync     <= '0';
    wait for fblank_c;

    -- quit simulation
    wait for 1000 us;
    sim_done <= true;
    assert false report "Simulation finished successfully!" severity failure;
    wait;
  end process stim0;

end architecture beh;

