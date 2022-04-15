library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;

package inst_pkg is

  constant inst_vector_nop_c  : std_ulogic_vector(CFG_IMEM_WIDTH-1 downto 0) := x"00000000";
  constant inst_scalar_nop_c  : std_ulogic_vector(CFG_IMEM_WIDTH-1 downto 0) := x"00000000";
  
  constant class_simd_arith_c : std_ulogic                    := '1';
  constant class_simd_ldst_c  : std_ulogic_vector(1 downto 0) := "00";
  constant class_simd_trans_c : std_ulogic_vector(1 downto 0) := "01";
  
  type inst_source_t is record
    reg_a                 : std_ulogic_vector(CFG_GPRF_SIZE-1 downto 0);
    reg_b                 : std_ulogic_vector(CFG_GPRF_SIZE-1 downto 0);
  end record inst_source_t;
  
  type inst_destin_t is record
    reg_d                 : std_ulogic_vector(CFG_GPRF_SIZE-1 downto 0);
  end record inst_destin_t;

  type inst_t is record
    opcode                : std_ulogic_vector(5 downto 0);
    destin                : inst_destin_t;
    source                : inst_source_t;
    imm                   : std_ulogic_vector(15 downto 0);
  end record inst_t;

  type vinst_source_t is record
    reg_a                 : std_ulogic_vector(CFG_VREG_SIZE downto 0);
    reg_b                 : std_ulogic_vector(CFG_VREG_SIZE downto 0);
  end record vinst_source_t;
  
  type vinst_destin_t is record
    reg_d                 : std_ulogic_vector(CFG_VREG_SIZE downto 0);
  end record vinst_destin_t;

  type vinst_3xrsl_fields_t is record
    a : std_ulogic_vector(3 downto 0);
    b : std_ulogic;
    c : std_ulogic_vector(1 downto 0);
  end record vinst_3xrsl_fields_t;

  type vinst_3xrdl_fields_t is record
    a : std_ulogic_vector(3 downto 0);
    b : std_ulogic_vector(1 downto 0);
  end record vinst_3xrdl_fields_t;

  type vinst_2xrsa_fields_t is record
    a    : std_ulogic_vector(3 downto 0);
    l    : std_ulogic;
    b    : std_ulogic;
    imm6 : std_ulogic_vector(5 downto 0);
  end record vinst_2xrsa_fields_t;

  type vinst_1xrmi_fields_t is record
    op    : std_ulogic;
    cmode : std_ulogic_vector(3 downto 0);
    imm8  : std_ulogic_vector(7 downto 0);
  end record vinst_1xrmi_fields_t;

  type vinst_ldst_fields_t is record
    a     : std_ulogic_vector(3 downto 0);
    b     : std_ulogic;    
    c     : std_ulogic_vector(1 downto 0);
    imm5  : std_ulogic_vector(4 downto 0);
  end record vinst_ldst_fields_t;
    
  type vinst_trans_fields_t is record
    op    : std_ulogic_vector(1 downto 0);
    amode : std_ulogic_vector(1 downto 0);    
    c     : std_ulogic_vector(1 downto 0);
    imm5  : std_ulogic_vector(4 downto 0);
    imm8  : std_ulogic_vector(7 downto 0);
  end record vinst_trans_fields_t;
  
  type vinst_shuffle_fields_t is record
    vn     : std_ulogic_vector(7 downto 0);
    ssss   : std_ulogic_vector(3 downto 0);
    vwidth : std_ulogic_vector(1 downto 0);
  end record vinst_shuffle_fields_t;

  type vinst_fields_t is record
    f3xrsl   : vinst_3xrsl_fields_t;
    f3xrdl   : vinst_3xrdl_fields_t;
    f2xrsa   : vinst_2xrsa_fields_t;
    f1xrmi   : vinst_1xrmi_fields_t;
    fldst    : vinst_ldst_fields_t;
    ftrans   : vinst_trans_fields_t;
    fshuffle : vinst_shuffle_fields_t;
    u        : std_ulogic;
    w        : std_ulogic;
  end record vinst_fields_t;

  type vinst_t is record
    class   : std_ulogic;
    fields  : vinst_fields_t;
    destin  : vinst_destin_t;
    source  : vinst_source_t;
  end record vinst_t;

  function get_inst   (constant inst : in std_ulogic_vector(31 downto 0)) return inst_t;
  function get_vinst  (constant inst : in std_ulogic_vector(31 downto 0)) return vinst_t;

end package inst_pkg;

package body inst_pkg is  
  ----------------------------------------------------------------------------
  -- get instruction object from std_ulogic_vector(31 dwonto 0)
  ----------------------------------------------------------------------------
  function get_inst (constant inst : in std_ulogic_vector(31 downto 0)) return inst_t is
    variable vinst : inst_t;
  begin
    vinst.opcode       := inst(31 downto 26); 
    vinst.destin.reg_d := inst(25 downto 21);
    vinst.source.reg_a := inst(20 downto 16);
    vinst.source.reg_b := inst(15 downto 11);
    vinst.imm          := inst(15 downto  0);
    return vinst;
  end function get_inst;

  ----------------------------------------------------------------------------
  -- get instruction object from std_ulogic_vector(31 dwonto 0)
  ----------------------------------------------------------------------------
  function get_vinst (constant inst : in std_ulogic_vector(31 downto 0)) return vinst_t is
    variable vinst : vinst_t;
  begin
    vinst.class                  := inst(25);
    vinst.fields.f3xrsl.a        := inst(11 downto  8);
    vinst.fields.f3xrsl.b        := inst( 4);
    vinst.fields.f3xrsl.c        := inst(21 downto 20);

    vinst.fields.f3xrdl.a        := inst(11 downto  8);
    vinst.fields.f3xrdl.b        := inst(21 downto 20);

    vinst.fields.f2xrsa.a        := inst(11 downto  8);
    vinst.fields.f2xrsa.b        := inst( 6);
    vinst.fields.f2xrsa.l        := inst( 7);
    vinst.fields.f2xrsa.imm6     := inst(21 downto 16);

    vinst.fields.f1xrmi.op       := inst(5);
    vinst.fields.f1xrmi.imm8     := inst(24) & inst(18 downto 16) & inst(3 downto 0);
    vinst.fields.f1xrmi.cmode    := inst(11 downto 8);
    
    vinst.fields.fldst.a         := inst(11 downto  8);
    vinst.fields.fldst.b         := inst( 4);
    vinst.fields.fldst.c         := inst(21 downto 20);
    vinst.fields.fldst.imm5      := inst( 5) & inst( 3 downto  0);
    
    vinst.fields.ftrans.op       := inst( 9 downto  8);
    vinst.fields.ftrans.amode    := inst(11 downto 10);
    vinst.fields.ftrans.c        := inst(21 downto 20);
    vinst.fields.ftrans.imm5     := inst( 5) & inst( 3 downto  0);
    
    vinst.fields.fshuffle.vn     := inst(23) & inst( 6 downto  0);
    vinst.fields.fshuffle.ssss   := inst(12) & inst(16) & inst(11 downto 10);
    vinst.fields.fshuffle.vwidth := inst(21 downto 20);

    vinst.fields.u               := inst(24);
    vinst.fields.w               := inst( 6);

    vinst.destin.reg_d           := inst(22) & inst(15 downto 12);
    vinst.source.reg_a           := inst( 7) & inst(19 downto 16);
    vinst.source.reg_b           := inst( 5) & inst( 3 downto  0);
    return vinst;
  end function get_vinst;
    
end package body inst_pkg;

