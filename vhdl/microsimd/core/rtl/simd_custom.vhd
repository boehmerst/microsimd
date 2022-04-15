library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.vec_data_pkg.all;

entity simd_custom is
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;
    en_i      : in  std_ulogic;
    init_i    : in  std_ulogic;
    start_i   : in  std_ulogic;
    cmd_i     : in  std_ulogic_vector(2 downto 0);
    veca_i    : in  vec_data_t;
    vecb_i    : in  vec_data_t;
    result_o  : out vec_data_t;
    ready_o   : out std_ulogic
  );
end entity simd_custom;

architecture rtl of simd_custom is

  signal customi0_resulta : vec_data_t;
  signal customi0_resultb : vec_data_t;
  signal custom0_start    : std_ulogic;
  signal custom0_mode     : std_ulogic;

begin
  -----------------------------------------------------------------------------
  -- custom 0 instruction
  -----------------------------------------------------------------------------
  custom0_start <= start_i when cmd_i(0) = '1' else '0';
  custom0_mode  <= cmd_i(1);

  customi0: entity work.custom_inst0
    port map (
      clk_i      => clk_i,
      reset_n_i  => reset_n_i,
      en_i       => en_i,
      init_i     => init_i,
      mode_i     => custom0_mode,
      start_i    => start_i,
      veca_i     => veca_i,
      vecb_i     => vecb_i,
      resulta_o  => customi0_resulta,
      resultb_o  => customi0_resultb,
      ready_o    => ready_o
    );

  result_o <= customi0_resulta when cmd_i(0) = '1' else customi0_resultb;

end architecture rtl;

