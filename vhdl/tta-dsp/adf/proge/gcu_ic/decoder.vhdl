library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.tta0_globals.all;
use work.tta0_gcu_opcodes.all;
use work.tce_util.all;

entity tta0_decoder is

  port (
    instructionword : in std_logic_vector(INSTRUCTIONWIDTH-1 downto 0);
    pc_load : out std_logic;
    ra_load : out std_logic;
    pc_opcode : out std_logic_vector(0 downto 0);
    lock : in std_logic;
    lock_r : out std_logic;
    clk : in std_logic;
    rstx : in std_logic;
    locked : out std_logic;
    simm_B0 : out std_logic_vector(31 downto 0);
    simm_cntrl_B0 : out std_logic_vector(0 downto 0);
    simm_B1 : out std_logic_vector(31 downto 0);
    simm_cntrl_B1 : out std_logic_vector(0 downto 0);
    simm_B2 : out std_logic_vector(31 downto 0);
    simm_cntrl_B2 : out std_logic_vector(0 downto 0);
    socket_bool_i1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_bool_o1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_gcu_i1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_gcu_i2_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_gcu_o1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_ALU_i1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_ALU_i2_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_ALU_o1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_IMM_rd_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_R1_32_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_ALU_o1_1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_ALU_o1_1_1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_ALU_i1_1_1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_ALU_i1_1_1_1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_ALU_i1_1_1_1_1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_ALU_o1_1_1_1_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_ALU_o1_1_1_3_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_ALU_o1_1_1_2_1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_ALU_o1_1_1_2_1_1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_ALU_o1_1_1_2_1_2_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_R1_32_1_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_ALU_o1_1_2_1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_ALU_o1_1_1_1_2_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_ALU_i2_1_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_ALU_i2_2_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_ALU_o1_2_bus_cntrl : out std_logic_vector(2 downto 0);
    socket_R1_32_2_bus_cntrl : out std_logic_vector(1 downto 0);
    socket_R1_32_1_2_bus_cntrl : out std_logic_vector(0 downto 0);
    socket_ALU_i1_1_1_1_2_bus_cntrl : out std_logic_vector(0 downto 0);
    fu_ALU_0_in1t_load : out std_logic;
    fu_ALU_0_in2_load : out std_logic;
    fu_ALU_0_opc : out std_logic_vector(3 downto 0);
    fu_VLSU_in1t_load : out std_logic;
    fu_VLSU_in3_load : out std_logic;
    fu_VLSU_opc : out std_logic_vector(0 downto 0);
    fu_VALU_int0_load : out std_logic;
    fu_VALU_in2_load : out std_logic;
    fu_VALU_in1_load : out std_logic;
    fu_VALU_opc : out std_logic_vector(3 downto 0);
    fu_VBCAST_in1t_load : out std_logic;
    fu_VEXTRACT_in1t_load : out std_logic;
    fu_VEXTRACT_in2_load : out std_logic;
    fu_ALU_1_in1t_load : out std_logic;
    fu_ALU_1_in2_load : out std_logic;
    fu_ALU_1_opc : out std_logic_vector(3 downto 0);
    fu_PARAM_LSU_in1t_load : out std_logic;
    fu_PARAM_LSU_in2_load : out std_logic;
    fu_PARAM_LSU_opc : out std_logic_vector(2 downto 0);
    fu_DATA_LSU_in1t_load : out std_logic;
    fu_DATA_LSU_in2_load : out std_logic;
    fu_DATA_LSU_opc : out std_logic_vector(2 downto 0);
    rf_BOOL_wr_load : out std_logic;
    rf_BOOL_wr_opc : out std_logic_vector(0 downto 0);
    rf_BOOL_rd_load : out std_logic;
    rf_BOOL_rd_opc : out std_logic_vector(0 downto 0);
    rf_RF_32_0_R1_32_load : out std_logic;
    rf_RF_32_0_R1_32_opc : out std_logic_vector(4 downto 0);
    rf_RF_32_0_W1_32_load : out std_logic;
    rf_RF_32_0_W1_32_opc : out std_logic_vector(4 downto 0);
    rf_RF_32_0_R2_load : out std_logic;
    rf_RF_32_0_R2_opc : out std_logic_vector(4 downto 0);
    rf_RF_128_0_R1_32_load : out std_logic;
    rf_RF_128_0_R1_32_opc : out std_logic_vector(4 downto 0);
    rf_RF_128_0_W1_32_load : out std_logic;
    rf_RF_128_0_W1_32_opc : out std_logic_vector(4 downto 0);
    rf_RF_128_0_R2_load : out std_logic;
    rf_RF_128_0_R2_opc : out std_logic_vector(4 downto 0);
    iu_IU_1x32_r0_read_load : out std_logic;
    iu_IU_1x32_r0_read_opc : out std_logic_vector(0 downto 0);
    iu_IU_1x32_write : out std_logic_vector(31 downto 0);
    iu_IU_1x32_write_load : out std_logic;
    iu_IU_1x32_write_opc : out std_logic_vector(0 downto 0);
    rf_guard_BOOL_0 : in std_logic;
    rf_guard_BOOL_1 : in std_logic;
    lock_req : in std_logic_vector(2 downto 0);
    glock : out std_logic_vector(12 downto 0));

end tta0_decoder;

