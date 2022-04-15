-------------------------------------------------------------------------------
-- Title      : hibi_pif_dma_regfile
-- Project    :
-------------------------------------------------------------------------------
-- File       : hibi_pif_dma_regfile.vhd
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

library microsimd;
use microsimd.hibi_pif_dma_regif_types_pkg.all;
use microsimd.hibi_pif_dma_regfile_pkg.all;

--pragma translate_off
library std;
use std.textio.all;

library hibi;
use hibi.txt_util.all;
--pragma translate_on

entity hibi_pif_dma_regfile is
  port (
    clk_i       : in  std_ulogic;
    reset_n_i   : in  std_ulogic;
    gif_req_i   : in  hibi_pif_dma_gif_req_t;
    gif_rsp_o   : out hibi_pif_dma_gif_rsp_t;
    logic2reg_i : in  hibi_pif_dma_logic2reg_t;
    reg2logic_o : out hibi_pif_dma_reg2logic_t
  );
end entity hibi_pif_dma_regfile;

architecture rtl of hibi_pif_dma_regfile is

--pragma translate_off
  constant enable_msg_c  : boolean := true;
  constant module_name_c : string  := "hibi_pif_dma_regfile";
--pragma translate_on

  signal HIBI_DMA_CTRL : hibi_pif_dma_HIBI_DMA_CTRL_rw_t;
  signal HIBI_DMA_CFG0 : hibi_pif_dma_HIBI_DMA_CFG0_rw_t;
  signal HIBI_DMA_MEM_ADDR0 : hibi_pif_dma_HIBI_DMA_MEM_ADDR0_rw_t;
  signal HIBI_DMA_HIBI_ADDR0 : hibi_pif_dma_HIBI_DMA_HIBI_ADDR0_rw_t;
  signal HIBI_DMA_TRIGGER_MASK0 : hibi_pif_dma_HIBI_DMA_TRIGGER_MASK0_rw_t;
  signal HIBI_DMA_CFG1 : hibi_pif_dma_HIBI_DMA_CFG1_rw_t;
  signal HIBI_DMA_MEM_ADDR1 : hibi_pif_dma_HIBI_DMA_MEM_ADDR1_rw_t;
  signal HIBI_DMA_HIBI_ADDR1 : hibi_pif_dma_HIBI_DMA_HIBI_ADDR1_rw_t;
  signal HIBI_DMA_TRIGGER_MASK1 : hibi_pif_dma_HIBI_DMA_TRIGGER_MASK1_rw_t;
  signal HIBI_DMA_CFG2 : hibi_pif_dma_HIBI_DMA_CFG2_rw_t;
  signal HIBI_DMA_MEM_ADDR2 : hibi_pif_dma_HIBI_DMA_MEM_ADDR2_rw_t;
  signal HIBI_DMA_HIBI_ADDR2 : hibi_pif_dma_HIBI_DMA_HIBI_ADDR2_rw_t;
  signal HIBI_DMA_TRIGGER_MASK2 : hibi_pif_dma_HIBI_DMA_TRIGGER_MASK2_rw_t;
  signal HIBI_DMA_CFG3 : hibi_pif_dma_HIBI_DMA_CFG3_rw_t;
  signal HIBI_DMA_MEM_ADDR3 : hibi_pif_dma_HIBI_DMA_MEM_ADDR3_rw_t;
  signal HIBI_DMA_HIBI_ADDR3 : hibi_pif_dma_HIBI_DMA_HIBI_ADDR3_rw_t;
  signal HIBI_DMA_TRIGGER_MASK3 : hibi_pif_dma_HIBI_DMA_TRIGGER_MASK3_rw_t;
  signal HIBI_TXPIF_CFG : hibi_pif_dma_HIBI_TXPIF_CFG_rw_t;
  signal HIBI_PIF_CTRL : hibi_pif_dma_HIBI_PIF_CTRL_rw_t;

