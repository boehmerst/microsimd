# automatic generated ghdl makefile do not edit manually
# library and module name
TECH_LIB = tech
TECH_MOD = tech

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
TECH_COMFLAGS = --work=${TECH_LIB} --workdir=$$DEST_PROJECTS/${TECH_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
TECH_ELABFLAGS = --work=${TECH_LIB} --workdir=$$DEST_PROJECTS/${TECH_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${TECH_LIB}/ghdl/tech_constants_pkg.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${TECH_LIB}/ghdl/tech_constants_pkg.o: ${GIT_PROJECTS}/vhdl/tech/rtl/tech_constants_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(TECH_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${TECH_LIB}/ghdl/tech_constants_pkg.o

# file dependencies
${DEST_PROJECTS}/${TECH_LIB}/ghdl/tech_constants_pkg.o:

