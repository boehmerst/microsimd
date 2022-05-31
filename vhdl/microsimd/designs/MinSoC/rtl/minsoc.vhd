library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.crossbar_pkg.all;
use work.core_pkg.all;

entity minsoc is
  port (
    clk_i     : in  std_logic;
    reset_n_i : in  std_logic;
    gpi_i     : in  std_ulogic_vector(3 downto 0);
    gpo_o     : out std_ulogic_vector(7 downto 0)
  );
end entity minsoc;

architecture rtl of minsoc is

  type xbar_mst_t  is (imst, dmst);
  type xbar_slv_t  is (rom, ram);
  type fsl_slave_t is (per_fsl);  

  constant rom_size_c       : integer   := 12; --> 1k x 32
  constant ram_size_c       : integer   := 12; --> 1k x 32
  constant xbar_log2wsize_c : integer   := 12;

  constant nr_slv_c         : integer   := xbar_slv_t'pos(xbar_slv_t'right)+1;
  constant nr_mst_c         : integer   := xbar_mst_t'pos(xbar_mst_t'right)+1;
  constant nr_fsl_c         : positive  := fsl_slave_t'pos(fsl_slave_t'right)+1;
   
  signal dmem               : dmem_in_t; 
  signal xbari0_imem        : imem_in_t;
  signal xbari0_dmem        : scu_dmem_in_t;
  signal xbari0_wait_n      : std_ulogic;
  
  signal corei0_imem        : imem_out_t;
  signal corei0_dmem        : dmem_out_t;

  signal fsl_rsp            : fsl_rsp_array_t(0 to nr_fsl_c-1);
  signal corei0_fsl_sel     : std_ulogic_vector(nr_fsl_c-1 downto 0);
  signal corei0_fsl_req     : fsl_req_t;
  signal peri0_fsl_rsp      : fsl_rsp_t;

  signal xbar_mst_req       : xbar_req_arr_t(0 to nr_mst_c-1);
  signal xbar_slv_rsp       : xbar_rsp_arr_t(0 to nr_slv_c-1);
  signal xbari0_mst_rsp     : xbar_rsp_arr_t(0 to nr_mst_c-1);
  signal xbari0_slv_req     : xbar_req_arr_t(0 to nr_slv_c-1);
  signal xbari0_wait_req    : std_ulogic;

begin
  ------------------------------------------------------------------------------
  -- xbar switch
  ------------------------------------------------------------------------------
  xbari0: entity work.crossbar_wrapper
    generic map (
      nr_slv_g      => nr_slv_c,
      log2_window_g => xbar_log2wsize_c
    )
    port map (
      clk_i         => clk_i,
      reset_n_i     => reset_n_i,
      en_i          => std_one_c,
      init_i        => std_zero_c,
      imem_i        => corei0_imem,
      imem_o        => xbari0_imem,
      dmem_o        => xbari0_dmem,  
      dmem_i        => corei0_dmem.scu,
      wait_n_o      => xbari0_wait_n,   
      slv_req_o     => xbari0_slv_req,
      slv_rsp_i     => xbar_slv_rsp
    );

  ------------------------------------------------------------------------------
  -- 32 bit memory 0
  ------------------------------------------------------------------------------
  mem_rom: block is
    signal mem_dat : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0); 
    signal mem_we  : std_ulogic_vector(3 downto 0);
    signal mem_en  : std_ulogic;
  begin   
    mem_we <= xbari0_slv_req(xbar_slv_t'pos(rom)).sel when xbari0_slv_req(xbar_slv_t'pos(rom)).wr = '1' else "0000";
    mem_en <= xbari0_slv_req(xbar_slv_t'pos(rom)).en;    

    memi0 : entity work.sram_4en
      generic map (
        data_width_g => CFG_DMEM_WIDTH,
        addr_width_g => ram_size_c-2
      )
      port map (
        clk_i  => clk_i,
        wre_i  => mem_we,
        ena_i  => mem_en,
        addr_i => xbari0_slv_req(xbar_slv_t'pos(rom)).addr(ram_size_c-1 downto 2),
        dat_i  => xbari0_slv_req(xbar_slv_t'pos(rom)).wdata,
        dat_o  => mem_dat
      );
    
     xbar_slv_rsp(xbar_slv_t'pos(rom)).rdata <= mem_dat;
  end block mem_rom;

  ------------------------------------------------------------------------------
  -- 32 bit memory 1
  ------------------------------------------------------------------------------
  mem_block1: block is
    signal mem_dat : std_ulogic_vector(CFG_DMEM_WIDTH-1 downto 0); 
    signal mem_we  : std_ulogic_vector(3 downto 0);
    signal mem_en  : std_ulogic;
  begin   
    mem_we <= xbari0_slv_req(xbar_slv_t'pos(ram)).sel when xbari0_slv_req(xbar_slv_t'pos(ram)).wr = '1' else "0000";
    mem_en <= xbari0_slv_req(xbar_slv_t'pos(ram)).en;

    memi0 : entity work.sram_4en
      generic map (
        data_width_g => CFG_DMEM_WIDTH,
        addr_width_g => ram_size_c-2
      )
      port map (
        clk_i  => clk_i,
        wre_i  => mem_we,
        ena_i  => mem_en,
        addr_i => xbari0_slv_req(xbar_slv_t'pos(ram)).addr(ram_size_c-1 downto 2),
        dat_i  => xbari0_slv_req(xbar_slv_t'pos(ram)).wdata,
        dat_o  => mem_dat
      );
    
     xbar_slv_rsp(xbar_slv_t'pos(ram)).rdata <= mem_dat;
  end block mem_block1;

  ------------------------------------------------------------------------------
  -- fsl peripheral
  ------------------------------------------------------------------------------
  peri0: entity work.fsl_per
    port map (
      clk_i     => clk_i,
      reset_n_i => reset_n_i,
      en_i      => std_one_c,
      init_i    => std_zero_c,
      sel_i     => corei0_fsl_sel(fsl_slave_t'pos(per_fsl)),
      fsl_req_i => corei0_fsl_req,
      fsl_rsp_o => peri0_fsl_rsp,
      gpi_i     => gpi_i,
      gpo_o     => gpo_o
  );

  ------------------------------------------------------------------------------
  -- a minimal microsimd cpu core
  ------------------------------------------------------------------------------
  fsl_rsp(fsl_slave_t'pos(per_fsl)) <= peri0_fsl_rsp;

  dmem.scu  <= xbari0_dmem;
  dmem.simd <= dflt_vec_dmem_in_c;        -- since we use internal LSU

  corei0: entity work.core
    generic map (
      use_lsu_g         => true,
      use_barrel_g      => false,
      use_vec_barrel_g  => false,
      use_hw_mul_g      => false,
      use_fsl_g         => true,
      nr_fsl_g          => nr_fsl_c,
      use_vec_mul_g     => false,
      use_shuffle_g     => false,
      use_custom_g      => false,
      mci_custom_g      => false,
      use_irq_g         => false
    )
    port map (
      clk_i     => clk_i,                       
      reset_n_i => reset_n_i,
      init_i    => std_zero_c,
      irq_i     => std_zero_c,
      wait_n_i  => xbari0_wait_n,
      imem_o    => corei0_imem,
      imem_i    => xbari0_imem,
      dmem_o    => corei0_dmem,
      dmem_i    => dmem,
      fsl_sel_o => corei0_fsl_sel,
      fsl_req_o => corei0_fsl_req,
      fsl_rsp_i => fsl_rsp
    );  

end architecture rtl;

