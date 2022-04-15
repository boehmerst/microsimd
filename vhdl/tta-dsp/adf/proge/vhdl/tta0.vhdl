library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.tce_util.all;
use work.tta0_globals.all;
use work.tta0_imem_mau.all;
use work.tta0_params.all;

entity tta0 is

  generic (
    core_id : integer := 0);

  port (
    clk : in std_logic;
    rstx : in std_logic;
    busy : in std_logic;
    imem_en_x : out std_logic;
    imem_addr : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    imem_data : in std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0);
    locked : out std_logic;
    fu_PARAM_LSU_mem_addr_o : out std_logic_vector(fu_PARAM_LSU_addrw_g-2-1 downto 0);
    fu_PARAM_LSU_mem_en_o : out std_logic_vector(0 downto 0);
    fu_PARAM_LSU_mem_wr_o : out std_logic_vector(0 downto 0);
    fu_PARAM_LSU_mem_sel_o : out std_logic_vector(fu_PARAM_LSU_dataw_g/8-1 downto 0);
    fu_PARAM_LSU_mem_wdata_o : out std_logic_vector(fu_PARAM_LSU_dataw_g-1 downto 0);
    fu_PARAM_LSU_mem_rdata_i : in std_logic_vector(fu_PARAM_LSU_dataw_g-1 downto 0);
    fu_PARAM_LSU_mem_ready_i : in std_logic_vector(0 downto 0);
    fu_DATA_LSU_mem_addr_o : out std_logic_vector(fu_DATA_LSU_addrw_g-2-1 downto 0);
    fu_DATA_LSU_mem_en_o : out std_logic_vector(0 downto 0);
    fu_DATA_LSU_mem_wr_o : out std_logic_vector(0 downto 0);
    fu_DATA_LSU_mem_sel_o : out std_logic_vector(fu_DATA_LSU_dataw_g/8-1 downto 0);
    fu_DATA_LSU_mem_wdata_o : out std_logic_vector(fu_DATA_LSU_dataw_g-1 downto 0);
    fu_DATA_LSU_mem_rdata_i : in std_logic_vector(fu_DATA_LSU_dataw_g-1 downto 0);
    fu_DATA_LSU_mem_ready_i : in std_logic_vector(0 downto 0);
    fu_VLSU_mem_addr_o : out std_logic_vector(fu_VLSU_addrw_g-2-1 downto 0);
    fu_VLSU_mem_en_o : out std_logic_vector(0 downto 0);
    fu_VLSU_mem_sel_o : out std_logic_vector(fu_VLSU_dataw_g/8-1 downto 0);
    fu_VLSU_mem_wr_o : out std_logic_vector(0 downto 0);
    fu_VLSU_mem_wdata_o : out std_logic_vector(fu_VLSU_dataw_g-1 downto 0);
    fu_VLSU_mem_rdata_i : in std_logic_vector(fu_VLSU_dataw_g-1 downto 0);
    fu_VLSU_mem_ready_i : in std_logic_vector(0 downto 0));

end tta0;

