# automatic generated ghdl makefile do not edit manually
# library and module name
HIBI_DMA_LIB = microsimd
HIBI_DMA_MOD = hibi_dma

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
HIBI_DMA_COMFLAGS = --work=${HIBI_DMA_LIB} --workdir=$$DEST_PROJECTS/${HIBI_DMA_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
HIBI_DMA_ELABFLAGS = --work=${HIBI_DMA_LIB} --workdir=$$DEST_PROJECTS/${HIBI_DMA_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_fsl.o ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_regfile_pkg.o ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_ctrl.o ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma.o ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_wrapper.o ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_regfile.o ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_pkg.o ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_trigger.o ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_regif_types_pkg.o ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_gif_mux.o ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_core.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_fsl.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_dma/rtl/hibi_dma_fsl.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_DMA_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_fsl.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_regfile_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_dma/rtl/hibi_dma_regfile_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_DMA_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_regfile_pkg.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_ctrl.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_dma/rtl/hibi_dma_ctrl.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_DMA_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_ctrl.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_dma/rtl/hibi_dma.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_DMA_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_wrapper.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_dma/rtl/hibi_dma_wrapper.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_DMA_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_wrapper.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_regfile.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_dma/rtl/hibi_dma_regfile.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_DMA_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_regfile.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_dma/rtl/hibi_dma_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_DMA_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_pkg.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_trigger.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_dma/rtl/hibi_dma_trigger.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_DMA_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_trigger.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_regif_types_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_dma/rtl/hibi_dma_regif_types_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_DMA_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_regif_types_pkg.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_gif_mux.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_dma/rtl/hibi_dma_gif_mux.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_DMA_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_gif_mux.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_core.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_dma/rtl/hibi_dma_core.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_DMA_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_core.o

# file dependencies
${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_fsl.o: ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_regif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_regfile_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_pkg.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_regfile_pkg.o:

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_ctrl.o: ${DEST_PROJECTS}/general/ghdl/general_function_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_regif_types_pkg.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma.o: ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_regif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_regfile_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_regfile.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_trigger.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_core.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_ctrl.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_gif_mux.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_wrapper.o: ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_regif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_fsl.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_regfile.o: ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_regif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_regfile_pkg.o ${DEST_PROJECTS}/hibi/ghdl/txt_util.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_pkg.o:

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_trigger.o:

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_regif_types_pkg.o:

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_gif_mux.o: ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_regif_types_pkg.o

${DEST_PROJECTS}/${HIBI_DMA_LIB}/ghdl/hibi_dma_core.o: ${DEST_PROJECTS}/general/ghdl/general_function_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/round_robin_arb.o

