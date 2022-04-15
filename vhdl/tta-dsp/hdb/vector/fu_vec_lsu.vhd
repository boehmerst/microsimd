----------------------------------------------------------------------------------------
-- TODO: the internal and external memory interface is kind of quick and dirty
--       we might want to consider to use a decoubled IO protocoll: valid + ready = fire 
----------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.func_pkg.all;

entity fu_vec_lsu is
  generic (
    addrw_g     : integer := 11;
    dataw_g     : integer := 32;
    elemcount_g : integer := 4;
    latency_g   : integer := 3+4-1
  );
  port(
    clk_i       : in  std_logic;
    reset_n_i   : in  std_logic;
    glock_i     : in  std_logic;
    glock_req_o : out std_logic;

    t1load_i    : in  std_logic;
    t1data_i    : in  std_logic_vector(addrw_g-1 downto 0);
    t1opcode_i  : in  std_logic_vector(0 downto 0);
    o1load_i    : in  std_logic;
    o1data_i    : in  std_logic_vector(elemcount_g*dataw_g-1 downto 0);
    r1data_o    : out std_logic_vector(elemcount_g*dataw_g-1 downto 0);

    mem_addr_o  : out std_logic_vector(addrw_g-3 downto 0);
    mem_en_o    : out std_logic_vector(0 downto 0);
    mem_wr_o    : out std_logic_vector(0 downto 0);
    mem_sel_o   : out std_logic_vector(dataw_g/8-1 downto 0);
    mem_wdata_o : out std_logic_vector(dataw_g-1 downto 0);
    mem_rdata_i : in  std_logic_vector(dataw_g-1 downto 0);
    mem_ready_i : in  std_logic_vector(0 downto 0)
   );
end entity fu_vec_lsu;

architecture rtl of fu_vec_lsu is

  constant OPC_VEC_LD  : integer := 0;
  constant OPC_VEC_ST  : integer := 1;

  type transfer_cmd_t  is (load, store, idle);

  type mem_req_t is record
    addr  : std_logic_vector(addrw_g-3 downto 0);
    wr    : std_logic;
    start : std_logic;
    wdata : std_logic_vector(elemcount_g*dataw_g-1 downto 0);
  end record mem_req_t;
  constant dflt_mem_req_c : mem_req_t :=(
    addr  => (others =>'0'),
    wr    => '0',
    start => '0',
    wdata => (others => '0')
  );

  type mem_rsp_t is record
    rdata : std_logic_vector(elemcount_g*dataw_g-1 downto 0);
    ack   : std_logic;
  end record mem_rsp_t;
  constant dflt_mem_rsp_c : mem_rsp_t :=(
    rdata => (others => '0'),
    ack   => '0'
  );

  signal issueb0_mem_req : mem_req_t;
  signal execb0_mem_rsp  : mem_rsp_t;

