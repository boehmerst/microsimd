library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cordic_kernel is
  generic (
    vec_width_g       : natural range 2 to integer'high := 16; -- (x,y) vector width
    phase_width_g     : natural range 2 to integer'high := 16; -- phase width
    phase_magnitude_g : natural range 3 to integer'high := 3;  -- magnitude of phase 
    iter_g            : natural;                               -- iteration step
    registered_g      : std_ulogic                             -- registered output
  );
  port (
    clk_i      : in  std_ulogic;
    reset_n_i  : in  std_ulogic;
    en_i       : in  std_ulogic;
    init_i     : in  std_ulogic;
    add_ctrl_i : in  std_ulogic;
    x_i        : in  std_ulogic_vector(vec_width_g-1   downto 0);
    y_i        : in  std_ulogic_vector(vec_width_g-1   downto 0);
    z_i        : in  std_ulogic_vector(phase_width_g-1 downto 0);
    x_o        : out std_ulogic_vector(vec_width_g-1   downto 0);
    y_o        : out std_ulogic_vector(vec_width_g-1   downto 0);
    z_o        : out std_ulogic_vector(phase_width_g-1 downto 0)
  );
end entity cordic_kernel;

architecture rtl of cordic_kernel is
  ------------------------------------------------------------------------------
  -- arithmetic shift right
  ------------------------------------------------------------------------------	
	function delta(v : signed; shift : natural) return signed is
	  variable result : signed(v'length-1 downto 0);
	begin
	  result := (v'left downto v'left-shift => v(v'left)) & v(v'left-1 downto shift);

    if(shift /= 0 and shift /= v'length-1) then -- round arg < -0.5 -> 0 
      if( v(v'left-1 downto shift) = (v'left-1 downto shift => '1') and v(shift-1) = '1') then
        result := (others=>'0');
      end if;
    end if;

	  return result;
	end function delta;

  ------------------------------------------------------------------------------
  -- add, sub
  ------------------------------------------------------------------------------
	function addsub(dataa, datab : in signed; add_sub : in std_ulogic) return signed is
	begin
		if (add_sub = '1') then
			return dataa + datab;
		else
			return dataa - datab;
		end if;
	end function addsub;

  constant mul_c  : real := 2.0**(phase_width_g-phase_magnitude_g);
  constant atan_c : integer := integer(arctan(real(2.0**(-iter_g))) * mul_c);

  signal xi   : signed(vec_width_g-1   downto 0);
  signal yi   : signed(vec_width_g-1   downto 0);
  signal zi   : signed(phase_width_g-1 downto 0);

  signal dx   : signed(vec_width_g-1   downto 0);
  signal dy   : signed(vec_width_g-1   downto 0);
  signal dz   : signed(phase_width_g-1 downto 0);
  
  signal add_ctrl   : std_ulogic;
  signal add_ctrl_n : std_ulogic;

begin
  -----------------------------------------------------------------------------
  -- cordic step
  -----------------------------------------------------------------------------
  xi   <= signed(x_i);
  yi   <= signed(y_i);
  zi   <= signed(z_i);
  
  add_ctrl   <= add_ctrl_i;
  add_ctrl_n <= not add_ctrl_i;
  
  dx   <= addsub(xi, delta(yi, iter_g), add_ctrl_n);
  dy   <= addsub(yi, delta(xi, iter_g), add_ctrl);
  dz   <= addsub(zi, to_signed(atan_c, dz'length), add_ctrl_n);

  -----------------------------------------------------------------------------
  -- conditional register stage
  -----------------------------------------------------------------------------
  reg_block: block is
    signal x_reg : std_ulogic_vector(vec_width_g-1 downto 0);
    signal y_reg : std_ulogic_vector(vec_width_g-1 downto 0);
    signal z_reg : std_ulogic_vector(vec_width_g-1 downto 0);
  begin
    gen_reg: if registered_g = '1' generate 
      sync0: process(clk_i, reset_n_i)  is
        begin
          if(reset_n_i = '0') then
            x_reg     <= (others=>'0');
            y_reg     <= (others=>'0');
            z_reg     <= (others=>'0');
          elsif(rising_edge(clk_i)) then
            if(en_i = '1') then
              if(init_i = '1') then
                x_reg <= (others=>'0');
                y_reg <= (others=>'0');
                z_reg <= (others=>'0');
              else
                x_reg <= std_ulogic_vector(dx);
                y_reg <= std_ulogic_vector(dy);
                z_reg <= std_ulogic_vector(dz);
              end if;
            end if;
          end if;
        end process sync0;

      x_o <= x_reg;
      y_o <= y_reg;
      z_o <= z_reg;
    end generate gen_reg;

    gen_out: if registered_g = '0' generate
      x_o <= std_ulogic_vector(dx);
      y_o <= std_ulogic_vector(dy);
      z_o <= std_ulogic_vector(dz);
    end generate;

    --x_o <= x_reg when registered_g = '1' else std_ulogic_vector(dx);
    --y_o <= y_reg when registered_g = '1' else std_ulogic_vector(dy);
    --z_o <= z_reg when registered_g = '1' else std_ulogic_vector(dz);

  end block reg_block;

end architecture rtl;

