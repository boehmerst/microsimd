library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library general;
use general.general_function_pkg.log2ceil;

library microsimd;
use microsimd.func_pkg.all;
use microsimd.hibi_link_pkg.all;
use microsimd.hibi_pif_types_pkg.all;
use microsimd.hibi_wishbone_bridge_regif_types_pkg.all;
use microsimd.hibi_wishbone_bridge_regfile_pkg.all;
use microsimd.hibi_wishbone_bridge_pkg.all;
use microsimd.wishbone_pkg.all;

entity mpsoc_tb is
end entity mpsoc_tb;

architecture beh of mpsoc_tb is

  -----------------------------------------------------------------------------
  -- TODO: find a better place
  -----------------------------------------------------------------------------
  type hibi_targets_t is (CPU0, MEM, BRIDGE, PIF);
  type hibi_addr_array_t is array (0 to 3) of integer;
  constant hibi_addresses_c : hibi_addr_array_t :=(
    16#1000#, 16#3000#, 16#5000#, 16#7000#
  );

  type hibi_dma_direction_t is (send, receive);

  constant hibi_remote_dma_cfg_buffer_c : std_ulogic_vector := x"80000000";

  ------------------------------------------------------------------------------
  -- generic wb transfer
  ------------------------------------------------------------------------------
  procedure wishbone_transfer(req : in wb_req_arr_t; rsp : out wb_rsp_arr_t; constant cnt : in positive; signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin
    req_loop0: for i in 0 to cnt-1 loop
      mst_req <= req(i);

      -- wait for slave ack response
      ready_loop0: while(true) loop
        wait until clk'event and clk = '1';
        exit when slv_rsp.ack = '1';
      end loop ready_loop0;

      rsp(i) := slv_rsp;
    end loop req_loop0;

    mst_req <= dflt_wb_req_c;
  end procedure wishbone_transfer;

  ------------------------------------------------------------------------------
  -- wishbone write transfer
  ------------------------------------------------------------------------------  
  procedure wishbone_write(addr, data : in std_ulogic_vector; signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
    variable req : wb_req_arr_t(0 to 0);
    variable rsp : wb_rsp_arr_t(0 to 0);
  begin
    req(0).adr   := std_ulogic_vector(resize(unsigned(addr), req(0).adr'length));
    req(0).dat   := std_ulogic_vector(resize(unsigned(data), req(0).dat'length));
    req(0).cyc   := '1';
    req(0).stb   := '1';
    req(0).we    := '1';
    req(0).sel   := (others=>'1');
    wishbone_transfer(req, rsp, 1, mst_req, slv_rsp, clk);
  end procedure wishbone_write;

  ------------------------------------------------------------------------------
  -- wishbone read transfer
  ------------------------------------------------------------------------------    
  procedure wishbone_read(addr : in std_ulogic_vector; data : out std_ulogic_vector; signal mst_req : out wb_req_t; 
                          signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
    variable req : wb_req_arr_t(0 to 0);
    variable rsp : wb_rsp_arr_t(0 to 0);  
  begin
    req(0).adr   := std_ulogic_vector(resize(unsigned(addr), req(0).adr'length));
    req(0).dat   := (others => '0');
    req(0).cyc   := '1';
    req(0).stb   := '1';
    req(0).we    := '0';
    req(0).sel   := (others=>'1');
    wishbone_transfer(req, rsp, 1, mst_req, slv_rsp, clk);
    data         := std_ulogic_vector(resize(unsigned(rsp(0).data), data'length));
  end procedure wishbone_read;

  -----------------------------------------------------------------------------
  -- enable HIBI bridge DMA
  -----------------------------------------------------------------------------
  procedure hibi_local_dma_enable(signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
    variable addr_word : std_ulogic_vector(hibi_wishbone_bridge_addr_width_c-1 downto 0);
    variable addr_byte : std_ulogic_vector(hibi_wishbone_bridge_addr_width_c-1 downto 0);
    variable data      : std_ulogic_vector(hibi_wishbone_bridge_data_width_c-1 downto 0);
  begin
    addr_word := addr_offset_HIBI_DMA_CTRL_slv_c;
    addr_byte := addr_word sll 2;
    data      := (bit_offset_HIBI_DMA_CTRL_en_c => '1', others => '0');
    
    wishbone_write(addr_byte, data, mst_req, slv_rsp, clk);
  end procedure hibi_local_dma_enable;


  -----------------------------------------------------------------------------
  -- HIBI DMA transfer
  -----------------------------------------------------------------------------
  procedure hibi_local_dma_transfer(constant channel : in natural; constant hibi_dest_addr : in std_ulogic_vector; constant mem_addr : in std_ulogic_vector; constant count : in positive;  
                                    constant direction : in hibi_dma_direction_t; constant hibi_cmd : in std_ulogic_vector; signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
    variable offset    : integer;
    variable addr_word : std_ulogic_vector(hibi_wishbone_bridge_addr_width_c-1 downto 0);
    variable addr_byte : std_ulogic_vector(hibi_wishbone_bridge_addr_width_c-1 downto 0);
    variable data      : std_ulogic_vector(hibi_wishbone_bridge_data_width_c-1 downto 0);
    variable cfg       : hibi_wishbone_bridge_HIBI_DMA_CFG0_rw_t;
  begin

    offset          := channel * 4;
    addr_word       := std_ulogic_vector(to_unsigned(addr_offset_HIBI_DMA_CFG0_integer_c + offset, addr_word'length));
    addr_byte       := addr_word sll 2;

    cfg             := dflt_hibi_wishbone_bridge_HIBI_DMA_CFG0_c;
    cfg.count       := std_ulogic_vector(to_unsigned(count, dflt_hibi_wishbone_bridge_HIBI_DMA_CFG0_c.count'length));

    cfg.direction   := '0';
    if direction = send then
      cfg.direction := '1';
    end if;
    
    cfg.hibi_cmd    := hibi_cmd;
    cfg.const_addr  := '0';

    data := (others => '0');	      
    
    data(bit_offset_HIBI_DMA_CFG0_count_c + cfg.count'length-1 downto bit_offset_HIBI_DMA_CFG0_count_c)          := cfg.count;
    data(bit_offset_HIBI_DMA_CFG0_direction_c)                                                                   := cfg.direction;
    data(bit_offset_HIBI_DMA_CFG0_hibi_cmd_c + cfg.hibi_cmd'length-1 downto bit_offset_HIBI_DMA_CFG0_hibi_cmd_c) := cfg.hibi_cmd;
    data(bit_offset_HIBI_DMA_CFG0_const_addr_c)                                                                  := cfg.const_addr;

    wishbone_write(addr_byte, data, mst_req, slv_rsp, clk);

    addr_word := std_ulogic_vector(to_unsigned(addr_offset_HIBI_DMA_MEM_ADDR0_integer_c + offset, addr_word'length));
    addr_byte := addr_word sll 2;
    wishbone_write(addr_byte, mem_addr, mst_req, slv_rsp, clk);

    addr_word := std_ulogic_vector(to_unsigned(addr_offset_HIBI_DMA_HIBI_ADDR0_integer_c + offset, addr_word'length));
    addr_byte := addr_word sll 2;
    wishbone_write(addr_byte, hibi_dest_addr, mst_req, slv_rsp, clk);

    addr_word := addr_offset_HIBI_DMA_TRIGGER_slv_c;
    addr_byte := addr_word sll 2;   
    wishbone_write(addr_byte, std_ulogic_vector(unsigned'(x"00000001") sll channel), mst_req, slv_rsp, clk);

  end procedure hibi_local_dma_transfer;


  -----------------------------------------------------------------------------
  -- HIBI bridge DMA send
  -----------------------------------------------------------------------------
  procedure hibi_local_dma_send(constant channel : in natural; constant hibi_dest_addr : in std_ulogic_vector; constant mem_addr : in std_ulogic_vector; constant count : in positive;  
                                signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin
    hibi_local_dma_transfer(channel, hibi_dest_addr, mem_addr, count, send, hibi_wr_data_c, mst_req, slv_rsp, clk);
  end procedure hibi_local_dma_send;


  -----------------------------------------------------------------------------
  -- HIBI bridge DMA rec
  -----------------------------------------------------------------------------
  procedure hibi_local_dma_rec(constant channel : in natural; constant hibi_dest_addr : in std_ulogic_vector; constant mem_addr : in std_ulogic_vector; constant count : in positive;  
                               signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin
    hibi_local_dma_transfer(channel, hibi_dest_addr, mem_addr, count, receive, hibi_rd_data_c, mst_req, slv_rsp, clk);
  end procedure hibi_local_dma_rec;


  -----------------------------------------------------------------------------
  -- HIBI bridge send data
  -----------------------------------------------------------------------------
  procedure hibi_send(constant hibi_dest_addr : in std_ulogic_vector; constant mem_addr : in std_ulogic_vector; constant count : in positive;  
                      signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin
    hibi_local_dma_transfer(0, hibi_dest_addr, mem_addr, count, send, hibi_wr_data_c, mst_req, slv_rsp, clk);
  end procedure hibi_send;


  -----------------------------------------------------------------------------
  -- HIBI bridge receive data
  -----------------------------------------------------------------------------
  procedure hibi_rec(constant hibi_dest_addr : in std_ulogic_vector; constant mem_addr : in std_ulogic_vector; constant count : in positive;  
                     signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin
    hibi_local_dma_transfer(1, hibi_dest_addr, mem_addr, count, receive, hibi_rd_data_c, mst_req, slv_rsp, clk);
  end procedure hibi_rec;


  -----------------------------------------------------------------------------
  -- HIBI bridge send prio
  -----------------------------------------------------------------------------
  procedure hibi_send_prio(constant hibi_dest_addr : in std_ulogic_vector; constant mem_addr : in std_ulogic_vector; constant count : in positive;  
                           signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin
    assert count = 1 report "The remote DMA implementation currently does only support single transfers for prio data" severity warning;
    hibi_local_dma_transfer(0, hibi_dest_addr, mem_addr, count, send, hibi_wr_prio_data_c, mst_req, slv_rsp, clk);
  end procedure hibi_send_prio;


  -----------------------------------------------------------------------------
  -- HIBI bridge receive prio
  -----------------------------------------------------------------------------
  procedure hibi_rec_prio(constant hibi_dest_addr : in std_ulogic_vector; constant mem_addr : in std_ulogic_vector; constant count : in positive;  
                          signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin
    assert count = 1 report "The remote DMA implementation currently does only support single transfers for prio data" severity warning;
    hibi_local_dma_transfer(1, hibi_dest_addr, mem_addr, count, receive, hibi_rd_prio_data_c, mst_req, slv_rsp, clk);
  end procedure hibi_rec_prio;


  -----------------------------------------------------------------------------
  -- HIBI bridge wait for link
  -----------------------------------------------------------------------------
  procedure hibi_wait_link(constant channel : in natural; signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
    variable data : std_ulogic_vector(hibi_wishbone_bridge_data_width_c-1 downto 0);
    constant mask : std_ulogic_vector(hibi_wishbone_bridge_data_width_c-1 downto 0) := std_ulogic_vector(unsigned'(x"00000001") sll channel);
  begin

    busy0: while(true) loop
      wishbone_read(addr_offset_HIBI_DMA_STATUS_slv_c sll 2, data, mst_req, slv_rsp, clk);
      exit when unsigned(data and mask) = 0;
    end loop busy0;

  end procedure hibi_wait_link;


  -----------------------------------------------------------------------------
  -- HIBI bridge send blocking
  -----------------------------------------------------------------------------
  procedure hibi_send_b(constant hibi_dest_addr : in std_ulogic_vector; constant mem_addr : in std_ulogic_vector; constant count : in positive;  
                        signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin
    hibi_send(hibi_dest_addr, mem_addr, count, mst_req, slv_rsp, clk);
    hibi_wait_link(0, mst_req, slv_rsp, clk);
  end procedure hibi_send_b;


  -----------------------------------------------------------------------------
  -- HIBI bridge receive prio blocking
  -----------------------------------------------------------------------------
  procedure hibi_rec_b(constant hibi_dest_addr : in std_ulogic_vector; constant mem_addr : in std_ulogic_vector; constant count : in positive;  
                       signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin
    hibi_rec(hibi_dest_addr, mem_addr, count, mst_req, slv_rsp, clk);
    hibi_wait_link(1, mst_req, slv_rsp, clk);
  end procedure hibi_rec_b;


  -----------------------------------------------------------------------------
  -- HIBI bridge send prio blocking
  -----------------------------------------------------------------------------
  procedure hibi_send_prio_b(constant hibi_dest_addr : in std_ulogic_vector; constant mem_addr : in std_ulogic_vector; constant count : in positive;  
                             signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin
    hibi_send_prio(hibi_dest_addr, mem_addr, count, mst_req, slv_rsp, clk);
    hibi_wait_link(0, mst_req, slv_rsp, clk);
  end procedure hibi_send_prio_b;


  -----------------------------------------------------------------------------
  -- HIBI bridge receive prio blocking
  -----------------------------------------------------------------------------
  procedure hibi_rec_prio_b(constant hibi_dest_addr : in std_ulogic_vector; constant mem_addr : in std_ulogic_vector; constant count : in positive;  
                            signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin
    hibi_rec_prio(hibi_dest_addr, mem_addr, count, mst_req, slv_rsp, clk);
    hibi_wait_link(1, mst_req, slv_rsp, clk);
  end procedure hibi_rec_prio_b;


  -----------------------------------------------------------------------------
  --TODO: how to deal with incompatible remote address maps?
  --      should they foced to be equal?
  --      requires the gpio to be offset?
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- HIBI bridge remote DMA enable
  -----------------------------------------------------------------------------
  procedure hibi_remote_dma_enable(constant hibi_remote_addr : in std_ulogic_vector; signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin
    wishbone_write(hibi_remote_dma_cfg_buffer_c, x"00000001", mst_req, slv_rsp, clk);
    hibi_send_prio_b(hibi_remote_addr or std_logic_vector(resize(addr_offset_HIBI_DMA_CTRL_unsigned_c, hibi_remote_addr'length)), hibi_remote_dma_cfg_buffer_c, 1, mst_req, slv_rsp, clk);
  end procedure hibi_remote_dma_enable;

  -----------------------------------------------------------------------------
  -- HIBI bridge remote DMA rx setup
  -----------------------------------------------------------------------------
  procedure hibi_remote_dma_rx_setup(constant hibi_remote_addr : in std_ulogic_vector; constant channel : in natural; constant mem_addr : in std_ulogic_vector; constant count : in positive;
                                     signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
    variable offset    : integer;
    variable addr_word : std_ulogic_vector(hibi_wishbone_bridge_addr_width_c-1 downto 0);
    variable data      : std_ulogic_vector(hibi_wishbone_bridge_data_width_c-1 downto 0);
    variable cfg       :  hibi_wishbone_bridge_HIBI_DMA_CFG0_rw_t;

  begin
    cfg             := dflt_hibi_wishbone_bridge_HIBI_DMA_CFG0_c;
    cfg.count       := std_ulogic_vector(to_unsigned(count, dflt_hibi_wishbone_bridge_HIBI_DMA_CFG0_c.count'length));
    cfg.direction   := '0';
    cfg.hibi_cmd    := hibi_rd_data_c;
    cfg.const_addr  := '0';

    data := (others => '0');	      
    
    data(bit_offset_HIBI_DMA_CFG0_count_c + cfg.count'length-1 downto bit_offset_HIBI_DMA_CFG0_count_c)          := cfg.count;
    data(bit_offset_HIBI_DMA_CFG0_direction_c)                                                                   := cfg.direction;
    data(bit_offset_HIBI_DMA_CFG0_hibi_cmd_c + cfg.hibi_cmd'length-1 downto bit_offset_HIBI_DMA_CFG0_hibi_cmd_c) := cfg.hibi_cmd;
    data(bit_offset_HIBI_DMA_CFG0_const_addr_c)                                                                  := cfg.const_addr;

    offset          := channel * 4;
    addr_word       := std_ulogic_vector(to_unsigned(addr_offset_HIBI_DMA_CFG0_integer_c + offset, addr_word'length));
   
    wishbone_write(hibi_remote_dma_cfg_buffer_c, data, mst_req, slv_rsp, clk);
    hibi_send_prio_b(hibi_remote_addr or std_logic_vector(resize(unsigned(addr_word), hibi_remote_addr'length)), hibi_remote_dma_cfg_buffer_c, 1, mst_req, slv_rsp, clk);

    addr_word       := std_ulogic_vector(to_unsigned(addr_offset_HIBI_DMA_MEM_ADDR0_integer_c + offset, addr_word'length));

    wishbone_write(hibi_remote_dma_cfg_buffer_c, mem_addr, mst_req, slv_rsp, clk);
    hibi_send_prio_b(hibi_remote_addr or std_logic_vector(resize(unsigned(addr_word), hibi_remote_addr'length)), hibi_remote_dma_cfg_buffer_c, 1, mst_req, slv_rsp, clk);
    
  end procedure hibi_remote_dma_rx_setup;

  -----------------------------------------------------------------------------
  -- HIBI bridge remote DMA tx setup
  -----------------------------------------------------------------------------
  procedure hibi_remote_dma_tx_setup(constant hibi_remote_addr : in std_ulogic_vector; constant channel : in natural; 
                                     constant hibi_dest_addr : in std_ulogic_vector; constant mem_addr : in std_ulogic_vector; 
                                     constant count : in positive; constant const_addr : in boolean; signal mst_req : out wb_req_t; 
                                     signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
    variable offset    : integer;
    variable addr_word : std_ulogic_vector(hibi_wishbone_bridge_addr_width_c-1 downto 0);
    variable data      : std_ulogic_vector(hibi_wishbone_bridge_data_width_c-1 downto 0);
    variable cfg       : hibi_wishbone_bridge_HIBI_DMA_CFG0_rw_t;

  begin
    cfg             := dflt_hibi_wishbone_bridge_HIBI_DMA_CFG0_c;
    cfg.count       := std_ulogic_vector(to_unsigned(count, dflt_hibi_wishbone_bridge_HIBI_DMA_CFG0_c.count'length));
    cfg.direction   := '0';
    cfg.hibi_cmd    := hibi_wr_data_c;
    cfg.const_addr  := '0';

    if const_addr = true then
      cfg.const_addr  := '1';
    end if;

    data := (others => '0');	      
    
    data(bit_offset_HIBI_DMA_CFG0_count_c + cfg.count'length-1 downto bit_offset_HIBI_DMA_CFG0_count_c)          := cfg.count;
    data(bit_offset_HIBI_DMA_CFG0_direction_c)                                                                   := cfg.direction;
    data(bit_offset_HIBI_DMA_CFG0_hibi_cmd_c + cfg.hibi_cmd'length-1 downto bit_offset_HIBI_DMA_CFG0_hibi_cmd_c) := cfg.hibi_cmd;
    data(bit_offset_HIBI_DMA_CFG0_const_addr_c)                                                                  := cfg.const_addr;

    offset          := channel * 4;
    addr_word       := std_ulogic_vector(to_unsigned(addr_offset_HIBI_DMA_CFG0_integer_c + offset, addr_word'length));
    wishbone_write(hibi_remote_dma_cfg_buffer_c, data, mst_req, slv_rsp, clk);
    hibi_send_prio_b(hibi_remote_addr or std_logic_vector(resize(unsigned(addr_word), hibi_remote_addr'length)), hibi_remote_dma_cfg_buffer_c, 1, mst_req, slv_rsp, clk);


    addr_word       := std_ulogic_vector(to_unsigned(addr_offset_HIBI_DMA_MEM_ADDR0_integer_c + offset, addr_word'length));
    wishbone_write(hibi_remote_dma_cfg_buffer_c, mem_addr, mst_req, slv_rsp, clk);
    hibi_send_prio_b(hibi_remote_addr or std_logic_vector(resize(unsigned(addr_word), hibi_remote_addr'length)), hibi_remote_dma_cfg_buffer_c, 1, mst_req, slv_rsp, clk);


    addr_word       := std_ulogic_vector(to_unsigned(addr_offset_HIBI_DMA_HIBI_ADDR0_integer_c + offset, addr_word'length));
    wishbone_write(hibi_remote_dma_cfg_buffer_c, hibi_dest_addr, mst_req, slv_rsp, clk);
    hibi_send_prio_b(hibi_remote_addr or std_logic_vector(resize(unsigned(addr_word), hibi_remote_addr'length)), hibi_remote_dma_cfg_buffer_c, 1, mst_req, slv_rsp, clk);

  end procedure hibi_remote_dma_tx_setup;

  -----------------------------------------------------------------------------
  -- HIBI bridge remote DMA start
  -----------------------------------------------------------------------------
  procedure hibi_remote_dma_start(constant hibi_remote_addr : in std_ulogic_vector; constant channel_mask : in std_ulogic_vector; 
                                  signal mst_req : out wb_req_t; signal slv_rsp : in wb_rsp_t; signal clk : in std_ulogic) is
  begin

    wishbone_write(hibi_remote_dma_cfg_buffer_c, channel_mask, mst_req, slv_rsp, clk);
    hibi_send_prio_b(hibi_remote_addr or std_logic_vector(resize(addr_offset_HIBI_DMA_TRIGGER_unsigned_c, hibi_remote_addr'length)), hibi_remote_dma_cfg_buffer_c, 1, mst_req, slv_rsp, clk);

  end procedure hibi_remote_dma_start;


  constant host_rom_size_c         : integer   := 15;
  constant host_rom_data_width_c   : integer   := 32;

  constant nr_cols_c               : integer   := 40;
  constant nr_rows_c               : integer   := 30;
  
  constant lblank_c                : time      := 1 us;
  constant fblank_c                : time      := 100 us;
  
  constant clk_cycle_c             : time      := 10 ns;
  constant pif_clk_cycle_c         : time      := 15 ns;  

  signal sim_done                  : boolean   := false;
  
  signal clk                       : std_logic := '0';
  signal reset                     : std_logic := '0';

  signal host_req                  : wb_req_t := dflt_wb_req_c;
  signal host_rsp                  : wb_rsp_t;
  
  signal rxpif                     : hibi_pif_arr_t(0 to 1) := (others => dflt_hibi_pif_c);

  constant host_rom_file_name_c    : string  := "./rom/rom.mem";
  constant host_rom_entries_c      : integer := (2**(host_rom_size_c-2));

  type ram_type is array (host_rom_entries_c-1 downto 0) of std_ulogic_vector (host_rom_data_width_c-1 downto 0);

  constant bridge_buffer_entries_c : integer := (2**(hibi_wishbone_bridge_mem_addr_width_c-2));


  -------------------------------------------------------------------------------
  -- mem_init
  -------------------------------------------------------------------------------
  procedure mem_init(variable RAM : inout ram_type; constant file_name : in string; variable size : out integer)  is
    file     readfile       : text open read_mode is file_name;
    variable vecline        : line;

    variable add_ulv        : std_ulogic_vector(host_rom_size_c-2-1 downto 0);
    variable var_ulv        : std_ulogic_vector(host_rom_data_width_c-1 downto 0);

    variable add_int        : natural   := 0;
    variable addr_indicator : character := ' ';
  begin
    if(file_name /= "none") then
      readline(readfile, vecline);

      read(vecline, addr_indicator);
      assert addr_indicator = '@' report "Incorrect address indicator: expecting @address" severity failure;

      hread(vecline, add_ulv);

      add_int := to_integer(unsigned(add_ulv));
      size    := add_int;
        	      
      while not endfile(readfile) loop
        -----------------------------------------------------------------------
        -- read data
        -----------------------------------------------------------------------
        readline(readfile, vecline);
        hread(vecline, var_ulv);

        if(add_int > host_rom_entries_c-1) then
          assert false report "Address out of range while filling memory" severity failure;
        else
          RAM(add_int) := var_ulv;
          add_int      := add_int + 1;
        end if;
      end loop;

      size := add_int - size;

      assert false report "Memory filling successfull" severity note;
    end if;
  end procedure mem_init;


begin
  ------------------------------------------------------------------------------
  -- clock and reset
  ------------------------------------------------------------------------------
  clk           <= not clk after clk_cycle_c/2 when sim_done = false;
  rxpif(0).pclk <= not rxpif(0).pclk after pif_clk_cycle_c/2 when sim_done = false;
  reset         <= '1' after 500 ns;

  ------------------------------------------------------------------------------
  -- MPSoC
  ------------------------------------------------------------------------------
  duti0: entity microsimd.msmp
    generic map (
      nr_cpus_g  => 1
    )
    port map (
      clk_i      => clk,
      reset_n_i  => reset,
      host_req_i => host_req,
      host_rsp_o => host_rsp,   
      pif_i      => rxpif,
      pif_o      => open
    );

  ------------------------------------------------------------------------------
  -- stimuli
  ------------------------------------------------------------------------------
  stim0: process is
    -- TODO: check addr width wich is 16 bit only including HIBI address identiefier
    -- this might limit us to access the full target address range
    variable target                 : hibi_targets_t;
    variable target_hibi_addr       : std_ulogic_vector(hibi_addr_width_c-1 downto 0);
    variable target_boot_addr       : unsigned(16 downto 0) := (others => '0');

    variable pix_count              : integer := 0;
    variable ROM                    : ram_type;
    variable rom_size               : natural;
    variable boot_loop_iterations   : natural;
    variable boot_loop_remains      : natural;
    variable local_boot_addr        : unsigned(dflt_wb_req_c.dat'length-1 downto 0);
    variable local_boot_addr_offset : unsigned(dflt_wb_req_c.dat'length-1 downto 0) := (2 downto 0 => "100", others => '0');

  begin
    mem_init(ROM, host_rom_file_name_c, rom_size);

    wait until reset = '1';
    wait until rising_edge(clk);
    
    wait for 2 us;

    -- enable logic but not the cores (HIBI transfer enabled IP functionality still disabled -> ready for boot)
    wishbone_write(addr_offset_HIBI_DMA_GPIO_slv_c sll 2, x"00F0", host_req, host_rsp, clk);
    
    wait for 2 us;

    target           := CPU0;
    target_hibi_addr := std_ulogic_vector(to_unsigned(hibi_addresses_c(hibi_targets_t'pos(target)), hibi_addr_width_c));

    hibi_local_dma_enable(host_req, host_rsp, clk);
    hibi_remote_dma_enable(target_hibi_addr, host_req, host_rsp, clk);

    wait for 2 us;

    -- overide the hart_id to 0xFFFF, just to check if it works
    wishbone_write(hibi_remote_dma_cfg_buffer_c, x"FFFFFFFF", host_req, host_rsp, clk);
    hibi_send_prio_b(target_hibi_addr or std_logic_vector(resize(microsimd.hibi_dma_regfile_pkg.addr_offset_HIBI_DMA_GPIO_unsigned_c,     target_hibi_addr'length)), hibi_remote_dma_cfg_buffer_c, 1, host_req, host_rsp, clk);
    hibi_send_prio_b(target_hibi_addr or std_logic_vector(resize(microsimd.hibi_dma_regfile_pkg.addr_offset_HIBI_DMA_GPIO_DIR_unsigned_c, target_hibi_addr'length)), hibi_remote_dma_cfg_buffer_c, 1, host_req, host_rsp, clk);


    wait for 2 us;

    boot_loop_iterations := rom_size / (bridge_buffer_entries_c - to_integer(local_boot_addr_offset));
    boot_loop_remains    := rom_size rem (bridge_buffer_entries_c - to_integer(local_boot_addr_offset));
    local_boot_addr      := (local_boot_addr'left => '1', others => '0');
    local_boot_addr      := local_boot_addr + local_boot_addr_offset;

    if boot_loop_iterations > 0 then
      boot0: for i in 0 to boot_loop_iterations-1 loop
        for j in 0 to bridge_buffer_entries_c-1 loop
          wishbone_write(std_logic_vector(local_boot_addr), ROM(i), host_req, host_rsp, clk);
          local_boot_addr  := local_boot_addr + 4;
        end loop;
      
        hibi_remote_dma_rx_setup(target_hibi_addr, 0, std_logic_vector(target_boot_addr), bridge_buffer_entries_c, host_req, host_rsp, clk);
        hibi_remote_dma_start(target_hibi_addr, x"0001", host_req, host_rsp, clk);
        hibi_local_dma_send(0, target_hibi_addr, std_logic_vector(local_boot_addr_offset), bridge_buffer_entries_c, host_req, host_rsp, clk);

	target_boot_addr   := target_boot_addr + 4*bridge_buffer_entries_c;
	local_boot_addr    := (local_boot_addr'left => '1', others => '0');
        local_boot_addr    := local_boot_addr + local_boot_addr_offset;
      end loop boot0;
    end if;

    wait for 2 us;

    if boot_loop_remains > 0 then
      boot1: for i in 0 to boot_loop_remains-1 loop
        wishbone_write(std_logic_vector(local_boot_addr), ROM(i), host_req, host_rsp, clk);
        local_boot_addr  := local_boot_addr + 4;
      end loop boot1;

      hibi_remote_dma_rx_setup(target_hibi_addr, 0, std_logic_vector(target_boot_addr), boot_loop_remains, host_req, host_rsp, clk);
      hibi_remote_dma_start(target_hibi_addr, x"0001", host_req, host_rsp, clk);
      hibi_local_dma_send(0, target_hibi_addr, std_logic_vector(local_boot_addr_offset), boot_loop_remains, host_req, host_rsp, clk);
    end if;

    wait for 2 us;


    -- enable cores also... ready to rock
    wishbone_write(addr_offset_HIBI_DMA_GPIO_slv_c sll 2, x"00FF", host_req, host_rsp, clk);

    wait for 100 us; 





    --row_loop: for i in 0 to nr_rows_c-1 loop
    --  col_loop: for j in 0 to nr_cols_c-1 loop
    --    wait until falling_edge(rxpif(0).pclk);
    --    rxpif(0).vsync <= '1';
    --    rxpif(0).hsync <= '1';
    --    rxpif(0).data  <= std_ulogic_vector(unsigned(rxpif(0).data) + 1);
    --  end loop col_loop;
      
    --  wait until falling_edge(rxpif(0).pclk);
    --  rxpif(0).hsync   <= '0';
    --  wait for lblank_c;
    --end loop row_loop;
    
    --rxpif(0).vsync     <= '0';
    --wait for fblank_c;

    -- quit simulation
    wait for 10 us;
    sim_done <= true;
    assert false report "Simulation finished successfully!" severity failure;
    wait;
  end process stim0;

end architecture beh;

