library ieee;
use ieee.std_logic_1164.all;

package mem_pkg is
-------------------------------------------------------------------------------
-- single port synchronous memory
-------------------------------------------------------------------------------
component sp_sync_mem is
  generic (
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clk_i  : in  std_logic;
    we_i   : in  std_logic;
    en_i   : in  std_logic;
    addr_i : in  std_logic_vector(addr_width_g-1 downto 0);
    di_i   : in  std_logic_vector(data_width_g-1 downto 0);
    do_o   : out std_logic_vector(data_width_g-1 downto 0)
  );
end component sp_sync_mem;

-------------------------------------------------------------------------------
-- single port memory with asynchronous read port
-------------------------------------------------------------------------------
component sp_async_mem is
  generic (
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clk_i  : in  std_logic;
    we_i   : in  std_logic;
    addr_i : in  std_logic_vector(addr_width_g-1 downto 0);
    di_i   : in  std_logic_vector(data_width_g-1 downto 0);
    do_o   : out std_logic_vector(data_width_g-1 downto 0)
  );
end component sp_async_mem;

-------------------------------------------------------------------------------
-- dual port memory with asyncronous read port
-------------------------------------------------------------------------------
component dp_async_mem is
  generic (
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clk_i     : in  std_logic;
    we_i      : in  std_logic;
    sp_addr_i : in  std_logic_vector(addr_width_g-1 downto 0);
    dp_addr_i : in  std_logic_vector(addr_width_g-1 downto 0);
    di_i      : in  std_logic_vector(data_width_g-1 downto 0);
    spo_o     : out std_logic_vector(data_width_g-1 downto 0);
    dpo_o     : out std_logic_vector(data_width_g-1 downto 0)
  );
end component dp_async_mem;

-------------------------------------------------------------------------------
-- dual port memory with syncronous read port
-------------------------------------------------------------------------------
component dp_sync_mem is
  generic (
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clk_i     : in  std_logic;
    we_i      : in  std_logic;
    sp_addr_i : in  std_logic_vector(addr_width_g-1 downto 0);
    dp_addr_i : in  std_logic_vector(addr_width_g-1 downto 0);
    di_i      : in  std_logic_vector(data_width_g-1 downto 0);
    spo_o     : out std_logic_vector(data_width_g-1 downto 0);
    dpo_o     : out std_logic_vector(data_width_g-1 downto 0)
  );
end component dp_sync_mem;

-------------------------------------------------------------------------------
-- dual port memory with two clocks
-------------------------------------------------------------------------------
component dp_2wr_sync_mem is
  generic (
    addr_width_g : integer;
    data_width_g : integer
  );
  port (
    clka_i  : in  std_logic;
    clkb_i  : in  std_logic;
    ena_i   : in  std_logic;
    enb_i   : in  std_logic;
    wea_i   : in  std_logic;
    web_i   : in  std_logic;
    addra_i : in  std_logic_vector(addr_width_g downto 0);
    addrb_i : in  std_logic_vector(addr_width_g downto 0);
    dia_i   : in  std_logic_vector(data_width_g downto 0);
    dib_i   : in  std_logic_vector(data_width_g downto 0);
    doa_o   : out std_logic_vector(data_width_g downto 0);
    dob_o   : out std_logic_vector(data_width_g downto 0)
  );
end component dp_2wr_sync_mem;

end package mem_pkg;

