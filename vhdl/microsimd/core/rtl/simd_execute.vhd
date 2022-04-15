library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.core_pkg.all;
use work.func_pkg.all;
use work.vec_data_pkg.all;
use work.simd_addsub32_pkg.all;
use work.simd_shift32_pkg.all;

entity simd_execute is
  generic (
    use_barrel_g  : boolean;
    use_mul_g     : boolean;
    use_shuffle_g : boolean;
    use_custom_g  : boolean
  );
  port (
    clk_i        : in  std_ulogic;
    reset_n_i    : in  std_ulogic;
    init_i       : in  std_ulogic;
    en_i         : in  std_ulogic;
    stall_i      : in  std_ulogic;
    exec_o       : out vec_execute_out_t;
    exec_i       : in  vec_execute_in_t;
    scalar_i     : in  std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0);
    vec_data_o   : out vec_data_t;
    ready_o      : out std_ulogic
  );
end entity simd_execute;

architecture rtl of simd_execute is
  
  type reg_t is record
    exec  : vec_execute_out_t;
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    exec  => dflt_vec_execute_out_c
  );
  
  ------------------------------------------------------------------------------
  -- extend vector
  ------------------------------------------------------------------------------
  function extend(vec : vec_data_t; sel : std_ulogic_vector(1 downto 0)) return vec_data_t is
    variable result : vec_data_t;
  begin
    result   := vec;
    if(sel = "01") then
      result := vec(vec_low) & vec(vec_low);
    elsif(sel = "10") then
      result := vec(vec_high) & vec(vec_high);
    end if;
    return result;
  end function extend;
  
  ------------------------------------------------------------------------------
  -- signed and unsigned saturate narrow 
  ------------------------------------------------------------------------------
  function sat_narrow_word(vec    : in std_ulogic_vector(15 downto 0);
                           dt     : in simd_data_t;
                           res_dt : in simd_data_t) return std_ulogic_vector is
    constant positive_c : std_ulogic := '0';
    variable sign       : std_ulogic;
    variable high_part  : std_ulogic_vector(7 downto 0);
    variable result     : std_ulogic_vector(7 downto 0);
  begin
  
    high_part := vec(15 downto 8);
    sign      := high_part(7);
    result    := vec( 7 downto 0);
  
    if(dt = U) then
      if(v_or(high_part) = '1') then
        result      := x"ff";
      end if;
    else        
      if(sign = positive_c) then
        if(v_or(high_part) = '1') then
          result   := x"ff";
          if(res_dt = S) then
            result := x"7f";
          end if;
        end if;
      else
        if(v_and(high_part) = '0') then
          result   := x"00";
          if(res_dt = S) then
            result := x"80";
          end if;
        end if;
      end if;
    end if;        
    return result;
  end function sat_narrow_word;

  function sat_narrow_dword(vec    : in std_ulogic_vector(31 downto 0);
                            dt     : in simd_data_t;
                            res_dt : in simd_data_t) return std_ulogic_vector is
    constant positive_c : std_ulogic := '0';
    variable sign       : std_ulogic;
    variable high_part  : std_ulogic_vector(15 downto 0);
    variable result     : std_ulogic_vector(15 downto 0);
  begin
  
    high_part := vec(31 downto 16);
    sign      := high_part(15);
    result    := vec(15 downto 0);
  
    if(dt = U) then
      if(v_or(high_part) = '1') then
        result      := x"ffff";
      end if;
    else        
      if(sign = positive_c) then
        if(v_or(high_part) = '1') then
          result   := x"ffff";
          if(res_dt = S) then
            result := x"7fff";
          end if;
        end if;
      else
        if(v_and(high_part) = '0') then
          result   := x"0000";
          if(res_dt = S) then
            result := x"8000";
          end if;
        end if;
      end if;
    end if;        
    return result;
  end function sat_narrow_dword;

  signal shuffle_ready  : std_ulogic;
  signal shuffle_data   : vec_data_t;
  
  signal shuffle_vwidth : std_ulogic_vector(1 downto 0);
  signal shuffle_ssss   : std_ulogic_vector(3 downto 0);
  signal shuffle_vn     : std_ulogic_vector(7 downto 0);
  signal shuffle_veca   : vec_data_t;
  signal shuffle_vecb   : vec_data_t;
  
  signal mul            : simd_mul_in_t;
  signal mul_ready      : std_ulogic;
  signal mul_data       : vec_data_t;

  signal custom_ready   : std_ulogic;
  signal custom_data    : vec_data_t;
  signal custom_veca    : vec_data_t;
  signal custom_vecb    : vec_data_t;
  
  signal ena            : std_ulogic;
  signal r, rin         : reg_t;

