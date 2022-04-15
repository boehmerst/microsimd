library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.ext;
use IEEE.std_logic_arith.sxt;
use work.tta0_globals.all;
use work.tce_util.all;

entity tta0_interconn is

  port (
    clk : in std_logic;
    rstx : in std_logic;
    glock : in std_logic;
    socket_bool_i1_data : out std_logic_vector(0 downto 0);
    socket_bool_i1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_bool_o1_data0 : in std_logic_vector(0 downto 0);
    socket_bool_o1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_gcu_i1_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    socket_gcu_i1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_gcu_i2_data : out std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    socket_gcu_i2_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_gcu_o1_data0 : in std_logic_vector(IMEMADDRWIDTH-1 downto 0);
    socket_gcu_o1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_ALU_i1_data : out std_logic_vector(31 downto 0);
    socket_ALU_i1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_ALU_i2_data : out std_logic_vector(31 downto 0);
    socket_ALU_i2_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_ALU_o1_data0 : in std_logic_vector(31 downto 0);
    socket_ALU_o1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_IMM_rd_data0 : in std_logic_vector(31 downto 0);
    socket_IMM_rd_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_R1_32_data0 : in std_logic_vector(31 downto 0);
    socket_R1_32_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_W1_32_data : out std_logic_vector(31 downto 0);
    socket_ALU_o1_1_data0 : in std_logic_vector(127 downto 0);
    socket_ALU_o1_1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_ALU_i1_4_data : out std_logic_vector(31 downto 0);
    socket_ALU_o1_1_1_data0 : in std_logic_vector(127 downto 0);
    socket_ALU_o1_1_1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_ALU_i1_1_1_data : out std_logic_vector(127 downto 0);
    socket_ALU_i1_1_1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_ALU_i1_1_1_1_data : out std_logic_vector(31 downto 0);
    socket_ALU_i1_1_1_1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_ALU_i1_1_1_1_1_data : out std_logic_vector(17 downto 0);
    socket_ALU_i1_1_1_1_1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_ALU_o1_1_1_1_data0 : in std_logic_vector(31 downto 0);
    socket_ALU_o1_1_1_1_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_ALU_o1_1_1_3_data0 : in std_logic_vector(127 downto 0);
    socket_ALU_o1_1_1_3_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_ALU_o1_1_1_2_1_data : out std_logic_vector(127 downto 0);
    socket_ALU_o1_1_1_2_1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_ALU_o1_1_1_2_1_1_data : out std_logic_vector(127 downto 0);
    socket_ALU_o1_1_1_2_1_1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_ALU_o1_1_1_2_1_2_data : out std_logic_vector(127 downto 0);
    socket_ALU_o1_1_1_2_1_2_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_W1_32_1_data : out std_logic_vector(127 downto 0);
    socket_R1_32_1_data0 : in std_logic_vector(127 downto 0);
    socket_R1_32_1_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_ALU_o1_1_2_1_data0 : in std_logic_vector(31 downto 0);
    socket_ALU_o1_1_2_1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_ALU_i1_1_1_1_1_1_2_5_data : out std_logic_vector(127 downto 0);
    socket_ALU_i1_1_1_1_1_1_2_6_data : out std_logic_vector(31 downto 0);
    socket_ALU_i1_1_1_1_1_2_data : out std_logic_vector(31 downto 0);
    socket_ALU_i1_1_1_1_3_data : out std_logic_vector(14 downto 0);
    socket_ALU_o1_1_1_1_2_data0 : in std_logic_vector(31 downto 0);
    socket_ALU_o1_1_1_1_2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_ALU_i2_1_data : out std_logic_vector(31 downto 0);
    socket_ALU_i2_1_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_ALU_i2_2_data : out std_logic_vector(31 downto 0);
    socket_ALU_i2_2_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_ALU_o1_2_data0 : in std_logic_vector(31 downto 0);
    socket_ALU_o1_2_bus_cntrl : in std_logic_vector(2 downto 0);
    socket_R1_32_2_data0 : in std_logic_vector(31 downto 0);
    socket_R1_32_2_bus_cntrl : in std_logic_vector(1 downto 0);
    socket_R1_32_1_2_data0 : in std_logic_vector(127 downto 0);
    socket_R1_32_1_2_bus_cntrl : in std_logic_vector(0 downto 0);
    socket_ALU_i1_1_1_1_2_data : out std_logic_vector(31 downto 0);
    socket_ALU_i1_1_1_1_2_bus_cntrl : in std_logic_vector(0 downto 0);
    simm_B0 : in std_logic_vector(31 downto 0);
    simm_cntrl_B0 : in std_logic_vector(0 downto 0);
    simm_B1 : in std_logic_vector(31 downto 0);
    simm_cntrl_B1 : in std_logic_vector(0 downto 0);
    simm_B2 : in std_logic_vector(31 downto 0);
    simm_cntrl_B2 : in std_logic_vector(0 downto 0));

