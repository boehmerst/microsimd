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

package fsl_per_regfile_pkg is

type fsl_per_regfile_ctrl_t is record
  wr : std_ulogic;
  rd : std_ulogic;
end record fsl_per_regfile_ctrl_t;

-------------------------------------------------------------------------------
-- SCRATCHPAD0 register
-------------------------------------------------------------------------------
constant addr_offset_SCRATCHPAD0_integer_c  : integer := 0;
constant addr_offset_SCRATCHPAD0_unsigned_c : unsigned(2-1 downto 0) := "00";
constant addr_offset_SCRATCHPAD0_slv_c      : std_ulogic_vector(2-1 downto 0) := "00";

constant bit_offset_SCRATCHPAD0_scratch_c : integer := 0;

type fsl_per_SCRATCHPAD0_rw_t is record
  scratch : std_ulogic_vector(3 downto 0);
end record fsl_per_SCRATCHPAD0_rw_t;
constant dflt_fsl_per_SCRATCHPAD0_c : fsl_per_SCRATCHPAD0_rw_t :=(
  scratch => "0000"
);

type fsl_per_SCRATCHPAD0_reg2logic_t is record
  c : fsl_per_regfile_ctrl_t;
  rw : fsl_per_SCRATCHPAD0_rw_t;
end record fsl_per_SCRATCHPAD0_reg2logic_t;

-------------------------------------------------------------------------------
-- SCRATCHPAD1 register
-------------------------------------------------------------------------------
constant addr_offset_SCRATCHPAD1_integer_c  : integer := 1;
constant addr_offset_SCRATCHPAD1_unsigned_c : unsigned(2-1 downto 0) := "01";
constant addr_offset_SCRATCHPAD1_slv_c      : std_ulogic_vector(2-1 downto 0) := "01";

constant bit_offset_SCRATCHPAD1_scratch_c : integer := 0;

type fsl_per_SCRATCHPAD1_rw_t is record
  scratch : std_ulogic_vector(3 downto 0);
end record fsl_per_SCRATCHPAD1_rw_t;
constant dflt_fsl_per_SCRATCHPAD1_c : fsl_per_SCRATCHPAD1_rw_t :=(
  scratch => "0000"
);

type fsl_per_SCRATCHPAD1_reg2logic_t is record
  c : fsl_per_regfile_ctrl_t;
  rw : fsl_per_SCRATCHPAD1_rw_t;
end record fsl_per_SCRATCHPAD1_reg2logic_t;

-------------------------------------------------------------------------------
-- GPIN0 register
-------------------------------------------------------------------------------
constant addr_offset_GPIN0_integer_c  : integer := 2;
constant addr_offset_GPIN0_unsigned_c : unsigned(2-1 downto 0) := "10";
constant addr_offset_GPIN0_slv_c      : std_ulogic_vector(2-1 downto 0) := "10";

constant bit_offset_GPIN0_input_c : integer := 0;

type fsl_per_GPIN0_ro_t is record
  input : std_ulogic_vector(1 downto 0);
end record fsl_per_GPIN0_ro_t;

type fsl_per_GPIN0_reg2logic_t is record
  c : fsl_per_regfile_ctrl_t;
end record fsl_per_GPIN0_reg2logic_t;

type fsl_per_GPIN0_logic2reg_t is record
  ro : fsl_per_GPIN0_ro_t;
end record fsl_per_GPIN0_logic2reg_t;

-------------------------------------------------------------------------------
-- GPIN1 register
-------------------------------------------------------------------------------
constant addr_offset_GPIN1_integer_c  : integer := 3;
constant addr_offset_GPIN1_unsigned_c : unsigned(2-1 downto 0) := "11";
constant addr_offset_GPIN1_slv_c      : std_ulogic_vector(2-1 downto 0) := "11";

constant bit_offset_GPIN1_input_c : integer := 0;

type fsl_per_GPIN1_ro_t is record
  input : std_ulogic_vector(1 downto 0);
end record fsl_per_GPIN1_ro_t;

type fsl_per_GPIN1_reg2logic_t is record
  c : fsl_per_regfile_ctrl_t;
end record fsl_per_GPIN1_reg2logic_t;

type fsl_per_GPIN1_logic2reg_t is record
  ro : fsl_per_GPIN1_ro_t;
end record fsl_per_GPIN1_logic2reg_t;

-------------------------------------------------------------------------------
-- putting it all together
-------------------------------------------------------------------------------
type fsl_per_reg2logic_t is record
  SCRATCHPAD0 : fsl_per_SCRATCHPAD0_reg2logic_t;
  SCRATCHPAD1 : fsl_per_SCRATCHPAD1_reg2logic_t;
  GPIN0 : fsl_per_GPIN0_reg2logic_t;
  GPIN1 : fsl_per_GPIN1_reg2logic_t;
end record fsl_per_reg2logic_t;

type fsl_per_logic2reg_t is record
  GPIN0 : fsl_per_GPIN0_logic2reg_t;
  GPIN1 : fsl_per_GPIN1_logic2reg_t;
end record fsl_per_logic2reg_t;

end package fsl_per_regfile_pkg;
