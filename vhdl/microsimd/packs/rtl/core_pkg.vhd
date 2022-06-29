library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.func_pkg.all;
use work.vec_data_pkg.all;

package core_pkg is

  constant std_zero_c : std_ulogic := '0';
  constant std_one_c  : std_ulogic := '1';

  constant C_8_ZEROS  : std_ulogic_vector ( 7 downto 0) := (others => '0');
  constant C_16_ZEROS : std_ulogic_vector (15 downto 0) := (others => '0');
  constant C_24_ZEROS : std_ulogic_vector (23 downto 0) := (others => '0');
  constant C_32_ZEROS : std_ulogic_vector (31 downto 0) := (others => '0');

  type alu_op_t             is (ALU_ADD, ALU_OR, ALU_AND, ALU_XOR, ALU_SHIFT, ALU_SEXT8, ALU_SEXT16, ALU_MUL, ALU_BS, ALU_MOV, ALU_FSL);
  type alu_simd_op_t        is (SIMD_ADD, SIMD_OR, SIMD_AND, SIMD_XOR, SIMD_SHIFT, SIMD_MUL, SIMD_BIF, SIMD_BIT, SIMD_BSL, SIMD_MOV, SIMD_MOVA, SIMD_SHUF, SIMD_CUSTOM);
  
  type simd_size_t          is (BYTE, WORD, DOUBLE);
  type simd_direction_t     is (LEFT, RIGHT, LEFT_RIGHT);

  type simd_addsub_t        is (ADD,  SUB);
  type simd_data_t          is (U, S);
  type simd_op_ext_t        is (NONE, NARROW_HIGH, NARROW_LOW, WIDE, LONG);
  
  type src_a_t              is (ALU_SRC_REGA, ALU_SRC_NOT_REGA, ALU_SRC_PC, ALU_SRC_ZERO);
  type src_b_t              is (ALU_SRC_REGB, ALU_SRC_NOT_REGB, ALU_SRC_IMM, ALU_SRC_NOT_IMM);
  
  type src_vec_a_t          is (SIMD_SRC_REGA, SIMD_SRC_REGAB, SIMD_SRC_SHIFT_IMM, SIMD_SRC_ZERO, SIMD_SRC_REGD);
  type src_vec_b_t          is (SIMD_SRC_REGB, SIMD_SRC_NOT_REGB, SIMD_SRC_IMM, SIMD_SRC_NOT_IMM, SIMD_SRC_REGBA);
  
  type carry_t              is (CARRY_ZERO, CARRY_ONE, CARRY_ALU, CARRY_ARITH);
  type carry_keep_t         is (CARRY_NOT_KEEP, CARRY_KEEP);
  type branch_condition_t   is (NOP, BNC, BEQ, BNE, BLT, BLE, BGT, BGE);
  type transfer_size_t      is (WORD, HALFWORD, BYTE);
  --type vif_condition_t      is (NONE, EQ, NE, GE, GT, LE, LT);

  type fsl_ctrl_t is record
    link     : std_ulogic_vector(2 downto 0);
    blocking : std_ulogic;
    ctrl     : std_ulogic;
    wr       : std_ulogic;
    rd       : std_ulogic;
  end record fsl_ctrl_t;
  constant dflt_fsl_ctrl_c : fsl_ctrl_t :=(
    link     => (others=>'0'),
    blocking => '0',
    ctrl     => '0',
    wr       => '0',
    rd       => '0'
  );
  
  type fsl_result_t is record
    data     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    valid    : std_ulogic; 
  end record fsl_result_t;
  constant dflt_fsl_result_c : fsl_result_t :=(
    data     => (others=>'0'),
    valid    => '0'
  );
  
  type fsl_req_t is record
    blocking : std_ulogic;
    ctrl     : std_ulogic;
    wr       : std_ulogic;
    rd       : std_ulogic;
    data     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
  end record fsl_req_t;
  constant dflt_fsl_req_c : fsl_req_t :=(
    blocking => '0',
    ctrl     => '0',
    wr       => '0',
    rd       => '0',
    data     => (others=>'0')
  );
  
  type fsl_rsp_t is record
    rdata    : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    valid    : std_ulogic;
    wait_req : std_ulogic;
  end record fsl_rsp_t;
  constant dflt_fsl_rsp_c : fsl_rsp_t :=(
    rdata    => (others=>'0'),
    valid    => '0',
    wait_req => '0'
  );
  
  type fsl_req_array_t is array(natural range <>) of fsl_req_t;
  type fsl_rsp_array_t is array(natural range <>) of fsl_rsp_t;
  
  type ctrl_execution_t is record
    alu_op            : alu_op_t;
    alu_src_a         : src_a_t;
    alu_src_b         : src_b_t;
    operation         : std_ulogic;
    carry             : carry_t;
    carry_keep        : carry_keep_t;
    branch_cond       : branch_condition_t;
    delay             : std_ulogic;
    fsl               : fsl_ctrl_t;
    addr_post_modify  : std_ulogic;
 end record ctrl_execution_t;
 constant dflt_ctrl_execution_c : ctrl_execution_t :=(
    alu_op            => ALU_ADD,
    alu_src_a         => ALU_SRC_REGA,
    alu_src_b         => ALU_SRC_REGB,
    operation         => '0',
    carry             => CARRY_ZERO,
    carry_keep        => CARRY_KEEP,
    branch_cond       => NOP,
    delay             => '0',
    fsl               => dflt_fsl_ctrl_c,
    addr_post_modify  => '0'
  );
  
  type ctrl_vec_execution_t is record
    simd_op           : alu_simd_op_t;
    simd_src_a        : src_vec_a_t;
    simd_src_a_sel    : std_ulogic_vector(1 downto 0);
    simd_src_b        : src_vec_b_t;
    simd_src_b_sel    : std_ulogic_vector(1 downto 0);
    size              : simd_size_t;
    dt                : simd_data_t;
    res_dt            : simd_data_t;
    dir               : simd_direction_t;
    mode              : simd_addsub_t;
    qualifier         : simd_op_ext_t;
    saturate          : std_ulogic;
    mac               : std_ulogic;
    custom_cmd        : std_ulogic_vector(2 downto 0);
  end record ctrl_vec_execution_t;
  constant dflt_ctrl_vec_execution_c : ctrl_vec_execution_t :=(
    simd_op           => SIMD_ADD,
    simd_src_a        => SIMD_SRC_REGA,
    simd_src_a_sel    => "11",
    simd_src_b        => SIMD_SRC_REGB,
    simd_src_b_sel    => "11",
    size              => DOUBLE,
    dt                => U,
    res_dt            => U,
    dir               => LEFT,
    mode              => ADD,
    qualifier         => NONE,
    saturate          => '0',
    mac               => '0',
    custom_cmd        => (others=>'0')
  ); 

  type ctrl_memory_t is record
    mem_write         : std_ulogic;
    mem_read          : std_ulogic;
    transfer_size     : transfer_size_t;
  end record ctrl_memory_t;
  constant dflt_ctrl_memory_c : ctrl_memory_t :=(
    mem_write         => '0',
    mem_read          => '0',
    transfer_size     => WORD
  );
  
  type ctrl_vec_memory_t is record
    mem_write         : std_ulogic;
    mem_read          : std_ulogic; 
    transfer_size     : std_ulogic_vector(1 downto 0);
  end record ctrl_vec_memory_t;
  constant dflt_ctrl_vec_memory_c : ctrl_vec_memory_t :=(
    mem_write         => '0',
    mem_read          => '0',
    transfer_size     => "11"
  );

  type ctrl_memory_writeback_t is record
    mem_read          : std_ulogic;
    transfer_size     : transfer_size_t;
  end record ctrl_memory_writeback_t;
  constant dflt_ctrl_memory_writeback_c : ctrl_memory_writeback_t :=(
    mem_read          => '0',
    transfer_size     => WORD
  );
  
  type ctrl_vec_memory_writeback_t is record
    mem_read          : std_ulogic;
    transfer_size     : std_ulogic_vector(1 downto 0);
  end record ctrl_vec_memory_writeback_t;
  constant dflt_ctrl_vec_memory_writeback_c : ctrl_vec_memory_writeback_t :=(
    mem_read          => '0',
    transfer_size     => "11"
  );

  type forward_t is record
    reg_d             : std_ulogic_vector(CFG_GPRF_SIZE-1 downto 0);
    reg_write         : std_ulogic;
  end record forward_t;
  constant dflt_forward_c : forward_t :=(
    reg_d             => (others=>'0'),
    reg_write         => '0'
  );
  
  type vec_forward_t is record
    reg_d             : std_ulogic_vector(CFG_VREG_SIZE-1 downto 0);
    reg_write         : std_ulogic_vector(1 downto 0);
  end record vec_forward_t;
  constant dflt_vec_forward_c : vec_forward_t :=(
    reg_d             => (others=>'0'),
    reg_write         => (others=>'0')
  ); 

  type imem_in_t is record
    dat               : std_ulogic_vector(CFG_IMEM_WIDTH-1 downto 0);
  end record imem_in_t;

  type imem_out_t is record
    adr               : std_ulogic_vector(CFG_IMEM_SIZE-1 downto 0);
    ena               : std_ulogic;
  end record imem_out_t;

  type fetch_in_t is record
    hazard            : std_ulogic;
    stall             : std_ulogic;
    branch            : std_ulogic;
    branch_target     : std_ulogic_vector(CFG_IMEM_SIZE-1 downto 0);
  end record fetch_in_t;

  type fetch_out_t is record
    pc                : std_ulogic_vector(CFG_IMEM_SIZE-1 downto 0);
  end record fetch_out_t;
  
  type gprf_in_t is record
    adr_a             : std_ulogic_vector(CFG_GPRF_SIZE-1  downto 0);
    adr_b             : std_ulogic_vector(CFG_GPRF_SIZE-1  downto 0);
    adr_d             : std_ulogic_vector(CFG_GPRF_SIZE-1  downto 0);
    dat_w             : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    adr_w             : std_ulogic_vector(CFG_GPRF_SIZE-1  downto 0);
    wre               : std_ulogic;
    ena               : std_ulogic;
  end record gprf_in_t;

  type gprf_out_t is record
    dat_a             : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    dat_b             : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    dat_d             : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
  end record gprf_out_t;
  
  type vecrf_in_t is record
    adr_a             : std_ulogic_vector(CFG_VREG_SIZE-1   downto 0);
    adr_b             : std_ulogic_vector(CFG_VREG_SIZE-1   downto 0);
    adr_d             : std_ulogic_vector(CFG_VREG_SIZE-1   downto 0);
    dat_w             : vec_data_t;
    adr_w             : std_ulogic_vector(CFG_VREG_SIZE-1   downto 0);
    wre               : std_ulogic_vector(CFG_VREG_SLICES-1 downto 0);
    ena               : std_ulogic;
  end record vecrf_in_t;

  type vecrf_out_t is record
    dat_a             : vec_data_t;
    dat_b             : vec_data_t;
    dat_d             : vec_data_t;
  end record vecrf_out_t;  
  
  type dec_scalar_in_t is record
    irq               : std_ulogic;
    pc                : std_ulogic_vector(CFG_IMEM_SIZE-1  downto 0);
    inst              : std_ulogic_vector(CFG_IMEM_WIDTH-1 downto 0);
    ctrl_wrb          : forward_t;
    ctrl_mem_wrb      : ctrl_memory_writeback_t;
    mem_result        : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    alu_result        : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    flush_id          : std_ulogic;
  end record dec_scalar_in_t;
  
  type dec_simd_in_t is record
    ctrl_wrb          : vec_forward_t;
    ctrl_mem_wrb      : ctrl_vec_memory_writeback_t;
    mem_result        : vec_data_t;
    alu_result        : vec_data_t;
  end record dec_simd_in_t;
  
  type dec_scalar_out_t is record
    reg_a             : std_ulogic_vector(CFG_GPRF_SIZE-1  downto 0);
    reg_b             : std_ulogic_vector(CFG_GPRF_SIZE-1  downto 0);
    imm               : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    pc                : std_ulogic_vector(CFG_IMEM_SIZE-1  downto 0);
    hazard            : std_ulogic;
    stall             : std_ulogic;
    ctrl_ex           : ctrl_execution_t;
    ctrl_mem          : ctrl_memory_t;
    ctrl_wrb          : forward_t;
    fwd_dec_result    : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    fwd_dec           : forward_t;
  end record dec_scalar_out_t;
  constant dflt_dec_scalar_out_c : dec_scalar_out_t :=(
    reg_a             => (others=>'0'),
    reg_b             => (others=>'0'),  
    imm               => (others=>'0'),
    pc                => (others=>'0'),
    hazard            => '0',
    stall             => '0',
    ctrl_ex           => dflt_ctrl_execution_c,
    ctrl_mem          => dflt_ctrl_memory_c,
    ctrl_wrb          => dflt_forward_c,
    fwd_dec_result    => (others => '0'),
    fwd_dec           => dflt_forward_c
  );
  
  type dec_simd_out_t is record
    reg_a             : std_ulogic_vector(CFG_VREG_SIZE-1  downto 0);
    reg_b             : std_ulogic_vector(CFG_VREG_SIZE-1  downto 0);
    imm               : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    ctrl_ex           : ctrl_vec_execution_t;
    ctrl_mem          : ctrl_vec_memory_t;
    ctrl_wrb          : vec_forward_t;
    fwd_dec_result    : vec_data_t;
    fwd_dec           : vec_forward_t;
  end record dec_simd_out_t;
  constant dflt_dec_simd_out_c : dec_simd_out_t :=(
    reg_a             => (others=>'0'),
    reg_b             => (others=>'0'),
    imm               => (others=>'0'),
    ctrl_ex           => dflt_ctrl_vec_execution_c,
    ctrl_mem          => dflt_ctrl_vec_memory_c,
    ctrl_wrb          => dflt_vec_forward_c,
    fwd_dec_result    => dflt_vec_data_c,
    fwd_dec           => dflt_vec_forward_c
  );

  type decode_in_t is record
    scu  : dec_scalar_in_t;
    simd : dec_simd_in_t;
  end record decode_in_t;

  type decode_out_t is record
    scu  : dec_scalar_out_t;
    simd : dec_simd_out_t;
  end record decode_out_t;
  constant dflt_decode_out_c : decode_out_t :=(
    scu  => dflt_dec_scalar_out_c,
    simd => dflt_dec_simd_out_c
  );

  type execute_out_t is record
    alu_result        : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    mem_addr          : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    dat_d             : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    branch            : std_ulogic;
    pc                : std_ulogic_vector(CFG_IMEM_SIZE-1 downto 0);
    flush_id          : std_ulogic;
    flush_ex          : std_ulogic;
    ctrl_mem          : ctrl_memory_t;
    ctrl_wrb          : forward_t;
  end record execute_out_t;
  constant dflt_execute_out_c : execute_out_t :=(
    alu_result        => (others=>'0'),
    mem_addr          => (others=>'0'),
    dat_d             => (others=>'0'),
    branch            => '0',
    pc                => (others=>'0'),
    flush_id          => '0',
    flush_ex          => '0',
    ctrl_mem          => dflt_ctrl_memory_c,
    ctrl_wrb          => dflt_forward_c
  );
  
  type vec_execute_out_t is record
    alu_result        : vec_data_t;
    dat_d             : vec_data_t;
    ctrl_mem          : ctrl_vec_memory_t;
    ctrl_wrb          : vec_forward_t;
  end record vec_execute_out_t;
  constant dflt_vec_execute_out_c : vec_execute_out_t :=(
    alu_result        => dflt_vec_data_c,
    dat_d             => dflt_vec_data_c,
    ctrl_mem          => dflt_ctrl_vec_memory_c,
    ctrl_wrb          => dflt_vec_forward_c
  );

  type execute_in_t is record
    reg_a             : std_ulogic_vector(CFG_GPRF_SIZE-1  downto 0);
    dat_a             : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    reg_b             : std_ulogic_vector(CFG_GPRF_SIZE-1  downto 0);
    dat_b             : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);  
    dat_d             : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    imm               : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    pc                : std_ulogic_vector(CFG_IMEM_SIZE-1  downto 0);
    fwd_dec           : forward_t;
    fwd_dec_result    : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    fwd_mem           : forward_t;
    ctrl_ex           : ctrl_execution_t;
    ctrl_mem          : ctrl_memory_t;
    ctrl_wrb          : forward_t;
    ctrl_mem_wrb      : ctrl_memory_writeback_t;
    mem_result        : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    alu_result        : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
  end record execute_in_t;
  
  type vec_execute_in_t is record
    reg_a             : std_ulogic_vector(CFG_VREG_SIZE-1  downto 0);
    dat_a             : vec_data_t;
    reg_b             : std_ulogic_vector(CFG_VREG_SIZE-1  downto 0);
    dat_b             : vec_data_t;
    dat_d             : vec_data_t; 
    imm               : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    fwd_dec           : vec_forward_t;
    fwd_dec_result    : vec_data_t;
    fwd_mem           : vec_forward_t;
    ctrl_ex           : ctrl_vec_execution_t;
    ctrl_mem          : ctrl_vec_memory_t;
    ctrl_wrb          : vec_forward_t;
    ctrl_mem_wrb      : ctrl_vec_memory_writeback_t;
    mem_result        : vec_data_t;
    alu_result        : vec_data_t;
    flush             : std_ulogic;
  end record vec_execute_in_t;
  
  type scu_mem_in_t is record
    dat_d             : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    alu_result        : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    mem_addr          : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    mem_result        : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    pc                : std_ulogic_vector(CFG_IMEM_SIZE-1  downto 0);
    branch            : std_ulogic;
    ctrl_mem          : ctrl_memory_t;
    ctrl_wrb          : forward_t;
  end record scu_mem_in_t;
  
  type vec_mem_in_t is record
    dat_d             : vec_data_t;
    alu_result        : vec_data_t;
    mem_result        : vec_data_t;
    ctrl_mem          : ctrl_vec_memory_t;
    ctrl_wrb          : vec_forward_t;
  end record vec_mem_in_t;
  
  type mem_in_t is record
    scu               : scu_mem_in_t;
    simd              : vec_mem_in_t;
  end record mem_in_t;

  type scu_mem_out_t is record
    alu_result        : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    ctrl_wrb          : forward_t;
    ctrl_mem_wrb      : ctrl_memory_writeback_t;
  end record scu_mem_out_t;
  constant dflt_scu_mem_out_c : scu_mem_out_t :=(
    alu_result        => (others=>'0'),
    ctrl_wrb          => dflt_forward_c,
    ctrl_mem_wrb      => dflt_ctrl_memory_writeback_c
  );
  
  type vec_mem_out_t is record
    alu_result        : vec_data_t;
    ctrl_wrb          : vec_forward_t;
    ctrl_mem_wrb      : ctrl_vec_memory_writeback_t;
  end record vec_mem_out_t;
  constant dflt_vec_mem_out_c : vec_mem_out_t :=(
    alu_result        => dflt_vec_data_c,
    ctrl_wrb          => dflt_vec_forward_c,
    ctrl_mem_wrb      => dflt_ctrl_vec_memory_writeback_c
  );
  
  type mem_out_t is record
    scu               : scu_mem_out_t;
    simd              : vec_mem_out_t;
  end record mem_out_t;
  constant dflt_mem_out_c : mem_out_t :=(
    scu               => dflt_scu_mem_out_c,
    simd              => dflt_vec_mem_out_c
  );

  type scu_dmem_in_t is record
    dat               : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
  end record scu_dmem_in_t;
  
  type vec_dmem_in_t is record
    dat               : vec_data_t;
  end record vec_dmem_in_t;
  constant dflt_vec_dmem_in_c : vec_dmem_in_t :=(
    dat               => dflt_vec_data_c
  );
  
  type dmem_in_t is record
    scu               : scu_dmem_in_t;
    simd              : vec_dmem_in_t;
  end record dmem_in_t;

  type scu_dmem_out_t is record
    dat               : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    adr               : std_ulogic_vector(CFG_DMEM_SIZE-1  downto 0);
    sel               : std_ulogic_vector(3 downto 0);
    we                : std_ulogic;
    ena               : std_ulogic;
  end record scu_dmem_out_t;
  constant dflt_scu_dmem_out_c : scu_dmem_out_t :=(
    dat               => (others=>'0'),
    adr               => (others=>'0'),
    sel               => (others=>'0'),
    we                => '0',
    ena               => '0'
  );
  
  type vec_dmem_out_t is record
    dat               : vec_data_t;
    adr               : std_ulogic_vector(CFG_VDMEM_SIZE-1 downto 0);
    sel               : std_ulogic_vector(1 downto 0);
    we                : std_ulogic;
    ena               : std_ulogic;
  end record vec_dmem_out_t;
  constant dflt_vec_dmem_out_c : vec_dmem_out_t :=(
    dat               => dflt_vec_data_c,
    adr               => (others=>'0'),
    sel               => (others=>'0'),
    we                => '0',
    ena               => '0'
  );
  
  type dmem_out_t is record
    scu              : scu_dmem_out_t;
    simd             : vec_dmem_out_t;
  end record dmem_out_t;
  constant dflt_dmem_out_c : dmem_out_t :=(
    scu              => dflt_scu_dmem_out_c,
    simd             => dflt_vec_dmem_out_c
  );
  
  type dmem_in_array_t is array(natural range <>) of dmem_in_t;
  type dmem_out_array_t is array(natural range <>) of dmem_out_t;
  
  type mul32_in_t is record
    op_a   : std_ulogic_vector(31 downto 0);
    op_b   : std_ulogic_vector(31 downto 0);
    sign   : simd_data_t;
    start  : std_ulogic;
    mac    : std_ulogic;
    op     : simd_addsub_t;
    long   : std_ulogic;
    acc    : std_ulogic_vector(63 downto 0);
  end record mul32_in_t;

  type mul32_flags_t is record
    byte   : std_ulogic;
    word   : std_ulogic;
    double : std_ulogic;
  end record mul32_flags_t;
  constant dflt_mul32_flags_c : mul32_flags_t :=(
    byte   => '0',
    word   => '0',
    double => '0'
  );
  
  type mul32_out_t is record
    valid  : std_ulogic;
    ovflw  : mul32_flags_t;
    result : std_ulogic_vector(63 downto 0);
  end record;
  
  type simd_mul_in_t is record
    size     : simd_size_t;
    dt       : simd_data_t;
    mac      : std_ulogic;
    op       : simd_addsub_t;
    long     : std_ulogic;
    op_a     : vec_data_t;
    op_b     : vec_data_t;
    op_c     : vec_data_t;
  end record simd_mul_in_t;
  
  type simd_mul_out_t is record
    result   : vec_data_t;
  end record simd_mul_out_t;

  -----------------------------------------------------------------------------
  -- fnction definition part
  -----------------------------------------------------------------------------
  function select_register_data (reg_dat, reg, wb_dat : std_ulogic_vector; write : std_ulogic) return std_ulogic_vector;
  function sel_vecreg_data (reg_dat : vec_data_t; reg : std_ulogic_vector; wb_dat : vec_data_t; write : std_ulogic) return vec_data_t;
  function fwd_cond (reg_write : std_ulogic; reg_a, reg_d : std_ulogic_vector) return std_ulogic;
  function align_mem_load (data : std_ulogic_vector; size : transfer_size_t; address : std_ulogic_vector) return std_ulogic_vector;
  function align_mem_store (data : std_ulogic_vector; size : transfer_size_t) return std_ulogic_vector;
  function decode_mem_store (address : std_ulogic_vector(1 downto 0); size : transfer_size_t) return std_ulogic_vector;
  function align_vec_load(data : vec_data_t; size : std_ulogic_vector(1 downto 0)) return vec_data_t;
  function align_vec_store(data : vec_data_t; size : std_ulogic_vector(1 downto 0)) return vec_data_t;
  function decode_vreg_wb(wide : std_ulogic; reg : std_ulogic) return std_ulogic_vector;
  function expand_imm(cmode : std_ulogic_vector(3 downto 0); op : std_ulogic; imm8 : std_ulogic_vector(7 downto 0)) return std_ulogic_vector;
  function align_adr(adr : std_logic_vector(CFG_IMEM_SIZE-1 downto 0); target_width : positive; granularity : transfer_size_t) return std_ulogic_vector;

