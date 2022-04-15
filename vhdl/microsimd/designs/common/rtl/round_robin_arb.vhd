library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity round_robin_arb is
  generic (
    cnt_g : integer := 2
  );
  port (
    clk_i        : in  std_ulogic;
    reset_n_i    : in  std_ulogic;
    en_i         : in  std_ulogic;
    init_i       : in  std_ulogic;
    req_i        : in  std_ulogic_vector(cnt_g-1 downto 0);
    ack_i        : in  std_ulogic;
    grant_comb_o : out std_ulogic_vector(cnt_g-1 downto 0);
    grant_o      : out std_ulogic_vector(cnt_g-1 downto 0)
  );
end entity round_robin_arb;

architecture rtl of round_robin_arb is

  type reg_t is record
    grant    : std_ulogic_vector(cnt_g-1 downto 0);
    prev_req : std_ulogic_vector(cnt_g-1 downto 0);
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    grant    => (others=>'0'),
    prev_req => (others=>'0')
  );
  
  signal r, rin : reg_t;
  
begin
  ------------------------------------------------------------------------------
  -- comb0
  ------------------------------------------------------------------------------
  comb0: process(r, req_i, ack_i) is
    variable v : reg_t;
    variable mask_prev : std_ulogic_vector(cnt_g-1 downto 0);
    variable sel_gnt   : std_ulogic_vector(cnt_g-1 downto 0);
    variable isol_lsb  : std_ulogic_vector(cnt_g-1 downto 0);
    variable win       : std_ulogic_vector(cnt_g-1 downto 0);
  begin
    v := r;
    
    ----------------------------------------------------------------------------
    -- mask off previos winner(s)
    ----------------------------------------------------------------------------
    mask_prev := req_i and not (std_ulogic_vector(unsigned(r.prev_req) - 1) or r.prev_req);
    
    ----------------------------------------------------------------------------
    -- find the highest priority using two'th complement method (lsb is highest)
    ----------------------------------------------------------------------------
    sel_gnt   := mask_prev and std_ulogic_vector(unsigned(not(mask_prev)) + 1);
    
    ----------------------------------------------------------------------------
    -- select the potential new winner in case all previous were completed
    ----------------------------------------------------------------------------
    isol_lsb  := req_i and std_ulogic_vector(unsigned(not(req_i)) + 1);
    
    ----------------------------------------------------------------------------
    -- mux between new turn and previous turn
    ----------------------------------------------------------------------------
    if(unsigned(mask_prev) /= 0) then
      win     := sel_gnt;
    else
      win     := isol_lsb;
    end if;
    
    ----------------------------------------------------------------------------
    -- grant the request
    ----------------------------------------------------------------------------
    if(unsigned(r.grant) = 0 or ack_i = '1') then
      if(unsigned(win) /= 0) then
        v.prev_req := win;
      end if;
      v.grant      := win;
    end if;
    
    ----------------------------------------------------------------------------
    -- drive module output
    ----------------------------------------------------------------------------
    grant_comb_o <= v.grant;
    grant_o      <= r.grant;
    
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

