library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_count_async_set is
  generic (
    width_g : natural
  );
  port (
    reset_n   : in  std_logic;
    clk_i     : in  std_logic;
    set_n_i   : in  std_logic;
    clear_n_i : in  std_logic;
    en_i      : in  std_logic;
    count_o   : out std_logic_vector(width_g-1 downto 0)
  );
end entity gen_count_async_set;


architecture beh of gen_count_async_set is

signal count : unsigned(width_g-1 downto 0);
  
begin
  count_o <= std_logic_vector(count);

  sync : process (clk_i, reset_n)
  begin
    if(reset_n = '0') then
      count   <= (others => '1');
    elsif(rising_edge(clk_i)) then
      if set_n_i = '0' then
        count <= (others => '1');
      elsif clear_n_i = '0' then
        count <= (others => '0');
      elsif en_i = '1' then
        count <= count + 1;
      end if;
    end if;
  end process sync;

end architecture beh;

