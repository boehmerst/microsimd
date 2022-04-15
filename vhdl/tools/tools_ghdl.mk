# automatic generated ghdl makefile do not edit manually
# library and module name
TOOLS_LIB = tools
TOOLS_MOD = tools

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
TOOLS_COMFLAGS = --work=${TOOLS_LIB} --workdir=$$DEST_PROJECTS/${TOOLS_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
TOOLS_ELABFLAGS = --work=${TOOLS_LIB} --workdir=$$DEST_PROJECTS/${TOOLS_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${TOOLS_LIB}/ghdl/fileio.o ${DEST_PROJECTS}/${TOOLS_LIB}/ghdl/fileio_pkg.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${TOOLS_LIB}/ghdl/fileio.o: ${GIT_PROJECTS}/vhdl/tools/rtl/fileio.vhd
	@echo "compile file......." $<
	@$(COMP) $(TOOLS_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${TOOLS_LIB}/ghdl/fileio.o

${DEST_PROJECTS}/${TOOLS_LIB}/ghdl/fileio_pkg.o: ${GIT_PROJECTS}/vhdl/tools/rtl/fileio_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(TOOLS_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${TOOLS_LIB}/ghdl/fileio_pkg.o

# file dependencies
${DEST_PROJECTS}/${TOOLS_LIB}/ghdl/fileio.o: ${DEST_PROJECTS}/tools/ghdl/fileio_pkg.o

${DEST_PROJECTS}/${TOOLS_LIB}/ghdl/fileio_pkg.o:

