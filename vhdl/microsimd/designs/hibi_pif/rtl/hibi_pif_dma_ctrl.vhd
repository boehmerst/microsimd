-------------------------------------------------------------------------------
-- Title      : hibi_pif_dma
-- Project    :
-------------------------------------------------------------------------------
-- File       : hibi_pif_dma_ctrl.vhd
-- Author     : boehmers
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

library general;
use general.general_function_pkg.all;

library microsimd;
use microsimd.hibi_link_pkg.all;
use microsimd.hibi_pif_dma_regif_types_pkg.all;

entity hibi_pif_dma_ctrl is
  port (
    clk_i              : in  std_ulogic;
    reset_n_i          : in  std_ulogic;
    init_i             : in  std_ulogic;
    en_i               : in  std_ulogic;
    gif_req_o          : out hibi_pif_dma_gif_req_t;
    gif_rsp_i          : in  hibi_pif_dma_gif_rsp_t;
    agent_msg_txreq_o  : out agent_txreq_t;
    agent_msg_txrsp_i  : in  agent_txrsp_t;
    agent_msg_rxreq_o  : out agent_rxreq_t;
    agent_msg_rxrsp_i  : in  agent_rxrsp_t
  );
end entity hibi_pif_dma_ctrl;

architecture rtl of hibi_pif_dma_ctrl is

  type state_t is (idle, delay, wr_data, rd_src, rd_addr, rd_data);

  type reg_t is record
    state      : state_t;
    gif_req    : hibi_pif_dma_gif_req_t;
    hibi_rxreq : agent_rxreq_t;
    hibi_txreq : agent_txreq_t;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    state      => idle,
    gif_req    => dflt_hibi_pif_dma_gif_req_c,
    hibi_rxreq => dflt_agent_rxreq_c,
    hibi_txreq => dflt_agent_txreq_c
  );

  signal r, rin : reg_t;

begin
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, gif_rsp_i, agent_msg_txrsp_i, agent_msg_rxrsp_i) is
    variable v: reg_t;
  begin
    v := r;

    ----------------------------------------------------------------------------
    -- control FSM
    ----------------------------------------------------------------------------
    v.hibi_txreq.we     := '0';
    v.hibi_rxreq.re     := '0';
    v.gif_req.wr        := '0';
    v.gif_req.rd        := '0';

    case(r.state) is
      when idle    => if(agent_msg_rxrsp_i.empty = '0') then
                        v.hibi_rxreq.re     := '1';
                        v.state             := delay;
                      end if;

      when delay   => if(agent_msg_rxrsp_i.empty = '1' or (r.hibi_rxreq.re = '1' and agent_msg_rxrsp_i.almost_empty = '1')) then
                        v.hibi_rxreq.re     := '0';
                      else
                        v.hibi_rxreq.re     := '1';
                        if(agent_msg_rxrsp_i.av = '1') then
                          v.gif_req.addr    := agent_msg_rxrsp_i.data(v.gif_req.addr'range);
                          if(agent_msg_rxrsp_i.comm = hibi_wr_prio_data_c) then
                            v.state         := wr_data;
                          elsif(agent_msg_rxrsp_i.comm = hibi_rd_prio_data_c) then
                            v.state         := rd_src;
                            v.gif_req.rd    := '1';
                          end if;
                        end if;
                      end if;

      when wr_data => v.state               := idle;
                      v.gif_req.wdata       := agent_msg_rxrsp_i.data(v.gif_req.wdata'range);
                      v.gif_req.wr          := '1';
                      v.hibi_rxreq.re       := '0';

      when rd_src  => v.hibi_txreq.data     := agent_msg_rxrsp_i.data;
                      v.state               := rd_data;

                      -- NOTE: we awnser with hibi_wr_data_c on prio read requests
                      if(agent_msg_txrsp_i.full = '0') then
                        v.hibi_txreq.we     := '1';
                        v.hibi_txreq.comm   := hibi_wr_data_c;
                        v.hibi_txreq.av     := '1';
                      end if;

      when rd_data => v.hibi_txreq.av       := '0';
                      if(agent_msg_txrsp_i.full = '1' or (r.hibi_txreq.we = '1' and agent_msg_txrsp_i.almost_full = '1')) then
                        v.hibi_txreq.we     := '0';
                      else
                        v.hibi_txreq.we     := '1';
                        v.hibi_txreq.data   := std_ulogic_vector(resize(unsigned(gif_rsp_i.rdata), v.hibi_txreq.data'length));
                        v.state             := idle;
                      end if;

      when others  => null;
    end case;

    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    agent_msg_txreq_o <= r.hibi_txreq;
    agent_msg_rxreq_o <= r.hibi_rxreq;
    gif_req_o         <= r.gif_req; 

    rin <= v;
  end process comb0;

  ------------------------------------------------------------------------------
  -- sync0
  ------------------------------------------------------------------------------
  sync0: process(clk_i, reset_n_i) is
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

