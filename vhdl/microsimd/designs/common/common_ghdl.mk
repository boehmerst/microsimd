# automatic generated ghdl makefile do not edit manually
# library and module name
COMMON_LIB = microsimd
COMMON_MOD = common

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
COMMON_COMFLAGS = --work=${COMMON_LIB} --workdir=$$DEST_PROJECTS/${COMMON_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
COMMON_ELABFLAGS = --work=${COMMON_LIB} --workdir=$$DEST_PROJECTS/${COMMON_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${COMMON_LIB}/ghdl/round_robin_arb.o ${DEST_PROJECTS}/${COMMON_LIB}/ghdl/hibi_link_pkg.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${COMMON_LIB}/ghdl/round_robin_arb.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/common/rtl/round_robin_arb.vhd
	@echo "compile file......." $<
	@$(COMP) $(COMMON_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${COMMON_LIB}/ghdl/round_robin_arb.o

${DEST_PROJECTS}/${COMMON_LIB}/ghdl/hibi_link_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/common/rtl/hibi_link_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(COMMON_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${COMMON_LIB}/ghdl/hibi_link_pkg.o

# file dependencies
${DEST_PROJECTS}/${COMMON_LIB}/ghdl/round_robin_arb.o:

${DEST_PROJECTS}/${COMMON_LIB}/ghdl/hibi_link_pkg.o: ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o

