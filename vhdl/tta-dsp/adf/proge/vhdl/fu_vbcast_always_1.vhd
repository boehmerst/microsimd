library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fu_vbcast_always_1 is
  generic (
    dataw_g     : integer := 32;
    elemcount_g : integer := 4
  );
  port (
    t1data   : in std_logic_vector(dataw_g-1 downto 0);
    t1load   : in std_logic;
  
    r1data   : out std_logic_vector(elemcount_g*dataw_g-1 downto 0);
    glock    : in  std_logic;
    rstx     : in  std_logic;
    clk      : in  std_logic
  );
end entity fu_vbcast_always_1;

architecture rtl of fu_vbcast_always_1 is

type reg_t is record
  r1data : std_logic_vector(elemcount_g*dataw_g-1 downto 0);
end record reg_t;
constant dflt_reg_c : reg_t :=(
  r1data => (others=>'0')
);

signal clk_en : std_logic;
signal r, rin : reg_t;

begin

  comb0: process(r, t1data, t1load) 
    variable v : reg_t;
  begin
    v := r;

    for i in 0 to elemcount_g loop
      v.r1data((i+1)*dataw_g-1 downto i*dataw_g) := t1data;
    end loop;
    
    r1data <= r.r1data;

    rin    <= v;
  end process comb0;

  clk_en <= (not glock) and t1load;

  sync0: process(clk, rstx) 
  begin
    if rstx = '0' then
      r <= dflt_reg_c;
    elsif rising_edge(clk) then
      if clk_en = '1' then
        r <= rin;
      end if;
    end if;
  end process sync0;

end architecture rtl;

