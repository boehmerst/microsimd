# automatic generated ghdl makefile do not edit manually
# library and module name
CROSSBAR_LIB = microsimd
CROSSBAR_MOD = crossbar

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
CROSSBAR_COMFLAGS = --work=${CROSSBAR_LIB} --workdir=$$DEST_PROJECTS/${CROSSBAR_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
CROSSBAR_ELABFLAGS = --work=${CROSSBAR_LIB} --workdir=$$DEST_PROJECTS/${CROSSBAR_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_pkg.o ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_wrapper.o ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_tb.o ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_tb ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_util_pkg.o ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar.o ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_latch.o

# targets to elaborate entities
${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_tb: ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_tb.o
	@echo "elaborate entity..." crossbar_tb
	@$(ELAB) $(CROSSBAR_ELABFLAGS) crossbar_tb
	@echo -n "#/bin/bash\n\nghdl -r --work=${CROSSBAR_LIB} --workdir=$$DEST_PROJECTS/${CROSSBAR_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 " >> ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_tb.sh
	@echo -n "crossbar_tb " >> ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_tb.sh
	@echo -n '$$' >> ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_tb.sh
	@echo "1" >> ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_tb.sh

# targets to analyze files
${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/crossbar/rtl/crossbar_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(CROSSBAR_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_pkg.o

${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_wrapper.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/crossbar/rtl/crossbar_wrapper.vhd
	@echo "compile file......." $<
	@$(COMP) $(CROSSBAR_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_wrapper.o

${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_tb.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/crossbar/rtl_tb/crossbar_tb.vhd
	@echo "compile file......." $<
	@$(COMP) $(CROSSBAR_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_tb.o

${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_util_pkg.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/crossbar/beh/crossbar_util_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(CROSSBAR_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_util_pkg.o

${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/crossbar/rtl/crossbar.vhd
	@echo "compile file......." $<
	@$(COMP) $(CROSSBAR_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar.o

${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_latch.o: ${GIT_PROJECTS}/vhdl/microsimd/designs/crossbar/rtl/crossbar_latch.vhd
	@echo "compile file......." $<
	@$(COMP) $(CROSSBAR_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_latch.o

# file dependencies
${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_pkg.o:

${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_wrapper.o: ${DEST_PROJECTS}/microsimd/ghdl/crossbar_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/core_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/crossbar_latch.o ${DEST_PROJECTS}/microsimd/ghdl/crossbar.o

${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_tb.o: ${DEST_PROJECTS}/osvvm/ghdl/coveragepkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/crossbar_util_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/crossbar_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/crossbar.o

${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_util_pkg.o: ${DEST_PROJECTS}/microsimd/ghdl/crossbar_pkg.o

${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar.o: ${DEST_PROJECTS}/microsimd/ghdl/crossbar_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/func_pkg.o ${DEST_PROJECTS}/microsimd/ghdl/round_robin_arb.o

${DEST_PROJECTS}/${CROSSBAR_LIB}/ghdl/crossbar_latch.o: ${DEST_PROJECTS}/microsimd/ghdl/crossbar_pkg.o

