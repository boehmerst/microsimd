# automatic generated ghdl makefile do not edit manually
# library and module name
FIFO_LIB = tech
FIFO_MOD = fifo

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
FIFO_COMFLAGS = --work=${FIFO_LIB} --workdir=$$DEST_PROJECTS/${FIFO_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
FIFO_ELABFLAGS = --work=${FIFO_LIB} --workdir=$$DEST_PROJECTS/${FIFO_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${FIFO_LIB}/ghdl/dp_fifo.o ${DEST_PROJECTS}/${FIFO_LIB}/ghdl/dp_fifo_beh.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${FIFO_LIB}/ghdl/dp_fifo.o: ${GIT_PROJECTS}/vhdl/tech/fifo/rtl/dp_fifo.vhd
	@echo "compile file......." $<
	@$(COMP) $(FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${FIFO_LIB}/ghdl/dp_fifo.o

${DEST_PROJECTS}/${FIFO_LIB}/ghdl/dp_fifo_beh.o: ${GIT_PROJECTS}/vhdl/tech/fifo/rtl/dp_fifo_beh.vhd
	@echo "compile file......." $<
	@$(COMP) $(FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${FIFO_LIB}/ghdl/dp_fifo_beh.o

# file dependencies
${DEST_PROJECTS}/${FIFO_LIB}/ghdl/dp_fifo.o: ${DEST_PROJECTS}/tech/ghdl/tech_constants_pkg.o ${DEST_PROJECTS}/tech/ghdl/dp_fifo_beh.o

${DEST_PROJECTS}/${FIFO_LIB}/ghdl/dp_fifo_beh.o: ${DEST_PROJECTS}/general/ghdl/graycount.o ${DEST_PROJECTS}/general/ghdl/graycount.o

