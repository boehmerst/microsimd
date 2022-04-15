library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.core_pkg.all;
use work.func_pkg.all;
use work.vec_data_pkg.all;

entity mem is
  port (
    clk_i      : in  std_ulogic;
    reset_n_i  : in  std_ulogic;
    init_i     : in  std_ulogic;
    en_i       : in  std_ulogic;
    mem_o      : out mem_out_t;
    mem_i      : in  mem_in_t;
    dmem_o     : out dmem_out_t
  );
end entity mem;

architecture rtl of mem is

  type reg_t is record
    mem          : mem_out_t;
    mem_addr_sel : std_ulogic_vector(log2ceil(CFG_DMEM_WIDTH/8)-1 downto 0);
    vec_req      : std_ulogic;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    mem          => dflt_mem_out_c,
    mem_addr_sel => (others=>'0'),
    vec_req      => '0'
  );

  signal r, rin : reg_t;

begin
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, mem_i) is
    variable v              : reg_t;
    variable intermediate   : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    variable mem_result     : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    variable vec_mem_result : vec_data_t;
    variable vec_load       : vec_data_t;
    variable vec_load_store : vec_data_t;
  begin
    v := r;
    
    ----------------------------------------------------------------------------
    -- simple delay latch to provide to WB stage and forward to EX
    ----------------------------------------------------------------------------
    v.mem.scu.ctrl_wrb                    := mem_i.scu.ctrl_wrb;
    v.mem.scu.ctrl_mem_wrb.mem_read       := mem_i.scu.ctrl_mem.mem_read;
    v.mem.scu.ctrl_mem_wrb.transfer_size  := mem_i.scu.ctrl_mem.transfer_size;
    
    v.mem.simd.ctrl_wrb                   := mem_i.simd.ctrl_wrb;
    v.mem.simd.alu_result                 := mem_i.simd.alu_result;
    v.mem.simd.ctrl_mem_wrb.mem_read      := mem_i.simd.ctrl_mem.mem_read;
    v.mem.simd.ctrl_mem_wrb.transfer_size := mem_i.simd.ctrl_mem.transfer_size;
     
    ----------------------------------------------------------------------------
    -- set alu result for branch, load instructions, to WB and forward to EX
    ----------------------------------------------------------------------------
    if(mem_i.scu.branch = '1') then
      v.mem.scu.alu_result               := sign_extend(mem_i.scu.pc, '0', 32);
    else
      v.mem.scu.alu_result               := mem_i.scu.alu_result;
    end if;
    
    ----------------------------------------------------------------------------
    -- latch to be used for reordering mem_result (see below)
    ----------------------------------------------------------------------------
    v.mem_addr_sel                       := mem_i.scu.mem_addr(v.mem_addr_sel'range);
    
    ----------------------------------------------------------------------------
    -- forward memory result
    ----------------------------------------------------------------------------
    if(CFG_MEM_FWD_WRB = true and (r.mem.scu.ctrl_mem_wrb.mem_read and compare(mem_i.scu.ctrl_wrb.reg_d, r.mem.scu.ctrl_wrb.reg_d)) = '1') then
      intermediate                       := align_mem_load(mem_i.scu.mem_result, r.mem.scu.ctrl_mem_wrb.transfer_size, r.mem_addr_sel);
      mem_result                         := align_mem_store(intermediate, mem_i.scu.ctrl_mem.transfer_size);
    else
      mem_result                         := mem_i.scu.dat_d;
    end if;
    
    vec_load                             := align_vec_load(mem_i.simd.mem_result, r.mem.simd.ctrl_mem_wrb.transfer_size);
    vec_load_store                       := align_vec_store(vec_load, mem_i.simd.ctrl_mem.transfer_size);

    if(CFG_MEM_FWD_WRB = true and (r.mem.simd.ctrl_mem_wrb.mem_read and compare(mem_i.simd.ctrl_wrb.reg_d, r.mem.simd.ctrl_wrb.reg_d)) = '1' and r.mem.simd.ctrl_wrb.reg_write(0) = '1') then
      vec_mem_result(vec_low)            := vec_load_store(vec_low);
    else
      vec_mem_result(vec_low)            := mem_i.simd.dat_d(vec_low);
    end if;

    if(CFG_MEM_FWD_WRB = true and (r.mem.simd.ctrl_mem_wrb.mem_read and compare(mem_i.simd.ctrl_wrb.reg_d, r.mem.simd.ctrl_wrb.reg_d)) = '1' and r.mem.simd.ctrl_wrb.reg_write(1) = '1') then
      vec_mem_result(vec_high)           := vec_load_store(vec_high);
    else
      vec_mem_result(vec_high)           := mem_i.simd.dat_d(vec_high);
    end if;
    
    ---------------------------------------------------------------------------
    -- drive module outputs and FFs
    ---------------------------------------------------------------------------
    mem_o           <= r.mem;
    
    dmem_o.scu.dat  <= mem_result;
    dmem_o.scu.sel  <= decode_mem_store(mem_i.scu.mem_addr(1 downto 0), mem_i.scu.ctrl_mem.transfer_size);
    dmem_o.scu.we   <= mem_i.scu.ctrl_mem.mem_write;
    dmem_o.scu.adr  <= mem_i.scu.mem_addr(CFG_DMEM_SIZE-1 downto 0);
    dmem_o.scu.ena  <= mem_i.scu.ctrl_mem.mem_read or mem_i.scu.ctrl_mem.mem_write;
    
    dmem_o.simd.dat <= vec_mem_result;
    dmem_o.simd.we  <= mem_i.simd.ctrl_mem.mem_write;
    dmem_o.simd.sel <= mem_i.simd.ctrl_mem.transfer_size;
    dmem_o.simd.adr <= mem_i.scu.mem_addr(CFG_VDMEM_SIZE-1 downto 0);
    dmem_o.simd.ena <= mem_i.simd.ctrl_mem.mem_read or mem_i.simd.ctrl_mem.mem_write;
    
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

