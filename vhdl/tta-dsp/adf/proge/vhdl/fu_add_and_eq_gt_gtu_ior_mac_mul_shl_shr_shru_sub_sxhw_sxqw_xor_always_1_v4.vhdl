-- This file is generated. Do not modify!

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Std_Logic_arith.all;

entity fu_add_and_eq_gt_gtu_ior_mac_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1_v4 is
  port(
    t1data	 : in std_logic_vector(127 downto 0);
    t1load	 : in std_logic;
    t1opcode	 : in std_logic_vector(3 downto 0);
    r1data	 : out std_logic_vector(127 downto 0);
    o1data	 : in std_logic_vector(127 downto 0);
    o1load	 : in std_logic;
    o2data	 : in std_logic_vector(127 downto 0);
    o2load	 : in std_logic;
    glock	 : in std_logic;
    rstx	 : in std_logic;
    clk	 : in std_logic);
end fu_add_and_eq_gt_gtu_ior_mac_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1_v4;

architecture rtl of fu_add_and_eq_gt_gtu_ior_mac_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1_v4 is
  signal t1data_s	 : std_logic_vector(127 downto 0);
  signal r1data_s	 : std_logic_vector(127 downto 0);
  signal o1data_s	 : std_logic_vector(127 downto 0);
  signal o2data_s	 : std_logic_vector(127 downto 0);
  signal pipelined_opcode_delay1_r	 : std_logic_vector(3 downto 0);
begin

FU_GEN :
   for i in 0 to 3 generate
     begin
      fu_add_and_eq_gt_gtu_ior_mac_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1_inst : entity work.fu_add_and_eq_gt_gtu_ior_mac_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1
        generic map(
          dataw	 => 32)
        port map(
          t1data	 => t1data_s((i+1)*32-1 downto i*32),
          t1load	 => t1load,
          t1opcode	 => t1opcode,
          r1data	 => r1data_s((i+1)*32-1 downto i*32),
          o1data	 => o1data_s((i+1)*32-1 downto i*32),
          o1load	 => o1load,
          o2data	 => o2data_s((i+1)*32-1 downto i*32),
          o2load	 => o2load,
          glock	 => glock,
          rstx	 => rstx,
          clk	 => clk);
  end generate FU_GEN;


  -- Connects inputs correctly
  input_control: process (t1opcode, t1data, o1data, o2data)
  begin
    case t1opcode is
      when "1100" =>  -- SXHW32X4
        t1data_s(15 downto 0)	 <= t1data(15 downto 0);
        t1data_s(47 downto 32)	 <= t1data(31 downto 16);
        t1data_s(79 downto 64)	 <= t1data(47 downto 32);
        t1data_s(111 downto 96)	 <= t1data(63 downto 48);
      when "1101" =>  -- SXQW32X4
        t1data_s(7 downto 0)	 <= t1data(7 downto 0);
        t1data_s(39 downto 32)	 <= t1data(15 downto 8);
        t1data_s(71 downto 64)	 <= t1data(23 downto 16);
        t1data_s(103 downto 96)	 <= t1data(31 downto 24);
      when others =>  -- Direct connections
        t1data_s	 <= t1data;
        o1data_s	 <= o1data;
        o2data_s	 <= o2data;
    end case;
  end process input_control;


  -- Connects outputs correctly
  output_control: process (r1data_s, pipelined_opcode_delay1_r)
  begin
    r1data	 <= (others=>'0');
    case pipelined_opcode_delay1_r is
      when "0010" =>  -- EQ32X4
        r1data(0 downto 0)	 <= r1data_s(0 downto 0);
        r1data(1 downto 1)	 <= r1data_s(32 downto 32);
        r1data(2 downto 2)	 <= r1data_s(64 downto 64);
        r1data(3 downto 3)	 <= r1data_s(96 downto 96);
      when "0011" =>  -- GT32X4
        r1data(0 downto 0)	 <= r1data_s(0 downto 0);
        r1data(1 downto 1)	 <= r1data_s(32 downto 32);
        r1data(2 downto 2)	 <= r1data_s(64 downto 64);
        r1data(3 downto 3)	 <= r1data_s(96 downto 96);
      when "0100" =>  -- GTU32X4
        r1data(0 downto 0)	 <= r1data_s(0 downto 0);
        r1data(1 downto 1)	 <= r1data_s(32 downto 32);
        r1data(2 downto 2)	 <= r1data_s(64 downto 64);
        r1data(3 downto 3)	 <= r1data_s(96 downto 96);
      when others =>  -- Direct connections
        r1data	 <= r1data_s;
    end case;
  end process output_control;


  -- Pipelines opcode for output_control
  opcode_pipeline_control: process (clk, rstx)
    begin
      if rstx = '0' then
        pipelined_opcode_delay1_r	 <= (others => '0');
      elsif clk'event and clk = '1' then
        if glock='0' then
          pipelined_opcode_delay1_r	 <= t1opcode;
        end if;
      end if;
  end process opcode_pipeline_control;

end rtl;
