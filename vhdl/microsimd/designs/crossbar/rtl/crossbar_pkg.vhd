library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package crossbar_pkg is
  constant xbar_addr_width_c : integer := 16;
  constant xbar_data_width_c : integer := 32;

  type xbar_req_t is record
    addr  : std_ulogic_vector(xbar_addr_width_c-1 downto 0);
    wdata : std_ulogic_vector(xbar_data_width_c-1 downto 0);
    sel   : std_ulogic_vector(3 downto 0);
    wr    : std_ulogic;
    en    : std_ulogic;
  end record xbar_req_t;
  constant dflt_xbar_req_c : xbar_req_t :=(
    addr  => (others=>'0'),
    wdata => (others=>'0'),
    sel   => (others=>'0'),
    wr    => '0',
    en    => '0'
  );
  
  type xbar_rsp_t is record
    rdata : std_ulogic_vector(xbar_data_width_c-1 downto 0);
    ready : std_ulogic;
  end record xbar_rsp_t;
  constant dflt_xbar_rsp_c : xbar_rsp_t :=(
    rdata => (others=>'0'),
    ready => '1'
  );
  
  type xbar_req_arr_t is array(natural range <>) of xbar_req_t;
  type xbar_rsp_arr_t is array(natural range <>) of xbar_rsp_t;
  
  function xbar_req_mux(req : in xbar_req_arr_t; sel : in natural) return xbar_req_t;
  function xbar_req_mux(req : in xbar_req_arr_t; sel : in std_ulogic_vector; en : in std_ulogic) return xbar_req_t;
  function xbar_rsp_mux(rsp : in xbar_rsp_arr_t; sel : in natural) return xbar_rsp_t;
  function xbar_rsp_mux(rsp : in xbar_rsp_arr_t; sel : in std_ulogic_vector) return xbar_rsp_t;
  
end package crossbar_pkg;

package body crossbar_pkg is  
  ------------------------------------------------------------------------------
  -- request multiplexing
  ------------------------------------------------------------------------------
  function xbar_req_mux(req : in xbar_req_arr_t; sel : in natural) return xbar_req_t is
  begin
    return req(sel);
  end function xbar_req_mux;
  
  function xbar_req_mux(req : in xbar_req_arr_t; sel : in std_ulogic_vector; en : in std_ulogic) return xbar_req_t is
    variable request : xbar_req_t;
  begin
    request    := xbar_req_mux(req, to_integer(unsigned(sel)));
    request.en := en;
    return request;
  end function xbar_req_mux;
  
  ------------------------------------------------------------------------------
  -- response multiplexing
  ------------------------------------------------------------------------------
  function xbar_rsp_mux(rsp : in xbar_rsp_arr_t; sel : in natural) return xbar_rsp_t is
  begin
    return rsp(sel);
  end function xbar_rsp_mux;

  function xbar_rsp_mux(rsp : in xbar_rsp_arr_t; sel : in std_ulogic_vector) return xbar_rsp_t is
  begin
    return xbar_rsp_mux(rsp, to_integer(unsigned(sel)));
  end function xbar_rsp_mux;
  
end package body crossbar_pkg;