begin
  ------------------------------------------------------------------------------
  -- shuffle unit
  ------------------------------------------------------------------------------
  shuffle_block: block is
    signal shufflei0_ready : std_ulogic;
    signal shufflei0_data  : vec_data_t;
    signal shuffle_start   : std_ulogic;
  begin
    shuffle_unit: if use_shuffle_g generate
    
      shuffle_start <= '1' when exec_i.ctrl_ex.simd_op = SIMD_SHUF and exec_i.flush = '0' else '0';
    
      shufflei0: entity work.shuffle
        port map (
          clk_i     => clk_i,
          reset_n_i => reset_n_i,
          init_i    => init_i,
          en_i      => en_i,
          start_i   => shuffle_start,
          veca_i    => shuffle_veca,
          vecb_i    => shuffle_vecb,
          vn_i      => shuffle_vn,
          ssss_i    => shuffle_ssss,
          vwidth_i  => shuffle_vwidth,
          ready_o   => shufflei0_ready,
          data_o    => shufflei0_data
        );
    end generate shuffle_unit;
    
    shuffle_ready <= shufflei0_ready when use_shuffle_g else '1';
    shuffle_data  <= shufflei0_data  when use_shuffle_g else dflt_vec_data_c;
    
  end block shuffle_block;
  
  ------------------------------------------------------------------------------
  -- mac unit
  ------------------------------------------------------------------------------  
  mac_block: block is
    signal muli0_ready : std_ulogic;
    signal muli0_mul   : simd_mul_out_t;
    signal mul_start   : std_ulogic;
  begin
    mac_unit: if use_mul_g generate
    
      mul_start <= '1' when exec_i.ctrl_ex.simd_op = SIMD_MUL and exec_i.flush = '0' else '0';
      
      muli0: entity work.simd_mul
        port map (
          clk_i     => clk_i,
          reset_n_i => reset_n_i,
          init_i    => init_i,
          en_i      => en_i,
          start_i   => mul_start,
          mul_i     => mul,
          mul_o     => muli0_mul,
          ready_o   => muli0_ready
        );
    end generate mac_unit;
    
    mul_ready <= muli0_ready      when use_mul_g else '1';
    mul_data  <= muli0_mul.result when use_mul_g else dflt_vec_data_c;
    
  end block mac_block;
  
  ------------------------------------------------------------------------------
  -- custom0 unit
  ------------------------------------------------------------------------------
  custom_block: block is
    signal custom_start    : std_ulogic;
    signal customi0_ready  : std_ulogic;
    signal customi0_result : vec_data_t;
  begin
    custom_unit : if use_custom_g generate
    
      custom_start <= '1' when exec_i.ctrl_ex.simd_op = SIMD_CUSTOM and exec_i.flush = '0' else '0';
  
        customi0: entity work.simd_custom
          port map (
            clk_i     => clk_i,
            reset_n_i => reset_n_i,
            init_i    => init_i,
            en_i      => en_i,
            start_i   => custom_start,
            cmd_i     => exec_i.ctrl_ex.custom_cmd,
            veca_i    => custom_veca,
            vecb_i    => custom_vecb,
            result_o  => customi0_result,
            ready_o   => customi0_ready 
          );

     end generate custom_unit;
  
    custom_ready <= customi0_ready  when use_custom_g else '1';
    custom_data  <= customi0_result when use_custom_g else dflt_vec_data_c;
  
  end block custom_block;
  
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, exec_i, scalar_i, shuffle_ready, shuffle_data, mul_ready, mul_data, custom_ready, custom_data) is
    variable v                   : reg_t;
    variable sel_dat_a           : vec_data_t;
    variable sel_dat_b           : vec_data_t;
    variable sel_dat_d           : vec_data_t;
    variable mem_result          : vec_data_t;
    variable dat_a               : vec_data_t;
    variable dat_b               : vec_data_t;
    variable dat_d               : vec_data_t;
    variable dat_a_ext           : vec_data_t;
    variable dat_b_ext           : vec_data_t;
    variable dat_d_ext           : vec_data_t;
    variable shift_val           : vec_data_t;
    variable shift_amount        : vec_data_t;
    variable alu_src_a           : vec_data_t;
    variable alu_src_b           : vec_data_t;
    variable alu_result          : vec_data_t;
    variable alu_add_result      : vec_data_t;
    variable alu_shift_result    : vec_data_t;
    variable narrow_add_result   : vec_data_t;
	  variable narrow_shift_result : vec_data_t;
  begin
    v := r;
    
    ----------------------------------------------------------------------------
    -- forward logic
    ----------------------------------------------------------------------------
    sel_dat_a(vec_low)  := sel_vecreg_data(exec_i.dat_a, exec_i.reg_a, exec_i.fwd_dec_result, fwd_cond(exec_i.fwd_dec.reg_write(0), exec_i.fwd_dec.reg_d, exec_i.reg_a))(vec_low);
    sel_dat_a(vec_high) := sel_vecreg_data(exec_i.dat_a, exec_i.reg_a, exec_i.fwd_dec_result, fwd_cond(exec_i.fwd_dec.reg_write(1), exec_i.fwd_dec.reg_d, exec_i.reg_a))(vec_high);

    sel_dat_b(vec_low)  := sel_vecreg_data(exec_i.dat_b, exec_i.reg_b, exec_i.fwd_dec_result, fwd_cond(exec_i.fwd_dec.reg_write(0), exec_i.fwd_dec.reg_d, exec_i.reg_b))(vec_low);
    sel_dat_b(vec_high) := sel_vecreg_data(exec_i.dat_b, exec_i.reg_b, exec_i.fwd_dec_result, fwd_cond(exec_i.fwd_dec.reg_write(1), exec_i.fwd_dec.reg_d, exec_i.reg_b))(vec_high);

    sel_dat_d(vec_low)  := sel_vecreg_data(exec_i.dat_d, exec_i.ctrl_wrb.reg_d, exec_i.fwd_dec_result, fwd_cond(exec_i.fwd_dec.reg_write(0), exec_i.fwd_dec.reg_d, exec_i.ctrl_wrb.reg_d))(vec_low);
    sel_dat_d(vec_high) := sel_vecreg_data(exec_i.dat_d, exec_i.ctrl_wrb.reg_d, exec_i.fwd_dec_result, fwd_cond(exec_i.fwd_dec.reg_write(1), exec_i.fwd_dec.reg_d, exec_i.ctrl_wrb.reg_d))(vec_high);
    
    ----------------------------------------------------------------------------
    -- conditionally flush execution stage in case of control hazards
    ----------------------------------------------------------------------------
    if(exec_i.flush = '1') then
      v.exec.ctrl_mem.mem_write := '0';
      v.exec.ctrl_mem.mem_read  := '0';
      v.exec.ctrl_wrb.reg_write := (others=>'0');
      v.exec.ctrl_wrb.reg_d     := (others=>'0');
    else
      v.exec.ctrl_mem           := exec_i.ctrl_mem;
      v.exec.ctrl_wrb           := exec_i.ctrl_wrb;
    end if;

    ----------------------------------------------------------------------------
    -- memory result vs alu_result
    ----------------------------------------------------------------------------   
    if(exec_i.ctrl_mem_wrb.mem_read = '1') then
      mem_result                := exec_i.mem_result;
    else
      mem_result                := exec_i.alu_result;
    end if;    
    
    ---------------------------------------------------------------------------
    -- multiplex from the forward buses
    ---------------------------------------------------------------------------
    if(fwd_cond(r.exec.ctrl_wrb.reg_write(0), r.exec.ctrl_wrb.reg_d, exec_i.reg_a) = '1') then
      dat_a(vec_low)            := r.exec.alu_result(vec_low);
    elsif(fwd_cond(exec_i.fwd_mem.reg_write(0), exec_i.fwd_mem.reg_d, exec_i.reg_a) = '1') then
      dat_a(vec_low)            := mem_result(vec_low);
    else
      dat_a(vec_low)            := sel_dat_a(vec_low);
    end if;

    if(fwd_cond(r.exec.ctrl_wrb.reg_write(1), r.exec.ctrl_wrb.reg_d, exec_i.reg_a) = '1') then
      dat_a(vec_high)           := r.exec.alu_result(vec_high);
    elsif(fwd_cond(exec_i.fwd_mem.reg_write(1), exec_i.fwd_mem.reg_d, exec_i.reg_a) = '1') then
      dat_a(vec_high)           := mem_result(vec_high);
    else
      dat_a(vec_high)           := sel_dat_a(vec_high);
    end if;

    if(fwd_cond(r.exec.ctrl_wrb.reg_write(0), r.exec.ctrl_wrb.reg_d, exec_i.reg_b) = '1') then
     dat_b(vec_low)             := r.exec.alu_result(vec_low);
    elsif(fwd_cond(exec_i.fwd_mem.reg_write(0), exec_i.fwd_mem.reg_d, exec_i.reg_b) = '1') then
      dat_b(vec_low)            := mem_result(vec_low);
    else
      dat_b(vec_low)            := sel_dat_b(vec_low);
    end if;

    if(fwd_cond(r.exec.ctrl_wrb.reg_write(1), r.exec.ctrl_wrb.reg_d, exec_i.reg_b) = '1') then
     dat_b(vec_high)            := r.exec.alu_result(vec_high);
    elsif(fwd_cond(exec_i.fwd_mem.reg_write(1), exec_i.fwd_mem.reg_d, exec_i.reg_b) = '1') then
      dat_b(vec_high)           := mem_result(vec_high);
    else
      dat_b(vec_high)           := sel_dat_b(vec_high);
    end if;
    
    if(fwd_cond(r.exec.ctrl_wrb.reg_write(0), r.exec.ctrl_wrb.reg_d, exec_i.ctrl_wrb.reg_d) = '1') then
      dat_d(vec_low)            := r.exec.alu_result(vec_low);
    elsif(fwd_cond(exec_i.fwd_mem.reg_write(0), exec_i.fwd_mem.reg_d, exec_i.ctrl_wrb.reg_d) = '1') then
      dat_d(vec_low)            := mem_result(vec_low);
    else
      dat_d(vec_low)            := sel_dat_d(vec_low);
    end if;

    if(fwd_cond(r.exec.ctrl_wrb.reg_write(1), r.exec.ctrl_wrb.reg_d, exec_i.ctrl_wrb.reg_d) = '1') then
      dat_d(vec_high)           := r.exec.alu_result(vec_high);
    elsif(fwd_cond(exec_i.fwd_mem.reg_write(1), exec_i.fwd_mem.reg_d, exec_i.ctrl_wrb.reg_d) = '1') then
      dat_d(vec_high)           := mem_result(vec_high);
    else
      dat_d(vec_high)           := sel_dat_d(vec_high);
    end if;
    
    v.exec.dat_d                := dat_d;
    
    ----------------------------------------------------------------------------
    -- conditionally extend input operand candidates
    ----------------------------------------------------------------------------
    dat_a_ext                   := extend(dat_a, exec_i.ctrl_ex.simd_src_a_sel);
    dat_b_ext                   := extend(dat_b, exec_i.ctrl_ex.simd_src_b_sel);
    dat_d_ext                   := extend(dat_d, exec_i.fwd_mem.reg_write);
    
    ----------------------------------------------------------------------------
    -- shift input mux
    ----------------------------------------------------------------------------
    shift_val                   := dat_b_ext;
    shift_amount                := dat_a_ext;
    
    if(exec_i.ctrl_ex.simd_src_a = SIMD_SRC_SHIFT_IMM) then
      shift_amount              := (others=>exec_i.imm);
    end if;
    
    shift_long0: for i in 0 to CFG_VREG_SLICES-1 loop
      if(exec_i.ctrl_ex.qualifier = LONG) then
        if(exec_i.ctrl_ex.size = WORD) then
          shift_val(i)(byte1)   := (others=>'0');
          shift_val(i)(byte3)   := (others=>'0');
        else
          shift_val(i)(word1)   := (others=>'0');
        end if;
      end if;
    end loop shift_long0;
    
    ----------------------------------------------------------------------------
    -- alu_a input signal assignment
    ----------------------------------------------------------------------------
    alu_src_a                   := dat_a_ext;
    
    if(exec_i.ctrl_ex.simd_src_a = SIMD_SRC_REGAB) then
      srca1: for i in 0 to CFG_VREG_SLICES/2-1 loop
        if(exec_i.ctrl_ex.size = BYTE) then
          alu_src_a(i)(byte0)   := dat_a_ext(2*i  )(byte0);
          alu_src_a(i)(byte1)   := dat_a_ext(2*i  )(byte2);
          alu_src_a(i)(byte2)   := dat_a_ext(2*i+1)(byte0);
          alu_src_a(i)(byte3)   := dat_a_ext(2*i+1)(byte2);
        else
          alu_src_a(i)(word0)   := dat_a_ext(2*i  )(word0);
          alu_src_a(i)(word1)   := dat_a_ext(2*i+1)(word0);
        end if;
      end loop srca1;
      alu_src_a(vec_high)       := alu_src_a(vec_low);
    end if;

    ----------------------------------------------------------------------------
    -- alu_b input signal assignment
    ----------------------------------------------------------------------------
    alu_src_b                   := dat_b_ext;
    
    if(exec_i.ctrl_ex.simd_src_b = SIMD_SRC_NOT_REGB) then
      srcb1: for i in 0 to CFG_VREG_SLICES-1 loop
        alu_src_b(i)            := not alu_src_b(i);
      end loop srcb1;
    elsif(exec_i.ctrl_ex.simd_src_b = SIMD_SRC_IMM) then
      srcb2: for i in 0 to CFG_VREG_SLICES-1 loop
        alu_src_b(i)            := exec_i.imm;
      end loop srcb2;
    elsif(exec_i.ctrl_ex.simd_src_b = SIMD_SRC_NOT_IMM) then
      srcb3: for i in 0 to CFG_VREG_SLICES-1 loop
        alu_src_b(i)            := not exec_i.imm;
      end loop srcb3;
    elsif(exec_i.ctrl_ex.simd_src_b = SIMD_SRC_REGBA) then
      srcb4: for i in 0 to CFG_VREG_SLICES/2-1 loop
        if(exec_i.ctrl_ex.size = BYTE) then
          alu_src_b(i)(byte0)   := dat_a_ext(2*i  )(byte1);
          alu_src_b(i)(byte1)   := dat_a_ext(2*i  )(byte3);
          alu_src_b(i)(byte2)   := dat_a_ext(2*i+1)(byte1);
          alu_src_b(i)(byte3)   := dat_a_ext(2*i+1)(byte3);
        else
          alu_src_b(i)(word0)   := dat_a_ext(2*i  )(word1);
          alu_src_b(i)(word1)   := dat_a_ext(2*i+1)(word1);
        end if;
      end loop srcb4;
      alu_src_b(vec_high)       := alu_src_b(vec_low);
    end if;
      
    ----------------------------------------------------------------------------
    -- arithmetic and logic unit
    ----------------------------------------------------------------------------
    arith: for i in 0 to CFG_VREG_SLICES-1 loop
      --------------------------------------------------------------------------
      -- check for long and wide operation and sign extend operands
      --------------------------------------------------------------------------
      if(exec_i.ctrl_ex.qualifier = LONG) then
        if(exec_i.ctrl_ex.size = WORD) then
          if(exec_i.ctrl_ex.dt = U) then
            alu_src_a(i)(byte1) := (others=>'0');
            alu_src_a(i)(byte3) := (others=>'0');
          else
            alu_src_a(i)(byte1) := (others=>alu_src_a(i)( 7));
            alu_src_a(i)(byte3) := (others=>alu_src_a(i)(23));
          end if;
        else
          if(exec_i.ctrl_ex.dt = U) then
            alu_src_a(i)(word1) := (others=>'0');
          else
            alu_src_a(i)(word1) := (others=>alu_src_a(i)(15));
          end if;
        end if;
      end if;

      case(exec_i.ctrl_ex.qualifier) is
        when LONG | WIDE => if(exec_i.ctrl_ex.size = WORD) then
                              if(exec_i.ctrl_ex.dt = U) then
                                alu_src_b(i)(byte1) := (others=>'0');
                                alu_src_b(i)(byte3) := (others=>'0');
                              else
                                alu_src_b(i)(byte1) := (others=>alu_src_b(i)( 7));
                                alu_src_b(i)(byte3) := (others=>alu_src_b(i)(23));
                              end if;
                            else
                              if(exec_i.ctrl_ex.dt = U) then
                                alu_src_b(i)(word1) := (others=>'0');
                              else
                                alu_src_b(i)(word1) := (others=>alu_src_b(i)(15));
                              end if;
                            end if;
        when others      => null;
      end case;

      alu_add_result(i)  := simd_addsub32( alu_src_a(i), 
                                           alu_src_b(i), 
                                           exec_i.ctrl_ex.mode, 
                                           exec_i.ctrl_ex.size, 
                                           exec_i.ctrl_ex.dt, 
                                           exec_i.ctrl_ex.saturate
                                         );
                                     
      alu_shift_result(i) := simd_shift32( shift_val(i), 
                                           shift_amount(i), 
                                           exec_i.ctrl_ex.size, 
                                           exec_i.ctrl_ex.dt, 
                                           exec_i.ctrl_ex.res_dt, 
                                           exec_i.ctrl_ex.dir, 
                                           exec_i.ctrl_ex.saturate
                                         );
    end loop arith;
    
    ----------------------------------------------------------------------------
    -- conditionally narrow alu_add result
    ----------------------------------------------------------------------------
    narrow_add_result                    := alu_add_result;
    
    narrow_alu: for i in 0 to CFG_VREG_SLICES/2-1 loop
      if(exec_i.ctrl_ex.qualifier = NARROW_HIGH) then
        if(exec_i.ctrl_ex.size = WORD) then
          narrow_add_result(i+0)(byte0)  := alu_add_result(i+0)(byte1);
          narrow_add_result(i+0)(byte1)  := alu_add_result(i+0)(byte3);
          narrow_add_result(i+0)(byte2)  := alu_add_result(i+1)(byte1);
          narrow_add_result(i+0)(byte3)  := alu_add_result(i+1)(byte3);
          narrow_add_result(i+1)(byte0)  := alu_add_result(i+0)(byte1);
          narrow_add_result(i+1)(byte1)  := alu_add_result(i+0)(byte3);
          narrow_add_result(i+1)(byte2)  := alu_add_result(i+1)(byte1);
          narrow_add_result(i+1)(byte3)  := alu_add_result(i+1)(byte3);
        else
          narrow_add_result(i+0)(word0)  := alu_add_result(i+0)(word1);
          narrow_add_result(i+0)(word1)  := alu_add_result(i+1)(word1);
          narrow_add_result(i+1)(word0)  := alu_add_result(i+0)(word1);
          narrow_add_result(i+1)(word1)  := alu_add_result(i+1)(word1);          
        end if;
      end if;
    end loop narrow_alu;
    
    ----------------------------------------------------------------------------
    -- conditionally narrow shift result
    ----------------------------------------------------------------------------
    narrow_shift_result                     := alu_shift_result;
    
    narrow_shift: for i in 0 to CFG_VREG_SLICES/2-1 loop
      if(exec_i.ctrl_ex.qualifier = NARROW_LOW) then
        if(exec_i.ctrl_ex.size = WORD) then
          narrow_shift_result(i+0)(byte0)   := alu_shift_result(i+0)(byte0);
          if(exec_i.ctrl_ex.saturate = '1') then
            narrow_shift_result(i+0)(byte0) := sat_narrow_word(alu_shift_result(i+0)(word0), exec_i.ctrl_ex.dt, exec_i.ctrl_ex.res_dt);
          end if;
          
          narrow_shift_result(i+0)(byte1)   := alu_shift_result(i+0)(byte2);
          if(exec_i.ctrl_ex.saturate = '1') then
            narrow_shift_result(i+0)(byte1) := sat_narrow_word(alu_shift_result(i+0)(word1), exec_i.ctrl_ex.dt, exec_i.ctrl_ex.res_dt);
          end if;        
          
          narrow_shift_result(i+0)(byte2)   := alu_shift_result(i+1)(byte0);
          if(exec_i.ctrl_ex.saturate = '1') then
            narrow_shift_result(i+0)(byte2) := sat_narrow_word(alu_shift_result(i+1)(word0), exec_i.ctrl_ex.dt, exec_i.ctrl_ex.res_dt);
          end if;
          
          narrow_shift_result(i+0)(byte3)   := alu_shift_result(i+1)(byte2);
          if(exec_i.ctrl_ex.saturate = '1') then
            narrow_shift_result(i+0)(byte3) := sat_narrow_word(alu_shift_result(i+1)(word1), exec_i.ctrl_ex.dt, exec_i.ctrl_ex.res_dt);
          end if;            
          
          narrow_shift_result(i+1)(byte0)   := narrow_shift_result(i+0)(byte0);
          narrow_shift_result(i+1)(byte1)   := narrow_shift_result(i+0)(byte1);
          narrow_shift_result(i+1)(byte2)   := narrow_shift_result(i+0)(byte2);
          narrow_shift_result(i+1)(byte3)   := narrow_shift_result(i+0)(byte3);
        else
          narrow_shift_result(i+0)(word0)   := alu_shift_result(i+0)(word0);
          if(exec_i.ctrl_ex.saturate = '1') then
            narrow_shift_result(i+0)(word0) := sat_narrow_dword(alu_shift_result(i+0), exec_i.ctrl_ex.dt, exec_i.ctrl_ex.res_dt);
          end if;
          
          narrow_shift_result(i+0)(word1)   := alu_shift_result(i+1)(word0);
          if(exec_i.ctrl_ex.saturate = '1') then
            narrow_shift_result(i+0)(word1) := sat_narrow_dword(alu_shift_result(i+1), exec_i.ctrl_ex.dt, exec_i.ctrl_ex.res_dt);
          end if;
          
          narrow_shift_result(i+1)(word0)   := narrow_shift_result(i+0)(word0);
          narrow_shift_result(i+1)(word1)   := narrow_shift_result(i+0)(word1);      
        end if;
      end if;
    end loop narrow_shift;
    
    ----------------------------------------------------------------------------
    -- alu operations
    ----------------------------------------------------------------------------
    case(exec_i.ctrl_ex.simd_op) is
      when SIMD_ADD     => alu_result := narrow_add_result;                                                  
      when SIMD_OR      => alu_result := alu_src_a or  alu_src_b;
      when SIMD_AND     => alu_result := alu_src_a and alu_src_b;
      when SIMD_XOR     => alu_result := alu_src_a xor alu_src_b;
      when SIMD_BIF     => alu_result := ((dat_d_ext and dat_b_ext) or dat_a_ext) and not dat_b_ext;
      when SIMD_BIT     => alu_result := ((dat_a_ext and dat_b_ext) or dat_d_ext) and not dat_b_ext;
      when SIMD_BSL     => alu_result := ((dat_a_ext and dat_d_ext) or dat_b_ext) and not dat_d_ext;
      when SIMD_SHIFT   => alu_result := narrow_shift_result;
      when SIMD_MOV     => alu_result := insert(dat_d, exec_i.imm, scalar_i);
      when SIMD_MOVA    => alu_result := (others=>scalar_i);
      when SIMD_MUL     => alu_result := mul_data;
      when SIMD_SHUF    => alu_result := shuffle_data;
      when SIMD_CUSTOM  => alu_result := custom_data;
      when others       => alu_result := narrow_add_result;
    end case;

    v.exec.alu_result := alu_result;
    
    ----------------------------------------------------------------------------
    -- drive multiplier TODO: use exec_i.imm to carry mul config
    ----------------------------------------------------------------------------
    mul.size       <= exec_i.ctrl_ex.size;
    mul.dt         <= exec_i.ctrl_ex.dt;
    mul.mac        <= exec_i.ctrl_ex.mac;
    mul.op         <= exec_i.ctrl_ex.mode;
    
    if(exec_i.ctrl_ex.qualifier = LONG) then
      mul.long     <= '1';
    else
      mul.long     <= '0';
    end if;
    
    mul.op_a       <= dat_a_ext;
    mul.op_b       <= dat_b_ext;
    mul.op_c       <= dat_d_ext;
    
    ----------------------------------------------------------------------------
    -- drive shuffle unit
    ----------------------------------------------------------------------------
    shuffle_vn     <= exec_i.imm( 7 downto  0);
    shuffle_ssss   <= exec_i.imm(11 downto  8);
    shuffle_vwidth <= exec_i.imm(13 downto 12);
    shuffle_veca   <= dat_d_ext;
    shuffle_vecb   <= dat_a_ext;
    
    ----------------------------------------------------------------------------
    -- drive custom0 unit TODO: use cfg_i.imm to carry mode
    ----------------------------------------------------------------------------
    custom_veca    <= dat_a_ext;
    custom_vecb    <= dat_b_ext;
    
    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    exec_o         <= r.exec;
    vec_data_o     <= dat_a;
    ready_o        <= shuffle_ready and mul_ready and custom_ready; 
    
    rin            <= v;
  end process comb0;
  
  ------------------------------------------------------------------------------
  -- sync0
  ------------------------------------------------------------------------------
  ena <= en_i and shuffle_ready and mul_ready and custom_ready and not stall_i;
    
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

