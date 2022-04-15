library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hibi;
library general;

library microsimd;
use microsimd.hibi_pif_types_pkg.all;
use microsimd.hibi_pif_dma_pkg.all;

entity hibi_pif_rx is
  port (
    clk_i          : in  std_ulogic;
    reset_n_i      : in  std_ulogic;
    en_i           : in  std_ulogic;
    pclk_reset_n_i : in  std_ulogic;
    pif_i          : in  hibi_pif_t;
    rxfifo_req_i   : in  hibi_pif_rxfifo_req_t;
    rxfifo_rsp_o   : out hibi_pif_rxfifo_rsp_t
  );
end entity hibi_pif_rx;

architecture rtl of hibi_pif_rx is

  type reg_t is record
    rx_reg : std_ulogic_vector(pif_data_width_c-1 downto 0);
    cnt    : unsigned(1 downto 0);
    hsync  : std_ulogic;
    vsync  : std_ulogic;
    data   : std_ulogic_vector(pif_data_width_c-1 downto 0);
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    rx_reg => (others=>'0'),
    cnt    => (others=>'0'),
    hsync  => '0',
    vsync  => '0',
    data   => (others=>'0')
  );
    
  signal r, rin       : reg_t;

  signal init         : std_ulogic;
  signal en           : std_ulogic;
  signal eni0_q       : std_ulogic;

  signal fifo_wr      : std_ulogic;
  signal fifo_wr_data : std_ulogic_vector(dflt_hibi_pif_rxfifo_rsp_c.data'range);
    
begin
  ------------------------------------------------------------------------------
  -- synchronizer for the input streams
  ------------------------------------------------------------------------------    
  eni0: entity general.sync_ff
    port map (
      clk_i     => pif_i.pclk,
      reset_n_i => pclk_reset_n_i,
      d_i       => en_i,
      q_o       => eni0_q
    );
  
  ------------------------------------------------------------------------------
  -- delay FF for init generation
  ------------------------------------------------------------------------------
  dff: process(pclk_reset_n_i, pif_i.pclk) is
  begin
    if(pclk_reset_n_i = '0') then
      en <= '0';
    elsif(rising_edge(pif_i.pclk)) then
      en <= eni0_q;
    end if;
  end process dff;
     
  init <= '1' when en = '1' and eni0_q = '0' else '0';

  ------------------------------------------------------------------------------
  -- input fifos
  ------------------------------------------------------------------------------    
  fifoi0: entity hibi.cdc_fifo
    generic map (
      read_ahead_g  => 0,
      sync_clocks_g => 0,
      depth_log2_g  => 4,
      dataw_g       => dflt_hibi_pif_rxfifo_rsp_c.data'length
    )
    port map (
      --TODO: only one reset domain -> check CDC FIFO!
      rst_n                          => reset_n_i,
      rd_clk                         => clk_i,
      rd_en_in                       => rxfifo_req_i.rd,
      rd_empty_out                   => rxfifo_rsp_o.empty,
      rd_one_d_out                   => rxfifo_rsp_o.almost_empty,
      std_ulogic_vector(rd_data_out) => rxfifo_rsp_o.data,
      wr_clk                         => pif_i.pclk,
      wr_en_in                       => fifo_wr,
      wr_full_out                    => open,
      wr_one_p_out                   => open,
      wr_data_in                     => std_logic_vector(fifo_wr_data)
    );
    
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, pif_i.hsync, pif_i.vsync, pif_i.data) is
    variable v       : reg_t;
    variable gpif_wr : std_ulogic;
  begin
    v := r;
    
    ----------------------------------------------------------------------------
    -- register input data
    ----------------------------------------------------------------------------
    v.hsync := pif_i.hsync;
    v.vsync := pif_i.vsync;
    v.data  := pif_i.data;
        
    gpif_wr := r.hsync and r.vsync;
        
    if(gpif_wr = '1') then
      v.cnt := r.cnt + 1;
    end if;
    
    v.rx_reg     := r.data;       
     
    fifo_wr      <= r.cnt(0) and gpif_wr;
    fifo_wr_data <= r.data & r.rx_reg;
        
    rin <= v; 
  end process comb0;    

  ------------------------------------------------------------------------------
  -- sync0
  ------------------------------------------------------------------------------
  sync0: process(pclk_reset_n_i, pif_i.pclk) is
  begin
    if(pclk_reset_n_i = '0') then
      r <= dflt_reg_c;
    elsif(rising_edge(pif_i.pclk)) then
      if(en = '1') then
        if(init = '1') then
          r <= dflt_reg_c;
        else
          r <= rin;
        end if;
      end if;
    end if;
  end process sync0;    
  
end architecture rtl;

