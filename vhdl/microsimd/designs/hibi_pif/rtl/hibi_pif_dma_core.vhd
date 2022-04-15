-------------------------------------------------------------------------------
-- Title      : hibi_pif_dma
-- Project    :
-------------------------------------------------------------------------------
-- File       : hibi_pif_dma_core.vhd
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
use microsimd.hibi_pif_dma_pkg.all;

entity hibi_pif_dma_core is
  generic (
    log2_burst_length_g : integer range 2 to 8 := 4
  );
  port (
    clk_i         : in  std_ulogic;
    reset_n_i     : in  std_ulogic;
    init_i        : in  std_ulogic;
    en_i          : in  std_ulogic;
    ctrl_i        : in  hibi_pif_dma_ctrl_arr_t;
    cfg_i         : in  hibi_pif_dma_cfg_arr_t;
    status_o      : out hibi_pif_dma_status_arr_t;
    mem_req_o     : out hibi_pif_dma_mem_req_t;
    mem_rsp_i     : in  hibi_pif_dma_mem_rsp_t;
    mem_wait_i    : in  std_ulogic;
    agent_txreq_o : out agent_txreq_t;
    agent_txrsp_i : in  agent_txrsp_t;
    agent_rxreq_o : out agent_rxreq_t;
    agent_rxrsp_i : in  agent_rxrsp_t
  );
end entity hibi_pif_dma_core;

