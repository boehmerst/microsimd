library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.core_pkg.all;
use work.inst_pkg.all;
use work.func_pkg.all;
use work.vec_data_pkg.all;

entity decode is
  generic (
    use_barrel_g : boolean;
    use_hw_mul_g : boolean;
    use_fsl_g    : boolean;
    use_irq_g    : boolean;
    use_dbg_g    : boolean;
    use_custom_g : boolean;
    mci_custom_g : boolean;
    irq_vec_g    : std_ulogic_vector(CFG_IMEM_SIZE-1 downto 0)
  );
  port (
    clk_i        : in  std_ulogic;
    reset_n_i    : in  std_ulogic;
    init_i       : in  std_ulogic;
    en_i         : in  std_ulogic;
    decode_i     : in  decode_in_t;
    decode_o     : out decode_out_t;
    gprf_o       : out gprf_out_t;
    vecrf_o      : out vecrf_out_t
  );
end entity decode;

architecture rtl of decode is

  constant reg_zero_c         : std_ulogic_vector(CFG_GPRF_SIZE-1 downto 0)              := (others=>'0');
  constant reg_irq_ret_addr_c : std_ulogic_vector(CFG_GPRF_SIZE-1 downto 0)              := "01110";
  constant addr_ext_c         : std_ulogic_vector(log2ceil(CFG_DMEM_WIDTH/8)-1 downto 0) := (others=>'0');

  type reg_t is record
    decode         : decode_out_t;
    pc             : std_ulogic_vector(CFG_IMEM_SIZE-1 downto 0);
    inst           : std_ulogic_vector(CFG_IMEM_WIDTH-1 downto 0);
    start          : std_ulogic;
    irq            : std_ulogic;
    irq_en         : std_ulogic;
    irq_delay      : std_ulogic;
    immediate      : std_ulogic_vector(15 downto 0);
    is_immediate   : std_ulogic;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    decode         => dflt_decode_out_c,
    pc             => (others=>'0'),
    inst           => (others=>'0'),
    start          => '0',
    irq            => '0',
    irq_en         => '1',
    irq_delay      => '0',
    immediate      => (others=>'0'),
    is_immediate   => '0'
  );

  signal gprf         : gprf_in_t;
  signal vecrf        : vecrf_in_t;

  signal wb_dat_d     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0); 
  signal wb_vec_dat_d : vec_data_t; 
  signal r, rin       : reg_t;
  
