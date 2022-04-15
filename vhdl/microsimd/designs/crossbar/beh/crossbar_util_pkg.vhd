library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.crossbar_pkg.all;

package crossbar_util_pkg is

  procedure mem_access(req : in xbar_req_arr_t; rsp : out xbar_rsp_arr_t; constant cnt : in positive; signal mst_req : out xbar_req_t; signal mst_rsp : in xbar_rsp_t; signal clk : in std_ulogic);
  procedure mem_write(addr, data : in std_ulogic_vector; signal mst_req : out xbar_req_t; signal mst_rsp : in xbar_rsp_t; signal clk : in std_ulogic);
  procedure mem_read(addr : in std_ulogic_vector; data : out std_ulogic_vector; signal mst_req : out xbar_req_t; signal mst_rsp : in xbar_rsp_t; signal clk : in std_ulogic);

end package crossbar_util_pkg;

package body crossbar_util_pkg is
  ------------------------------------------------------------------------------
  -- generic memory access
  ------------------------------------------------------------------------------
  procedure mem_access(req : in xbar_req_arr_t; rsp : out xbar_rsp_arr_t; constant cnt : in positive; signal mst_req : out xbar_req_t; signal mst_rsp : in xbar_rsp_t; signal clk : in std_ulogic) is
  begin
    assert req'high >= cnt-1 and rsp'high >= cnt-1 report "Transfer count exceeds request and / or response dimention" severity failure;
    
    req_loop0: for i in 0 to cnt-1 loop
      mst_req <= req(i);

      -- wait for master ready response
      ready_loop0: while(true) loop
        wait until clk'event and clk = '1';
        exit when mst_rsp.ready = '1';
      end loop ready_loop0;
      
      -- conditionall capture response
      if(i /= 0) then
        rsp(i-1) := mst_rsp;
      end if;
      
      -- conditionall issue next request
      if(i < cnt-1) then
        mst_req <= req(i+1);
      else
        mst_req <= dflt_xbar_req_c;
      end if;
    end loop req_loop0;
    
    -- capture last response
    ready_loop1: while(true) loop
      wait until clk'event and clk = '1';
      exit when mst_rsp.ready = '1';
    end loop ready_loop1;
    
    rsp(cnt-1) := mst_rsp;
  end procedure mem_access;

  ------------------------------------------------------------------------------
  -- write to memory
  ------------------------------------------------------------------------------  
  procedure mem_write(addr, data : in std_ulogic_vector; signal mst_req : out xbar_req_t; signal mst_rsp : in xbar_rsp_t; signal clk : in std_ulogic) is
    variable req : xbar_req_arr_t(0 to 0);
    variable rsp : xbar_rsp_arr_t(0 to 0);
  begin
    req(0).addr  := std_ulogic_vector(resize(unsigned(addr), req(0).addr'length));
    req(0).wdata := std_ulogic_vector(resize(unsigned(data), req(0).wdata'length));
    req(0).en    := '1';
    req(0).wr    := '1';
    req(0).sel   := (others=>'1');
    mem_access(req, rsp, 1, mst_req, mst_rsp, clk);
  end procedure mem_write;
  
  ------------------------------------------------------------------------------
  -- read from memory
  ------------------------------------------------------------------------------    
  procedure mem_read(addr : in std_ulogic_vector; data : out std_ulogic_vector; signal mst_req : out xbar_req_t; signal mst_rsp : in xbar_rsp_t; signal clk : in std_ulogic) is
    variable req : xbar_req_arr_t(0 to 0);
    variable rsp : xbar_rsp_arr_t(0 to 0);  
  begin
    req(0).addr  := std_ulogic_vector(resize(unsigned(addr), req(0).addr'length));
    req(0).en    := '1';
    req(0).wr    := '0';
    req(0).sel   := (others=>'1');
    mem_access(req, rsp, 1, mst_req, mst_rsp, clk);
    data         := std_ulogic_vector(resize(unsigned(rsp(0).rdata), data'length));
  end procedure mem_read;

end package body crossbar_util_pkg;

