library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hibi;
use hibi.cfg_init_pkg.all;

entity cfg_mem_static is
  generic (
    id_width_g       : integer := 4;
    id_g             : integer := 5;
    data_width_g     : integer := 16;
    counter_width_g  : integer := 8;
    cfg_addr_width_g : integer := 7;   

    inv_addr_en_g    : integer := 0;
    addr_g           : integer := 46;
    prior_g          : integer := 2;
    max_send_g       : integer := 50;

    arb_type_g       : integer := 0;
    n_agents_g       : integer := 4;
    n_cfg_pages_g    : integer := 1;
    n_time_slots_g   : integer := 0;
    cfg_re_g         : integer := 0;
    cfg_we_g         : integer := 0
    );

  port (
    clk                  : in std_logic;
    rst_n                : in std_logic;
    addr_in              : in std_logic_vector (cfg_addr_width_g -1 downto 0);
    data_in              : in std_logic_vector (data_width_g -1 downto 0);
    re_in                : in std_logic;
    we_in                : in std_logic;

    curr_slot_ends_out   : out std_logic;
    curr_slot_own_out    : out std_logic;
    next_slot_starts_out : out std_logic;
    next_slot_own_out    : out std_logic;
    dbg_out              : out integer range 0 to 100;  -- For debug

    data_out             : out std_logic_vector (data_width_g-1 downto 0);
    arb_type_out         : out std_logic_vector (1 downto 0);
    n_agents_out         : out std_logic_vector (id_width_g-1 downto 0);
    max_send_out         : out std_logic_vector (counter_width_g-1 downto 0);
    prior_out            : out std_logic_vector (id_width_g-1 downto 0);
    pwr_mode_out         : out std_logic_vector (1 downto 0)
    );
end cfg_mem_static;


architecture rtl of cfg_mem_static is
begin

  curr_slot_ends_out   <= '0';
  curr_slot_own_out    <= '0';
  next_slot_starts_out <= '0';
  next_slot_own_out    <= '0';
  dbg_out              <=  0;
  data_out             <= (others => '0');
  arb_type_out         <= (others => '0');
  n_agents_out         <= std_logic_vector(to_unsigned(n_agents_g, n_agents_out'length));
  max_send_out         <= std_logic_vector(to_unsigned(max_send_g, max_send_out'length));
  prior_out            <= std_logic_vector(to_unsigned(prior_g, prior_out'length));
  pwr_mode_out         <= (others => '0');
  
end architecture rtl;
