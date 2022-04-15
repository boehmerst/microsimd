# automatic generated ghdl makefile do not edit manually
# library and module name
FIFOS_LIB = hibi
FIFOS_MOD = fifos

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
FIFOS_COMFLAGS = --work=${FIFOS_LIB} --workdir=$$DEST_PROJECTS/${FIFOS_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
FIFOS_ELABFLAGS = --work=${FIFOS_LIB} --workdir=$$DEST_PROJECTS/${FIFOS_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${FIFOS_LIB}/ghdl/fifo.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${FIFOS_LIB}/ghdl/fifo.o: ${GIT_PROJECTS}/vhdl/hibi/fifos/rtl/fifo.vhd
	@echo "compile file......." $<
	@$(COMP) $(FIFOS_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${FIFOS_LIB}/ghdl/fifo.o

# file dependencies
${DEST_PROJECTS}/${FIFOS_LIB}/ghdl/fifo.o:

