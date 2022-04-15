# automatic generated ghdl makefile do not edit manually
# library and module name
SYNCHRONIZER_LIB = hibi
SYNCHRONIZER_MOD = synchronizer

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
SYNCHRONIZER_COMFLAGS = --work=${SYNCHRONIZER_LIB} --workdir=$$DEST_PROJECTS/${SYNCHRONIZER_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
SYNCHRONIZER_ELABFLAGS = --work=${SYNCHRONIZER_LIB} --workdir=$$DEST_PROJECTS/${SYNCHRONIZER_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_out_burst.o ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/synch_fifo_pulse.o ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_we_in.o ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/asyn_re_fifo.o ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_out.o ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_top.o ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_we_out.o ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/re_feeder.o ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_in.o ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_we_top.o ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/ext_data_synch_v2.o ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_in_burst.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_out_burst.o: ${GIT_PROJECTS}/vhdl/hibi/synchronizer/rtl/aif_read_out_burst.vhd
	@echo "compile file......." $<
	@$(COMP) $(SYNCHRONIZER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_out_burst.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/synch_fifo_pulse.o: ${GIT_PROJECTS}/vhdl/hibi/synchronizer/rtl/synch_fifo_pulse.vhd
	@echo "compile file......." $<
	@$(COMP) $(SYNCHRONIZER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/synch_fifo_pulse.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_we_in.o: ${GIT_PROJECTS}/vhdl/hibi/synchronizer/rtl/aif_we_in.vhd
	@echo "compile file......." $<
	@$(COMP) $(SYNCHRONIZER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_we_in.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/asyn_re_fifo.o: ${GIT_PROJECTS}/vhdl/hibi/synchronizer/rtl/asyn_re_fifo.vhd
	@echo "compile file......." $<
	@$(COMP) $(SYNCHRONIZER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/asyn_re_fifo.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_out.o: ${GIT_PROJECTS}/vhdl/hibi/synchronizer/rtl/aif_read_out.vhd
	@echo "compile file......." $<
	@$(COMP) $(SYNCHRONIZER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_out.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_top.o: ${GIT_PROJECTS}/vhdl/hibi/synchronizer/rtl/aif_read_top.vhd
	@echo "compile file......." $<
	@$(COMP) $(SYNCHRONIZER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_top.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_we_out.o: ${GIT_PROJECTS}/vhdl/hibi/synchronizer/rtl/aif_we_out.vhd
	@echo "compile file......." $<
	@$(COMP) $(SYNCHRONIZER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_we_out.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/re_feeder.o: ${GIT_PROJECTS}/vhdl/hibi/synchronizer/rtl/re_feeder.vhd
	@echo "compile file......." $<
	@$(COMP) $(SYNCHRONIZER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/re_feeder.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_in.o: ${GIT_PROJECTS}/vhdl/hibi/synchronizer/rtl/aif_read_in.vhd
	@echo "compile file......." $<
	@$(COMP) $(SYNCHRONIZER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_in.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_we_top.o: ${GIT_PROJECTS}/vhdl/hibi/synchronizer/rtl/aif_we_top.vhd
	@echo "compile file......." $<
	@$(COMP) $(SYNCHRONIZER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_we_top.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/ext_data_synch_v2.o: ${GIT_PROJECTS}/vhdl/hibi/synchronizer/rtl/ext_data_synch_v2.vhd
	@echo "compile file......." $<
	@$(COMP) $(SYNCHRONIZER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/ext_data_synch_v2.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_in_burst.o: ${GIT_PROJECTS}/vhdl/hibi/synchronizer/rtl/aif_read_in_burst.vhd
	@echo "compile file......." $<
	@$(COMP) $(SYNCHRONIZER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_in_burst.o

# file dependencies
${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_out_burst.o:

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/synch_fifo_pulse.o:

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_we_in.o:

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/asyn_re_fifo.o: ${DEST_PROJECTS}/hibi/ghdl/aif_read_in.o ${DEST_PROJECTS}/hibi/ghdl/fifo.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_out.o:

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_top.o: ${DEST_PROJECTS}/hibi/ghdl/aif_read_out.o ${DEST_PROJECTS}/hibi/ghdl/aif_read_in.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_we_out.o:

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/re_feeder.o:

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_in.o:

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_we_top.o: ${DEST_PROJECTS}/hibi/ghdl/aif_we_out.o ${DEST_PROJECTS}/hibi/ghdl/aif_we_in.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/ext_data_synch_v2.o: ${DEST_PROJECTS}/hibi/ghdl/multiclk_fifo_v4.o

${DEST_PROJECTS}/${SYNCHRONIZER_LIB}/ghdl/aif_read_in_burst.o:

