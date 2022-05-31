-------------------------------------------------------------------------------
-- Title      : hibi_dma
-- Project    :
-------------------------------------------------------------------------------
-- File       : hibi_dma.vhd
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

package hibi_dma_regfile_pkg is

type hibi_dma_regfile_ctrl_t is record
  wr : std_ulogic;
  rd : std_ulogic;
end record hibi_dma_regfile_ctrl_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_CTRL register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_CTRL_integer_c  : integer := 0;
constant addr_offset_HIBI_DMA_CTRL_unsigned_c : unsigned(5-1 downto 0) := "00000";
constant addr_offset_HIBI_DMA_CTRL_slv_c      : std_ulogic_vector(5-1 downto 0) := "00000";

constant bit_offset_HIBI_DMA_CTRL_en_c : integer := 0;

type hibi_dma_HIBI_DMA_CTRL_rw_t is record
  en : std_ulogic;
end record hibi_dma_HIBI_DMA_CTRL_rw_t;
constant dflt_hibi_dma_HIBI_DMA_CTRL_c : hibi_dma_HIBI_DMA_CTRL_rw_t :=(
  en => '0'
);

type hibi_dma_HIBI_DMA_CTRL_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_CTRL_rw_t;
end record hibi_dma_HIBI_DMA_CTRL_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_STATUS register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_STATUS_integer_c  : integer := 1;
constant addr_offset_HIBI_DMA_STATUS_unsigned_c : unsigned(5-1 downto 0) := "00001";
constant addr_offset_HIBI_DMA_STATUS_slv_c      : std_ulogic_vector(5-1 downto 0) := "00001";

constant bit_offset_HIBI_DMA_STATUS_busy0_c : integer := 0;
constant bit_offset_HIBI_DMA_STATUS_busy1_c : integer := 1;
constant bit_offset_HIBI_DMA_STATUS_busy2_c : integer := 2;
constant bit_offset_HIBI_DMA_STATUS_busy3_c : integer := 3;

type hibi_dma_HIBI_DMA_STATUS_ro_t is record
  busy0 : std_ulogic;
  busy1 : std_ulogic;
  busy2 : std_ulogic;
  busy3 : std_ulogic;
end record hibi_dma_HIBI_DMA_STATUS_ro_t;

type hibi_dma_HIBI_DMA_STATUS_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
end record hibi_dma_HIBI_DMA_STATUS_reg2logic_t;

type hibi_dma_HIBI_DMA_STATUS_logic2reg_t is record
  ro : hibi_dma_HIBI_DMA_STATUS_ro_t;
end record hibi_dma_HIBI_DMA_STATUS_logic2reg_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_TRIGGER register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_TRIGGER_integer_c  : integer := 2;
constant addr_offset_HIBI_DMA_TRIGGER_unsigned_c : unsigned(5-1 downto 0) := "00010";
constant addr_offset_HIBI_DMA_TRIGGER_slv_c      : std_ulogic_vector(5-1 downto 0) := "00010";

constant bit_offset_HIBI_DMA_TRIGGER_start0_c : integer := 0;
constant bit_offset_HIBI_DMA_TRIGGER_start1_c : integer := 1;
constant bit_offset_HIBI_DMA_TRIGGER_start2_c : integer := 2;
constant bit_offset_HIBI_DMA_TRIGGER_start3_c : integer := 3;

type hibi_dma_HIBI_DMA_TRIGGER_xw_t is record
  start0 : std_ulogic;
  start1 : std_ulogic;
  start2 : std_ulogic;
  start3 : std_ulogic;
end record hibi_dma_HIBI_DMA_TRIGGER_xw_t;

type hibi_dma_HIBI_DMA_TRIGGER_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  xw : hibi_dma_HIBI_DMA_TRIGGER_xw_t;
end record hibi_dma_HIBI_DMA_TRIGGER_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_CFG0 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_CFG0_integer_c  : integer := 3;
constant addr_offset_HIBI_DMA_CFG0_unsigned_c : unsigned(5-1 downto 0) := "00011";
constant addr_offset_HIBI_DMA_CFG0_slv_c      : std_ulogic_vector(5-1 downto 0) := "00011";

