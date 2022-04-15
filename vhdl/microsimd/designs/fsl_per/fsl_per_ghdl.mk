# automatic generated ghdl makefile do not edit manually
# library and module name
FSL_PER_LIB = microsimd
FSL_PER_MOD = fsl_per

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
FSL_PER_COMFLAGS = --work=${FSL_PER_LIB} --workdir=$$DEST_PROJECTS/${FSL_PER_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
FSL_PER_ELABFLAGS = --work=${FSL_PER_LIB} --workdir=$$DEST_PROJECTS/${FSL_PER_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_regif_types_pkg.o ${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per.o ${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_ctrl.o ${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_regfile.o ${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_regfile_pkg.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_regif_types_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/fsl_per/rtl/fsl_per_regif_types_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(FSL_PER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_regif_types_pkg.o

${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/fsl_per/rtl/fsl_per.vhd
	@echo "compile file......." $<
	@$(COMP) $(FSL_PER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per.o

${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_ctrl.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/fsl_per/rtl/fsl_per_ctrl.vhd
	@echo "compile file......." $<
	@$(COMP) $(FSL_PER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_ctrl.o

${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_regfile.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/fsl_per/rtl/fsl_per_regfile.vhd
	@echo "compile file......." $<
	@$(COMP) $(FSL_PER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_regfile.o

${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_regfile_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/fsl_per/rtl/fsl_per_regfile_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(FSL_PER_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_regfile_pkg.o

# file dependencies
${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_regif_types_pkg.o:

${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per.o: ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/fsl_per_regif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/fsl_per_regfile_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/fsl_per_regfile.o ${DEST_PROJECTS}/microsimd/ghdl/fsl_per_ctrl.o

${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_ctrl.o: ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/fsl_per_regif_types_pkg.o

${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_regfile.o: ${DEST_PROJECTS}/microsimd/ghdl/fsl_per_regif_types_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/fsl_per_regfile_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/txt_util.o

${DEST_PROJECTS}/${FSL_PER_LIB}/ghdl/fsl_per_regfile_pkg.o:

