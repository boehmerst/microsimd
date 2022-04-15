library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.core_pkg.all;
use work.config_pkg.all;
use work.vec_data_pkg.all;

entity shuffle is
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;
    init_i    : in  std_ulogic;
    en_i      : in  std_ulogic;
    start_i   : in  std_ulogic;
    veca_i    : in  vec_data_t;
    vecb_i    : in  vec_data_t;
    vn_i      : in  std_ulogic_vector(7 downto 0);
    ssss_i    : in  std_ulogic_vector(3 downto 0);
    vwidth_i  : in  std_ulogic_vector(1 downto 0);
    ready_o   : out std_ulogic;
    data_o    : out vec_data_t
  );
end entity shuffle;

architecture rtl of shuffle is  
  -----------------------------------------------------------------------------
  -- start of type and signal declarations
  -----------------------------------------------------------------------------
  constant unit_width_c: integer := CFG_SHUFFLE_WIDTH/4;
  
  type state_t is (idle, shuffle, done);

  type reg_t is record
    state     : state_t;
    count     : unsigned(1 downto 0);
    ready     : std_ulogic;
    shift_reg : std_ulogic_vector(CFG_SHUFFLE_WIDTH-1 downto 0);
  end record reg_t;
  constant dflt_reg_c : reg_t :=(
    state     => idle,
    count     => (others=>'0'),
    ready     => '1',
    shift_reg => (others=>'0')
  );
  
  signal r, rin : reg_t;
  
begin
  -----------------------------------------------------------------------------
  -- comb0
  -----------------------------------------------------------------------------
  comb0: process(r, start_i, veca_i, vecb_i, vn_i, ssss_i, vwidth_i) is
    variable v              : reg_t;
    variable input          : std_ulogic_vector(CFG_SHUFFLE_WIDTH-1 downto 0);
    variable perm           : std_ulogic_vector(CFG_SHUFFLE_WIDTH-1 downto 0);
    variable sel            : std_ulogic_vector(1 downto 0);
    variable perm00         : std_ulogic_vector(CFG_SHUFFLE_WIDTH-1 downto 0);
    variable perm01         : std_ulogic_vector(CFG_SHUFFLE_WIDTH-1 downto 0);
    variable perm10         : std_ulogic_vector(CFG_SHUFFLE_WIDTH-1 downto 0);
    variable perm_rev       : std_ulogic_vector(CFG_SHUFFLE_WIDTH-1 downto 0);
    variable perm00_rev     : std_ulogic_vector(CFG_SHUFFLE_WIDTH-1 downto 0);
    variable perm01_rev     : std_ulogic_vector(CFG_SHUFFLE_WIDTH-1 downto 0);
    variable perm10_rev     : std_ulogic_vector(CFG_SHUFFLE_WIDTH-1 downto 0);
    variable src_a          : std_ulogic_vector(CFG_DMEM_WIDTH*CFG_VREG_SLICES-1 downto 0);
    variable src_b          : std_ulogic_vector(CFG_DMEM_WIDTH*CFG_VREG_SLICES-1 downto 0);
    variable result_shuffle : std_ulogic_vector(CFG_DMEM_WIDTH*CFG_VREG_SLICES-1 downto 0);
    variable reg_input      : std_ulogic_vector(unit_width_c-1 downto 0);
    variable shift          : std_ulogic;
  begin
    v   := r;    
    ---------------------------------------------------------------------------
    -- convert input vectors
    ---------------------------------------------------------------------------
    src_a := to_std(veca_i);
    src_b := to_std(vecb_i);
    
    ---------------------------------------------------------------------------
    -- control FSM
    ---------------------------------------------------------------------------
    shift   := '0';
    
    case(r.state) is
      when idle    => if(start_i = '1') then
                        v.state  := shuffle;
                        v.ready  := '0';
                        v.count  := (others=>'0');
                        v.count  := v.count + 1;
                        shift    := '1';
                      end if;
                      
      when shuffle => if(r.count = 3) then
                        v.state  := done;
                        v.ready  := '1';
                      else
                        v.count  := r.count + 1;
                      end if;
                      shift      := '1';
                      
      when done    => v.state    := idle;
      
      when others  => null;
    end case;
    
    ---------------------------------------------------------------------------
    -- source multiplexing
    ---------------------------------------------------------------------------
    if(ssss_i(to_integer(r.count)) = '0') then
      input := src_b;
    else
      input := src_a;
    end if;
    
    ---------------------------------------------------------------------------
    -- permutatation
    ---------------------------------------------------------------------------
    for i in 0 to 3 loop
      -------------------------------------------------------------------------
      -- permutation with width "00"
      -------------------------------------------------------------------------
      perm_00: for j in 0 to 7 loop
        perm00((i*8+j+1)*unit_width_c/8-1 downto (i*8+j)*unit_width_c/8) := input((j*4+i+1)*unit_width_c/8-1 downto (j*4+i)*unit_width_c/8);
      end loop perm_00;
      
      -------------------------------------------------------------------------
      -- permutation with width "01"
      -------------------------------------------------------------------------
      perm_01: for j in 0 to 3 loop
        perm01((i*4+j+1)*unit_width_c/4-1 downto (i*4+j)*unit_width_c/4) := input((j*4+i+1)*unit_width_c/4-1 downto (j*4+i)*unit_width_c/4);
      end loop perm_01;
      
      -------------------------------------------------------------------------
      -- permutation with width "10"
      -------------------------------------------------------------------------
      perm_10: for j in 0 to 1 loop
        perm10((i*2+j+1)*unit_width_c/2-1 downto (i*2+j)*unit_width_c/2) := input((j*4+i+1)*unit_width_c/2-1 downto (j*4+i)*unit_width_c/2);
      end loop perm_10;
    end loop;
    ---------------------------------------------------------------------------
    -- permutation multiplexor
    ---------------------------------------------------------------------------
    case(vwidth_i) is
      when "00"   => perm := perm00;
      when "01"   => perm := perm01;
      when "10"   => perm := perm10;
      when others => perm := input;
    end case;
    
    ---------------------------------------------------------------------------
    -- shift register including the mixing
    ---------------------------------------------------------------------------               
    case(r.count) is
      when   "00" => sel := vn_i(1 downto 0);
      when   "01" => sel := vn_i(3 downto 2);
      when   "10" => sel := vn_i(5 downto 4);
      when others => sel := vn_i(7 downto 6);
    end case;
    
    case(sel) is
      when "00"   => reg_input := perm(1*unit_width_c-1 downto 0*unit_width_c);
      when "01"   => reg_input := perm(2*unit_width_c-1 downto 1*unit_width_c);
      when "10"   => reg_input := perm(3*unit_width_c-1 downto 2*unit_width_c);
      when others => reg_input := perm(4*unit_width_c-1 downto 3*unit_width_c);
    end case;
   
    if(shift = '1') then
      v.shift_reg := reg_input & r.shift_reg(CFG_SHUFFLE_WIDTH-1 downto unit_width_c);
    end if;
    
    ---------------------------------------------------------------------------
    -- reverse permutation
    ---------------------------------------------------------------------------
    for i in 0 to 3 loop
      -------------------------------------------------------------------------
      -- reverse permutation with width "00"
      -------------------------------------------------------------------------
      perm_00_rev: for j in 0 to 7 loop
        perm00_rev((j*4+i+1)*unit_width_c/8-1 downto (j*4+i)*unit_width_c/8) := r.shift_reg((i*8+j+1)*unit_width_c/8-1 downto (i*8+j)*unit_width_c/8);
      end loop perm_00_rev;
      
      -------------------------------------------------------------------------
      -- reverse permutation with width "01"
      -------------------------------------------------------------------------
      perm_01_rev: for j in 0 to 3 loop
        perm01_rev((j*4+i+1)*unit_width_c/4-1 downto (j*4+i)*unit_width_c/4) := r.shift_reg((i*4+j+1)*unit_width_c/4-1 downto (i*4+j)*unit_width_c/4);
      end loop perm_01_rev;
      
      -------------------------------------------------------------------------
      -- reverse permutation with width "10"
      -------------------------------------------------------------------------
      perm_10_rev: for j in 0 to 1 loop
        perm10_rev((j*4+i+1)*unit_width_c/2-1 downto (j*4+i)*unit_width_c/2) := r.shift_reg((i*2+j+1)*unit_width_c/2-1 downto (i*2+j)*unit_width_c/2);
      end loop perm_10_rev;
    end loop;
    
    case(vwidth_i) is
      when "00"   => perm_rev := perm00_rev;
      when "01"   => perm_rev := perm01_rev;
      when "10"   => perm_rev := perm10_rev;
      when others => perm_rev := r.shift_reg;
    end case;
        
    result_shuffle                               := src_a;
    result_shuffle(CFG_SHUFFLE_WIDTH-1 downto 0) := perm_rev(CFG_SHUFFLE_WIDTH-1 downto 0);
    
    ---------------------------------------------------------------------------
    -- drive module output and FFs
    ---------------------------------------------------------------------------
    data_o  <= to_vec(result_shuffle);
    ready_o <= r.ready;
    
    rin     <= v;
  end process comb0;
  
  -----------------------------------------------------------------------------
  -- sync0
  -----------------------------------------------------------------------------
  sync0: process(clk_i, reset_n_i) is
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

