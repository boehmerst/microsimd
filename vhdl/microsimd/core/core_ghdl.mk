# automatic generated ghdl makefile do not edit manually
# library and module name
CORE_LIB = microsimd
CORE_MOD = core

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
CORE_COMFLAGS = --work=${CORE_LIB} --workdir=$$DEST_PROJECTS/${CORE_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
CORE_ELABFLAGS = --work=${CORE_LIB} --workdir=$$DEST_PROJECTS/${CORE_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${CORE_LIB}/ghdl/lsu.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/execute.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/simd_mul.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/fsl_ctrl.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/fetch.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/dsram.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/mul32x32.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/simd_custom.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/mul_inferred.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/mem.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/gprf.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/core.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/simd_execute.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/vecrf.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/decode.o ${DEST_PROJECTS}/${CORE_LIB}/ghdl/shuffle.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${CORE_LIB}/ghdl/lsu.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/lsu.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/lsu.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/execute.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/execute.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/execute.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/simd_mul.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/simd_mul.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/simd_mul.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/fsl_ctrl.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/fsl_ctrl.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/fsl_ctrl.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/fetch.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/fetch.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/fetch.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/dsram.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/dsram.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/dsram.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/mul32x32.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/mul32x32.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/mul32x32.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/simd_custom.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/simd_custom.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/simd_custom.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/mul_inferred.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/mul_inferred.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/mul_inferred.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/mem.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/mem.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/mem.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/gprf.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/gprf.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/gprf.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/core.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/core.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/core.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/simd_execute.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/simd_execute.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/simd_execute.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/vecrf.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/vecrf.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/vecrf.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/decode.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/decode.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/decode.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/shuffle.o: ${GIT_PROJECTS}/vhdl/microsimd/core/rtl/shuffle.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORE_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORE_LIB}/ghdl/shuffle.o

# file dependencies
${DEST_PROJECTS}/${CORE_LIB}/ghdl/lsu.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/execute.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/fsl_ctrl.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/simd_mul.o: ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/mul32x32.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/fsl_ctrl.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/fetch.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/dsram.o:

${DEST_PROJECTS}/${CORE_LIB}/ghdl/mul32x32.o: ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/mul_inferred.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/simd_custom.o: ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/custom_inst0.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/mul_inferred.o: ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/mem.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/gprf.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/dsram.o ${DEST_PROJECTS}/microsimd/ghdl/dsram.o ${DEST_PROJECTS}/microsimd/ghdl/dsram.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/core.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/fetch.o ${DEST_PROJECTS}/microsimd/ghdl/decode.o ${DEST_PROJECTS}/microsimd/ghdl/execute.o ${DEST_PROJECTS}/microsimd/ghdl/simd_execute.o ${DEST_PROJECTS}/microsimd/ghdl/mem.o ${DEST_PROJECTS}/microsimd/ghdl/lsu.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/simd_execute.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/simd_addsub32_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/simd_shift32_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/shuffle.o ${DEST_PROJECTS}/microsimd/ghdl/simd_mul.o ${DEST_PROJECTS}/microsimd/ghdl/simd_custom.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/vecrf.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/dsram.o ${DEST_PROJECTS}/microsimd/ghdl/dsram.o ${DEST_PROJECTS}/microsimd/ghdl/dsram.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/decode.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/inst_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/gprf.o ${DEST_PROJECTS}/microsimd/ghdl/vecrf.o

${DEST_PROJECTS}/${CORE_LIB}/ghdl/shuffle.o: ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o