architecture rtl_andor of tta0_decoder is

  -- signals for source, destination and guard fields
  signal move_B0 : std_logic_vector(22 downto 0);
  signal src_B0 : std_logic_vector(12 downto 0);
  signal dst_B0 : std_logic_vector(6 downto 0);
  signal grd_B0 : std_logic_vector(2 downto 0);
  signal move_B1 : std_logic_vector(17 downto 0);
  signal src_B1 : std_logic_vector(8 downto 0);
  signal dst_B1 : std_logic_vector(5 downto 0);
  signal grd_B1 : std_logic_vector(2 downto 0);
  signal move_B2 : std_logic_vector(17 downto 0);
  signal src_B2 : std_logic_vector(8 downto 0);
  signal dst_B2 : std_logic_vector(5 downto 0);
  signal grd_B2 : std_logic_vector(2 downto 0);
  signal move_VB0 : std_logic_vector(8 downto 0);
  signal src_VB0 : std_logic_vector(0 downto 0);
  signal dst_VB0 : std_logic_vector(4 downto 0);
  signal grd_VB0 : std_logic_vector(2 downto 0);
  signal move_VB1 : std_logic_vector(2 downto 0);
  signal grd_VB1 : std_logic_vector(2 downto 0);
  signal move_VB2 : std_logic_vector(6 downto 0);
  signal dst_VB2 : std_logic_vector(3 downto 0);
  signal grd_VB2 : std_logic_vector(2 downto 0);
  signal move_VB3 : std_logic_vector(2 downto 0);
  signal grd_VB3 : std_logic_vector(2 downto 0);
  signal move_VB4 : std_logic_vector(13 downto 0);
  signal src_VB4 : std_logic_vector(5 downto 0);
  signal dst_VB4 : std_logic_vector(4 downto 0);
  signal grd_VB4 : std_logic_vector(2 downto 0);
  signal move_VB5 : std_logic_vector(9 downto 0);
  signal src_VB5 : std_logic_vector(4 downto 0);
  signal dst_VB5 : std_logic_vector(1 downto 0);
  signal grd_VB5 : std_logic_vector(2 downto 0);
  signal move_VB6 : std_logic_vector(13 downto 0);
  signal src_VB6 : std_logic_vector(5 downto 0);
  signal dst_VB6 : std_logic_vector(4 downto 0);
  signal grd_VB6 : std_logic_vector(2 downto 0);

  -- signals for dedicated immediate slots

  -- signal for long immediate tag
  signal limm_tag : std_logic_vector(0 downto 0);

  -- squash signals
  signal squash_B0 : std_logic;
  signal squash_B1 : std_logic;
  signal squash_B2 : std_logic;
  signal squash_VB0 : std_logic;
  signal squash_VB1 : std_logic;
  signal squash_VB2 : std_logic;
  signal squash_VB3 : std_logic;
  signal squash_VB4 : std_logic;
  signal squash_VB5 : std_logic;
  signal squash_VB6 : std_logic;

  -- socket control signals
  signal socket_bool_i1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_bool_o1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_gcu_i1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_gcu_i2_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_gcu_o1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_ALU_i1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_ALU_i2_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_ALU_o1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_IMM_rd_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_R1_32_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_ALU_o1_1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_ALU_o1_1_1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_ALU_i1_1_1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_ALU_i1_1_1_1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_ALU_i1_1_1_1_1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_ALU_o1_1_1_1_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_ALU_o1_1_1_3_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_ALU_o1_1_1_2_1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_ALU_o1_1_1_2_1_1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_ALU_o1_1_1_2_1_2_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_R1_32_1_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_ALU_o1_1_2_1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_ALU_o1_1_1_1_2_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_ALU_i2_1_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_ALU_i2_2_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_ALU_o1_2_bus_cntrl_reg : std_logic_vector(2 downto 0);
  signal socket_R1_32_2_bus_cntrl_reg : std_logic_vector(1 downto 0);
  signal socket_R1_32_1_2_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal socket_ALU_i1_1_1_1_2_bus_cntrl_reg : std_logic_vector(0 downto 0);
  signal simm_B0_reg : std_logic_vector(31 downto 0);
  signal simm_cntrl_B0_reg : std_logic_vector(0 downto 0);
  signal simm_B1_reg : std_logic_vector(31 downto 0);
  signal simm_cntrl_B1_reg : std_logic_vector(0 downto 0);
  signal simm_B2_reg : std_logic_vector(31 downto 0);
  signal simm_cntrl_B2_reg : std_logic_vector(0 downto 0);

  -- FU control signals
  signal fu_ALU_0_in1t_load_reg : std_logic;
  signal fu_ALU_0_in2_load_reg : std_logic;
  signal fu_ALU_0_opc_reg : std_logic_vector(3 downto 0);
  signal fu_VLSU_in1t_load_reg : std_logic;
  signal fu_VLSU_in3_load_reg : std_logic;
  signal fu_VLSU_opc_reg : std_logic_vector(0 downto 0);
  signal fu_VALU_int0_load_reg : std_logic;
  signal fu_VALU_in2_load_reg : std_logic;
  signal fu_VALU_in1_load_reg : std_logic;
  signal fu_VALU_opc_reg : std_logic_vector(3 downto 0);
  signal fu_VBCAST_in1t_load_reg : std_logic;
  signal fu_VEXTRACT_in1t_load_reg : std_logic;
  signal fu_VEXTRACT_in2_load_reg : std_logic;
  signal fu_ALU_1_in1t_load_reg : std_logic;
  signal fu_ALU_1_in2_load_reg : std_logic;
  signal fu_ALU_1_opc_reg : std_logic_vector(3 downto 0);
  signal fu_PARAM_LSU_in1t_load_reg : std_logic;
  signal fu_PARAM_LSU_in2_load_reg : std_logic;
  signal fu_PARAM_LSU_opc_reg : std_logic_vector(2 downto 0);
  signal fu_DATA_LSU_in1t_load_reg : std_logic;
  signal fu_DATA_LSU_in2_load_reg : std_logic;
  signal fu_DATA_LSU_opc_reg : std_logic_vector(2 downto 0);
  signal fu_gcu_pc_load_reg : std_logic;
  signal fu_gcu_ra_load_reg : std_logic;
  signal fu_gcu_opc_reg : std_logic_vector(0 downto 0);

  -- RF control signals
  signal rf_BOOL_wr_load_reg : std_logic;
  signal rf_BOOL_wr_opc_reg : std_logic_vector(0 downto 0);
  signal rf_BOOL_rd_load_reg : std_logic;
  signal rf_BOOL_rd_opc_reg : std_logic_vector(0 downto 0);
  signal rf_RF_32_0_R1_32_load_reg : std_logic;
  signal rf_RF_32_0_R1_32_opc_reg : std_logic_vector(4 downto 0);
  signal rf_RF_32_0_W1_32_load_reg : std_logic;
  signal rf_RF_32_0_W1_32_opc_reg : std_logic_vector(4 downto 0);
  signal rf_RF_32_0_R2_load_reg : std_logic;
  signal rf_RF_32_0_R2_opc_reg : std_logic_vector(4 downto 0);
  signal rf_RF_128_0_R1_32_load_reg : std_logic;
  signal rf_RF_128_0_R1_32_opc_reg : std_logic_vector(4 downto 0);
  signal rf_RF_128_0_W1_32_load_reg : std_logic;
  signal rf_RF_128_0_W1_32_opc_reg : std_logic_vector(4 downto 0);
  signal rf_RF_128_0_R2_load_reg : std_logic;
  signal rf_RF_128_0_R2_opc_reg : std_logic_vector(4 downto 0);

  signal merged_glock_req : std_logic;
  signal pre_decode_merged_glock : std_logic;
  signal post_decode_merged_glock : std_logic;
  signal post_decode_merged_glock_r : std_logic;

  signal decode_fill_lock_reg : std_logic;
