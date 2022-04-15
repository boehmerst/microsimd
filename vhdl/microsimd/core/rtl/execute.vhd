library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.core_pkg.all;
use work.func_pkg.all;
use work.vec_data_pkg.all;

entity execute is
  generic (
    use_barrel_g : boolean;
    use_hw_mul_g : boolean;
    use_fsl_g    : boolean;
    nr_fsl_g     : positive
  );
  port (
    clk_i        : in  std_ulogic;
    reset_n_i    : in  std_ulogic;
    init_i       : in  std_ulogic;
    en_i         : in  std_ulogic;
    stall_i      : in  std_ulogic;
    exec_o       : out execute_out_t;
    exec_i       : in  execute_in_t;
    scalar_o     : out std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    dat_vec_i    : in  vec_data_t;
    fsl_sel_o    : out std_ulogic_vector(nr_fsl_g-1 downto 0);
    fsl_req_o    : out fsl_req_t;
    fsl_rsp_i    : in  fsl_rsp_array_t(0 to nr_fsl_g-1);
    ready_o      : out std_ulogic
  );
end entity execute;

architecture rtl of execute is

  type reg_t is record
    exec       : execute_out_t;
    carry      : std_ulogic;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    exec       => dflt_execute_out_c,
    carry      => '0'
  );

  signal fsl_data   : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
  signal fsl_ready  : std_ulogic;
  signal fsl_result : fsl_result_t;

  signal ena        : std_ulogic;

  signal r, rin     : reg_t;
  
