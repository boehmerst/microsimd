# automatic generated ghdl makefile do not edit manually
# library and module name
HIBI_MEM_LIB = microsimd
HIBI_MEM_MOD = hibi_mem

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
HIBI_MEM_COMFLAGS = --work=${HIBI_MEM_LIB} --workdir=$$DEST_PROJECTS/${HIBI_MEM_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
HIBI_MEM_ELABFLAGS = --work=${HIBI_MEM_LIB} --workdir=$$DEST_PROJECTS/${HIBI_MEM_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_wrapper.o ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem.o ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_trigger.o ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_ctrl.o ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_regfile_pkg.o ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_regif_types_pkg.o ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_regfile.o ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_core.o ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_pkg.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_wrapper.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_mem/rtl/hibi_mem_wrapper.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_wrapper.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_mem/rtl/hibi_mem.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_trigger.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_mem/rtl/hibi_mem_trigger.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_trigger.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_ctrl.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_mem/rtl/hibi_mem_ctrl.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_ctrl.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_regfile_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_mem/rtl/hibi_mem_regfile_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_regfile_pkg.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_regif_types_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_mem/rtl/hibi_mem_regif_types_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_regif_types_pkg.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_regfile.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_mem/rtl/hibi_mem_regfile.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_regfile.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_core.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_mem/rtl/hibi_mem_core.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_core.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/hibi_mem/rtl/hibi_mem_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_pkg.o

# file dependencies
${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_wrapper.o: ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem.o ${DEST_PROJECTS}/microsimd/ghdl/sram_4en.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem.o: ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_regif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_regfile_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_regfile.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_trigger.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_core.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_ctrl.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_trigger.o:

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_ctrl.o: ${DEST_PROJECTS}/general/ghdl/general_function_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_regif_types_pkg.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_regfile_pkg.o:

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_regif_types_pkg.o:

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_regfile.o: ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_regif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_regfile_pkg.o ${DEST_PROJECTS}/hibi/ghdl/txt_util.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_core.o: ${DEST_PROJECTS}/general/ghdl/general_function_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_link_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/hibi_mem_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/round_robin_arb.o

${DEST_PROJECTS}/${HIBI_MEM_LIB}/ghdl/hibi_mem_pkg.o:

