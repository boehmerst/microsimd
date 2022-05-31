-------------------------------------------------------------------------------
-- Title      : hibi_wishbone_bridge
-- Project    :
-------------------------------------------------------------------------------
-- File       : hibi_wishbone_bridge.vhd
-- Author     : Stephan Böhmer
-- Company    : private
-- Created    : 
-- Last update: 
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: automated generated do not edit manually
-------------------------------------------------------------------------------
-- Copyright (c) 2011 Stephan Böhmer
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
--             1.0      SBo     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package hibi_wishbone_bridge_regif_types_pkg is

constant hibi_wishbone_bridge_addr_width_c : integer := 9;
constant hibi_wishbone_bridge_data_width_c : integer := 32;

type hibi_wishbone_bridge_gif_req_t is record
  addr  : std_ulogic_vector(hibi_wishbone_bridge_addr_width_c-1 downto 0);
  wdata : std_ulogic_vector(hibi_wishbone_bridge_data_width_c-1 downto 0);
  wr    : std_ulogic;
  rd    : std_ulogic;
end record hibi_wishbone_bridge_gif_req_t;
constant dflt_hibi_wishbone_bridge_gif_req_c : hibi_wishbone_bridge_gif_req_t :=(
  addr  => (others=>'0'),
  wdata => (others=>'0'),
  wr    => '0',
  rd    => '0'
);

type hibi_wishbone_bridge_gif_req_arr_t is array(natural range <>) of hibi_wishbone_bridge_gif_req_t;

type hibi_wishbone_bridge_gif_rsp_t is record
  rdata : std_ulogic_vector(hibi_wishbone_bridge_data_width_c-1 downto 0);
  ack   : std_ulogic;
end record hibi_wishbone_bridge_gif_rsp_t;
constant dflt_hibi_wishbone_bridge_gif_rsp_c : hibi_wishbone_bridge_gif_rsp_t :=(
  rdata => (others=>'0'),
  ack   => '0'
);

type hibi_wishbone_bridge_gif_rsp_arr_t is array(natural range <>) of hibi_wishbone_bridge_gif_rsp_t;

end package hibi_wishbone_bridge_regif_types_pkg;

