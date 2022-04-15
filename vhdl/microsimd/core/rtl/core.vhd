library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.func_pkg.all;
use work.core_pkg.all;
use work.vec_data_pkg.all;

entity core is
  generic (
    use_lsu_g          : boolean                                     := false;
    use_barrel_g       : boolean                                     := CFG_USE_BARREL;
    use_vec_barrel_g   : boolean                                     := CFG_USE_VEC_BARREL;
    use_hw_mul_g       : boolean                                     := CFG_USE_HW_MUL;
    use_fsl_g          : boolean                                     := CFG_USE_FSL;
    nr_fsl_g           : positive                                    := CFG_NR_FSL;
    use_vec_mul_g      : boolean                                     := CFG_USE_HW_VEC_MUL;
    use_shuffle_g      : boolean                                     := CFG_USE_SHUFFLE;
    use_custom_g       : boolean                                     := CFG_USE_CUSTOM;
    mci_custom_g       : boolean                                     := CFG_MCI_CUSTOM;
    use_irq_g          : boolean                                     := CFG_INTERRUPT;
    irq_vec_g          : std_ulogic_vector(CFG_IMEM_SIZE-1 downto 0) := CFG_IRQ_VEC
  );
  port (
    clk_i              : in  std_ulogic;
    reset_n_i          : in  std_ulogic;
    init_i             : in  std_ulogic;
    irq_i              : in  std_ulogic;
    wait_n_i           : in  std_ulogic;
    imem_o             : out imem_out_t;
    imem_i             : in  imem_in_t;
    dmem_o             : out dmem_out_t;
    dmem_i             : in  dmem_in_t;
    fsl_sel_o          : out std_ulogic_vector(nr_fsl_g-1 downto 0);
    fsl_req_o          : out fsl_req_t;
    fsl_rsp_i          : in  fsl_rsp_array_t(0 to nr_fsl_g-1)
  );
end entity core;

architecture rtl of core is

  signal fetch                : fetch_in_t;
  signal fetchi0_fetch        : fetch_out_t;

  signal decode               : decode_in_t;
  signal decodei0_decode      : decode_out_t;
  signal decodei0_gprf        : gprf_out_t;
  signal decodei0_vecrf       : vecrf_out_t;
  
  signal exec                 : execute_in_t;
  signal execi0_exec          : execute_out_t;
  signal execi0_scalar        : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
  signal execi0_ready         : std_ulogic;

  signal simd_exec            : vec_execute_in_t;
  signal simd_execi0_exec     : vec_execute_out_t;
  signal simd_execi0_ready    : std_ulogic;
  signal simd_execi0_vec_data : vec_data_t;

  signal mem                  : mem_in_t;
  signal memi0_mem            : mem_out_t;
  signal memi0_dmem           : dmem_out_t;
  
  signal dmem                 : dmem_in_t;
  signal wait_n               : std_ulogic;
  
  signal ena                  : std_ulogic;
  signal simd_exec_ena        : std_ulogic;
  signal scu_exec_ena         : std_ulogic;

