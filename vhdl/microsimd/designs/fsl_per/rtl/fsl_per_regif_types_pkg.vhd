-------------------------------------------------------------------------------
-- Title      : fsl_per
-- Project    :
-------------------------------------------------------------------------------
-- File       : fsl_per.vhd
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

package fsl_per_regif_types_pkg is

constant fsl_per_addr_width_c : integer := 2;
constant fsl_per_data_width_c : integer := 4;

type fsl_per_gif_req_t is record
  addr  : std_ulogic_vector(fsl_per_addr_width_c-1 downto 0);
  wdata : std_ulogic_vector(fsl_per_data_width_c-1 downto 0);
  wr    : std_ulogic;
  rd    : std_ulogic;
end record fsl_per_gif_req_t;
constant dflt_fsl_per_gif_req_c : fsl_per_gif_req_t :=(
  addr  => (others=>'0'),
  wdata => (others=>'0'),
  wr    => '0',
  rd    => '0'
);

type fsl_per_gif_rsp_t is record
  rdata : std_ulogic_vector(fsl_per_data_width_c-1 downto 0);
  ack   : std_ulogic;
end record fsl_per_gif_rsp_t;
constant dflt_fsl_per_gif_rsp_c : fsl_per_gif_rsp_t :=(
  rdata => (others=>'0'),
  ack   => '0'
);

end package fsl_per_regif_types_pkg;