begin
  ------------------------------------------------------------------------------------------------
  -- decode and issue the memory access to the execution stage
  ------------------------------------------------------------------------------------------------
  issueb0: block is
    port (
      clk_i       : in  std_logic;
      reset_n_i   : in  std_logic;
      glock_i     : in  std_logic;

      t1load_i    : in  std_logic;
      t1data_i    : in  std_logic_vector(addrw_g-1 downto 0);
      t1opcode_i  : in  std_logic_vector(0 downto 0);
      o1load_i    : in  std_logic;
      o1data_i    : in  std_logic_vector(dataw_g-1 downto 0);
      r1data_o    : out std_logic_vector(dataw_g-1 downto 0);
      glock_req_o : out std_logic;

      mem_req_o  : out mem_req_t;
      mem_rsp_i  : in  mem_rsp_t
    );
    port map (
      clk_i => clk_i,
      reset_n_i   => reset_n_i,
      glock_i     => glock_i,
      glock_req_o => glock_req_o,

      t1load_i    => t1load_i,
      t1data_i    => t1data_i,
      t1opcode_i  => t1opcode_i,
      o1load_i    => o1load_i,
      o1data_i    => o1data_i,
      r1data_o    => r1data_o,

      mem_req_o   => issueb0_mem_req,
      mem_rsp_i   => execb0_mem_rsp
    );

    type pipe_t is record
      cmd  : transfer_cmd_t;
    end record pipe_t;
    constant dflt_pipe_c : pipe_t := (
      cmd  => IDLE
    );

    type pipe_arr_t is array (natural range<>) of pipe_t;

    type reg_t is record
      transfer : pipe_arr_t(latency_g-1 downto 0);
      mem_req  : mem_req_t;
      lock_req : std_logic;
    end record reg_t;
    constant dflt_reg_c : reg_t := (
      transfer => (others => dflt_pipe_c),
      mem_req  => dflt_mem_req_c,
      lock_req => '0'
    );

    signal stall    : std_logic;
    signal lock_req : std_logic;
    signal r, rin   : reg_t;

  begin
    --------------------------------------------------------------------------------------------------
    -- comb0
    --------------------------------------------------------------------------------------------------
    comb0: process(r, t1load_i, t1data_i, t1opcode_i, o1load_i, o1data_i, mem_rsp_i) is
      variable v        : reg_t;
      variable transfer : pipe_t;
    begin
      v          := r;
      transfer   := dflt_pipe_c;

      ------------------------------------------------------------------------------------------------
      -- latch data as it might have been loaded before the request being triggered
      ------------------------------------------------------------------------------------------------
      if o1load_i = '1' then
        v.mem_req.wdata := o1data_i;
      end if;

      v.transfer := r.transfer(r.transfer'left-1 downto 0) & dflt_pipe_c;

      if to_integer(unsigned(t1opcode_i)) = transfer_cmd_t'pos(load) then
        transfer.cmd := load;
      elsif to_integer(unsigned(t1opcode_i)) = transfer_cmd_t'pos(store) then
        transfer.cmd := store;
      end if;

      if mem_rsp_i.ack = '1' then
        v.mem_req.start := '0';
      end if;

      if t1load_i = '1' then
        v.transfer(0)   := transfer;
        v.mem_req.addr  := t1data_i(t1data_i'left downto 2);
        v.mem_req.wr    := '0';
        v.mem_req.start := '1';

        if transfer.cmd = store then
          v.mem_req.wr  := '1';
        end if;
      end if;

      --------------------------------------------------------------------------------------------
      -- drive block output
      --------------------------------------------------------------------------------------------   
      lock_req   <= '0';
      if mem_rsp_i.ack = '0' and r.transfer(r.transfer'left).cmd /= idle then
        lock_req <= '1';
      end if;

      r1data_o   <= mem_rsp_i.rdata;
      mem_req_o  <= r.mem_req;

      rin        <= v;

    end process comb0;


    ----------------------------------------------------------------------------------------------
    -- sync0
    ----------------------------------------------------------------------------------------------
    stall       <= glock_i or lock_req;
    glock_req_o <= lock_req;

    sync0: process(reset_n_i, clk_i) is
    begin
      if(reset_n_i = '0') then
        r <= dflt_reg_c;
      elsif(rising_edge(clk_i)) then
        if(stall = '0') then
          r <= rin;
        end if;
      end if; 
    end process sync0;  

  end block issueb0;


  ------------------------------------------------------------------------------------------------
  -- execute the memory access and manage the interface to the memory bus
  ------------------------------------------------------------------------------------------------
  execb0: block is
    port (
      clk_i      : in  std_logic;
      reset_n_i  : in  std_logic;
      glock_i    : in  std_logic;
      t1load_i   : in  std_logic;

      mem_req_i  : in  mem_req_t;
      mem_rsp_o  : out mem_rsp_t;

      mem_addr_o  : out std_logic_vector(addrw_g-3 downto 0);
      mem_en_o    : out std_logic;
      mem_wr_o    : out std_logic;
      mem_sel_o   : out std_logic_vector(dataw_g/8-1 downto 0);
      mem_wdata_o : out std_logic_vector(dataw_g-1 downto 0);
      mem_rdata_i : in  std_logic_vector(dataw_g-1 downto 0);
      mem_ready_i : in  std_logic
    );
    port map (
      clk_i       => clk_i,
      reset_n_i   => reset_n_i,
      glock_i     => glock_i,
      t1load_i    => t1load_i,

      mem_req_i   => issueb0_mem_req,
      mem_rsp_o   => execb0_mem_rsp,

      mem_addr_o  => mem_addr_o,
      mem_en_o    => mem_en_o(0),
      mem_wr_o    => mem_wr_o(0),
      mem_sel_o   => mem_sel_o,
      mem_wdata_o => mem_wdata_o,
      mem_rdata_i => mem_rdata_i,
      mem_ready_i => mem_ready_i(0)
    );

    type state_t is (idle, transfer);

    type reg_t is record
      state     : state_t;
      mem_rsp   : mem_rsp_t;
      count     : unsigned(log2ceil(elemcount_g)-1 downto 0);
      mem_en    : std_logic;
      mem_addr  : unsigned(addrw_g-1 downto 0);
      mem_wr    : std_logic;
      mem_wdata : std_logic_vector(dataw_g-1 downto 0);
    end record reg_t;
    constant dflt_reg_c : reg_t := (
      state     => idle,
      mem_rsp   => dflt_mem_rsp_c,
      count     => (others=>'0'),
      mem_en    => '0',
      mem_addr  => (others=>'0'),
      mem_wr    => '0',
      mem_wdata => (others=>'0')
    );

    signal r, rin : reg_t;

  begin

    --------------------------------------------------------------------------
    -- comb0
    --------------------------------------------------------------------------
    comb0: process(r, glock_i, t1load_i, mem_req_i, mem_rdata_i) is
      variable start : std_logic;
      variable v     : reg_t;
    begin
      v := r;

      case(r.state) is
        when idle     => if mem_req_i.start = '1' then
                           v.state       := transfer;
                           v.count       := (others=>'0');
                           v.mem_en      := '1';
                           v.mem_wr      := mem_req_i.wr;
                           v.mem_rsp.ack := '0';
                         end if;

        when transfer => v.count         := r.count + 1;
                         v.mem_rsp.ack   := '0';

                         if v.count = elemcount_g-1 then
                           v.state       := idle;
                           v.mem_rsp.ack := '1';
                           v.mem_en      := '0';

                           if mem_req_i.start = '1' then
                             v.state     := transfer;
                             v.count     := (others=>'0');
                             v.mem_en    := '1';
                             v.mem_wr    := mem_req_i.wr;
                           end if;
                         end if;
                         
        when others   => null;
      end case;

      v.mem_addr  := unsigned(mem_req_i.addr) + v.count;
      v.mem_wdata := mem_req_i.wdata(to_integer(v.count)*dataw_g-1 downto to_integer(v.count)*dataw_g);

      if r.mem_en = '1' and r.mem_wr = '0' then
        v.mem_rsp.rdata(to_integer(v.count)*dataw_g-1 downto to_integer(v.count)*dataw_g) := mem_rdata_i;
      end if;

      -----------------------------------------------------------------------
      -- drive module output
      -----------------------------------------------------------------------
      mem_addr_o  <= std_logic_vector(r.mem_addr);
      mem_en_o    <= r.mem_en;
      mem_wr_o    <= r.mem_wr;
      mem_wdata_o <= r.mem_wdata;
      mem_sel_o   <= (others=>'1');

      mem_rsp_o   <= r.mem_rsp;

      rin <= v;

    end process comb0;


    --------------------------------------------------------------------------
    -- sync0
    --------------------------------------------------------------------------
    sync0: process(reset_n_i, clk_i) is
    begin
      if(reset_n_i = '0') then
        r <= dflt_reg_c;
      elsif(rising_edge(clk_i)) then
        if(mem_ready_i = '1') then
          r <= rin;
        end if;
      end if; 
    end process sync0;  


  end block execb0;

end architecture rtl;

