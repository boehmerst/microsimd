library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package config_pkg is

  type regfile_type_t is (reg, latch, bram);
  constant CFG_REGFILE_TYPE   : integer := regfile_type_t'pos(reg);

  -- Implement hardware multiplier
  constant CFG_USE_HW_MUL     : boolean  := true;    -- Disable or enable multiplier [0,1]
  constant CFG_USE_HW_VEC_MUL : boolean  := true;    -- Disable or enable vector multiplier [0,1]

  -- Implement hardware barrel shifter
  constant CFG_USE_BARREL     : boolean  := true;    -- Disable or enable barrel shifter [0,1]
  constant CFG_USE_VEC_BARREL : boolean  := true;    -- Disable or enable barrel shifter [0,1]
  
  -- Debug mode
  constant CFG_DEBUG          : boolean  := true;    -- Resets some extra registers for better readability
                                                     -- and enables feedback (report) [0,1]
                                                     -- Set CFG_DEBUG to zero to obtain best performance.
  -- Memory parameters; changing memory parameters 
  -- might require to adapt peripheral components
  -- like DMA, XBAR, FSL, ...
  constant CFG_DMEM_SIZE      : positive := 16;      -- Data memory bus size in 2LOG # elements
  constant CFG_VDMEM_SIZE     : positive := 16;      -- Vector data memory bus size in 2LOG # elements
  constant CFG_IMEM_SIZE      : positive := 16;      -- Instruction memory bus size in 2LOG # elements
    
  constant CFG_BYTE_ORDER     : boolean  := true;    -- Switch between MSB (1, default) and LSB (0) byte order policy
  
  -- Implement external interrupt
  constant CFG_INTERRUPT      : boolean  := true;    -- Disable or enable external interrupt [0,1]
  constant CFG_IRQ_VEC        : std_ulogic_vector(CFG_IMEM_SIZE-1 downto 0)
                                         := (others=>'0');

  -- Register parameters
  constant CFG_REG_FORCE_ZERO : boolean  := true;    -- Force data to zero if register address is zero [0,1]
  constant CFG_REG_FWD_WRB    : boolean  := true;    -- Forward writeback to loosen register memory requirements [0,1]
  constant CFG_MEM_FWD_WRB    : boolean  := true;    -- Forward memory result instead of introducing stalls [0,1]

  constant CFG_DMEM_WIDTH     : positive := 32;      -- Data memory width in bits
  constant CFG_IMEM_WIDTH     : positive := 32;      -- Instruction memory width in bits
  constant CFG_GPRF_SIZE      : positive :=  5;      -- General Purpose Register File Size in 2LOG # elements
  
  constant CFG_VREG_SIZE      : positive :=  4;      -- Vector Register File Size in 2LOG # elements
  constant CFG_VREG_SLICES    : positive :=  2;      -- Number of slices each of CFG_DMEM_WIDTH width
  
  constant CFG_USE_SHUFFLE    : boolean  := true;
  constant CFG_SHUFFLE_WIDTH  : positive := CFG_VREG_SLICES * CFG_DMEM_WIDTH;
  
  constant CFG_USE_FSL        : boolean  := true;
  --constant CFG_NR_FSL         : positive := 1;

  type fsl_slave_t is(hibi_dma_fsl);  
  constant CFG_NR_FSL         : positive range 1 to 3 := fsl_slave_t'pos(fsl_slave_t'right)+1;
  
  -- Custom instruction
  constant CFG_USE_CUSTOM     : boolean  := true;    -- Use custom vector instruction
  constant CFG_MCI_CUSTOM     : boolean  := true;    -- Custom is multicycle instruction

end package config_pkg;