architecture rtl of hibi_pif_dma_core is
  constant max_burst_length_c : integer := 2**log2_burst_length_g;

  type buffer_t is array(natural range 0 to max_burst_length_c-1) of std_ulogic_vector(hibi_pif_dma_mem_data_width_c-1 downto 0);

  type mem_req_t is record
    addr        : unsigned(hibi_pif_dma_mem_addr_width_c-1 downto 0);
    we          : std_ulogic;
    en          : std_ulogic;
  end record mem_req_t;
  constant dflt_mem_req_c : mem_req_t :=(
    addr        => (others=>'0'),
    we          => '0',
    en          => '0'
  );

  type channel_describtor_t is record
    pull_count      : unsigned(hibi_pif_dma_count_width_c-1 downto 0);
    push_count      : unsigned(hibi_pif_dma_count_width_c-1 downto 0);
    burst_count     : unsigned(log2_burst_length_g downto 0);
    buffer_index    : unsigned(log2_burst_length_g-1 downto 0);
    mem_req         : mem_req_t;
  end record channel_describtor_t;
  constant dflt_channel_describtor_c : channel_describtor_t :=(
    pull_count      => (others=>'0'),
    push_count      => (others=>'0'),
    burst_count     => (others=>'0'),
    buffer_index    => (others=>'0'),
    mem_req         => dflt_mem_req_c
  );

  type channel_t is record
    data_buffer     : buffer_t;
    describtor      : channel_describtor_t;
    active          : std_ulogic;
    status          : hibi_pif_dma_status_t;
  end record channel_t;
  constant dflt_channel_c : channel_t :=(
    data_buffer     => (others=>(others=>'0')),
    describtor      => dflt_channel_describtor_c,
    active          => '0',
    status          => dflt_hibi_pif_dma_status_c
  );

  type channel_arr_t is array(natural range 0 to hibi_pif_dma_channels_c-1) of channel_t;
  constant dflt_channel_arr_c : channel_arr_t := (others=>dflt_channel_c);

  type tx_state_t is (tx_idle, describtor_switch, wait_pull_mem, pull_mem, last_pull_mem, wait_push_hibi, push_hibi);
  type rx_state_t is (rx_idle, wait_pull_hibi, pull_hibi, wait_push_mem, push_mem, last_push_mem, rx_error);

  type rx_t is record
    state        : rx_state_t;
    describtor   : channel_describtor_t;
    hibi_rxreq   : agent_rxreq_t;
    curr_channel : std_ulogic_vector(log2ceil(hibi_pif_dma_channels_c)-1 downto 0);
    lock_mem     : std_ulogic;
  end record rx_t;
  constant dflt_rx_c : rx_t :=(
    state        => rx_idle,
    describtor   => dflt_channel_describtor_c,
    hibi_rxreq   => dflt_agent_rxreq_c,
    curr_channel => (others=>'0'),
    lock_mem     => '0'
  );

  type tx_t is record
    state      : tx_state_t;
    describtor : channel_describtor_t;
    hibi_txreq : agent_txreq_t;
    lock_mem   : std_ulogic;
    mem_ack    : std_ulogic;
  end record tx_t;
  constant dflt_tx_c : tx_t :=(
    state      => tx_idle,
    describtor    => dflt_channel_describtor_c,
    hibi_txreq => dflt_agent_txreq_c,
    lock_mem   => '0',
    mem_ack    => '0'
  );

  type reg_t is record
    tx       : tx_t;
    rx       : rx_t;
    channels : channel_arr_t;
    data     : std_ulogic_vector(hibi_pif_dma_mem_data_width_c-1 downto 0);
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    tx       => dflt_tx_c,
    rx       => dflt_rx_c,
    channels => dflt_channel_arr_c,
    data     => (others=>'0')
  );

  ------------------------------------------------------------------------------
  -- return all active tx channels
  ------------------------------------------------------------------------------
  function get_tx_channels(ch : channel_arr_t) return std_ulogic_vector is
    variable active : std_ulogic_vector(hibi_pif_dma_channels_c-1 downto 0);
  begin
    act: for i in 0 to hibi_pif_dma_channels_c-1 loop
      active(i) := ch(i).active and not ch(i).describtor.mem_req.we;
    end loop act;
    return active;
  end function get_tx_channels;

  ------------------------------------------------------------------------------
  -- return all active rx channels
  ------------------------------------------------------------------------------
  function get_rx_channels(ch : channel_arr_t) return std_ulogic_vector is
    variable active : std_ulogic_vector(hibi_pif_dma_channels_c-1 downto 0);
  begin
    act: for i in 0 to hibi_pif_dma_channels_c-1 loop
      active(i) := ch(i).active and ch(i).describtor.mem_req.we;
    end loop act;
    return active;
  end function get_rx_channels;

  ------------------------------------------------------------------------------
  -- return binary version of onehot input
  ------------------------------------------------------------------------------
  function onehot_to_bin(onehot : std_ulogic_vector) return integer is
  begin
    bin0: for i in onehot'range loop
      if(onehot(i) = '1') then
        return i;
      end if;
    end loop bin0;
    return 0;
  end function onehot_to_bin;

  ------------------------------------------------------------------------------
  -- return highest priority bit number that is set
  ------------------------------------------------------------------------------
  function lsb_set(vec : std_ulogic_vector) return std_ulogic_vector is
    variable result : std_ulogic_vector(log2ceil(vec'length)-1 downto 0);
  begin
    result := (others=>'0');
    lsb0: for i in vec'range loop
      if(vec(i) = '1') then
        result := std_ulogic_vector(to_unsigned(i, result'length));
        exit;
      end if;
    end loop lsb0;
    return result;
  end function lsb_set;

  signal tx_arbi0_grant : std_ulogic_vector(hibi_pif_dma_channels_c-1 downto 0);
  signal tx_arb_req     : std_ulogic_vector(hibi_pif_dma_channels_c-1 downto 0);
  signal tx_arb_ack     : std_ulogic;

  signal r, rin         : reg_t;

begin
  ------------------------------------------------------------------------------
  -- tx channel arbiter
  ------------------------------------------------------------------------------
  tx_arbi0: entity microsimd.round_robin_arb
    generic map (
      cnt_g =>  hibi_pif_dma_channels_c
    )
    port map (
      clk_i     => clk_i,
      reset_n_i => reset_n_i,
      en_i      => en_i,
      init_i    => init_i,
      req_i     => tx_arb_req,
      ack_i     => tx_arb_ack,
      grant_o   => tx_arbi0_grant
    );

  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, cfg_i, ctrl_i, mem_rsp_i, mem_wait_i, agent_txrsp_i, agent_rxrsp_i, tx_arbi0_grant) is
    variable v               : reg_t;
    variable v_tx_arb_req    : std_ulogic_vector(hibi_pif_dma_channels_c-1 downto 0);
    variable v_tx_arb_ack    : std_ulogic;
    variable tx_channel      : integer range 0 to hibi_pif_dma_channels_c-1;
    variable rx_channel      : integer range 0 to hibi_pif_dma_channels_c-1;
    variable next_rx_channel : integer range 0 to hibi_pif_dma_channels_c-1;
    variable mem_req         : mem_req_t;
    variable status          : hibi_pif_dma_status_arr_t;
  begin
    v := r;

    ----------------------------------------------------------------------------
    -- currently selected rx and tx channel
    ----------------------------------------------------------------------------
    tx_channel     := onehot_to_bin(tx_arbi0_grant);
    rx_channel     := to_integer(unsigned(r.rx.curr_channel));

    ----------------------------------------------------------------------------
    -- write to internal data buffer MEM --> BUF (tx channel)
    ----------------------------------------------------------------------------
    if(mem_wait_i = '0') then
      v.tx.mem_ack                   := r.tx.describtor.mem_req.en;
      if(r.tx.mem_ack = '1') then
        v.channels(tx_channel).data_buffer(to_integer(r.tx.describtor.buffer_index))
                                     := mem_rsp_i.dat;
        v.tx.describtor.buffer_index := r.tx.describtor.buffer_index + 1;
        v.tx.describtor.pull_count   := r.tx.describtor.pull_count - 1;
        v.tx.describtor.burst_count  := r.tx.describtor.burst_count - 1;
      end if;
    end if;

    ----------------------------------------------------------------------------
    -- write to internal data buffer HIBI --> BUF (rx channel)
    ----------------------------------------------------------------------------
    if(r.rx.hibi_rxreq.re = '1' and agent_rxrsp_i.av = '0') then
      v.channels(rx_channel).data_buffer(to_integer(r.rx.describtor.buffer_index))
                                     := agent_rxrsp_i.data;
      v.rx.describtor.buffer_index   := r.rx.describtor.buffer_index + 1;
      v.rx.describtor.pull_count     := r.rx.describtor.pull_count - 1;
      v.rx.describtor.burst_count    := r.rx.describtor.burst_count - 1;
    end if;

    ----------------------------------------------------------------------------
    -- read / ack from internal data buffer HIBI <-- BUF (tx channel)
    ----------------------------------------------------------------------------
    if(r.tx.hibi_txreq.we = '1' and r.tx.hibi_txreq.av = '0') then
      v.tx.describtor.buffer_index   := r.tx.describtor.buffer_index + 1;
      v.tx.describtor.push_count     := r.tx.describtor.push_count - 1;
      v.tx.describtor.burst_count    := r.tx.describtor.burst_count - 1;
    end if;

    ----------------------------------------------------------------------------
    -- read / ack from internal data buffer MEM <-- BUF (rx channel)
    ----------------------------------------------------------------------------
    if(mem_wait_i = '0') then
      if(r.rx.describtor.mem_req.en = '1') then
        v.rx.describtor.buffer_index := r.rx.describtor.buffer_index + 1;
        v.rx.describtor.push_count   := r.rx.describtor.push_count - 1;
        v.rx.describtor.burst_count  := r.rx.describtor.burst_count - 1;
      end if;
    end if;

    ----------------------------------------------------------------------------
    -- mark each channel being started as active and store direction
    ----------------------------------------------------------------------------
    act0: for i in 0 to hibi_pif_dma_channels_c-1 loop
      if(ctrl_i(i).start = '1' and unsigned(cfg_i(i).count) /= 0) then
        v.channels(i).active                   := '1';
        v.channels(i).status.busy              := '1';
        v.channels(i).describtor.pull_count    := unsigned(cfg_i(i).count);
        v.channels(i).describtor.push_count    := unsigned(cfg_i(i).count);
        v.channels(i).describtor.mem_req.addr  := unsigned(cfg_i(i).mem_addr);
        v.channels(i).describtor.mem_req.we    := not cfg_i(i).direction;

        v.channels(i).describtor.burst_count   := to_unsigned(max_burst_length_c,  v.channels(i).describtor.burst_count'length);
        if(unsigned(cfg_i(i).count) < max_burst_length_c) then
          v.channels(i).describtor.burst_count := unsigned(cfg_i(i).count(v.channels(i).describtor.burst_count'range));
        end if;
      end if;
    end loop act0;

    ----------------------------------------------------------------------------
    -- generate arbitration request
    ----------------------------------------------------------------------------
    v_tx_arb_ack := '0';
    v_tx_arb_req := get_tx_channels(r.channels);

    ----------------------------------------------------------------------------
    -- channel DMA tx-fsm
    ----------------------------------------------------------------------------
    case v.tx.state is
      when tx_idle         => if(unsigned(v_tx_arb_req) /= 0) then
                                v.tx.state                  := describtor_switch;
                              end if;

      when describtor_switch  => v.tx.describtor            := v.channels(tx_channel).describtor;

                              v.tx.describtor.burst_count   := to_unsigned(max_burst_length_c, v.tx.describtor.burst_count'length);
                              if(v.tx.describtor.pull_count < max_burst_length_c) then
                                v.tx.describtor.burst_count := v.tx.describtor.pull_count(v.tx.describtor.burst_count'range);
                              end if;

                              v.tx.state                    := pull_mem;
                              v.tx.describtor.mem_req.en    := '1';
                              v.tx.lock_mem                 := '1';

                              if(mem_wait_i = '1' or r.rx.lock_mem = '1') then
                                v.tx.state                  := wait_pull_mem;
                                v.tx.describtor.mem_req.en  := '0';
                                v.tx.lock_mem               := '0';
                              end if;

      when wait_pull_mem   => if(mem_wait_i = '0' and r.rx.lock_mem = '0') then
                                v.tx.state                  := pull_mem;
                                v.tx.describtor.mem_req.en  := '1';
                                v.tx.lock_mem               := '1';
                              end if;

      when pull_mem        => if(mem_wait_i = '0') then
                                if(cfg_i(tx_channel).const_addr = '0') then
                                  v.tx.describtor.mem_req.addr := r.tx.describtor.mem_req.addr + 4;
                                end if;

                                if(v.tx.describtor.burst_count = 1) then
                                  v.tx.state                   := last_pull_mem;
                                  v.tx.describtor.mem_req.en   := '0';
                                  v.tx.lock_mem                := '0';
                                end if;
                              end if;

      when last_pull_mem   => if(mem_wait_i = '0') then
                                v.tx.hibi_txreq.we             := '1';
                                v.tx.hibi_txreq.av             := '1';
                                v.tx.hibi_txreq.comm           := cfg_i(tx_channel).cmd;
                                v.tx.state                     := push_hibi;

                                v.tx.describtor.buffer_index   := (others=>'0');
                                v.tx.describtor.burst_count    := to_unsigned(max_burst_length_c, v.tx.describtor.burst_count'length);
                                if(v.tx.describtor.push_count < max_burst_length_c) then
                                  v.tx.describtor.burst_count  := v.tx.describtor.push_count(v.tx.describtor.burst_count'range);
                                end if;

                                if(agent_txrsp_i.full = '1') then
                                  v.tx.state                   := wait_push_hibi;
                                  v.tx.hibi_txreq.we           := '0';
                                end if;
                              end if;

      when wait_push_hibi  => if(agent_txrsp_i.full = '0') then
                                v.tx.state                     := push_hibi;
                                v.tx.hibi_txreq.we             := '1';
                              end if;

      when push_hibi       => v.tx.hibi_txreq.av               := '0';

                              if(agent_txrsp_i.full = '1' or (r.tx.hibi_txreq.we = '1' and agent_txrsp_i.almost_full = '1')) then
                                v.tx.hibi_txreq.we             := '0';
                              else
                                v.tx.hibi_txreq.we             := '1';
                              end if;

                              --------------------------------------------------
                              -- deassert active one cycle before last transfer
                              -- as it must be deasserted before the arbiter ack
                              --------------------------------------------------
                              if(v.tx.describtor.burst_count = 1 and v.tx.describtor.push_count = 1) then
                                v.channels(tx_channel).active        := '0';
                              end if;

                              if(v.tx.describtor.burst_count = 0) then
                                v.tx.describtor.buffer_index         := (others=>'0');
                                v.channels(tx_channel).describtor    := v.tx.describtor;
                                v.tx.state                           := describtor_switch;
                                v.tx.hibi_txreq.we                   := '0';
                                v_tx_arb_ack                         := '1';

                                if(v.tx.describtor.push_count = 0) then
                                  v.channels(tx_channel).status.busy := '0';
                                  v.channels(tx_channel).active      := '0';
                                  v.tx.state                         := tx_idle;
                                end if;
                              end if;

      when others          => null;
    end case;

    ----------------------------------------------------------------------------
    -- channel DMA rx-fsm
    ----------------------------------------------------------------------------
    next_rx_channel := to_integer(unsigned(agent_rxrsp_i.data(v.rx.curr_channel'range)));

    case v.rx.state is
      when rx_idle         => if(unsigned(get_rx_channels(r.channels)) /= 0) then
                                v.rx.curr_channel             := lsb_set(get_rx_channels(r.channels));
                                v.rx.describtor               := r.channels(to_integer(unsigned(v.rx.curr_channel))).describtor;

                                if(agent_rxrsp_i.empty = '1') then
                                  v.rx.state                  := wait_pull_hibi;
                                  v.rx.hibi_rxreq.re          := '0';
                                else
                                  v.rx.state                  := pull_hibi;
                                  v.rx.hibi_rxreq.re          := '1';
                                end if;
                              end if;

      when wait_pull_hibi  => if(agent_rxrsp_i.empty = '0') then
                                v.rx.state                    := pull_hibi;
                                v.rx.hibi_rxreq.re            := '1';
                              end if;

      when pull_hibi       => if(agent_rxrsp_i.empty = '1' or (r.rx.hibi_rxreq.re = '1' and agent_rxrsp_i.almost_empty = '1')) then
                                v.rx.hibi_rxreq.re            := '0';
                              else
                                v.rx.hibi_rxreq.re            := '1';
                              end if;

                              if(agent_rxrsp_i.av = '1') then
                                v.rx.curr_channel                   := agent_rxrsp_i.data(v.rx.curr_channel'range);

                                if(v.channels(next_rx_channel).describtor.mem_req.we = '0') then
                                  v.rx.state                        := rx_error;
                                end if;

                                if(v.rx.curr_channel /= r.rx.curr_channel) then
                                  v.channels(rx_channel).describtor := r.rx.describtor;
                                  v.rx.describtor                   := r.channels(next_rx_channel).describtor;
                                end if;
                              else
                                if(v.rx.describtor.burst_count = 0) then
                                  v.rx.state                     := push_mem;
                                  v.rx.hibi_rxreq                := dflt_agent_rxreq_c;
                                  v.rx.describtor.mem_req.en     := '1';
                                  v.rx.lock_mem                  := '1';

                                  if(mem_wait_i = '1' or v.tx.lock_mem = '1' or r.tx.lock_mem = '1') then
                                    v.rx.state                   := wait_push_mem;
                                    v.rx.describtor.mem_req.en   := '0';
                                    v.rx.lock_mem                := '0';
                                  end if;

                                  v.rx.describtor.buffer_index   := (others=>'0');
                                  v.rx.describtor.burst_count    := to_unsigned(max_burst_length_c, v.rx.describtor.burst_count'length);
                                  if(v.rx.describtor.push_count < max_burst_length_c) then
                                    v.rx.describtor.burst_count  := v.rx.describtor.push_count(v.rx.describtor.burst_count'range);
                                  end if;
                                end if;
                              end if;

      when wait_push_mem   => if(mem_wait_i = '0' and v.tx.lock_mem = '0' and r.tx.lock_mem = '0') then
                                v.rx.state                    := push_mem;
                                v.rx.describtor.mem_req.en    := '1';
                                v.rx.lock_mem                 := '1';
                              end if;

      when push_mem        => if(mem_wait_i = '0') then
                                if(cfg_i(rx_channel).const_addr = '0') then
                                  v.rx.describtor.mem_req.addr   := r.rx.describtor.mem_req.addr + 4;
                                end if;

                                if(v.rx.describtor.burst_count = 0) then
                                  v.rx.state                     := pull_hibi;
                                  v.rx.hibi_rxreq.re             := '1';
                                  v.rx.describtor.mem_req.en     := '0';
                                  v.rx.lock_mem                  := '0';

                                  v.rx.describtor.buffer_index   := (others=>'0');
                                  v.rx.describtor.burst_count    := to_unsigned(max_burst_length_c, v.rx.describtor.burst_count'length);
                                  if(v.rx.describtor.pull_count < max_burst_length_c) then
                                    v.rx.describtor.burst_count  := v.rx.describtor.pull_count(v.rx.describtor.burst_count'range);
                                  end if;

                                  if(agent_rxrsp_i.empty = '1') then
                                    v.rx.state                := wait_pull_hibi;
                                    v.rx.hibi_rxreq.re        := '0';
                                  end if;

                                  if(v.rx.describtor.push_count = 0) then
                                    v.rx.state                := rx_idle;
                                    v.rx.describtor.mem_req   := dflt_mem_req_c;

                                    v.channels(rx_channel).status.busy := '0';
                                    v.channels(rx_channel).active      := '0';
                                  end if;
                                end if;
                              end if;

      when rx_error        => --TODO: disable all rx channels and return to idle
                              --v.rx.state                             := rx_idle;
                              v.rx.hibi_rxreq.re                       := '0';
                              v.channels(rx_channel).status.busy       := '0';
                              v.channels(rx_channel).active            := '0';

      when others          => null;
    end case;

    ----------------------------------------------------------------------------
    -- mem rx data multiplexing
    ----------------------------------------------------------------------------
    v.data                 := v.channels(rx_channel).data_buffer(to_integer(v.rx.describtor.buffer_index));

    ----------------------------------------------------------------------------
    -- hibi tx data multiplexing
    ----------------------------------------------------------------------------
    v.tx.hibi_txreq.data   := v.channels(tx_channel).data_buffer(to_integer(v.tx.describtor.buffer_index));
    if(v.tx.hibi_txreq.av = '1') then
      v.tx.hibi_txreq.data := std_ulogic_vector(resize(unsigned(cfg_i(tx_channel).hibi_addr), v.tx.hibi_txreq.data'length));
    end if;

    ----------------------------------------------------------------------------
    -- memory request mux
    ----------------------------------------------------------------------------
    if(r.tx.lock_mem = '1') then
      mem_req := r.tx.describtor.mem_req;
    else
      mem_req := r.rx.describtor.mem_req;
    end if;

    ----------------------------------------------------------------------------
    -- channel status assignment
    ----------------------------------------------------------------------------
    status0: for i in 0 to hibi_pif_dma_channels_c-1 loop
      status(i) := r.channels(i).status;
    end loop status0;

    ----------------------------------------------------------------------------
    -- drive tx arbiter
    ----------------------------------------------------------------------------
    tx_arb_req     <= v_tx_arb_req;
    tx_arb_ack     <= v_tx_arb_ack;

    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    status_o       <= status;

    agent_txreq_o  <= r.tx.hibi_txreq;
    agent_rxreq_o  <= r.rx.hibi_rxreq;

    mem_req_o      <= (adr =>std_ulogic_vector(mem_req.addr), we => mem_req.we, ena => mem_req.en, dat => r.data);

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

