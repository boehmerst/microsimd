# automatic generated ghdl makefile do not edit manually
# library and module name
MISC_LIB = general
MISC_MOD = misc

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
MISC_COMFLAGS = --work=${MISC_LIB} --workdir=$$DEST_PROJECTS/${MISC_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
MISC_ELABFLAGS = --work=${MISC_LIB} --workdir=$$DEST_PROJECTS/${MISC_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${MISC_LIB}/ghdl/general_misc_pkg.o ${DEST_PROJECTS}/${MISC_LIB}/ghdl/sync_ff.o ${DEST_PROJECTS}/${MISC_LIB}/ghdl/graycount.o ${DEST_PROJECTS}/${MISC_LIB}/ghdl/sync_pulse_gen.o ${DEST_PROJECTS}/${MISC_LIB}/ghdl/general_function_pkg.o ${DEST_PROJECTS}/${MISC_LIB}/ghdl/edgedetect.o ${DEST_PROJECTS}/${MISC_LIB}/ghdl/gen_count_async_set.o ${DEST_PROJECTS}/${MISC_LIB}/ghdl/cl_feedback_cdc.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${MISC_LIB}/ghdl/general_misc_pkg.o: ${GIT_PROJECTS}/vhdl/general/misc/rtl/general_misc_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(MISC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MISC_LIB}/ghdl/general_misc_pkg.o

${DEST_PROJECTS}/${MISC_LIB}/ghdl/sync_ff.o: ${GIT_PROJECTS}/vhdl/general/misc/rtl/sync_ff.vhd
	@echo "compile file......." $<
	@$(COMP) $(MISC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MISC_LIB}/ghdl/sync_ff.o

${DEST_PROJECTS}/${MISC_LIB}/ghdl/graycount.o: ${GIT_PROJECTS}/vhdl/general/misc/rtl/graycount.vhd
	@echo "compile file......." $<
	@$(COMP) $(MISC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MISC_LIB}/ghdl/graycount.o

${DEST_PROJECTS}/${MISC_LIB}/ghdl/sync_pulse_gen.o: ${GIT_PROJECTS}/vhdl/general/misc/rtl/sync_pulse_gen.vhd
	@echo "compile file......." $<
	@$(COMP) $(MISC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MISC_LIB}/ghdl/sync_pulse_gen.o

${DEST_PROJECTS}/${MISC_LIB}/ghdl/general_function_pkg.o: ${GIT_PROJECTS}/vhdl/general/misc/rtl/general_function_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(MISC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MISC_LIB}/ghdl/general_function_pkg.o

${DEST_PROJECTS}/${MISC_LIB}/ghdl/edgedetect.o: ${GIT_PROJECTS}/vhdl/general/misc/rtl/edgedetect.vhd
	@echo "compile file......." $<
	@$(COMP) $(MISC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MISC_LIB}/ghdl/edgedetect.o

${DEST_PROJECTS}/${MISC_LIB}/ghdl/gen_count_async_set.o: ${GIT_PROJECTS}/vhdl/general/misc/rtl/gen_count_async_set.vhd
	@echo "compile file......." $<
	@$(COMP) $(MISC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MISC_LIB}/ghdl/gen_count_async_set.o

${DEST_PROJECTS}/${MISC_LIB}/ghdl/cl_feedback_cdc.o: ${GIT_PROJECTS}/vhdl/general/misc/rtl/cl_feedback_cdc.vhd
	@echo "compile file......." $<
	@$(COMP) $(MISC_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MISC_LIB}/ghdl/cl_feedback_cdc.o

# file dependencies
${DEST_PROJECTS}/${MISC_LIB}/ghdl/general_misc_pkg.o: ${DEST_PROJECTS}/general/ghdl/gen_count_async_set.o ${DEST_PROJECTS}/general/ghdl/graycount.o ${DEST_PROJECTS}/general/ghdl/edgedetect.o

${DEST_PROJECTS}/${MISC_LIB}/ghdl/sync_ff.o:

${DEST_PROJECTS}/${MISC_LIB}/ghdl/graycount.o:

${DEST_PROJECTS}/${MISC_LIB}/ghdl/sync_pulse_gen.o: ${DEST_PROJECTS}/general/ghdl/sync_ff.o ${DEST_PROJECTS}/general/ghdl/edgedetect.o

${DEST_PROJECTS}/${MISC_LIB}/ghdl/general_function_pkg.o:

${DEST_PROJECTS}/${MISC_LIB}/ghdl/edgedetect.o:

${DEST_PROJECTS}/${MISC_LIB}/ghdl/gen_count_async_set.o:

${DEST_PROJECTS}/${MISC_LIB}/ghdl/cl_feedback_cdc.o: ${DEST_PROJECTS}/general/ghdl/sync_pulse_gen.o ${DEST_PROJECTS}/general/ghdl/sync_pulse_gen.o

