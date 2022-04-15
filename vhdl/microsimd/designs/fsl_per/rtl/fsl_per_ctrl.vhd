library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.core_pkg.all;
use work.fsl_per_regif_types_pkg.all;

entity fsl_per_ctrl is
  port (
    clk_i         : in  std_ulogic;
    reset_n_i     : in  std_ulogic;
    en_i          : in  std_ulogic;
    init_i        : in  std_ulogic;
    sel_i         : in  std_ulogic;
    fsl_req_i     : in  fsl_req_t;
    fsl_rsp_o     : out fsl_rsp_t;
    gif_req_o     : out fsl_per_gif_req_t;
    gif_rsp_i     : in  fsl_per_gif_rsp_t
  );
end entity fsl_per_ctrl;

architecture rtl of fsl_per_ctrl is

  type reg_t is record
    state     : std_ulogic;
    gif_req   : fsl_per_gif_req_t;
    fsl_rsp   : fsl_rsp_t;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    state     => '0',
    gif_req   => dflt_fsl_per_gif_req_c,
    fsl_rsp   => dflt_fsl_rsp_c
  );
  
  signal r, rin : reg_t;
  
begin
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, sel_i, fsl_req_i, gif_rsp_i) is
    variable v      : reg_t;
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
        
    if(sel_i = '1') then
      if(fsl_req_i.rd = '1' and fsl_req_i.ctrl = '0') then
        v.fsl_rsp.rdata := std_ulogic_vector(resize(unsigned(gif_rsp_i.rdata), v.fsl_rsp.rdata'length));
      end if;
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

