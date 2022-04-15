library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.func_pkg.all;

entity fu_lsu_always_3 is
  generic (
    dataw_g   : integer := 32;
    addrw_g   : integer := 11;
    latency_g : integer := 3
  );
  port(
    clk_i       : in  std_logic;
    reset_n_i   : in  std_logic;
    glock_i     : in  std_logic;
    glock_req_o : out std_logic;

    t1load_i    : in  std_logic;
    t1data_i    : in  std_logic_vector(addrw_g-1 downto 0);
    t1opcode_i  : in  std_logic_vector(2 downto 0);
    o1load_i    : in  std_logic;
    o1data_i    : in  std_logic_vector(dataw_g-1 downto 0);
    r1data_o    : out std_logic_vector(dataw_g-1 downto 0);

    mem_addr_o  : out std_logic_vector(addrw_g-3 downto 0);
    mem_en_o    : out std_logic_vector(0 downto 0);
    mem_wr_o    : out std_logic_vector(0 downto 0);
    mem_sel_o   : out std_logic_vector(dataw_g/8-1 downto 0);
    mem_wdata_o : out std_logic_vector(dataw_g-1 downto 0);
    mem_rdata_i : in  std_logic_vector(dataw_g-1 downto 0);
    mem_ready_i : in  std_logic_vector(0 downto 0)
   );
end entity fu_lsu_always_3;

