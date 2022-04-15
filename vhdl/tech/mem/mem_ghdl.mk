# automatic generated ghdl makefile do not edit manually
# library and module name
MEM_LIB = tech
MEM_MOD = mem

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
MEM_COMFLAGS = --work=${MEM_LIB} --workdir=$$DEST_PROJECTS/${MEM_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
MEM_ELABFLAGS = --work=${MEM_LIB} --workdir=$$DEST_PROJECTS/${MEM_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_sync_mem_beh.o ${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_sync_mem.o ${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_async_mem_beh.o ${DEST_PROJECTS}/${MEM_LIB}/ghdl/mem_pkg.o ${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_2wr_sync_mem_beh.o ${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_async_mem.o ${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_async_mem_beh.o ${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_sync_mem_beh.o ${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_async_mem.o ${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_sync_mem.o ${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_2wr_sync_mem.o

# targets to elaborate entities
# targets to analyze files
${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_sync_mem_beh.o: ${GIT_PROJECTS}/vhdl/tech/mem/rtl/sp_sync_mem_beh.vhd
	@echo "compile file......." $<
	@$(COMP) $(MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_sync_mem_beh.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_sync_mem.o: ${GIT_PROJECTS}/vhdl/tech/mem/rtl/dp_sync_mem.vhd
	@echo "compile file......." $<
	@$(COMP) $(MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_sync_mem.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_async_mem_beh.o: ${GIT_PROJECTS}/vhdl/tech/mem/rtl/sp_async_mem_beh.vhd
	@echo "compile file......." $<
	@$(COMP) $(MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_async_mem_beh.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/mem_pkg.o: ${GIT_PROJECTS}/vhdl/tech/mem/rtl/mem_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MEM_LIB}/ghdl/mem_pkg.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_2wr_sync_mem_beh.o: ${GIT_PROJECTS}/vhdl/tech/mem/rtl/dp_2wr_sync_mem_beh.vhd
	@echo "compile file......." $<
	@$(COMP) $(MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_2wr_sync_mem_beh.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_async_mem.o: ${GIT_PROJECTS}/vhdl/tech/mem/rtl/dp_async_mem.vhd
	@echo "compile file......." $<
	@$(COMP) $(MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_async_mem.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_async_mem_beh.o: ${GIT_PROJECTS}/vhdl/tech/mem/rtl/dp_async_mem_beh.vhd
	@echo "compile file......." $<
	@$(COMP) $(MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_async_mem_beh.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_sync_mem_beh.o: ${GIT_PROJECTS}/vhdl/tech/mem/rtl/dp_sync_mem_beh.vhd
	@echo "compile file......." $<
	@$(COMP) $(MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_sync_mem_beh.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_async_mem.o: ${GIT_PROJECTS}/vhdl/tech/mem/rtl/sp_async_mem.vhd
	@echo "compile file......." $<
	@$(COMP) $(MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_async_mem.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_sync_mem.o: ${GIT_PROJECTS}/vhdl/tech/mem/rtl/sp_sync_mem.vhd
	@echo "compile file......." $<
	@$(COMP) $(MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_sync_mem.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_2wr_sync_mem.o: ${GIT_PROJECTS}/vhdl/tech/mem/rtl/dp_2wr_sync_mem.vhd
	@echo "compile file......." $<
	@$(COMP) $(MEM_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_2wr_sync_mem.o

# file dependencies
${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_sync_mem_beh.o:

${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_sync_mem.o: ${DEST_PROJECTS}/tech/ghdl/tech_constants_pkg.o ${DEST_PROJECTS}/tech/ghdl/dp_sync_mem_beh.o ${DEST_PROJECTS}/tech/ghdl/dp_sync_mem_beh.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_async_mem_beh.o:

${DEST_PROJECTS}/${MEM_LIB}/ghdl/mem_pkg.o: ${DEST_PROJECTS}/tech/ghdl/sp_sync_mem.o ${DEST_PROJECTS}/tech/ghdl/sp_async_mem.o ${DEST_PROJECTS}/tech/ghdl/dp_async_mem.o ${DEST_PROJECTS}/tech/ghdl/dp_sync_mem.o ${DEST_PROJECTS}/tech/ghdl/dp_2wr_sync_mem.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_2wr_sync_mem_beh.o:

${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_async_mem.o: ${DEST_PROJECTS}/tech/ghdl/tech_constants_pkg.o ${DEST_PROJECTS}/tech/ghdl/dp_async_mem_beh.o ${DEST_PROJECTS}/tech/ghdl/dp_async_mem_beh.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_async_mem_beh.o:

${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_sync_mem_beh.o:

${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_async_mem.o: ${DEST_PROJECTS}/tech/ghdl/tech_constants_pkg.o ${DEST_PROJECTS}/tech/ghdl/sp_async_mem_beh.o ${DEST_PROJECTS}/tech/ghdl/sp_async_mem_beh.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/sp_sync_mem.o: ${DEST_PROJECTS}/tech/ghdl/tech_constants_pkg.o ${DEST_PROJECTS}/tech/ghdl/sp_sync_mem_beh.o ${DEST_PROJECTS}/tech/ghdl/sp_sync_mem_beh.o

${DEST_PROJECTS}/${MEM_LIB}/ghdl/dp_2wr_sync_mem.o: ${DEST_PROJECTS}/tech/ghdl/tech_constants_pkg.o ${DEST_PROJECTS}/tech/ghdl/dp_2wr_sync_mem_beh.o ${DEST_PROJECTS}/tech/ghdl/dp_2wr_sync_mem_beh.o