constant bit_offset_HIBI_DMA_CFG0_count_c : integer := 0;
constant bit_offset_HIBI_DMA_CFG0_direction_c : integer := 15;
constant bit_offset_HIBI_DMA_CFG0_hibi_cmd_c : integer := 16;
constant bit_offset_HIBI_DMA_CFG0_const_addr_c : integer := 21;

type hibi_dma_HIBI_DMA_CFG0_rw_t is record
  count : std_ulogic_vector(9 downto 0);
  direction : std_ulogic;
  hibi_cmd : std_ulogic_vector(4 downto 0);
  const_addr : std_ulogic;
end record hibi_dma_HIBI_DMA_CFG0_rw_t;
constant dflt_hibi_dma_HIBI_DMA_CFG0_c : hibi_dma_HIBI_DMA_CFG0_rw_t :=(
  count => "0000000000",
  direction => '1',
  hibi_cmd => "00010",
  const_addr => '0'
);

type hibi_dma_HIBI_DMA_CFG0_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_CFG0_rw_t;
end record hibi_dma_HIBI_DMA_CFG0_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_MEM_ADDR0 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_MEM_ADDR0_integer_c  : integer := 4;
constant addr_offset_HIBI_DMA_MEM_ADDR0_unsigned_c : unsigned(5-1 downto 0) := "00100";
constant addr_offset_HIBI_DMA_MEM_ADDR0_slv_c      : std_ulogic_vector(5-1 downto 0) := "00100";

constant bit_offset_HIBI_DMA_MEM_ADDR0_addr_c : integer := 0;

type hibi_dma_HIBI_DMA_MEM_ADDR0_rw_t is record
  addr : std_ulogic_vector(15 downto 0);
end record hibi_dma_HIBI_DMA_MEM_ADDR0_rw_t;
constant dflt_hibi_dma_HIBI_DMA_MEM_ADDR0_c : hibi_dma_HIBI_DMA_MEM_ADDR0_rw_t :=(
  addr => "0000000000000000"
);

type hibi_dma_HIBI_DMA_MEM_ADDR0_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_MEM_ADDR0_rw_t;
end record hibi_dma_HIBI_DMA_MEM_ADDR0_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_HIBI_ADDR0 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_HIBI_ADDR0_integer_c  : integer := 5;
constant addr_offset_HIBI_DMA_HIBI_ADDR0_unsigned_c : unsigned(5-1 downto 0) := "00101";
constant addr_offset_HIBI_DMA_HIBI_ADDR0_slv_c      : std_ulogic_vector(5-1 downto 0) := "00101";

constant bit_offset_HIBI_DMA_HIBI_ADDR0_addr_c : integer := 0;

type hibi_dma_HIBI_DMA_HIBI_ADDR0_rw_t is record
  addr : std_ulogic_vector(15 downto 0);
end record hibi_dma_HIBI_DMA_HIBI_ADDR0_rw_t;
constant dflt_hibi_dma_HIBI_DMA_HIBI_ADDR0_c : hibi_dma_HIBI_DMA_HIBI_ADDR0_rw_t :=(
  addr => "0000000000000000"
);

type hibi_dma_HIBI_DMA_HIBI_ADDR0_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_HIBI_ADDR0_rw_t;
end record hibi_dma_HIBI_DMA_HIBI_ADDR0_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_TRIGGER_MASK0 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_TRIGGER_MASK0_integer_c  : integer := 6;
constant addr_offset_HIBI_DMA_TRIGGER_MASK0_unsigned_c : unsigned(5-1 downto 0) := "00110";
constant addr_offset_HIBI_DMA_TRIGGER_MASK0_slv_c      : std_ulogic_vector(5-1 downto 0) := "00110";

constant bit_offset_HIBI_DMA_TRIGGER_MASK0_mask_c : integer := 0;

type hibi_dma_HIBI_DMA_TRIGGER_MASK0_rw_t is record
  mask : std_ulogic_vector(3 downto 0);
end record hibi_dma_HIBI_DMA_TRIGGER_MASK0_rw_t;
constant dflt_hibi_dma_HIBI_DMA_TRIGGER_MASK0_c : hibi_dma_HIBI_DMA_TRIGGER_MASK0_rw_t :=(
  mask => "0000"
);

