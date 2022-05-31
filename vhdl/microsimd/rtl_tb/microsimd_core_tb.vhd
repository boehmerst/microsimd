library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.func_pkg.all;
use work.core_pkg.all;
use work.vec_data_pkg.all;

--library tech;
-- TODO: think about how we can use VHDL-2008 customized packages to define technology locally
--use tech.tech_constants_pkg.all;

entity microsimd_core_tb is
end entity microsimd_core_tb;

architecture beh of microsimd_core_tb is

  signal sim_done                : boolean   := false;
  signal clk                     : std_logic := '0';
  signal reset_n                 : std_logic := '0';
  constant clk_cycle_c           : time      := 10 ns;

  constant rom_size_c            : integer   := 15;
  constant ram_size_c            : integer   := 15;
  
  type fsl_link_t is (peripherals);
  constant nr_fsl_c              : positive := fsl_link_t'pos(fsl_link_t'right)+1;
  
  signal imem                    : imem_in_t;
  signal dmem                    : dmem_in_t;
  
  signal corei0_imem             : imem_out_t;
  signal corei0_dmem             : dmem_out_t;
  signal corei0_fsl_sel          : std_ulogic_vector(nr_fsl_c-1 downto 0);
  signal corei0_fsl_req          : fsl_req_t;
   
  signal fsl_rsp                 : fsl_rsp_array_t(0 to nr_fsl_c-1);
  signal bench_gpi               : std_ulogic_vector(3 downto 0) := (others => '0');
  
  signal fsli0_fsl_rsp           : fsl_rsp_t;
  signal fsli0_gpo               : std_ulogic_vector(7 downto 0);
  
begin
  ------------------------------------------------------------------------------
  -- clock and reset
  ------------------------------------------------------------------------------
  clk     <= not clk after clk_cycle_c/2 when sim_done = false;
  reset_n <= '1' after 500 ns;
  
  ------------------------------------------------------------------------------
  -- core
  ------------------------------------------------------------------------------
  fsl_rsp(fsl_link_t'pos(peripherals)) <= fsli0_fsl_rsp;
  
  corei0: entity work.core
    generic map (
      use_barrel_g     => true,  
      use_hw_mul_g     => true,
      use_irq_g        => false,
      use_fsl_g        => true,
      nr_fsl_g         => nr_fsl_c
    )
    port map (
      clk_i            => clk,                       
      reset_n_i        => reset_n,
      init_i           => '0',
      irq_i            => '0',
      wait_n_i         => '1',
      imem_o           => corei0_imem,
      imem_i           => imem,
      dmem_o           => corei0_dmem,
      dmem_i           => dmem,
      fsl_sel_o        => corei0_fsl_sel,
      fsl_req_o        => corei0_fsl_req,
      fsl_rsp_i        => fsl_rsp
    );
    
  ------------------------------------------------------------------------------
  -- 32 Bit instruction memory
  ------------------------------------------------------------------------------
  imemi0 : entity work.sram
    generic map (
      file_name_g  => "./rom/rom.mem",
      data_width_g => CFG_IMEM_WIDTH,
      addr_width_g => rom_size_c-2
    )
    port map (
      clk_i   => clk,
      we_i    => '0',
      en_i    => corei0_imem.ena,
      addr_i  => corei0_imem.adr(rom_size_c-1 downto 2),
      di_i    => (others=>'0'),
      do_o    => imem.dat
    );
    
  ------------------------------------------------------------------------------
  -- 32 Bit data memory
  ------------------------------------------------------------------------------
  dmemi0: block is
    signal mem_we    : std_ulogic_vector(3 downto 0);
    signal mem_en    : std_ulogic;
  begin   
    mem_we <= corei0_dmem.scu.sel when corei0_dmem.scu.we = '1' else "0000";
    mem_en <= corei0_dmem.scu.ena;
    
    memi0 : entity work.sram_4en
      generic map (
        data_width_g => CFG_DMEM_WIDTH,
        addr_width_g => ram_size_c-2
      )
      port map (
        clk_i  => clk,
        wre_i  => mem_we,
        ena_i  => mem_en,
        addr_i => corei0_dmem.scu.adr(ram_size_c-1 downto 2),
        dat_i  => corei0_dmem.scu.dat,
        dat_o  => dmem.scu.dat
      );
  end block dmemi0;

  ------------------------------------------------------------------------------
  -- vector memory generic width depending on number of vector slices
  ------------------------------------------------------------------------------
  vecmemi0: block is
    signal mem_we    : std_ulogic_vector(corei0_dmem.simd.sel'range);
    signal mem_en    : std_ulogic;
    signal mem_rdata : std_ulogic_vector(CFG_VREG_SLICES*CFG_DMEM_WIDTH-1 downto 0);
  begin
  
    mem_we <= corei0_dmem.simd.sel when corei0_dmem.simd.we = '1' else (others=>'0');
    mem_en <= corei0_dmem.simd.ena;
  
    memi0 : entity work.sram_2en
      generic map (
        width_g => CFG_VREG_SLICES*CFG_DMEM_WIDTH,
        size_g  => ram_size_c-3
      )
      port map (
        clk_i  => clk,
        wre_i  => mem_we,
        ena_i  => mem_en,
        addr_i => corei0_dmem.simd.adr(ram_size_c-1 downto 3),
        dat_i  => to_std(corei0_dmem.simd.dat),
        dat_o  => mem_rdata
      );
      
      dmem.simd.dat <= to_vec(mem_rdata);
  end block vecmemi0;
  
  ------------------------------------------------------------------------------
  -- fsl peripheral
  ------------------------------------------------------------------------------
  fsli0: entity work.fsl_per
    port map (
      clk_i     => clk,
      reset_n_i => reset_n,
      en_i      => '1',
      init_i    => '0',
      sel_i     => corei0_fsl_sel(fsl_link_t'pos(peripherals)),
      fsl_req_i => corei0_fsl_req,
      fsl_rsp_o => fsli0_fsl_rsp,
      gpi_i     => bench_gpi,
      gpo_o     => fsli0_gpo
    );

  ------------------------------------------------------------------------------
  -- stimuli
  ------------------------------------------------------------------------------
  stim0: process is
  begin
    wait until reset_n = '1';
    wait until rising_edge(clk);

    -- quit simulation
    wait until fsli0_gpo = x"FF";
    sim_done <= true;
    assert false report "Simulation finished successfully!" severity failure;
    wait;
  end process stim0;
  
end architecture beh;

