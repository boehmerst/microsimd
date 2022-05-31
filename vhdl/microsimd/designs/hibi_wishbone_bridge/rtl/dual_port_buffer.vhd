library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.hibi_wishbone_bridge_pkg.all;


entity dual_port_buffer is
  generic (
    data_width_g : integer := hibi_wishbone_bridge_mem_data_width_c;
    addr_width_g : integer := hibi_wishbone_bridge_mem_addr_width_c-2
  );
  port (
    clk_i        : in  std_ulogic;
    reset_n_i    : in  std_ulogic;
    en_i         : in  std_ulogic;
    init_i       : in  std_ulogic;
    port_a_req_i : in  hibi_wishbone_bridge_mem_req_t;
    port_a_rsp_o : out hibi_wishbone_bridge_mem_rsp_t;
    port_b_req_i : in  hibi_wishbone_bridge_mem_req_t;
    port_b_rsp_o : out hibi_wishbone_bridge_mem_rsp_t
  );
end entity dual_port_buffer;


architecture rtl of dual_port_buffer is
  
  constant entries_c : integer := (2**addr_width_g);
  type mem_t is array(natural range 0 to entries_c-1) of std_ulogic_vector(data_width_g-1 downto 0);

  type reg_t is record
    mem          : mem_t;
    port_a_rdata : std_ulogic_vector(data_width_g-1 downto 0);
    port_b_rdata : std_ulogic_vector(data_width_g-1 downto 0);
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    mem          => (others => (others => '0')),
    port_a_rdata => (others => '0'),
    port_b_rdata => (others => '0')
  );

  signal r, rin : reg_t;

begin
  -----------------------------------------------------------------------------
  -- comb0
  -----------------------------------------------------------------------------
  comb0: process (r, port_a_req_i, port_b_req_i) is
    variable v : reg_t;
  begin
    v := r;

    ---------------------------------------------------------------------------
    -- port b has higher write priority writing to the same address
    -- no write forwarding in case of writing and readig the same address
    ---------------------------------------------------------------------------
    if port_a_req_i.ena = '1' then
      if port_a_req_i.we = '1' then
	v.mem(to_integer(unsigned(port_a_req_i.adr))) := port_a_req_i.dat;
      else
        v.port_a_rdata := r.mem(to_integer(unsigned(port_a_req_i.adr)));
      end if;
    end if;

    if port_b_req_i.ena = '1' then
      if port_b_req_i.we = '1' then
	v.mem(to_integer(unsigned(port_b_req_i.adr))) := port_b_req_i.dat;
      else
        v.port_b_rdata := r.mem(to_integer(unsigned(port_b_req_i.adr)));
      end if;
    end if;

    ---------------------------------------------------------------------------
    -- drive module output
    ---------------------------------------------------------------------------
    port_a_rsp_o.dat <= r.port_a_rdata;
    port_b_rsp_o.dat <= r.port_b_rdata;

    rin <= v;
  end process comb0;

  -----------------------------------------------------------------------------
  -- sync0
  -----------------------------------------------------------------------------
  sync0: process(clk_i, reset_n_i) is
  begin
    if reset_n_i = '0' then
      r <= dflt_reg_c;
    elsif rising_edge(clk_i) then
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

