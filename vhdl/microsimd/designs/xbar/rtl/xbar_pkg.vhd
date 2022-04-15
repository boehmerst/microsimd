library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package xbar_pkg is

constant addr_width_c : integer := 16;
constant data_width_c : integer := 32;

type xbar_ctrl_t is record
  addr : std_ulogic_vector(addr_width_c-1 downto 0);
  sel  : std_ulogic_vector(3 downto 0);
  wr   : std_ulogic;
  en   : std_ulogic;
end record xbar_ctrl_t;
constant dflt_xbar_ctrl_c : xbar_ctrl_t :=(
  addr => (others=>'0'),
  sel  => (others=>'0'),
  wr   => '0',
  en   => '0'
);

type xbar_req_t is record
  ctrl  : xbar_ctrl_t;
  wdata : std_ulogic_vector(data_width_c-1 downto 0);
end record xbar_req_t;
constant dflt_xbar_req_c : xbar_req_t :=(
  ctrl  => dflt_xbar_ctrl_c,
  wdata => (others=>'0')
);

type xbar_rsp_t is record
  rdata : std_ulogic_vector(data_width_c-1 downto 0);
end record xbar_rsp_t;
constant dflt_xbar_rsp_c : xbar_rsp_t :=(
  rdata => (others=>'0')
);

type xbar_req_arr_t is array(natural range<>) of xbar_req_t;
type xbar_rsp_arr_t is array(natural range<>) of xbar_rsp_t;

end package xbar_pkg;

