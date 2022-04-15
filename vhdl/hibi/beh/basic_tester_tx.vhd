-------------------------------------------------------------------------------
-- Title      : A block which sends data to HIBI ver 2 and 3
-- Project    : Nocbench & Funbase
-------------------------------------------------------------------------------
-- File       : basic_tester_tx.vhd
-- Author     : ege
-- Created    : 2010-03-24
-- Last update: 2012-02-06
-- Description: Reads ASCII file where each line describes transfer of 1 word.
--              Each transfers needs 4 hexadecimal parameters:
--               - delay (clock cycles) after previous tx
--               - dst address
--               - data value
--               - command
--
-------------------------------------------------------------------------------
-- Copyright (c) 2010
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- April 2010   1.0     ege     First version
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

library hibi;
use hibi.basic_tester_pkg.all;

entity basic_tester_tx is
  generic (
    conf_file_g  : string  := "";
    comm_width_g : integer := 5;
    data_width_g : integer := 0
  );
  port (
    clk            : in std_logic;
    rst_n          : in std_logic;
    done_out       : out std_logic;
    -- HIBI wrapper ports
    agent_av_out   : out std_logic;
    agent_data_out : out std_logic_vector (data_width_g-1 downto 0);
    agent_comm_out : out std_logic_vector (comm_width_g-1 downto 0);
    agent_we_out   : out std_logic;
    agent_full_in  : in  std_logic;
    agent_one_p_in : in  std_logic
  );
end basic_tester_tx;

architecture rtl of basic_tester_tx is

  type control_states is (read_conf, wait_sending, wr_addr, wr_data, finish);

  signal curr_state_r : control_states := read_conf;
  signal delay_r      : integer;

begin

  main : process (clk, rst_n)
    file conf_data_file : text open read_mode is conf_file_g;

    variable delay_v    : integer;
    variable dst_ag_v   : integer;
    variable data_val_v : integer;
    variable cmd_v      : integer;
  begin
    if rst_n = '0' then
      curr_state_r   <= read_conf;
      agent_av_out   <= '0';
      agent_data_out <= (others=>'0');
      agent_comm_out <= (others=>'0');
      agent_we_out   <= '0';
      done_out       <= '0';

      delay_r        <= 0;
      delay_v        := 0;
      dst_ag_v       := 0;
      data_val_v     := 0;
      cmd_v          := 0;

    elsif clk'event and clk = '1' then

      case curr_state_r is
        when read_conf =>
          if agent_full_in = '0' then
            -- read next transfer from file if FIFO has space and the whole file has not yet been read
            if endfile(conf_data_file) then
              curr_state_r <= finish;
              assert false report "End of the configuration file reached"
                severity note;
            else
              read_conf_file( delay        => delay_v,
                              dest_agent_n => dst_ag_v,
                              value        => data_val_v,
                              cmd          => cmd_v,
                              conf_dat     => conf_data_file );
              
              -- FSM causes few empty cycles, compensate by decrementing delay_v
              delay_v := delay_v-1;
              
              if cmd_v = -1 then
                cmd_v := 2; --use write as default
              end if;

              if delay_v < 1 then
                -- start sending directly
                if dst_ag_v = 0 then
                  curr_state_r <= wr_data; 
                else
                  curr_state_r <= wr_addr;
                end if;
              else
                curr_state_r   <= wait_sending;
              end if;    
            end if;

            agent_av_out   <= '0';
            agent_data_out <= (others=>'0');
            agent_comm_out <= (others=>'0');
            agent_we_out   <= '0';
            delay_r        <= delay_v;
          else
            curr_state_r <= read_conf;
          end if;
          
        when wait_sending =>
          delay_r    <= delay_r-1;
          if delay_r < 2 then
            if dst_ag_v = 0 then
              curr_state_r <= wr_data;
            else
              curr_state_r <= wr_addr;
            end if;
          else
            curr_state_r <= wait_sending;
          end if;
    
        when wr_addr =>
          if agent_full_in = '0' then
            -- write the address  if there is room in HIBI's tx FIFO
            agent_av_out   <= '1';
            agent_data_out <= std_logic_vector(to_signed(dst_ag_v, data_width_g));
            agent_comm_out <= std_logic_vector(to_signed(cmd_v, comm_width_g));
            agent_we_out   <= '1';
            curr_state_r   <= wr_data;
          else
            -- don't start yet, wait that there is space in FIFO
            agent_av_out   <= '0';
            agent_data_out <= (others=>'0');
            agent_comm_out <= (others=>'0');
            agent_we_out   <= '0';
            curr_state_r   <= wr_addr;
          end if;

        when wr_data =>
          if agent_full_in = '0' then
            -- write the requested data value if there is room in HIBI's tx FIFO
            agent_av_out   <= '0';
            agent_data_out <= std_logic_vector(to_signed(data_val_v, data_width_g));
            agent_comm_out <= std_logic_vector(to_signed(cmd_v, comm_width_g));
            agent_we_out   <= '1';
            curr_state_r   <= read_conf;           
          else
            -- keep the old values (=adst ddress) and stay in this state
            curr_state_r <= wr_data;
          end if;

        when finish =>
          -- notify that we're done.
          done_out       <= '1';
          agent_av_out   <= '0';
          agent_data_out <= (others=>'0');
          agent_comm_out <= (others=>'0');
          agent_we_out   <= '0';

        when others => null;
      end case;
    end if;
  end process main;
  
end architecture rtl;