type hibi_dma_HIBI_DMA_TRIGGER_MASK0_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_TRIGGER_MASK0_rw_t;
end record hibi_dma_HIBI_DMA_TRIGGER_MASK0_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_CFG1 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_CFG1_integer_c  : integer := 7;
constant addr_offset_HIBI_DMA_CFG1_unsigned_c : unsigned(5-1 downto 0) := "00111";
constant addr_offset_HIBI_DMA_CFG1_slv_c      : std_ulogic_vector(5-1 downto 0) := "00111";

constant bit_offset_HIBI_DMA_CFG1_count_c : integer := 0;
constant bit_offset_HIBI_DMA_CFG1_direction_c : integer := 15;
constant bit_offset_HIBI_DMA_CFG1_hibi_cmd_c : integer := 16;
constant bit_offset_HIBI_DMA_CFG1_const_addr_c : integer := 21;

type hibi_dma_HIBI_DMA_CFG1_rw_t is record
  count : std_ulogic_vector(9 downto 0);
  direction : std_ulogic;
  hibi_cmd : std_ulogic_vector(4 downto 0);
  const_addr : std_ulogic;
end record hibi_dma_HIBI_DMA_CFG1_rw_t;
constant dflt_hibi_dma_HIBI_DMA_CFG1_c : hibi_dma_HIBI_DMA_CFG1_rw_t :=(
  count => "0000000000",
  direction => '1',
  hibi_cmd => "00010",
  const_addr => '0'
);

type hibi_dma_HIBI_DMA_CFG1_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_CFG1_rw_t;
end record hibi_dma_HIBI_DMA_CFG1_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_MEM_ADDR1 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_MEM_ADDR1_integer_c  : integer := 8;
constant addr_offset_HIBI_DMA_MEM_ADDR1_unsigned_c : unsigned(5-1 downto 0) := "01000";
constant addr_offset_HIBI_DMA_MEM_ADDR1_slv_c      : std_ulogic_vector(5-1 downto 0) := "01000";

constant bit_offset_HIBI_DMA_MEM_ADDR1_addr_c : integer := 0;

type hibi_dma_HIBI_DMA_MEM_ADDR1_rw_t is record
  addr : std_ulogic_vector(15 downto 0);
end record hibi_dma_HIBI_DMA_MEM_ADDR1_rw_t;
constant dflt_hibi_dma_HIBI_DMA_MEM_ADDR1_c : hibi_dma_HIBI_DMA_MEM_ADDR1_rw_t :=(
  addr => "0000000000000000"
);

type hibi_dma_HIBI_DMA_MEM_ADDR1_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_MEM_ADDR1_rw_t;
end record hibi_dma_HIBI_DMA_MEM_ADDR1_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_HIBI_ADDR1 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_HIBI_ADDR1_integer_c  : integer := 9;
constant addr_offset_HIBI_DMA_HIBI_ADDR1_unsigned_c : unsigned(5-1 downto 0) := "01001";
constant addr_offset_HIBI_DMA_HIBI_ADDR1_slv_c      : std_ulogic_vector(5-1 downto 0) := "01001";

constant bit_offset_HIBI_DMA_HIBI_ADDR1_addr_c : integer := 0;

type hibi_dma_HIBI_DMA_HIBI_ADDR1_rw_t is record
  addr : std_ulogic_vector(15 downto 0);
end record hibi_dma_HIBI_DMA_HIBI_ADDR1_rw_t;
constant dflt_hibi_dma_HIBI_DMA_HIBI_ADDR1_c : hibi_dma_HIBI_DMA_HIBI_ADDR1_rw_t :=(
  addr => "0000000000000000"
);

type hibi_dma_HIBI_DMA_HIBI_ADDR1_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_HIBI_ADDR1_rw_t;
end record hibi_dma_HIBI_DMA_HIBI_ADDR1_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_TRIGGER_MASK1 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_TRIGGER_MASK1_integer_c  : integer := 10;
constant addr_offset_HIBI_DMA_TRIGGER_MASK1_unsigned_c : unsigned(5-1 downto 0) := "01010";
constant addr_offset_HIBI_DMA_TRIGGER_MASK1_slv_c      : std_ulogic_vector(5-1 downto 0) := "01010";

