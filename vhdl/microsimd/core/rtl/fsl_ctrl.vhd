library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.func_pkg.all;
use work.core_pkg.all;

entity fsl_ctrl is
  port (
    clk_i        : in  std_ulogic;
    reset_n_i    : in  std_ulogic;
    en_i         : in  std_ulogic;
    init_i       : in  std_ulogic;
    fsl_ctrl_i   : in  fsl_ctrl_t;
    fsl_data_i   : in  std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    fsl_result_o : out fsl_result_t;
    fsl_sel_o    : out std_ulogic_vector(CFG_NR_FSL-1 downto 0);
    fsl_req_o    : out fsl_req_t;
    fsl_rsp_i    : in  fsl_rsp_array_t(0 to CFG_NR_FSL-1);
    ready_o      : out std_ulogic
  );
end entity fsl_ctrl;

architecture rtl of fsl_ctrl is

  type reg_t is record
    channel   : std_ulogic_vector(2 downto 0);
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    channel   => (others=>'0')
  );
  
  signal r, rin : reg_t;

begin
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, fsl_ctrl_i, fsl_data_i, fsl_rsp_i) is
    variable v            : reg_t;
    variable result       : fsl_rsp_t;
  begin
    v := r;

    ----------------------------------------------------------------------------
    -- latch channel
    ----------------------------------------------------------------------------
    v.channel := fsl_ctrl_i.link;

    ----------------------------------------------------------------------------
    -- result mux
    ----------------------------------------------------------------------------
    if(CFG_NR_FSL = 1 or CFG_NR_FSL = 0) then
      result := fsl_rsp_i(0); -- to avoid null array
    else
      result := fsl_rsp_i(to_integer(unsigned(r.channel(log2ceil(CFG_NR_FSL)-1 downto 0))));
    end if;
    
    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    fsl_req_o.blocking   <= fsl_ctrl_i.blocking;
    fsl_req_o.ctrl       <= fsl_ctrl_i.ctrl;
    fsl_req_o.wr         <= fsl_ctrl_i.wr;
    fsl_req_o.rd         <= fsl_ctrl_i.rd;
    fsl_req_o.data       <= fsl_data_i;
    
    fsl_result_o.data    <= result.rdata;
    fsl_result_o.valid   <= result.valid;
    
    ready_o              <= not result.wait_req;
    
    rin <= v;
  end process comb0;
  
  fsl_sel_o <= onehot(fsl_ctrl_i.link)(fsl_sel_o'range) when en_i = '1' and (fsl_ctrl_i.wr = '1' or fsl_ctrl_i.rd = '1') else (others=>'0');
  
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

