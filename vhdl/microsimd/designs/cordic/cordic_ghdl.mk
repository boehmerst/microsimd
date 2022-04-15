# automatic generated ghdl makefile do not edit manually
# library and module name
CORDIC_LIB = microsimd
CORDIC_MOD = cordic

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
CORDIC_COMFLAGS = --work=${CORDIC_LIB} --workdir=$$DEST_PROJECTS/${CORDIC_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
CORDIC_ELABFLAGS = --work=${CORDIC_LIB} --workdir=$$DEST_PROJECTS/${CORDIC_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${CORDIC_LIB}/ghdl/cordic_kernel.o ${DEST_PROJECTS}/${CORDIC_LIB}/ghdl/cordic_core.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${CORDIC_LIB}/ghdl/cordic_kernel.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/cordic/rtl/cordic_kernel.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORDIC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORDIC_LIB}/ghdl/cordic_kernel.o

${DEST_PROJECTS}/${CORDIC_LIB}/ghdl/cordic_core.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/cordic/rtl/cordic_core.vhd
	@echo "compile file......." $<
	@$(COMP) $(CORDIC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CORDIC_LIB}/ghdl/cordic_core.o

# file dependencies
${DEST_PROJECTS}/${CORDIC_LIB}/ghdl/cordic_kernel.o:

${DEST_PROJECTS}/${CORDIC_LIB}/ghdl/cordic_core.o: ${DEST_PROJECTS}/microsimd/ghdl/cordic_kernel.o

