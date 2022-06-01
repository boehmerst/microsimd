library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.hibi_wishbone_bridge_regif_types_pkg.all;


entity wb2gif is
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
    gif_req_o    : out hibi_wishbone_bridge_gif_req_arr_t(0 to 1);
    gif_rsp_i    : in  hibi_wishbone_bridge_gif_rsp_arr_t(0 to 1)
  );
end entity wb2gif;


architecture rtl of wb2gif is

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
  comb0: process (r, wb_req_i, gif_rsp_i) is
    variable v       : reg_t;
    variable mem_en  : std_ulogic;
    variable ack     : std_ulogic;
    variable sel     : std_ulogic;
    variable sel_int : integer range 0 to 1;
  begin
    v := r;

    mem_en  := '0';
    ack     := '0';

    sel     := wb_req_i.adr(wb_req_i.adr'left);
    sel_int := to_integer(unsigned'("" & sel));

    if v.state = idle then
      if wb_req_i.stb = '1' and wb_req_i.cyc = '1' then
	v.state := trans;
	mem_en := '1';
      end if;
    elsif v.state = trans then
      if gif_rsp_i(sel_int).ack = '1' then
	v.state := idle;
	ack     := '1';
      end if;
    else
      null;
    end if;

    ---------------------------------------------------------------------------
    -- drive module output
    ---------------------------------------------------------------------------
    -- NOTE: Everything is 32 Bit aligned internally and no byte or half word 
    -- access are supported
    ---------------------------------------------------------------------------
    gif_req_o(0).addr  <= std_ulogic_vector(resize(unsigned(wb_req_i.adr(wb_req_i.adr'left-1 downto 2)), gif_req_o(0).addr'length));
    gif_req_o(0).wdata <= std_ulogic_vector(resize(unsigned(wb_req_i.dat), gif_req_o(0).wdata'length));

    gif_req_o(1).addr  <= std_ulogic_vector(resize(unsigned(wb_req_i.adr(wb_req_i.adr'left-1 downto 2)), gif_req_o(1).addr'length));
    gif_req_o(1).wdata <= std_ulogic_vector(resize(unsigned(wb_req_i.dat), gif_req_o(1).wdata'length));

    gif_req_o(0).wr    <= mem_en and     wb_req_i.we and not sel;
    gif_req_o(0).rd    <= mem_en and not wb_req_i.we and not sel;
    gif_req_o(1).wr    <= mem_en and     wb_req_i.we and     sel;
    gif_req_o(1).rd    <= mem_en and not wb_req_i.we and     sel;
  
    wb_rsp_o.data   <= std_ulogic_vector(resize(unsigned(gif_rsp_i(sel_int).rdata), wb_rsp_o.data'length));
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

