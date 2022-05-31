library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.core_pkg.all;
use work.fsl_per_regif_types_pkg.all;
use work.fsl_per_regfile_pkg.all;


entity fsl_per is
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;
    en_i      : in  std_ulogic;
    init_i    : in  std_ulogic;
    sel_i     : in  std_ulogic;
    fsl_req_i : in  fsl_req_t;
    fsl_rsp_o : out fsl_rsp_t;
    gpi_i     : in  std_ulogic_vector(3 downto 0);
    gpo_o     : out std_ulogic_vector(7 downto 0)
  );
end entity fsl_per;

architecture rtl of fsl_per is

  signal fsli0_gif_req     : fsl_per_gif_req_t;
  signal regifi0_gif_rsp   : fsl_per_gif_rsp_t;
  
  signal logic2reg         : fsl_per_logic2reg_t;
  signal regifi0_reg2logic : fsl_per_reg2logic_t;

begin
  ------------------------------------------------------------------------------
  -- fsl_per register file
  ------------------------------------------------------------------------------
  regifi0: entity work.fsl_per_regfile
    port map (
      clk_i       => clk_i,
      reset_n_i   => reset_n_i,
      gif_req_i   => fsli0_gif_req,
      gif_rsp_o   => regifi0_gif_rsp,
      logic2reg_i => logic2reg,
      reg2logic_o => regifi0_reg2logic
    );
      
  ------------------------------------------------------------------------------
  -- FSL unit
  ------------------------------------------------------------------------------
  fsli0: entity work.fsl_per_ctrl
    port map (
      clk_i        => clk_i,
      reset_n_i    => reset_n_i,
      en_i         => en_i,
      init_i       => init_i,
      sel_i        => sel_i,
      fsl_req_i    => fsl_req_i,
      fsl_rsp_o    => fsl_rsp_o,
      gif_req_o    => fsli0_gif_req,
      gif_rsp_i    => regifi0_gif_rsp
    );
    
  ------------------------------------------------------------------------------
  -- register mapping
  ------------------------------------------------------------------------------
  logic2reg.GPIN0.ro.input <= gpi_i(1 downto 0);
  logic2reg.GPIN1.ro.input <= gpi_i(3 downto 2);
  
  gpo_o <= regifi0_reg2logic.SCRATCHPAD1.rw.scratch & regifi0_reg2logic.SCRATCHPAD0.rw.scratch;

end architecture rtl;

