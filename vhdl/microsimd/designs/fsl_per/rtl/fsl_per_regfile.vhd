-------------------------------------------------------------------------------
-- Title      : fsl_per_regfile
-- Project    :
-------------------------------------------------------------------------------
-- File       : fsl_per_regfile.vhd
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

library work;
use work.fsl_per_regif_types_pkg.all;
use work.fsl_per_regfile_pkg.all;

--pragma translate_off
library std;
use std.textio.all;

library work;
use work.txt_util.all;
--pragma translate_on

entity fsl_per_regfile is
  port (
    clk_i       : in  std_ulogic;
    reset_n_i   : in  std_ulogic;
    gif_req_i   : in  fsl_per_gif_req_t;
    gif_rsp_o   : out fsl_per_gif_rsp_t;
    logic2reg_i : in  fsl_per_logic2reg_t;
    reg2logic_o : out fsl_per_reg2logic_t
  );
end entity fsl_per_regfile;

architecture rtl of fsl_per_regfile is

--pragma translate_off
  constant enable_msg_c  : boolean := true;
  constant module_name_c : string  := "fsl_per_regfile";
--pragma translate_on

  signal SCRATCHPAD0 : fsl_per_SCRATCHPAD0_rw_t;
  signal SCRATCHPAD1 : fsl_per_SCRATCHPAD1_rw_t;

begin
  -------------------------------------------------------------------------------
  --  SCRATCHPAD0 write logic (internally located register)
  -------------------------------------------------------------------------------
  SCRATCHPAD0_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      SCRATCHPAD0 <= dflt_fsl_per_SCRATCHPAD0_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_SCRATCHPAD0_slv_c and gif_req_i.wr = '1') then
        SCRATCHPAD0.scratch <= gif_req_i.wdata(3 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") SCRATCHPAD0 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> scratch: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(3 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process SCRATCHPAD0_rw;
  reg2logic_o.SCRATCHPAD0.rw <= SCRATCHPAD0;

  -------------------------------------------------------------------------------
  -- SCRATCHPAD0 access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.SCRATCHPAD0.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_SCRATCHPAD0_slv_c else '0';
  reg2logic_o.SCRATCHPAD0.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_SCRATCHPAD0_slv_c else '0';

  -------------------------------------------------------------------------------
  --  SCRATCHPAD1 write logic (internally located register)
  -------------------------------------------------------------------------------
  SCRATCHPAD1_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      SCRATCHPAD1 <= dflt_fsl_per_SCRATCHPAD1_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_SCRATCHPAD1_slv_c and gif_req_i.wr = '1') then
        SCRATCHPAD1.scratch <= gif_req_i.wdata(3 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") SCRATCHPAD1 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> scratch: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(3 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process SCRATCHPAD1_rw;
  reg2logic_o.SCRATCHPAD1.rw <= SCRATCHPAD1;

  -------------------------------------------------------------------------------
  -- SCRATCHPAD1 access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.SCRATCHPAD1.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_SCRATCHPAD1_slv_c else '0';
  reg2logic_o.SCRATCHPAD1.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_SCRATCHPAD1_slv_c else '0';


  -------------------------------------------------------------------------------
  -- GPIN0 access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.GPIN0.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_GPIN0_slv_c else '0';
  reg2logic_o.GPIN0.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_GPIN0_slv_c else '0';


  -------------------------------------------------------------------------------
  -- GPIN1 access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.GPIN1.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_GPIN1_slv_c else '0';
  reg2logic_o.GPIN1.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_GPIN1_slv_c else '0';

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
          when addr_offset_SCRATCHPAD0_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(3 downto 0) <= SCRATCHPAD0.scratch;
          when addr_offset_SCRATCHPAD1_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(3 downto 0) <= SCRATCHPAD1.scratch;
          when addr_offset_GPIN0_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(1 downto 0) <= logic2reg_i.GPIN0.ro.input;
          when addr_offset_GPIN1_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(1 downto 0) <= logic2reg_i.GPIN1.ro.input;
          when others =>
            gif_rsp_o.rdata <= (others=>'0');
        end case;
      end if;
    end if;
  end process read;

end architecture rtl;
