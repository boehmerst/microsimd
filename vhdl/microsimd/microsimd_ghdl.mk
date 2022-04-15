# automatic generated ghdl makefile do not edit manually
# library and module name
MICROSIMD_LIB = microsimd
MICROSIMD_MOD = microsimd

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
MICROSIMD_COMFLAGS = --work=${MICROSIMD_LIB} --workdir=$$DEST_PROJECTS/${MICROSIMD_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
MICROSIMD_ELABFLAGS = --work=${MICROSIMD_LIB} --workdir=$$DEST_PROJECTS/${MICROSIMD_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/txt_util.o ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/mul32x32_tb.o ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/mul32x32_tb ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/microsimd_core_tb.o ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/microsimd_core_tb

# targets to elaborate entities
${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/mul32x32_tb: ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/mul32x32_tb.o
	@echo "elaborate entity..." mul32x32_tb
	@$(ELAB) $(MICROSIMD_ELABFLAGS) mul32x32_tb
	@echo -n "#/bin/bash\n\nghdl -r --work=${MICROSIMD_LIB} --workdir=$$DEST_PROJECTS/${MICROSIMD_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 " >> ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/mul32x32_tb.sh
	@echo -n "mul32x32_tb " >> ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/mul32x32_tb.sh
	@echo -n '$$' >> ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/mul32x32_tb.sh
	@echo "1" >> ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/mul32x32_tb.sh

${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/microsimd_core_tb: ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/microsimd_core_tb.o
	@echo "elaborate entity..." microsimd_core_tb
	@$(ELAB) $(MICROSIMD_ELABFLAGS) microsimd_core_tb
	@echo -n "#/bin/bash\n\nghdl -r --work=${MICROSIMD_LIB} --workdir=$$DEST_PROJECTS/${MICROSIMD_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 " >> ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/microsimd_core_tb.sh
	@echo -n "microsimd_core_tb " >> ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/microsimd_core_tb.sh
	@echo -n '$$' >> ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/microsimd_core_tb.sh
	@echo "1" >> ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/microsimd_core_tb.sh

# targets to analyze files
${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/txt_util.o: ${GIT_PROJECTS}/vhdl/microsimd/beh/txt_util.vhd
	@echo "compile file......." $<
	@$(COMP) $(MICROSIMD_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/txt_util.o

${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/mul32x32_tb.o: ${GIT_PROJECTS}/vhdl/microsimd/rtl_tb/mul32x32_tb.vhd
	@echo "compile file......." $<
	@$(COMP) $(MICROSIMD_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/mul32x32_tb.o

${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/microsimd_core_tb.o: ${GIT_PROJECTS}/vhdl/microsimd/rtl_tb/microsimd_core_tb.vhd
	@echo "compile file......." $<
	@$(COMP) $(MICROSIMD_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/microsimd_core_tb.o

# file dependencies
${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/txt_util.o:

${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/mul32x32_tb.o: ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/mul32x32.o

${DEST_PROJECTS}/${MICROSIMD_LIB}/ghdl/microsimd_core_tb.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core.o ${DEST_PROJECTS}/microsimd/ghdl/sram.o ${DEST_PROJECTS}/microsimd/ghdl/sram_4en.o ${DEST_PROJECTS}/microsimd/ghdl/sram_2en.o ${DEST_PROJECTS}/microsimd/ghdl/fsl_per.o