architecture rtl of fu_lsu_always_3 is

  -- TODO: use enum and 'pos syntax for opcode decoding
  constant OPC_LD16  : integer := 0;
  constant OPC_LD32  : integer := 1;
  constant OPC_LD8   : integer := 2;
  constant OPC_LDU16 : integer := 3;
  constant OPC_LDU8  : integer := 4;
  constant OPC_ST16  : integer := 5;
  constant OPC_ST32  : integer := 6;
  constant OPC_ST8   : integer := 7;

  type transfer_size_t is (WORD, HALFWORD, BYTE);
  type transfer_cmd_t  is (IDLE, LOAD, ULOAD, STORE);

  --------------------------------------------------------------------------------------------------
  -- This function repeats the operand to all positions in a memory store operation
  --------------------------------------------------------------------------------------------------
  function align_mem_store(data: std_logic_vector; size: transfer_size_t) return std_logic_vector is
    variable bdata : std_logic_vector(data'length-1 downto 0);
    variable hdata : std_logic_vector(data'length-1 downto 0);
    variable wdata : std_logic_vector(data'length-1 downto 0);
  begin
    for i in 0 to data'length/8-1 loop
      bdata( 8*(i+1)-1 downto  8*i) := data( 7 downto 0);
    end loop;

    for i in 0 to data'length/16-1 loop
      hdata(16*(i+1)-1 downto 16*i) := data(15 downto 0);
    end loop;

    wdata := data;

    case size is
      when byte     => return bdata;
      when halfword => return hdata;
      when others   => return wdata;
    end case;
  end function align_mem_store;

  --------------------------------------------------------------------------------------------------
  -- This function aligns the memory load operation (big endian decoding)
  --------------------------------------------------------------------------------------------------
  function align_mem_load(data: std_logic_vector; size: transfer_size_t; lsb: std_logic_vector(1 downto 0); sext: std_logic) return std_logic_vector is
    variable rdata : std_logic_vector(data'length-1 downto 0);
    variable sign  : std_logic;
  begin
    --TODO: make more generic
    --assert data'length = 32 report "currently only 32 bit supported" severity failure;

    case size is
      when byte => 
        case lsb is
          when "00"   => sign  := data(31) and sext;
                         rdata := sign_extend(data(31 downto 24), sign, rdata'length);
          when "01"   => sign  := data(23) and sext;
                         rdata := sign_extend(data(23 downto 16), sign, rdata'length);
          when "10"   => sign  := data(15) and sext;
                         rdata := sign_extend(data(15 downto  8), sign, rdata'length);
          when "11"   => sign  := data( 7) and sext;
                         rdata := sign_extend(data( 7 downto  0), sign, rdata'length);
          when others => null;
        end case;
      when halfword => 
        case lsb(1) is
          when '0'   =>  sign  := data(31) and sext;
                         rdata := sign_extend(data(31 downto 16), sign, rdata'length);
          when '1'   =>  sign  := data(15) and sext;
                         rdata := sign_extend(data(15 downto  0), sign, rdata'length);
          when others => null;
        end case;
      when word       => sign  := data(31) and sext;
                         rdata := sign_extend(data(31 downto  0), sign, rdata'length);
    end case;
    return rdata;
  end function align_mem_load;

  --------------------------------------------------------------------------------------------------
  -- This function selects the correct bytes for memory writes (big endian encoding)
  --------------------------------------------------------------------------------------------------
  function decode_mem_store(lsb: std_logic_vector(1 downto 0); size: transfer_size_t) return std_logic_vector is
  begin
    -- TODO: make more generic
    case size is
      when byte =>
        case lsb is
          when "00"   => return "1000";
          when "01"   => return "0100";
          when "10"   => return "0010";
          when "11"   => return "0001";
          when others => return "0000";
        end case;
      when halfword =>
        case lsb is
          when "10"   => return "0011";
          when "00"   => return "1100";
          when others => return "0000";
        end case;
      when others =>
        return "1111";
    end case;
  end function decode_mem_store;

  type mem_req_t is record
    addr  : std_logic_vector(addrw_g-3 downto 0);
    wr    : std_logic;
    wdata : std_logic_vector(dataw_g-1 downto 0);
    sel   : std_logic_vector(dataw_g/8-1 downto 0);
  end record mem_req_t;
  constant dflt_mem_req_c : mem_req_t :=(
    addr  => (others =>'0'),
    wr    => '0',
    wdata => (others => '0'),
    sel   => (others => '0')
  );

  type mem_rsp_t is record
    rdata : std_logic_vector(dataw_g-1 downto 0);
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
      t1opcode_i  : in  std_logic_vector(2 downto 0);
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
      size : transfer_size_t;
      lsb  : std_logic_vector(log2ceil(dataw_g/8)-1 downto 0);
      cmd  : transfer_cmd_t;
    end record pipe_t;
    constant dflt_pipe_c : pipe_t := (
      size => WORD,
      lsb  => (others => '0'),
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
      variable opcode   : natural range 0 to 7;
      variable transfer : pipe_t;
      variable sext     : std_logic;
    begin
      v        := r;
      transfer := dflt_pipe_c;
      opcode   := to_integer(unsigned(t1opcode_i));

      ------------------------------------------------------------------------------------------------
      -- latch data as it might have been loaded before the request being triggered
      ------------------------------------------------------------------------------------------------
      if o1load_i = '1' then
        v.mem_req.wdata := o1data_i;
      end if;

      ------------------------------------------------------------------------------------------------
      -- command decoding
      ------------------------------------------------------------------------------------------------
      transfer.lsb := t1data_i(transfer.lsb'range);

      case opcode is
        when OPC_LD8  | OPC_LDU8  | OPC_ST8  => transfer.size := BYTE;
        when OPC_LD16 | OPC_LDU16 | OPC_ST16 => transfer.size := HALFWORD;
        when others                          => transfer.size := WORD;
      end case;
     
      case opcode is
        when OPC_LDU8 | OPC_LDU16           => transfer.cmd := ULOAD;
        when OPC_LD8  | OPC_LD16 | OPC_LD32 => transfer.cmd := LOAD;
        when OPC_ST8  | OPC_ST16 | OPC_ST32 => transfer.cmd := STORE;
        when others                         => transfer.cmd := IDLE;
      end case;

      v.transfer        := r.transfer(r.transfer'left-1 downto 0) & dflt_pipe_c;

      if t1load_i = '1' then
        v.transfer(0)   := transfer;
        v.mem_req.addr  := t1data_i(t1data_i'left downto 2);
        v.mem_req.sel   := decode_mem_store(t1data_i(1 downto 0), transfer.size);
        v.mem_req.wr    := '0';
        v.mem_req.wdata := align_mem_store(v.mem_req.wdata, transfer.size);

        if transfer.cmd = STORE then
          v.mem_req.wr  := '1';
        end if;
      end if;

      --------------------------------------------------------------------------------------------
      -- drive block output
      --------------------------------------------------------------------------------------------   
      lock_req   <= '0';
      if mem_rsp_i.ack = '0' and r.transfer(r.transfer'left).cmd /= IDLE then
        lock_req <= '1';
      end if;

      sext   := '0';
      if r.transfer(r.transfer'left).cmd = LOAD then
        sext := '1';
      end if;

      r1data_o   <= align_mem_load(mem_rsp_i.rdata, r.transfer(r.transfer'left).size, r.transfer(r.transfer'left).lsb, sext);
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

    type reg_t is record
      en      : std_logic;
      en_del  : std_logic;
      rd_del  : std_logic;
      mem_rsp : mem_rsp_t;
    end record reg_t;
    constant dflt_reg_c : reg_t := (
      en      => '0',
      en_del  => '0',
      rd_del  => '0',
      mem_rsp => dflt_mem_rsp_c
    );

    signal r, rin : reg_t;

  begin
    --------------------------------------------------------------------------
    -- comb0
    --------------------------------------------------------------------------
    comb0: process(r, glock_i, t1load_i, mem_req_i, mem_rdata_i) is
      variable v : reg_t;
    begin
      v        := r;

      -- TODO: if memory issues !ready we miss the start condition
      --       not sure if this is a relevant corner case
      v.en     := not glock_i and t1load_i;
      v.en_del := r.en;
      v.rd_del := not mem_req_i.wr;

      if v.en = '1' then
        v.mem_rsp.ack := '0';
      end if;

      if r.en_del = '1' then
        v.mem_rsp.ack := '1';
      end if;

      if r.en_del = '1' and r.rd_del = '1' then
        v.mem_rsp.rdata := mem_rdata_i;
      end if;

      -----------------------------------------------------------------------
      -- drive module output
      -----------------------------------------------------------------------
      mem_addr_o  <= mem_req_i.addr;
      mem_en_o    <= r.en;
      mem_wr_o    <= mem_req_i.wr;
      mem_sel_o   <= mem_req_i.sel;
      mem_wdata_o <= mem_req_i.wdata;

      mem_rsp_o   <= r.mem_rsp; 
      rin         <= v;
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