begin

  -- dismembering of instruction
  process (instructionword)
  begin --process
    move_B0 <= instructionword(23-1 downto 0);
    src_B0 <= instructionword(19 downto 7);
    dst_B0 <= instructionword(6 downto 0);
    grd_B0 <= instructionword(22 downto 20);
    move_B1 <= instructionword(41-1 downto 23);
    src_B1 <= instructionword(37 downto 29);
    dst_B1 <= instructionword(28 downto 23);
    grd_B1 <= instructionword(40 downto 38);
    move_B2 <= instructionword(59-1 downto 41);
    src_B2 <= instructionword(55 downto 47);
    dst_B2 <= instructionword(46 downto 41);
    grd_B2 <= instructionword(58 downto 56);
    move_VB0 <= instructionword(68-1 downto 59);
    src_VB0 <= instructionword(64 downto 64);
    dst_VB0 <= instructionword(63 downto 59);
    grd_VB0 <= instructionword(67 downto 65);
    move_VB1 <= instructionword(71-1 downto 68);
    grd_VB1 <= instructionword(70 downto 68);
    move_VB2 <= instructionword(78-1 downto 71);
    dst_VB2 <= instructionword(74 downto 71);
    grd_VB2 <= instructionword(77 downto 75);
    move_VB3 <= instructionword(81-1 downto 78);
    grd_VB3 <= instructionword(80 downto 78);
    move_VB4 <= instructionword(95-1 downto 81);
    src_VB4 <= instructionword(91 downto 86);
    dst_VB4 <= instructionword(85 downto 81);
    grd_VB4 <= instructionword(94 downto 92);
    move_VB5 <= instructionword(105-1 downto 95);
    src_VB5 <= instructionword(101 downto 97);
    dst_VB5 <= instructionword(96 downto 95);
    grd_VB5 <= instructionword(104 downto 102);
    move_VB6 <= instructionword(119-1 downto 105);
    src_VB6 <= instructionword(115 downto 110);
    dst_VB6 <= instructionword(109 downto 105);
    grd_VB6 <= instructionword(118 downto 116);

    limm_tag <= instructionword(119 downto 119);
  end process;

  -- map control registers to outputs
  fu_ALU_0_in1t_load <= fu_ALU_0_in1t_load_reg;
  fu_ALU_0_in2_load <= fu_ALU_0_in2_load_reg;
  fu_ALU_0_opc <= fu_ALU_0_opc_reg;

  fu_VLSU_in1t_load <= fu_VLSU_in1t_load_reg;
  fu_VLSU_in3_load <= fu_VLSU_in3_load_reg;
  fu_VLSU_opc <= fu_VLSU_opc_reg;

  fu_VALU_int0_load <= fu_VALU_int0_load_reg;
  fu_VALU_in2_load <= fu_VALU_in2_load_reg;
  fu_VALU_in1_load <= fu_VALU_in1_load_reg;
  fu_VALU_opc <= fu_VALU_opc_reg;

  fu_VBCAST_in1t_load <= fu_VBCAST_in1t_load_reg;

  fu_VEXTRACT_in1t_load <= fu_VEXTRACT_in1t_load_reg;
  fu_VEXTRACT_in2_load <= fu_VEXTRACT_in2_load_reg;

  fu_ALU_1_in1t_load <= fu_ALU_1_in1t_load_reg;
  fu_ALU_1_in2_load <= fu_ALU_1_in2_load_reg;
  fu_ALU_1_opc <= fu_ALU_1_opc_reg;

  fu_PARAM_LSU_in1t_load <= fu_PARAM_LSU_in1t_load_reg;
  fu_PARAM_LSU_in2_load <= fu_PARAM_LSU_in2_load_reg;
  fu_PARAM_LSU_opc <= fu_PARAM_LSU_opc_reg;

  fu_DATA_LSU_in1t_load <= fu_DATA_LSU_in1t_load_reg;
  fu_DATA_LSU_in2_load <= fu_DATA_LSU_in2_load_reg;
  fu_DATA_LSU_opc <= fu_DATA_LSU_opc_reg;

  ra_load <= fu_gcu_ra_load_reg;
  pc_load <= fu_gcu_pc_load_reg;
  pc_opcode <= fu_gcu_opc_reg;
  rf_BOOL_wr_load <= rf_BOOL_wr_load_reg;
  rf_BOOL_wr_opc <= rf_BOOL_wr_opc_reg;
  rf_BOOL_rd_load <= rf_BOOL_rd_load_reg;
  rf_BOOL_rd_opc <= rf_BOOL_rd_opc_reg;
  rf_RF_32_0_R1_32_load <= rf_RF_32_0_R1_32_load_reg;
  rf_RF_32_0_R1_32_opc <= rf_RF_32_0_R1_32_opc_reg;
  rf_RF_32_0_W1_32_load <= rf_RF_32_0_W1_32_load_reg;
  rf_RF_32_0_W1_32_opc <= rf_RF_32_0_W1_32_opc_reg;
  rf_RF_32_0_R2_load <= rf_RF_32_0_R2_load_reg;
  rf_RF_32_0_R2_opc <= rf_RF_32_0_R2_opc_reg;
  rf_RF_128_0_R1_32_load <= rf_RF_128_0_R1_32_load_reg;
  rf_RF_128_0_R1_32_opc <= rf_RF_128_0_R1_32_opc_reg;
  rf_RF_128_0_W1_32_load <= rf_RF_128_0_W1_32_load_reg;
  rf_RF_128_0_W1_32_opc <= rf_RF_128_0_W1_32_opc_reg;
  rf_RF_128_0_R2_load <= rf_RF_128_0_R2_load_reg;
  rf_RF_128_0_R2_opc <= rf_RF_128_0_R2_opc_reg;
  iu_IU_1x32_r0_read_opc <= "0";
  iu_IU_1x32_write_opc <= "0";
  socket_bool_i1_bus_cntrl <= socket_bool_i1_bus_cntrl_reg;
  socket_bool_o1_bus_cntrl <= socket_bool_o1_bus_cntrl_reg;
  socket_gcu_i1_bus_cntrl <= socket_gcu_i1_bus_cntrl_reg;
  socket_gcu_i2_bus_cntrl <= socket_gcu_i2_bus_cntrl_reg;
  socket_gcu_o1_bus_cntrl <= socket_gcu_o1_bus_cntrl_reg;
  socket_ALU_i1_bus_cntrl <= socket_ALU_i1_bus_cntrl_reg;
  socket_ALU_i2_bus_cntrl <= socket_ALU_i2_bus_cntrl_reg;
  socket_ALU_o1_bus_cntrl <= socket_ALU_o1_bus_cntrl_reg;
  socket_IMM_rd_bus_cntrl <= socket_IMM_rd_bus_cntrl_reg;
  socket_R1_32_bus_cntrl <= socket_R1_32_bus_cntrl_reg;
  socket_ALU_o1_1_bus_cntrl <= socket_ALU_o1_1_bus_cntrl_reg;
  socket_ALU_o1_1_1_bus_cntrl <= socket_ALU_o1_1_1_bus_cntrl_reg;
  socket_ALU_i1_1_1_bus_cntrl <= socket_ALU_i1_1_1_bus_cntrl_reg;
  socket_ALU_i1_1_1_1_bus_cntrl <= socket_ALU_i1_1_1_1_bus_cntrl_reg;
  socket_ALU_i1_1_1_1_1_bus_cntrl <= socket_ALU_i1_1_1_1_1_bus_cntrl_reg;
  socket_ALU_o1_1_1_1_bus_cntrl <= socket_ALU_o1_1_1_1_bus_cntrl_reg;
  socket_ALU_o1_1_1_3_bus_cntrl <= socket_ALU_o1_1_1_3_bus_cntrl_reg;
  socket_ALU_o1_1_1_2_1_bus_cntrl <= socket_ALU_o1_1_1_2_1_bus_cntrl_reg;
  socket_ALU_o1_1_1_2_1_1_bus_cntrl <= socket_ALU_o1_1_1_2_1_1_bus_cntrl_reg;
  socket_ALU_o1_1_1_2_1_2_bus_cntrl <= socket_ALU_o1_1_1_2_1_2_bus_cntrl_reg;
  socket_R1_32_1_bus_cntrl <= socket_R1_32_1_bus_cntrl_reg;
  socket_ALU_o1_1_2_1_bus_cntrl <= socket_ALU_o1_1_2_1_bus_cntrl_reg;
  socket_ALU_o1_1_1_1_2_bus_cntrl <= socket_ALU_o1_1_1_1_2_bus_cntrl_reg;
  socket_ALU_i2_1_bus_cntrl <= socket_ALU_i2_1_bus_cntrl_reg;
  socket_ALU_i2_2_bus_cntrl <= socket_ALU_i2_2_bus_cntrl_reg;
  socket_ALU_o1_2_bus_cntrl <= socket_ALU_o1_2_bus_cntrl_reg;
  socket_R1_32_2_bus_cntrl <= socket_R1_32_2_bus_cntrl_reg;
  socket_R1_32_1_2_bus_cntrl <= socket_R1_32_1_2_bus_cntrl_reg;
  socket_ALU_i1_1_1_1_2_bus_cntrl <= socket_ALU_i1_1_1_1_2_bus_cntrl_reg;
  simm_cntrl_B0 <= simm_cntrl_B0_reg;
  simm_B0 <= simm_B0_reg;
  simm_cntrl_B1 <= simm_cntrl_B1_reg;
  simm_B1 <= simm_B1_reg;
  simm_cntrl_B2 <= simm_cntrl_B2_reg;
  simm_B2 <= simm_B2_reg;

  -- generate signal squash_B0
  process (grd_B0, move_B0, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_B0(22 downto 20))) = 5) then
      squash_B0 <= '1';
    else
      sel := conv_integer(unsigned(grd_B0));
      case sel is
        when 1 =>
          squash_B0 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_B0 <= rf_guard_BOOL_0;
        when 3 =>
          squash_B0 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_B0 <= rf_guard_BOOL_1;
        when others =>
          squash_B0 <= '0';
      end case;
    end if;
  end process;

  -- generate signal squash_B1
  process (grd_B1, limm_tag, move_B1, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    if (conv_integer(unsigned(limm_tag)) = 1) then
      squash_B1 <= '1';
    -- squash by move NOP encoding
    elsif (conv_integer(unsigned(move_B1(17 downto 15))) = 5) then
      squash_B1 <= '1';
    else
      sel := conv_integer(unsigned(grd_B1));
      case sel is
        when 1 =>
          squash_B1 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_B1 <= rf_guard_BOOL_0;
        when 3 =>
          squash_B1 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_B1 <= rf_guard_BOOL_1;
        when others =>
          squash_B1 <= '0';
      end case;
    end if;
  end process;

  -- generate signal squash_B2
  process (grd_B2, limm_tag, move_B2, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    if (conv_integer(unsigned(limm_tag)) = 1) then
      squash_B2 <= '1';
    -- squash by move NOP encoding
    elsif (conv_integer(unsigned(move_B2(17 downto 15))) = 5) then
      squash_B2 <= '1';
    else
      sel := conv_integer(unsigned(grd_B2));
      case sel is
        when 1 =>
          squash_B2 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_B2 <= rf_guard_BOOL_0;
        when 3 =>
          squash_B2 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_B2 <= rf_guard_BOOL_1;
        when others =>
          squash_B2 <= '0';
      end case;
    end if;
  end process;

  -- generate signal squash_VB0
  process (grd_VB0, move_VB0, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_VB0(8 downto 6))) = 5) then
      squash_VB0 <= '1';
    else
      sel := conv_integer(unsigned(grd_VB0));
      case sel is
        when 1 =>
          squash_VB0 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_VB0 <= rf_guard_BOOL_0;
        when 3 =>
          squash_VB0 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_VB0 <= rf_guard_BOOL_1;
        when others =>
          squash_VB0 <= '0';
      end case;
    end if;
  end process;

  -- generate signal squash_VB1
  process (grd_VB1, move_VB1, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_VB1(2 downto 0))) = 5) then
      squash_VB1 <= '1';
    else
      sel := conv_integer(unsigned(grd_VB1));
      case sel is
        when 1 =>
          squash_VB1 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_VB1 <= rf_guard_BOOL_0;
        when 3 =>
          squash_VB1 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_VB1 <= rf_guard_BOOL_1;
        when others =>
          squash_VB1 <= '0';
      end case;
    end if;
  end process;

  -- generate signal squash_VB2
  process (grd_VB2, move_VB2, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_VB2(6 downto 4))) = 5) then
      squash_VB2 <= '1';
    else
      sel := conv_integer(unsigned(grd_VB2));
      case sel is
        when 1 =>
          squash_VB2 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_VB2 <= rf_guard_BOOL_0;
        when 3 =>
          squash_VB2 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_VB2 <= rf_guard_BOOL_1;
        when others =>
          squash_VB2 <= '0';
      end case;
    end if;
  end process;

  -- generate signal squash_VB3
  process (grd_VB3, move_VB3, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_VB3(2 downto 0))) = 5) then
      squash_VB3 <= '1';
    else
      sel := conv_integer(unsigned(grd_VB3));
      case sel is
        when 1 =>
          squash_VB3 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_VB3 <= rf_guard_BOOL_0;
        when 3 =>
          squash_VB3 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_VB3 <= rf_guard_BOOL_1;
        when others =>
          squash_VB3 <= '0';
      end case;
    end if;
  end process;

  -- generate signal squash_VB4
  process (grd_VB4, move_VB4, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_VB4(13 downto 11))) = 5) then
      squash_VB4 <= '1';
    else
      sel := conv_integer(unsigned(grd_VB4));
      case sel is
        when 1 =>
          squash_VB4 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_VB4 <= rf_guard_BOOL_0;
        when 3 =>
          squash_VB4 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_VB4 <= rf_guard_BOOL_1;
        when others =>
          squash_VB4 <= '0';
      end case;
    end if;
  end process;

  -- generate signal squash_VB5
  process (grd_VB5, move_VB5, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_VB5(9 downto 7))) = 5) then
      squash_VB5 <= '1';
    else
      sel := conv_integer(unsigned(grd_VB5));
      case sel is
        when 1 =>
          squash_VB5 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_VB5 <= rf_guard_BOOL_0;
        when 3 =>
          squash_VB5 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_VB5 <= rf_guard_BOOL_1;
        when others =>
          squash_VB5 <= '0';
      end case;
    end if;
  end process;

  -- generate signal squash_VB6
  process (grd_VB6, move_VB6, rf_guard_BOOL_0, rf_guard_BOOL_1)
    variable sel : integer;
  begin --process
    -- squash by move NOP encoding
    if (conv_integer(unsigned(move_VB6(13 downto 11))) = 5) then
      squash_VB6 <= '1';
    else
      sel := conv_integer(unsigned(grd_VB6));
      case sel is
        when 1 =>
          squash_VB6 <= not rf_guard_BOOL_0;
        when 2 =>
          squash_VB6 <= rf_guard_BOOL_0;
        when 3 =>
          squash_VB6 <= not rf_guard_BOOL_1;
        when 4 =>
          squash_VB6 <= rf_guard_BOOL_1;
        when others =>
          squash_VB6 <= '0';
      end case;
    end if;
  end process;


  --long immediate write process
  process (clk, rstx)
  begin --process
    if (rstx = '0') then
      iu_IU_1x32_write_load <= '0';
      iu_IU_1x32_write <= (others => '0');
    elsif (clk'event and clk = '1') then
      if pre_decode_merged_glock = '0' then
        if (conv_integer(unsigned(limm_tag)) = 0) then
          iu_IU_1x32_write_load <= '0';
          iu_IU_1x32_write(31 downto 0) <= tce_sxt("0", 32);
        else
          iu_IU_1x32_write(31 downto 16) <= tce_ext(instructionword(56 downto 41), 16);
          iu_IU_1x32_write(15 downto 0) <= instructionword(38 downto 23);
          iu_IU_1x32_write_load <= '1';
        end if;
      end if;
    end if;
  end process;


  -- main decoding process
  process (clk, rstx)
  begin
    if (rstx = '0') then
      socket_bool_i1_bus_cntrl_reg <= (others => '0');
      socket_bool_o1_bus_cntrl_reg <= (others => '0');
      socket_gcu_i1_bus_cntrl_reg <= (others => '0');
      socket_gcu_i2_bus_cntrl_reg <= (others => '0');
      socket_gcu_o1_bus_cntrl_reg <= (others => '0');
      socket_ALU_i1_bus_cntrl_reg <= (others => '0');
      socket_ALU_i2_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_bus_cntrl_reg <= (others => '0');
      socket_IMM_rd_bus_cntrl_reg <= (others => '0');
      socket_R1_32_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_1_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_1_1_bus_cntrl_reg <= (others => '0');
      socket_ALU_i1_1_1_bus_cntrl_reg <= (others => '0');
      socket_ALU_i1_1_1_1_bus_cntrl_reg <= (others => '0');
      socket_ALU_i1_1_1_1_1_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_1_1_1_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_1_1_3_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_1_1_2_1_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_1_1_2_1_1_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_1_1_2_1_2_bus_cntrl_reg <= (others => '0');
      socket_R1_32_1_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_1_2_1_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_1_1_1_2_bus_cntrl_reg <= (others => '0');
      socket_ALU_i2_1_bus_cntrl_reg <= (others => '0');
      socket_ALU_i2_2_bus_cntrl_reg <= (others => '0');
      socket_ALU_o1_2_bus_cntrl_reg <= (others => '0');
      socket_R1_32_2_bus_cntrl_reg <= (others => '0');
      socket_R1_32_1_2_bus_cntrl_reg <= (others => '0');
      socket_ALU_i1_1_1_1_2_bus_cntrl_reg <= (others => '0');
      simm_B0_reg <= (others => '0');
      simm_cntrl_B0_reg <= (others => '0');
      simm_B1_reg <= (others => '0');
      simm_cntrl_B1_reg <= (others => '0');
      simm_B2_reg <= (others => '0');
      simm_cntrl_B2_reg <= (others => '0');
      fu_ALU_0_opc_reg <= (others => '0');
      fu_VLSU_opc_reg <= (others => '0');
      fu_VALU_opc_reg <= (others => '0');
      fu_ALU_1_opc_reg <= (others => '0');
      fu_PARAM_LSU_opc_reg <= (others => '0');
      fu_DATA_LSU_opc_reg <= (others => '0');
      fu_gcu_opc_reg <= (others => '0');
      rf_BOOL_wr_opc_reg <= (others => '0');
      rf_BOOL_rd_opc_reg <= (others => '0');
      rf_RF_32_0_R1_32_opc_reg <= (others => '0');
      rf_RF_32_0_W1_32_opc_reg <= (others => '0');
      rf_RF_32_0_R2_opc_reg <= (others => '0');
      rf_RF_128_0_R1_32_opc_reg <= (others => '0');
      rf_RF_128_0_W1_32_opc_reg <= (others => '0');
      rf_RF_128_0_R2_opc_reg <= (others => '0');

      fu_ALU_0_in1t_load_reg <= '0';
      fu_ALU_0_in2_load_reg <= '0';
      fu_VLSU_in1t_load_reg <= '0';
      fu_VLSU_in3_load_reg <= '0';
      fu_VALU_int0_load_reg <= '0';
      fu_VALU_in2_load_reg <= '0';
      fu_VALU_in1_load_reg <= '0';
      fu_VBCAST_in1t_load_reg <= '0';
      fu_VEXTRACT_in1t_load_reg <= '0';
      fu_VEXTRACT_in2_load_reg <= '0';
      fu_ALU_1_in1t_load_reg <= '0';
      fu_ALU_1_in2_load_reg <= '0';
      fu_PARAM_LSU_in1t_load_reg <= '0';
      fu_PARAM_LSU_in2_load_reg <= '0';
      fu_DATA_LSU_in1t_load_reg <= '0';
      fu_DATA_LSU_in2_load_reg <= '0';
      fu_gcu_pc_load_reg <= '0';
      fu_gcu_ra_load_reg <= '0';
      rf_BOOL_wr_load_reg <= '0';
      rf_BOOL_rd_load_reg <= '0';
      rf_RF_32_0_R1_32_load_reg <= '0';
      rf_RF_32_0_W1_32_load_reg <= '0';
      rf_RF_32_0_R2_load_reg <= '0';
      rf_RF_128_0_R1_32_load_reg <= '0';
      rf_RF_128_0_W1_32_load_reg <= '0';
      rf_RF_128_0_R2_load_reg <= '0';
      iu_IU_1x32_r0_read_load <= '0';


    elsif (clk'event and clk = '1') then -- rising clock edge
    if (pre_decode_merged_glock = '0') then

        -- bus control signals for output mux
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 8))) = 17) then
          socket_bool_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_bool_o1_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 5))) = 10) then
          socket_bool_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_bool_o1_bus_cntrl_reg(1) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 8))) = 18) then
          socket_gcu_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_gcu_o1_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 5))) = 11) then
          socket_gcu_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_gcu_o1_bus_cntrl_reg(1) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 8))) = 19) then
          socket_ALU_o1_bus_cntrl_reg(0) <= '1';
        else
          socket_ALU_o1_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 5))) = 9) then
          socket_ALU_o1_bus_cntrl_reg(2) <= '1';
        else
          socket_ALU_o1_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 5))) = 12) then
          socket_ALU_o1_bus_cntrl_reg(1) <= '1';
        else
          socket_ALU_o1_bus_cntrl_reg(1) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 8))) = 20) then
          socket_IMM_rd_bus_cntrl_reg(1) <= '1';
        else
          socket_IMM_rd_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 5))) = 10) then
          socket_IMM_rd_bus_cntrl_reg(2) <= '1';
        else
          socket_IMM_rd_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 5))) = 13) then
          socket_IMM_rd_bus_cntrl_reg(0) <= '1';
        else
          socket_IMM_rd_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 8))) = 16) then
          socket_R1_32_bus_cntrl_reg(0) <= '1';
        else
          socket_R1_32_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 5))) = 8) then
          socket_R1_32_bus_cntrl_reg(1) <= '1';
        else
          socket_R1_32_bus_cntrl_reg(1) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_VB0 = '0' and conv_integer(unsigned(src_VB0(0 downto 0))) = 0) then
          socket_ALU_o1_1_bus_cntrl_reg(0) <= '1';
        else
          socket_ALU_o1_1_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_VB6 = '0' and conv_integer(unsigned(src_VB6(5 downto 3))) = 4) then
          socket_ALU_o1_1_bus_cntrl_reg(1) <= '1';
        else
          socket_ALU_o1_1_bus_cntrl_reg(1) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_VB4 = '0' and conv_integer(unsigned(src_VB4(5 downto 5))) = 1) then
          socket_ALU_o1_1_1_bus_cntrl_reg(1) <= '1';
        else
          socket_ALU_o1_1_1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_VB6 = '0' and conv_integer(unsigned(src_VB6(5 downto 3))) = 5) then
          socket_ALU_o1_1_1_bus_cntrl_reg(0) <= '1';
        else
          socket_ALU_o1_1_1_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_VB2 = '0' and true) then
          socket_ALU_o1_1_1_bus_cntrl_reg(2) <= '1';
        else
          socket_ALU_o1_1_1_bus_cntrl_reg(2) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 8))) = 21) then
          socket_ALU_o1_1_1_1_bus_cntrl_reg(1) <= '1';
        else
          socket_ALU_o1_1_1_1_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 5))) = 11) then
          socket_ALU_o1_1_1_1_bus_cntrl_reg(0) <= '1';
        else
          socket_ALU_o1_1_1_1_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 5))) = 14) then
          socket_ALU_o1_1_1_1_bus_cntrl_reg(2) <= '1';
        else
          socket_ALU_o1_1_1_1_bus_cntrl_reg(2) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_VB0 = '0' and conv_integer(unsigned(src_VB0(0 downto 0))) = 1) then
          socket_ALU_o1_1_1_3_bus_cntrl_reg(1) <= '1';
        else
          socket_ALU_o1_1_1_3_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_VB6 = '0' and conv_integer(unsigned(src_VB6(5 downto 3))) = 6) then
          socket_ALU_o1_1_1_3_bus_cntrl_reg(0) <= '1';
        else
          socket_ALU_o1_1_1_3_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_VB3 = '0' and true) then
          socket_ALU_o1_1_1_3_bus_cntrl_reg(2) <= '1';
        else
          socket_ALU_o1_1_1_3_bus_cntrl_reg(2) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_VB4 = '0' and conv_integer(unsigned(src_VB4(5 downto 5))) = 0) then
          socket_R1_32_1_bus_cntrl_reg(0) <= '1';
        else
          socket_R1_32_1_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_VB6 = '0' and conv_integer(unsigned(src_VB6(5 downto 5))) = 0) then
          socket_R1_32_1_bus_cntrl_reg(1) <= '1';
        else
          socket_R1_32_1_bus_cntrl_reg(1) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 8))) = 22) then
          socket_ALU_o1_1_2_1_bus_cntrl_reg(0) <= '1';
        else
          socket_ALU_o1_1_2_1_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 8))) = 23) then
          socket_ALU_o1_1_1_1_2_bus_cntrl_reg(1) <= '1';
        else
          socket_ALU_o1_1_1_1_2_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 5))) = 12) then
          socket_ALU_o1_1_1_1_2_bus_cntrl_reg(0) <= '1';
        else
          socket_ALU_o1_1_1_1_2_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 8))) = 24) then
          socket_ALU_o1_2_bus_cntrl_reg(0) <= '1';
        else
          socket_ALU_o1_2_bus_cntrl_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 5))) = 13) then
          socket_ALU_o1_2_bus_cntrl_reg(2) <= '1';
        else
          socket_ALU_o1_2_bus_cntrl_reg(2) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 5))) = 15) then
          socket_ALU_o1_2_bus_cntrl_reg(1) <= '1';
        else
          socket_ALU_o1_2_bus_cntrl_reg(1) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 5))) = 8) then
          socket_R1_32_2_bus_cntrl_reg(1) <= '1';
        else
          socket_R1_32_2_bus_cntrl_reg(1) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 5))) = 9) then
          socket_R1_32_2_bus_cntrl_reg(0) <= '1';
        else
          socket_R1_32_2_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        if (squash_VB5 = '0' and true) then
          socket_R1_32_1_2_bus_cntrl_reg(0) <= '1';
        else
          socket_R1_32_1_2_bus_cntrl_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- bus control signals for short immediate sockets
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 12))) = 0) then
          simm_cntrl_B0_reg(0) <= '1';
        simm_B0_reg <= tce_sxt(src_B0(11 downto 0), simm_B0_reg'length);
        else
          simm_cntrl_B0_reg(0) <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 8))) = 0) then
          simm_cntrl_B1_reg(0) <= '1';
        simm_B1_reg <= tce_sxt(src_B1(7 downto 0), simm_B1_reg'length);
        else
          simm_cntrl_B1_reg(0) <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 8))) = 0) then
          simm_cntrl_B2_reg(0) <= '1';
        simm_B2_reg <= tce_sxt(src_B2(7 downto 0), simm_B2_reg'length);
        else
          simm_cntrl_B2_reg(0) <= '0';
        end if;
        -- data control signals for output sockets connected to FUs
        -- control signals for RF read ports
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 8))) = 17 and true) then
          rf_BOOL_rd_load_reg <= '1';
          rf_BOOL_rd_opc_reg <= tce_ext(src_B0(0 downto 0), rf_BOOL_rd_opc_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 5))) = 10 and true) then
          rf_BOOL_rd_load_reg <= '1';
          rf_BOOL_rd_opc_reg <= tce_ext(src_B1(0 downto 0), rf_BOOL_rd_opc_reg'length);
        else
          rf_BOOL_rd_load_reg <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 8))) = 16 and true) then
          rf_RF_32_0_R1_32_load_reg <= '1';
          rf_RF_32_0_R1_32_opc_reg <= tce_ext(src_B0(4 downto 0), rf_RF_32_0_R1_32_opc_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 5))) = 8 and true) then
          rf_RF_32_0_R1_32_load_reg <= '1';
          rf_RF_32_0_R1_32_opc_reg <= tce_ext(src_B1(4 downto 0), rf_RF_32_0_R1_32_opc_reg'length);
        else
          rf_RF_32_0_R1_32_load_reg <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 5))) = 8 and true) then
          rf_RF_32_0_R2_load_reg <= '1';
          rf_RF_32_0_R2_opc_reg <= tce_ext(src_B2(4 downto 0), rf_RF_32_0_R2_opc_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 5))) = 9 and true) then
          rf_RF_32_0_R2_load_reg <= '1';
          rf_RF_32_0_R2_opc_reg <= tce_ext(src_B1(4 downto 0), rf_RF_32_0_R2_opc_reg'length);
        else
          rf_RF_32_0_R2_load_reg <= '0';
        end if;
        if (squash_VB4 = '0' and conv_integer(unsigned(src_VB4(5 downto 5))) = 0 and true) then
          rf_RF_128_0_W1_32_load_reg <= '1';
          rf_RF_128_0_W1_32_opc_reg <= tce_ext(src_VB4(4 downto 0), rf_RF_128_0_W1_32_opc_reg'length);
        elsif (squash_VB6 = '0' and conv_integer(unsigned(src_VB6(5 downto 5))) = 0 and true) then
          rf_RF_128_0_W1_32_load_reg <= '1';
          rf_RF_128_0_W1_32_opc_reg <= tce_ext(src_VB6(4 downto 0), rf_RF_128_0_W1_32_opc_reg'length);
        else
          rf_RF_128_0_W1_32_load_reg <= '0';
        end if;
        if (squash_VB5 = '0' and true and true) then
          rf_RF_128_0_R2_load_reg <= '1';
          rf_RF_128_0_R2_opc_reg <= tce_ext(src_VB5(4 downto 0), rf_RF_128_0_R2_opc_reg'length);
        else
          rf_RF_128_0_R2_load_reg <= '0';
        end if;

        --control signals for IU read ports
        -- control signals for IU read ports
        if (squash_B0 = '0' and conv_integer(unsigned(src_B0(12 downto 8))) = 20) then
          iu_IU_1x32_r0_read_load <= '1';
        elsif (squash_B2 = '0' and conv_integer(unsigned(src_B2(8 downto 5))) = 10) then
          iu_IU_1x32_r0_read_load <= '1';
        elsif (squash_B1 = '0' and conv_integer(unsigned(src_B1(8 downto 5))) = 13) then
          iu_IU_1x32_r0_read_load <= '1';
        else
          iu_IU_1x32_r0_read_load <= '0';
        end if;

        -- control signals for FU inputs
        if (squash_B0 = '0' and conv_integer(unsigned(dst_B0(6 downto 4))) = 2) then
          fu_ALU_0_in1t_load_reg <= '1';
          fu_ALU_0_opc_reg <= dst_B0(3 downto 0);
          socket_ALU_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i1_bus_cntrl_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 4))) = 0) then
          fu_ALU_0_in1t_load_reg <= '1';
          fu_ALU_0_opc_reg <= dst_B2(3 downto 0);
          socket_ALU_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i1_bus_cntrl_reg'length);
        else
          fu_ALU_0_in1t_load_reg <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(dst_B0(6 downto 0))) = 63) then
          fu_ALU_0_in2_load_reg <= '1';
          socket_ALU_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i2_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 0))) = 31) then
          fu_ALU_0_in2_load_reg <= '1';
          socket_ALU_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i2_bus_cntrl_reg'length);
        else
          fu_ALU_0_in2_load_reg <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(dst_B0(6 downto 1))) = 30) then
          fu_VLSU_in1t_load_reg <= '1';
          fu_VLSU_opc_reg <= dst_B0(0 downto 0);
          socket_ALU_i1_1_1_1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i1_1_1_1_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 1))) = 14) then
          fu_VLSU_in1t_load_reg <= '1';
          fu_VLSU_opc_reg <= dst_B1(0 downto 0);
          socket_ALU_i1_1_1_1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i1_1_1_1_bus_cntrl_reg'length);
        else
          fu_VLSU_in1t_load_reg <= '0';
        end if;
        if (squash_VB5 = '0' and conv_integer(unsigned(dst_VB5(1 downto 0))) = 0) then
          fu_VLSU_in3_load_reg <= '1';
          socket_ALU_i1_1_1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i1_1_1_bus_cntrl_reg'length);
        elsif (squash_VB3 = '0' and true) then
          fu_VLSU_in3_load_reg <= '1';
          socket_ALU_i1_1_1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i1_1_1_bus_cntrl_reg'length);
        else
          fu_VLSU_in3_load_reg <= '0';
        end if;
        if (squash_VB0 = '0' and conv_integer(unsigned(dst_VB0(4 downto 4))) = 0) then
          fu_VALU_int0_load_reg <= '1';
          fu_VALU_opc_reg <= dst_VB0(3 downto 0);
          socket_ALU_o1_1_1_2_1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_o1_1_1_2_1_bus_cntrl_reg'length);
        elsif (squash_VB4 = '0' and conv_integer(unsigned(dst_VB4(4 downto 4))) = 0) then
          fu_VALU_int0_load_reg <= '1';
          fu_VALU_opc_reg <= dst_VB4(3 downto 0);
          socket_ALU_o1_1_1_2_1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_o1_1_1_2_1_bus_cntrl_reg'length);
        elsif (squash_VB2 = '0' and true) then
          fu_VALU_int0_load_reg <= '1';
          fu_VALU_opc_reg <= dst_VB2(3 downto 0);
          socket_ALU_o1_1_1_2_1_bus_cntrl_reg <= conv_std_logic_vector(2, socket_ALU_o1_1_1_2_1_bus_cntrl_reg'length);
        else
          fu_VALU_int0_load_reg <= '0';
        end if;
        if (squash_VB5 = '0' and conv_integer(unsigned(dst_VB5(1 downto 0))) = 1) then
          fu_VALU_in2_load_reg <= '1';
          socket_ALU_o1_1_1_2_1_1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_o1_1_1_2_1_1_bus_cntrl_reg'length);
        elsif (squash_VB1 = '0' and true) then
          fu_VALU_in2_load_reg <= '1';
          socket_ALU_o1_1_1_2_1_1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_o1_1_1_2_1_1_bus_cntrl_reg'length);
        else
          fu_VALU_in2_load_reg <= '0';
        end if;
        if (squash_VB0 = '0' and conv_integer(unsigned(dst_VB0(4 downto 4))) = 1) then
          fu_VALU_in1_load_reg <= '1';
          socket_ALU_o1_1_1_2_1_2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_o1_1_1_2_1_2_bus_cntrl_reg'length);
        elsif (squash_VB4 = '0' and conv_integer(unsigned(dst_VB4(4 downto 4))) = 1) then
          fu_VALU_in1_load_reg <= '1';
          socket_ALU_o1_1_1_2_1_2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_o1_1_1_2_1_2_bus_cntrl_reg'length);
        else
          fu_VALU_in1_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 0))) = 32) then
          fu_VBCAST_in1t_load_reg <= '1';
        else
          fu_VBCAST_in1t_load_reg <= '0';
        end if;
        if (squash_VB5 = '0' and conv_integer(unsigned(dst_VB5(1 downto 0))) = 2) then
          fu_VEXTRACT_in1t_load_reg <= '1';
        else
          fu_VEXTRACT_in1t_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 0))) = 33) then
          fu_VEXTRACT_in2_load_reg <= '1';
        else
          fu_VEXTRACT_in2_load_reg <= '0';
        end if;
        if (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 4))) = 1) then
          fu_ALU_1_in1t_load_reg <= '1';
          fu_ALU_1_opc_reg <= dst_B2(3 downto 0);
          socket_ALU_i2_2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i2_2_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 4))) = 0) then
          fu_ALU_1_in1t_load_reg <= '1';
          fu_ALU_1_opc_reg <= dst_B1(3 downto 0);
          socket_ALU_i2_2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i2_2_bus_cntrl_reg'length);
        else
          fu_ALU_1_in1t_load_reg <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(dst_B0(6 downto 0))) = 65) then
          fu_ALU_1_in2_load_reg <= '1';
          socket_ALU_i2_1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i2_1_bus_cntrl_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 4))) = 3) then
          fu_ALU_1_in2_load_reg <= '1';
          socket_ALU_i2_1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i2_1_bus_cntrl_reg'length);
        else
          fu_ALU_1_in2_load_reg <= '0';
        end if;
        if (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 3))) = 2) then
          fu_PARAM_LSU_in1t_load_reg <= '1';
          fu_PARAM_LSU_opc_reg <= dst_B1(2 downto 0);
        else
          fu_PARAM_LSU_in1t_load_reg <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(dst_B0(6 downto 0))) = 64) then
          fu_PARAM_LSU_in2_load_reg <= '1';
        else
          fu_PARAM_LSU_in2_load_reg <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(dst_B0(6 downto 3))) = 6) then
          fu_DATA_LSU_in1t_load_reg <= '1';
          fu_DATA_LSU_opc_reg <= dst_B0(2 downto 0);
          socket_ALU_i1_1_1_1_1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i1_1_1_1_1_bus_cntrl_reg'length);
        elsif (squash_B2 = '0' and conv_integer(unsigned(dst_B2(5 downto 4))) = 2) then
          fu_DATA_LSU_in1t_load_reg <= '1';
          fu_DATA_LSU_opc_reg <= dst_B2(2 downto 0);
          socket_ALU_i1_1_1_1_1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i1_1_1_1_1_bus_cntrl_reg'length);
        else
          fu_DATA_LSU_in1t_load_reg <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(dst_B0(6 downto 0))) = 66) then
          fu_DATA_LSU_in2_load_reg <= '1';
          socket_ALU_i1_1_1_1_2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_ALU_i1_1_1_1_2_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 0))) = 34) then
          fu_DATA_LSU_in2_load_reg <= '1';
          socket_ALU_i1_1_1_1_2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_ALU_i1_1_1_1_2_bus_cntrl_reg'length);
        else
          fu_DATA_LSU_in2_load_reg <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(dst_B0(6 downto 1))) = 29) then
          fu_gcu_pc_load_reg <= '1';
          fu_gcu_opc_reg <= dst_B0(0 downto 0);
          socket_gcu_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_gcu_i1_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 1))) = 13) then
          fu_gcu_pc_load_reg <= '1';
          fu_gcu_opc_reg <= dst_B1(0 downto 0);
          socket_gcu_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_gcu_i1_bus_cntrl_reg'length);
        else
          fu_gcu_pc_load_reg <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(dst_B0(6 downto 0))) = 62) then
          fu_gcu_ra_load_reg <= '1';
          socket_gcu_i2_bus_cntrl_reg <= conv_std_logic_vector(0, socket_gcu_i2_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 0))) = 30) then
          fu_gcu_ra_load_reg <= '1';
          socket_gcu_i2_bus_cntrl_reg <= conv_std_logic_vector(1, socket_gcu_i2_bus_cntrl_reg'length);
        else
          fu_gcu_ra_load_reg <= '0';
        end if;
        -- control signals for RF inputs
        if (squash_B0 = '0' and conv_integer(unsigned(dst_B0(6 downto 1))) = 28 and true) then
          rf_BOOL_wr_load_reg <= '1';
          rf_BOOL_wr_opc_reg <= dst_B0(0 downto 0);
          socket_bool_i1_bus_cntrl_reg <= conv_std_logic_vector(0, socket_bool_i1_bus_cntrl_reg'length);
        elsif (squash_B1 = '0' and conv_integer(unsigned(dst_B1(5 downto 1))) = 12 and true) then
          rf_BOOL_wr_load_reg <= '1';
          rf_BOOL_wr_opc_reg <= dst_B1(0 downto 0);
          socket_bool_i1_bus_cntrl_reg <= conv_std_logic_vector(1, socket_bool_i1_bus_cntrl_reg'length);
        else
          rf_BOOL_wr_load_reg <= '0';
        end if;
        if (squash_B0 = '0' and conv_integer(unsigned(dst_B0(6 downto 5))) = 0 and true) then
          rf_RF_32_0_W1_32_load_reg <= '1';
          rf_RF_32_0_W1_32_opc_reg <= dst_B0(4 downto 0);
        else
          rf_RF_32_0_W1_32_load_reg <= '0';
        end if;
        if (squash_VB6 = '0' and true and true) then
          rf_RF_128_0_R1_32_load_reg <= '1';
          rf_RF_128_0_R1_32_opc_reg <= dst_VB6(4 downto 0);
        else
          rf_RF_128_0_R1_32_load_reg <= '0';
        end if;
      end if;
    end if;
  end process;

  lock_reg_proc : process (clk, rstx)
  begin
    if (rstx = '0') then
      -- Locked during active reset      post_decode_merged_glock_r <= '1';
    elsif (clk'event and clk = '1') then
      post_decode_merged_glock_r <= post_decode_merged_glock;
    end if;
  end process lock_reg_proc;

  lock_r <= merged_glock_req;
  merged_glock_req <= lock_req(0) or lock_req(1) or lock_req(2);
  pre_decode_merged_glock <= lock or merged_glock_req;
  post_decode_merged_glock <= pre_decode_merged_glock or decode_fill_lock_reg;
  locked <= post_decode_merged_glock_r;
  glock(0) <= post_decode_merged_glock; -- to ALU_0
  glock(1) <= post_decode_merged_glock; -- to VLSU
  glock(2) <= post_decode_merged_glock; -- to VALU
  glock(3) <= post_decode_merged_glock; -- to VBCAST
  glock(4) <= post_decode_merged_glock; -- to VEXTRACT
  glock(5) <= post_decode_merged_glock; -- to ALU_1
  glock(6) <= post_decode_merged_glock; -- to PARAM_LSU
  glock(7) <= post_decode_merged_glock; -- to DATA_LSU
  glock(8) <= post_decode_merged_glock; -- to BOOL
  glock(9) <= post_decode_merged_glock; -- to RF_32_0
  glock(10) <= post_decode_merged_glock; -- to RF_128_0
  glock(11) <= post_decode_merged_glock; -- to IU_1x32
  glock(12) <= post_decode_merged_glock;

  decode_pipeline_fill_lock: process (clk, rstx)
  begin
    if rstx = '0' then
      decode_fill_lock_reg <= '1';
    elsif clk'event and clk = '1' then
      if lock = '0' then
        decode_fill_lock_reg <= '0';
      end if;
    end if;
  end process decode_pipeline_fill_lock;

end rtl_andor;
