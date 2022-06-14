library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
      
entity graycount is
  generic (
    counter_width_g : integer
  );
  port (
    clk     : in  std_logic;
    ena_i   : in  std_logic;
    clear_i : in  std_logic;
    count_o : out std_logic_vector (counter_width_g-1 downto 0)
  );
end entity graycount;
 
architecture rtl of graycount is

  signal count : unsigned(counter_width_g-1 downto 0);

begin

  process (clk) begin
    if (rising_edge(clk)) then
      if (clear_i = '1') then
        --Gray count begins @ '1' with
        count   <= to_unsigned(1, count'length);  
        count_o <= (others=>'0');
        -- first 'ena_i'.
      elsif (ena_i = '1') then
        count   <= count + 1;
        count_o <= ( count(counter_width_g-1) & (std_logic_vector(count(counter_width_g-2 downto 0)) xor 
		                                 std_logic_vector(count(counter_width_g-1 downto 1))) );
      end if;
    end if;
  end process;

end architecture rtl;
