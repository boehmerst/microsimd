# automatic generated ghdl makefile do not edit manually
# library and module name
MULTICLK_FIFO_LIB = hibi
MULTICLK_FIFO_MOD = multiclk_fifo

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
MULTICLK_FIFO_COMFLAGS = --work=${MULTICLK_FIFO_LIB} --workdir=$$DEST_PROJECTS/${MULTICLK_FIFO_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
MULTICLK_FIFO_ELABFLAGS = --work=${MULTICLK_FIFO_LIB} --workdir=$$DEST_PROJECTS/${MULTICLK_FIFO_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/mixed_clk_fifo_v3.o ${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/threeclk_fifo_v1.o ${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/multiclk_fifo_v4.o ${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/re_pulse_synchronizer.o ${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/we_pulse_synchronizer.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/mixed_clk_fifo_v3.o: ${GIT_PROJECTS}/vhdl/hibi/multiclk_fifo/rtl/mixed_clk_fifo_v3.vhd
	@echo "compile file......." $<
	@$(COMP) $(MULTICLK_FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/mixed_clk_fifo_v3.o

${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/threeclk_fifo_v1.o: ${GIT_PROJECTS}/vhdl/hibi/multiclk_fifo/rtl/threeclk_fifo_v1.vhd
	@echo "compile file......." $<
	@$(COMP) $(MULTICLK_FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/threeclk_fifo_v1.o

${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/multiclk_fifo_v4.o: ${GIT_PROJECTS}/vhdl/hibi/multiclk_fifo/rtl/multiclk_fifo_v4.vhd
	@echo "compile file......." $<
	@$(COMP) $(MULTICLK_FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/multiclk_fifo_v4.o

${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/re_pulse_synchronizer.o: ${GIT_PROJECTS}/vhdl/hibi/multiclk_fifo/rtl/re_pulse_synchronizer.vhd
	@echo "compile file......." $<
	@$(COMP) $(MULTICLK_FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/re_pulse_synchronizer.o

${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/we_pulse_synchronizer.o: ${GIT_PROJECTS}/vhdl/hibi/multiclk_fifo/rtl/we_pulse_synchronizer.vhd
	@echo "compile file......." $<
	@$(COMP) $(MULTICLK_FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/we_pulse_synchronizer.o

# file dependencies
${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/mixed_clk_fifo_v3.o: ${DEST_PROJECTS}/hibi/ghdl/fifo.o ${DEST_PROJECTS}/hibi/ghdl/we_pulse_synchronizer.o ${DEST_PROJECTS}/hibi/ghdl/re_pulse_synchronizer.o

${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/threeclk_fifo_v1.o: ${DEST_PROJECTS}/hibi/ghdl/multiclk_fifo_v4.o ${DEST_PROJECTS}/hibi/ghdl/multiclk_fifo_v4.o

${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/multiclk_fifo_v4.o: ${DEST_PROJECTS}/hibi/ghdl/fifo.o

${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/re_pulse_synchronizer.o:

${DEST_PROJECTS}/${MULTICLK_FIFO_LIB}/ghdl/we_pulse_synchronizer.o:

