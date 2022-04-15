library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library microsimd;
use microsimd.core_pkg.all;
use microsimd.config_pkg.all;

package hibi_link_pkg is

  -- TODO: move to config package
  constant hibi_comm_width_c          : integer    := 5;
  constant hibi_addr_width_c          : integer    := 16;
  constant hibi_data_width_c          : integer    := 32;
 
  constant hibi_idle_c                : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "00000";
  constant hibi_wr_data_c             : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "00010";
  constant hibi_wr_prio_data_c        : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "00011";
  constant hibi_rd_data_c             : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "00100";
  constant hibi_rd_prio_data_c        : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "00101";
  constant hibi_rd_data_linked_c      : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "00110";
  constant hibi_rd_prio_data_linked_c : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "00111";
  constant hibi_wr_data_nopost_c      : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "01000";
  constant hibi_wr_prio_data_nopost_c : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "01001";
  constant hibi_wr_data_cond_c        : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "01010";
  constant hibi_wr_prio_data_cond_c   : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "01011";
  constant hibi_lock_c                : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "01101";
  constant hibi_wr_data_locked_c      : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "01111";
  constant hibi_rd_data_locked_c      : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "10001";
  constant hibi_unlock_c              : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "10011";
  constant hibi_wr_cfg_c              : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "10101";
  constant hibi_rd_cfg_c              : std_ulogic_vector(hibi_comm_width_c-1 downto 0) := "10111";

  type agent_txreq_t is record
    av   : std_ulogic;
    data : std_ulogic_vector(hibi_data_width_c-1 downto 0);
    comm : std_ulogic_vector(hibi_comm_width_c-1 downto 0);
    we   : std_ulogic;
  end record agent_txreq_t;
  constant dflt_agent_txreq_c : agent_txreq_t :=(
    av   => '0',
    data => (others=>'0'),
    comm => (others=>'0'),
    we   => '0'
  );

  type agent_txrsp_t is record
    full        : std_ulogic;
    almost_full : std_ulogic;
  end record agent_txrsp_t;
  constant dflt_agent_txrsp_c : agent_txrsp_t :=(
    full        => '0',
    almost_full => '0'
  );

  type agent_rxreq_t is record
    re          : std_ulogic;
  end record agent_rxreq_t;
  constant dflt_agent_rxreq_c : agent_rxreq_t :=(
    re          => '0'
  );

  type agent_rxrsp_t is record
    av           : std_ulogic;
    data         : std_ulogic_vector(hibi_data_width_c-1 downto 0);
    comm         : std_ulogic_vector(hibi_comm_width_c-1 downto 0);
    empty        : std_ulogic;
    almost_empty : std_ulogic;
  end record agent_rxrsp_t;
  constant dflt_agent_rxrsp_c : agent_rxrsp_t :=(
    av           => '0',
    data         => (others=>'0'),
    comm         => (others=>'0'),
    empty        => '1',
    almost_empty => '1'
  );

  type agent_txreq_array_t is array(natural range <>) of agent_txreq_t;
  type agent_txrsp_array_t is array(natural range <>) of agent_txrsp_t;
  type agent_rxreq_array_t is array(natural range <>) of agent_rxreq_t;
  type agent_rxrsp_array_t is array(natural range <>) of agent_rxrsp_t;

  function bind_link(full, almost_full : std_logic) return agent_txrsp_t;
  function bind_link(av           : std_logic; 
                     data         : std_logic_vector(hibi_data_width_c-1 downto 0);
                     comm         : std_logic_vector(hibi_comm_width_c-1 downto 0); 
                     empty        : std_logic;
                     almost_empty : std_logic) return agent_rxrsp_t;

end package hibi_link_pkg;

package body hibi_link_pkg is

  function bind_link(full, almost_full : std_logic) return agent_txrsp_t is
    variable result : agent_txrsp_t;
  begin
    result.full        := full;
    result.almost_full := almost_full;
    return result;
  end function bind_link;

  function bind_link(av           : std_logic; 
                     data         : std_logic_vector(hibi_data_width_c-1 downto 0);
                     comm         : std_logic_vector(hibi_comm_width_c-1 downto 0); 
                     empty        : std_logic;
                     almost_empty : std_logic) return agent_rxrsp_t is
    variable result : agent_rxrsp_t;
  begin
    result.av           := std_ulogic(av);
    result.comm         := std_ulogic_vector(comm);
    result.data         := std_ulogic_vector(data);
    result.empty        := std_ulogic(empty);
    result.almost_empty := std_ulogic(almost_empty);
    return result;
  end function bind_link;

end package body hibi_link_pkg;


