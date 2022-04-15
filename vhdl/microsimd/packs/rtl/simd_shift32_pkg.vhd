library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.core_pkg.all;
use work.func_pkg.all;
use work.vec_data_pkg.all;

package simd_shift32_pkg is

  constant shift_left_c  : std_ulogic := '0';
  constant shift_right_c : std_ulogic := '1';

  -----------------------------------------------------------------------------
  -- 32 bit simd shift
  -----------------------------------------------------------------------------  
  function simd_shift32(value  : std_ulogic_vector(31 downto 0); 
                        shamt  : std_ulogic_vector(31 downto 0);
                        size   : simd_size_t;
                        dt     : simd_data_t;
                        res_dt : simd_data_t;
                        dir    : simd_direction_t;
                        sat    : std_ulogic) return std_ulogic_vector;

end package simd_shift32_pkg;


package body simd_shift32_pkg is
  -----------------------------------------------------------------------------
  -- private types
  -----------------------------------------------------------------------------
  type std8_arr_t  is array(natural range 0 to  7) of std_ulogic_vector( 7 downto 0);
  type std16_arr_t is array(natural range 0 to 15) of std_ulogic_vector(15 downto 0);
  type std32_arr_t is array(natural range 0 to 31) of std_ulogic_vector(31 downto 0);

  constant usatmask8_c : std8_arr_t :=(
    x"00", x"80", x"c0", x"e0",
    x"f0", x"f8", x"fc", x"fe"
  );
  
  constant ssatmask8_c : std8_arr_t :=(
    x"80", x"c0", x"e0", x"f0",
    x"f8", x"fc", x"fe", x"ff"
  );

  constant usatmask16_c : std16_arr_t :=(
    x"0000", x"8000", x"c000", x"e000",
    x"f000", x"f800", x"fc00", x"fe00",
    x"ff00", x"ff80", x"ffc0", x"ffe0",
    x"fff0", x"fff8", x"fffc", x"fffe"
  );
  
  constant ssatmask16_c : std16_arr_t :=(
    x"8000", x"c000", x"e000", x"f000",
    x"f800", x"fc00", x"fe00", x"ff00",
    x"ff80", x"ffc0", x"ffe0", x"fff0",
    x"fff8", x"fffc", x"fffe", x"ffff"
  );  

  constant usatmask32_c : std32_arr_t :=(
    x"00000000", x"80000000", x"c0000000", x"e0000000",
    x"f0000000", x"f8000000", x"fc000000", x"fe000000",
    x"ff000000", x"ff800000", x"ffc00000", x"ffe00000",
    x"fff00000", x"fff80000", x"fffc0000", x"fffe0000",
    x"ffff0000", x"ffff8000", x"ffffc000", x"ffffe000",
    x"fffff000", x"fffff800", x"fffffc00", x"fffffe00",
    x"ffffff00", x"ffffff80", x"ffffffc0", x"ffffffe0",
    x"fffffff0", x"fffffff8", x"fffffffc", x"fffffffe"
  );
  
  constant ssatmask32_c : std32_arr_t :=(
    x"80000000", x"c0000000", x"e0000000", x"f0000000",
    x"f8000000", x"fc000000", x"fe000000", x"ff000000",
    x"ff800000", x"ffc00000", x"ffe00000", x"fff00000",
    x"fff80000", x"fffc0000", x"fffe0000", x"ffff0000",
    x"ffff8000", x"ffffc000", x"ffffe000", x"fffff000",
    x"fffff800", x"fffffc00", x"fffffe00", x"ffffff00",
    x"ffffff80", x"ffffffc0", x"ffffffe0", x"fffffff0",
    x"fffffff8", x"fffffffc", x"fffffffe", x"ffffffff"
  );
  
  -----------------------------------------------------------------------------
  -- absolute
  -----------------------------------------------------------------------------
  function absolute(a: std_ulogic_vector) return std_ulogic_vector is
    variable ina : unsigned(a'length-1 downto 0);
  begin
    ina := unsigned(a);
    if(a(a'left) = '1') then
      ina := (not ina) + 1;
    end if;
    return std_ulogic_vector(ina(a'length-1 downto 0));
  end function absolute; 

  -----------------------------------------------------------------------------
  -- or_reduce
  -----------------------------------------------------------------------------
  function or_reduce(a : std_ulogic_vector) return std_ulogic is
    variable result : std_ulogic;
  begin
    result   := '0';
    or_red: for i in a'range loop 
      result := result or a(i);
    end loop or_red;
    return result;
  end function or_reduce;

  -----------------------------------------------------------------------------
  -- and_reduce
  -----------------------------------------------------------------------------
  function and_reduce(a : std_ulogic_vector) return std_ulogic is
    variable result : std_ulogic;
  begin
    result   := '1';
    and_red: for i in a'range loop 
      result := result and a(i);
    end loop and_red;
    return result;
  end function and_reduce;

  -----------------------------------------------------------------------------
  -- 32 bit simd shift left
  -----------------------------------------------------------------------------
  function simd_shift32(value  : std_ulogic_vector(31 downto 0); 
                        shamt  : std_ulogic_vector(31 downto 0);
                        size   : simd_size_t;
                        dt     : simd_data_t;
                        res_dt : simd_data_t;
                        dir    : simd_direction_t;
                        sat    : std_ulogic) return std_ulogic_vector is
    variable shift32_val        : std_ulogic_vector(31 downto 0);
    variable shift32_shamt      : std_ulogic_vector( 4 downto 0);
    variable shift32_left_res   : std_ulogic_vector(31 downto 0);
    variable shift32_right_res  : std_ulogic_vector(31 downto 0);
    variable shift32_pad        : std_ulogic;

    variable shift16_val        : std_ulogic_vector(15 downto 0);
    variable shift16_shamt      : std_ulogic_vector( 3 downto 0);
    variable shift16_left_res   : std_ulogic_vector(15 downto 0);
    variable shift16_right_res  : std_ulogic_vector(15 downto 0);
    variable shift16_pad        : std_ulogic;

    variable shift8_val_0       : std_ulogic_vector( 7 downto 0);
    variable shift8_shamt_0     : std_ulogic_vector( 2 downto 0);
    variable shift8_left_res_0  : std_ulogic_vector( 7 downto 0);
    variable shift8_right_res_0 : std_ulogic_vector( 7 downto 0);
    variable shift8_pad_0       : std_ulogic;

    variable shift8_val_1       : std_ulogic_vector( 7 downto 0);
    variable shift8_shamt_1     : std_ulogic_vector( 2 downto 0);
    variable shift8_left_res_1  : std_ulogic_vector( 7 downto 0);
    variable shift8_right_res_1 : std_ulogic_vector( 7 downto 0);
    variable shift8_pad_1       : std_ulogic;

    variable usat_byte_mask     : std_ulogic_vector( 7 downto 0);
    variable usat_word_mask     : std_ulogic_vector(15 downto 0);
    variable usat_double_mask   : std_ulogic_vector(31 downto 0);
    
    variable ssat_byte_mask     : std_ulogic_vector( 7 downto 0);
    variable ssat_word_mask     : std_ulogic_vector(15 downto 0);
    variable ssat_double_mask   : std_ulogic_vector(31 downto 0);

    variable signed_saturate    : std_ulogic_vector( 3 downto 0);
    variable unsigned_saturate  : std_ulogic_vector( 3 downto 0);

    variable shift_dir          : std_ulogic_vector( 3 downto 0);
    variable result             : std_ulogic_vector(31 downto 0);
  begin
    ---------------------------------------------------------------------------
    -- determine shift direction for mux selection
    ---------------------------------------------------------------------------
    case(dir) is
      when LEFT       => shift_dir := (others=>shift_left_c);
      when RIGHT      => shift_dir := (others=>shift_right_c);
      when LEFT_RIGHT => case(size) is
                           when BYTE   => dir8: for i in 0 to 3 loop
                                            shift_dir(i)     := shamt(8*i+3);
                                          end loop dir8;
                           when WORD   => dir16: for i in 0 to 1 loop
                                            shift_dir(2*i)   := shamt(16*i+4);
                                            shift_dir(2*i+1) := shamt(16*i+4);
                                          end loop dir16;
                           when others => shift_dir          := (others=>shamt(5));
                         end case;
      when others     => shift_dir := (others=>shift_left_c);
    end case;

    ---------------------------------------------------------------------------
    -- shifter input assignment
    ---------------------------------------------------------------------------
    shift32_shamt  := (others=>'0');
    shift32_val    := (others=>'0');
    shift32_pad    := '0';
    shift16_shamt  := (others=>'0');
    shift16_val    := (others=>'0');
    shift16_pad    := '0';
    shift8_shamt_0 := (others=>'0');
    shift8_val_0   := (others=>'0');
    shift8_pad_0   := '0';
    shift8_shamt_1 := (others=>'0');
    shift8_val_1   := (others=>'0');
    shift8_pad_1   := '0';

    case(size) is
      when BYTE   => shift8_val_0   := value( 7 downto  0);
                     shift8_shamt_0 := absolute(shamt( 3 downto  0))(2 downto 0);
                     shift8_pad_0   := '0';
                     
                     shift8_val_1   := value(15 downto  8);
                     shift8_shamt_1 := absolute(shamt(11 downto  8))(2 downto 0);
                     shift8_pad_1   :=  '0';

                     shift16_val    := std_ulogic_vector(resize(unsigned(value(23 downto 16)), 16));
                     shift16_shamt  := '0' & absolute(shamt(19 downto 16))(2 downto 0);
                     shift16_pad    := '0';

                     shift32_val    := std_ulogic_vector(resize(unsigned(value(31 downto 24)), 32));
                     shift32_shamt  := "00" & absolute(shamt(27 downto 24))(2 downto 0);
                     shift32_pad    := '0';
                     
                     if(dt = S) then
                       shift8_pad_0 := value( 7);
                       shift8_pad_1 := value(15);
                       shift16_pad  := value(23);
                       shift32_pad  := value(31);
                       shift16_val  := std_ulogic_vector(resize(signed(value(23 downto 16)), 16));
                       shift32_val  := std_ulogic_vector(resize(signed(value(31 downto 24)), 32));
                     end if;             

      when WORD   => shift16_val    := value(15 downto  0);
                     shift16_shamt  := absolute(shamt( 4 downto  0))(3 downto 0);
                     shift16_pad    := '0';

                     shift32_val    := std_ulogic_vector(resize(unsigned(value(31 downto 16)), 32));
                     shift32_shamt  := '0' & absolute(shamt(20 downto 16))(3 downto 0);
                     shift32_pad    := '0';
                     
                     if(dt = S) then
                       shift16_pad  := value(15);
                       shift32_pad  := value(31);
                       shift32_val  := std_ulogic_vector(resize(signed(value(31 downto 16)), 32));
                     end if;

      when others => shift32_val    := value;
                     shift32_shamt  := absolute(shamt( 5 downto  0))(4 downto 0);
                     shift32_pad    := '0';
                     
                     if(dt = S) then
                       shift32_pad  := value(31);
                     end if;            
    end case;

    ---------------------------------------------------------------------------
    -- shift
    ---------------------------------------------------------------------------
    shift8_left_res_0  := shift8_left(shift8_val_0, shift8_shamt_0);
    shift8_left_res_1  := shift8_left(shift8_val_1, shift8_shamt_1);
    shift16_left_res   := shift16_left(shift16_val, shift16_shamt);
    shift32_left_res   := shift_left(shift32_val,   shift32_shamt);

    shift8_right_res_0 := shift8_right(shift8_val_0, shift8_shamt_0, shift8_pad_0);
    shift8_right_res_1 := shift8_right(shift8_val_1, shift8_shamt_1, shift8_pad_1);
    shift16_right_res  := shift16_right(shift16_val, shift16_shamt,  shift16_pad);
    shift32_right_res  := shift_right(shift32_val,   shift32_shamt,  shift32_pad);

    ---------------------------------------------------------------------------
    -- generate saturation mask
    ---------------------------------------------------------------------------
    usat_byte_mask     := usatmask8_c (to_integer(unsigned(shamt(2 downto 0))));
    usat_word_mask     := usatmask16_c(to_integer(unsigned(shamt(3 downto 0))));
    usat_double_mask   := usatmask32_c(to_integer(unsigned(shamt(4 downto 0))));
    
    ssat_byte_mask     := ssatmask8_c (to_integer(unsigned(shamt(2 downto 0))));
    ssat_word_mask     := ssatmask16_c(to_integer(unsigned(shamt(3 downto 0))));
    ssat_double_mask   := ssatmask32_c(to_integer(unsigned(shamt(4 downto 0))));
    
    ---------------------------------------------------------------------------
    -- test for saturation
    ---------------------------------------------------------------------------
    signed_saturate   := (others=>'0');
    unsigned_saturate := (others=>'0');

    if(sat = '1') then
      case(size) is
        when BYTE   =>
          if(dt = U) then
            usbyte: for i in 0 to 3 loop
              unsigned_saturate(i) := or_reduce(value((i+1)*8-1 downto i*8) and usat_byte_mask);
            end loop usbyte;
          elsif(dt = S) then
            sbyte: for i in 0 to 3 loop
              if(value((i+1)*8-1) = '0') then
                signed_saturate(i) := or_reduce(value((i+1)*8-1 downto i*8) and ssat_byte_mask);
              else
                signed_saturate(i) := not and_reduce(value((i+1)*8-1 downto i*8) or not ssat_byte_mask);
              end if;
            end loop sbyte;
          end if;
        when WORD   =>
          if(dt = U) then
            unsigned_saturate(1)   := or_reduce(value(15 downto  0) and usat_word_mask);
            unsigned_saturate(3)   := or_reduce(value(31 downto 16) and usat_word_mask);
          elsif(dt = S) then
           if(value(15) = '0') then
              signed_saturate(1)   := or_reduce(value(15 downto  0) and ssat_word_mask);
              signed_saturate(3)   := or_reduce(value(31 downto 16) and ssat_word_mask);
            else
              signed_saturate(1)   := not and_reduce(value(15 downto  0) or not ssat_word_mask);
              signed_saturate(3)   := not and_reduce(value(31 downto 16) or not ssat_word_mask);
            end if;
          end if;
        when others =>
          if(dt = U) then
            unsigned_saturate(3)   := or_reduce(value and usat_double_mask);
          elsif(dt = S) then
            if(value(31) = '0') then
              signed_saturate(3)   := or_reduce(value and ssat_double_mask);
            else
              signed_saturate(3)   := not and_reduce(value or not ssat_double_mask);      
            end if;
          end if;
      end case;
    end if;

    ---------------------------------------------------------------------------
    -- generate result
    ---------------------------------------------------------------------------
    case(size) is
      when BYTE   =>  if(shift_dir(0) = '1') then
                        result( 7 downto  0) := shift8_right_res_0;
                      else
                        result( 7 downto  0) := shift8_left_res_0;
                      end if;
                      if(shift_dir(1) = '1') then
                        result(15 downto  8) := shift8_right_res_1;
                      else
                        result(15 downto  8) := shift8_left_res_1;
                      end if;
                      if(shift_dir(2) = '1') then
                        result(23 downto 16) := shift16_right_res(7 downto 0);
                      else
                        result(23 downto 16) := shift16_left_res(7 downto 0);
                      end if;
                      if(shift_dir(3) = '1') then
                        result(31 downto 24) := shift32_right_res(7 downto 0);
                      else
                        result(31 downto 24) := shift32_left_res(7 downto 0);
                      end if;

      when WORD   =>  if(shift_dir(1) = '1') then
                        result(15 downto  0) := shift16_right_res;
                      else
                        result(15 downto  0) := shift16_left_res;
                      end if;
                      if(shift_dir(3) = '1') then
                        result(31 downto 16) := shift32_right_res(15 downto 0);
                      else
                        result(31 downto 16) := shift32_left_res(15 downto 0);
                      end if;

      when others =>  if(shift_dir(3) = '1') then
                        result := shift32_right_res;
                      else
                        result := shift32_left_res;
                      end if;
    end case;

    ---------------------------------------------------------------------------
    -- conditionally saturate
    ---------------------------------------------------------------------------
    if(sat = '1') then
      case(size) is
        when BYTE   => ressat0: for i in 0 to 3 loop
                         if(dt = U) then
                           if(unsigned_saturate(i) = '1') then
                             result((i+1)*8-1 downto  i*8)       := x"ff";
                           end if;
                         else
                           if(res_dt = U) then
                             if(unsigned_saturate(i) = '1') then
                               if(value((i+1)*8-1) = '0') then
                                 result((i+1)*8-1 downto  i*8)   := x"ff";
                               else
                                 result((i+1)*8-1 downto  i*8)   := x"00";
                               end if;
                             end if;
                           else
                             if(signed_saturate(i) = '1') then
                               if(value((i+1)*8-1) = '0') then
                                 result((i+1)*8-1 downto  i*8)   := x"7f";
                               else  
                                 result((i+1)*8-1 downto  i*8)   := x"80";
                               end if;
                             end if;
                           end if;
                         end if;
                       end loop ressat0;

        when WORD   => ressat1: for i in 0 to 1 loop
                         if(dt = U) then
                           if(unsigned_saturate(2*i+1) = '1') then
                             result((i+1)*16-1 downto  i*16)     := x"ffff";
                           end if;
                         else
                           if(res_dt = U) then
                             if(unsigned_saturate(2*i+1) = '1') then
                               if(value((i+1)*16-1) = '0') then
                                 result((i+1)*16-1 downto  i*16) := x"ffff";
                               else
                                 result((i+1)*16-1 downto  i*16) := x"0000";
                               end if;
                             end if;
                           else
                             if(signed_saturate(2*i+1) = '1') then
                               if(value((i+1)*16-1) = '0') then
                                 result((i+1)*16-1 downto  i*16) := x"7fff";
                               else  
                                 result((i+1)*16-1 downto  i*16) := x"8000";
                               end if;
                             end if;
                           end if;
                         end if;
                       end loop ressat1;

        when others => if(dt = U) then
                         if(unsigned_saturate(3) = '1') then
                           result                                := x"ffffffff";
                         end if;
                       else
                         if(res_dt = U) then
                           if(value(31) = '0') then
                             result                              := x"ffffffff";
                           else
                             result                              := x"00000000";
                           end if;
                         else
                           if(signed_saturate(3) = '1') then
                             if(value(31) = '0') then
                               result                            := x"7fffffff";
                             else
                               result                            := x"80000000";
                             end if;
                           end if;
                         end if;
                       end if;
      end case;     
    end if;

    return result;
  end function simd_shift32;

end package body simd_shift32_pkg;