begin  
  ------------------------------------------------------------------------------
  -- enable for core and execution units
  ------------------------------------------------------------------------------
  ena            <= wait_n and simd_execi0_ready and execi0_ready;
  simd_exec_ena  <= wait_n and execi0_ready;
  scu_exec_ena   <= wait_n and simd_execi0_ready;
  
  ------------------------------------------------------------------------------
  -- fetch (IF)
  ------------------------------------------------------------------------------
  fetch.hazard        <= decodei0_decode.scu.hazard;
  fetch.stall         <= decodei0_decode.scu.stall;
  fetch.branch        <= execi0_exec.branch;
  fetch.branch_target <= execi0_exec.alu_result(fetch.branch_target'range);
  
  fetchi0: entity work.fetch
    port map (
      clk_i           => clk_i,
      reset_n_i       => reset_n_i,
      init_i          => init_i,
      en_i            => ena,
      fetch_i         => fetch,
      fetch_o         => fetchi0_fetch,
      imem_o          => imem_o
    );
    
  ------------------------------------------------------------------------------
  -- decode (ID, OF and WB)
  ------------------------------------------------------------------------------
  decode.scu.irq           <= irq_i;
  decode.scu.pc            <= fetchi0_fetch.pc;
  decode.scu.inst          <= imem_i.dat;
  decode.scu.ctrl_wrb      <= memi0_mem.scu.ctrl_wrb;
  decode.scu.ctrl_mem_wrb  <= memi0_mem.scu.ctrl_mem_wrb;
  decode.scu.mem_result    <= dmem.scu.dat;
  decode.scu.alu_result    <= memi0_mem.scu.alu_result;
  decode.scu.flush_id      <= execi0_exec.flush_id;
  
  decode.simd.ctrl_wrb     <= memi0_mem.simd.ctrl_wrb;
  decode.simd.ctrl_mem_wrb <= memi0_mem.simd.ctrl_mem_wrb;
  decode.simd.mem_result   <= dmem.simd.dat;
  decode.simd.alu_result   <= memi0_mem.simd.alu_result;
  
  decodei0: entity work.decode
    generic map (
      use_barrel_g    => use_barrel_g,
      use_hw_mul_g    => use_hw_mul_g,
      use_fsl_g       => use_fsl_g,
      use_dbg_g       => true,
      use_custom_g    => use_custom_g,
      mci_custom_g    => mci_custom_g,
      use_irq_g       => use_irq_g,
      irq_vec_g       => irq_vec_g
    )
    port map (
      clk_i           => clk_i,
      reset_n_i       => reset_n_i,
      init_i          => init_i,
      en_i            => ena,
      decode_i        => decode,
      decode_o        => decodei0_decode,
      gprf_o          => decodei0_gprf,
      vecrf_o         => decodei0_vecrf
    );
    
  ------------------------------------------------------------------------------
  -- scalar execution unit (EX)
  ------------------------------------------------------------------------------
  exec.fwd_dec        <= decodei0_decode.scu.fwd_dec;
  exec.fwd_dec_result <= decodei0_decode.scu.fwd_dec_result;

  exec.dat_a          <= decodei0_gprf.dat_a;
  exec.dat_b          <= decodei0_gprf.dat_b;
  exec.dat_d          <= decodei0_gprf.dat_d;
  exec.reg_a          <= decodei0_decode.scu.reg_a;
  exec.reg_b          <= decodei0_decode.scu.reg_b;

  exec.imm            <= decodei0_decode.scu.imm;
  exec.pc             <= decodei0_decode.scu.pc;
  exec.ctrl_wrb       <= decodei0_decode.scu.ctrl_wrb;
  exec.ctrl_mem       <= decodei0_decode.scu.ctrl_mem;
  exec.ctrl_ex        <= decodei0_decode.scu.ctrl_ex;

  exec.fwd_mem        <= memi0_mem.scu.ctrl_wrb;
  exec.mem_result     <= dmem.scu.dat;
  exec.alu_result     <= memi0_mem.scu.alu_result;
  exec.ctrl_mem_wrb   <= memi0_mem.scu.ctrl_mem_wrb;
  
  execi0: entity work.execute
    generic map (
      use_barrel_g    => use_barrel_g,
      use_hw_mul_g    => use_hw_mul_g,
      use_fsl_g       => use_fsl_g,
      nr_fsl_g        => nr_fsl_g
    )
    port map (
      clk_i           => clk_i,
      reset_n_i       => reset_n_i,
      init_i          => init_i,
      en_i            => scu_exec_ena,
      stall_i         => decodei0_decode.scu.stall,
      exec_o          => execi0_exec,
      exec_i          => exec,
      scalar_o        => execi0_scalar,
      dat_vec_i       => simd_execi0_vec_data,
      fsl_sel_o       => fsl_sel_o,
      fsl_req_o       => fsl_req_o,
      fsl_rsp_i       => fsl_rsp_i,
      ready_o         => execi0_ready
    );
  
  ------------------------------------------------------------------------------
  -- SIMD execution unit (VEX)
  ------------------------------------------------------------------------------
  simd_exec.fwd_dec        <= decodei0_decode.simd.fwd_dec;
  simd_exec.fwd_dec_result <= decodei0_decode.simd.fwd_dec_result;

  simd_exec.dat_a          <= decodei0_vecrf.dat_a;
  simd_exec.dat_b          <= decodei0_vecrf.dat_b;
  simd_exec.dat_d          <= decodei0_vecrf.dat_d;
  simd_exec.reg_a          <= decodei0_decode.simd.reg_a;
  simd_exec.reg_b          <= decodei0_decode.simd.reg_b;

  simd_exec.imm            <= decodei0_decode.simd.imm;
  simd_exec.ctrl_wrb       <= decodei0_decode.simd.ctrl_wrb;
  simd_exec.ctrl_mem       <= decodei0_decode.simd.ctrl_mem;
  simd_exec.ctrl_ex        <= decodei0_decode.simd.ctrl_ex;
  simd_exec.flush          <= execi0_exec.flush_ex;

  simd_exec.fwd_mem        <= memi0_mem.simd.ctrl_wrb;
  simd_exec.mem_result     <= dmem.simd.dat;
  simd_exec.alu_result     <= memi0_mem.simd.alu_result;
  simd_exec.ctrl_mem_wrb   <= memi0_mem.simd.ctrl_mem_wrb;
    
  simd_execi0: entity work.simd_execute
    generic map (
      use_barrel_g  => use_vec_barrel_g,
      use_mul_g     => use_vec_mul_g,
      use_shuffle_g => use_shuffle_g,
      use_custom_g  => use_custom_g
    )
    port map (
      clk_i         => clk_i,
      reset_n_i     => reset_n_i,
      init_i        => init_i,
      en_i          => simd_exec_ena,
      stall_i       => decodei0_decode.scu.stall,
      exec_o        => simd_execi0_exec,
      exec_i        => simd_exec,
      scalar_i      => execi0_scalar,
      vec_data_o    => simd_execi0_vec_data,
      ready_o       => simd_execi0_ready
    );

  ------------------------------------------------------------------------------
  -- memory unit (MEM)
  ------------------------------------------------------------------------------
  mem.scu.alu_result  <= execi0_exec.alu_result;
  mem.scu.mem_addr    <= execi0_exec.mem_addr;
  mem.scu.pc          <= execi0_exec.pc;
  mem.scu.branch      <= execi0_exec.branch;
  mem.scu.dat_d       <= execi0_exec.dat_d;
  mem.scu.ctrl_wrb    <= execi0_exec.ctrl_wrb;
  mem.scu.ctrl_mem    <= execi0_exec.ctrl_mem;
  mem.scu.mem_result  <= dmem.scu.dat;
  
  mem.simd.alu_result <= simd_execi0_exec.alu_result;
  mem.simd.dat_d      <= simd_execi0_exec.dat_d;
  mem.simd.ctrl_wrb   <= simd_execi0_exec.ctrl_wrb;
  mem.simd.ctrl_mem   <= simd_execi0_exec.ctrl_mem;
  mem.simd.mem_result <= dmem.simd.dat;
  
  memi0: entity work.mem
    port map (
      clk_i      => clk_i,
      reset_n_i  => reset_n_i,
      init_i     => init_i,
      en_i       => ena,
      mem_o      => memi0_mem,
      mem_i      => mem,
      dmem_o     => memi0_dmem
    );
    
  ------------------------------------------------------------------------------
  -- load-store unit
  ------------------------------------------------------------------------------
  lsu_block0: block is
    signal lsui0_wait_n    : std_ulogic;
    signal lsui0_lsu_dmem  : scu_dmem_out_t;
    signal lsui0_core_dmem : dmem_in_t;
  begin
    lsu_gen0: if use_lsu_g generate
      lsui0: entity work.lsu
        port map (
          clk_i       => clk_i,
          reset_n_i   => reset_n_i,
          init_i      => init_i,
          wait_n_i    => wait_n_i,
          core_dmem_i => memi0_dmem,
          core_dmem_o => lsui0_core_dmem,
          lsu_dmem_o  => lsui0_lsu_dmem,
          lsu_dmem_i  => dmem_i.scu,
          wait_n_o    => lsui0_wait_n
        );
    end generate lsu_gen0;
    dmem_o.scu  <= lsui0_lsu_dmem      when use_lsu_g else memi0_dmem.scu;
    dmem_o.simd <= dflt_vec_dmem_out_c when use_lsu_g else memi0_dmem.simd;    
    dmem        <= lsui0_core_dmem     when use_lsu_g else dmem_i;
    wait_n      <= lsui0_wait_n        when use_lsu_g else wait_n_i; 
  end block lsu_block0;
  
end architecture rtl;