constant bit_offset_HIBI_DMA_TRIGGER_MASK1_mask_c : integer := 0;

type hibi_dma_HIBI_DMA_TRIGGER_MASK1_rw_t is record
  mask : std_ulogic_vector(3 downto 0);
end record hibi_dma_HIBI_DMA_TRIGGER_MASK1_rw_t;
constant dflt_hibi_dma_HIBI_DMA_TRIGGER_MASK1_c : hibi_dma_HIBI_DMA_TRIGGER_MASK1_rw_t :=(
  mask => "0000"
);

type hibi_dma_HIBI_DMA_TRIGGER_MASK1_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_TRIGGER_MASK1_rw_t;
end record hibi_dma_HIBI_DMA_TRIGGER_MASK1_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_CFG2 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_CFG2_integer_c  : integer := 11;
constant addr_offset_HIBI_DMA_CFG2_unsigned_c : unsigned(5-1 downto 0) := "01011";
constant addr_offset_HIBI_DMA_CFG2_slv_c      : std_ulogic_vector(5-1 downto 0) := "01011";

constant bit_offset_HIBI_DMA_CFG2_count_c : integer := 0;
constant bit_offset_HIBI_DMA_CFG2_direction_c : integer := 15;
constant bit_offset_HIBI_DMA_CFG2_hibi_cmd_c : integer := 16;
constant bit_offset_HIBI_DMA_CFG2_const_addr_c : integer := 21;

type hibi_dma_HIBI_DMA_CFG2_rw_t is record
  count : std_ulogic_vector(9 downto 0);
  direction : std_ulogic;
  hibi_cmd : std_ulogic_vector(4 downto 0);
  const_addr : std_ulogic;
end record hibi_dma_HIBI_DMA_CFG2_rw_t;
constant dflt_hibi_dma_HIBI_DMA_CFG2_c : hibi_dma_HIBI_DMA_CFG2_rw_t :=(
  count => "0000000000",
  direction => '1',
  hibi_cmd => "00010",
  const_addr => '0'
);

type hibi_dma_HIBI_DMA_CFG2_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_CFG2_rw_t;
end record hibi_dma_HIBI_DMA_CFG2_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_MEM_ADDR2 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_MEM_ADDR2_integer_c  : integer := 12;
constant addr_offset_HIBI_DMA_MEM_ADDR2_unsigned_c : unsigned(5-1 downto 0) := "01100";
constant addr_offset_HIBI_DMA_MEM_ADDR2_slv_c      : std_ulogic_vector(5-1 downto 0) := "01100";

constant bit_offset_HIBI_DMA_MEM_ADDR2_addr_c : integer := 0;

type hibi_dma_HIBI_DMA_MEM_ADDR2_rw_t is record
  addr : std_ulogic_vector(15 downto 0);
end record hibi_dma_HIBI_DMA_MEM_ADDR2_rw_t;
constant dflt_hibi_dma_HIBI_DMA_MEM_ADDR2_c : hibi_dma_HIBI_DMA_MEM_ADDR2_rw_t :=(
  addr => "0000000000000000"
);

type hibi_dma_HIBI_DMA_MEM_ADDR2_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_MEM_ADDR2_rw_t;
end record hibi_dma_HIBI_DMA_MEM_ADDR2_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_HIBI_ADDR2 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_HIBI_ADDR2_integer_c  : integer := 13;
constant addr_offset_HIBI_DMA_HIBI_ADDR2_unsigned_c : unsigned(5-1 downto 0) := "01101";
constant addr_offset_HIBI_DMA_HIBI_ADDR2_slv_c      : std_ulogic_vector(5-1 downto 0) := "01101";

constant bit_offset_HIBI_DMA_HIBI_ADDR2_addr_c : integer := 0;

type hibi_dma_HIBI_DMA_HIBI_ADDR2_rw_t is record
  addr : std_ulogic_vector(15 downto 0);
