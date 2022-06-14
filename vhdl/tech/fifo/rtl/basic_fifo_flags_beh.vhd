-------------------------------------------------------------------------------
-- file downloaded from http://www.nandland.com
--
-- description: creates a synchronous fifo made out of registers.
--              generic: g_width sets the width of the fifo created.
--              generic: g_depth sets the depth of the fifo created.
--
--              total fifo register usage will be width * depth
--              note that this fifo should not be used to cross clock domains.
--              (read and write clocks need to be the same clock domain)
--
--              fifo full flag will assert as soon as last word is written.
--              fifo empty flag will assert as soon as last word is read.
--
--              fifo is 100% synthesizable.  it uses assert statements which do
--              not synthesize, but will cause your simulation to crash if you
--              are doing something you shouldn't be doing (reading from an
--              empty fifo or writing to a full fifo).
--
--              with flags = has almost full (af)/almost empty (ae) flags
--              these are settable via generics: g_af_level and g_ae_level
--              g_af_level: goes high when # words in fifo is > this number.
--              g_ae_level: goes high when # words in fifo is < this number.
-------------------------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library general;
use general.general_function_pkg.all;
 
entity basic_fifo_flags_beh is
  generic (
    width_g        : natural := 8;
    depth_g        : integer := 32;
    af_level_g     : integer := 28;
    ae_level_g     : integer := 4
    );
  port (
    reset_n_i      : in std_logic;
    clk_i          : in std_logic;
 
    -- fifo write interface
    wr_en_i        : in  std_logic;
    wr_data_i      : in  std_logic_vector(width_g-1 downto 0);
    almost_full_o  : out std_logic;
    full_o         : out std_logic;
 
    -- fifo read interface
    rd_en_i        : in  std_logic;
    rd_data_o      : out std_logic_vector(width_g-1 downto 0);
    almost_empty_o : out std_logic;
    empty_o        : out std_logic
  );
end entity basic_fifo_flags_beh;
 
architecture rtl of basic_fifo_flags_beh is
 
  type t_fifo_data is array (0 to depth_g-1) of std_logic_vector(width_g-1 downto 0);
  signal r_fifo_data : t_fifo_data; -- := (others => (others => '0'));
 
  --signal r_wr_index   : unsigned(log2ceil(depth_g)-1 downto 0);

  signal r_wr_index   : integer range 0 to depth_g-1;
  signal r_rd_index   : integer range 0 to depth_g-1;
 
  -- # words in fifo, has extra range to allow for assert conditions
  signal r_fifo_count : integer range 0 to depth_g;
 
  signal w_full  : std_logic;
  signal w_empty : std_logic;
   
begin
 
  p_control : process (clk_i, reset_n_i) is
  begin
    if reset_n_i = '0' then
      r_fifo_count <= 0;
      r_wr_index   <= 0;
      r_rd_index   <= 0;
      r_fifo_data  <= (others => (others => '0'));
    elsif rising_edge(clk_i) then
      -- keeps track of the total number of words in the fifo
      if (wr_en_i = '1' and rd_en_i = '0') then
        r_fifo_count <= r_fifo_count + 1;
      elsif (wr_en_i = '0' and rd_en_i = '1') then
        r_fifo_count <= r_fifo_count - 1;
      end if;
 
      -- keeps track of the write index (and controls roll-over)
      if (wr_en_i = '1' and w_full = '0') then
        if r_wr_index = depth_g-1 then
          r_wr_index <= 0;
        else
          r_wr_index <= r_wr_index + 1;
        end if;
      end if;
 
      -- keeps track of the read index (and controls roll-over)        
      if (rd_en_i = '1' and w_empty = '0') then
        if r_rd_index = depth_g-1 then
          r_rd_index <= 0;
        else
          r_rd_index <= r_rd_index + 1;
        end if;
      end if;
 
      -- registers the input data when there is a write
      if wr_en_i = '1' then
        r_fifo_data(r_wr_index) <= wr_data_i;
      end if;
    end if;
  end process p_control;
 
   
  rd_data_o <= r_fifo_data(r_rd_index);
 
  w_full  <= '1' when r_fifo_count = depth_g else '0';
  w_empty <= '1' when r_fifo_count = 0       else '0';
 
  almost_full_o  <= '1' when r_fifo_count > af_level_g else '0';
  almost_empty_o <= '1' when r_fifo_count < ae_level_g else '0';
   
  full_o  <= w_full;
  empty_o <= w_empty;
   
 
  -----------------------------------------------------------------------------
  -- assertion logic - not synthesized
  -----------------------------------------------------------------------------
  -- synthesis translate_off
 
  p_assert : process (clk_i) is
  begin
    if rising_edge(clk_i) then
      if wr_en_i = '1' and w_full = '1' then
        report "assert failure - module_register_fifo: fifo is full and being written " severity failure;
      end if;
 
      if rd_en_i = '1' and w_empty = '1' then
        report "assert failure - module_register_fifo: fifo is empty and being read " severity failure;
      end if;
    end if;
  end process p_assert;
 
  -- synthesis translate_on
     
   
end architecture rtl;
