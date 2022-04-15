# automatic generated ghdl makefile do not edit manually
# library and module name
OSVVM_LIB = osvvm
OSVVM_MOD = osvvm

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
OSVVM_COMFLAGS = --work=${OSVVM_LIB} --workdir=$$DEST_PROJECTS/${OSVVM_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
OSVVM_ELABFLAGS = --work=${OSVVM_LIB} --workdir=$$DEST_PROJECTS/${OSVVM_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/messagepkg.o ${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/coveragepkg.o ${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/randombasepkg.o ${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/sortlistpkg_int.o ${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/randompkg.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/messagepkg.o: ${GIT_PROJECTS}/vhdl/osvvm/rtl/MessagePkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(OSVVM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/messagepkg.o

${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/coveragepkg.o: ${GIT_PROJECTS}/vhdl/osvvm/rtl/CoveragePkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(OSVVM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/coveragepkg.o

${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/randombasepkg.o: ${GIT_PROJECTS}/vhdl/osvvm/rtl/RandomBasePkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(OSVVM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/randombasepkg.o

${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/sortlistpkg_int.o: ${GIT_PROJECTS}/vhdl/osvvm/rtl/SortListPkg_int.vhd
	@echo "compile file......." $<
	@$(COMP) $(OSVVM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/sortlistpkg_int.o

${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/randompkg.o: ${GIT_PROJECTS}/vhdl/osvvm/rtl/RandomPkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(OSVVM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/randompkg.o

# file dependencies
${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/messagepkg.o:

${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/coveragepkg.o: ${DEST_PROJECTS}/osvvm/ghdl/randombasepkg.o ${DEST_PROJECTS}/osvvm/ghdl/randompkg.o ${DEST_PROJECTS}/osvvm/ghdl/messagepkg.o

${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/randombasepkg.o:

${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/sortlistpkg_int.o:

${DEST_PROJECTS}/${OSVVM_LIB}/ghdl/randompkg.o: ${DEST_PROJECTS}/osvvm/ghdl/randombasepkg.o ${DEST_PROJECTS}/osvvm/ghdl/sortlistpkg_int.o

