library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library microsimd;
use microsimd.core_pkg.all;
use microsimd.hibi_dma_regif_types_pkg.all;
use microsimd.hibi_dma_regfile_pkg.all;
use microsimd.hibi_dma_pkg.all;

entity hibi_dma_fsl is
  port (
    clk_i         : in  std_ulogic;
    reset_n_i     : in  std_ulogic;
    en_i          : in  std_ulogic;
    init_i        : in  std_ulogic;
    sel_i         : in  std_ulogic;
    fsl_req_i     : in  fsl_req_t;
    fsl_rsp_o     : out fsl_rsp_t;
    gif_req_o     : out hibi_dma_gif_req_t;
    gif_rsp_i     : in  hibi_dma_gif_rsp_t;
    dma_status_i  : in  hibi_dma_status_arr_t
  );
end entity hibi_dma_fsl;

architecture rtl of hibi_dma_fsl is

  type reg_t is record
    state     : std_ulogic;
    gif_req   : hibi_dma_gif_req_t;
    fsl_rsp   : fsl_rsp_t;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    state     => '0',
    gif_req   => dflt_hibi_dma_gif_req_c,
    fsl_rsp   => dflt_fsl_rsp_c
  );
  
  signal r, rin : reg_t;
  
begin
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, sel_i, fsl_req_i, gif_rsp_i, dma_status_i) is
    variable v      : reg_t;
    variable status : unsigned(hibi_dma_channels_c-1 downto 0); 
  begin
    v := r;
    
    v.gif_req.wr        := '0';
    v.gif_req.rd        := '0';
    
    if(sel_i = '1') then
      v.state           := not v.state;
    end if;

    if(sel_i = '1') then
      if(fsl_req_i.wr = '1' and fsl_req_i.ctrl = '1') then
        v.gif_req.addr  := fsl_req_i.data(v.gif_req.addr'range);
      end if;
    end if;
    
    if(sel_i = '1') then
      if(fsl_req_i.wr = '1' and fsl_req_i.ctrl = '0') then
        v.gif_req.wdata := fsl_req_i.data(v.gif_req.wdata'range);
        v.gif_req.wr    := v.state;
      end if;
    end if;
    
    if(sel_i = '1') then
      if(fsl_req_i.rd = '1' and fsl_req_i.ctrl = '1') then
        v.gif_req.addr  := fsl_req_i.data(v.gif_req.addr'range);
        v.gif_req.rd    := v.state;
      end if;
    end if;
    
    ----------------------------------------------------------------------------
    -- blocking wait for status being ready
    ----------------------------------------------------------------------------
    stat_loop: for i in 0 to hibi_dma_channels_c-1 loop
      status(i) := dma_status_i(i).busy;
    end loop stat_loop;
    
    if(sel_i = '1') then
      if(fsl_req_i.rd = '1' and fsl_req_i.ctrl = '0') then
        v.fsl_rsp.rdata := std_ulogic_vector(resize(unsigned(gif_rsp_i.rdata), v.fsl_rsp.rdata'length));
      end if;
      
      if(r.gif_req.addr = addr_offset_HIBI_DMA_STATUS_slv_c) then
        if(status = 0) then
          v.fsl_rsp.valid      := '1';
        else
          v.fsl_rsp.valid      := '0';
        end if;
        
        if(fsl_req_i.blocking = '1') then
          if(status /= 0) then
            v.fsl_rsp.wait_req := '1';
          end if;
        end if;
      end if;
    end if;
    
    if(status = 0) then
      v.fsl_rsp.wait_req := '0';
      v.fsl_rsp.valid    := '1';
    end if;    
    
    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    gif_req_o <= r.gif_req;
    fsl_rsp_o <= r.fsl_rsp;
    
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

