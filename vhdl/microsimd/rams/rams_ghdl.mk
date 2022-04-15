# automatic generated ghdl makefile do not edit manually
# library and module name
RAMS_LIB = microsimd
RAMS_MOD = rams

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
RAMS_COMFLAGS = --work=${RAMS_LIB} --workdir=$$DEST_PROJECTS/${RAMS_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
RAMS_ELABFLAGS = --work=${RAMS_LIB} --workdir=$$DEST_PROJECTS/${RAMS_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${RAMS_LIB}/ghdl/sram_4en.o ${DEST_PROJECTS}/${RAMS_LIB}/ghdl/sram.o ${DEST_PROJECTS}/${RAMS_LIB}/ghdl/sram_2en.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${RAMS_LIB}/ghdl/sram_4en.o: ${GIT_PROJECTS}/vhdl/microsimd/rams/beh/sram_4en.vhd
	@echo "compile file......." $<
	@$(COMP) $(RAMS_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${RAMS_LIB}/ghdl/sram_4en.o

${DEST_PROJECTS}/${RAMS_LIB}/ghdl/sram.o: ${GIT_PROJECTS}/vhdl/microsimd/rams/beh/sram.vhd
	@echo "compile file......." $<
	@$(COMP) $(RAMS_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${RAMS_LIB}/ghdl/sram.o

${DEST_PROJECTS}/${RAMS_LIB}/ghdl/sram_2en.o: ${GIT_PROJECTS}/vhdl/microsimd/rams/beh/sram_2en.vhd
	@echo "compile file......." $<
	@$(COMP) $(RAMS_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${RAMS_LIB}/ghdl/sram_2en.o

# file dependencies
${DEST_PROJECTS}/${RAMS_LIB}/ghdl/sram_4en.o: ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o

${DEST_PROJECTS}/${RAMS_LIB}/ghdl/sram.o:

${DEST_PROJECTS}/${RAMS_LIB}/ghdl/sram_2en.o: ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o

