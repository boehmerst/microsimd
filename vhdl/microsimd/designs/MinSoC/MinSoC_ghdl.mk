# automatic generated ghdl makefile do not edit manually
# library and module name
MINSOC_LIB = microsimd
MINSOC_MOD = MinSoC

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
MINSOC_COMFLAGS = --work=${MINSOC_LIB} --workdir=$$DEST_PROJECTS/${MINSOC_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
MINSOC_ELABFLAGS = --work=${MINSOC_LIB} --workdir=$$DEST_PROJECTS/${MINSOC_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${MINSOC_LIB}/ghdl/minsoc.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${MINSOC_LIB}/ghdl/minsoc.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/MinSoC/rtl/minsoc.vhd
	@echo "compile file......." $<
	@$(COMP) $(MINSOC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MINSOC_LIB}/ghdl/minsoc.o

# file dependencies
${DEST_PROJECTS}/${MINSOC_LIB}/ghdl/minsoc.o: ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/crossbar_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/crossbar_wrapper.o ${DEST_PROJECTS}/microsimd/ghdl/sram_4en.o ${DEST_PROJECTS}/microsimd/ghdl/sram_4en.o ${DEST_PROJECTS}/microsimd/ghdl/fsl_per.o ${DEST_PROJECTS}/microsimd/ghdl/core.o

