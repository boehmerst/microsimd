-------------------------------------------------------------------------------
-- Title      : hibi_wishbone_bridge_regfile
-- Project    :
-------------------------------------------------------------------------------
-- File       : hibi_wishbone_bridge_regfile.vhd
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
use work.hibi_wishbone_bridge_regif_types_pkg.all;
use work.hibi_wishbone_bridge_regfile_pkg.all;

--pragma translate_off
library std;
use std.textio.all;

library work;
use work.txt_util.all;
--pragma translate_on

entity hibi_wishbone_bridge_regfile is
  port (
    clk_i       : in  std_ulogic;
    reset_n_i   : in  std_ulogic;
    gif_req_i   : in  hibi_wishbone_bridge_gif_req_t;
    gif_rsp_o   : out hibi_wishbone_bridge_gif_rsp_t;
    logic2reg_i : in  hibi_wishbone_bridge_logic2reg_t;
    reg2logic_o : out hibi_wishbone_bridge_reg2logic_t
  );
end entity hibi_wishbone_bridge_regfile;

architecture rtl of hibi_wishbone_bridge_regfile is

--pragma translate_off
  constant enable_msg_c  : boolean := true;
  constant module_name_c : string  := "hibi_wishbone_bridge_regfile";
--pragma translate_on

  signal HIBI_DMA_CTRL : hibi_wishbone_bridge_HIBI_DMA_CTRL_rw_t;
  signal HIBI_DMA_CFG0 : hibi_wishbone_bridge_HIBI_DMA_CFG0_rw_t;
  signal HIBI_DMA_MEM_ADDR0 : hibi_wishbone_bridge_HIBI_DMA_MEM_ADDR0_rw_t;
  signal HIBI_DMA_HIBI_ADDR0 : hibi_wishbone_bridge_HIBI_DMA_HIBI_ADDR0_rw_t;
  signal HIBI_DMA_TRIGGER_MASK0 : hibi_wishbone_bridge_HIBI_DMA_TRIGGER_MASK0_rw_t;
  signal HIBI_DMA_CFG1 : hibi_wishbone_bridge_HIBI_DMA_CFG1_rw_t;
  signal HIBI_DMA_MEM_ADDR1 : hibi_wishbone_bridge_HIBI_DMA_MEM_ADDR1_rw_t;
  signal HIBI_DMA_HIBI_ADDR1 : hibi_wishbone_bridge_HIBI_DMA_HIBI_ADDR1_rw_t;
  signal HIBI_DMA_TRIGGER_MASK1 : hibi_wishbone_bridge_HIBI_DMA_TRIGGER_MASK1_rw_t;
  signal HIBI_DMA_GPIO_DIR : hibi_wishbone_bridge_HIBI_DMA_GPIO_DIR_rw_t;

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
      HIBI_DMA_CTRL <= dflt_hibi_wishbone_bridge_HIBI_DMA_CTRL_c;
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

  -------------------------------------------------------------------------------
  -- HIBI_DMA_CTRL access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_CTRL.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_CTRL_slv_c else '0';
  reg2logic_o.HIBI_DMA_CTRL.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_CTRL_slv_c else '0';


  -------------------------------------------------------------------------------
  -- HIBI_DMA_STATUS access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_STATUS.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_STATUS_slv_c else '0';
  reg2logic_o.HIBI_DMA_STATUS.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_STATUS_slv_c else '0';


  -------------------------------------------------------------------------------
  -- HIBI_DMA_TRIGGER access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_TRIGGER.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_slv_c else '0';
  reg2logic_o.HIBI_DMA_TRIGGER.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_slv_c else '0';
  reg2logic_o.HIBI_DMA_TRIGGER.xw.start0 <= gif_req_i.wdata(0);
  reg2logic_o.HIBI_DMA_TRIGGER.xw.start1 <= gif_req_i.wdata(1);

  -------------------------------------------------------------------------------
  --  HIBI_DMA_CFG0 write logic (internally located register)
  -------------------------------------------------------------------------------
  HIBI_DMA_CFG0_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_CFG0 <= dflt_hibi_wishbone_bridge_HIBI_DMA_CFG0_c;
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
  -- HIBI_DMA_CFG0 access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_CFG0.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_CFG0_slv_c else '0';
  reg2logic_o.HIBI_DMA_CFG0.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_CFG0_slv_c else '0';

  -------------------------------------------------------------------------------
  --  HIBI_DMA_MEM_ADDR0 write logic (internally located register)
  -------------------------------------------------------------------------------
  HIBI_DMA_MEM_ADDR0_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_MEM_ADDR0 <= dflt_hibi_wishbone_bridge_HIBI_DMA_MEM_ADDR0_c;
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
  -- HIBI_DMA_MEM_ADDR0 access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_MEM_ADDR0.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_MEM_ADDR0_slv_c else '0';
  reg2logic_o.HIBI_DMA_MEM_ADDR0.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_MEM_ADDR0_slv_c else '0';

  -------------------------------------------------------------------------------
  --  HIBI_DMA_HIBI_ADDR0 write logic (internally located register)
  -------------------------------------------------------------------------------
  HIBI_DMA_HIBI_ADDR0_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_HIBI_ADDR0 <= dflt_hibi_wishbone_bridge_HIBI_DMA_HIBI_ADDR0_c;
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
  -- HIBI_DMA_HIBI_ADDR0 access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_HIBI_ADDR0.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_HIBI_ADDR0_slv_c else '0';
  reg2logic_o.HIBI_DMA_HIBI_ADDR0.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_HIBI_ADDR0_slv_c else '0';

  -------------------------------------------------------------------------------
  --  HIBI_DMA_TRIGGER_MASK0 write logic (internally located register)
  -------------------------------------------------------------------------------
  HIBI_DMA_TRIGGER_MASK0_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_TRIGGER_MASK0 <= dflt_hibi_wishbone_bridge_HIBI_DMA_TRIGGER_MASK0_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_MASK0_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_TRIGGER_MASK0.mask <= gif_req_i.wdata(1 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_TRIGGER_MASK0 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> mask: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(1 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_TRIGGER_MASK0_rw;
  reg2logic_o.HIBI_DMA_TRIGGER_MASK0.rw <= HIBI_DMA_TRIGGER_MASK0;

  -------------------------------------------------------------------------------
  -- HIBI_DMA_TRIGGER_MASK0 access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_TRIGGER_MASK0.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_MASK0_slv_c else '0';
  reg2logic_o.HIBI_DMA_TRIGGER_MASK0.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_MASK0_slv_c else '0';

  -------------------------------------------------------------------------------
  --  HIBI_DMA_CFG1 write logic (internally located register)
  -------------------------------------------------------------------------------
  HIBI_DMA_CFG1_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_CFG1 <= dflt_hibi_wishbone_bridge_HIBI_DMA_CFG1_c;
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
  -- HIBI_DMA_CFG1 access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_CFG1.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_CFG1_slv_c else '0';
  reg2logic_o.HIBI_DMA_CFG1.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_CFG1_slv_c else '0';

  -------------------------------------------------------------------------------
  --  HIBI_DMA_MEM_ADDR1 write logic (internally located register)
  -------------------------------------------------------------------------------
  HIBI_DMA_MEM_ADDR1_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_MEM_ADDR1 <= dflt_hibi_wishbone_bridge_HIBI_DMA_MEM_ADDR1_c;
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
  -- HIBI_DMA_MEM_ADDR1 access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_MEM_ADDR1.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_MEM_ADDR1_slv_c else '0';
  reg2logic_o.HIBI_DMA_MEM_ADDR1.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_MEM_ADDR1_slv_c else '0';

  -------------------------------------------------------------------------------
  --  HIBI_DMA_HIBI_ADDR1 write logic (internally located register)
  -------------------------------------------------------------------------------
  HIBI_DMA_HIBI_ADDR1_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_HIBI_ADDR1 <= dflt_hibi_wishbone_bridge_HIBI_DMA_HIBI_ADDR1_c;
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
  -- HIBI_DMA_HIBI_ADDR1 access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_HIBI_ADDR1.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_HIBI_ADDR1_slv_c else '0';
  reg2logic_o.HIBI_DMA_HIBI_ADDR1.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_HIBI_ADDR1_slv_c else '0';

  -------------------------------------------------------------------------------
  --  HIBI_DMA_TRIGGER_MASK1 write logic (internally located register)
  -------------------------------------------------------------------------------
  HIBI_DMA_TRIGGER_MASK1_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_TRIGGER_MASK1 <= dflt_hibi_wishbone_bridge_HIBI_DMA_TRIGGER_MASK1_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_MASK1_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_TRIGGER_MASK1.mask <= gif_req_i.wdata(1 downto 0);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_TRIGGER_MASK1 write access: "));
          writeline(output, wr);
          write(wr, string'("  -> mask: ") &
          string'("0x") & hstr(std_logic_vector(gif_req_i.wdata(1 downto 0))) );
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_TRIGGER_MASK1_rw;
  reg2logic_o.HIBI_DMA_TRIGGER_MASK1.rw <= HIBI_DMA_TRIGGER_MASK1;

  -------------------------------------------------------------------------------
  -- HIBI_DMA_TRIGGER_MASK1 access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_TRIGGER_MASK1.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_MASK1_slv_c else '0';
  reg2logic_o.HIBI_DMA_TRIGGER_MASK1.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_TRIGGER_MASK1_slv_c else '0';


  -------------------------------------------------------------------------------
  -- HIBI_DMA_GPIO access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_GPIO.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_GPIO_slv_c else '0';
  reg2logic_o.HIBI_DMA_GPIO.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_GPIO_slv_c else '0';
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_0 <= gif_req_i.wdata(0);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_1 <= gif_req_i.wdata(1);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_2 <= gif_req_i.wdata(2);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_3 <= gif_req_i.wdata(3);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_4 <= gif_req_i.wdata(4);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_5 <= gif_req_i.wdata(5);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_6 <= gif_req_i.wdata(6);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_7 <= gif_req_i.wdata(7);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_8 <= gif_req_i.wdata(8);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_9 <= gif_req_i.wdata(9);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_A <= gif_req_i.wdata(10);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_B <= gif_req_i.wdata(11);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_C <= gif_req_i.wdata(12);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_D <= gif_req_i.wdata(13);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_E <= gif_req_i.wdata(14);
  reg2logic_o.HIBI_DMA_GPIO.xw.GPIO_F <= gif_req_i.wdata(15);

  -------------------------------------------------------------------------------
  --  HIBI_DMA_GPIO_DIR write logic (internally located register)
  -------------------------------------------------------------------------------
  HIBI_DMA_GPIO_DIR_rw: process(clk_i, reset_n_i) is
--pragma translate_off
    variable wr : line;
--pragma translate_on
  begin
    if(reset_n_i = '0') then
      HIBI_DMA_GPIO_DIR <= dflt_hibi_wishbone_bridge_HIBI_DMA_GPIO_DIR_c;
    elsif(rising_edge(clk_i)) then
      if(gif_req_i.addr = addr_offset_HIBI_DMA_GPIO_DIR_slv_c and gif_req_i.wr = '1') then
        HIBI_DMA_GPIO_DIR.GPIO_0 <= gif_req_i.wdata(0);
        HIBI_DMA_GPIO_DIR.GPIO_1 <= gif_req_i.wdata(1);
        HIBI_DMA_GPIO_DIR.GPIO_2 <= gif_req_i.wdata(2);
        HIBI_DMA_GPIO_DIR.GPIO_3 <= gif_req_i.wdata(3);
        HIBI_DMA_GPIO_DIR.GPIO_4 <= gif_req_i.wdata(4);
        HIBI_DMA_GPIO_DIR.GPIO_5 <= gif_req_i.wdata(5);
        HIBI_DMA_GPIO_DIR.GPIO_6 <= gif_req_i.wdata(6);
        HIBI_DMA_GPIO_DIR.GPIO_7 <= gif_req_i.wdata(7);
        HIBI_DMA_GPIO_DIR.GPIO_8 <= gif_req_i.wdata(8);
        HIBI_DMA_GPIO_DIR.GPIO_9 <= gif_req_i.wdata(9);
        HIBI_DMA_GPIO_DIR.GPIO_A <= gif_req_i.wdata(10);
        HIBI_DMA_GPIO_DIR.GPIO_B <= gif_req_i.wdata(11);
        HIBI_DMA_GPIO_DIR.GPIO_C <= gif_req_i.wdata(12);
        HIBI_DMA_GPIO_DIR.GPIO_D <= gif_req_i.wdata(13);
        HIBI_DMA_GPIO_DIR.GPIO_E <= gif_req_i.wdata(14);
        HIBI_DMA_GPIO_DIR.GPIO_F <= gif_req_i.wdata(15);
--pragma translate_off
        if(enable_msg_c) then
          write(wr, string'("Time: "));
          write(wr, now);
          write(wr, string'(" (") & module_name_c & string'(") HIBI_DMA_GPIO_DIR write access: "));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_0: ") &
          std_ulogic'image(gif_req_i.wdata(0)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_1: ") &
          std_ulogic'image(gif_req_i.wdata(1)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_2: ") &
          std_ulogic'image(gif_req_i.wdata(2)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_3: ") &
          std_ulogic'image(gif_req_i.wdata(3)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_4: ") &
          std_ulogic'image(gif_req_i.wdata(4)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_5: ") &
          std_ulogic'image(gif_req_i.wdata(5)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_6: ") &
          std_ulogic'image(gif_req_i.wdata(6)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_7: ") &
          std_ulogic'image(gif_req_i.wdata(7)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_8: ") &
          std_ulogic'image(gif_req_i.wdata(8)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_9: ") &
          std_ulogic'image(gif_req_i.wdata(9)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_A: ") &
          std_ulogic'image(gif_req_i.wdata(10)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_B: ") &
          std_ulogic'image(gif_req_i.wdata(11)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_C: ") &
          std_ulogic'image(gif_req_i.wdata(12)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_D: ") &
          std_ulogic'image(gif_req_i.wdata(13)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_E: ") &
          std_ulogic'image(gif_req_i.wdata(14)));
          writeline(output, wr);
          write(wr, string'("  -> GPIO_F: ") &
          std_ulogic'image(gif_req_i.wdata(15)));
          writeline(output, wr);
        end if;
--pragma translate_on
      end if;
    end if;
  end process HIBI_DMA_GPIO_DIR_rw;
  reg2logic_o.HIBI_DMA_GPIO_DIR.rw <= HIBI_DMA_GPIO_DIR;

  -------------------------------------------------------------------------------
  -- HIBI_DMA_GPIO_DIR access control decoding
  -------------------------------------------------------------------------------
  reg2logic_o.HIBI_DMA_GPIO_DIR.c.wr <= gif_req_i.wr when gif_req_i.addr = addr_offset_HIBI_DMA_GPIO_DIR_slv_c else '0';
  reg2logic_o.HIBI_DMA_GPIO_DIR.c.rd <= gif_req_i.rd when gif_req_i.addr = addr_offset_HIBI_DMA_GPIO_DIR_slv_c else '0';

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
          when addr_offset_HIBI_DMA_TRIGGER_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(0) <= '0';
            gif_rsp_o.rdata(1) <= '0';
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
            gif_rsp_o.rdata(1 downto 0) <= HIBI_DMA_TRIGGER_MASK0.mask;
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
            gif_rsp_o.rdata(1 downto 0) <= HIBI_DMA_TRIGGER_MASK1.mask;
          when addr_offset_HIBI_DMA_GPIO_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(0) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_0;
            gif_rsp_o.rdata(1) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_1;
            gif_rsp_o.rdata(2) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_2;
            gif_rsp_o.rdata(3) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_3;
            gif_rsp_o.rdata(4) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_4;
            gif_rsp_o.rdata(5) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_5;
            gif_rsp_o.rdata(6) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_6;
            gif_rsp_o.rdata(7) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_7;
            gif_rsp_o.rdata(8) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_8;
            gif_rsp_o.rdata(9) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_9;
            gif_rsp_o.rdata(10) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_A;
            gif_rsp_o.rdata(11) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_B;
            gif_rsp_o.rdata(12) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_C;
            gif_rsp_o.rdata(13) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_D;
            gif_rsp_o.rdata(14) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_E;
            gif_rsp_o.rdata(15) <= logic2reg_i.HIBI_DMA_GPIO.xr.GPIO_F;
          when addr_offset_HIBI_DMA_GPIO_DIR_slv_c =>
            gif_rsp_o.rdata <= (others=>'0');
            gif_rsp_o.rdata(0) <= HIBI_DMA_GPIO_DIR.GPIO_0;
            gif_rsp_o.rdata(1) <= HIBI_DMA_GPIO_DIR.GPIO_1;
            gif_rsp_o.rdata(2) <= HIBI_DMA_GPIO_DIR.GPIO_2;
            gif_rsp_o.rdata(3) <= HIBI_DMA_GPIO_DIR.GPIO_3;
            gif_rsp_o.rdata(4) <= HIBI_DMA_GPIO_DIR.GPIO_4;
            gif_rsp_o.rdata(5) <= HIBI_DMA_GPIO_DIR.GPIO_5;
            gif_rsp_o.rdata(6) <= HIBI_DMA_GPIO_DIR.GPIO_6;
            gif_rsp_o.rdata(7) <= HIBI_DMA_GPIO_DIR.GPIO_7;
            gif_rsp_o.rdata(8) <= HIBI_DMA_GPIO_DIR.GPIO_8;
            gif_rsp_o.rdata(9) <= HIBI_DMA_GPIO_DIR.GPIO_9;
            gif_rsp_o.rdata(10) <= HIBI_DMA_GPIO_DIR.GPIO_A;
            gif_rsp_o.rdata(11) <= HIBI_DMA_GPIO_DIR.GPIO_B;
            gif_rsp_o.rdata(12) <= HIBI_DMA_GPIO_DIR.GPIO_C;
            gif_rsp_o.rdata(13) <= HIBI_DMA_GPIO_DIR.GPIO_D;
            gif_rsp_o.rdata(14) <= HIBI_DMA_GPIO_DIR.GPIO_E;
            gif_rsp_o.rdata(15) <= HIBI_DMA_GPIO_DIR.GPIO_F;
          when others =>
            gif_rsp_o.rdata <= (others=>'0');
        end case;
      end if;
    end if;
  end process read;

end architecture rtl;
