library work;
use work.tta0_imem_mau.all;

package tta0_globals is
  -- address width of the instruction memory
  constant IMEMADDRWIDTH : positive := 10;
  -- width of the instruction memory in MAUs
  constant IMEMWIDTHINMAUS : positive := 1;
  -- width of instruction fetch block.
  constant IMEMDATAWIDTH : positive := IMEMWIDTHINMAUS*IMEMMAUWIDTH;
  -- clock period
  constant PERIOD : time := 10 ns;
  -- number of busses.
  constant BUSTRACE_WIDTH : positive := 992;
  -- number of cores
  constant CORECOUNT : positive := 1;
  -- instruction width
  constant INSTRUCTIONWIDTH : positive := 120;
end tta0_globals;
