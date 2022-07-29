library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package xbar_2008_pkg is

  type xbar_ctrl_t is record
    addr : std_ulogic_vector;
    sel  : std_ulogic_vector;
    wr   : std_ulogic;
    en   : std_ulogic;
  end record xbar_ctrl_t;

  function dflt_xbar_crtl(t : in xbar_ctrl_t) return xbar_ctrl_t;

  type xbar_req_t is record
    ctrl  : xbar_ctrl_t;
    wdata : std_ulogic_vector;
  end record xbar_req_t;

  function dflt_xbar_req(t : in xbar_req_t) return xbar_req_t;

  type xbar_rsp_t is record
    rdata : std_ulogic_vector;
  end record xbar_rsp_t;

  function dflt_xbar_rsp(t : in xbar_rsp_t) return xbar_rsp_t;

  type xbar_req_arr_t is array(natural range<>) of xbar_req_t;
  type xbar_rsp_arr_t is array(natural range<>) of xbar_rsp_t;

end package xbar_2008_pkg;


package body xbar_2008_pkg is

  function dflt_xbar_crtl(t : in xbar_ctrl_t) return xbar_ctrl_t is
    variable v : xbar_ctrl_t(addr(t.addr'range), sel(t.sel'range));
  begin
    v.addr := (v.addr'range => '0');
    v.sel  := (v.sel'range  => '0');
    v.wr   := '0';
    v.en   := '0';    
    return v;
  end function dflt_xbar_crtl;

  function dflt_xbar_req(t : in xbar_req_t) return xbar_req_t is
    variable v : xbar_req_t(ctrl(addr(t.ctrl.addr'range), sel(t.ctrl.sel'range)), wdata(t.wdata'range));
  begin
    v.ctrl  := dflt_xbar_crtl(t.ctrl);
    v.wdata := (v.wdata'range => '0');
    return v; 
  end function dflt_xbar_req;
  
  function dflt_xbar_rsp(t : in xbar_rsp_t) return xbar_rsp_t is
    variable v : xbar_rsp_t(rdata(t.rdata'range));
  begin
    v.rdata := (v.rdata'range => '0');
    return v;
  end function dflt_xbar_rsp;

end package body;