end package core_pkg;

package body core_pkg is
  ------------------------------------------------------------------------------
  -- This function select the register value:
  --   A) zero
  --   B) bypass value read from register file
  --   C) value from register file
  ------------------------------------------------------------------------------
  function select_register_data (reg_dat, reg, wb_dat : std_ulogic_vector; write : std_ulogic) return std_ulogic_vector is
    variable tmp : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
  begin
    if(CFG_REG_FORCE_ZERO = true and is_zero(reg) = '1') then
      tmp := (others => '0');
    elsif(CFG_REG_FWD_WRB = true and write = '1') then
      tmp := wb_dat;
    else
      tmp := reg_dat;
    end if;
      return tmp;
  end function select_register_data;
  
  ---------------------------------------------------------------------------
  -- Same as select_register_data but for vector registers
  ---------------------------------------------------------------------------
  function sel_vecreg_data(reg_dat: vec_data_t; reg : std_ulogic_vector; wb_dat : vec_data_t; write : std_ulogic) return vec_data_t is
    variable tmp : vec_data_t;
  begin
    --if(CFG_REG_FORCE_ZERO = true and is_zero(reg) = '1') then
    --  tmp := dflt_vec_data_c;
    if(CFG_REG_FWD_WRB = true and write = '1') then
      tmp := wb_dat;
    else
      tmp := reg_dat;
    end if;
      return tmp;
  end function sel_vecreg_data;  
  
  ------------------------------------------------------------------------------
  -- This function checks if a forwarding condition is met. The condition is met 
  -- of register A and D match
  -- and the signal needs to be written back to the register file
  ------------------------------------------------------------------------------
  function fwd_cond (reg_write : std_ulogic; reg_a, reg_d : std_ulogic_vector ) return std_ulogic is
  begin
    return reg_write and compare(reg_a, reg_d);
  end function fwd_cond;

  ------------------------------------------------------------------------------
  -- This function aligns the memory load operation (Big endian decoding)
  ------------------------------------------------------------------------------
  function align_mem_load (data : std_ulogic_vector; size : transfer_size_t; address : std_ulogic_vector ) return std_ulogic_vector is
  begin
    case size is
      when byte => 
        case address(1 downto 0) is
          when "00"   => return C_24_ZEROS & data(31 downto 24);
          when "01"   => return C_24_ZEROS & data(23 downto 16);
          when "10"   => return C_24_ZEROS & data(15 downto  8);
          when "11"   => return C_24_ZEROS & data( 7 downto  0);
          when others => return C_32_ZEROS;
        end case;
      when halfword => 
        case address(1 downto 0) is
          when "00"   => return C_16_ZEROS & data(31 downto 16);
          when "10"   => return C_16_ZEROS & data(15 downto  0);
          when others => return C_32_ZEROS;
        end case;
      when others =>
        return data;
    end case;
  end function align_mem_load;

  ---------------------------------------------------------------------------------
  -- This function repeats the operand to all positions in a memory store operation
  ---------------------------------------------------------------------------------
  function align_mem_store (data : std_ulogic_vector; size : transfer_size_t) return std_ulogic_vector is
  begin
    case size is
      when byte     => return data( 7 downto 0) & data( 7 downto 0) & data(7 downto 0) & data(7 downto 0);
      when halfword => return data(15 downto 0) & data(15 downto 0);
      when others   => return data;
    end case;
  end function align_mem_store;

  ----------------------------------------------------------------------------------
  -- This function selects the correct bytes for memory writes (Big endian encoding)
  ----------------------------------------------------------------------------------
  function decode_mem_store (address : std_ulogic_vector(1 downto 0); size : transfer_size_t) return std_ulogic_vector is
  begin
    case size is
      when BYTE =>
        case address is
          when "00"   => return "1000";
          when "01"   => return "0100";
          when "10"   => return "0010";
          when "11"   => return "0001";
          when others => return "0000";
        end case;
      when HALFWORD =>
        case address is
          -- Big endian encoding
          when "10"   => return "0011";
          when "00"   => return "1100";
          when others => return "0000";
        end case;
      when others =>
        return "1111";
    end case;
  end function decode_mem_store;

  ------------------------------------------------------------------------------
  -- This function aligns the memory vector load operation (WIDE vs. NARROW)
  ------------------------------------------------------------------------------
  function align_vec_load(data : vec_data_t; size : std_ulogic_vector(1 downto 0)) return vec_data_t is
    variable result : vec_data_t;
  begin
    if(size = "11") then
      result   := data;
    elsif(size = "01") then
      result   := data(vec_low) & data(vec_low);
    else
      result   := data(vec_high) & data(vec_high);
    end if;
    return result;
  end function align_vec_load;

  ------------------------------------------------------------------------------
  -- This function repeats the operand in a vector store operation
  ------------------------------------------------------------------------------
  function align_vec_store(data : vec_data_t; size : std_ulogic_vector(1 downto 0)) return vec_data_t is
    variable result : vec_data_t;
  begin
    if(size = "11") then
      result := data;
    elsif(size = "01") then
      result := data(vec_low) & data(vec_low);
    else
      result := data(vec_high) & data(vec_high);
    end if;
    return result;
  end function align_vec_store;

  ------------------------------------------------------------------------------
  -- This function decodes reg writeback flag
  ------------------------------------------------------------------------------
  function decode_vreg_wb(wide : std_ulogic; reg : std_ulogic) return std_ulogic_vector is
    variable result : std_ulogic_vector(1 downto 0);
  begin
    result(0) := wide or not reg;
    result(1) := wide or reg;
    return result;
  end function decode_vreg_wb;

  ------------------------------------------------------------------------------
  -- expand simmediate
  ------------------------------------------------------------------------------
  function expand_imm(cmode : std_ulogic_vector(3 downto 0); op : std_ulogic; imm8 : std_ulogic_vector(7 downto 0)) return std_ulogic_vector is
    variable result : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
  begin
    result := (others=>'0');
    case(cmode(3 downto 1)) is
      when "000"  => result   := x"000000" & imm8;
      when "001"  => result   := x"0000"   & imm8 & x"00";
      when "010"  => result   := x"00"     & imm8 & x"0000";
      when "011"  => result   := imm8 & x"000000";
      when "100"  => result   := x"00" & imm8 & x"00" & imm8;
      when "101"  => result   := imm8 & x"00" & imm8 & x"00";
      when "110"  => if(cmode(0) = '0') then
                       result := x"0000" & imm8 & x"11";
                     else
                       result := x"11" & imm8 & x"0000";
                     end if;
      when "111"  => if(cmode(0) = '0' and op = '0') then
                       result := imm8 & imm8 & imm8 & imm8;
                     elsif(cmode(0) = '0' and op = '1') then
                       result := imm8(7) & imm8(7) & imm8(7) & imm8(7) &
                                 imm8(6) & imm8(6) & imm8(6) & imm8(6) &
                                 imm8(5) & imm8(5) & imm8(5) & imm8(5) &
                                 imm8(4) & imm8(4) & imm8(4) & imm8(4) &
                                 imm8(3) & imm8(3) & imm8(3) & imm8(3) &
                                 imm8(2) & imm8(2) & imm8(2) & imm8(2) &
                                 imm8(1) & imm8(1) & imm8(1) & imm8(1) &
                                 imm8(0) & imm8(0) & imm8(0) & imm8(0);
                      end if;
      when others => null;
    end case;
    return result;
  end function expand_imm;

  -----------------------------------------------------------------------------
  -- align address to adapt to word or halfword granular interface
  -----------------------------------------------------------------------------
  function align_adr(adr : std_ulogic_vector(CFG_IMEM_SIZE-1 downto 0); target_width : positive; granularity : transfer_size_t) return std_ulogic_vector is
    variable result : std_ulogic_vector(CFG_IMEM_SIZE-1 downto 0);
  begin
    result := (others=>'0');
    case granularity is
      when BYTE     => result(adr'length-1-0 downto 0) := adr;
      when HALFWORD => result(adr'length-1-1 downto 0) := adr(adr'left downto 1); 
      when WORD     => result(adr'length-1-2 downto 0) := adr(adr'left downto 2);
      when others   => null;
    end case;
    return std_ulogic_vector(resize(unsigned(result), target_width));
  end function align_adr;

end package body core_pkg;