end record hibi_dma_HIBI_DMA_HIBI_ADDR2_rw_t;
constant dflt_hibi_dma_HIBI_DMA_HIBI_ADDR2_c : hibi_dma_HIBI_DMA_HIBI_ADDR2_rw_t :=(
  addr => "0000000000000000"
);

type hibi_dma_HIBI_DMA_HIBI_ADDR2_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_HIBI_ADDR2_rw_t;
end record hibi_dma_HIBI_DMA_HIBI_ADDR2_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_TRIGGER_MASK2 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_TRIGGER_MASK2_integer_c  : integer := 14;
constant addr_offset_HIBI_DMA_TRIGGER_MASK2_unsigned_c : unsigned(5-1 downto 0) := "01110";
constant addr_offset_HIBI_DMA_TRIGGER_MASK2_slv_c      : std_ulogic_vector(5-1 downto 0) := "01110";

constant bit_offset_HIBI_DMA_TRIGGER_MASK2_mask_c : integer := 0;

type hibi_dma_HIBI_DMA_TRIGGER_MASK2_rw_t is record
  mask : std_ulogic_vector(3 downto 0);
end record hibi_dma_HIBI_DMA_TRIGGER_MASK2_rw_t;
constant dflt_hibi_dma_HIBI_DMA_TRIGGER_MASK2_c : hibi_dma_HIBI_DMA_TRIGGER_MASK2_rw_t :=(
  mask => "0000"
);

type hibi_dma_HIBI_DMA_TRIGGER_MASK2_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_TRIGGER_MASK2_rw_t;
end record hibi_dma_HIBI_DMA_TRIGGER_MASK2_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_CFG3 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_CFG3_integer_c  : integer := 15;
constant addr_offset_HIBI_DMA_CFG3_unsigned_c : unsigned(5-1 downto 0) := "01111";
constant addr_offset_HIBI_DMA_CFG3_slv_c      : std_ulogic_vector(5-1 downto 0) := "01111";

constant bit_offset_HIBI_DMA_CFG3_count_c : integer := 0;
constant bit_offset_HIBI_DMA_CFG3_direction_c : integer := 15;
constant bit_offset_HIBI_DMA_CFG3_hibi_cmd_c : integer := 16;
constant bit_offset_HIBI_DMA_CFG3_const_addr_c : integer := 21;

type hibi_dma_HIBI_DMA_CFG3_rw_t is record
  count : std_ulogic_vector(9 downto 0);
  direction : std_ulogic;
  hibi_cmd : std_ulogic_vector(4 downto 0);
  const_addr : std_ulogic;
end record hibi_dma_HIBI_DMA_CFG3_rw_t;
constant dflt_hibi_dma_HIBI_DMA_CFG3_c : hibi_dma_HIBI_DMA_CFG3_rw_t :=(
  count => "0000000000",
  direction => '1',
  hibi_cmd => "00010",
  const_addr => '0'
);

type hibi_dma_HIBI_DMA_CFG3_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_CFG3_rw_t;
end record hibi_dma_HIBI_DMA_CFG3_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_MEM_ADDR3 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_MEM_ADDR3_integer_c  : integer := 16;
constant addr_offset_HIBI_DMA_MEM_ADDR3_unsigned_c : unsigned(5-1 downto 0) := "10000";
constant addr_offset_HIBI_DMA_MEM_ADDR3_slv_c      : std_ulogic_vector(5-1 downto 0) := "10000";

constant bit_offset_HIBI_DMA_MEM_ADDR3_addr_c : integer := 0;

type hibi_dma_HIBI_DMA_MEM_ADDR3_rw_t is record
  addr : std_ulogic_vector(15 downto 0);
end record hibi_dma_HIBI_DMA_MEM_ADDR3_rw_t;
constant dflt_hibi_dma_HIBI_DMA_MEM_ADDR3_c : hibi_dma_HIBI_DMA_MEM_ADDR3_rw_t :=(
  addr => "0000000000000000"
);

