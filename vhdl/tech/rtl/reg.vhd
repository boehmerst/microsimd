library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity reg is
  generic (
    reset_value_g : std_ulogic := '0';
    reset_level_g : std_ulogic := '0'
  );
  port (
    clk_i   : in  std_ulogic;
    reset_i : in  std_ulogic;
    en_i    : in  std_ulogic;
    init_i  : in  std_ulogic;
    d_i     : in  std_ulogic;
    d_o     : out std_ulogic
  );
end entity reg;

architecture rtl of reg is
begin

  sync0: process (clk_i, reset_i) is
  begin
    if reset_i = reset_level_g then
      d_o <= reset_value_g;
    elsif rising_edge(clk_i) then
      if en_i = '1' then
	if init_i = '1' then
	  d_o <= reset_value_g;
	else
	  d_o <= d_i;
	end if;
      end if;
    end if;
  end process sync0;

end architecture rtl;

