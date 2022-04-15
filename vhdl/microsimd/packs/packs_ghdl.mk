# automatic generated ghdl makefile do not edit manually
# library and module name
PACKS_LIB = microsimd
PACKS_MOD = packs

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
PACKS_COMFLAGS = --work=${PACKS_LIB} --workdir=$$DEST_PROJECTS/${PACKS_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
PACKS_ELABFLAGS = --work=${PACKS_LIB} --workdir=$$DEST_PROJECTS/${PACKS_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${PACKS_LIB}/ghdl/simd_shift32_pkg.o ${DEST_PROJECTS}/${PACKS_LIB}/ghdl/simd_addsub32_pkg.o ${DEST_PROJECTS}/${PACKS_LIB}/ghdl/core_pkg.o ${DEST_PROJECTS}/${PACKS_LIB}/ghdl/vec_data_pkg.o ${DEST_PROJECTS}/${PACKS_LIB}/ghdl/func_pkg.o ${DEST_PROJECTS}/${PACKS_LIB}/ghdl/inst_pkg.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${PACKS_LIB}/ghdl/simd_shift32_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/packs/rtl/simd_shift32_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(PACKS_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${PACKS_LIB}/ghdl/simd_shift32_pkg.o

${DEST_PROJECTS}/${PACKS_LIB}/ghdl/simd_addsub32_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/packs/rtl/simd_addsub32_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(PACKS_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${PACKS_LIB}/ghdl/simd_addsub32_pkg.o

${DEST_PROJECTS}/${PACKS_LIB}/ghdl/core_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/packs/rtl/core_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(PACKS_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${PACKS_LIB}/ghdl/core_pkg.o

${DEST_PROJECTS}/${PACKS_LIB}/ghdl/vec_data_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/packs/rtl/vec_data_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(PACKS_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${PACKS_LIB}/ghdl/vec_data_pkg.o

${DEST_PROJECTS}/${PACKS_LIB}/ghdl/func_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/packs/rtl/func_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(PACKS_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${PACKS_LIB}/ghdl/func_pkg.o

${DEST_PROJECTS}/${PACKS_LIB}/ghdl/inst_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/packs/rtl/inst_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(PACKS_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${PACKS_LIB}/ghdl/inst_pkg.o

# file dependencies
${DEST_PROJECTS}/${PACKS_LIB}/ghdl/simd_shift32_pkg.o: ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o

${DEST_PROJECTS}/${PACKS_LIB}/ghdl/simd_addsub32_pkg.o: ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o

${DEST_PROJECTS}/${PACKS_LIB}/ghdl/core_pkg.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o

${DEST_PROJECTS}/${PACKS_LIB}/ghdl/vec_data_pkg.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o

${DEST_PROJECTS}/${PACKS_LIB}/ghdl/func_pkg.o:

${DEST_PROJECTS}/${PACKS_LIB}/ghdl/inst_pkg.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o