type hibi_dma_HIBI_DMA_MEM_ADDR3_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_MEM_ADDR3_rw_t;
end record hibi_dma_HIBI_DMA_MEM_ADDR3_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_HIBI_ADDR3 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_HIBI_ADDR3_integer_c  : integer := 17;
constant addr_offset_HIBI_DMA_HIBI_ADDR3_unsigned_c : unsigned(5-1 downto 0) := "10001";
constant addr_offset_HIBI_DMA_HIBI_ADDR3_slv_c      : std_ulogic_vector(5-1 downto 0) := "10001";

constant bit_offset_HIBI_DMA_HIBI_ADDR3_addr_c : integer := 0;

type hibi_dma_HIBI_DMA_HIBI_ADDR3_rw_t is record
  addr : std_ulogic_vector(15 downto 0);
end record hibi_dma_HIBI_DMA_HIBI_ADDR3_rw_t;
constant dflt_hibi_dma_HIBI_DMA_HIBI_ADDR3_c : hibi_dma_HIBI_DMA_HIBI_ADDR3_rw_t :=(
  addr => "0000000000000000"
);

type hibi_dma_HIBI_DMA_HIBI_ADDR3_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_HIBI_ADDR3_rw_t;
end record hibi_dma_HIBI_DMA_HIBI_ADDR3_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_TRIGGER_MASK3 register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_TRIGGER_MASK3_integer_c  : integer := 18;
constant addr_offset_HIBI_DMA_TRIGGER_MASK3_unsigned_c : unsigned(5-1 downto 0) := "10010";
constant addr_offset_HIBI_DMA_TRIGGER_MASK3_slv_c      : std_ulogic_vector(5-1 downto 0) := "10010";

constant bit_offset_HIBI_DMA_TRIGGER_MASK3_mask_c : integer := 0;

type hibi_dma_HIBI_DMA_TRIGGER_MASK3_rw_t is record
  mask : std_ulogic_vector(3 downto 0);
end record hibi_dma_HIBI_DMA_TRIGGER_MASK3_rw_t;
constant dflt_hibi_dma_HIBI_DMA_TRIGGER_MASK3_c : hibi_dma_HIBI_DMA_TRIGGER_MASK3_rw_t :=(
  mask => "0000"
);

type hibi_dma_HIBI_DMA_TRIGGER_MASK3_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_TRIGGER_MASK3_rw_t;
end record hibi_dma_HIBI_DMA_TRIGGER_MASK3_reg2logic_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_GPIO register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_GPIO_integer_c  : integer := 19;
constant addr_offset_HIBI_DMA_GPIO_unsigned_c : unsigned(5-1 downto 0) := "10011";
constant addr_offset_HIBI_DMA_GPIO_slv_c      : std_ulogic_vector(5-1 downto 0) := "10011";

constant bit_offset_HIBI_DMA_GPIO_GPIO_0_c : integer := 0;
constant bit_offset_HIBI_DMA_GPIO_GPIO_1_c : integer := 1;
constant bit_offset_HIBI_DMA_GPIO_GPIO_2_c : integer := 2;
constant bit_offset_HIBI_DMA_GPIO_GPIO_3_c : integer := 3;
constant bit_offset_HIBI_DMA_GPIO_GPIO_4_c : integer := 4;
constant bit_offset_HIBI_DMA_GPIO_GPIO_5_c : integer := 5;
constant bit_offset_HIBI_DMA_GPIO_GPIO_6_c : integer := 6;
constant bit_offset_HIBI_DMA_GPIO_GPIO_7_c : integer := 7;
constant bit_offset_HIBI_DMA_GPIO_GPIO_8_c : integer := 8;
constant bit_offset_HIBI_DMA_GPIO_GPIO_9_c : integer := 9;
constant bit_offset_HIBI_DMA_GPIO_GPIO_A_c : integer := 10;
constant bit_offset_HIBI_DMA_GPIO_GPIO_B_c : integer := 11;
constant bit_offset_HIBI_DMA_GPIO_GPIO_C_c : integer := 12;
constant bit_offset_HIBI_DMA_GPIO_GPIO_D_c : integer := 13;
constant bit_offset_HIBI_DMA_GPIO_GPIO_E_c : integer := 14;
constant bit_offset_HIBI_DMA_GPIO_GPIO_F_c : integer := 15;

