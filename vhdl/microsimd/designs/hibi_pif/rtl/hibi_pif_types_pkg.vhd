library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library general;
use general.general_function_pkg.all;

library microsimd;
use microsimd.hibi_pif_dma_pkg.all;

package hibi_pif_types_pkg is

  constant pif_data_width_c  : integer := 16;
  constant pif_hsize_c       : integer := 512;
  constant pif_vsize_c       : integer := 512;

  type hibi_pif_cfg_t is record
    hsize : std_ulogic_vector(log2ceil(pif_hsize_c)-1 downto 0);
    vsize : std_ulogic_vector(log2ceil(pif_vsize_c)-1 downto 0);
  end record hibi_pif_cfg_t;
  constant dflt_hibi_pif_cfg_c : hibi_pif_cfg_t :=(
    hsize => (others=>'0'),
    vsize => (others=>'0')
  );
  
  type hibi_pif_cfg_arr_t is array(natural range <>) of hibi_pif_cfg_t;
  
  type hibi_pif_ctrl_t is record
    fe : std_ulogic;
    le : std_ulogic;
  end record hibi_pif_ctrl_t;
  constant dflt_hibi_pif_ctrl_c : hibi_pif_ctrl_t :=(
    fe => '0',
    le => '0'
  );

  type hibi_pif_ctrl_arr_t is array(natural range <>) of hibi_pif_ctrl_t;
  
  type hibi_pif_status_t is record
    hsync : std_ulogic;
    vsync : std_ulogic;
    busy  : std_ulogic;
  end record hibi_pif_status_t;
  constant dflt_hibi_pif_status_c : hibi_pif_status_t :=(
    hsync => '0',
    vsync => '0',
    busy  => '0'
  );
  
  type hibi_pif_status_arr_t is array(natural range <>) of hibi_pif_status_t;

  type hibi_pif_t is record
    pclk  : std_ulogic;
    hsync : std_ulogic;
    vsync : std_ulogic;
    data  : std_ulogic_vector(pif_data_width_c-1 downto 0);
  end record hibi_pif_t;
  constant dflt_hibi_pif_c : hibi_pif_t :=(
    pclk  => '0',
    hsync => '0',
    vsync => '0',
    data  => (others=>'0')
  );
  
  type hibi_pif_arr_t is array(natural range <>) of hibi_pif_t;
  
  type hibi_pif_txfifo_req_t is record
    wr   : std_ulogic;
    data : std_ulogic_vector(hibi_pif_dma_mem_data_width_c-1 downto 0);
  end record hibi_pif_txfifo_req_t;
  constant dflt_hibi_pif_txfifo_req_c : hibi_pif_txfifo_req_t :=(
    wr   => '0',
    data => (others=>'0')
  );
  
  type hibi_pif_rxfifo_req_t is record
    rd   : std_ulogic;
  end record hibi_pif_rxfifo_req_t;
  constant dflt_hibi_pif_rxfifo_req_c : hibi_pif_rxfifo_req_t :=(
    rd   => '0'
  );
  
  type hibi_pif_txfifo_req_arr_t is array(natural range <>) of hibi_pif_txfifo_req_t;
  type hibi_pif_rxfifo_req_arr_t is array(natural range <>) of hibi_pif_rxfifo_req_t;  

  type hibi_pif_txfifo_rsp_t is record
    full        : std_ulogic;
    almost_full : std_ulogic;
  end record hibi_pif_txfifo_rsp_t;
  constant dflt_hibi_pif_txfifo_rsp_c : hibi_pif_txfifo_rsp_t :=(
    full        => '0',
    almost_full => '0'
  );
  
  type hibi_pif_rxfifo_rsp_t is record
    empty        : std_ulogic;
    almost_empty : std_ulogic;
    data         : std_ulogic_vector(hibi_pif_dma_mem_data_width_c-1 downto 0);
  end record hibi_pif_rxfifo_rsp_t;
  constant dflt_hibi_pif_rxfifo_rsp_c : hibi_pif_rxfifo_rsp_t :=(
    empty        => '0',
    almost_empty => '0',
    data         => (others=>'0')
  );  
  
  type hibi_pif_txfifo_rsp_arr_t is array(natural range <>) of hibi_pif_txfifo_rsp_t;
  type hibi_pif_rxfifo_rsp_arr_t is array(natural range <>) of hibi_pif_rxfifo_rsp_t;  
    
end package hibi_pif_types_pkg;

