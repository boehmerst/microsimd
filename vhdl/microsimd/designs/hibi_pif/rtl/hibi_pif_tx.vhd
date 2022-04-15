library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library hibi;

library microsimd;
use microsimd.hibi_pif_types_pkg.all;
use microsimd.hibi_pif_dma_pkg.all;

entity hibi_pif_tx is
  port (
    clk_i        : in  std_ulogic;
    reset_n_i    : in  std_ulogic;
    en_i         : in  std_ulogic;
    init_i       : in  std_ulogic;
    cfg_i        : in  hibi_pif_cfg_t;
    ctrl_i       : in  hibi_pif_ctrl_t;
    status_o     : out hibi_pif_status_t;
    pif_o        : out hibi_pif_t;
    txfifo_req_i : in  hibi_pif_txfifo_req_t;
    txfifo_rsp_o : out hibi_pif_txfifo_rsp_t
  ); 
end entity hibi_pif_tx;

architecture rtl of hibi_pif_tx is

  type state_t is (idle, wait_le, xmit, lp);
  
  type cnt_t is record
    hsize  : unsigned(dflt_hibi_pif_cfg_c.hsize'range);
    vsize  : unsigned(dflt_hibi_pif_cfg_c.vsize'range);
    divide : unsigned(0 downto 0);
  end record cnt_t;
   
  type reg_t is record
    state  : state_t;
    fe     : std_ulogic;
    le     : std_ulogic;
    cnt    : cnt_t;
    pif    : hibi_pif_t;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    state  => idle,
    fe     => '0',
    le     => '0',
    cnt    => (others=>(others=>'0')),
    pif    => dflt_hibi_pif_c
  );
  
  signal fifo_rd_req     : std_ulogic;
  
  signal fifoi0_rd_empty : std_logic;
  signal fifoi0_rd_one_d : std_logic;
  signal fifoi0_rd_data  : std_logic_vector(dflt_hibi_pif_rxfifo_rsp_c.data'range);
  
  signal r, rin : reg_t;

begin
  ------------------------------------------------------------------------------
  -- output fifo
  ------------------------------------------------------------------------------
  fifoi0: entity hibi.cdc_fifo
    generic map (
      read_ahead_g  => 0,
      sync_clocks_g => 1,
      depth_log2_g  => 4,
      dataw_g       => dflt_hibi_pif_rxfifo_rsp_c.data'length
    )
    port map (
      rst_n        => reset_n_i,
      rd_clk       => clk_i,
      rd_en_in     => fifo_rd_req,
      rd_empty_out => fifoi0_rd_empty,
      rd_one_d_out => fifoi0_rd_one_d,
      rd_data_out  => fifoi0_rd_data,
      wr_clk       => clk_i,
      wr_en_in     => txfifo_req_i.wr,
      wr_full_out  => txfifo_rsp_o.full,
      wr_one_p_out => txfifo_rsp_o.almost_full,
      wr_data_in   => std_logic_vector(txfifo_req_i.data)
    );

  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, cfg_i, ctrl_i, fifoi0_rd_data) is
    variable v       : reg_t;
    variable fifo_rd : std_ulogic;
  begin
    v := r;
    
    if(ctrl_i.le = '1') then
      v.le := '1';
    end if;
    
    if(ctrl_i.fe = '1') then
      v.fe := '1';
    end if;
    
    v.pif.pclk := not r.pif.pclk;
    
    -- TODO: use edge detect if other dividors are required
    fifo_rd    := '0';
    
    if(v.pif.pclk = '0') then
      case r.state is
        when idle    => if(r.fe = '1' and r.le = '1') then
                          v.fe           := '0';
                          v.le           := '0';                                     
                          if(unsigned(cfg_i.hsize) = 0 or unsigned(cfg_i.vsize) = 0) then
                            v.state      := idle;
                          else
                            v.state      := xmit;
                            v.pif.hsync  := '1';
                            v.pif.vsync  := '1';
                            v.cnt.divide := r.cnt.divide + 1;
                            v.cnt.hsize  := unsigned(cfg_i.hsize) - 1;
                            v.cnt.vsize  := unsigned(cfg_i.vsize) - 1;                          
                          end if;                      
                        elsif(r.fe = '1') then
                          v.fe           := '0';
                          v.state        := wait_le;
                          v.pif.vsync    := '1';
                        end if;
                      
        when wait_le => if(r.le = '1') then 
                          v.le           := '0';
                          if(unsigned(cfg_i.hsize) = 0 or unsigned(cfg_i.vsize) = 0) then
                            v.state      := idle;
                          else
                            v.state      := xmit;
                            v.pif.hsync  := '1';
                            v.cnt.hsize  := unsigned(cfg_i.hsize) - 1;
                            v.cnt.vsize  := unsigned(cfg_i.vsize) - 1;                          
                          end if;
                        end if;
      
        when xmit    => if(r.cnt.hsize = 0) then
                          v.pif.hsync    := '0';
                          v.state        := lp;
                          v.cnt.divide   := (others=>'0');
                          if(r.cnt.vsize = 0) then
                            v.state      := idle;
                            v.pif.vsync  := '0';
                          end if;
                        else
                          v.cnt.hsize    := r.cnt.hsize - 1;
                          v.cnt.divide   := r.cnt.divide + 1;
                        end if;
      
        when lp      => if(r.le = '1') then
                          v.le           := '0';
                          v.pif.hsync    := '1';
                          v.state        := xmit;
                          v.cnt.divide   := r.cnt.divide + 1;
                          v.cnt.hsize    := unsigned(cfg_i.hsize) - 1;
                        end if;
      
        when others  => null;
      end case;
      
      fifo_rd      := v.pif.vsync and v.pif.hsync and v.cnt.divide(0);
    end if;
    
    if(v.cnt.divide(0) = '0') then
      v.pif.data := std_ulogic_vector(fifoi0_rd_data(15 downto  0));
    else
      v.pif.data := std_ulogic_vector(fifoi0_rd_data(31 downto 16));
    end if;
    
    ----------------------------------------------------------------------------
    -- drive module output / FIFO
    ----------------------------------------------------------------------------
    fifo_rd_req <= fifo_rd;
    
    status_o    <= ( vsync => r.pif.vsync, hsync => r.pif.hsync, 
                     busy => r.pif.vsync or r.pif.hsync );
                  
    pif_o       <= r.pif;
    
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

