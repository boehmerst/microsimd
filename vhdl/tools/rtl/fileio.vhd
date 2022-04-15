library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library tools;
use tools.fileio_pkg.all;

entity fileio is
  generic (
    name_g : string;
    mode_g : fileio_mode_t
  );
  port (
    clk_i    : in    std_logic;
    reset_i  : in    std_logic;
    req_i    : in    std_logic;
    data_io  : inout fileio_container_t;
    ack_o    : out   std_logic;
    status_o : out   fileio_status_t 
  );
end entity fileio;

architecture beh of fileio is

type reg_t is record
  ack     : std_logic;
  status  : fileio_status_t;
  line_nr : integer;
end record reg_t;
constant dflt_reg_c : reg_t := (
  ack     => '0',
  status  => full,
  line_nr => 0
);

type data_container_t is array (natural range data_io'range) of 
  std_logic_vector(31 downto 0);

signal r            : reg_t;
signal data, data_r : data_container_t;

begin
-------------------------------------------------------------------------------
-- check
-------------------------------------------------------------------------------
  check: process is
    variable l : line;
  begin
    write(l, string'("fileio " & name_g & " created in "));
    case(mode_g) is
      when read    => write(l, string'("read mode"));
      when write   => write(l, string'("write mode"));
      when compare => write(l, string'("compare mode"));
      when others  => write(l, string'("unknown mode"));
    end case;

    assert((mode_g = read) or (mode_g = write) or (mode_g = compare)) report 
      "unsupported mode" severity failure;

    writeline(output, l);
    wait;

  end process check;


-------------------------------------------------------------------------------
-- mode read
-------------------------------------------------------------------------------
mode_read: if mode_g = read generate
  file_read: process(reset_i, clk_i) is
    file file_obj     : text open read_mode is name_g;
    variable filestat : file_open_status;
    variable rd       : line;
    variable wr       : line;
    variable i        : integer;
    variable c        : character;
    variable neol     : boolean    := true;
    variable v        : reg_t;
  begin
    if reset_i = '1' then
      file_close(file_obj);
      file_open(filestat, file_obj, name_g, read_mode);
      r        <= dflt_reg_c;
      ack_o    <= '0';
      status_o <= empty;
    elsif(rising_edge(clk_i)) then
      v     := r;
      v.ack := '0';
      if(req_i = '1') then
        loop
          -- test if reading from empty file
          if(endfile(file_obj)) then
            v.status := empty;
            exit;
          end if;

          readline(file_obj, rd);
          v.line_nr := v.line_nr + 1;
          next when rd'length = 0;  -- skip empty lines
          read(rd, c, neol);
          next when c = '#';        -- skip coments

          -- output messages
          if(c = 'M') then
            write(wr, name_g & string'(" (t="));
            write(wr, now);
            write(wr, string'(") message: "));
            loop
              read(rd, c, neol);
              exit when not neol;
              write(wr, c);
            end loop;
            writeline(output, wr);
            next;
          end if;

          -- D marks a data line
          if(c = 'D') then
            for k in data_io'range loop
              read(rd, i);
              data_io(k) <= std_logic_vector(to_signed(i, 32));
              v.ack   := '1';
            end loop;
          end if;

          exit;
        end loop;
      end if;

      -- drive module output
      status_o <= v.status;
      ack_o    <= v.ack;
      r        <= v;
      end if; -- rising_edge(clk_i)
  end process file_read;
end generate mode_read;


-------------------------------------------------------------------------------
-- mode write
-------------------------------------------------------------------------------
mode_write: if mode_g = write generate
  file_write: process(clk_i) is
    file file_obj : text open write_mode is name_g;
    variable rd   : line;
    variable wr   : line;
    variable i    : integer;
    variable c    : character;
    variable neol : boolean    := true;
    variable v    : reg_t;
  begin
    if(rising_edge(clk_i)) then
      if(req_i = '1') then
        write(wr, string'("D"));
        for k in data_io'range loop
          i := to_integer(signed(data_io(k)));
          write(wr, string'(" "));
          write(wr, i);
        end loop;
        writeline(file_obj, wr);
      end if;
    end if;
  end process file_write;
end generate mode_write;


-------------------------------------------------------------------------------
-- mode compare
-------------------------------------------------------------------------------
mode_compare: if mode_g = compare generate
  file_compare: process(reset_i, clk_i) is
    file file_obj     : text open read_mode is name_g;
    variable filestat : file_open_status;
    variable rd       : line;
    variable wr       : line;
    variable i        : integer;
    variable c        : character;
    variable neol     : boolean    := true;
    variable v        : reg_t;
  begin
    if reset_i = '1' then
      file_close(file_obj);
      file_open(filestat, file_obj, name_g, read_mode);
      r        <= dflt_reg_c;
      ack_o    <= '0';
      status_o <= empty;
    elsif(rising_edge(clk_i)) then
      v     := r;
      v.ack := '0';
      if(req_i = '1') then
        loop
          -- test if reading from empty file
          if(endfile(file_obj)) then
            v.status := empty;
            exit;
          end if;

          readline(file_obj, rd);
          v.line_nr := v.line_nr + 1;
          next when rd'length = 0;  -- skip empty lines
          read(rd, c, neol);
          next when c = '#';        -- skip coments

          -- output messages
          if(c = 'M') then
            write(wr, name_g & string'(" (t="));
            write(wr, now);
            write(wr, string'(") message: "));
            loop
              read(rd, c, neol);
              exit when not neol;
              write(wr, c);
            end loop;
            writeline(output, wr);
            next;
          end if;

          -- D marks a data line
          if(c = 'D') then
            for k in data_io'range loop
              read(rd, i);
              data(k)   <= std_logic_vector(to_signed(i, 32));
              data_r(k) <= data_io(k);
              v.ack   := '1';
            end loop;
          end if;

          exit;
        end loop;
      end if;

      if(r.ack = '1') then
        for i in data_io'range loop
          if(data_r(i) /= data(i)) then
            write(wr, name_g & string'(" (t="));
            write(wr, now);
            write(wr, string'(") line ")                    &
            integer'image(r.line_nr)                        &
            string'(" lane ")                               &
            integer'image(i)                                &
            string'(" compare missmatch ")                  & 
            string'(": expected ")                          &
            integer'image(to_integer(signed(data(i))))      &
            string'(" but got ")                            &
            integer'image(to_integer(signed(data_r(i)))));
            writeline(output, wr);
          end if;
        end loop;
      end if;

      -- drive module output
      status_o <= v.status;
      ack_o    <= v.ack;
      r        <= v;
      end if; -- rising_edge(clk_i)
  end process file_compare;
end generate mode_compare;

end architecture beh;

