# automatic generated ghdl makefile do not edit manually
# library and module name
TTA-DSP_LIB = tta-dsp
TTA-DSP_MOD = tta-dsp

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
TTA-DSP_COMFLAGS = --work=${TTA-DSP_LIB} --workdir=$$DEST_PROJECTS/${TTA-DSP_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
TTA-DSP_ELABFLAGS = --work=${TTA-DSP_LIB} --workdir=$$DEST_PROJECTS/${TTA-DSP_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all:

# targets to elaborate entities
# targets to analyze files
# file dependencies
