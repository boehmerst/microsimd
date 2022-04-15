library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.core_pkg.all;

entity mul32x32_tb is
end entity mul32x32_tb;

architecture beh of mul32x32_tb is
  signal sim_done                : boolean   := false;
  signal clk                     : std_logic := '0';
  signal reset                   : std_logic := '0';
  constant clk_cycle_c           : time      := 10 ns;
  
  signal mul                     : mul32_in_t;
  signal duti0_mul               : mul32_out_t;
  
begin
  -----------------------------------------------------------------------------
  -- clock and reset
  -----------------------------------------------------------------------------
  clk   <= not clk after clk_cycle_c/2 when sim_done = false;
  reset <= '1' after 500 ns;
  
  duti0: entity work.mul32x32
    port map (
      reset_n_i => reset,
      clk_i     => clk,
      en_i      => '1',
      init_i    => '0',
      mul_i     => mul,
      mul_o     => duti0_mul
    );
  
  -----------------------------------------------------------------------------
  -- stimuli
  -----------------------------------------------------------------------------
  stim0: process is
  begin
    mul.op_a  <= x"00000000";
    mul.op_b  <= x"00000000";
    mul.sign  <= U;
    mul.start <= '0';
    mul.mac   <= '0';
    mul.op    <= ADD;
    mul.long  <= '0';
    mul.acc   <= x"0000000000000000";
    
    wait until reset = '1';
    wait until rising_edge(clk);

    mul.op_a  <= std_ulogic_vector(to_signed(1, mul.op_a'length));
    mul.op_b  <= std_ulogic_vector(to_signed(-100, mul.op_b'length));
    mul.sign  <= S;
    mul.start <= '1';
    mul.mac   <= '1';
    mul.op    <= ADD;
    mul.long  <= '0';
    mul.acc   <= x"0000000000000002";
    
    wait until rising_edge(clk);
    mul.start <= '0';
    --mul.sign  <= '0';

    -- quit simulation
    wait for 10 us;
    sim_done <= true;
    assert false report "Simulation finished successfully!" severity failure;
    wait;
  end process stim0;
  
end architecture beh;