architecture structural of tta0 is

  signal decomp_fetch_en_wire : std_logic;
  signal decomp_lock_wire : std_logic;
  signal decomp_fetchblock_wire : std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0);
  signal decomp_instructionword_wire : std_logic_vector(INSTRUCTIONWIDTH-1 downto 0);
  signal decomp_glock_wire : std_logic;
  signal decomp_lock_r_wire : std_logic;
  signal fu_ALU_0_t1data_wire : std_logic_vector(31 downto 0);
  signal fu_ALU_0_t1load_wire : std_logic;
  signal fu_ALU_0_r1data_wire : std_logic_vector(31 downto 0);
  signal fu_ALU_0_o1data_wire : std_logic_vector(31 downto 0);
  signal fu_ALU_0_o1load_wire : std_logic;
  signal fu_ALU_0_t1opcode_wire : std_logic_vector(3 downto 0);
  signal fu_ALU_0_glock_wire : std_logic;
  signal fu_ALU_1_t1data_wire : std_logic_vector(31 downto 0);
  signal fu_ALU_1_t1load_wire : std_logic;
  signal fu_ALU_1_r1data_wire : std_logic_vector(31 downto 0);
  signal fu_ALU_1_o1data_wire : std_logic_vector(31 downto 0);
  signal fu_ALU_1_o1load_wire : std_logic;
  signal fu_ALU_1_t1opcode_wire : std_logic_vector(3 downto 0);
  signal fu_ALU_1_glock_wire : std_logic;
  signal fu_DATA_LSU_t1data_i_wire : std_logic_vector(17 downto 0);
  signal fu_DATA_LSU_t1load_i_wire : std_logic;
  signal fu_DATA_LSU_r1data_o_wire : std_logic_vector(31 downto 0);
  signal fu_DATA_LSU_o1data_i_wire : std_logic_vector(31 downto 0);
  signal fu_DATA_LSU_o1load_i_wire : std_logic;
  signal fu_DATA_LSU_o1opcode_i_wire : std_logic_vector(2 downto 0);
  signal fu_DATA_LSU_glock_i_wire : std_logic;
  signal fu_DATA_LSU_glock_req_o_wire : std_logic;
  signal fu_PARAM_LSU_t1data_i_wire : std_logic_vector(14 downto 0);
  signal fu_PARAM_LSU_t1load_i_wire : std_logic;
  signal fu_PARAM_LSU_r1data_o_wire : std_logic_vector(31 downto 0);
  signal fu_PARAM_LSU_o1data_i_wire : std_logic_vector(31 downto 0);
  signal fu_PARAM_LSU_o1load_i_wire : std_logic;
  signal fu_PARAM_LSU_o1opcode_i_wire : std_logic_vector(2 downto 0);
  signal fu_PARAM_LSU_glock_i_wire : std_logic;
  signal fu_PARAM_LSU_glock_req_o_wire : std_logic;
  signal fu_VALU_t1data_wire : std_logic_vector(127 downto 0);
  signal fu_VALU_t1load_wire : std_logic;
  signal fu_VALU_r1data_wire : std_logic_vector(127 downto 0);
  signal fu_VALU_o1data_wire : std_logic_vector(127 downto 0);
  signal fu_VALU_o1load_wire : std_logic;
  signal fu_VALU_o2data_wire : std_logic_vector(127 downto 0);
  signal fu_VALU_o2load_wire : std_logic;
  signal fu_VALU_t1opcode_wire : std_logic_vector(3 downto 0);
  signal fu_VALU_glock_wire : std_logic;
  signal fu_VBCAST_t1data_wire : std_logic_vector(31 downto 0);
  signal fu_VBCAST_t1load_wire : std_logic;
  signal fu_VBCAST_r1data_wire : std_logic_vector(127 downto 0);
  signal fu_VBCAST_glock_wire : std_logic;
  signal fu_VEXTRACT_t1data_wire : std_logic_vector(127 downto 0);
  signal fu_VEXTRACT_t1load_wire : std_logic;
  signal fu_VEXTRACT_r1data_wire : std_logic_vector(31 downto 0);
  signal fu_VEXTRACT_o1data_wire : std_logic_vector(31 downto 0);
  signal fu_VEXTRACT_o1load_wire : std_logic;
  signal fu_VEXTRACT_glock_wire : std_logic;
  signal fu_VLSU_t1data_i_wire : std_logic_vector(31 downto 0);
  signal fu_VLSU_t1load_i_wire : std_logic;
  signal fu_VLSU_r1data_o_wire : std_logic_vector(127 downto 0);
  signal fu_VLSU_o1data_i_wire : std_logic_vector(127 downto 0);
  signal fu_VLSU_o1load_i_wire : std_logic;
  signal fu_VLSU_t1opcode_i_wire : std_logic_vector(0 downto 0);
  signal fu_VLSU_glock_i_wire : std_logic;
  signal fu_VLSU_glock_req_o_wire : std_logic;
  signal ic_glock_wire : std_logic;
  signal ic_socket_bool_i1_data_wire : std_logic_vector(0 downto 0);
  signal ic_socket_bool_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_bool_o1_data0_wire : std_logic_vector(0 downto 0);
  signal ic_socket_bool_o1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_gcu_i1_data_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal ic_socket_gcu_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_gcu_i2_data_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal ic_socket_gcu_i2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_gcu_o1_data0_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal ic_socket_gcu_o1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_ALU_i1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_ALU_i2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_ALU_o1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_IMM_rd_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_IMM_rd_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_R1_32_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_R1_32_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_W1_32_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_o1_1_data0_wire : std_logic_vector(127 downto 0);
  signal ic_socket_ALU_o1_1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_ALU_i1_4_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_o1_1_1_data0_wire : std_logic_vector(127 downto 0);
  signal ic_socket_ALU_o1_1_1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_ALU_i1_1_1_data_wire : std_logic_vector(127 downto 0);
  signal ic_socket_ALU_i1_1_1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_ALU_i1_1_1_1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i1_1_1_1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_ALU_i1_1_1_1_1_data_wire : std_logic_vector(17 downto 0);
  signal ic_socket_ALU_i1_1_1_1_1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_ALU_o1_1_1_1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_o1_1_1_1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_ALU_o1_1_1_3_data0_wire : std_logic_vector(127 downto 0);
  signal ic_socket_ALU_o1_1_1_3_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_ALU_o1_1_1_2_1_data_wire : std_logic_vector(127 downto 0);
  signal ic_socket_ALU_o1_1_1_2_1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_ALU_o1_1_1_2_1_1_data_wire : std_logic_vector(127 downto 0);
  signal ic_socket_ALU_o1_1_1_2_1_1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_ALU_o1_1_1_2_1_2_data_wire : std_logic_vector(127 downto 0);
  signal ic_socket_ALU_o1_1_1_2_1_2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_W1_32_1_data_wire : std_logic_vector(127 downto 0);
  signal ic_socket_R1_32_1_data0_wire : std_logic_vector(127 downto 0);
  signal ic_socket_R1_32_1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_ALU_o1_1_2_1_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_o1_1_2_1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_ALU_i1_1_1_1_1_1_2_5_data_wire : std_logic_vector(127 downto 0);
  signal ic_socket_ALU_i1_1_1_1_1_1_2_6_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i1_1_1_1_1_2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i1_1_1_1_3_data_wire : std_logic_vector(14 downto 0);
  signal ic_socket_ALU_o1_1_1_1_2_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_o1_1_1_1_2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_ALU_i2_1_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i2_1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_ALU_i2_2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i2_2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_ALU_o1_2_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_o1_2_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal ic_socket_R1_32_2_data0_wire : std_logic_vector(31 downto 0);
  signal ic_socket_R1_32_2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal ic_socket_R1_32_1_2_data0_wire : std_logic_vector(127 downto 0);
  signal ic_socket_R1_32_1_2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_socket_ALU_i1_1_1_1_2_data_wire : std_logic_vector(31 downto 0);
  signal ic_socket_ALU_i1_1_1_1_2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal ic_simm_B0_wire : std_logic_vector(31 downto 0);
  signal ic_simm_cntrl_B0_wire : std_logic_vector(0 downto 0);
  signal ic_simm_B1_wire : std_logic_vector(31 downto 0);
  signal ic_simm_cntrl_B1_wire : std_logic_vector(0 downto 0);
  signal ic_simm_B2_wire : std_logic_vector(31 downto 0);
  signal ic_simm_cntrl_B2_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_instructionword_wire : std_logic_vector(INSTRUCTIONWIDTH-1 downto 0);
  signal inst_decoder_pc_load_wire : std_logic;
  signal inst_decoder_ra_load_wire : std_logic;
  signal inst_decoder_pc_opcode_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_lock_wire : std_logic;
  signal inst_decoder_lock_r_wire : std_logic;
  signal inst_decoder_simm_B0_wire : std_logic_vector(31 downto 0);
  signal inst_decoder_simm_cntrl_B0_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_simm_B1_wire : std_logic_vector(31 downto 0);
  signal inst_decoder_simm_cntrl_B1_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_simm_B2_wire : std_logic_vector(31 downto 0);
  signal inst_decoder_simm_cntrl_B2_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_bool_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_bool_o1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_gcu_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_gcu_i2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_gcu_o1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_ALU_i1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_ALU_i2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_ALU_o1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_IMM_rd_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_R1_32_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_ALU_o1_1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_ALU_o1_1_1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_ALU_i1_1_1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_ALU_i1_1_1_1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_ALU_i1_1_1_1_1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_ALU_o1_1_1_1_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_ALU_o1_1_1_3_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_ALU_o1_1_1_2_1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_ALU_o1_1_1_2_1_1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_ALU_o1_1_1_2_1_2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_R1_32_1_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_ALU_o1_1_2_1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_ALU_o1_1_1_1_2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_ALU_i2_1_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_ALU_i2_2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_ALU_o1_2_bus_cntrl_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_socket_R1_32_2_bus_cntrl_wire : std_logic_vector(1 downto 0);
  signal inst_decoder_socket_R1_32_1_2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_socket_ALU_i1_1_1_1_2_bus_cntrl_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_fu_ALU_0_in1t_load_wire : std_logic;
  signal inst_decoder_fu_ALU_0_in2_load_wire : std_logic;
  signal inst_decoder_fu_ALU_0_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_fu_VLSU_in1t_load_wire : std_logic;
  signal inst_decoder_fu_VLSU_in3_load_wire : std_logic;
  signal inst_decoder_fu_VLSU_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_fu_VALU_int0_load_wire : std_logic;
  signal inst_decoder_fu_VALU_in2_load_wire : std_logic;
  signal inst_decoder_fu_VALU_in1_load_wire : std_logic;
  signal inst_decoder_fu_VALU_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_fu_VBCAST_in1t_load_wire : std_logic;
  signal inst_decoder_fu_VEXTRACT_in1t_load_wire : std_logic;
  signal inst_decoder_fu_VEXTRACT_in2_load_wire : std_logic;
  signal inst_decoder_fu_ALU_1_in1t_load_wire : std_logic;
  signal inst_decoder_fu_ALU_1_in2_load_wire : std_logic;
  signal inst_decoder_fu_ALU_1_opc_wire : std_logic_vector(3 downto 0);
  signal inst_decoder_fu_PARAM_LSU_in1t_load_wire : std_logic;
  signal inst_decoder_fu_PARAM_LSU_in2_load_wire : std_logic;
  signal inst_decoder_fu_PARAM_LSU_opc_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_fu_DATA_LSU_in1t_load_wire : std_logic;
  signal inst_decoder_fu_DATA_LSU_in2_load_wire : std_logic;
  signal inst_decoder_fu_DATA_LSU_opc_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_rf_BOOL_wr_load_wire : std_logic;
  signal inst_decoder_rf_BOOL_wr_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_rf_BOOL_rd_load_wire : std_logic;
  signal inst_decoder_rf_BOOL_rd_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_rf_RF_32_0_R1_32_load_wire : std_logic;
  signal inst_decoder_rf_RF_32_0_R1_32_opc_wire : std_logic_vector(4 downto 0);
  signal inst_decoder_rf_RF_32_0_W1_32_load_wire : std_logic;
  signal inst_decoder_rf_RF_32_0_W1_32_opc_wire : std_logic_vector(4 downto 0);
  signal inst_decoder_rf_RF_32_0_R2_load_wire : std_logic;
  signal inst_decoder_rf_RF_32_0_R2_opc_wire : std_logic_vector(4 downto 0);
  signal inst_decoder_rf_RF_128_0_R1_32_load_wire : std_logic;
  signal inst_decoder_rf_RF_128_0_R1_32_opc_wire : std_logic_vector(4 downto 0);
  signal inst_decoder_rf_RF_128_0_W1_32_load_wire : std_logic;
  signal inst_decoder_rf_RF_128_0_W1_32_opc_wire : std_logic_vector(4 downto 0);
  signal inst_decoder_rf_RF_128_0_R2_load_wire : std_logic;
  signal inst_decoder_rf_RF_128_0_R2_opc_wire : std_logic_vector(4 downto 0);
  signal inst_decoder_iu_IU_1x32_r0_read_load_wire : std_logic;
  signal inst_decoder_iu_IU_1x32_r0_read_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_iu_IU_1x32_write_wire : std_logic_vector(31 downto 0);
  signal inst_decoder_iu_IU_1x32_write_load_wire : std_logic;
  signal inst_decoder_iu_IU_1x32_write_opc_wire : std_logic_vector(0 downto 0);
  signal inst_decoder_rf_guard_BOOL_0_wire : std_logic;
  signal inst_decoder_rf_guard_BOOL_1_wire : std_logic;
  signal inst_decoder_lock_req_wire : std_logic_vector(2 downto 0);
  signal inst_decoder_glock_wire : std_logic_vector(12 downto 0);
  signal inst_fetch_ra_out_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal inst_fetch_ra_in_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal inst_fetch_pc_in_wire : std_logic_vector(IMEMADDRWIDTH-1 downto 0);
  signal inst_fetch_pc_load_wire : std_logic;
  signal inst_fetch_ra_load_wire : std_logic;
  signal inst_fetch_pc_opcode_wire : std_logic_vector(0 downto 0);
  signal inst_fetch_fetch_en_wire : std_logic;
  signal inst_fetch_glock_wire : std_logic;
  signal inst_fetch_fetchblock_wire : std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0);
  signal iu_IU_1x32_r1data_wire : std_logic_vector(31 downto 0);
  signal iu_IU_1x32_r1load_wire : std_logic;
  signal iu_IU_1x32_r1opcode_wire : std_logic_vector(0 downto 0);
  signal iu_IU_1x32_t1data_wire : std_logic_vector(31 downto 0);
  signal iu_IU_1x32_t1load_wire : std_logic;
  signal iu_IU_1x32_t1opcode_wire : std_logic_vector(0 downto 0);
  signal iu_IU_1x32_guard_wire : std_logic_vector(0 downto 0);
  signal iu_IU_1x32_glock_wire : std_logic;
  signal rf_BOOL_r1data_wire : std_logic_vector(0 downto 0);
  signal rf_BOOL_r1load_wire : std_logic;
  signal rf_BOOL_r1opcode_wire : std_logic_vector(0 downto 0);
  signal rf_BOOL_t1data_wire : std_logic_vector(0 downto 0);
  signal rf_BOOL_t1load_wire : std_logic;
  signal rf_BOOL_t1opcode_wire : std_logic_vector(0 downto 0);
  signal rf_BOOL_guard_wire : std_logic_vector(1 downto 0);
  signal rf_BOOL_glock_wire : std_logic;
  signal rf_RF_128_0_r1data_wire : std_logic_vector(127 downto 0);
  signal rf_RF_128_0_r1load_wire : std_logic;
  signal rf_RF_128_0_r1opcode_wire : std_logic_vector(4 downto 0);
  signal rf_RF_128_0_r2data_wire : std_logic_vector(127 downto 0);
  signal rf_RF_128_0_r2load_wire : std_logic;
  signal rf_RF_128_0_r2opcode_wire : std_logic_vector(4 downto 0);
  signal rf_RF_128_0_t1data_wire : std_logic_vector(127 downto 0);
  signal rf_RF_128_0_t1load_wire : std_logic;
  signal rf_RF_128_0_t1opcode_wire : std_logic_vector(4 downto 0);
  signal rf_RF_128_0_guard_wire : std_logic_vector(31 downto 0);
  signal rf_RF_128_0_glock_wire : std_logic;
  signal rf_RF_32_0_r1data_wire : std_logic_vector(31 downto 0);
  signal rf_RF_32_0_r1load_wire : std_logic;
  signal rf_RF_32_0_r1opcode_wire : std_logic_vector(4 downto 0);
  signal rf_RF_32_0_r2data_wire : std_logic_vector(31 downto 0);
  signal rf_RF_32_0_r2load_wire : std_logic;
  signal rf_RF_32_0_r2opcode_wire : std_logic_vector(4 downto 0);
  signal rf_RF_32_0_t1data_wire : std_logic_vector(31 downto 0);
  signal rf_RF_32_0_t1load_wire : std_logic;
  signal rf_RF_32_0_t1opcode_wire : std_logic_vector(4 downto 0);
  signal rf_RF_32_0_guard_wire : std_logic_vector(31 downto 0);
  signal rf_RF_32_0_glock_wire : std_logic;
  signal ground_signal : std_logic_vector(31 downto 0);

  component tta0_ifetch
    port (
      clk : in std_logic;
      rstx : in std_logic;
      ra_out : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      ra_in : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      busy : in std_logic;
      imem_en_x : out std_logic;
      imem_addr : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      imem_data : in std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0);
      pc_in : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      pc_load : in std_logic;
      ra_load : in std_logic;
      pc_opcode : in std_logic_vector(1-1 downto 0);
      fetch_en : in std_logic;
      glock : out std_logic;
      fetchblock : out std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0));
  end component;

  component tta0_decompressor
    port (
      fetch_en : out std_logic;
      lock : in std_logic;
      fetchblock : in std_logic_vector(IMEMWIDTHINMAUS*IMEMMAUWIDTH-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      instructionword : out std_logic_vector(INSTRUCTIONWIDTH-1 downto 0);
      glock : out std_logic;
      lock_r : in std_logic);
  end component;

  component tta0_decoder
    port (
      instructionword : in std_logic_vector(INSTRUCTIONWIDTH-1 downto 0);
      pc_load : out std_logic;
      ra_load : out std_logic;
      pc_opcode : out std_logic_vector(1-1 downto 0);
      lock : in std_logic;
      lock_r : out std_logic;
      clk : in std_logic;
      rstx : in std_logic;
      locked : out std_logic;
      simm_B0 : out std_logic_vector(32-1 downto 0);
      simm_cntrl_B0 : out std_logic_vector(1-1 downto 0);
      simm_B1 : out std_logic_vector(32-1 downto 0);
      simm_cntrl_B1 : out std_logic_vector(1-1 downto 0);
      simm_B2 : out std_logic_vector(32-1 downto 0);
      simm_cntrl_B2 : out std_logic_vector(1-1 downto 0);
      socket_bool_i1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_bool_o1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_gcu_i1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_gcu_i2_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_gcu_o1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_ALU_i1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_ALU_i2_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_ALU_o1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_IMM_rd_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_R1_32_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_ALU_o1_1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_ALU_o1_1_1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_ALU_i1_1_1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_ALU_i1_1_1_1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_ALU_i1_1_1_1_1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_ALU_o1_1_1_1_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_ALU_o1_1_1_3_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_ALU_o1_1_1_2_1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_ALU_o1_1_1_2_1_1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_ALU_o1_1_1_2_1_2_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_R1_32_1_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_ALU_o1_1_2_1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_ALU_o1_1_1_1_2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_ALU_i2_1_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_ALU_i2_2_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_ALU_o1_2_bus_cntrl : out std_logic_vector(3-1 downto 0);
      socket_R1_32_2_bus_cntrl : out std_logic_vector(2-1 downto 0);
      socket_R1_32_1_2_bus_cntrl : out std_logic_vector(1-1 downto 0);
      socket_ALU_i1_1_1_1_2_bus_cntrl : out std_logic_vector(1-1 downto 0);
      fu_ALU_0_in1t_load : out std_logic;
      fu_ALU_0_in2_load : out std_logic;
      fu_ALU_0_opc : out std_logic_vector(4-1 downto 0);
      fu_VLSU_in1t_load : out std_logic;
      fu_VLSU_in3_load : out std_logic;
      fu_VLSU_opc : out std_logic_vector(1-1 downto 0);
      fu_VALU_int0_load : out std_logic;
      fu_VALU_in2_load : out std_logic;
      fu_VALU_in1_load : out std_logic;
      fu_VALU_opc : out std_logic_vector(4-1 downto 0);
      fu_VBCAST_in1t_load : out std_logic;
      fu_VEXTRACT_in1t_load : out std_logic;
      fu_VEXTRACT_in2_load : out std_logic;
      fu_ALU_1_in1t_load : out std_logic;
      fu_ALU_1_in2_load : out std_logic;
      fu_ALU_1_opc : out std_logic_vector(4-1 downto 0);
      fu_PARAM_LSU_in1t_load : out std_logic;
      fu_PARAM_LSU_in2_load : out std_logic;
      fu_PARAM_LSU_opc : out std_logic_vector(3-1 downto 0);
      fu_DATA_LSU_in1t_load : out std_logic;
      fu_DATA_LSU_in2_load : out std_logic;
      fu_DATA_LSU_opc : out std_logic_vector(3-1 downto 0);
      rf_BOOL_wr_load : out std_logic;
      rf_BOOL_wr_opc : out std_logic_vector(1-1 downto 0);
      rf_BOOL_rd_load : out std_logic;
      rf_BOOL_rd_opc : out std_logic_vector(1-1 downto 0);
      rf_RF_32_0_R1_32_load : out std_logic;
      rf_RF_32_0_R1_32_opc : out std_logic_vector(5-1 downto 0);
      rf_RF_32_0_W1_32_load : out std_logic;
      rf_RF_32_0_W1_32_opc : out std_logic_vector(5-1 downto 0);
      rf_RF_32_0_R2_load : out std_logic;
      rf_RF_32_0_R2_opc : out std_logic_vector(5-1 downto 0);
      rf_RF_128_0_R1_32_load : out std_logic;
      rf_RF_128_0_R1_32_opc : out std_logic_vector(5-1 downto 0);
      rf_RF_128_0_W1_32_load : out std_logic;
      rf_RF_128_0_W1_32_opc : out std_logic_vector(5-1 downto 0);
      rf_RF_128_0_R2_load : out std_logic;
      rf_RF_128_0_R2_opc : out std_logic_vector(5-1 downto 0);
      iu_IU_1x32_r0_read_load : out std_logic;
      iu_IU_1x32_r0_read_opc : out std_logic_vector(0 downto 0);
      iu_IU_1x32_write : out std_logic_vector(32-1 downto 0);
      iu_IU_1x32_write_load : out std_logic;
      iu_IU_1x32_write_opc : out std_logic_vector(0 downto 0);
      rf_guard_BOOL_0 : in std_logic;
      rf_guard_BOOL_1 : in std_logic;
      lock_req : in std_logic_vector(3-1 downto 0);
      glock : out std_logic_vector(13-1 downto 0));
  end component;

  component fu_lsu_always_3
    generic (
      dataw_g : integer;
      addrw_g : integer;
      latency_g : integer);
    port (
      t1data_i : in std_logic_vector(addrw_g-1 downto 0);
      t1load_i : in std_logic;
      r1data_o : out std_logic_vector(dataw_g-1 downto 0);
      o1data_i : in std_logic_vector(dataw_g-1 downto 0);
      o1load_i : in std_logic;
      o1opcode_i : in std_logic_vector(3-1 downto 0);
      mem_addr_o : out std_logic_vector(addrw_g-2-1 downto 0);
      mem_en_o : out std_logic_vector(1-1 downto 0);
      mem_wr_o : out std_logic_vector(1-1 downto 0);
      mem_sel_o : out std_logic_vector(dataw_g/8-1 downto 0);
      mem_wdata_o : out std_logic_vector(dataw_g-1 downto 0);
      mem_rdata_i : in std_logic_vector(dataw_g-1 downto 0);
      mem_ready_i : in std_logic_vector(1-1 downto 0);
      clk_i : in std_logic;
      reset_n_i : in std_logic;
      glock_i : in std_logic;
      glock_req_o : out std_logic);
  end component;

  component fu_add_and_eq_gt_gtu_ior_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1
    generic (
      dataw : integer);
    port (
      t1data : in std_logic_vector(dataw-1 downto 0);
      t1load : in std_logic;
      r1data : out std_logic_vector(dataw-1 downto 0);
      o1data : in std_logic_vector(dataw-1 downto 0);
      o1load : in std_logic;
      t1opcode : in std_logic_vector(4-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component fu_vec_lsu
    generic (
      elemcount_g : integer;
      addrw_g : integer;
      latency_g : integer;
      dataw_g : integer);
    port (
      t1data_i : in std_logic_vector(addrw_g-1 downto 0);
      t1load_i : in std_logic;
      r1data_o : out std_logic_vector(elemcount_g*dataw_g-1 downto 0);
      o1data_i : in std_logic_vector(elemcount_g*dataw_g-1 downto 0);
      o1load_i : in std_logic;
      t1opcode_i : in std_logic_vector(1-1 downto 0);
      mem_addr_o : out std_logic_vector(addrw_g-2-1 downto 0);
      mem_en_o : out std_logic_vector(1-1 downto 0);
      mem_sel_o : out std_logic_vector(dataw_g/8-1 downto 0);
      mem_wr_o : out std_logic_vector(1-1 downto 0);
      mem_wdata_o : out std_logic_vector(dataw_g-1 downto 0);
      mem_rdata_i : in std_logic_vector(dataw_g-1 downto 0);
      mem_ready_i : in std_logic_vector(1-1 downto 0);
      clk_i : in std_logic;
      reset_n_i : in std_logic;
      glock_i : in std_logic;
      glock_req_o : out std_logic);
  end component;

  component fu_vextract_always_1
    generic (
      dataw_g : integer;
      elemcount_g : integer);
    port (
      t1data : in std_logic_vector(dataw-1 downto 0);
      t1load : in std_logic;
      r1data : out std_logic_vector(dataw-1 downto 0);
      o1data : in std_logic_vector(elemcount*dataw-1 downto 0);
      o1load : in std_logic;
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component fu_vbcast32x4_always_1
    generic (
      dataw_g : integer;
      elemcount_g : integer);
    port (
      t1data : in std_logic_vector(dataw-1 downto 0);
      t1load : in std_logic;
      r1data : out std_logic_vector(elemcount*dataw-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component fu_add_and_eq_gt_gtu_ior_mac_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1_v4
    port (
      t1data : in std_logic_vector(128-1 downto 0);
      t1load : in std_logic;
      r1data : out std_logic_vector(128-1 downto 0);
      o1data : in std_logic_vector(128-1 downto 0);
      o1load : in std_logic;
      o2data : in std_logic_vector(128-1 downto 0);
      o2load : in std_logic;
      t1opcode : in std_logic_vector(4-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component rf_1wr_1rd_always_1_guarded_1
    generic (
      dataw : integer;
      rf_size : integer);
    port (
      r1data : out std_logic_vector(dataw-1 downto 0);
      r1load : in std_logic;
      r1opcode : in std_logic_vector(bit_width(rf_size)-1 downto 0);
      t1data : in std_logic_vector(dataw-1 downto 0);
      t1load : in std_logic;
      t1opcode : in std_logic_vector(bit_width(rf_size)-1 downto 0);
      guard : out std_logic_vector(rf_size-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component rf_1wr_2rd_always_1_guarded_1
    generic (
      dataw : integer;
      rf_size : integer);
    port (
      r1data : out std_logic_vector(dataw-1 downto 0);
      r1load : in std_logic;
      r1opcode : in std_logic_vector(bit_width(rf_size)-1 downto 0);
      r2data : out std_logic_vector(dataw-1 downto 0);
      r2load : in std_logic;
      r2opcode : in std_logic_vector(bit_width(rf_size)-1 downto 0);
      t1data : in std_logic_vector(dataw-1 downto 0);
      t1load : in std_logic;
      t1opcode : in std_logic_vector(bit_width(rf_size)-1 downto 0);
      guard : out std_logic_vector(rf_size-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component rf_1wr_1rd_always_1_guarded_0
    generic (
      dataw : integer;
      rf_size : integer);
    port (
      r1data : out std_logic_vector(dataw-1 downto 0);
      r1load : in std_logic;
      r1opcode : in std_logic_vector(bit_width(rf_size)-1 downto 0);
      t1data : in std_logic_vector(dataw-1 downto 0);
      t1load : in std_logic;
      t1opcode : in std_logic_vector(bit_width(rf_size)-1 downto 0);
      guard : out std_logic_vector(rf_size-1 downto 0);
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic);
  end component;

  component tta0_interconn
    port (
      clk : in std_logic;
      rstx : in std_logic;
      glock : in std_logic;
      socket_bool_i1_data : out std_logic_vector(1-1 downto 0);
      socket_bool_i1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_bool_o1_data0 : in std_logic_vector(1-1 downto 0);
      socket_bool_o1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_gcu_i1_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      socket_gcu_i1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_gcu_i2_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      socket_gcu_i2_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_gcu_o1_data0 : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
      socket_gcu_o1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_ALU_i1_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_ALU_i2_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i2_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_ALU_o1_data0 : in std_logic_vector(32-1 downto 0);
      socket_ALU_o1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_IMM_rd_data0 : in std_logic_vector(32-1 downto 0);
      socket_IMM_rd_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_R1_32_data0 : in std_logic_vector(32-1 downto 0);
      socket_R1_32_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_W1_32_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_o1_1_data0 : in std_logic_vector(128-1 downto 0);
      socket_ALU_o1_1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_ALU_i1_4_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_o1_1_1_data0 : in std_logic_vector(128-1 downto 0);
      socket_ALU_o1_1_1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_ALU_i1_1_1_data : out std_logic_vector(128-1 downto 0);
      socket_ALU_i1_1_1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_ALU_i1_1_1_1_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i1_1_1_1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_ALU_i1_1_1_1_1_data : out std_logic_vector(18-1 downto 0);
      socket_ALU_i1_1_1_1_1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_ALU_o1_1_1_1_data0 : in std_logic_vector(32-1 downto 0);
      socket_ALU_o1_1_1_1_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_ALU_o1_1_1_3_data0 : in std_logic_vector(128-1 downto 0);
      socket_ALU_o1_1_1_3_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_ALU_o1_1_1_2_1_data : out std_logic_vector(128-1 downto 0);
      socket_ALU_o1_1_1_2_1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_ALU_o1_1_1_2_1_1_data : out std_logic_vector(128-1 downto 0);
      socket_ALU_o1_1_1_2_1_1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_ALU_o1_1_1_2_1_2_data : out std_logic_vector(128-1 downto 0);
      socket_ALU_o1_1_1_2_1_2_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_W1_32_1_data : out std_logic_vector(128-1 downto 0);
      socket_R1_32_1_data0 : in std_logic_vector(128-1 downto 0);
      socket_R1_32_1_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_ALU_o1_1_2_1_data0 : in std_logic_vector(32-1 downto 0);
      socket_ALU_o1_1_2_1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_ALU_i1_1_1_1_1_1_2_5_data : out std_logic_vector(128-1 downto 0);
      socket_ALU_i1_1_1_1_1_1_2_6_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i1_1_1_1_1_2_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i1_1_1_1_3_data : out std_logic_vector(15-1 downto 0);
      socket_ALU_o1_1_1_1_2_data0 : in std_logic_vector(32-1 downto 0);
      socket_ALU_o1_1_1_1_2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_ALU_i2_1_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i2_1_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_ALU_i2_2_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i2_2_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_ALU_o1_2_data0 : in std_logic_vector(32-1 downto 0);
      socket_ALU_o1_2_bus_cntrl : in std_logic_vector(3-1 downto 0);
      socket_R1_32_2_data0 : in std_logic_vector(32-1 downto 0);
      socket_R1_32_2_bus_cntrl : in std_logic_vector(2-1 downto 0);
      socket_R1_32_1_2_data0 : in std_logic_vector(128-1 downto 0);
      socket_R1_32_1_2_bus_cntrl : in std_logic_vector(1-1 downto 0);
      socket_ALU_i1_1_1_1_2_data : out std_logic_vector(32-1 downto 0);
      socket_ALU_i1_1_1_1_2_bus_cntrl : in std_logic_vector(1-1 downto 0);
      simm_B0 : in std_logic_vector(32-1 downto 0);
      simm_cntrl_B0 : in std_logic_vector(1-1 downto 0);
      simm_B1 : in std_logic_vector(32-1 downto 0);
      simm_cntrl_B1 : in std_logic_vector(1-1 downto 0);
      simm_B2 : in std_logic_vector(32-1 downto 0);
      simm_cntrl_B2 : in std_logic_vector(1-1 downto 0));
  end component;


begin

  ic_socket_gcu_o1_data0_wire <= inst_fetch_ra_out_wire;
  inst_fetch_ra_in_wire <= ic_socket_gcu_i2_data_wire;
  inst_fetch_pc_in_wire <= ic_socket_gcu_i1_data_wire;
  inst_fetch_pc_load_wire <= inst_decoder_pc_load_wire;
  inst_fetch_ra_load_wire <= inst_decoder_ra_load_wire;
  inst_fetch_pc_opcode_wire <= inst_decoder_pc_opcode_wire;
  inst_fetch_fetch_en_wire <= decomp_fetch_en_wire;
  decomp_lock_wire <= inst_fetch_glock_wire;
  decomp_fetchblock_wire <= inst_fetch_fetchblock_wire;
  inst_decoder_instructionword_wire <= decomp_instructionword_wire;
  inst_decoder_lock_wire <= decomp_glock_wire;
  decomp_lock_r_wire <= inst_decoder_lock_r_wire;
  ic_simm_B0_wire <= inst_decoder_simm_B0_wire;
  ic_simm_cntrl_B0_wire <= inst_decoder_simm_cntrl_B0_wire;
  ic_simm_B1_wire <= inst_decoder_simm_B1_wire;
  ic_simm_cntrl_B1_wire <= inst_decoder_simm_cntrl_B1_wire;
  ic_simm_B2_wire <= inst_decoder_simm_B2_wire;
  ic_simm_cntrl_B2_wire <= inst_decoder_simm_cntrl_B2_wire;
  ic_socket_bool_i1_bus_cntrl_wire <= inst_decoder_socket_bool_i1_bus_cntrl_wire;
  ic_socket_bool_o1_bus_cntrl_wire <= inst_decoder_socket_bool_o1_bus_cntrl_wire;
  ic_socket_gcu_i1_bus_cntrl_wire <= inst_decoder_socket_gcu_i1_bus_cntrl_wire;
  ic_socket_gcu_i2_bus_cntrl_wire <= inst_decoder_socket_gcu_i2_bus_cntrl_wire;
  ic_socket_gcu_o1_bus_cntrl_wire <= inst_decoder_socket_gcu_o1_bus_cntrl_wire;
  ic_socket_ALU_i1_bus_cntrl_wire <= inst_decoder_socket_ALU_i1_bus_cntrl_wire;
  ic_socket_ALU_i2_bus_cntrl_wire <= inst_decoder_socket_ALU_i2_bus_cntrl_wire;
  ic_socket_ALU_o1_bus_cntrl_wire <= inst_decoder_socket_ALU_o1_bus_cntrl_wire;
  ic_socket_IMM_rd_bus_cntrl_wire <= inst_decoder_socket_IMM_rd_bus_cntrl_wire;
  ic_socket_R1_32_bus_cntrl_wire <= inst_decoder_socket_R1_32_bus_cntrl_wire;
  ic_socket_ALU_o1_1_bus_cntrl_wire <= inst_decoder_socket_ALU_o1_1_bus_cntrl_wire;
  ic_socket_ALU_o1_1_1_bus_cntrl_wire <= inst_decoder_socket_ALU_o1_1_1_bus_cntrl_wire;
  ic_socket_ALU_i1_1_1_bus_cntrl_wire <= inst_decoder_socket_ALU_i1_1_1_bus_cntrl_wire;
  ic_socket_ALU_i1_1_1_1_bus_cntrl_wire <= inst_decoder_socket_ALU_i1_1_1_1_bus_cntrl_wire;
  ic_socket_ALU_i1_1_1_1_1_bus_cntrl_wire <= inst_decoder_socket_ALU_i1_1_1_1_1_bus_cntrl_wire;
  ic_socket_ALU_o1_1_1_1_bus_cntrl_wire <= inst_decoder_socket_ALU_o1_1_1_1_bus_cntrl_wire;
  ic_socket_ALU_o1_1_1_3_bus_cntrl_wire <= inst_decoder_socket_ALU_o1_1_1_3_bus_cntrl_wire;
  ic_socket_ALU_o1_1_1_2_1_bus_cntrl_wire <= inst_decoder_socket_ALU_o1_1_1_2_1_bus_cntrl_wire;
  ic_socket_ALU_o1_1_1_2_1_1_bus_cntrl_wire <= inst_decoder_socket_ALU_o1_1_1_2_1_1_bus_cntrl_wire;
  ic_socket_ALU_o1_1_1_2_1_2_bus_cntrl_wire <= inst_decoder_socket_ALU_o1_1_1_2_1_2_bus_cntrl_wire;
  ic_socket_R1_32_1_bus_cntrl_wire <= inst_decoder_socket_R1_32_1_bus_cntrl_wire;
  ic_socket_ALU_o1_1_2_1_bus_cntrl_wire <= inst_decoder_socket_ALU_o1_1_2_1_bus_cntrl_wire;
  ic_socket_ALU_o1_1_1_1_2_bus_cntrl_wire <= inst_decoder_socket_ALU_o1_1_1_1_2_bus_cntrl_wire;
  ic_socket_ALU_i2_1_bus_cntrl_wire <= inst_decoder_socket_ALU_i2_1_bus_cntrl_wire;
  ic_socket_ALU_i2_2_bus_cntrl_wire <= inst_decoder_socket_ALU_i2_2_bus_cntrl_wire;
  ic_socket_ALU_o1_2_bus_cntrl_wire <= inst_decoder_socket_ALU_o1_2_bus_cntrl_wire;
  ic_socket_R1_32_2_bus_cntrl_wire <= inst_decoder_socket_R1_32_2_bus_cntrl_wire;
  ic_socket_R1_32_1_2_bus_cntrl_wire <= inst_decoder_socket_R1_32_1_2_bus_cntrl_wire;
  ic_socket_ALU_i1_1_1_1_2_bus_cntrl_wire <= inst_decoder_socket_ALU_i1_1_1_1_2_bus_cntrl_wire;
  fu_ALU_0_t1load_wire <= inst_decoder_fu_ALU_0_in1t_load_wire;
  fu_ALU_0_o1load_wire <= inst_decoder_fu_ALU_0_in2_load_wire;
  fu_ALU_0_t1opcode_wire <= inst_decoder_fu_ALU_0_opc_wire;
  fu_VLSU_t1load_i_wire <= inst_decoder_fu_VLSU_in1t_load_wire;
  fu_VLSU_o1load_i_wire <= inst_decoder_fu_VLSU_in3_load_wire;
  fu_VLSU_t1opcode_i_wire <= inst_decoder_fu_VLSU_opc_wire;
  fu_VALU_t1load_wire <= inst_decoder_fu_VALU_int0_load_wire;
  fu_VALU_o2load_wire <= inst_decoder_fu_VALU_in2_load_wire;
  fu_VALU_o1load_wire <= inst_decoder_fu_VALU_in1_load_wire;
  fu_VALU_t1opcode_wire <= inst_decoder_fu_VALU_opc_wire;
  fu_VBCAST_t1load_wire <= inst_decoder_fu_VBCAST_in1t_load_wire;
  fu_VEXTRACT_t1load_wire <= inst_decoder_fu_VEXTRACT_in1t_load_wire;
  fu_VEXTRACT_o1load_wire <= inst_decoder_fu_VEXTRACT_in2_load_wire;
  fu_ALU_1_t1load_wire <= inst_decoder_fu_ALU_1_in1t_load_wire;
  fu_ALU_1_o1load_wire <= inst_decoder_fu_ALU_1_in2_load_wire;
  fu_ALU_1_t1opcode_wire <= inst_decoder_fu_ALU_1_opc_wire;
  fu_PARAM_LSU_t1load_i_wire <= inst_decoder_fu_PARAM_LSU_in1t_load_wire;
  fu_PARAM_LSU_o1load_i_wire <= inst_decoder_fu_PARAM_LSU_in2_load_wire;
  fu_PARAM_LSU_o1opcode_i_wire <= inst_decoder_fu_PARAM_LSU_opc_wire;
  fu_DATA_LSU_t1load_i_wire <= inst_decoder_fu_DATA_LSU_in1t_load_wire;
  fu_DATA_LSU_o1load_i_wire <= inst_decoder_fu_DATA_LSU_in2_load_wire;
  fu_DATA_LSU_o1opcode_i_wire <= inst_decoder_fu_DATA_LSU_opc_wire;
  rf_BOOL_t1load_wire <= inst_decoder_rf_BOOL_wr_load_wire;
  rf_BOOL_t1opcode_wire <= inst_decoder_rf_BOOL_wr_opc_wire;
  rf_BOOL_r1load_wire <= inst_decoder_rf_BOOL_rd_load_wire;
  rf_BOOL_r1opcode_wire <= inst_decoder_rf_BOOL_rd_opc_wire;
  rf_RF_32_0_r1load_wire <= inst_decoder_rf_RF_32_0_R1_32_load_wire;
  rf_RF_32_0_r1opcode_wire <= inst_decoder_rf_RF_32_0_R1_32_opc_wire;
  rf_RF_32_0_t1load_wire <= inst_decoder_rf_RF_32_0_W1_32_load_wire;
  rf_RF_32_0_t1opcode_wire <= inst_decoder_rf_RF_32_0_W1_32_opc_wire;
  rf_RF_32_0_r2load_wire <= inst_decoder_rf_RF_32_0_R2_load_wire;
  rf_RF_32_0_r2opcode_wire <= inst_decoder_rf_RF_32_0_R2_opc_wire;
  rf_RF_128_0_t1load_wire <= inst_decoder_rf_RF_128_0_R1_32_load_wire;
  rf_RF_128_0_t1opcode_wire <= inst_decoder_rf_RF_128_0_R1_32_opc_wire;
  rf_RF_128_0_r1load_wire <= inst_decoder_rf_RF_128_0_W1_32_load_wire;
  rf_RF_128_0_r1opcode_wire <= inst_decoder_rf_RF_128_0_W1_32_opc_wire;
  rf_RF_128_0_r2load_wire <= inst_decoder_rf_RF_128_0_R2_load_wire;
  rf_RF_128_0_r2opcode_wire <= inst_decoder_rf_RF_128_0_R2_opc_wire;
  iu_IU_1x32_r1load_wire <= inst_decoder_iu_IU_1x32_r0_read_load_wire;
  iu_IU_1x32_r1opcode_wire <= inst_decoder_iu_IU_1x32_r0_read_opc_wire;
  iu_IU_1x32_t1data_wire <= inst_decoder_iu_IU_1x32_write_wire;
  iu_IU_1x32_t1load_wire <= inst_decoder_iu_IU_1x32_write_load_wire;
  iu_IU_1x32_t1opcode_wire <= inst_decoder_iu_IU_1x32_write_opc_wire;
  inst_decoder_rf_guard_BOOL_0_wire <= rf_BOOL_guard_wire(0);
  inst_decoder_rf_guard_BOOL_1_wire <= rf_BOOL_guard_wire(1);
  inst_decoder_lock_req_wire(0) <= fu_VLSU_glock_req_o_wire;
  inst_decoder_lock_req_wire(1) <= fu_PARAM_LSU_glock_req_o_wire;
  inst_decoder_lock_req_wire(2) <= fu_DATA_LSU_glock_req_o_wire;
  fu_ALU_0_glock_wire <= inst_decoder_glock_wire(0);
  fu_VLSU_glock_i_wire <= inst_decoder_glock_wire(1);
  fu_VALU_glock_wire <= inst_decoder_glock_wire(2);
  fu_VBCAST_glock_wire <= inst_decoder_glock_wire(3);
  fu_VEXTRACT_glock_wire <= inst_decoder_glock_wire(4);
  fu_ALU_1_glock_wire <= inst_decoder_glock_wire(5);
  fu_PARAM_LSU_glock_i_wire <= inst_decoder_glock_wire(6);
  fu_DATA_LSU_glock_i_wire <= inst_decoder_glock_wire(7);
  rf_BOOL_glock_wire <= inst_decoder_glock_wire(8);
  rf_RF_32_0_glock_wire <= inst_decoder_glock_wire(9);
  rf_RF_128_0_glock_wire <= inst_decoder_glock_wire(10);
  iu_IU_1x32_glock_wire <= inst_decoder_glock_wire(11);
  ic_glock_wire <= inst_decoder_glock_wire(12);
  fu_PARAM_LSU_t1data_i_wire <= ic_socket_ALU_i1_1_1_1_3_data_wire;
  ic_socket_ALU_o1_1_1_1_2_data0_wire <= fu_PARAM_LSU_r1data_o_wire;
  fu_PARAM_LSU_o1data_i_wire <= ic_socket_ALU_i1_1_1_1_1_2_data_wire;
  fu_ALU_1_t1data_wire <= ic_socket_ALU_i2_2_data_wire;
  ic_socket_ALU_o1_2_data0_wire <= fu_ALU_1_r1data_wire;
  fu_ALU_1_o1data_wire <= ic_socket_ALU_i2_1_data_wire;
  fu_ALU_0_t1data_wire <= ic_socket_ALU_i1_data_wire;
  ic_socket_ALU_o1_data0_wire <= fu_ALU_0_r1data_wire;
  fu_ALU_0_o1data_wire <= ic_socket_ALU_i2_data_wire;
  fu_DATA_LSU_t1data_i_wire <= ic_socket_ALU_i1_1_1_1_1_data_wire;
  ic_socket_ALU_o1_1_1_1_data0_wire <= fu_DATA_LSU_r1data_o_wire;
  fu_DATA_LSU_o1data_i_wire <= ic_socket_ALU_i1_1_1_1_2_data_wire;
  fu_VLSU_t1data_i_wire <= ic_socket_ALU_i1_1_1_1_data_wire;
  ic_socket_ALU_o1_1_1_data0_wire <= fu_VLSU_r1data_o_wire;
  fu_VLSU_o1data_i_wire <= ic_socket_ALU_i1_1_1_data_wire;
  fu_VEXTRACT_t1data_wire <= ic_socket_ALU_i1_1_1_1_1_1_2_5_data_wire;
  ic_socket_ALU_o1_1_2_1_data0_wire <= fu_VEXTRACT_r1data_wire;
  fu_VEXTRACT_o1data_wire <= ic_socket_ALU_i1_1_1_1_1_1_2_6_data_wire;
  fu_VBCAST_t1data_wire <= ic_socket_ALU_i1_4_data_wire;
  ic_socket_ALU_o1_1_data0_wire <= fu_VBCAST_r1data_wire;
  fu_VALU_t1data_wire <= ic_socket_ALU_o1_1_1_2_1_data_wire;
  ic_socket_ALU_o1_1_1_3_data0_wire <= fu_VALU_r1data_wire;
  fu_VALU_o1data_wire <= ic_socket_ALU_o1_1_1_2_1_2_data_wire;
  fu_VALU_o2data_wire <= ic_socket_ALU_o1_1_1_2_1_1_data_wire;
  ic_socket_bool_o1_data0_wire <= rf_BOOL_r1data_wire;
  rf_BOOL_t1data_wire <= ic_socket_bool_i1_data_wire;
  ic_socket_R1_32_data0_wire <= rf_RF_32_0_r1data_wire;
  ic_socket_R1_32_2_data0_wire <= rf_RF_32_0_r2data_wire;
  rf_RF_32_0_t1data_wire <= ic_socket_W1_32_data_wire;
  ic_socket_R1_32_1_data0_wire <= rf_RF_128_0_r1data_wire;
  ic_socket_R1_32_1_2_data0_wire <= rf_RF_128_0_r2data_wire;
  rf_RF_128_0_t1data_wire <= ic_socket_W1_32_1_data_wire;
  ic_socket_IMM_rd_data0_wire <= iu_IU_1x32_r1data_wire;
  ground_signal <= (others => '0');

  inst_fetch : tta0_ifetch
    port map (
      clk => clk,
      rstx => rstx,
      ra_out => inst_fetch_ra_out_wire,
      ra_in => inst_fetch_ra_in_wire,
      busy => busy,
      imem_en_x => imem_en_x,
      imem_addr => imem_addr,
      imem_data => imem_data,
      pc_in => inst_fetch_pc_in_wire,
      pc_load => inst_fetch_pc_load_wire,
      ra_load => inst_fetch_ra_load_wire,
      pc_opcode => inst_fetch_pc_opcode_wire,
      fetch_en => inst_fetch_fetch_en_wire,
      glock => inst_fetch_glock_wire,
      fetchblock => inst_fetch_fetchblock_wire);

  decomp : tta0_decompressor
    port map (
      fetch_en => decomp_fetch_en_wire,
      lock => decomp_lock_wire,
      fetchblock => decomp_fetchblock_wire,
      clk => clk,
      rstx => rstx,
      instructionword => decomp_instructionword_wire,
      glock => decomp_glock_wire,
      lock_r => decomp_lock_r_wire);

  inst_decoder : tta0_decoder
    port map (
      instructionword => inst_decoder_instructionword_wire,
      pc_load => inst_decoder_pc_load_wire,
      ra_load => inst_decoder_ra_load_wire,
      pc_opcode => inst_decoder_pc_opcode_wire,
      lock => inst_decoder_lock_wire,
      lock_r => inst_decoder_lock_r_wire,
      clk => clk,
      rstx => rstx,
      locked => locked,
      simm_B0 => inst_decoder_simm_B0_wire,
      simm_cntrl_B0 => inst_decoder_simm_cntrl_B0_wire,
      simm_B1 => inst_decoder_simm_B1_wire,
      simm_cntrl_B1 => inst_decoder_simm_cntrl_B1_wire,
      simm_B2 => inst_decoder_simm_B2_wire,
      simm_cntrl_B2 => inst_decoder_simm_cntrl_B2_wire,
      socket_bool_i1_bus_cntrl => inst_decoder_socket_bool_i1_bus_cntrl_wire,
      socket_bool_o1_bus_cntrl => inst_decoder_socket_bool_o1_bus_cntrl_wire,
      socket_gcu_i1_bus_cntrl => inst_decoder_socket_gcu_i1_bus_cntrl_wire,
      socket_gcu_i2_bus_cntrl => inst_decoder_socket_gcu_i2_bus_cntrl_wire,
      socket_gcu_o1_bus_cntrl => inst_decoder_socket_gcu_o1_bus_cntrl_wire,
      socket_ALU_i1_bus_cntrl => inst_decoder_socket_ALU_i1_bus_cntrl_wire,
      socket_ALU_i2_bus_cntrl => inst_decoder_socket_ALU_i2_bus_cntrl_wire,
      socket_ALU_o1_bus_cntrl => inst_decoder_socket_ALU_o1_bus_cntrl_wire,
      socket_IMM_rd_bus_cntrl => inst_decoder_socket_IMM_rd_bus_cntrl_wire,
      socket_R1_32_bus_cntrl => inst_decoder_socket_R1_32_bus_cntrl_wire,
      socket_ALU_o1_1_bus_cntrl => inst_decoder_socket_ALU_o1_1_bus_cntrl_wire,
      socket_ALU_o1_1_1_bus_cntrl => inst_decoder_socket_ALU_o1_1_1_bus_cntrl_wire,
      socket_ALU_i1_1_1_bus_cntrl => inst_decoder_socket_ALU_i1_1_1_bus_cntrl_wire,
      socket_ALU_i1_1_1_1_bus_cntrl => inst_decoder_socket_ALU_i1_1_1_1_bus_cntrl_wire,
      socket_ALU_i1_1_1_1_1_bus_cntrl => inst_decoder_socket_ALU_i1_1_1_1_1_bus_cntrl_wire,
      socket_ALU_o1_1_1_1_bus_cntrl => inst_decoder_socket_ALU_o1_1_1_1_bus_cntrl_wire,
      socket_ALU_o1_1_1_3_bus_cntrl => inst_decoder_socket_ALU_o1_1_1_3_bus_cntrl_wire,
      socket_ALU_o1_1_1_2_1_bus_cntrl => inst_decoder_socket_ALU_o1_1_1_2_1_bus_cntrl_wire,
      socket_ALU_o1_1_1_2_1_1_bus_cntrl => inst_decoder_socket_ALU_o1_1_1_2_1_1_bus_cntrl_wire,
      socket_ALU_o1_1_1_2_1_2_bus_cntrl => inst_decoder_socket_ALU_o1_1_1_2_1_2_bus_cntrl_wire,
      socket_R1_32_1_bus_cntrl => inst_decoder_socket_R1_32_1_bus_cntrl_wire,
      socket_ALU_o1_1_2_1_bus_cntrl => inst_decoder_socket_ALU_o1_1_2_1_bus_cntrl_wire,
      socket_ALU_o1_1_1_1_2_bus_cntrl => inst_decoder_socket_ALU_o1_1_1_1_2_bus_cntrl_wire,
      socket_ALU_i2_1_bus_cntrl => inst_decoder_socket_ALU_i2_1_bus_cntrl_wire,
      socket_ALU_i2_2_bus_cntrl => inst_decoder_socket_ALU_i2_2_bus_cntrl_wire,
      socket_ALU_o1_2_bus_cntrl => inst_decoder_socket_ALU_o1_2_bus_cntrl_wire,
      socket_R1_32_2_bus_cntrl => inst_decoder_socket_R1_32_2_bus_cntrl_wire,
      socket_R1_32_1_2_bus_cntrl => inst_decoder_socket_R1_32_1_2_bus_cntrl_wire,
      socket_ALU_i1_1_1_1_2_bus_cntrl => inst_decoder_socket_ALU_i1_1_1_1_2_bus_cntrl_wire,
      fu_ALU_0_in1t_load => inst_decoder_fu_ALU_0_in1t_load_wire,
      fu_ALU_0_in2_load => inst_decoder_fu_ALU_0_in2_load_wire,
      fu_ALU_0_opc => inst_decoder_fu_ALU_0_opc_wire,
      fu_VLSU_in1t_load => inst_decoder_fu_VLSU_in1t_load_wire,
      fu_VLSU_in3_load => inst_decoder_fu_VLSU_in3_load_wire,
      fu_VLSU_opc => inst_decoder_fu_VLSU_opc_wire,
      fu_VALU_int0_load => inst_decoder_fu_VALU_int0_load_wire,
      fu_VALU_in2_load => inst_decoder_fu_VALU_in2_load_wire,
      fu_VALU_in1_load => inst_decoder_fu_VALU_in1_load_wire,
      fu_VALU_opc => inst_decoder_fu_VALU_opc_wire,
      fu_VBCAST_in1t_load => inst_decoder_fu_VBCAST_in1t_load_wire,
      fu_VEXTRACT_in1t_load => inst_decoder_fu_VEXTRACT_in1t_load_wire,
      fu_VEXTRACT_in2_load => inst_decoder_fu_VEXTRACT_in2_load_wire,
      fu_ALU_1_in1t_load => inst_decoder_fu_ALU_1_in1t_load_wire,
      fu_ALU_1_in2_load => inst_decoder_fu_ALU_1_in2_load_wire,
      fu_ALU_1_opc => inst_decoder_fu_ALU_1_opc_wire,
      fu_PARAM_LSU_in1t_load => inst_decoder_fu_PARAM_LSU_in1t_load_wire,
      fu_PARAM_LSU_in2_load => inst_decoder_fu_PARAM_LSU_in2_load_wire,
      fu_PARAM_LSU_opc => inst_decoder_fu_PARAM_LSU_opc_wire,
      fu_DATA_LSU_in1t_load => inst_decoder_fu_DATA_LSU_in1t_load_wire,
      fu_DATA_LSU_in2_load => inst_decoder_fu_DATA_LSU_in2_load_wire,
      fu_DATA_LSU_opc => inst_decoder_fu_DATA_LSU_opc_wire,
      rf_BOOL_wr_load => inst_decoder_rf_BOOL_wr_load_wire,
      rf_BOOL_wr_opc => inst_decoder_rf_BOOL_wr_opc_wire,
      rf_BOOL_rd_load => inst_decoder_rf_BOOL_rd_load_wire,
      rf_BOOL_rd_opc => inst_decoder_rf_BOOL_rd_opc_wire,
      rf_RF_32_0_R1_32_load => inst_decoder_rf_RF_32_0_R1_32_load_wire,
      rf_RF_32_0_R1_32_opc => inst_decoder_rf_RF_32_0_R1_32_opc_wire,
      rf_RF_32_0_W1_32_load => inst_decoder_rf_RF_32_0_W1_32_load_wire,
      rf_RF_32_0_W1_32_opc => inst_decoder_rf_RF_32_0_W1_32_opc_wire,
      rf_RF_32_0_R2_load => inst_decoder_rf_RF_32_0_R2_load_wire,
      rf_RF_32_0_R2_opc => inst_decoder_rf_RF_32_0_R2_opc_wire,
      rf_RF_128_0_R1_32_load => inst_decoder_rf_RF_128_0_R1_32_load_wire,
      rf_RF_128_0_R1_32_opc => inst_decoder_rf_RF_128_0_R1_32_opc_wire,
      rf_RF_128_0_W1_32_load => inst_decoder_rf_RF_128_0_W1_32_load_wire,
      rf_RF_128_0_W1_32_opc => inst_decoder_rf_RF_128_0_W1_32_opc_wire,
      rf_RF_128_0_R2_load => inst_decoder_rf_RF_128_0_R2_load_wire,
      rf_RF_128_0_R2_opc => inst_decoder_rf_RF_128_0_R2_opc_wire,
      iu_IU_1x32_r0_read_load => inst_decoder_iu_IU_1x32_r0_read_load_wire,
      iu_IU_1x32_r0_read_opc => inst_decoder_iu_IU_1x32_r0_read_opc_wire,
      iu_IU_1x32_write => inst_decoder_iu_IU_1x32_write_wire,
      iu_IU_1x32_write_load => inst_decoder_iu_IU_1x32_write_load_wire,
      iu_IU_1x32_write_opc => inst_decoder_iu_IU_1x32_write_opc_wire,
      rf_guard_BOOL_0 => inst_decoder_rf_guard_BOOL_0_wire,
      rf_guard_BOOL_1 => inst_decoder_rf_guard_BOOL_1_wire,
      lock_req => inst_decoder_lock_req_wire,
      glock => inst_decoder_glock_wire);

  fu_PARAM_LSU : fu_lsu_always_3
    generic map (
      dataw_g => fu_PARAM_LSU_dataw_g,
      addrw_g => fu_PARAM_LSU_addrw_g,
      latency_g => 3)
    port map (
      t1data_i => fu_PARAM_LSU_t1data_i_wire,
      t1load_i => fu_PARAM_LSU_t1load_i_wire,
      r1data_o => fu_PARAM_LSU_r1data_o_wire,
      o1data_i => fu_PARAM_LSU_o1data_i_wire,
      o1load_i => fu_PARAM_LSU_o1load_i_wire,
      o1opcode_i => fu_PARAM_LSU_o1opcode_i_wire,
      mem_addr_o => fu_PARAM_LSU_mem_addr_o,
      mem_en_o => fu_PARAM_LSU_mem_en_o,
      mem_wr_o => fu_PARAM_LSU_mem_wr_o,
      mem_sel_o => fu_PARAM_LSU_mem_sel_o,
      mem_wdata_o => fu_PARAM_LSU_mem_wdata_o,
      mem_rdata_i => fu_PARAM_LSU_mem_rdata_i,
      mem_ready_i => fu_PARAM_LSU_mem_ready_i,
      clk_i => clk,
      reset_n_i => rstx,
      glock_i => fu_PARAM_LSU_glock_i_wire,
      glock_req_o => fu_PARAM_LSU_glock_req_o_wire);

  fu_ALU_1 : fu_add_and_eq_gt_gtu_ior_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1
    generic map (
      dataw => 32)
    port map (
      t1data => fu_ALU_1_t1data_wire,
      t1load => fu_ALU_1_t1load_wire,
      r1data => fu_ALU_1_r1data_wire,
      o1data => fu_ALU_1_o1data_wire,
      o1load => fu_ALU_1_o1load_wire,
      t1opcode => fu_ALU_1_t1opcode_wire,
      clk => clk,
      rstx => rstx,
      glock => fu_ALU_1_glock_wire);

  fu_ALU_0 : fu_add_and_eq_gt_gtu_ior_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1
    generic map (
      dataw => 32)
    port map (
      t1data => fu_ALU_0_t1data_wire,
      t1load => fu_ALU_0_t1load_wire,
      r1data => fu_ALU_0_r1data_wire,
      o1data => fu_ALU_0_o1data_wire,
      o1load => fu_ALU_0_o1load_wire,
      t1opcode => fu_ALU_0_t1opcode_wire,
      clk => clk,
      rstx => rstx,
      glock => fu_ALU_0_glock_wire);

  fu_DATA_LSU : fu_lsu_always_3
    generic map (
      dataw_g => fu_DATA_LSU_dataw_g,
      addrw_g => fu_DATA_LSU_addrw_g,
      latency_g => 3)
    port map (
      t1data_i => fu_DATA_LSU_t1data_i_wire,
      t1load_i => fu_DATA_LSU_t1load_i_wire,
      r1data_o => fu_DATA_LSU_r1data_o_wire,
      o1data_i => fu_DATA_LSU_o1data_i_wire,
      o1load_i => fu_DATA_LSU_o1load_i_wire,
      o1opcode_i => fu_DATA_LSU_o1opcode_i_wire,
      mem_addr_o => fu_DATA_LSU_mem_addr_o,
      mem_en_o => fu_DATA_LSU_mem_en_o,
      mem_wr_o => fu_DATA_LSU_mem_wr_o,
      mem_sel_o => fu_DATA_LSU_mem_sel_o,
      mem_wdata_o => fu_DATA_LSU_mem_wdata_o,
      mem_rdata_i => fu_DATA_LSU_mem_rdata_i,
      mem_ready_i => fu_DATA_LSU_mem_ready_i,
      clk_i => clk,
      reset_n_i => rstx,
      glock_i => fu_DATA_LSU_glock_i_wire,
      glock_req_o => fu_DATA_LSU_glock_req_o_wire);

  fu_VLSU : fu_vec_lsu
    generic map (
      elemcount_g => 4,
      addrw_g => fu_VLSU_addrw_g,
      latency_g => 6,
      dataw_g => fu_VLSU_dataw_g)
    port map (
      t1data_i => fu_VLSU_t1data_i_wire,
      t1load_i => fu_VLSU_t1load_i_wire,
      r1data_o => fu_VLSU_r1data_o_wire,
      o1data_i => fu_VLSU_o1data_i_wire,
      o1load_i => fu_VLSU_o1load_i_wire,
      t1opcode_i => fu_VLSU_t1opcode_i_wire,
      mem_addr_o => fu_VLSU_mem_addr_o,
      mem_en_o => fu_VLSU_mem_en_o,
      mem_sel_o => fu_VLSU_mem_sel_o,
      mem_wr_o => fu_VLSU_mem_wr_o,
      mem_wdata_o => fu_VLSU_mem_wdata_o,
      mem_rdata_i => fu_VLSU_mem_rdata_i,
      mem_ready_i => fu_VLSU_mem_ready_i,
      clk_i => clk,
      reset_n_i => rstx,
      glock_i => fu_VLSU_glock_i_wire,
      glock_req_o => fu_VLSU_glock_req_o_wire);

  fu_VEXTRACT : fu_vextract_always_1
    generic map (
      dataw_g => 32,
      elemcount_g => 4)
    port map (
      t1data => fu_VEXTRACT_t1data_wire,
      t1load => fu_VEXTRACT_t1load_wire,
      r1data => fu_VEXTRACT_r1data_wire,
      o1data => fu_VEXTRACT_o1data_wire,
      o1load => fu_VEXTRACT_o1load_wire,
      clk => clk,
      rstx => rstx,
      glock => fu_VEXTRACT_glock_wire);

  fu_VBCAST : fu_vbcast32x4_always_1
    generic map (
      dataw_g => 32,
      elemcount_g => 4)
    port map (
      t1data => fu_VBCAST_t1data_wire,
      t1load => fu_VBCAST_t1load_wire,
      r1data => fu_VBCAST_r1data_wire,
      clk => clk,
      rstx => rstx,
      glock => fu_VBCAST_glock_wire);

  fu_VALU : fu_add_and_eq_gt_gtu_ior_mac_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1_v4
    port map (
      t1data => fu_VALU_t1data_wire,
      t1load => fu_VALU_t1load_wire,
      r1data => fu_VALU_r1data_wire,
      o1data => fu_VALU_o1data_wire,
      o1load => fu_VALU_o1load_wire,
      o2data => fu_VALU_o2data_wire,
      o2load => fu_VALU_o2load_wire,
      t1opcode => fu_VALU_t1opcode_wire,
      clk => clk,
      rstx => rstx,
      glock => fu_VALU_glock_wire);

  rf_BOOL : rf_1wr_1rd_always_1_guarded_1
    generic map (
      dataw => 1,
      rf_size => 2)
    port map (
      r1data => rf_BOOL_r1data_wire,
      r1load => rf_BOOL_r1load_wire,
      r1opcode => rf_BOOL_r1opcode_wire,
      t1data => rf_BOOL_t1data_wire,
      t1load => rf_BOOL_t1load_wire,
      t1opcode => rf_BOOL_t1opcode_wire,
      guard => rf_BOOL_guard_wire,
      clk => clk,
      rstx => rstx,
      glock => rf_BOOL_glock_wire);

  rf_RF_32_0 : rf_1wr_2rd_always_1_guarded_1
    generic map (
      dataw => 32,
      rf_size => 32)
    port map (
      r1data => rf_RF_32_0_r1data_wire,
      r1load => rf_RF_32_0_r1load_wire,
      r1opcode => rf_RF_32_0_r1opcode_wire,
      r2data => rf_RF_32_0_r2data_wire,
      r2load => rf_RF_32_0_r2load_wire,
      r2opcode => rf_RF_32_0_r2opcode_wire,
      t1data => rf_RF_32_0_t1data_wire,
      t1load => rf_RF_32_0_t1load_wire,
      t1opcode => rf_RF_32_0_t1opcode_wire,
      guard => rf_RF_32_0_guard_wire,
      clk => clk,
      rstx => rstx,
      glock => rf_RF_32_0_glock_wire);

  rf_RF_128_0 : rf_1wr_2rd_always_1_guarded_1
    generic map (
      dataw => 128,
      rf_size => 32)
    port map (
      r1data => rf_RF_128_0_r1data_wire,
      r1load => rf_RF_128_0_r1load_wire,
      r1opcode => rf_RF_128_0_r1opcode_wire,
      r2data => rf_RF_128_0_r2data_wire,
      r2load => rf_RF_128_0_r2load_wire,
      r2opcode => rf_RF_128_0_r2opcode_wire,
      t1data => rf_RF_128_0_t1data_wire,
      t1load => rf_RF_128_0_t1load_wire,
      t1opcode => rf_RF_128_0_t1opcode_wire,
      guard => rf_RF_128_0_guard_wire,
      clk => clk,
      rstx => rstx,
      glock => rf_RF_128_0_glock_wire);

  iu_IU_1x32 : rf_1wr_1rd_always_1_guarded_0
    generic map (
      dataw => 32,
      rf_size => 1)
    port map (
      r1data => iu_IU_1x32_r1data_wire,
      r1load => iu_IU_1x32_r1load_wire,
      r1opcode => iu_IU_1x32_r1opcode_wire,
      t1data => iu_IU_1x32_t1data_wire,
      t1load => iu_IU_1x32_t1load_wire,
      t1opcode => iu_IU_1x32_t1opcode_wire,
      guard => iu_IU_1x32_guard_wire,
      clk => clk,
      rstx => rstx,
      glock => iu_IU_1x32_glock_wire);

  ic : tta0_interconn
    port map (
      clk => clk,
      rstx => rstx,
      glock => ic_glock_wire,
      socket_bool_i1_data => ic_socket_bool_i1_data_wire,
      socket_bool_i1_bus_cntrl => ic_socket_bool_i1_bus_cntrl_wire,
      socket_bool_o1_data0 => ic_socket_bool_o1_data0_wire,
      socket_bool_o1_bus_cntrl => ic_socket_bool_o1_bus_cntrl_wire,
      socket_gcu_i1_data => ic_socket_gcu_i1_data_wire,
      socket_gcu_i1_bus_cntrl => ic_socket_gcu_i1_bus_cntrl_wire,
      socket_gcu_i2_data => ic_socket_gcu_i2_data_wire,
      socket_gcu_i2_bus_cntrl => ic_socket_gcu_i2_bus_cntrl_wire,
      socket_gcu_o1_data0 => ic_socket_gcu_o1_data0_wire,
      socket_gcu_o1_bus_cntrl => ic_socket_gcu_o1_bus_cntrl_wire,
      socket_ALU_i1_data => ic_socket_ALU_i1_data_wire,
      socket_ALU_i1_bus_cntrl => ic_socket_ALU_i1_bus_cntrl_wire,
      socket_ALU_i2_data => ic_socket_ALU_i2_data_wire,
      socket_ALU_i2_bus_cntrl => ic_socket_ALU_i2_bus_cntrl_wire,
      socket_ALU_o1_data0 => ic_socket_ALU_o1_data0_wire,
      socket_ALU_o1_bus_cntrl => ic_socket_ALU_o1_bus_cntrl_wire,
      socket_IMM_rd_data0 => ic_socket_IMM_rd_data0_wire,
      socket_IMM_rd_bus_cntrl => ic_socket_IMM_rd_bus_cntrl_wire,
      socket_R1_32_data0 => ic_socket_R1_32_data0_wire,
      socket_R1_32_bus_cntrl => ic_socket_R1_32_bus_cntrl_wire,
      socket_W1_32_data => ic_socket_W1_32_data_wire,
      socket_ALU_o1_1_data0 => ic_socket_ALU_o1_1_data0_wire,
      socket_ALU_o1_1_bus_cntrl => ic_socket_ALU_o1_1_bus_cntrl_wire,
      socket_ALU_i1_4_data => ic_socket_ALU_i1_4_data_wire,
      socket_ALU_o1_1_1_data0 => ic_socket_ALU_o1_1_1_data0_wire,
      socket_ALU_o1_1_1_bus_cntrl => ic_socket_ALU_o1_1_1_bus_cntrl_wire,
      socket_ALU_i1_1_1_data => ic_socket_ALU_i1_1_1_data_wire,
      socket_ALU_i1_1_1_bus_cntrl => ic_socket_ALU_i1_1_1_bus_cntrl_wire,
      socket_ALU_i1_1_1_1_data => ic_socket_ALU_i1_1_1_1_data_wire,
      socket_ALU_i1_1_1_1_bus_cntrl => ic_socket_ALU_i1_1_1_1_bus_cntrl_wire,
      socket_ALU_i1_1_1_1_1_data => ic_socket_ALU_i1_1_1_1_1_data_wire,
      socket_ALU_i1_1_1_1_1_bus_cntrl => ic_socket_ALU_i1_1_1_1_1_bus_cntrl_wire,
      socket_ALU_o1_1_1_1_data0 => ic_socket_ALU_o1_1_1_1_data0_wire,
      socket_ALU_o1_1_1_1_bus_cntrl => ic_socket_ALU_o1_1_1_1_bus_cntrl_wire,
      socket_ALU_o1_1_1_3_data0 => ic_socket_ALU_o1_1_1_3_data0_wire,
      socket_ALU_o1_1_1_3_bus_cntrl => ic_socket_ALU_o1_1_1_3_bus_cntrl_wire,
      socket_ALU_o1_1_1_2_1_data => ic_socket_ALU_o1_1_1_2_1_data_wire,
      socket_ALU_o1_1_1_2_1_bus_cntrl => ic_socket_ALU_o1_1_1_2_1_bus_cntrl_wire,
      socket_ALU_o1_1_1_2_1_1_data => ic_socket_ALU_o1_1_1_2_1_1_data_wire,
      socket_ALU_o1_1_1_2_1_1_bus_cntrl => ic_socket_ALU_o1_1_1_2_1_1_bus_cntrl_wire,
      socket_ALU_o1_1_1_2_1_2_data => ic_socket_ALU_o1_1_1_2_1_2_data_wire,
      socket_ALU_o1_1_1_2_1_2_bus_cntrl => ic_socket_ALU_o1_1_1_2_1_2_bus_cntrl_wire,
      socket_W1_32_1_data => ic_socket_W1_32_1_data_wire,
      socket_R1_32_1_data0 => ic_socket_R1_32_1_data0_wire,
      socket_R1_32_1_bus_cntrl => ic_socket_R1_32_1_bus_cntrl_wire,
      socket_ALU_o1_1_2_1_data0 => ic_socket_ALU_o1_1_2_1_data0_wire,
      socket_ALU_o1_1_2_1_bus_cntrl => ic_socket_ALU_o1_1_2_1_bus_cntrl_wire,
      socket_ALU_i1_1_1_1_1_1_2_5_data => ic_socket_ALU_i1_1_1_1_1_1_2_5_data_wire,
      socket_ALU_i1_1_1_1_1_1_2_6_data => ic_socket_ALU_i1_1_1_1_1_1_2_6_data_wire,
      socket_ALU_i1_1_1_1_1_2_data => ic_socket_ALU_i1_1_1_1_1_2_data_wire,
      socket_ALU_i1_1_1_1_3_data => ic_socket_ALU_i1_1_1_1_3_data_wire,
      socket_ALU_o1_1_1_1_2_data0 => ic_socket_ALU_o1_1_1_1_2_data0_wire,
      socket_ALU_o1_1_1_1_2_bus_cntrl => ic_socket_ALU_o1_1_1_1_2_bus_cntrl_wire,
      socket_ALU_i2_1_data => ic_socket_ALU_i2_1_data_wire,
      socket_ALU_i2_1_bus_cntrl => ic_socket_ALU_i2_1_bus_cntrl_wire,
      socket_ALU_i2_2_data => ic_socket_ALU_i2_2_data_wire,
      socket_ALU_i2_2_bus_cntrl => ic_socket_ALU_i2_2_bus_cntrl_wire,
      socket_ALU_o1_2_data0 => ic_socket_ALU_o1_2_data0_wire,
      socket_ALU_o1_2_bus_cntrl => ic_socket_ALU_o1_2_bus_cntrl_wire,
      socket_R1_32_2_data0 => ic_socket_R1_32_2_data0_wire,
      socket_R1_32_2_bus_cntrl => ic_socket_R1_32_2_bus_cntrl_wire,
      socket_R1_32_1_2_data0 => ic_socket_R1_32_1_2_data0_wire,
      socket_R1_32_1_2_bus_cntrl => ic_socket_R1_32_1_2_bus_cntrl_wire,
      socket_ALU_i1_1_1_1_2_data => ic_socket_ALU_i1_1_1_1_2_data_wire,
      socket_ALU_i1_1_1_1_2_bus_cntrl => ic_socket_ALU_i1_1_1_1_2_bus_cntrl_wire,
      simm_B0 => ic_simm_B0_wire,
      simm_cntrl_B0 => ic_simm_cntrl_B0_wire,
      simm_B1 => ic_simm_B1_wire,
      simm_cntrl_B1 => ic_simm_cntrl_B1_wire,
      simm_B2 => ic_simm_B2_wire,
      simm_cntrl_B2 => ic_simm_cntrl_B2_wire);

end structural;
