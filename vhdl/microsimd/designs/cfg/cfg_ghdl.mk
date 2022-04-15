# automatic generated ghdl makefile do not edit manually
# library and module name
CFG_LIB = microsimd
CFG_MOD = cfg

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
CFG_COMFLAGS = --work=${CFG_LIB} --workdir=$$DEST_PROJECTS/${CFG_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
CFG_ELABFLAGS = --work=${CFG_LIB} --workdir=$$DEST_PROJECTS/${CFG_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${CFG_LIB}/ghdl/custom_inst0.o ${DEST_PROJECTS}/${CFG_LIB}/ghdl/config_pkg.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${CFG_LIB}/ghdl/custom_inst0.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/cfg/rtl/custom_inst0.vhd
	@echo "compile file......." $<
	@$(COMP) $(CFG_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CFG_LIB}/ghdl/custom_inst0.o

${DEST_PROJECTS}/${CFG_LIB}/ghdl/config_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/cfg/rtl/config_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(CFG_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CFG_LIB}/ghdl/config_pkg.o

# file dependencies
${DEST_PROJECTS}/${CFG_LIB}/ghdl/custom_inst0.o: ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/config_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/vec_data_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/cordic_core.o

${DEST_PROJECTS}/${CFG_LIB}/ghdl/config_pkg.o:

