# automatic generated ghdl makefile do not edit manually
# library and module name
FIFO_MK2_LIB = hibi
FIFO_MK2_MOD = fifo_mk2

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
FIFO_MK2_COMFLAGS = --work=${FIFO_MK2_LIB} --workdir=$$DEST_PROJECTS/${FIFO_MK2_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
FIFO_MK2_ELABFLAGS = --work=${FIFO_MK2_LIB} --workdir=$$DEST_PROJECTS/${FIFO_MK2_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${FIFO_MK2_LIB}/ghdl/fifo_2clk.o ${DEST_PROJECTS}/${FIFO_MK2_LIB}/ghdl/ram_1clk.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${FIFO_MK2_LIB}/ghdl/fifo_2clk.o: ${GIT_PROJECTS}/vhdl/hibi/fifo_mk2/rtl/fifo_2clk.vhd
	@echo "compile file......." $<
	@$(COMP) $(FIFO_MK2_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${FIFO_MK2_LIB}/ghdl/fifo_2clk.o

${DEST_PROJECTS}/${FIFO_MK2_LIB}/ghdl/ram_1clk.o: ${GIT_PROJECTS}/vhdl/hibi/fifo_mk2/rtl/ram_1clk.vhd
	@echo "compile file......." $<
	@$(COMP) $(FIFO_MK2_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${FIFO_MK2_LIB}/ghdl/ram_1clk.o

# file dependencies
${DEST_PROJECTS}/${FIFO_MK2_LIB}/ghdl/fifo_2clk.o: ${DEST_PROJECTS}/hibi/ghdl/ram_1clk.o

${DEST_PROJECTS}/${FIFO_MK2_LIB}/ghdl/ram_1clk.o:

