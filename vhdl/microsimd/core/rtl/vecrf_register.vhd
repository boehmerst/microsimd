library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.core_pkg.all;

entity vecrf_register is
  generic (
    -- NOTE: not really generic because of IO types -> move to VHDL-2008
    dmem_width_g : positive := 32;
    vreg_slc_g   : positive := 1;
    vreg_size_g  : positive := 16
  );
  port (
    clk_i     : in  std_ulogic;
    reset_n_i : in  std_ulogic;
    vecrf_i   : in  vecrf_in_t;
    vecrf_o   : out vecrf_out_t
  );
end entity vecrf_register;

architecture rtl of vecrf_register is

begin
  ------------------------------------------------------------------------------
  -- generate vector register file
  ------------------------------------------------------------------------------
  vec_reg: for i in 0 to vreg_slc_g-1 generate
    reg: block is
      type regfile_t is array (natural range 0 to 2**vreg_size_g-1) of std_ulogic_vector(dmem_width_g-1 downto 0);

      type reg_t is record 
        regfile : regfile_t;
        dat_a   : std_ulogic_vector(dmem_width_g-1 downto 0);
        dat_b   : std_ulogic_vector(dmem_width_g-1 downto 0);
        dat_d   : std_ulogic_vector(dmem_width_g-1 downto 0);
      end record reg_t;
      constant dflt_reg_c : reg_t :=(
        regfile => (others => (others => '0')),
        dat_a   => (others => '0'),
        dat_b   => (others => '0'),
        dat_d   => (others => '0')
      );

      signal r, rin : reg_t;
    begin
      -----------------------------------------------------------------------------
      -- comb0
      -----------------------------------------------------------------------------
      comb0: process (r, vecrf_i.wre(i), vecrf_i.dat_w(i), vecrf_i.adr_a, vecrf_i.adr_b, vecrf_i.adr_d, vecrf_i.adr_w) is
        variable v : reg_t;
      begin
        v := r;

        if vecrf_i.wre(i) = '1' then
          v.regfile(to_integer(unsigned(vecrf_i.adr_w))) := vecrf_i.dat_w(i);
        end if;
    
        v.dat_a := r.regfile(to_integer(unsigned(vecrf_i.adr_a)));
        v.dat_b := r.regfile(to_integer(unsigned(vecrf_i.adr_b)));
        v.dat_d := r.regfile(to_integer(unsigned(vecrf_i.adr_d)));

        vecrf_o.dat_a(i) <= r.dat_a;
        vecrf_o.dat_b(i) <= r.dat_b;
        vecrf_o.dat_d(i) <= r.dat_d;

        rin <= v;
      end process comb0;
  
      -----------------------------------------------------------------------------
      -- sync0
      -----------------------------------------------------------------------------
      sync0: process (clk_i, reset_n_i) is
      begin
        if reset_n_i = '0' then
          r <= dflt_reg_c;
        elsif rising_edge(clk_i) then
          if vecrf_i.ena = '1' then
	    r <= rin;
          end if;
        end if;
      end process sync0;

    end block reg;
  end generate vec_reg;
  
end architecture rtl;

