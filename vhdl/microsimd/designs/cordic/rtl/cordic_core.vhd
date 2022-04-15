library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;

entity cordic_core is 
	generic (
		vec_width_g       : natural range 2 to integer'high := 16;
    phase_width_g     : natural range 2 to integer'high := 16;
    phase_magnitude_g : natural := 3;
		nr_stages_g       : natural := 16;
		register_g        : std_ulogic_vector
	);
	port (
	  clk_i     : in  std_ulogic;
	  reset_n_i : in  std_ulogic;
	  en_i      : in  std_ulogic;
	  init_i    : in  std_ulogic;
    mode_i    : in  std_ulogic;
		x_i       : in  std_ulogic_vector(vec_width_g-1   downto 0); 
		y_i	      : in  std_ulogic_vector(vec_width_g-1   downto 0);
		z_i	      : in  std_ulogic_vector(phase_width_g-1 downto 0);
		x_o	      : out std_ulogic_vector(vec_width_g-1   downto 0);
		y_o	      : out std_ulogic_vector(vec_width_g-1   downto 0);
		z_o	      : out std_ulogic_vector(phase_width_g-1 downto 0)
	);
end entity cordic_core;

architecture rtl of cordic_core is
  -----------------------------------------------------------------------------
  -- mode encoding
  -----------------------------------------------------------------------------
  constant mode_rot_c : std_ulogic := '1';
  constant mode_vec_c : std_ulogic := '0';

  -----------------------------------------------------------------------------
  -- +/-pi/4 for initial +/-pi/2 rotation
  -----------------------------------------------------------------------------
  constant mul_c       : real := 2.0**(phase_width_g-phase_magnitude_g);
  constant pi_over_4_c : std_ulogic_vector(phase_width_g-1 downto 0) 
    := std_ulogic_vector(to_signed(integer(MATH_PI_OVER_4 * mul_c), phase_width_g));
    
  constant neg_pi_over_4_c : std_ulogic_vector(phase_width_g-1 downto 0) 
    := std_ulogic_vector(to_signed(integer(-1.0 * MATH_PI_OVER_4 * mul_c), phase_width_g));
    
  -----------------------------------------------------------------------------
  -- vector and phase array type
  -----------------------------------------------------------------------------
  type vec_array_t   is array(natural range<>) of std_ulogic_vector(vec_width_g-1 downto 0);
  type phase_array_t is array(natural range<>) of std_ulogic_vector(phase_width_g-1 downto 0);

  signal x_vec        : std_ulogic_vector(vec_width_g-1 downto 0);
  signal y_vec        : std_ulogic_vector(vec_width_g-1 downto 0);
  signal z_vec        : std_ulogic_vector(phase_width_g-1 downto 0);
  signal add_ctrl_vec : std_ulogic_vector(nr_stages_g-1 downto 0);

  signal x_rot        : std_ulogic_vector(vec_width_g-1 downto 0);
  signal y_rot        : std_ulogic_vector(vec_width_g-1 downto 0);
  signal z_rot        : std_ulogic_vector(phase_width_g-1 downto 0);
  signal add_ctrl_rot : std_ulogic_vector(nr_stages_g-1 downto 0);

  signal x            : vec_array_t(0 to nr_stages_g);
  signal y            : vec_array_t(0 to nr_stages_g);
  signal z            : phase_array_t(0 to nr_stages_g);
  signal add_ctrl     : std_ulogic_vector(nr_stages_g-1 downto 0);

begin
  -----------------------------------------------------------------------------
  -- vectoring mode input mux (used for inital +/-pi/2 rotation also)
  -----------------------------------------------------------------------------
  add_ctrl_vec(0) <= '1' when y_i(y_i'left) = '0' and x_i(x_i'left) = '1' else
                     '0' when y_i(y_i'left) = '1' and x_i(x_i'left) = '1' else y_i(y_i'left);
                   
  x_vec           <= x_i when x_i(x_i'left) = '0' else (others=>'0');
  y_vec           <= y_i when x_i(x_i'left) = '0' else (others=>'0');
  
  z_vec           <= pi_over_4_c     when y_i(y_i'left) = '0' and x_i(x_i'left) = '1' else
                     neg_pi_over_4_c when y_i(y_i'left) = '1' and x_i(x_i'left) = '1' else (others=>'0');
   
  -----------------------------------------------------------------------------
  -- rotation mode (no initial rotation to adjust convergence intervall)
  -----------------------------------------------------------------------------
  add_ctrl_rot(0) <= not z(0)(z(0)'left);
  x_rot           <= x_i;
  y_rot           <= y_i;
  z_rot           <= z_i;

  -----------------------------------------------------------------------------
  -- control add vs. sub
  -----------------------------------------------------------------------------
  gen_add_ctrl0: for i in 1 to nr_stages_g-1 generate
    add_ctrl_vec(i) <= y(i)(y(i)'left);
    add_ctrl_rot(i) <= z(i)(z(i)'left);
  end generate gen_add_ctrl0;

  -----------------------------------------------------------------------------
  -- vectoring vs. rotation mux
  -----------------------------------------------------------------------------
  add_ctrl <= add_ctrl_vec when mode_i = mode_vec_c else add_ctrl_rot;
  x(0)     <= x_vec        when mode_i = mode_vec_c else x_rot;
  y(0)     <= y_vec        when mode_i = mode_vec_c else y_rot;
  z(0)     <= z_vec        when mode_i = mode_vec_c else z_rot;
  
  -----------------------------------------------------------------------------
  -- instanciate cordic stages
  -----------------------------------------------------------------------------
  gen_kernel: for i in 0 to nr_stages_g-1 generate
    kerneli : entity work.cordic_kernel
      generic map (
        vec_width_g       => vec_width_g,
        phase_width_g     => phase_width_g,
        phase_magnitude_g => phase_magnitude_g,
        iter_g            => i,
        registered_g      => register_g(i)
      )
      port map (
        clk_i      => clk_i,
        reset_n_i  => reset_n_i,
        en_i       => en_i,
        init_i     => init_i,
        add_ctrl_i => add_ctrl(i),
        x_i        => x(i),
        y_i        => y(i),
        z_i        => z(i),
        x_o        => x(i+1),
        y_o        => y(i+1),
        z_o        => z(i+1)
      );      
  end generate gen_kernel;

  x_o <= x(x'high);
  y_o <= y(y'high);
  z_o <= z(z'high);

end architecture rtl;

