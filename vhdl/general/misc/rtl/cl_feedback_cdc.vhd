-------------------------------------------------------------------------------
-- Title      : cl_feedback_cdc
-- Project    : TOF-Digitalis
-------------------------------------------------------------------------------
-- File       : cl_feedback_cdc.vhd
-- Author     : s.boehmer@pmdtec.com
-- Company    : PMDTec
-- Created    : 2011-08-22
-- Last update: 2011-08-22
-- Platform   : Fedora Linux
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Closed-Loop MSP-CDC with feedback
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

entity cl_feedback_cdc is
  generic (
    data_width_g : natural := 1
  );
  port (
    -- clocks
    clka_i       : in  std_logic;
    clkb_i       : in  std_logic;
    -- resets
    reseta_n_i   : in  std_logic;
    resetb_n_i   : in  std_logic;
    -- sending (clka) domain
    adata_i      : in  std_logic_vector(data_width_g-1 downto 0);
    asend_i      : in  std_logic;
    aready_o     : out std_logic;
    -- receiving (clkb) domain
    bdata_o      : out std_logic_vector(data_width_g-1 downto 0);
    breceive_o   : out std_logic
  );
end entity cl_feedback_cdc;

architecture rtl of cl_feedback_cdc is

  type state_t is (idle, sttx);

  type reg_t is record
    state  : state_t;
    aready : std_logic;
    tx     : std_logic;
    adata  : std_logic_vector(data_width_g-1 downto 0);
    a_en   : std_logic;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    state  => idle,
    aready => '1',
    tx     => '0',
    adata  => (others=>'0'),
    a_en   => '0'
  );

  -- sending domain signal
  signal r, rin :reg_t;
  signal aack   : std_logic;

  -- receiving domain signal
  signal back   : std_logic;
  signal rx     : std_logic;

begin
  -----------------------------------------------------------------------------
  -- comb0 (sending clock domain)
  -----------------------------------------------------------------------------
  comb0: process(r, asend_i, aack) is
    variable v : reg_t;
  begin
    v := r;

    -- ready FSM
    case(v.state) is
      when idle   => if(asend_i = '1') then
                       v.state := sttx;
                     end if;
                     v.aready  := '1';

      when sttx   => if(aack = '1') then
                       v.state := idle;
                     end if;
                     v.aready  := '0';

      when others => v.state   := idle;
    end case;

    -- tx if fsm is ready and data to be send
    v.tx := r.aready and asend_i;

    -- sending clock domain output latch
    if(v.tx = '1') then
      v.adata := adata_i;
    end if;

    -- synchronization pulse
    v.a_en := v.tx xor v.a_en;

    -- drive module output
    aready_o <= r.aready;

    rin <= v;
  end process comb0;

  -----------------------------------------------------------------------------
  -- sync0 (sending clock domain)
  -----------------------------------------------------------------------------
  sync0: process(reseta_n_i, clka_i) is
  begin
    if(reseta_n_i = '0') then
      r <= dflt_reg_c;
    elsif(rising_edge(clka_i)) then
      r <= rin; 
    end if;
  end process sync0;

  -----------------------------------------------------------------------------
  -- acknowledge synchronizer (sending clock domain)
  -----------------------------------------------------------------------------
  synci0: entity general.sync_pulse_gen
    generic map (
      edge_g  => "either"
    )
    port map (
      clk_i     => clka_i,
      reset_n_i => reseta_n_i,
      d_i       => back,
      p_o       => aack,
      q_o       => open
    );

   ----------------------------------------------------------------------------
   -- data valid synchronizer (receiving clock domain)
   ----------------------------------------------------------------------------
   synci1: entity general.sync_pulse_gen
    generic map (
      edge_g  => "either"
    )
    port map (
      clk_i     => clkb_i,
      reset_n_i => resetb_n_i,
      d_i       => r.a_en,
      p_o       => rx,
      q_o       => back
    );
 
    ---------------------------------------------------------------------------
    -- output latch (receiving clock domain)
    ---------------------------------------------------------------------------
    sync1: process(clkb_i, resetb_n_i) is
    begin
      if(resetb_n_i = '0') then
        bdata_o      <= (others=>'0');
        breceive_o   <= '0';
      elsif(rising_edge(clkb_i)) then
        breceive_o   <= '0';
        if(rx = '1') then
          bdata_o    <= r.adata;
          breceive_o <= '1';
        end if;
      end if;
    end process sync1;

end architecture rtl;