type hibi_dma_HIBI_DMA_GPIO_xw_t is record
  GPIO_0 : std_ulogic;
  GPIO_1 : std_ulogic;
  GPIO_2 : std_ulogic;
  GPIO_3 : std_ulogic;
  GPIO_4 : std_ulogic;
  GPIO_5 : std_ulogic;
  GPIO_6 : std_ulogic;
  GPIO_7 : std_ulogic;
  GPIO_8 : std_ulogic;
  GPIO_9 : std_ulogic;
  GPIO_A : std_ulogic;
  GPIO_B : std_ulogic;
  GPIO_C : std_ulogic;
  GPIO_D : std_ulogic;
  GPIO_E : std_ulogic;
  GPIO_F : std_ulogic;
end record hibi_dma_HIBI_DMA_GPIO_xw_t;

type hibi_dma_HIBI_DMA_GPIO_xr_t is record
  GPIO_0 : std_ulogic;
  GPIO_1 : std_ulogic;
  GPIO_2 : std_ulogic;
  GPIO_3 : std_ulogic;
  GPIO_4 : std_ulogic;
  GPIO_5 : std_ulogic;
  GPIO_6 : std_ulogic;
  GPIO_7 : std_ulogic;
  GPIO_8 : std_ulogic;
  GPIO_9 : std_ulogic;
  GPIO_A : std_ulogic;
  GPIO_B : std_ulogic;
  GPIO_C : std_ulogic;
  GPIO_D : std_ulogic;
  GPIO_E : std_ulogic;
  GPIO_F : std_ulogic;
end record hibi_dma_HIBI_DMA_GPIO_xr_t;

type hibi_dma_HIBI_DMA_GPIO_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  xw : hibi_dma_HIBI_DMA_GPIO_xw_t;
end record hibi_dma_HIBI_DMA_GPIO_reg2logic_t;

type hibi_dma_HIBI_DMA_GPIO_logic2reg_t is record
  xr : hibi_dma_HIBI_DMA_GPIO_xr_t;
end record hibi_dma_HIBI_DMA_GPIO_logic2reg_t;

-------------------------------------------------------------------------------
-- HIBI_DMA_GPIO_DIR register
-------------------------------------------------------------------------------
constant addr_offset_HIBI_DMA_GPIO_DIR_integer_c  : integer := 20;
constant addr_offset_HIBI_DMA_GPIO_DIR_unsigned_c : unsigned(5-1 downto 0) := "10100";
constant addr_offset_HIBI_DMA_GPIO_DIR_slv_c      : std_ulogic_vector(5-1 downto 0) := "10100";

constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_0_c : integer := 0;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_1_c : integer := 1;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_2_c : integer := 2;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_3_c : integer := 3;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_4_c : integer := 4;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_5_c : integer := 5;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_6_c : integer := 6;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_7_c : integer := 7;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_8_c : integer := 8;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_9_c : integer := 9;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_A_c : integer := 10;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_B_c : integer := 11;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_C_c : integer := 12;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_D_c : integer := 13;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_E_c : integer := 14;
constant bit_offset_HIBI_DMA_GPIO_DIR_GPIO_F_c : integer := 15;

type hibi_dma_HIBI_DMA_GPIO_DIR_rw_t is record
  GPIO_0 : std_ulogic;
  GPIO_1 : std_ulogic;
  GPIO_2 : std_ulogic;
  GPIO_3 : std_ulogic;
  GPIO_4 : std_ulogic;
  GPIO_5 : std_ulogic;
  GPIO_6 : std_ulogic;
  GPIO_7 : std_ulogic;
  GPIO_8 : std_ulogic;
  GPIO_9 : std_ulogic;
  GPIO_A : std_ulogic;
  GPIO_B : std_ulogic;
  GPIO_C : std_ulogic;
  GPIO_D : std_ulogic;
  GPIO_E : std_ulogic;
  GPIO_F : std_ulogic;
