-------------------------------------------------------------------------------
-- Title      : edgedetect
-- Project    : TOF-Digitalis
-------------------------------------------------------------------------------
-- File       : edgedetect.vhd
-- Author     : s.boehmer@pmdtec.com
-- Company    : PMDTec
-- Created    : 2011-08-22
-- Last update: 2011-08-22
-- Platform   : Fedora Linux
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Generic Edge Detector
-------------------------------------------------------------------------------
-- Copyright (c) 2011 PMDTec
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-08-22  1.0      SBo     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity edgedetect is
  generic (
    edge_g    : in string := "rising"
  );
  port (
    clk_i     : in  std_logic;
    reset_n_i : in  std_logic;
    d_i       : in  std_logic;
    p_o       : out std_logic;
    q_o       : out std_logic
  );
end entity edgedetect;

architecture rtl of edgedetect is

signal ff : std_logic;

begin
-------------------------------------------------------------------------------
-- either edge
-------------------------------------------------------------------------------
ee: if edge_g = "either" generate
  sync: process(clk_i, reset_n_i) is
  begin
    if(reset_n_i = '0') then
      p_o <= '0';
      ff  <= '0';
    elsif(rising_edge(clk_i)) then
      ff  <= d_i;
      p_o <= ff xor d_i;
    end if;
  end process sync;
end generate ee;

-------------------------------------------------------------------------------
-- rising edge
-------------------------------------------------------------------------------
re: if edge_g = "rising" generate
  sync: process(clk_i, reset_n_i) is
  begin
    if(reset_n_i = '0') then
      p_o <= '0';
      ff  <= '0';
    elsif(rising_edge(clk_i)) then
      ff  <= d_i;
      p_o <= not ff and d_i;
    end if;
  end process sync;
end generate re;

-------------------------------------------------------------------------------
-- falling edge
-------------------------------------------------------------------------------
fe: if edge_g = "falling" generate
  sync: process(clk_i, reset_n_i) is
  begin
    if(reset_n_i = '0') then
      p_o <= '0';
      ff  <= '0';
    elsif(rising_edge(clk_i)) then
      ff  <= d_i;
      p_o <= ff and not d_i;
    end if;
  end process sync;
end generate fe;

q_o <= ff;

end architecture rtl;

