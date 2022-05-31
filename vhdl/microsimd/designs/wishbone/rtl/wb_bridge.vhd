library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.crossbar_pkg.all;


entity wb_bridge is
  generic (
    reset_level_g : std_ulogic := '1'
  );
  port (
    wb_clk_i     : in  std_ulogic;
    wb_reset_i   : in  std_ulogic;
    en_i         : in  std_ulogic;
    init_i       : in  std_ulogic;
    wb_req_i     : in  wb_req_t;
    wb_rsp_o     : out wb_rsp_t;
    mem_req_o    : out xbar_req_t;
    mem_rsp_i    : in  xbar_rsp_t
  );
end entity wb_bridge;


architecture rtl of wb_bridge is

  type state_t is (idle, trans);

  type reg_t is record
    state : state_t;
  end record reg_t;
  constant dflt_reg_c : reg_t := (
    state => idle
  );

  signal r, rin : reg_t;

begin
  -----------------------------------------------------------------------------
  -- comb0
  -----------------------------------------------------------------------------
  comb0: process (r, wb_req_i, mem_rsp_i) is
    variable v      : reg_t;
    variable mem_en : std_ulogic;
    variable ack    : std_ulogic;
  begin
    v := r;

    mem_en := '0';
    ack    := '0';

    if v.state = idle then
      if wb_req_i.stb = '1' and wb_req_i.cyc = '1' then
	v.state := trans;
	mem_en := '1';
      end if;
    elsif v.state = trans then
      if mem_rsp_i.ready = '1' then
	v.state := idle;
	ack     := '1';
      end if;
    else
      null;
    end if;

    -- drive module output
    -- TODO: the address risizing is error prone
    mem_req_o.addr  <= std_ulogic_vector(resize(unsigned(wb_req_i.adr), mem_req_o.addr'length));
    mem_req_o.wdata <= wb_req_i.dat;
    mem_req_o.sel   <= wb_req_i.sel; 
    mem_req_o.wr    <= wb_req_i.we;
    mem_req_o.en    <= mem_en;

    wb_rsp_o.data   <= mem_rsp_i.rdata;
    wb_rsp_o.ack    <= ack;

    rin <= v;
  end process comb0;
  
  -----------------------------------------------------------------------------
  -- sync0
  -----------------------------------------------------------------------------
  sync0: process (wb_clk_i, wb_reset_i) is
  begin
    if wb_reset_i = reset_level_g then
      r <= dflt_reg_c;
    elsif rising_edge(wb_clk_i) then
      if en_i = '1' then
        if init_i = '1' then
	  r <= dflt_reg_c;
	else
	  r <= rin;
	end if;
      end if;
    end if;
  end process sync0;

end architecture rtl;