end record hibi_dma_HIBI_DMA_GPIO_DIR_rw_t;
constant dflt_hibi_dma_HIBI_DMA_GPIO_DIR_c : hibi_dma_HIBI_DMA_GPIO_DIR_rw_t :=(
  GPIO_0 => '0',
  GPIO_1 => '0',
  GPIO_2 => '0',
  GPIO_3 => '0',
  GPIO_4 => '0',
  GPIO_5 => '0',
  GPIO_6 => '0',
  GPIO_7 => '0',
  GPIO_8 => '0',
  GPIO_9 => '0',
  GPIO_A => '0',
  GPIO_B => '0',
  GPIO_C => '0',
  GPIO_D => '0',
  GPIO_E => '0',
  GPIO_F => '0'
);

type hibi_dma_HIBI_DMA_GPIO_DIR_reg2logic_t is record
  c : hibi_dma_regfile_ctrl_t;
  rw : hibi_dma_HIBI_DMA_GPIO_DIR_rw_t;
end record hibi_dma_HIBI_DMA_GPIO_DIR_reg2logic_t;

-------------------------------------------------------------------------------
-- putting it all together
-------------------------------------------------------------------------------
type hibi_dma_reg2logic_t is record
  HIBI_DMA_CTRL : hibi_dma_HIBI_DMA_CTRL_reg2logic_t;
  HIBI_DMA_STATUS : hibi_dma_HIBI_DMA_STATUS_reg2logic_t;
  HIBI_DMA_TRIGGER : hibi_dma_HIBI_DMA_TRIGGER_reg2logic_t;
  HIBI_DMA_CFG0 : hibi_dma_HIBI_DMA_CFG0_reg2logic_t;
  HIBI_DMA_MEM_ADDR0 : hibi_dma_HIBI_DMA_MEM_ADDR0_reg2logic_t;
  HIBI_DMA_HIBI_ADDR0 : hibi_dma_HIBI_DMA_HIBI_ADDR0_reg2logic_t;
  HIBI_DMA_TRIGGER_MASK0 : hibi_dma_HIBI_DMA_TRIGGER_MASK0_reg2logic_t;
  HIBI_DMA_CFG1 : hibi_dma_HIBI_DMA_CFG1_reg2logic_t;
  HIBI_DMA_MEM_ADDR1 : hibi_dma_HIBI_DMA_MEM_ADDR1_reg2logic_t;
  HIBI_DMA_HIBI_ADDR1 : hibi_dma_HIBI_DMA_HIBI_ADDR1_reg2logic_t;
  HIBI_DMA_TRIGGER_MASK1 : hibi_dma_HIBI_DMA_TRIGGER_MASK1_reg2logic_t;
  HIBI_DMA_CFG2 : hibi_dma_HIBI_DMA_CFG2_reg2logic_t;
  HIBI_DMA_MEM_ADDR2 : hibi_dma_HIBI_DMA_MEM_ADDR2_reg2logic_t;
  HIBI_DMA_HIBI_ADDR2 : hibi_dma_HIBI_DMA_HIBI_ADDR2_reg2logic_t;
  HIBI_DMA_TRIGGER_MASK2 : hibi_dma_HIBI_DMA_TRIGGER_MASK2_reg2logic_t;
  HIBI_DMA_CFG3 : hibi_dma_HIBI_DMA_CFG3_reg2logic_t;
  HIBI_DMA_MEM_ADDR3 : hibi_dma_HIBI_DMA_MEM_ADDR3_reg2logic_t;
  HIBI_DMA_HIBI_ADDR3 : hibi_dma_HIBI_DMA_HIBI_ADDR3_reg2logic_t;
  HIBI_DMA_TRIGGER_MASK3 : hibi_dma_HIBI_DMA_TRIGGER_MASK3_reg2logic_t;
  HIBI_DMA_GPIO : hibi_dma_HIBI_DMA_GPIO_reg2logic_t;
  HIBI_DMA_GPIO_DIR : hibi_dma_HIBI_DMA_GPIO_DIR_reg2logic_t;
end record hibi_dma_reg2logic_t;

type hibi_dma_logic2reg_t is record
  HIBI_DMA_STATUS : hibi_dma_HIBI_DMA_STATUS_logic2reg_t;
  HIBI_DMA_GPIO : hibi_dma_HIBI_DMA_GPIO_logic2reg_t;
end record hibi_dma_logic2reg_t;

end package hibi_dma_regfile_pkg;
