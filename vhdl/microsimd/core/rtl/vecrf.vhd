library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.core_pkg.all;

entity vecrf is
  generic (
    dmem_width_g : positive := 32;
    vreg_slc_g   : positive := 1;
    vreg_size_g  : positive := 16
  );
  port (
    clk_i   : in  std_ulogic;
    vecrf_i : in  vecrf_in_t;
    vecrf_o : out vecrf_out_t
  );
end entity vecrf;

architecture rtl of vecrf is
begin
  ------------------------------------------------------------------------------
  -- generate vector register file
  ------------------------------------------------------------------------------
  vec_reg: for i in 0 to vreg_slc_g-1 generate
    -- slices for vec_a
    slc_a: entity work.dsram 
      generic map (
        width_g => dmem_width_g,
        size_g  => vreg_size_g
      )
      port map (
        dat_o   => vecrf_o.dat_a(i),
        adr_i   => vecrf_i.adr_a,
        ena_i   => vecrf_i.ena,
        dat_w_i => vecrf_i.dat_w(i),
        adr_w_i => vecrf_i.adr_w,
        wre_i   => vecrf_i.wre(i),
        clk_i   => clk_i
      );
    -- slices for vec_b  
    slc_b: entity work.dsram 
      generic map (
        width_g => dmem_width_g,
        size_g  => vreg_size_g
      )
      port map (
        dat_o   => vecrf_o.dat_b(i),
        adr_i   => vecrf_i.adr_b,
        ena_i   => vecrf_i.ena,
        dat_w_i => vecrf_i.dat_w(i),
        adr_w_i => vecrf_i.adr_w,
        wre_i   => vecrf_i.wre(i),
        clk_i   => clk_i
      );
    -- slices for vec_d  
    slc_d: entity work.dsram 
      generic map (
        width_g => dmem_width_g,
        size_g  => vreg_size_g
      )
      port map (
        dat_o   => vecrf_o.dat_d(i),
        adr_i   => vecrf_i.adr_d,
        ena_i   => vecrf_i.ena,
        dat_w_i => vecrf_i.dat_w(i),
        adr_w_i => vecrf_i.adr_w,
        wre_i   => vecrf_i.wre(i),
        clk_i   => clk_i
      );
  end generate vec_reg;
  
end architecture rtl;

