# automatic generated ghdl makefile do not edit manually
# library and module name
XBAR_LIB = microsimd
XBAR_MOD = xbar

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
XBAR_COMFLAGS = --work=${XBAR_LIB} --workdir=$$DEST_PROJECTS/${XBAR_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
XBAR_ELABFLAGS = --work=${XBAR_LIB} --workdir=$$DEST_PROJECTS/${XBAR_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${XBAR_LIB}/ghdl/xbar_pkg.o ${DEST_PROJECTS}/${XBAR_LIB}/ghdl/xbar.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${XBAR_LIB}/ghdl/xbar_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/xbar/rtl/xbar_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(XBAR_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${XBAR_LIB}/ghdl/xbar_pkg.o

${DEST_PROJECTS}/${XBAR_LIB}/ghdl/xbar.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/xbar/rtl/xbar.vhd
	@echo "compile file......." $<
	@$(COMP) $(XBAR_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${XBAR_LIB}/ghdl/xbar.o

# file dependencies
${DEST_PROJECTS}/${XBAR_LIB}/ghdl/xbar_pkg.o:

${DEST_PROJECTS}/${XBAR_LIB}/ghdl/xbar.o: ${DEST_PROJECTS}/general/ghdl/general_function_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/xbar_pkg.o

