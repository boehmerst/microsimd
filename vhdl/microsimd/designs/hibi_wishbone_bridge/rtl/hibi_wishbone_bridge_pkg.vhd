-------------------------------------------------------------------------------
-- Title      : hibi_wishbone_bridge_pkg
-- Project    :
-------------------------------------------------------------------------------
-- File       : hibi_wishbone_bridge_pkg.vhd
-- Author     : deboehse
-- Company    : private
-- Created    : 
-- Last update: 
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: automated generated do not edit manually
-------------------------------------------------------------------------------
-- Copyright (c) 2013 Stephan Böhmer
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
--             1.0      SBo     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package hibi_wishbone_bridge_pkg is

  constant hibi_wishbone_bridge_hibi_addr_width_c : natural := 16;
  constant hibi_wishbone_bridge_mem_addr_width_c  : natural := 9;
  constant hibi_wishbone_bridge_mem_data_width_c  : natural := 32;
  constant hibi_wishbone_bridge_count_width_c     : natural := 10;
  constant hibi_wishbone_bridge_channels_c        : natural := 2;

  type hibi_wishbone_bridge_ctrl_t is record
     start : std_ulogic;
   end record hibi_wishbone_bridge_ctrl_t;

  type hibi_wishbone_bridge_ctrl_arr_t is array(natural range 0 to hibi_wishbone_bridge_channels_c-1) of hibi_wishbone_bridge_ctrl_t;

  type hibi_wishbone_bridge_cfg_t is record
    hibi_addr  : std_ulogic_vector(hibi_wishbone_bridge_hibi_addr_width_c-1 downto 0);
    mem_addr   : std_ulogic_vector(hibi_wishbone_bridge_mem_addr_width_c-1 downto 0);
    count      : std_ulogic_vector(hibi_wishbone_bridge_count_width_c-1 downto 0);
    direction  : std_ulogic;
    const_addr : std_ulogic;
    cmd        : std_ulogic_vector(4 downto 0);
  end record hibi_wishbone_bridge_cfg_t;
  constant dflt_hibi_wishbone_bridge_cfg_c : hibi_wishbone_bridge_cfg_t :=(
    hibi_addr  => (others=>'0'),
    mem_addr   => (others=>'0'),
    count      => (others=>'0'),
    direction  => '0',
    const_addr => '0',
    cmd        => (others=>'0')
  );

  type hibi_wishbone_bridge_cfg_arr_t is array(natural range 0 to hibi_wishbone_bridge_channels_c-1) of hibi_wishbone_bridge_cfg_t;

  type hibi_wishbone_bridge_status_t is record
    busy  : std_ulogic;
  end record hibi_wishbone_bridge_status_t;
  constant dflt_hibi_wishbone_bridge_status_c : hibi_wishbone_bridge_status_t :=(
    busy  => '0'
  );

  type hibi_wishbone_bridge_status_arr_t is array(natural range 0 to hibi_wishbone_bridge_channels_c-1) of hibi_wishbone_bridge_status_t;

  type hibi_wishbone_bridge_mem_req_t is record
    adr : std_ulogic_vector(hibi_wishbone_bridge_mem_addr_width_c-1 downto 0);
    we  : std_ulogic;
    ena : std_ulogic;
    dat : std_ulogic_vector(hibi_wishbone_bridge_mem_data_width_c-1 downto 0);
  end record hibi_wishbone_bridge_mem_req_t;
  constant dflt_hibi_wishbone_bridge_mem_req_c : hibi_wishbone_bridge_mem_req_t :=(
    adr => (others=>'0'),
    we  => '0',
    ena => '0',
    dat => (others=>'0')
  );

  type hibi_wishbone_bridge_mem_rsp_t is record
    dat  : std_ulogic_vector(hibi_wishbone_bridge_mem_data_width_c-1 downto 0);
  end record hibi_wishbone_bridge_mem_rsp_t;

end package hibi_wishbone_bridge_pkg;