begin
  ------------------------------------------------------------------------------
  -- Scalar Unit Register File
  ------------------------------------------------------------------------------
  gprf.ena   <= en_i;
  gprf.adr_a <= rin.decode.scu.reg_a;
  gprf.adr_b <= rin.decode.scu.reg_b;
  gprf.adr_d <= rin.decode.scu.ctrl_wrb.reg_d;
  gprf.dat_w <= wb_dat_d;
  gprf.adr_w <= decode_i.scu.ctrl_wrb.reg_d;
  gprf.wre   <= decode_i.scu.ctrl_wrb.reg_write;

  gprf0 : entity work.gprf
    generic map (
      dmem_width_g     => CFG_DMEM_WIDTH,
      gprf_size_g      => CFG_GPRF_SIZE
    )
    port map (
      clk_i  => clk_i,
      gprf_o => gprf_o,
      gprf_i => gprf
    );
    
  ------------------------------------------------------------------------------
  -- SIMD unit Register File
  ------------------------------------------------------------------------------
  vecrf.ena   <= en_i;
  vecrf.adr_a <= rin.decode.simd.reg_a;
  vecrf.adr_b <= rin.decode.simd.reg_b;
  vecrf.adr_d <= rin.decode.simd.ctrl_wrb.reg_d;
  vecrf.dat_w <= wb_vec_dat_d;
  vecrf.adr_w <= decode_i.simd.ctrl_wrb.reg_d;
  vecrf.wre   <= decode_i.simd.ctrl_wrb.reg_write;  

  vecrf0: entity work.vecrf
    generic map(
      dmem_width_g    => CFG_DMEM_WIDTH,
      vreg_slc_g      => CFG_VREG_SLICES,
      vreg_size_g     => CFG_VREG_SIZE
    )
    port map (
      clk_i   => clk_i,
      vecrf_o => vecrf_o,
      vecrf_i => vecrf
    );    
    
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, decode_i) is
    variable v                : reg_t;
    variable wb_result        : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    variable wb_vec_result    : vec_data_t;
    variable instruction      : std_ulogic_vector(CFG_IMEM_WIDTH-1 downto 0);
    variable spec_instruction : std_ulogic_vector(CFG_IMEM_WIDTH-1 downto 0);
    variable is_vec_reg_a     : std_ulogic;
    variable is_vec_reg_b     : std_ulogic;
    variable is_vec_reg_d     : std_ulogic;
    variable pc               : std_ulogic_vector(CFG_IMEM_SIZE-1  downto 0);
    variable reg_a            : std_ulogic_vector(CFG_GPRF_SIZE-1  downto 0);
    variable reg_b            : std_ulogic_vector(CFG_GPRF_SIZE-1  downto 0);
    variable reg_d            : std_ulogic_vector(CFG_GPRF_SIZE-1  downto 0);
    variable vec_reg_a        : std_ulogic_vector(CFG_VREG_SIZE    downto 0);
    variable vec_reg_b        : std_ulogic_vector(CFG_VREG_SIZE    downto 0);
    variable vec_reg_d        : std_ulogic_vector(CFG_VREG_SIZE    downto 0);   
    variable vec_reg_a_even   : std_ulogic;
    variable vec_reg_b_even   : std_ulogic;
    variable vec_reg_d_even   : std_ulogic;  
    variable opcode           : std_ulogic_vector(5 downto 0);
    variable vec_opcode       : vinst_fields_t;
  begin
    v       := r;
    v.start := '1';
    
    ----------------------------------------------------------------------------
    -- register if an interrupt occurs
    ----------------------------------------------------------------------------
    if(use_irq_g = true) then
      v.irq_delay := '0';
    end if;
    
    if(use_irq_g = true) then
      if(r.irq_en = '1' and decode_i.scu.irq = '1') then
        v.irq    := '1';
        v.irq_en := '0';
      end if;
    end if;
    
    ----------------------------------------------------------------------------
    -- latch instruction
    ----------------------------------------------------------------------------
    v.pc                         := decode_i.scu.pc;
    v.inst                       := decode_i.scu.inst;
    
    ----------------------------------------------------------------------------
    -- clear immediate
    ----------------------------------------------------------------------------
    v.is_immediate               := '0';
    v.immediate                  := (others=>'0');
    
    ----------------------------------------------------------------------------
    -- write-back logic regfiles
    ----------------------------------------------------------------------------
    if(decode_i.scu.ctrl_mem_wrb.mem_read = '1') then
      wb_result                  := align_mem_load(decode_i.scu.mem_result, decode_i.scu.ctrl_mem_wrb.transfer_size, decode_i.scu.alu_result(1 downto 0));
    else
      wb_result                  := decode_i.scu.alu_result;
    end if;

    if(decode_i.simd.ctrl_mem_wrb.mem_read = '1') then
      wb_vec_result              := decode_i.simd.mem_result;
    else
      wb_vec_result              := decode_i.simd.alu_result;
    end if;
    
    ----------------------------------------------------------------------------
    -- forward logic
    ----------------------------------------------------------------------------
    if(CFG_REG_FWD_WRB = true) then
      v.decode.scu.fwd_dec_result     := wb_result;
      v.decode.scu.fwd_dec            := decode_i.scu.ctrl_wrb;

      v.decode.simd.fwd_dec_result    := wb_vec_result;
      v.decode.simd.fwd_dec           := decode_i.simd.ctrl_wrb;
    else
      v.decode.scu.fwd_dec_result     := (others=>'0');
      v.decode.scu.fwd_dec.reg_d      := (others=>'0');
      v.decode.scu.fwd_dec.reg_write  := '0';

      v.decode.simd.fwd_dec_result    := (others=>(others=>'0'));
      v.decode.simd.fwd_dec.reg_d     := (others=>'0');
      v.decode.simd.fwd_dec.reg_write := (others=>'0');
    end if;
    
    ----------------------------------------------------------------------------
    -- speculative register decoding for hazard processing
    ----------------------------------------------------------------------------
    reg_a       := get_inst(decode_i.scu.inst).source.reg_a;
    reg_b       := get_inst(decode_i.scu.inst).source.reg_b;
    reg_d       := get_inst(decode_i.scu.inst).destin.reg_d;
    
    if((compare(get_inst(decode_i.scu.inst).opcode, "010111") and 
        compare(decode_i.scu.inst(25 downto 24), class_simd_trans_c) and 
        compare(decode_i.scu.inst(9 downto 8), "00")) = '1') then
      reg_a     := get_vinst(decode_i.scu.inst).source.reg_a;
    elsif((compare(get_inst(decode_i.scu.inst).opcode, "010111") and 
           compare(decode_i.scu.inst(25 downto 24), class_simd_ldst_c)) = '1') then
      reg_a     := get_vinst(decode_i.scu.inst).source.reg_a;
    end if;
      
    vec_reg_a   := get_vinst(decode_i.scu.inst).source.reg_a;
    vec_reg_b   := get_vinst(decode_i.scu.inst).source.reg_b;
    vec_reg_d   := get_vinst(decode_i.scu.inst).destin.reg_d;

    ----------------------------------------------------------------------------
    -- speculative decode vector instruction type for hazard processing
    -- TODO: fill with life to avoid unwanted stalls
    ----------------------------------------------------------------------------
    is_vec_reg_a := '1'; is_vec_reg_b := '1'; is_vec_reg_d := '1';
    
    ----------------------------------------------------------------------------
    -- hazard processing
    -- NOTE: is over pessimistic for vector hazards (NARROW not considered yet)
    ----------------------------------------------------------------------------
    if((not decode_i.scu.flush_id and r.decode.scu.ctrl_mem.mem_read and (compare(reg_a, r.decode.scu.ctrl_wrb.reg_d) or compare(reg_b, r.decode.scu.ctrl_wrb.reg_d))) = '1') then
      pc                    := (others => '0');    
      instruction           := (others => '0');
      v.decode.scu.hazard   := '1';
    elsif((not decode_i.scu.flush_id and r.decode.simd.ctrl_mem.mem_read and 
         ((is_vec_reg_a and compare(vec_reg_a(vec_reg_a'left downto 1), r.decode.simd.ctrl_wrb.reg_d)) or 
          (is_vec_reg_b and compare(vec_reg_b(vec_reg_b'left downto 1), r.decode.simd.ctrl_wrb.reg_d)))) = '1' ) then
      pc                    := (others => '0');
      instruction           := (others => '0');
      v.decode.scu.hazard   := '1';
    elsif(CFG_MEM_FWD_WRB = false and (not decode_i.scu.flush_id and r.decode.scu.ctrl_mem.mem_read and compare(reg_d, r.decode.scu.ctrl_wrb.reg_d)) = '1') then
      pc                    := (others => '0');    
      instruction           := (others => '0');
      v.decode.scu.hazard   := '1';
    elsif((not decode_i.scu.flush_id and r.decode.simd.ctrl_mem.mem_read and is_vec_reg_d and compare(vec_reg_d(vec_reg_d'left downto 1), r.decode.simd.ctrl_wrb.reg_d)) = '1') then
      pc                    := (others => '0');    
      instruction           := (others => '0');
      v.decode.scu.hazard   := '1';
    elsif(r.decode.scu.stall = '1') then
      pc                    := r.pc;
      instruction           := r.inst;
      v.decode.scu.stall    := '0';
    elsif(r.decode.scu.hazard = '1') then
      pc                    := r.pc;
      instruction           := r.inst;
      v.decode.scu.hazard   := '0';
    else
      pc                    := decode_i.scu.pc;
      instruction           := decode_i.scu.inst;
      v.decode.scu.hazard   := '0';
    end if;
    
    ----------------------------------------------------------------------------
    -- default assignment for scalar unit
    ----------------------------------------------------------------------------
    v.decode.scu.pc                 := pc;
    v.decode.scu.ctrl_wrb.reg_d     := get_inst(instruction).destin.reg_d;
    v.decode.scu.reg_a              := get_inst(instruction).source.reg_a;
    v.decode.scu.reg_b              := get_inst(instruction).source.reg_b;
    
    if(r.is_immediate = '1') then
      v.decode.scu.imm              := r.immediate & get_inst(instruction).imm;
    else
      v.decode.scu.imm              := std_ulogic_vector(resize(signed(get_inst(instruction).imm), v.decode.scu.imm'length));
    end if;
    
    v.decode.scu.ctrl_ex            := dflt_ctrl_execution_c;
    v.decode.scu.ctrl_mem           := dflt_ctrl_memory_c;
    v.decode.scu.ctrl_wrb.reg_write := '0';
    
    opcode                          := get_inst(instruction).opcode;
    
    ----------------------------------------------------------------------------
    -- default assignment for vector unit
    ----------------------------------------------------------------------------
    v.decode.simd.ctrl_wrb.reg_d     := get_vinst(instruction).destin.reg_d(CFG_VREG_SIZE downto 1);
    v.decode.simd.reg_a              := get_vinst(instruction).source.reg_a(CFG_VREG_SIZE downto 1);
    v.decode.simd.reg_b              := get_vinst(instruction).source.reg_b(CFG_VREG_SIZE downto 1);
    
    vec_reg_a_even                   := get_vinst(instruction).source.reg_a(0);
    vec_reg_b_even                   := get_vinst(instruction).source.reg_b(0);
    vec_reg_d_even                   := get_vinst(instruction).destin.reg_d(0);
    
    v.decode.simd.ctrl_ex            := dflt_ctrl_vec_execution_c;
    v.decode.simd.ctrl_mem           := dflt_ctrl_vec_memory_c;
    v.decode.simd.ctrl_wrb.reg_write := "00";

    vec_opcode                       := get_vinst(instruction).fields;
    
    if(r.start = '0') then
      --------------------------------------------------------------------------
      -- supress decoding of imem during the very first fetch phase
      --------------------------------------------------------------------------
      v.decode.scu                     := dflt_decode_out_c.scu;
    elsif(use_irq_g = true and (v.irq = '1' and r.irq_delay = '0' and decode_i.scu.flush_id = '0' and v.decode.scu.hazard = '0' and r.decode.scu.ctrl_ex.delay = '0' and r.is_immediate = '0')) then
      --------------------------------------------------------------------------
      -- interrupt processing
      --------------------------------------------------------------------------
      v.irq                            := '0';
      v.decode.scu.reg_a               := (others=>'0');
      v.decode.scu.reg_b               := (others=>'0');
      v.decode.scu.imm                 := std_ulogic_vector(resize(unsigned(irq_vec_g), v.decode.scu.imm'length));
      v.decode.scu.ctrl_wrb.reg_d      := reg_irq_ret_addr_c;
      v.decode.scu.ctrl_ex.branch_cond := BNC;
      v.decode.scu.ctrl_ex.alu_src_a   := ALU_SRC_REGA;
      v.decode.scu.ctrl_ex.alu_src_b   := ALU_SRC_IMM;
      v.decode.scu.ctrl_wrb.reg_write  := '1';
      
    elsif(decode_i.scu.flush_id = '1' or v.decode.scu.hazard = '1') then
      --------------------------------------------------------------------------
      -- hazard or flush_id (just to ease debugging remove to save logic)
      --------------------------------------------------------------------------
      if(use_dbg_g = true) then
        v.decode.scu.pc                := (others=>'0');
        v.decode.scu.ctrl_wrb.reg_d    := (others=>'0');
        v.decode.scu.reg_a             := (others=>'0');
        v.decode.scu.reg_b             := (others=>'0');
        v.decode.scu.imm               := (others=>'0');
        
        v.decode.simd.ctrl_wrb.reg_d   := (others=>'0');
        v.decode.simd.reg_a            := (others=>'0');
        v.decode.simd.reg_b            := (others=>'0');
        v.decode.simd.imm              := (others=>'0');
      end if;
      
    elsif is_zero(opcode(5 downto 4)) = '1' then
      --------------------------------------------------------------------------
      -- ADD, SUB, COMP
      --------------------------------------------------------------------------
      v.decode.scu.ctrl_ex.alu_op := ALU_ADD;

      -- source operand a
      if(opcode(0) = '1') then
        v.decode.scu.ctrl_ex.alu_src_a := ALU_SRC_NOT_REGA;
      else
        v.decode.scu.ctrl_ex.alu_src_a := ALU_SRC_REGA;
      end if;

      -- source operand b
      if(opcode(3) = '1') then
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_IMM;
      else
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_REGB;
      end if;

      if((compare(opcode, "000101") and instruction(1)) = '1') then
        v.decode.scu.ctrl_ex.operation := '1';
      end if;

      -- carry
      case opcode(1 downto 0) is
        when "00"   => v.decode.scu.ctrl_ex.carry := CARRY_ZERO;
        when "01"   => v.decode.scu.ctrl_ex.carry := CARRY_ONE;
        when others => v.decode.scu.ctrl_ex.carry := CARRY_ALU;
      end case;

      -- carry keep
      if(opcode(2) = '1') then
        v.decode.scu.ctrl_ex.carry_keep := CARRY_KEEP;
      else
        v.decode.scu.ctrl_ex.carry_keep := CARRY_NOT_KEEP;
      end if;

      -- flag writeback if reg_d != 0
      v.decode.scu.ctrl_wrb.reg_write   := is_not_zero(v.decode.scu.ctrl_wrb.reg_d);
      
    elsif((compare(opcode(5 downto 2), "1000") or compare(opcode(5 downto 2), "1010")) = '1') then
      --------------------------------------------------------------------------
      -- TODO: pattern compare would accidentely be decoded here also!
      -- OR, AND, XOR, ANDN, ORI, ANDI, XORI, ANDNI
      --------------------------------------------------------------------------
      case opcode(1 downto 0) is
        when "00"   => v.decode.scu.ctrl_ex.alu_op := ALU_OR;
        when "10"   => v.decode.scu.ctrl_ex.alu_op := ALU_XOR;
        when others => v.decode.scu.ctrl_ex.alu_op := ALU_AND;
      end case;

      if(opcode(3) = '1' and compare(opcode(1 downto 0), "11") = '1') then
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_NOT_IMM;
      elsif(opcode(3) = '1') then
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_IMM;
      elsif(opcode(3) = '0' and compare(opcode(1 downto 0), "11") = '1') then
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_NOT_REGB;
      else
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_REGB;
      end if;

      -- flag writeback if reg_d != 0
      v.decode.scu.ctrl_wrb.reg_write := is_not_zero(v.decode.scu.ctrl_wrb.reg_d);
      
    elsif(compare(opcode, "101100") = '1') then
      --------------------------------------------------------------------------
      -- IMM instruction
      --------------------------------------------------------------------------
      v.immediate    := get_inst(instruction).imm;
      v.is_immediate := '1';      

    elsif compare(opcode, "100100") = '1' then
      --------------------------------------------------------------------------
      -- TODO: CLZ inst would accidentely be interpreted as SIGN EXTEND
      -- TODO: WIC, WID would also
      -- SHIFT, SIGN EXTEND
      --------------------------------------------------------------------------
      if(compare(instruction(6 downto 5), "11") = '1') then
        if(instruction(0) = '1') then
          v.decode.scu.ctrl_ex.alu_op   := ALU_SEXT16;
        else
          v.decode.scu.ctrl_ex.alu_op   := ALU_SEXT8;
        end if;
      else
        v.decode.scu.ctrl_ex.alu_op     := ALU_SHIFT;
        v.decode.scu.ctrl_ex.carry_keep := CARRY_NOT_KEEP;
        
        case instruction(6 downto 5) is
          when "10"   => v.decode.scu.ctrl_ex.carry := CARRY_ZERO;
          when "01"   => v.decode.scu.ctrl_ex.carry := CARRY_ALU;
          when others => v.decode.scu.ctrl_ex.carry := CARRY_ARITH;
        end case;
      end if;

      -- flag writeback if reg_d != 0
      v.decode.scu.ctrl_wrb.reg_write := is_not_zero(v.decode.scu.ctrl_wrb.reg_d);

    elsif((compare(opcode, "100110") or compare(opcode, "101110")) = '1') then
      --------------------------------------------------------------------------
      -- BRANCH UNCONDITIONAL
      --------------------------------------------------------------------------
      v.decode.scu.ctrl_ex.branch_cond := BNC;

      if(opcode(3) = '1') then
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_IMM;
      else
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_REGB;
      end if;

      -- in case of branch and link write the result to reg_d also
      if(v.decode.scu.reg_a(2) = '1') then
        -- flag writeback if reg_d != 0
        v.decode.scu.ctrl_wrb.reg_write := is_not_zero(v.decode.scu.ctrl_wrb.reg_d);
      end if;

      if(v.decode.scu.reg_a(3) = '1') then
        v.decode.scu.ctrl_ex.alu_src_a := ALU_SRC_ZERO;
      else
        v.decode.scu.ctrl_ex.alu_src_a := ALU_SRC_PC;
      end if;

      if(use_irq_g = true) then
        v.irq_delay := '1';
      end if;
        
      -- delays slot behaviour
      v.decode.scu.ctrl_ex.delay := v.decode.scu.reg_a(4);

    elsif((compare(opcode, "100111") or compare(opcode, "101111")) = '1') then
      --------------------------------------------------------------------------
      -- BRANCH CONDITIONAL
      --------------------------------------------------------------------------
      v.decode.scu.ctrl_ex.alu_op      := ALU_ADD;
      v.decode.scu.ctrl_ex.alu_src_a   := ALU_SRC_PC;

      if(opcode(3) = '1') then
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_IMM;
      else
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_REGB;
      end if;

      case v.decode.scu.ctrl_wrb.reg_d(2 downto 0) is
        when "000"  => v.decode.scu.ctrl_ex.branch_cond := BEQ;
        when "001"  => v.decode.scu.ctrl_ex.branch_cond := BNE;
        when "010"  => v.decode.scu.ctrl_ex.branch_cond := BLT;
        when "011"  => v.decode.scu.ctrl_ex.branch_cond := BLE;
        when "100"  => v.decode.scu.ctrl_ex.branch_cond := BGT;
        when others => v.decode.scu.ctrl_ex.branch_cond := BGE;
      end case;

      if(use_irq_g = true) then
        v.irq_delay := '1';
      end if;
        
      -- delay slot behaviour
      v.decode.scu.ctrl_ex.delay := v.decode.scu.ctrl_wrb.reg_d(4);

    elsif(compare(opcode, "101101") = '1') then
      --------------------------------------------------------------------------
      -- RETURN
      --------------------------------------------------------------------------
      v.decode.scu.ctrl_ex.branch_cond := BNC;
      v.decode.scu.ctrl_ex.alu_src_b   := ALU_SRC_IMM;
      v.decode.scu.ctrl_ex.delay       := '1';

      if(use_irq_g = true) then
        if(v.decode.scu.ctrl_wrb.reg_d(0) = '1') then
          v.irq_en      := '1';
        end if;
        v.irq_delay     := '1';
      end if;

    elsif(compare(opcode(5 downto 4), "11") = '1') then
      --------------------------------------------------------------------------
      -- SW, LW
      --------------------------------------------------------------------------
      v.decode.scu.ctrl_ex.alu_op       := ALU_ADD;
      v.decode.scu.ctrl_ex.alu_src_a    := ALU_SRC_REGA;

      if(opcode(3) = '1') then
        v.decode.scu.ctrl_ex.alu_src_b  := ALU_SRC_IMM;
      else
        v.decode.scu.ctrl_ex.alu_src_b  := ALU_SRC_REGB;
      end if;

      v.decode.scu.ctrl_ex.carry        := CARRY_ZERO;

      if(opcode(2) = '1')then
        -- store
        v.decode.scu.ctrl_mem.mem_write := '1';
        v.decode.scu.ctrl_mem.mem_read  := '0';
        v.decode.scu.ctrl_wrb.reg_write := '0';
      else
        -- load
        v.decode.scu.ctrl_mem.mem_write := '0';
        v.decode.scu.ctrl_mem.mem_read  := '1';
        v.decode.scu.ctrl_wrb.reg_write := is_not_zero(v.decode.scu.ctrl_wrb.reg_d);
      end if;

      case opcode(1 downto 0) is
        when "00"   => v.decode.scu.ctrl_mem.transfer_size := BYTE;
        when "01"   => v.decode.scu.ctrl_mem.transfer_size := HALFWORD;
        when others => v.decode.scu.ctrl_mem.transfer_size := WORD;
      end case;

    elsif(use_hw_mul_g = true and (compare(opcode, "010000") or compare(opcode, "011000")) = '1') then
      --------------------------------------------------------------------------
      -- MUL
      --------------------------------------------------------------------------
      v.decode.scu.ctrl_ex.alu_op      := ALU_MUL;

      if(opcode(3) = '1') then
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_IMM;
      else
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_REGB;
      end if;

      v.decode.scu.ctrl_wrb.reg_write  := is_not_zero(v.decode.scu.ctrl_wrb.reg_d);

    elsif(use_barrel_g = true and (compare(opcode, "010001") or compare(opcode, "011001")) = '1') then
      --------------------------------------------------------------------------
      -- barrel shift
      --------------------------------------------------------------------------
      v.decode.scu.ctrl_ex.alu_op      := ALU_BS;

      if(opcode(3) = '1') then
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_IMM;
      else
        v.decode.scu.ctrl_ex.alu_src_b := ALU_SRC_REGB;
      end if;

      v.decode.scu.ctrl_wrb.reg_write  := is_not_zero(v.decode.scu.ctrl_wrb.reg_d);
      
    elsif(compare(opcode, "100101") = '1') then
      --------------------------------------------------------------------------
      -- machine status register (MSRSET, MSRCLR)
      -- INFO: currently no machine status register implemented
      --------------------------------------------------------------------------
      null;
      
    elsif(use_fsl_g = true and compare(opcode, "011011") = '1') then
      --------------------------------------------------------------------------
      -- FSLx
      -------------------------------------------------------------------------- 
      v.decode.scu.ctrl_ex.alu_op        := ALU_FSL;
      v.decode.scu.ctrl_ex.fsl.blocking  := not instruction(14);
      v.decode.scu.ctrl_ex.fsl.ctrl      := instruction(13);
      v.decode.scu.ctrl_ex.fsl.link      := instruction(2 downto 0);
      
      if(v.decode.scu.ctrl_ex.fsl.blocking = '0') then
        v.decode.scu.ctrl_ex.carry_keep  := CARRY_NOT_KEEP;
      end if;
      
      if(instruction(15) = '1') then
        v.decode.scu.ctrl_ex.fsl.wr      := '1';
      else
        v.decode.scu.ctrl_ex.fsl.rd      := '1';
        v.decode.scu.ctrl_wrb.reg_write  := is_not_zero(v.decode.scu.ctrl_wrb.reg_d);
      end if;
      
      if(r.decode.scu.stall = '0') then
        v.decode.scu.stall               := '1';
      end if;
      
    elsif(compare(opcode, "010111") = '1') then
      if(get_vinst(instruction).class = class_simd_arith_c) then
        if(instruction(23) = '0') then 
          ----------------------------------------------------------------------
          -- three register of same length
          ----------------------------------------------------------------------
          v.decode.simd.ctrl_wrb.reg_write              := "11";
          
          if(vec_opcode.w = '0') then
            v.decode.simd.ctrl_wrb.reg_write            := vec_reg_d_even & not vec_reg_d_even;
            v.decode.simd.ctrl_ex.simd_src_a_sel        := vec_reg_a_even & not vec_reg_a_even;
            v.decode.simd.ctrl_ex.simd_src_b_sel        := vec_reg_b_even & not vec_reg_b_even;
          end if;
    
          if(compare(vec_opcode.f3xrsl.a, "1000") = '1') then
            --------------------------------------------------------------------
            -- VADD, VSUB
            --------------------------------------------------------------------
            case(vec_opcode.f3xrsl.c) is
              when "00"   => v.decode.simd.ctrl_ex.size := BYTE;
              when "01"   => v.decode.simd.ctrl_ex.size := WORD;
              when others => v.decode.simd.ctrl_ex.size := DOUBLE;
            end case;

            if(vec_opcode.u = '1') then
              v.decode.simd.ctrl_ex.simd_src_b          := SIMD_SRC_NOT_REGB;
              v.decode.simd.ctrl_ex.mode                := SUB;
            end if;

          elsif((compare(vec_opcode.f3xrsl.a, "0001") and vec_opcode.f3xrsl.b) = '1') then
            --------------------------------------------------------------------
            -- VAND, VANDN (VBIC), VOR, VORN, VOR, VXOR, VBSL, VBIT, VBIF
            --------------------------------------------------------------------
            if(vec_opcode.u = '0') then
              v.decode.simd.ctrl_ex.simd_op             := SIMD_AND;
              if(vec_opcode.f3xrsl.c(1) = '1') then
                v.decode.simd.ctrl_ex.simd_op           := SIMD_OR;
              end if;
              if(vec_opcode.f3xrsl.c(0) = '1') then
                v.decode.simd.ctrl_ex.simd_src_b        := SIMD_SRC_NOT_REGB;
              end if;
            else
              case(vec_opcode.f3xrsl.c) is
                when "00"   => v.decode.simd.ctrl_ex.simd_op := SIMD_XOR;
                when "01"   => v.decode.simd.ctrl_ex.simd_op := SIMD_BSL;
                when "10"   => v.decode.simd.ctrl_ex.simd_op := SIMD_BIT;
                when others => v.decode.simd.ctrl_ex.simd_op := SIMD_BIF;
              end case;
            end if;

          elsif((compare(vec_opcode.f3xrsl.a, "0000") or compare(vec_opcode.f3xrsl.a, "0010")) = '1') then
            --------------------------------------------------------------------
            -- VQADD, VQSUB
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.saturate              := '1';
            v.decode.simd.ctrl_ex.dt                    := S;
            v.decode.simd.ctrl_ex.res_dt                := S;
        
            if(vec_opcode.u = '1') then
              v.decode.simd.ctrl_ex.dt                  := U;
              v.decode.simd.ctrl_ex.res_dt              := U;
            end if;

            case(vec_opcode.f3xrsl.c) is
              when "00"   => v.decode.simd.ctrl_ex.size := BYTE;
              when "01"   => v.decode.simd.ctrl_ex.size := WORD;
              when others => v.decode.simd.ctrl_ex.size := DOUBLE;
            end case;

            if(vec_opcode.f3xrsl.a(1) = '1') then
              v.decode.simd.ctrl_ex.simd_src_b          := SIMD_SRC_NOT_REGB;
              v.decode.simd.ctrl_ex.mode                := SUB;
            end if;
    
          elsif(compare(vec_opcode.f3xrsl.a, "0100") = '1') then
            --------------------------------------------------------------------
            -- VSHL, VQSHL (register)
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.simd_op               := SIMD_SHIFT;
            v.decode.simd.ctrl_ex.dir                   := LEFT_RIGHT;
            v.decode.simd.ctrl_ex.saturate              := vec_opcode.f3xrsl.b;
            v.decode.simd.ctrl_ex.dt                    := S;
            v.decode.simd.ctrl_ex.res_dt                := S;

            if(vec_opcode.u = '1') then
              v.decode.simd.ctrl_ex.dt                  := U;
              v.decode.simd.ctrl_ex.res_dt              := U;
            end if;

            case(vec_opcode.f3xrsl.c) is
              when "00"   => v.decode.simd.ctrl_ex.size := BYTE;
              when "01"   => v.decode.simd.ctrl_ex.size := WORD;
              when others => v.decode.simd.ctrl_ex.size := DOUBLE;
            end case;
            
          elsif(compare(vec_opcode.f3xrsl.a, "1001") = '1') then
            --------------------------------------------------------------------
            -- VMUL, VMADD, VMSUB
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.simd_op               := SIMD_MUL;
         
            if(vec_opcode.f3xrsl.b = '0') then
              v.decode.simd.ctrl_ex.dt                  := S;
              v.decode.simd.ctrl_ex.mac                 := '1';
              
              if(vec_opcode.u = '1') then
                v.decode.simd.ctrl_ex.mode              := SUB;
              end if;
            else
              if(vec_opcode.u = '1') then
                v.decode.simd.ctrl_ex.dt                := U;
              end if;
            end if;
            
            case(vec_opcode.f3xrsl.c) is
              when "00"   => v.decode.simd.ctrl_ex.size := BYTE;
              when "01"   => v.decode.simd.ctrl_ex.size := WORD;
              when others => v.decode.simd.ctrl_ex.size := DOUBLE;
            end case;
            
            if(r.decode.scu.stall = '0') then
              v.decode.scu.stall                        := '1';
            end if;
          
          elsif(compare(vec_opcode.f3xrsl.a, "1011") = '1') then
            --------------------------------------------------------------------
            -- VPADD
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.simd_src_a            := SIMD_SRC_REGAB;
            v.decode.simd.ctrl_ex.simd_src_b            := SIMD_SRC_REGBA;

            if(vec_opcode.f3xrsl.c = "00") then
              v.decode.simd.ctrl_ex.size                := BYTE;
            else
              v.decode.simd.ctrl_ex.size                := WORD;
            end if; 
            
          elsif(use_custom_g = true and compare(vec_opcode.f3xrsl.a, "1111") = '1') then
            --------------------------------------------------------------------
            -- user defined custom instructions
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.simd_op               := SIMD_CUSTOM;
            v.decode.simd.ctrl_ex.custom_cmd            := vec_opcode.f3xrsl.c & vec_opcode.f3xrsl.b;
              
            if(mci_custom_g = true and r.decode.scu.stall = '0') then
              v.decode.scu.stall                        := '1';
            end if;
            
          end if;
          
        elsif(instruction(23) = '1' and instruction(6) = '0' and instruction(4) = '0') then                
          ----------------------------------------------------------------------                          
          -- three registers of different length
          ----------------------------------------------------------------------
          if((compare(vec_opcode.f3xrdl.a(3 downto 1), "000") or compare(vec_opcode.f3xrdl.a(3 downto 1), "001")) = '1') then
            --------------------------------------------------------------------
            -- VADDL, VADDW, VSUBL, VSUBW
            --------------------------------------------------------------------
            if(vec_opcode.f3xrdl.a(1) = '1') then
              v.decode.simd.ctrl_ex.simd_src_b          := SIMD_SRC_NOT_REGB;
              v.decode.simd.ctrl_ex.mode                := SUB;
            end if;
        
            if(vec_opcode.f3xrdl.a(0) = '1') then
              v.decode.simd.ctrl_ex.qualifier           := WIDE;
              v.decode.simd.ctrl_ex.simd_src_a_sel      := "11";
              v.decode.simd.ctrl_ex.simd_src_b_sel      := v.decode.simd.reg_b(0) & not v.decode.simd.reg_b(0);          
            else
              v.decode.simd.ctrl_ex.qualifier           := LONG;
              v.decode.simd.ctrl_ex.simd_src_a_sel      := v.decode.simd.reg_a(0) & not v.decode.simd.reg_a(0);
              v.decode.simd.ctrl_ex.simd_src_b_sel      := v.decode.simd.reg_b(0) & not v.decode.simd.reg_b(0);
            end if;
        
            v.decode.simd.ctrl_ex.dt                    := S;
            v.decode.simd.ctrl_ex.res_dt                := S;
        
            if(vec_opcode.u = '1') then
              v.decode.simd.ctrl_ex.dt                  := U;
              v.decode.simd.ctrl_ex.res_dt              := U;
            end if;

            case(vec_opcode.f3xrdl.b) is
              when "00"   => v.decode.simd.ctrl_ex.size := BYTE;
              when "01"   => v.decode.simd.ctrl_ex.size := WORD;
              when others => v.decode.simd.ctrl_ex.size := DOUBLE;
            end case;
        
            v.decode.simd.ctrl_wrb.reg_write            := "11";
      
          elsif((compare(vec_opcode.f3xrdl.a, "0100") or  compare(vec_opcode.f3xrdl.a, "0110")) = '1') then
            --------------------------------------------------------------------
            -- VADDHN, VSUBHN
            --------------------------------------------------------------------
            if(vec_opcode.f3xrdl.a(1) = '1') then
              v.decode.simd.ctrl_ex.simd_src_b          := SIMD_SRC_NOT_REGB;
              v.decode.simd.ctrl_ex.mode                := SUB;
            end if;
        
            case(vec_opcode.f3xrdl.b) is
              when "00"   => v.decode.simd.ctrl_ex.size := WORD;
              when others => v.decode.simd.ctrl_ex.size := DOUBLE;
            end case;
            
            v.decode.simd.ctrl_ex.qualifier             := NARROW_HIGH;
            v.decode.simd.ctrl_wrb.reg_write            := vec_reg_d_even & not vec_reg_d_even;
            
          elsif((compare(vec_opcode.f3xrdl.a, "1000") or  compare(vec_opcode.f3xrdl.a, "1010")) = '1') then
            --------------------------------------------------------------------
            -- VMADDL, VMSUBL
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.simd_op               := SIMD_MUL;
            v.decode.simd.ctrl_ex.qualifier             := LONG;
            v.decode.simd.ctrl_ex.mac                   := '1';
            
            v.decode.simd.ctrl_ex.simd_src_a_sel        := vec_reg_a_even & not vec_reg_a_even;
            v.decode.simd.ctrl_ex.simd_src_b_sel        := vec_reg_b_even & not vec_reg_b_even;
            
            if(vec_opcode.u = '0') then
              v.decode.simd.ctrl_ex.dt                  := S;
            end if;
            
            if(vec_opcode.f3xrdl.a(1) = '1') then
              v.decode.simd.ctrl_ex.mode                := SUB;
            end if;
            
            case(vec_opcode.f3xrdl.b) is
              when "00"   => v.decode.simd.ctrl_ex.size := BYTE;
              when "01"   => v.decode.simd.ctrl_ex.size := WORD;
              when others => v.decode.simd.ctrl_ex.size := DOUBLE;
            end case;
            
            if(r.decode.scu.stall = '0') then
              v.decode.scu.stall                        := '1';
            end if;
            
          elsif(compare(vec_opcode.f3xrdl.a, "1100") = '1') then
            --------------------------------------------------------------------
            -- VMULL
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.simd_op               := SIMD_MUL;
            v.decode.simd.ctrl_ex.qualifier             := LONG;
            
            v.decode.simd.ctrl_ex.simd_src_a_sel        := vec_reg_a_even & not vec_reg_a_even;
            v.decode.simd.ctrl_ex.simd_src_b_sel        := vec_reg_b_even & not vec_reg_b_even;
            
            if(vec_opcode.u = '0') then
              v.decode.simd.ctrl_ex.dt                  := S;
            end if;
            
            case(vec_opcode.f3xrdl.b) is
              when "00"   => v.decode.simd.ctrl_ex.size := BYTE;
              when "01"   => v.decode.simd.ctrl_ex.size := WORD;
              when others => v.decode.simd.ctrl_ex.size := DOUBLE;
            end case;
            
            if(r.decode.scu.stall = '0') then
              v.decode.scu.stall                        := '1';
            end if;
          end if;

        elsif(instruction(23) = '1' and instruction(6) = '1' and instruction(4) = '0') then     
          ----------------------------------------------------------------------                                  
          -- two registers and a scalar
          ----------------------------------------------------------------------
          null;
      
        elsif(instruction(23) = '1' and instruction(21 downto 19) = "000" and instruction(7) = '0' and instruction(4) = '1') then
          ----------------------------------------------------------------------
          -- one register and a modified immediate         
          ----------------------------------------------------------------------
          v.decode.simd.imm                             := expand_imm(vec_opcode.f1xrmi.cmode, vec_opcode.f1xrmi.op, vec_opcode.f1xrmi.imm8);
          v.decode.simd.ctrl_wrb.reg_write              := "11";
          
          if(vec_opcode.w = '0') then
            v.decode.simd.ctrl_wrb.reg_write            := vec_reg_d_even & not vec_reg_d_even;
          end if;
    
          if((vec_opcode.f1xrmi.cmode(3) = '0' and vec_opcode.f1xrmi.cmode(0) = '1') or
             (vec_opcode.f1xrmi.cmode(3) = '1' and vec_opcode.f1xrmi.cmode(2) = '0'  and vec_opcode.f1xrmi.cmode(0) = '1')) then
            --------------------------------------------------------------------
            -- VORRI, VBIC (VANDNI)
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.simd_src_a            := SIMD_SRC_REGD;
            if(vec_opcode.f1xrmi.op = '0') then
              v.decode.simd.ctrl_ex.simd_op             := SIMD_OR;
              v.decode.simd.ctrl_ex.simd_src_b          := SIMD_SRC_IMM;
            else
              v.decode.simd.ctrl_ex.simd_op             := SIMD_AND;
              v.decode.simd.ctrl_ex.simd_src_b          := SIMD_SRC_NOT_IMM;
            end if;
      
          elsif((vec_opcode.f1xrmi.cmode(3)='0' and vec_opcode.f1xrmi.cmode(0) = '0') or
                (vec_opcode.f1xrmi.cmode(3)='1' and vec_opcode.f1xrmi.cmode(2) = '0'  and vec_opcode.f1xrmi.cmode(0) = '0') or
                (vec_opcode.f1xrmi.cmode(3)='1' and vec_opcode.f1xrmi.cmode(2) = '1')) then
            --------------------------------------------------------------------
            -- VMOVI (vector move imm), VMOVNI (vector bitwise NOT imm)
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.simd_op               := SIMD_OR;
            v.decode.simd.ctrl_ex.simd_src_a            := SIMD_SRC_ZERO;
            if(vec_opcode.f1xrmi.op = '0') then
              v.decode.simd.ctrl_ex.simd_src_b          := SIMD_SRC_IMM;
            else
              v.decode.simd.ctrl_ex.simd_src_b          := SIMD_SRC_NOT_IMM;
            end if;
          end if;
  
        elsif(instruction(23) = '1' and instruction(4) = '1') then
          ----------------------------------------------------------------------                      
          -- two registers and a shift amount
          ----------------------------------------------------------------------
          v.decode.simd.ctrl_wrb.reg_write              := "11";

          if(vec_opcode.w = '0') then
            v.decode.simd.ctrl_wrb.reg_write            := vec_reg_d_even & not vec_reg_d_even;
            v.decode.simd.ctrl_ex.simd_src_b_sel        := vec_reg_b_even & not vec_reg_b_even;
          end if;
      
          if(vec_opcode.f2xrsa.imm6(5 downto 3) = "001") then
            v.decode.simd.ctrl_ex.size                  := BYTE;
            v.decode.simd.imm                           := sign_extend(vec_opcode.f2xrsa.imm6(2 downto 0), '0', v.decode.simd.imm'length);
          elsif(vec_opcode.f2xrsa.imm6(5 downto 4) = "01") then
            v.decode.simd.ctrl_ex.size                  := WORD;
            v.decode.simd.imm                           := sign_extend(vec_opcode.f2xrsa.imm6(3 downto 0), '0', v.decode.simd.imm'length);
          else
            v.decode.simd.ctrl_ex.size                  := DOUBLE;
            v.decode.simd.imm                           := sign_extend(vec_opcode.f2xrsa.imm6(4 downto 0), '0', v.decode.simd.imm'length);
          end if;
      
          v.decode.simd.ctrl_ex.simd_src_a              := SIMD_SRC_SHIFT_IMM;
      
          if((compare(vec_opcode.f2xrsa.a, "0000") or compare(vec_opcode.f2xrsa.a, "1000") or compare(vec_opcode.f2xrsa.a, "1001")) = '1') then
            --------------------------------------------------------------------
            -- VSHR (immediate)
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.simd_op               := SIMD_SHIFT;
            v.decode.simd.ctrl_ex.dir                   := RIGHT;
        
            if(vec_opcode.f2xrsa.a(3) = '1') then
              v.decode.simd.ctrl_ex.qualifier           := NARROW_LOW;
            end if;
        
            if(vec_opcode.u = '1' or vec_opcode.f2xrsa.a(0) = '1') then
              v.decode.simd.ctrl_ex.saturate            := '1';
              v.decode.simd.ctrl_ex.dt                  := S;
              v.decode.simd.ctrl_ex.res_dt              := S;
        
              if(vec_opcode.u = '1') then
                v.decode.simd.ctrl_ex.res_dt            := U;
              end if;
              if(vec_opcode.u = '1' and vec_opcode.f2xrsa.a(0) = '1') then
                v.decode.simd.ctrl_ex.dt                := U;
              end if;
            end if;
              
          elsif(compare(vec_opcode.f2xrsa.a, "0101") = '1') then
            --------------------------------------------------------------------
            -- VSHL (immediate)
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.simd_op               := SIMD_SHIFT;
            v.decode.simd.ctrl_ex.dir                   := LEFT;
      
          elsif(compare(vec_opcode.f2xrsa.a(3 downto 1), "011") = '1') then
            --------------------------------------------------------------------
            -- VQSHL, VQSHLU (immediate)
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.simd_op               := SIMD_SHIFT;
            v.decode.simd.ctrl_ex.dir                   := LEFT;
            v.decode.simd.ctrl_ex.saturate              := '1';
        
            v.decode.simd.ctrl_ex.dt                    := S;
            v.decode.simd.ctrl_ex.res_dt                := S;
        
            if(vec_opcode.u = '1') then
              v.decode.simd.ctrl_ex.res_dt              := U;
            end if;
            if(vec_opcode.u = '1' and vec_opcode.f2xrsa.a(0) = '1') then
              v.decode.simd.ctrl_ex.dt                  := U;
            end if;
      
          elsif((compare(vec_opcode.f2xrsa.a, "1010") and not vec_opcode.f2xrsa.b and not vec_opcode.f2xrsa.l) = '1') then
            --------------------------------------------------------------------
            -- VSHLL
            --------------------------------------------------------------------
            v.decode.simd.ctrl_ex.simd_op               := SIMD_SHIFT;
            v.decode.simd.ctrl_ex.dir                   := LEFT;
            v.decode.simd.ctrl_ex.qualifier             := LONG;
            v.decode.simd.ctrl_wrb.reg_write            := "11";
            v.decode.simd.ctrl_ex.dt                    := U;
            v.decode.simd.ctrl_ex.res_dt                := U;
        
          end if;
      
        elsif(instruction(24 downto 23) = "11" and instruction(21 downto 20) = "11" and instruction(11) = '0' and instruction(4) = '0') then
          ----------------------------------------------------------------------
          -- two registers miscellanous
          ----------------------------------------------------------------------
          null;
        else
          -- unknown opcode
          null; 
        end if;
      elsif(instruction(25 downto 24) = class_simd_ldst_c) then
        ------------------------------------------------------------------------
        -- load-store instructions
        ------------------------------------------------------------------------
        v.decode.scu.imm                                := sign_extend(vec_opcode.fldst.imm5 & addr_ext_c, '0', v.decode.scu.imm'length);
        v.decode.scu.ctrl_ex.alu_op                     := ALU_ADD;
        v.decode.scu.reg_a                              := get_vinst(instruction).source.reg_a;
        v.decode.scu.ctrl_ex.alu_src_a                  := ALU_SRC_REGA;
        v.decode.scu.ctrl_ex.alu_src_b                  := ALU_SRC_IMM;
        v.decode.scu.ctrl_ex.addr_post_modify           := vec_opcode.fldst.a(2);
        
        if(vec_opcode.fldst.a(1) = '0') then
          v.decode.scu.ctrl_ex.alu_src_b                := ALU_SRC_NOT_IMM;
        end if;
        
        if(vec_opcode.fldst.b = '1') then
          v.decode.scu.ctrl_wrb.reg_d                   := get_vinst(instruction).source.reg_a;
          v.decode.scu.ctrl_wrb.reg_write               := is_not_zero(v.decode.scu.ctrl_wrb.reg_d);
        end if; 
        
        if(vec_opcode.fldst.a(0) = '1') then
          -- load
          v.decode.simd.ctrl_mem.mem_write              := '0';
          v.decode.simd.ctrl_mem.mem_read               := '1';
          v.decode.simd.ctrl_wrb.reg_write              := "11";
          
          if(vec_opcode.w = '0') then
            v.decode.simd.ctrl_wrb.reg_write            := vec_reg_d_even & not vec_reg_d_even;
            v.decode.simd.ctrl_mem.transfer_size        := vec_reg_d_even & not vec_reg_d_even;
          end if;
        else
          -- store
          v.decode.simd.ctrl_mem.mem_write              := '1';
          v.decode.simd.ctrl_mem.mem_read               := '0';
          
          if(vec_opcode.w = '0') then
            v.decode.simd.ctrl_mem.transfer_size        := vec_reg_d_even & not vec_reg_d_even;
          end if;
        end if;
        
      elsif(instruction(25 downto 24) = class_simd_trans_c) then
        ------------------------------------------------------------------------
        -- transfer instructions
        ------------------------------------------------------------------------
        if(compare(vec_opcode.ftrans.op, "00") = '1') then
          ----------------------------------------------------------------------
          -- VMOV, VMOVA (reg -> vreg)
          ----------------------------------------------------------------------
          v.decode.simd.imm                             := sign_extend(vec_opcode.ftrans.imm5, '0', v.decode.simd.imm'length);
          v.decode.simd.ctrl_wrb.reg_write              := "11";
          v.decode.simd.ctrl_ex.simd_op                 := SIMD_MOV;
          v.decode.scu.reg_a                            := get_vinst(instruction).source.reg_a;

          if(vec_opcode.ftrans.amode(0) = '1') then
            v.decode.simd.ctrl_ex.simd_op               := SIMD_MOVA;
            
            if(vec_opcode.w = '0') then
              v.decode.simd.ctrl_wrb.reg_write          := vec_reg_d_even & not vec_reg_d_even;
              v.decode.simd.ctrl_ex.simd_src_b_sel      := vec_reg_b_even & not vec_reg_b_even;
            end if;
          end if;
        
        elsif(compare(vec_opcode.ftrans.op, "01") = '1') then
          ----------------------------------------------------------------------
          -- VMOVS (vreg -> reg)
          ----------------------------------------------------------------------
          v.decode.scu.ctrl_ex.alu_op                   := ALU_MOV;
          v.decode.scu.ctrl_wrb.reg_d                   := get_vinst(instruction).destin.reg_d;
          v.decode.scu.ctrl_wrb.reg_write               := is_not_zero(v.decode.scu.ctrl_wrb.reg_d);
          v.decode.scu.imm                              := sign_extend(vec_opcode.ftrans.imm5, '0', v.decode.scu.imm'length);
        
        elsif(compare(vec_opcode.ftrans.op, "10") = '1') then
          ----------------------------------------------------------------------
          -- VSHUF
          ----------------------------------------------------------------------
          v.decode.simd.imm                             := sign_extend(vec_opcode.fshuffle.vwidth & vec_opcode.fshuffle.ssss &
                                                                       vec_opcode.fshuffle.vn, '0', v.decode.scu.imm'length);
          v.decode.simd.ctrl_wrb.reg_write              := "11";
          v.decode.simd.ctrl_ex.simd_op                 := SIMD_SHUF;
          
          if(r.decode.scu.stall = '0') then
            v.decode.scu.stall                          := '1';
          end if;
      
        end if;
      else
        -- unknown class
        null; 
      end if;
    end if;
    
    ----------------------------------------------------------------------------
    -- latch the current instruction that causes the stall
    ----------------------------------------------------------------------------
    if(v.decode.scu.stall = '1') then
      v.pc   := pc;
      v.inst := instruction;
    end if;

    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    wb_dat_d     <= wb_result;
    wb_vec_dat_d <= wb_vec_result; 
    
    decode_o <= r.decode;
        
    rin <= v;
  end process comb0;  
    
  ------------------------------------------------------------------------------
  -- sync0
  ------------------------------------------------------------------------------
  sync0: process(clk_i, reset_n_i) is
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

