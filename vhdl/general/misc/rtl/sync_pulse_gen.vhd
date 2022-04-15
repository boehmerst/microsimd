-------------------------------------------------------------------------------
-- Title      : sync_pulse_gen
-- Project    : TOF-Digitalis
-------------------------------------------------------------------------------
-- File       : sync_pulse_gen.vhd
-- Author     : s.boehmer@pmdtec.com
-- Company    : PMDTec
-- Created    : 2011-08-22
-- Last update: 2011-08-22
-- Platform   : Fedora Linux
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Synchronized Pulse Generator
-------------------------------------------------------------------------------
-- Copyright (c) 2011 PMDTec
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-08-22  1.0      SBo     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library general;

entity sync_pulse_gen is
  generic (
    edge_g  : in string := "rising"
  );
  port (
    clk_i       : in  std_logic;
    reset_n_i   : in  std_logic;
    d_i         : in  std_logic;
    p_o         : out std_logic;
    q_o         : out std_logic
  );
end entity sync_pulse_gen;

architecture rtl of sync_pulse_gen is

  signal synci0_q : std_logic;
  signal edgei0_p : std_logic;
  signal edgei0_q : std_logic;

begin

  -- synchronizer flip-flop
  synci0: entity general.sync_ff
    generic map (
      nr_stages_g => 2
    )
    port map (
      clk_i     => clk_i,
      reset_n_i => reset_n_i,
      d_i       => d_i,
      q_o       => synci0_q
    );

  -- edge detector
  edgei0: entity general.edgedetect
    generic map (
      edge_g  => edge_g
    )
    port map (
      clk_i     => clk_i,
      reset_n_i => reset_n_i,
      d_i       => synci0_q,
      p_o       => edgei0_p,
      q_o       => edgei0_q
    );

   -- drive module output
   p_o <= edgei0_p;
   q_o <= edgei0_q;

end architecture rtl;