begin
-------------------------------------------------------------------------------
--  HIBI_DMA_CTRL write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_CTRL_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_CTRL <= dflt_hibi_pif_dma_HIBI_DMA_CTRL_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_CTRL_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_CTRL.en <= gif_req_i.wdata(0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_CTRL write access: "));
          writeline(output, wr);
          write(wr, string'("  -> en: ") &
          std_ulogic'image(gif_req_i.wdata(0)));
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_CTRL_rw;
  reg2logic_o.HIBI_DMA_CTRL.rw <= HIBI_DMA_CTRL;
------------------------------------------------------------------------------
--  HIBI_DMA_TRIGGER logic (combinatorial only since extended xw, xr, xrw)
------------------------------------------------------------------------------
  HIBI_DMA_TRIGGER_c: process(gif_req_i.addr, gif_req_i.wr, gif_req_i.rd, gif_req_i.wdata) is
  begin
    reg2logic_o.HIBI_DMA_TRIGGER.c.wr <= '0';
    reg2logic_o.HIBI_DMA_TRIGGER.c.rd <= '0';

    if(gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_slv_c) then
      reg2logic_o.HIBI_DMA_TRIGGER.c.wr <= gif_req_i.wr;
      reg2logic_o.HIBI_DMA_TRIGGER.c.rd <= gif_req_i.rd;
    end if;

    reg2logic_o.HIBI_DMA_TRIGGER.xw.start0 <= gif_req_i.wdata(0);
    reg2logic_o.HIBI_DMA_TRIGGER.xw.start1 <= gif_req_i.wdata(1);
    reg2logic_o.HIBI_DMA_TRIGGER.xw.start2 <= gif_req_i.wdata(2);
    reg2logic_o.HIBI_DMA_TRIGGER.xw.start3 <= gif_req_i.wdata(3);
  end process HIBI_DMA_TRIGGER_c;
-------------------------------------------------------------------------------
--  HIBI_DMA_CFG0 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_CFG0_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_CFG0 <= dflt_hibi_pif_dma_HIBI_DMA_CFG0_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_CFG0_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_CFG0.count <= gif_req_i.wdata(9 downto 0);
        HIBI_DMA_CFG0.direction <= gif_req_i.wdata(15);
        HIBI_DMA_CFG0.hibi_cmd <= gif_req_i.wdata(20 downto 16);
        HIBI_DMA_CFG0.const_addr <= gif_req_i.wdata(21);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_CFG0 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> count: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(9 downto 0))) );
          writeline(output, wr);
          write(wr, string'("  -> direction: ") &
          std_ulogic'image(gif_req_i.wdata(15)));
          writeline(output, wr);
          write(wr, string'("  -> hibi_cmd: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(20 downto 16))) );
          writeline(output, wr);
          write(wr, string'("  -> const_addr: ") &
          std_ulogic'image(gif_req_i.wdata(21)));
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_CFG0_rw;
  reg2logic_o.HIBI_DMA_CFG0.rw <= HIBI_DMA_CFG0;
-------------------------------------------------------------------------------
--  HIBI_DMA_MEM_ADDR0 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_MEM_ADDR0_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_MEM_ADDR0 <= dflt_hibi_pif_dma_HIBI_DMA_MEM_ADDR0_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_MEM_ADDR0_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_MEM_ADDR0.addr <= gif_req_i.wdata(2 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_MEM_ADDR0 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> addr: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(2 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_MEM_ADDR0_rw;
  reg2logic_o.HIBI_DMA_MEM_ADDR0.rw <= HIBI_DMA_MEM_ADDR0;
-------------------------------------------------------------------------------
--  HIBI_DMA_HIBI_ADDR0 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_HIBI_ADDR0_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_HIBI_ADDR0 <= dflt_hibi_pif_dma_HIBI_DMA_HIBI_ADDR0_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_HIBI_ADDR0_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_HIBI_ADDR0.addr <= gif_req_i.wdata(15 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_HIBI_ADDR0 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> addr: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(15 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_HIBI_ADDR0_rw;
  reg2logic_o.HIBI_DMA_HIBI_ADDR0.rw <= HIBI_DMA_HIBI_ADDR0;
-------------------------------------------------------------------------------
--  HIBI_DMA_TRIGGER_MASK0 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_TRIGGER_MASK0_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_TRIGGER_MASK0 <= dflt_hibi_pif_dma_HIBI_DMA_TRIGGER_MASK0_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_MASK0_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_TRIGGER_MASK0.mask <= gif_req_i.wdata(3 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_TRIGGER_MASK0 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> mask: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(3 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_TRIGGER_MASK0_rw;
  reg2logic_o.HIBI_DMA_TRIGGER_MASK0.rw <= HIBI_DMA_TRIGGER_MASK0;
-------------------------------------------------------------------------------
--  HIBI_DMA_CFG1 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_CFG1_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_CFG1 <= dflt_hibi_pif_dma_HIBI_DMA_CFG1_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_CFG1_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_CFG1.count <= gif_req_i.wdata(9 downto 0);
        HIBI_DMA_CFG1.direction <= gif_req_i.wdata(15);
        HIBI_DMA_CFG1.hibi_cmd <= gif_req_i.wdata(20 downto 16);
        HIBI_DMA_CFG1.const_addr <= gif_req_i.wdata(21);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_CFG1 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> count: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(9 downto 0))) );
          writeline(output, wr);
          write(wr, string'("  -> direction: ") &
          std_ulogic'image(gif_req_i.wdata(15)));
          writeline(output, wr);
          write(wr, string'("  -> hibi_cmd: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(20 downto 16))) );
          writeline(output, wr);
          write(wr, string'("  -> const_addr: ") &
          std_ulogic'image(gif_req_i.wdata(21)));
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_CFG1_rw;
  reg2logic_o.HIBI_DMA_CFG1.rw <= HIBI_DMA_CFG1;
-------------------------------------------------------------------------------
--  HIBI_DMA_MEM_ADDR1 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_MEM_ADDR1_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_MEM_ADDR1 <= dflt_hibi_pif_dma_HIBI_DMA_MEM_ADDR1_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_MEM_ADDR1_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_MEM_ADDR1.addr <= gif_req_i.wdata(2 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_MEM_ADDR1 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> addr: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(2 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_MEM_ADDR1_rw;
  reg2logic_o.HIBI_DMA_MEM_ADDR1.rw <= HIBI_DMA_MEM_ADDR1;
-------------------------------------------------------------------------------
--  HIBI_DMA_HIBI_ADDR1 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_HIBI_ADDR1_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_HIBI_ADDR1 <= dflt_hibi_pif_dma_HIBI_DMA_HIBI_ADDR1_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_HIBI_ADDR1_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_HIBI_ADDR1.addr <= gif_req_i.wdata(15 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_HIBI_ADDR1 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> addr: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(15 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_HIBI_ADDR1_rw;
  reg2logic_o.HIBI_DMA_HIBI_ADDR1.rw <= HIBI_DMA_HIBI_ADDR1;
-------------------------------------------------------------------------------
--  HIBI_DMA_TRIGGER_MASK1 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_TRIGGER_MASK1_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_TRIGGER_MASK1 <= dflt_hibi_pif_dma_HIBI_DMA_TRIGGER_MASK1_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_MASK1_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_TRIGGER_MASK1.mask <= gif_req_i.wdata(3 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_TRIGGER_MASK1 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> mask: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(3 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_TRIGGER_MASK1_rw;
  reg2logic_o.HIBI_DMA_TRIGGER_MASK1.rw <= HIBI_DMA_TRIGGER_MASK1;
-------------------------------------------------------------------------------
--  HIBI_DMA_CFG2 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_CFG2_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_CFG2 <= dflt_hibi_pif_dma_HIBI_DMA_CFG2_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_CFG2_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_CFG2.count <= gif_req_i.wdata(9 downto 0);
        HIBI_DMA_CFG2.direction <= gif_req_i.wdata(15);
        HIBI_DMA_CFG2.hibi_cmd <= gif_req_i.wdata(20 downto 16);
        HIBI_DMA_CFG2.const_addr <= gif_req_i.wdata(21);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_CFG2 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> count: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(9 downto 0))) );
          writeline(output, wr);
          write(wr, string'("  -> direction: ") &
          std_ulogic'image(gif_req_i.wdata(15)));
          writeline(output, wr);
          write(wr, string'("  -> hibi_cmd: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(20 downto 16))) );
          writeline(output, wr);
          write(wr, string'("  -> const_addr: ") &
          std_ulogic'image(gif_req_i.wdata(21)));
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_CFG2_rw;
  reg2logic_o.HIBI_DMA_CFG2.rw <= HIBI_DMA_CFG2;
-------------------------------------------------------------------------------
--  HIBI_DMA_MEM_ADDR2 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_MEM_ADDR2_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_MEM_ADDR2 <= dflt_hibi_pif_dma_HIBI_DMA_MEM_ADDR2_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_MEM_ADDR2_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_MEM_ADDR2.addr <= gif_req_i.wdata(2 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_MEM_ADDR2 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> addr: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(2 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_MEM_ADDR2_rw;
  reg2logic_o.HIBI_DMA_MEM_ADDR2.rw <= HIBI_DMA_MEM_ADDR2;
-------------------------------------------------------------------------------
--  HIBI_DMA_HIBI_ADDR2 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_HIBI_ADDR2_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_HIBI_ADDR2 <= dflt_hibi_pif_dma_HIBI_DMA_HIBI_ADDR2_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_HIBI_ADDR2_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_HIBI_ADDR2.addr <= gif_req_i.wdata(15 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_HIBI_ADDR2 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> addr: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(15 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_HIBI_ADDR2_rw;
  reg2logic_o.HIBI_DMA_HIBI_ADDR2.rw <= HIBI_DMA_HIBI_ADDR2;
-------------------------------------------------------------------------------
--  HIBI_DMA_TRIGGER_MASK2 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_TRIGGER_MASK2_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_TRIGGER_MASK2 <= dflt_hibi_pif_dma_HIBI_DMA_TRIGGER_MASK2_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_MASK2_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_TRIGGER_MASK2.mask <= gif_req_i.wdata(3 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_TRIGGER_MASK2 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> mask: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(3 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_TRIGGER_MASK2_rw;
  reg2logic_o.HIBI_DMA_TRIGGER_MASK2.rw <= HIBI_DMA_TRIGGER_MASK2;
-------------------------------------------------------------------------------
--  HIBI_DMA_CFG3 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_CFG3_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_CFG3 <= dflt_hibi_pif_dma_HIBI_DMA_CFG3_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_CFG3_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_CFG3.count <= gif_req_i.wdata(9 downto 0);
        HIBI_DMA_CFG3.direction <= gif_req_i.wdata(15);
        HIBI_DMA_CFG3.hibi_cmd <= gif_req_i.wdata(20 downto 16);
        HIBI_DMA_CFG3.const_addr <= gif_req_i.wdata(21);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_CFG3 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> count: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(9 downto 0))) );
          writeline(output, wr);
          write(wr, string'("  -> direction: ") &
          std_ulogic'image(gif_req_i.wdata(15)));
          writeline(output, wr);
          write(wr, string'("  -> hibi_cmd: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(20 downto 16))) );
          writeline(output, wr);
          write(wr, string'("  -> const_addr: ") &
          std_ulogic'image(gif_req_i.wdata(21)));
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_CFG3_rw;
  reg2logic_o.HIBI_DMA_CFG3.rw <= HIBI_DMA_CFG3;
-------------------------------------------------------------------------------
--  HIBI_DMA_MEM_ADDR3 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_MEM_ADDR3_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_MEM_ADDR3 <= dflt_hibi_pif_dma_HIBI_DMA_MEM_ADDR3_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_MEM_ADDR3_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_MEM_ADDR3.addr <= gif_req_i.wdata(2 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_MEM_ADDR3 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> addr: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(2 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_MEM_ADDR3_rw;
  reg2logic_o.HIBI_DMA_MEM_ADDR3.rw <= HIBI_DMA_MEM_ADDR3;
-------------------------------------------------------------------------------
--  HIBI_DMA_HIBI_ADDR3 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_HIBI_ADDR3_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_HIBI_ADDR3 <= dflt_hibi_pif_dma_HIBI_DMA_HIBI_ADDR3_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_HIBI_ADDR3_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_HIBI_ADDR3.addr <= gif_req_i.wdata(15 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_HIBI_ADDR3 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> addr: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(15 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_HIBI_ADDR3_rw;
  reg2logic_o.HIBI_DMA_HIBI_ADDR3.rw <= HIBI_DMA_HIBI_ADDR3;
-------------------------------------------------------------------------------
--  HIBI_DMA_TRIGGER_MASK3 write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_DMA_TRIGGER_MASK3_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_TRIGGER_MASK3 <= dflt_hibi_pif_dma_HIBI_DMA_TRIGGER_MASK3_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_MASK3_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_TRIGGER_MASK3.mask <= gif_req_i.wdata(3 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_TRIGGER_MASK3 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> mask: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(3 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_TRIGGER_MASK3_rw;
  reg2logic_o.HIBI_DMA_TRIGGER_MASK3.rw <= HIBI_DMA_TRIGGER_MASK3;
-------------------------------------------------------------------------------
--  HIBI_TXPIF_CFG write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_TXPIF_CFG_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_TXPIF_CFG <= dflt_hibi_pif_dma_HIBI_TXPIF_CFG_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_TXPIF_CFG_slv_c and gif_req_i.wr = '1') then
        HIBI_TXPIF_CFG.hsize <= gif_req_i.wdata(8 downto 0);
        HIBI_TXPIF_CFG.vsize <= gif_req_i.wdata(24 downto 16);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_TXPIF_CFG write access: "));
          writeline(output, wr);
          write(wr, string'("  -> hsize: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(8 downto 0))) );
          writeline(output, wr);
          write(wr, string'("  -> vsize: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(24 downto 16))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_TXPIF_CFG_rw;
  reg2logic_o.HIBI_TXPIF_CFG.rw <= HIBI_TXPIF_CFG;
------------------------------------------------------------------------------
--  HIBI_TRIG_CTRL logic (combinatorial only since extended xw, xr, xrw)
------------------------------------------------------------------------------
  HIBI_TRIG_CTRL_c: process(gif_req_i.addr, gif_req_i.wr, gif_req_i.rd, gif_req_i.wdata) is
  begin
    reg2logic_o.HIBI_TRIG_CTRL.c.wr <= '0';
    reg2logic_o.HIBI_TRIG_CTRL.c.rd <= '0';

    if(gif_req_i.addr = addr_offset_HIBI_TRIG_CTRL_slv_c) then
      reg2logic_o.HIBI_TRIG_CTRL.c.wr <= gif_req_i.wr;
      reg2logic_o.HIBI_TRIG_CTRL.c.rd <= gif_req_i.rd;
    end if;

    reg2logic_o.HIBI_TRIG_CTRL.xw.le <= gif_req_i.wdata(0);
    reg2logic_o.HIBI_TRIG_CTRL.xw.fe <= gif_req_i.wdata(1);
  end process HIBI_TRIG_CTRL_c;
-------------------------------------------------------------------------------
--  HIBI_PIF_CTRL write logic (internally located register)
-------------------------------------------------------------------------------
  HIBI_PIF_CTRL_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_PIF_CTRL <= dflt_hibi_pif_dma_HIBI_PIF_CTRL_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_PIF_CTRL_slv_c and gif_req_i.wr = '1') then
        HIBI_PIF_CTRL.txen <= gif_req_i.wdata(4);
        HIBI_PIF_CTRL.rxen <= gif_req_i.wdata(5);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_PIF_CTRL write access: "));
          writeline(output, wr);
          write(wr, string'("  -> txen: ") &
          std_ulogic'image(gif_req_i.wdata(4)));
          writeline(output, wr);
          write(wr, string'("  -> rxen: ") &
          std_ulogic'image(gif_req_i.wdata(5)));
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_PIF_CTRL_rw;
  reg2logic_o.HIBI_PIF_CTRL.rw <= HIBI_PIF_CTRL;
-------------------------------------------------------------------------------
-- read logic
-------------------------------------------------------------------------------
  read: process(clk_i, reset_n_i) is
  begin
    if(reset_n_i = '0') then
      gif_rsp_o.rdata <= (others=>'0');
      gif_rsp_o.ack   <= '0';
    elsif(rising_edge(clk_i)) then
      gif_rsp_o.ack <= gif_req_i.rd or gif_req_i.wr;

      if(gif_req_i.rd = '1') then
        case(gif_req_i.addr) is
          when addr_offset_HIBI_DMA_CTRL_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(0) <= HIBI_DMA_CTRL.en;
          when addr_offset_HIBI_DMA_STATUS_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(0) <= logic2reg_i.HIBI_DMA_STATUS.ro.busy0;
            gif_rsp_o.rdata(1) <= logic2reg_i.HIBI_DMA_STATUS.ro.busy1;
            gif_rsp_o.rdata(2) <= logic2reg_i.HIBI_DMA_STATUS.ro.busy2;
            gif_rsp_o.rdata(3) <= logic2reg_i.HIBI_DMA_STATUS.ro.busy3;
          when addr_offset_HIBI_DMA_TRIGGER_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(0) <= '0';
            gif_rsp_o.rdata(1) <= '0';
            gif_rsp_o.rdata(2) <= '0';
            gif_rsp_o.rdata(3) <= '0';
          when addr_offset_HIBI_DMA_CFG0_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(9 downto 0) <= HIBI_DMA_CFG0.count;
            gif_rsp_o.rdata(15) <= HIBI_DMA_CFG0.direction;
            gif_rsp_o.rdata(20 downto 16) <= HIBI_DMA_CFG0.hibi_cmd;
            gif_rsp_o.rdata(21) <= HIBI_DMA_CFG0.const_addr;
          when addr_offset_HIBI_DMA_MEM_ADDR0_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(2 downto 0) <= HIBI_DMA_MEM_ADDR0.addr;
          when addr_offset_HIBI_DMA_HIBI_ADDR0_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(15 downto 0) <= HIBI_DMA_HIBI_ADDR0.addr;
          when addr_offset_HIBI_DMA_TRIGGER_MASK0_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(3 downto 0) <= HIBI_DMA_TRIGGER_MASK0.mask;
          when addr_offset_HIBI_DMA_CFG1_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(9 downto 0) <= HIBI_DMA_CFG1.count;
            gif_rsp_o.rdata(15) <= HIBI_DMA_CFG1.direction;
            gif_rsp_o.rdata(20 downto 16) <= HIBI_DMA_CFG1.hibi_cmd;
            gif_rsp_o.rdata(21) <= HIBI_DMA_CFG1.const_addr;
          when addr_offset_HIBI_DMA_MEM_ADDR1_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(2 downto 0) <= HIBI_DMA_MEM_ADDR1.addr;
          when addr_offset_HIBI_DMA_HIBI_ADDR1_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(15 downto 0) <= HIBI_DMA_HIBI_ADDR1.addr;
          when addr_offset_HIBI_DMA_TRIGGER_MASK1_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(3 downto 0) <= HIBI_DMA_TRIGGER_MASK1.mask;
          when addr_offset_HIBI_DMA_CFG2_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(9 downto 0) <= HIBI_DMA_CFG2.count;
            gif_rsp_o.rdata(15) <= HIBI_DMA_CFG2.direction;
            gif_rsp_o.rdata(20 downto 16) <= HIBI_DMA_CFG2.hibi_cmd;
            gif_rsp_o.rdata(21) <= HIBI_DMA_CFG2.const_addr;
          when addr_offset_HIBI_DMA_MEM_ADDR2_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(2 downto 0) <= HIBI_DMA_MEM_ADDR2.addr;
          when addr_offset_HIBI_DMA_HIBI_ADDR2_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(15 downto 0) <= HIBI_DMA_HIBI_ADDR2.addr;
          when addr_offset_HIBI_DMA_TRIGGER_MASK2_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(3 downto 0) <= HIBI_DMA_TRIGGER_MASK2.mask;
          when addr_offset_HIBI_DMA_CFG3_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(9 downto 0) <= HIBI_DMA_CFG3.count;
            gif_rsp_o.rdata(15) <= HIBI_DMA_CFG3.direction;
            gif_rsp_o.rdata(20 downto 16) <= HIBI_DMA_CFG3.hibi_cmd;
            gif_rsp_o.rdata(21) <= HIBI_DMA_CFG3.const_addr;
          when addr_offset_HIBI_DMA_MEM_ADDR3_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(2 downto 0) <= HIBI_DMA_MEM_ADDR3.addr;
          when addr_offset_HIBI_DMA_HIBI_ADDR3_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(15 downto 0) <= HIBI_DMA_HIBI_ADDR3.addr;
          when addr_offset_HIBI_DMA_TRIGGER_MASK3_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(3 downto 0) <= HIBI_DMA_TRIGGER_MASK3.mask;
          when addr_offset_HIBI_TXPIF_CFG_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(8 downto 0) <= HIBI_TXPIF_CFG.hsize;
            gif_rsp_o.rdata(24 downto 16) <= HIBI_TXPIF_CFG.vsize;
          when addr_offset_HIBI_TRIG_CTRL_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(0) <= '0';
            gif_rsp_o.rdata(1) <= '0';
          when addr_offset_HIBI_PIF_CTRL_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(4) <= HIBI_PIF_CTRL.txen;
            gif_rsp_o.rdata(5) <= HIBI_PIF_CTRL.rxen;
          when addr_offset_HIBI_TXPIF_STATUS_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(0) <= logic2reg_i.HIBI_TXPIF_STATUS.ro.busy;
            gif_rsp_o.rdata(1) <= logic2reg_i.HIBI_TXPIF_STATUS.ro.hsync;
            gif_rsp_o.rdata(2) <= logic2reg_i.HIBI_TXPIF_STATUS.ro.vsync;
          when others =>
            gif_rsp_o.rdata <= (others=>'0');
        end case;
      end if;
    end if;
  end process read;

end architecture rtl;
