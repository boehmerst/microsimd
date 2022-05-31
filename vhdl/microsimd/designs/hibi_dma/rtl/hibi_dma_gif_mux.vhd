-------------------------------------------------------------------------------
-- Title      : hibi_dma_gif_mux
-- Project    :
-------------------------------------------------------------------------------
-- File       : hibi_dma_gif_mux.vhd
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

library work;
use work.hibi_dma_regif_types_pkg.all;

entity hibi_dma_gif_mux is
  port (
    clk_i         : in  std_ulogic;
    reset_n_i     : in  std_ulogic;
    en_i          : in  std_ulogic;
    init_i        : in  std_ulogic;
    m0_gif_req_i  : in  hibi_dma_gif_req_t;
    m0_gif_rsp_o  : out hibi_dma_gif_rsp_t;
    m1_gif_req_i  : in  hibi_dma_gif_req_t;
    m1_gif_rsp_o  : out hibi_dma_gif_rsp_t;
    mux_gif_req_o : out hibi_dma_gif_req_t;
    mux_gif_rsp_i : in  hibi_dma_gif_rsp_t
  );
end entity hibi_dma_gif_mux;

architecture rtl of hibi_dma_gif_mux is

  type reg_t is record
    state   : std_ulogic;
    mux_sel : std_ulogic;
    m1_req  : hibi_dma_gif_req_t;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    state   => '0',
    mux_sel => '0',
    m1_req  => dflt_hibi_dma_gif_req_c
  );

  signal r, rin : reg_t;

begin
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, m0_gif_req_i, m1_gif_req_i) is
    variable v         : reg_t;
    variable m0_req_en : std_ulogic;
    variable m1_req_en : std_ulogic;
  begin
    v := r;

    m0_req_en := m0_gif_req_i.rd or m0_gif_req_i.wr;
    m1_req_en := m1_gif_req_i.rd or m1_gif_req_i.wr;

    -- NOTE: conditionally register m1 request, we do not reset the register
    --       because the output mux defaults to m0
    if m1_req_en = '1' then
      v.m1_req := m1_gif_req_i;
    end if;

    ----------------------------------------------------------------------------
    -- this is a simplified mux that strictely assumes the slave to respond
    -- in the following clock cycle
    -- master zero is served first in case of competing requests
    -- master one request gets registered 
    ----------------------------------------------------------------------------
    case v.state is
      when '0'    => v.mux_sel   := '0';
                     v.state     := '0';

                     if(m0_req_en = '0' and m1_req_en = '1') then
                       v.mux_sel := '1';
                     end if;

                     if(m0_req_en = '1' and m1_req_en = '1') then
                       v.state   := '1';
                     end if;

      when '1'    => v.mux_sel   := '1';
                     v.state     := '0';

      when others => null;
    end case;

    rin <= v;
  end process comb0;

  mux_gif_req_o      <= m0_gif_req_i when rin.mux_sel = '0' else rin.m1_req;

  m0_gif_rsp_o.rdata <= mux_gif_rsp_i.rdata;
  m1_gif_rsp_o.rdata <= mux_gif_rsp_i.rdata;

  m0_gif_rsp_o.ack   <= mux_gif_rsp_i.ack when r.mux_sel = '0' else '0';
  m1_gif_rsp_o.ack   <= mux_gif_rsp_i.ack when r.mux_sel = '1' else '0';

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
