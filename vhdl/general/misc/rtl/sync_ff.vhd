-------------------------------------------------------------------------------
-- Title      : sync_ff
-- Project    : TOF-Digitalis
-------------------------------------------------------------------------------
-- File       : sync_ff.vhd
-- Author     : s.boehmer@pmdtec.com
-- Company    : PMDTec
-- Created    : 2011-08-22
-- Last update: 2011-08-22
-- Platform   : Fedora Linux
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Synchronization flip-flop
-------------------------------------------------------------------------------
-- Copyright (c) 2011 PMDTec
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-08-22  1.0      SBo     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity sync_ff is
  generic (
    nr_stages_g : natural := 2
  );
  port (
    clk_i       : in  std_logic;
    reset_n_i   : in  std_logic;
    d_i         : in  std_logic;
    q_o         : out std_logic
  );
end entity sync_ff;

architecture rtl of sync_ff is

  signal pipe : std_logic_vector(nr_stages_g-1 downto 0);

begin
  -----------------------------------------------------------------------------
  -- flip-flop pipe
  -----------------------------------------------------------------------------
  sync0: process(clk_i, reset_n_i) is
  begin
    if(reset_n_i = '0') then
      pipe <= (others=>'0');
    elsif(rising_edge(clk_i)) then
      pipe <= pipe(pipe'left-1 downto 0) & d_i;
    end if;
  end process sync0;

  -- assign module output
  q_o <= pipe(pipe'left);

end architecture rtl;