begin
  ------------------------------------------------------------------------------
  -- fsl link controller
  ------------------------------------------------------------------------------
  fsl_block: block is
    signal fsli0_ready  : std_ulogic;
    signal fsli0_sel    : std_ulogic_vector(nr_fsl_g-1 downto 0);
    signal fsli0_result : fsl_result_t;
    signal fsli0_req    : fsl_req_t;
  begin
    fsl_unit: if use_fsl_g = true generate
      fsli0: entity work.fsl_ctrl
        port map (
          clk_i        => clk_i,
          reset_n_i    => reset_n_i,
          en_i         => en_i,
          init_i       => init_i,
          fsl_ctrl_i   => exec_i.ctrl_ex.fsl,
          fsl_data_i   => fsl_data,
          fsl_result_o => fsli0_result,
          fsl_sel_o    => fsli0_sel,
          fsl_req_o    => fsli0_req,
          fsl_rsp_i    => fsl_rsp_i,
          ready_o      => fsli0_ready
        );
    end generate fsl_unit;
    fsl_ready  <= fsli0_ready  when use_fsl_g else '1';
    fsl_result <= fsli0_result when use_fsl_g else dflt_fsl_result_c;
    fsl_sel_o  <= fsli0_sel    when use_fsl_g and r.exec.flush_ex = '0' else (others=>'0');
    fsl_req_o  <= fsli0_req    when use_fsl_g else dflt_fsl_req_c;
  end block fsl_block;
    
  
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, exec_i, dat_vec_i, fsl_result, fsl_ready) is
    variable v             : reg_t;
    variable alu_src_a     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    variable alu_src_b     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    variable carry         : std_ulogic;
    variable result        : std_ulogic_vector(CFG_DMEM_WIDTH downto 0);
    variable result_add    : std_ulogic_vector(CFG_DMEM_WIDTH downto 0);
    variable zero          : std_ulogic;
    variable dat_a         : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    variable dat_b         : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    variable dat_scu_a     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    variable sel_dat_a     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    variable sel_dat_b     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0); 
    variable sel_dat_scu_a : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0); 
    variable sel_dat_d     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    variable mem_result    : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
  begin
    v := r;

    ----------------------------------------------------------------------------
    -- write-back forward and r0 = zero logic
    ----------------------------------------------------------------------------
    sel_dat_a     := select_register_data(exec_i.dat_a, exec_i.reg_a, exec_i.fwd_dec_result, fwd_cond(exec_i.fwd_dec.reg_write, exec_i.fwd_dec.reg_d, exec_i.reg_a));
    sel_dat_b     := select_register_data(exec_i.dat_b, exec_i.reg_b, exec_i.fwd_dec_result, fwd_cond(exec_i.fwd_dec.reg_write, exec_i.fwd_dec.reg_d, exec_i.reg_b));
    sel_dat_d     := select_register_data(exec_i.dat_d, exec_i.ctrl_wrb.reg_d, exec_i.fwd_dec_result, fwd_cond(exec_i.fwd_dec.reg_write, exec_i.fwd_dec.reg_d, exec_i.ctrl_wrb.reg_d));
    
    ----------------------------------------------------------------------------
    -- conditionally flush execution stage in case of control hazards
    ----------------------------------------------------------------------------
    if(r.exec.flush_ex = '1') then
      v.exec.ctrl_mem.mem_write := '0';
      v.exec.ctrl_mem.mem_read  := '0';
      v.exec.ctrl_wrb.reg_write := '0';
      v.exec.ctrl_wrb.reg_d     := (others=>'0');
    else
      v.exec.ctrl_mem           := exec_i.ctrl_mem;
      v.exec.ctrl_wrb           := exec_i.ctrl_wrb;
    end if;
    
    ----------------------------------------------------------------------------
    -- if we got forwarded a memory result we migth need to align the data first
    ----------------------------------------------------------------------------
    if(exec_i.ctrl_mem_wrb.mem_read = '1') then
      mem_result := align_mem_load(exec_i.mem_result, exec_i.ctrl_mem_wrb.transfer_size, exec_i.alu_result(1 downto 0));
    else
      mem_result := exec_i.alu_result;
    end if;

    ----------------------------------------------------------------------------
    -- multiplex between the various forward logic paths
    ----------------------------------------------------------------------------
    if(fwd_cond(r.exec.ctrl_wrb.reg_write, r.exec.ctrl_wrb.reg_d, exec_i.reg_a) = '1') then
      dat_a                     := r.exec.alu_result;
    elsif(fwd_cond(exec_i.fwd_mem.reg_write, exec_i.fwd_mem.reg_d, exec_i.reg_a) = '1') then
      dat_a                     := mem_result;
    else    
      dat_a                     := sel_dat_a;
    end if;

    if(fwd_cond(r.exec.ctrl_wrb.reg_write, r.exec.ctrl_wrb.reg_d, exec_i.reg_b) = '1') then
      dat_b                     := r.exec.alu_result;
    elsif(fwd_cond(exec_i.fwd_mem.reg_write, exec_i.fwd_mem.reg_d, exec_i.reg_b) = '1') then
      dat_b                     := mem_result;
    else
      dat_b                     := sel_dat_b;
    end if;  

    if(fwd_cond(r.exec.ctrl_wrb.reg_write, r.exec.ctrl_wrb.reg_d, exec_i.ctrl_wrb.reg_d) = '1') then
      v.exec.dat_d              := align_mem_store(r.exec.alu_result, exec_i.ctrl_mem.transfer_size);
    elsif(fwd_cond(exec_i.fwd_mem.reg_write, exec_i.fwd_mem.reg_d, exec_i.ctrl_wrb.reg_d) = '1') then  
      v.exec.dat_d              := align_mem_store(mem_result, exec_i.ctrl_mem.transfer_size);
    else   
      v.exec.dat_d              := align_mem_store(sel_dat_d, exec_i.ctrl_mem.transfer_size);
    end if;
    
    ----------------------------------------------------------------------------
    -- set the first operand of the ALU
    ----------------------------------------------------------------------------
    case(exec_i.ctrl_ex.alu_src_a) is
      when ALU_SRC_PC       => alu_src_a := sign_extend(exec_i.pc, '0', CFG_DMEM_WIDTH);
      when ALU_SRC_NOT_REGA => alu_src_a := not dat_a;
      when ALU_SRC_ZERO     => alu_src_a := (others => '0');
      when others           => alu_src_a := dat_a;
    end case;

    ----------------------------------------------------------------------------
    -- set the second operand of the ALU
    ----------------------------------------------------------------------------
    case(exec_i.ctrl_ex.alu_src_b) is
      when ALU_SRC_IMM      => alu_src_b := exec_i.imm;
      when ALU_SRC_NOT_IMM  => alu_src_b := not exec_i.imm;
      when ALU_SRC_NOT_REGB => alu_src_b := not dat_b;
      when others           => alu_src_b := dat_b;
    end case;

    ----------------------------------------------------------------------------
    -- determine value of carry in
    ----------------------------------------------------------------------------
    case(exec_i.ctrl_ex.carry) is
      when CARRY_ALU   => carry := r.carry;
      when CARRY_ONE   => carry := '1';
      when CARRY_ARITH => carry := alu_src_a(CFG_DMEM_WIDTH-1);
      when others      => carry := '0';
    end case;

    result_add := add(alu_src_a, alu_src_b, carry);

    ----------------------------------------------------------------------------
    -- arithmetic ALU operations
    ----------------------------------------------------------------------------
    case exec_i.ctrl_ex.alu_op is
      when ALU_ADD    => result := result_add;
      when ALU_OR     => result := '0' & (alu_src_a or alu_src_b);
      when ALU_AND    => result := '0' & (alu_src_a and alu_src_b);
      when ALU_XOR    => result := '0' & (alu_src_a xor alu_src_b);
      when ALU_SHIFT  => result := alu_src_a(0) & carry & alu_src_a(CFG_DMEM_WIDTH-1 downto 1);
      when ALU_SEXT8  => result := '0' & sign_extend(alu_src_a(7 downto 0), alu_src_a(7), CFG_DMEM_WIDTH);
      when ALU_SEXT16 => result := '0' & sign_extend(alu_src_a(15 downto 0), alu_src_a(15), CFG_DMEM_WIDTH);
      when ALU_MUL    => if(use_hw_mul_g = true) then
                           result := '0' & multiply(alu_src_a, alu_src_b);
                         else
                           result := (others => '0');
                         end if;
      when ALU_BS     => if(use_barrel_g = true) then
                           result := '0' & shift(alu_src_a, alu_src_b(4 downto 0), exec_i.imm(10), exec_i.imm(9));
                         else
                           result := (others => '0');
                         end if;
      when ALU_MOV    => result := '0' & extract(dat_vec_i, exec_i.imm);
      when ALU_FSL    => result := not fsl_result.valid & fsl_result.data;
      when others     => result := (others => '0');
                         report "Invalid ALU operation" severity FAILURE;
    end case;
    
    ----------------------------------------------------------------------------
    -- set carry register
    ----------------------------------------------------------------------------
    if(exec_i.ctrl_ex.carry_keep /= CARRY_KEEP) then
      v.carry := result(CFG_DMEM_WIDTH);
    end if;

    zero := is_zero(dat_a);

    ----------------------------------------------------------------------------
    -- overwrite branch condition
    ----------------------------------------------------------------------------
    if(r.exec.flush_ex = '1') then
      v.exec.branch := '0';
    else
      -- determine branch condition
      case(exec_i.ctrl_ex.branch_cond) is
        when BNC    => v.exec.branch := '1';
        when BEQ    => v.exec.branch := zero;
        when BNE    => v.exec.branch := not zero;
        when BLT    => v.exec.branch := dat_a(CFG_DMEM_WIDTH-1);
        when BLE    => v.exec.branch := dat_a(CFG_DMEM_WIDTH-1) or zero;
        when BGT    => v.exec.branch := not (dat_a(CFG_DMEM_WIDTH-1) or zero);
        when BGE    => v.exec.branch := not dat_a(CFG_DMEM_WIDTH-1);
        when others => v.exec.branch := '0';
      end case;
    end if;
    
    ----------------------------------------------------------------------------
    -- handle CMPU
    ----------------------------------------------------------------------------
    if((exec_i.ctrl_ex.operation and not (alu_src_a(CFG_DMEM_WIDTH-1) xor alu_src_b(CFG_DMEM_WIDTH-1))) = '1') then
      -- set MSB
      v.exec.alu_result(CFG_DMEM_WIDTH-1 downto 0) := (not result(CFG_DMEM_WIDTH-1)) & result(CFG_DMEM_WIDTH-2 downto 0);
    else
      -- use ALU result
      v.exec.alu_result := result(CFG_DMEM_WIDTH-1 downto 0);
    end if;
    
    ----------------------------------------------------------------------------
    -- use alu_result or alu_src_a as memory address in mem stage
    ----------------------------------------------------------------------------
    if(exec_i.ctrl_ex.addr_post_modify = '1') then
      v.exec.mem_addr   := alu_src_a;
    else
      v.exec.mem_addr   := result(CFG_DMEM_WIDTH-1 downto 0);
    end if;

    v.exec.pc           := exec_i.pc;

    ----------------------------------------------------------------------------
    -- determine flush signals
    ----------------------------------------------------------------------------
    v.exec.flush_id := v.exec.branch;
    v.exec.flush_ex := v.exec.branch and not exec_i.ctrl_ex.delay;
    
    ----------------------------------------------------------------------------
    -- drive module output and fsl controller
    ----------------------------------------------------------------------------
    fsl_data <= dat_a;
    exec_o   <= r.exec;
    scalar_o <= dat_a;
    ready_o  <= fsl_ready;
    
    rin      <= v;
  end process comb0;
  
  ------------------------------------------------------------------------------
  -- sync0
  ------------------------------------------------------------------------------
  ena <= en_i and fsl_ready and not stall_i;
  
  sync0: process(clk_i, reset_n_i) is
  begin
    if(reset_n_i = '0') then
      r <= dflt_reg_c;
    elsif(rising_edge(clk_i)) then
      if(ena = '1') then
        if(init_i = '1') then
          r <= dflt_reg_c;
        else
          r <= rin;
        end if;
      end if;
    end if;
  end process sync0;  

end architecture rtl;

