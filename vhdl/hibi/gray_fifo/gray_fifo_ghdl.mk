# automatic generated ghdl makefile do not edit manually
# library and module name
GRAY_FIFO_LIB = hibi
GRAY_FIFO_MOD = gray_fifo

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
GRAY_FIFO_COMFLAGS = --work=${GRAY_FIFO_LIB} --workdir=$$DEST_PROJECTS/${GRAY_FIFO_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
GRAY_FIFO_ELABFLAGS = --work=${GRAY_FIFO_LIB} --workdir=$$DEST_PROJECTS/${GRAY_FIFO_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/cdc_fifo.o ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/async_dpram_generic.o ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/tb_cdc_fifo_tester.o ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/tb_cdc_fifo_tester ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/gray.o ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/cdc_fifo_ctrl.o ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/cdc_fifo_tester.o

# targets to elaborate entities
${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/tb_cdc_fifo_tester: ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/tb_cdc_fifo_tester.o
	@echo "elaborate entity..." tb_cdc_fifo_tester
	@$(ELAB) $(GRAY_FIFO_ELABFLAGS) tb_cdc_fifo_tester
	@echo -n "#/bin/bash\n\nghdl -r --work=${GRAY_FIFO_LIB} --workdir=$$DEST_PROJECTS/${GRAY_FIFO_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 " >> ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/tb_cdc_fifo_tester.sh
	@echo -n "tb_cdc_fifo_tester " >> ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/tb_cdc_fifo_tester.sh
	@echo -n '$$' >> ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/tb_cdc_fifo_tester.sh
	@echo "1" >> ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/tb_cdc_fifo_tester.sh

# targets to analyze files
${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/cdc_fifo.o: ${GIT_PROJECTS}/vhdl/hibi/gray_fifo/rtl/cdc_fifo.vhd
	@echo "compile file......." $<
	@$(COMP) $(GRAY_FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/cdc_fifo.o

${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/async_dpram_generic.o: ${GIT_PROJECTS}/vhdl/hibi/gray_fifo/rtl/async_dpram_generic.vhd
	@echo "compile file......." $<
	@$(COMP) $(GRAY_FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/async_dpram_generic.o

${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/tb_cdc_fifo_tester.o: ${GIT_PROJECTS}/vhdl/hibi/gray_fifo/rtl_tb/tb_cdc_fifo_tester.vhd
	@echo "compile file......." $<
	@$(COMP) $(GRAY_FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/tb_cdc_fifo_tester.o

${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/gray.o: ${GIT_PROJECTS}/vhdl/hibi/gray_fifo/rtl/gray.vhd
	@echo "compile file......." $<
	@$(COMP) $(GRAY_FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/gray.o

${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/cdc_fifo_ctrl.o: ${GIT_PROJECTS}/vhdl/hibi/gray_fifo/rtl/cdc_fifo_ctrl.vhd
	@echo "compile file......." $<
	@$(COMP) $(GRAY_FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/cdc_fifo_ctrl.o

${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/cdc_fifo_tester.o: ${GIT_PROJECTS}/vhdl/hibi/gray_fifo/rtl/cdc_fifo_tester.vhd
	@echo "compile file......." $<
	@$(COMP) $(GRAY_FIFO_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/cdc_fifo_tester.o

# file dependencies
${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/cdc_fifo.o: ${DEST_PROJECTS}/hibi/ghdl/async_dpram_generic.o ${DEST_PROJECTS}/hibi/ghdl/cdc_fifo_ctrl.o

${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/async_dpram_generic.o:

${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/tb_cdc_fifo_tester.o: ${DEST_PROJECTS}/hibi/ghdl/cdc_fifo_tester.o

${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/gray.o:

${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/cdc_fifo_ctrl.o: ${DEST_PROJECTS}/hibi/ghdl/gray.o

${DEST_PROJECTS}/${GRAY_FIFO_LIB}/ghdl/cdc_fifo_tester.o: ${DEST_PROJECTS}/hibi/ghdl/cdc_fifo.o

