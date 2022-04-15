# automatic generated ghdl makefile do not edit manually
# library and module name
SYNCH_FIFOS_LIB = hibi
SYNCH_FIFOS_MOD = synch_fifos

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
SYNCH_FIFOS_COMFLAGS = --work=${SYNCH_FIFOS_LIB} --workdir=$$DEST_PROJECTS/${SYNCH_FIFOS_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
SYNCH_FIFOS_ELABFLAGS = --work=${SYNCH_FIFOS_LIB} --workdir=$$DEST_PROJECTS/${SYNCH_FIFOS_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all:

# targets to elaborate entities
# targets to analyze files
# file dependencies
