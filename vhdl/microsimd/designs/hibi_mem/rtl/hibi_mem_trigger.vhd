-------------------------------------------------------------------------------
-- Title      : hibi_mem
-- Project    :
-------------------------------------------------------------------------------
-- File       : hibi_mem_trigger.vhd
-- Author     : deboehse
-- Company    : private
-- Created    : 
-- Last update: 
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: automated generated do not edit manually
-------------------------------------------------------------------------------
-- Copyright (c) 2013 Stephan Böhmer
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
--             1.0      SBo     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hibi_mem_trigger is
  generic (
    hibi_mem_channels_g : natural
  );
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;
    init_i    : in  std_ulogic;
    en_i      : in  std_ulogic;
    start_i   : in  std_ulogic;
    busy_i    : in  std_ulogic;
    trigger_i : in  std_ulogic_vector(hibi_mem_channels_g-1 downto 0);
    mask_i    : in  std_ulogic_vector(hibi_mem_channels_g-1 downto 0);
    trigger_o : out std_ulogic;
    start_o   : out std_ulogic
  );
end entity hibi_mem_trigger;

architecture rtl of hibi_mem_trigger is

  type state_t is (idle, started, triggered, running);

  type reg_t is record
    state   : state_t;
    start   : std_ulogic;
    events  : std_ulogic_vector(hibi_mem_channels_g-1 downto 0);
    trigger : std_ulogic;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    state   => idle,
    start   => '0',
    events  => (others=>'0'),
    trigger => '0'
  );

  signal r, rin : reg_t;

begin
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, start_i, trigger_i, mask_i, busy_i) is
    variable v     : reg_t;
    variable match : std_ulogic;
  begin
    v := r;

    v.start   := '0';
    v.trigger := '0';

    ----------------------------------------------------------------------------
    -- conditionally latch event
    ----------------------------------------------------------------------------
    set0: for i in trigger_i'range loop
      if(trigger_i(i) = '1') then
        v.events(i) := mask_i(i);
      end if;
    end loop set0;

    ----------------------------------------------------------------------------
    -- signal matching event
    ----------------------------------------------------------------------------
    match   := '0';
    if(v.events = mask_i) then
      match := '1';
    end if;

    ----------------------------------------------------------------------------
    -- control FSM
    ----------------------------------------------------------------------------
    fsm0: case r.state is
      when idle      => if(start_i = '1') then
                          if(match = '1') then
                            v.state  := triggered;
                            v.start  := '1';
                          else
                            v.state  := started;
                          end if;
                        end if;

      when started   => if(match = '1') then
                          v.state   := triggered;
                          v.start   := '1';
                        end if;

      when triggered => if(busy_i = '1') then
                          v.state := running;
                        end if;

      when running   => if(busy_i = '0') then
                          v.state   := idle;
                          v.trigger := '1';
                          v.events  := (others=>'0');
                        end if;

      when others    => null;
    end case fsm0;

    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    trigger_o <= r.trigger;
    start_o   <= r.start;

    rin <= v;
  end process comb0;

  ------------------------------------------------------------------------------
  -- sync0
  ------------------------------------------------------------------------------
  sync0: process(reset_n_i, clk_i) is
  begin
    if(reset_n_i = '0') then
      r <= dflt_reg_c;
    elsif(rising_edge(clk_i)) then
      if(en_i = '1') then
        if(init_i = '1') then
          r <= dflt_reg_c;
        else
          r <= rin;
        end if;
      end if;
    end if;
  end process sync0;

end architecture rtl;

