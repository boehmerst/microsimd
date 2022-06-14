library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library general;

entity dp_fifo_beh is
  generic (
    data_width_g : integer;
    addr_width_g : integer
  );
  port (
    -- Reading port.
    data_o  : out std_logic_vector(data_width_g-1 downto 0);
    empty_o : out std_logic;
    rd_i    : in  std_logic;
    rclk_i  : in  std_logic;
    -- Writing port.
    data_i  : in  std_logic_vector(data_width_g-1 downto 0);
    full_o  : out std_logic;
    wr_i    : in  std_logic;
    wclk_i  : in  std_logic;
 	 
    clear_i : in  std_logic
  );
end entity dp_fifo_beh;

architecture rtl of dp_fifo_beh is

  ---/Internal connections & variables------
  constant fifo_depth_c :integer := 2**addr_width_g;
  
  type ram_t is array (integer range <>) of std_logic_vector(data_width_g-1 downto 0);
  signal mem : ram_t (0 to fifo_depth_c-1);
  
  signal p_next_word_to_write  : std_logic_vector(addr_width_g-1 downto 0);
  signal p_next_word_to_read   : std_logic_vector(addr_width_g-1 downto 0);
  signal equal_addresses       : std_logic;
  signal next_write_address_en : std_logic;
  signal next_read_address_en  : std_logic;
  signal set_status            : std_logic;
  signal rst_status            : std_logic;
  signal status                : std_logic;
  signal preset_full           : std_logic;
  signal preset_empty          : std_logic;
  signal empty,full            : std_logic;
  
begin
  
  --------------Code--------------/
  --Data ports logic:
  --(Uses a dual-port RAM).
  --'data_o' logic:
  process (rclk_i) begin
    if (rising_edge(rclk_i)) then
      if (rd_i = '1' and empty = '0') then
        data_o <= mem(to_integer(unsigned(p_next_word_to_read)));
      end if;
    end if;
  end process;
           
  --'data_i' logic:
  process (wclk_i) begin
    if (rising_edge(wclk_i)) then
      if (wr_i = '1' and full = '0') then
        mem(to_integer(unsigned(p_next_word_to_write))) <= data_i;
      end if;
    end if;
  end process;
  
  --Fifo addresses support logic: 
  --'Next Addresses' enable logic:
  next_write_address_en <= wr_i and (not full);
  next_read_address_en  <= rd_i and (not empty);
          
  --Addreses (Gray counters) logic:
  gray_counter_wr : entity general.graycount
  generic map (
    counter_width_g => addr_width_g
  )
  port map (
    count_o => p_next_word_to_write,
    ena_i   => next_write_address_en,
    clear_i => clear_i,
    clk     => wclk_i
  );
      
  gray_counter_rd : entity general.graycount
  generic map (
    counter_width_g => addr_width_g
  )
  port map (
    count_o => p_next_word_to_read,
    ena_i   => next_read_address_en,
    clear_i => clear_i,
    clk     => rclk_i
  );
  
  --'equal_addresses' logic:
  equal_addresses <= '1' when (p_next_word_to_write = p_next_word_to_read) else '0';
  
  --'Quadrant selectors' logic:
  process (p_next_word_to_write, p_next_word_to_read)
    variable set_status_bit0 :std_logic;
    variable set_status_bit1 :std_logic;
    variable rst_status_bit0 :std_logic;
    variable rst_status_bit1 :std_logic;
  begin
    set_status_bit0 := p_next_word_to_write(addr_width_g-2) xnor p_next_word_to_read(addr_width_g-1);
    set_status_bit1 := p_next_word_to_write(addr_width_g-1) xor  p_next_word_to_read(addr_width_g-2);
    set_status      <= set_status_bit0 and set_status_bit1;
       
    rst_status_bit0 := p_next_word_to_write(addr_width_g-2) xor  p_next_word_to_read(addr_width_g-1);
    rst_status_bit1 := p_next_word_to_write(addr_width_g-1) xnor p_next_word_to_read(addr_width_g-2);
    rst_status      <= rst_status_bit0 and rst_status_bit1;
   end process;
   
  --'status' latch logic:
  process (set_status, rst_status, clear_i) begin 
    if (rst_status = '1' or clear_i = '1') then
      status <= '0'; --Going 'Empty'.
    elsif (set_status = '1') then
      status <= '1'; --Going 'Full'.
    end if;
  end process;
   
  --'full_o' logic for the writing port:
  preset_full <= status and equal_addresses; --'Full' Fifo.
   
  process (wclk_i, preset_full) begin --D Flip-Flop w/ Asynchronous Preset.
    if (preset_full = '1') then
      full <= '1';
    elsif (rising_edge(wclk_i)) then
      full <= '0';
    end if;
  end process;
  full_o <= full;
   
  --'empty_o' logic for the reading port:
  preset_empty <= not status and equal_addresses; --'Empty' Fifo.
   
  process (rclk_i, preset_empty) begin --D Flip-Flop w/ Asynchronous Preset.
    if (preset_empty = '1') then
      empty <= '1';
    elsif (rising_edge(rclk_i)) then
      empty <= '0';
    end if;
   end process;
   
   empty_o <= empty;
   
end architecture rtl;
