# automatic generated ghdl makefile do not edit manually
# library and module name
MPSOC_LIB = microsimd
MPSOC_MOD = MPSoC

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
MPSOC_COMFLAGS = --work=${MPSOC_LIB} --workdir=$$DEST_PROJECTS/${MPSOC_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
MPSOC_ELABFLAGS = --work=${MPSOC_LIB} --workdir=$$DEST_PROJECTS/${MPSOC_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/cpu.o ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/mpsoc_tb.o ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/mpsoc_tb ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/msmp.o ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/hibi_seg_r1.o

# targets to elaborate entities
${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/mpsoc_tb: ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/mpsoc_tb.o
	@echo "elaborate entity..." mpsoc_tb
	@$(ELAB) $(MPSOC_ELABFLAGS) mpsoc_tb
	@echo -n "#/bin/bash\n\nghdl -r --work=${MPSOC_LIB} --workdir=$$DEST_PROJECTS/${MPSOC_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 " >> ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/mpsoc_tb.sh
	@echo -n "mpsoc_tb " >> ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/mpsoc_tb.sh
	@echo -n '$$' >> ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/mpsoc_tb.sh
	@echo "1" >> ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/mpsoc_tb.sh

# targets to analyze files
${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/cpu.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/MPSoC/rtl/cpu.vhd
	@echo "compile file......." $<
	@$(COMP) $(MPSOC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/cpu.o

${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/mpsoc_tb.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/MPSoC/rtl_tb/mpsoc_tb.vhd
	@echo "compile file......." $<
	@$(COMP) $(MPSOC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/mpsoc_tb.o

${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/msmp.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/MPSoC/rtl/msmp.vhd
	@echo "compile file......." $<
	@$(COMP) $(MPSOC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/msmp.o

${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/hibi_seg_r1.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/MPSoC/rtl/hibi_seg_r1.vhd
	@echo "compile file......." $<
	@$(COMP) $(MPSOC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/hibi_seg_r1.o

# file dependencies
${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/cpu.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/xbar_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_dma_wrapper.o ${DEST_PROJECTS}/microsimd/ghdl/xbar.o ${DEST_PROJECTS}/microsimd/ghdl/sram_4en.o ${DEST_PROJECTS}/microsimd/ghdl/sram_4en.o ${DEST_PROJECTS}/microsimd/ghdl/sram_4en.o

${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/mpsoc_tb.o: ${DEST_PROJECTS}/general/ghdl/general_function_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/msmp.o

${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/msmp.o: ${DEST_PROJECTS}/general/ghdl/general_function_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif_types_pkg.o ${DEST_PROJECTS}/hibi/ghdl/hibiv3_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/cpu.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_pif.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_wrapper.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_seg_r1.o

${DEST_PROJECTS}/${MPSOC_LIB}/ghdl/hibi_seg_r1.o: ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/hibi/ghdl/hibiv3_pkg.o ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r1.o

