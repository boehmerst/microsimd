library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library general;
use general.general_function_pkg.all;

library microsimd;
use microsimd.hibi_pif_types_pkg.all;
use microsimd.hibi_pif_dma_pkg.all;

entity hibi_pif_fifo_if is
  generic (
    nr_txstreams_g : positive := 1;
    nr_rxstreams_g : positive := 1
  );
  port (
    clk_i        : in  std_ulogic;
    reset_n_i    : in  std_ulogic;
    en_i         : in  std_ulogic;
    init_i       : in  std_ulogic;
    mem_req_i    : in  hibi_pif_dma_mem_req_t;
    mem_rsp_o    : out hibi_pif_dma_mem_rsp_t;
    mem_wait_o   : out std_ulogic;
    txfifo_req_o : out hibi_pif_txfifo_req_arr_t(0 to nr_txstreams_g-1);
    txfifo_rsp_i : in  hibi_pif_txfifo_rsp_arr_t(0 to nr_txstreams_g-1);
    rxfifo_req_o : out hibi_pif_rxfifo_req_arr_t(0 to nr_rxstreams_g-1);
    rxfifo_rsp_i : in  hibi_pif_rxfifo_rsp_arr_t(0 to nr_rxstreams_g-1)
  );
end entity hibi_pif_fifo_if;

architecture rtl of hibi_pif_fifo_if is

  function decode_fifo(addr : in std_ulogic_vector) return unsigned is
    variable fifo_sel : unsigned(log2ceil(max(nr_txstreams_g, nr_rxstreams_g))-1 downto 0);
  begin
    fifo_sel := unsigned(addr(log2ceil(max(nr_txstreams_g, nr_rxstreams_g))+2-1 downto 2));
    return fifo_sel;
  end function decode_fifo;
  
  type reg_t is record
    mem_wait : std_ulogic;
    fifo_sel : unsigned(log2ceil(max(nr_txstreams_g, nr_rxstreams_g))-1 downto 0);
    dma_rd   : std_ulogic;
    dma_wr   : std_ulogic;
    addr     : std_ulogic_vector(hibi_pif_dma_mem_addr_width_c-1 downto 0);
    data     : std_ulogic_vector(hibi_pif_dma_mem_data_width_c-1 downto 0);
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    mem_wait => '0',
    fifo_sel => (others=>'0'),
    dma_rd   => '0',
    dma_wr   => '0',
    addr     => (others=>'0'),
    data     => (others=>'0')
  );
  
  signal r, rin : reg_t;
    
begin
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, mem_req_i, txfifo_rsp_i, rxfifo_rsp_i) is
    variable v            : reg_t;
    variable empty        : std_ulogic;
    variable almost_empty : std_ulogic;
    variable full         : std_ulogic;
    variable almost_full  : std_ulogic;
    variable fifo_rd      : std_ulogic_vector(nr_rxstreams_g-1 downto 0);
    variable fifo_wr      : std_ulogic_vector(nr_txstreams_g-1 downto 0);   
  begin
    v := r;
    
    ----------------------------------------------------------------------------
    -- decode actual FIFO to be considered
    ----------------------------------------------------------------------------
    if(r.mem_wait = '0') then
      v.dma_rd   := mem_req_i.ena and not mem_req_i.we;
      v.dma_wr   := mem_req_i.ena and     mem_req_i.we;
      v.data     := mem_req_i.dat;
      v.addr     := mem_req_i.adr;
    end if;
    
    v.fifo_sel := decode_fifo(v.addr);
    
    empty        := rxfifo_rsp_i(to_integer(v.fifo_sel(log2ceil(nr_rxstreams_g)-1 downto 0))).empty;
    almost_empty := rxfifo_rsp_i(to_integer(v.fifo_sel(log2ceil(nr_rxstreams_g)-1 downto 0))).almost_empty;    
    full         := txfifo_rsp_i(to_integer(v.fifo_sel(log2ceil(nr_txstreams_g)-1 downto 0))).full;
    almost_full  := txfifo_rsp_i(to_integer(v.fifo_sel(log2ceil(nr_txstreams_g)-1 downto 0))).almost_full;
    
    ----------------------------------------------------------------------------
    -- mem_wait logig to stall DMA
    ----------------------------------------------------------------------------
    if(r.mem_wait = '0') then
      if(v.dma_rd = '1' and empty = '1') then
        v.mem_wait := '1';
      elsif(v.dma_wr = '1' and full = '1') then
        v.mem_wait := '1';
      end if;
    else
      if(r.dma_rd = '1' and empty = '0') then
        v.mem_wait := '0';
      elsif(r.dma_wr = '1' and full = '0') then
        v.mem_wait := '0';
      end if;
    end if;

    ----------------------------------------------------------------------------
    -- FIFO control signal
    ----------------------------------------------------------------------------
    fifo_rd := (others=>'0');
    fifo_rd(to_integer(v.fifo_sel(log2ceil(nr_rxstreams_g)-1 downto 0))) := v.dma_rd and not empty;
    
    fifo_wr := (others=>'0');
    fifo_wr(to_integer(v.fifo_sel(log2ceil(nr_txstreams_g)-1 downto 0))) := v.dma_wr and not full;
    
    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    dat: for i in 0 to nr_txstreams_g-1 loop
      txfifo_req_o(i).data <= v.data;
      rxfifo_req_o(i).rd   <= fifo_rd(i);
      txfifo_req_o(i).wr   <= fifo_wr(i);      
    end loop dat;
    
    mem_rsp_o.dat   <= rxfifo_rsp_i(to_integer(r.fifo_sel(log2ceil(nr_rxstreams_g)-1 downto 0))).data;
    mem_wait_o      <= r.mem_wait;
          
    rin <= v;
  end process comb0;
  
  ------------------------------------------------------------------------------
  -- sync0
  ------------------------------------------------------------------------------
  sync0: process(reset_n_i, clk_i) is
  begin
    if(reset_n_i = '0') then
      r <= dflt_reg_c;
    elsif(rising_edge(clk_i)) then
      if(en_i = '1') then
        if(init_i = '1') then
          r <= dflt_reg_c;
        else
          r <= rin;
        end if;
      end if;
    end if;
  end process sync0;

end architecture rtl;

