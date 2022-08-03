library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- TODO: use VHDL-2008 package to customize width
-- NOTE: This is a dirty hack since we pull the bit with out of an IP
-- which makes this package less general

library microsimd;
use microsimd.hibi_wishbone_bridge_pkg.all;
use microsimd.hibi_wishbone_bridge_regif_types_pkg.all;

library general;
use general.general_function_pkg.all;


package wishbone_pkg is

  constant wb_adr_width_c : integer := hibi_wishbone_bridge_addr_width_c+1;  -- max(hibi_wishbone_bridge_mem_addr_width_c, hibi_wishbone_bridge_addr_width_c)+1;
  constant wb_dat_width_c : integer := hibi_wishbone_bridge_data_width_c;    -- max(hibi_wishbone_bridge_mem_data_width_c, hibi_wishbone_bridge_data_width_c);

    type wb_req_t is record
    adr : std_ulogic_vector(wb_adr_width_c-1 downto 0);
    dat : std_ulogic_vector(wb_dat_width_c-1 downto 0);
    we  : std_ulogic;
    sel : std_ulogic_vector(wb_dat_width_c/8-1 downto 0);
    stb : std_ulogic;
    cyc : std_ulogic;
  end record wb_req_t;
  constant dflt_wb_req_c : wb_req_t := (
    adr => (others => '0'),
    dat => (others => '0'),
    we  => '0',
    sel => (others => '0'),
    stb => '0',
    cyc => '0'
  );

  type wb_rsp_t is record
    data : std_ulogic_vector(31 downto 0);
    ack  : std_ulogic;
  end record wb_rsp_t;
  constant dflt_wb_rsp_c : wb_rsp_t := (
    data => (others => '0'),
    ack  => '0'
  );

  type wb_req_arr_t is array(natural range <>) of wb_req_t;
  type wb_rsp_arr_t is array(natural range <>) of wb_rsp_t;

end package wishbone_pkg;

package body wishbone_pkg is

end package body wishbone_pkg;