end tta0_interconn;

architecture comb_andor of tta0_interconn is

  signal databus_B0 : std_logic_vector(31 downto 0);
  signal databus_B0_alt0 : std_logic_vector(31 downto 0);
  signal databus_B0_alt1 : std_logic_vector(31 downto 0);
  signal databus_B0_alt2 : std_logic_vector(31 downto 0);
  signal databus_B0_alt3 : std_logic_vector(31 downto 0);
  signal databus_B0_alt4 : std_logic_vector(31 downto 0);
  signal databus_B0_alt5 : std_logic_vector(31 downto 0);
  signal databus_B0_alt6 : std_logic_vector(31 downto 0);
  signal databus_B0_alt7 : std_logic_vector(0 downto 0);
  signal databus_B0_alt8 : std_logic_vector(31 downto 0);
  signal databus_B0_simm : std_logic_vector(31 downto 0);
  signal databus_B1 : std_logic_vector(31 downto 0);
  signal databus_B1_alt0 : std_logic_vector(31 downto 0);
  signal databus_B1_alt1 : std_logic_vector(31 downto 0);
  signal databus_B1_alt2 : std_logic_vector(31 downto 0);
  signal databus_B1_alt3 : std_logic_vector(31 downto 0);
  signal databus_B1_alt4 : std_logic_vector(31 downto 0);
  signal databus_B1_alt5 : std_logic_vector(31 downto 0);
  signal databus_B1_alt6 : std_logic_vector(0 downto 0);
  signal databus_B1_alt7 : std_logic_vector(31 downto 0);
  signal databus_B1_simm : std_logic_vector(31 downto 0);
  signal databus_B2 : std_logic_vector(31 downto 0);
  signal databus_B2_alt0 : std_logic_vector(31 downto 0);
  signal databus_B2_alt1 : std_logic_vector(31 downto 0);
  signal databus_B2_alt2 : std_logic_vector(31 downto 0);
  signal databus_B2_alt3 : std_logic_vector(31 downto 0);
  signal databus_B2_alt4 : std_logic_vector(31 downto 0);
  signal databus_B2_alt5 : std_logic_vector(31 downto 0);
  signal databus_B2_simm : std_logic_vector(31 downto 0);
  signal databus_VB0 : std_logic_vector(127 downto 0);
  signal databus_VB0_alt0 : std_logic_vector(127 downto 0);
  signal databus_VB0_alt1 : std_logic_vector(127 downto 0);
  signal databus_VB1 : std_logic_vector(127 downto 0);
  signal databus_VB2 : std_logic_vector(127 downto 0);
  signal databus_VB2_alt0 : std_logic_vector(127 downto 0);
  signal databus_VB3 : std_logic_vector(127 downto 0);
  signal databus_VB3_alt0 : std_logic_vector(127 downto 0);
  signal databus_VB4 : std_logic_vector(127 downto 0);
  signal databus_VB4_alt0 : std_logic_vector(127 downto 0);
  signal databus_VB4_alt1 : std_logic_vector(127 downto 0);
  signal databus_VB5 : std_logic_vector(127 downto 0);
  signal databus_VB5_alt0 : std_logic_vector(127 downto 0);
  signal databus_VB6 : std_logic_vector(127 downto 0);
  signal databus_VB6_alt0 : std_logic_vector(127 downto 0);
  signal databus_VB6_alt1 : std_logic_vector(127 downto 0);
  signal databus_VB6_alt2 : std_logic_vector(127 downto 0);
  signal databus_VB6_alt3 : std_logic_vector(127 downto 0);

  component tta0_input_mux_1
    generic (
      BUSW_0 : integer := 32;
      DATAW : integer := 32);
    port (
      databus0 : in std_logic_vector(BUSW_0-1 downto 0);
      data : out std_logic_vector(DATAW-1 downto 0));
  end component;

  component tta0_input_mux_2
    generic (
      BUSW_0 : integer := 32;
      BUSW_1 : integer := 32;
      DATAW : integer := 32);
    port (
      databus0 : in std_logic_vector(BUSW_0-1 downto 0);
      databus1 : in std_logic_vector(BUSW_1-1 downto 0);
      data : out std_logic_vector(DATAW-1 downto 0);
      databus_cntrl : in std_logic_vector(0 downto 0));
  end component;

  component tta0_input_mux_3
    generic (
      BUSW_0 : integer := 32;
      BUSW_1 : integer := 32;
      BUSW_2 : integer := 32;
      DATAW : integer := 32);
    port (
      databus0 : in std_logic_vector(BUSW_0-1 downto 0);
      databus1 : in std_logic_vector(BUSW_1-1 downto 0);
      databus2 : in std_logic_vector(BUSW_2-1 downto 0);
      data : out std_logic_vector(DATAW-1 downto 0);
      databus_cntrl : in std_logic_vector(1 downto 0));
  end component;

  component tta0_output_socket_cons_1_1
    generic (
      BUSW_0 : integer := 32;
      DATAW_0 : integer := 32);
    port (
      databus0_alt : out std_logic_vector(BUSW_0-1 downto 0);
      data0 : in std_logic_vector(DATAW_0-1 downto 0);
      databus_cntrl : in std_logic_vector(0 downto 0));
  end component;

  component tta0_output_socket_cons_2_1
    generic (
      BUSW_0 : integer := 32;
      BUSW_1 : integer := 32;
      DATAW_0 : integer := 32);
    port (
      databus0_alt : out std_logic_vector(BUSW_0-1 downto 0);
      databus1_alt : out std_logic_vector(BUSW_1-1 downto 0);
      data0 : in std_logic_vector(DATAW_0-1 downto 0);
      databus_cntrl : in std_logic_vector(1 downto 0));
  end component;

  component tta0_output_socket_cons_3_1
    generic (
      BUSW_0 : integer := 32;
      BUSW_1 : integer := 32;
      BUSW_2 : integer := 32;
      DATAW_0 : integer := 32);
    port (
      databus0_alt : out std_logic_vector(BUSW_0-1 downto 0);
      databus1_alt : out std_logic_vector(BUSW_1-1 downto 0);
      databus2_alt : out std_logic_vector(BUSW_2-1 downto 0);
      data0 : in std_logic_vector(DATAW_0-1 downto 0);
      databus_cntrl : in std_logic_vector(2 downto 0));
  end component;


