# automatic generated ghdl makefile do not edit manually
# library and module name
HIBI_PIF_LIB = microsimd
HIBI_PIF_MOD = hibi_pif

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
HIBI_PIF_COMFLAGS = --work=${HIBI_PIF_LIB} --workdir=$$DEST_PROJECTS/${HIBI_PIF_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
HIBI_PIF_ELABFLAGS = --work=${HIBI_PIF_LIB} --workdir=$$DEST_PROJECTS/${HIBI_PIF_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif.o ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_regfile_pkg.o ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_pkg.o ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_fifo_if.o ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma.o ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_regfile.o ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_tx.o ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_regif_types_pkg.o ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_types_pkg.o ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_core.o ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_trigger.o ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_ctrl.o ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_rx.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_regfile_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif_dma_regfile_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_regfile_pkg.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif_dma_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_pkg.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_fifo_if.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif_fifo_if.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_fifo_if.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif_dma.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_regfile.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif_dma_regfile.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_regfile.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_tx.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif_tx.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_tx.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_regif_types_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif_dma_regif_types_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_regif_types_pkg.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_types_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif_types_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_types_pkg.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_core.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif_dma_core.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_core.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_trigger.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif_dma_trigger.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_trigger.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_ctrl.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif_dma_ctrl.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_ctrl.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_rx.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_pif/rtl/hibi_pif_rx.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_PIF_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_rx.o

# file dependencies
${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif.o: ${DEST_PROJECTS}/general/ghdl/general_function_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_regif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_regfile_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_rx.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_tx.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_fifo_if.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_regfile.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_core.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_ctrl.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_regfile_pkg.o:

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_pkg.o:

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_fifo_if.o: ${DEST_PROJECTS}/general/ghdl/general_function_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_pkg.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma.o: ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_regif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_regfile_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_regfile.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_trigger.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_core.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_ctrl.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_regfile.o: ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_regif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_regfile_pkg.o ${DEST_PROJECTS}/hibi/ghdl/txt_util.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_tx.o: ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_pkg.o ${DEST_PROJECTS}/hibi/ghdl/cdc_fifo.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_regif_types_pkg.o:

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_types_pkg.o: ${DEST_PROJECTS}/general/ghdl/general_function_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_pkg.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_core.o: ${DEST_PROJECTS}/general/ghdl/general_function_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/round_robin_arb.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_trigger.o:

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_dma_ctrl.o: ${DEST_PROJECTS}/general/ghdl/general_function_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_regif_types_pkg.o

${DEST_PROJECTS}/${HIBI_PIF_LIB}/ghdl/hibi_pif_rx.o: ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_dma_pkg.o ${DEST_PROJECTS}/general/ghdl/sync_ff.o ${DEST_PROJECTS}/hibi/ghdl/cdc_fifo.o