begin -- comb_andor

  ALU_i1 : tta0_input_mux_2
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B2,
      databus1 => databus_B0,
      data => socket_ALU_i1_data,
      databus_cntrl => socket_ALU_i1_bus_cntrl);

  ALU_i1_1_1 : tta0_input_mux_2
    generic map (
      BUSW_0 => 128,
      BUSW_1 => 128,
      DATAW => 128)
    port map (
      databus0 => databus_VB3,
      databus1 => databus_VB5,
      data => socket_ALU_i1_1_1_data,
      databus_cntrl => socket_ALU_i1_1_1_bus_cntrl);

  ALU_i1_1_1_1 : tta0_input_mux_2
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B0,
      data => socket_ALU_i1_1_1_1_data,
      databus_cntrl => socket_ALU_i1_1_1_1_bus_cntrl);

  ALU_i1_1_1_1_1 : tta0_input_mux_2
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW => 18)
    port map (
      databus0 => databus_B0,
      databus1 => databus_B2,
      data => socket_ALU_i1_1_1_1_1_data,
      databus_cntrl => socket_ALU_i1_1_1_1_1_bus_cntrl);

  ALU_i1_1_1_1_1_1_2_5 : tta0_input_mux_1
    generic map (
      BUSW_0 => 128,
      DATAW => 128)
    port map (
      databus0 => databus_VB5,
      data => socket_ALU_i1_1_1_1_1_1_2_5_data);

  ALU_i1_1_1_1_1_1_2_6 : tta0_input_mux_1
    generic map (
      BUSW_0 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      data => socket_ALU_i1_1_1_1_1_1_2_6_data);

  ALU_i1_1_1_1_1_2 : tta0_input_mux_1
    generic map (
      BUSW_0 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B0,
      data => socket_ALU_i1_1_1_1_1_2_data);

  ALU_i1_1_1_1_2 : tta0_input_mux_2
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B0,
      data => socket_ALU_i1_1_1_1_2_data,
      databus_cntrl => socket_ALU_i1_1_1_1_2_bus_cntrl);

  ALU_i1_1_1_1_3 : tta0_input_mux_1
    generic map (
      BUSW_0 => 32,
      DATAW => 15)
    port map (
      databus0 => databus_B1,
      data => socket_ALU_i1_1_1_1_3_data);

  ALU_i1_4 : tta0_input_mux_1
    generic map (
      BUSW_0 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      data => socket_ALU_i1_4_data);

  ALU_i2 : tta0_input_mux_2
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B0,
      data => socket_ALU_i2_data,
      databus_cntrl => socket_ALU_i2_bus_cntrl);

  ALU_i2_1 : tta0_input_mux_2
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B0,
      databus1 => databus_B2,
      data => socket_ALU_i2_1_data,
      databus_cntrl => socket_ALU_i2_1_bus_cntrl);

  ALU_i2_2 : tta0_input_mux_2
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B1,
      databus1 => databus_B2,
      data => socket_ALU_i2_2_data,
      databus_cntrl => socket_ALU_i2_2_bus_cntrl);

  ALU_o1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B0_alt0,
      databus1_alt => databus_B1_alt0,
      databus2_alt => databus_B2_alt0,
      data0 => socket_ALU_o1_data0,
      databus_cntrl => socket_ALU_o1_bus_cntrl);

  ALU_o1_1 : tta0_output_socket_cons_2_1
    generic map (
      BUSW_0 => 128,
      BUSW_1 => 128,
      DATAW_0 => 128)
    port map (
      databus0_alt => databus_VB0_alt0,
      databus1_alt => databus_VB6_alt0,
      data0 => socket_ALU_o1_1_data0,
      databus_cntrl => socket_ALU_o1_1_bus_cntrl);

  ALU_o1_1_1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 128,
      BUSW_1 => 128,
      BUSW_2 => 128,
      DATAW_0 => 128)
    port map (
      databus0_alt => databus_VB6_alt1,
      databus1_alt => databus_VB4_alt0,
      databus2_alt => databus_VB2_alt0,
      data0 => socket_ALU_o1_1_1_data0,
      databus_cntrl => socket_ALU_o1_1_1_bus_cntrl);

  ALU_o1_1_1_1 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B2_alt1,
      databus1_alt => databus_B0_alt1,
      databus2_alt => databus_B1_alt1,
      data0 => socket_ALU_o1_1_1_1_data0,
      databus_cntrl => socket_ALU_o1_1_1_1_bus_cntrl);

  ALU_o1_1_1_1_2 : tta0_output_socket_cons_2_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B2_alt2,
      databus1_alt => databus_B0_alt2,
      data0 => socket_ALU_o1_1_1_1_2_data0,
      databus_cntrl => socket_ALU_o1_1_1_1_2_bus_cntrl);

  ALU_o1_1_1_2_1 : tta0_input_mux_3
    generic map (
      BUSW_0 => 128,
      BUSW_1 => 128,
      BUSW_2 => 128,
      DATAW => 128)
    port map (
      databus0 => databus_VB0,
      databus1 => databus_VB4,
      databus2 => databus_VB2,
      data => socket_ALU_o1_1_1_2_1_data,
      databus_cntrl => socket_ALU_o1_1_1_2_1_bus_cntrl);

  ALU_o1_1_1_2_1_1 : tta0_input_mux_2
    generic map (
      BUSW_0 => 128,
      BUSW_1 => 128,
      DATAW => 128)
    port map (
      databus0 => databus_VB1,
      databus1 => databus_VB5,
      data => socket_ALU_o1_1_1_2_1_1_data,
      databus_cntrl => socket_ALU_o1_1_1_2_1_1_bus_cntrl);

  ALU_o1_1_1_2_1_2 : tta0_input_mux_2
    generic map (
      BUSW_0 => 128,
      BUSW_1 => 128,
      DATAW => 128)
    port map (
      databus0 => databus_VB0,
      databus1 => databus_VB4,
      data => socket_ALU_o1_1_1_2_1_2_data,
      databus_cntrl => socket_ALU_o1_1_1_2_1_2_bus_cntrl);

  ALU_o1_1_1_3 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 128,
      BUSW_1 => 128,
      BUSW_2 => 128,
      DATAW_0 => 128)
    port map (
      databus0_alt => databus_VB6_alt2,
      databus1_alt => databus_VB0_alt1,
      databus2_alt => databus_VB3_alt0,
      data0 => socket_ALU_o1_1_1_3_data0,
      databus_cntrl => socket_ALU_o1_1_1_3_bus_cntrl);

  ALU_o1_1_2_1 : tta0_output_socket_cons_1_1
    generic map (
      BUSW_0 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B0_alt3,
      data0 => socket_ALU_o1_1_2_1_data0,
      databus_cntrl => socket_ALU_o1_1_2_1_bus_cntrl);

  ALU_o1_2 : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B0_alt4,
      databus1_alt => databus_B1_alt2,
      databus2_alt => databus_B2_alt3,
      data0 => socket_ALU_o1_2_data0,
      databus_cntrl => socket_ALU_o1_2_bus_cntrl);

  IMM_rd : tta0_output_socket_cons_3_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      BUSW_2 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt3,
      databus1_alt => databus_B0_alt5,
      databus2_alt => databus_B2_alt4,
      data0 => socket_IMM_rd_data0,
      databus_cntrl => socket_IMM_rd_bus_cntrl);

  R1_32 : tta0_output_socket_cons_2_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B0_alt6,
      databus1_alt => databus_B1_alt4,
      data0 => socket_R1_32_data0,
      databus_cntrl => socket_R1_32_bus_cntrl);

  R1_32_1 : tta0_output_socket_cons_2_1
    generic map (
      BUSW_0 => 128,
      BUSW_1 => 128,
      DATAW_0 => 128)
    port map (
      databus0_alt => databus_VB4_alt1,
      databus1_alt => databus_VB6_alt3,
      data0 => socket_R1_32_1_data0,
      databus_cntrl => socket_R1_32_1_bus_cntrl);

  R1_32_1_2 : tta0_output_socket_cons_1_1
    generic map (
      BUSW_0 => 128,
      DATAW_0 => 128)
    port map (
      databus0_alt => databus_VB5_alt0,
      data0 => socket_R1_32_1_2_data0,
      databus_cntrl => socket_R1_32_1_2_bus_cntrl);

  R1_32_2 : tta0_output_socket_cons_2_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_alt5,
      databus1_alt => databus_B2_alt5,
      data0 => socket_R1_32_2_data0,
      databus_cntrl => socket_R1_32_2_bus_cntrl);

  W1_32 : tta0_input_mux_1
    generic map (
      BUSW_0 => 32,
      DATAW => 32)
    port map (
      databus0 => databus_B0,
      data => socket_W1_32_data);

  W1_32_1 : tta0_input_mux_1
    generic map (
      BUSW_0 => 128,
      DATAW => 128)
    port map (
      databus0 => databus_VB6,
      data => socket_W1_32_1_data);

  bool_i1 : tta0_input_mux_2
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW => 1)
    port map (
      databus0 => databus_B0,
      databus1 => databus_B1,
      data => socket_bool_i1_data,
      databus_cntrl => socket_bool_i1_bus_cntrl);

  bool_o1 : tta0_output_socket_cons_2_1
    generic map (
      BUSW_0 => 1,
      BUSW_1 => 1,
      DATAW_0 => 1)
    port map (
      databus0_alt => databus_B0_alt7,
      databus1_alt => databus_B1_alt6,
      data0 => socket_bool_o1_data0,
      databus_cntrl => socket_bool_o1_bus_cntrl);

  gcu_i1 : tta0_input_mux_2
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW => IMEMADDRWIDTH)
    port map (
      databus0 => databus_B0,
      databus1 => databus_B1,
      data => socket_gcu_i1_data,
      databus_cntrl => socket_gcu_i1_bus_cntrl);

  gcu_i2 : tta0_input_mux_2
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW => IMEMADDRWIDTH)
    port map (
      databus0 => databus_B0,
      databus1 => databus_B1,
      data => socket_gcu_i2_data,
      databus_cntrl => socket_gcu_i2_bus_cntrl);

  gcu_o1 : tta0_output_socket_cons_2_1
    generic map (
      BUSW_0 => 32,
      BUSW_1 => 32,
      DATAW_0 => IMEMADDRWIDTH)
    port map (
      databus0_alt => databus_B0_alt8,
      databus1_alt => databus_B1_alt7,
      data0 => socket_gcu_o1_data0,
      databus_cntrl => socket_gcu_o1_bus_cntrl);

  simm_socket_B0 : tta0_output_socket_cons_1_1
    generic map (
      BUSW_0 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B0_simm,
      data0 => simm_B0,
      databus_cntrl => simm_cntrl_B0);

  simm_socket_B1 : tta0_output_socket_cons_1_1
    generic map (
      BUSW_0 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B1_simm,
      data0 => simm_B1,
      databus_cntrl => simm_cntrl_B1);

  simm_socket_B2 : tta0_output_socket_cons_1_1
    generic map (
      BUSW_0 => 32,
      DATAW_0 => 32)
    port map (
      databus0_alt => databus_B2_simm,
      data0 => simm_B2,
      databus_cntrl => simm_cntrl_B2);

  databus_B0 <= tce_ext(databus_B0_alt0, databus_B0'length) or tce_ext(databus_B0_alt1, databus_B0'length) or tce_ext(databus_B0_alt2, databus_B0'length) or tce_ext(databus_B0_alt3, databus_B0'length) or tce_ext(databus_B0_alt4, databus_B0'length) or tce_ext(databus_B0_alt5, databus_B0'length) or tce_ext(databus_B0_alt6, databus_B0'length) or tce_ext(databus_B0_alt7, databus_B0'length) or tce_ext(databus_B0_alt8, databus_B0'length) or tce_sxt(databus_B0_simm, databus_B0'length);
  databus_B1 <= tce_ext(databus_B1_alt0, databus_B1'length) or tce_ext(databus_B1_alt1, databus_B1'length) or tce_ext(databus_B1_alt2, databus_B1'length) or tce_ext(databus_B1_alt3, databus_B1'length) or tce_ext(databus_B1_alt4, databus_B1'length) or tce_ext(databus_B1_alt5, databus_B1'length) or tce_ext(databus_B1_alt6, databus_B1'length) or tce_ext(databus_B1_alt7, databus_B1'length) or tce_sxt(databus_B1_simm, databus_B1'length);
  databus_B2 <= tce_ext(databus_B2_alt0, databus_B2'length) or tce_ext(databus_B2_alt1, databus_B2'length) or tce_ext(databus_B2_alt2, databus_B2'length) or tce_ext(databus_B2_alt3, databus_B2'length) or tce_ext(databus_B2_alt4, databus_B2'length) or tce_ext(databus_B2_alt5, databus_B2'length) or tce_sxt(databus_B2_simm, databus_B2'length);
  databus_VB0 <= tce_ext(databus_VB0_alt0, databus_VB0'length) or tce_ext(databus_VB0_alt1, databus_VB0'length);
  databus_VB1 <= (others=>'0');
  databus_VB2 <= tce_ext(databus_VB2_alt0, databus_VB2'length);
  databus_VB3 <= tce_ext(databus_VB3_alt0, databus_VB3'length);
  databus_VB4 <= tce_ext(databus_VB4_alt0, databus_VB4'length) or tce_ext(databus_VB4_alt1, databus_VB4'length);
  databus_VB5 <= tce_ext(databus_VB5_alt0, databus_VB5'length);
  databus_VB6 <= tce_ext(databus_VB6_alt0, databus_VB6'length) or tce_ext(databus_VB6_alt1, databus_VB6'length) or tce_ext(databus_VB6_alt2, databus_VB6'length) or tce_ext(databus_VB6_alt3, databus_VB6'length);

end comb_andor;
