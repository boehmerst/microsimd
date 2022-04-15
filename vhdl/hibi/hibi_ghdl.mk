# automatic generated ghdl makefile do not edit manually
# library and module name
HIBI_LIB = hibi
HIBI_MOD = hibi

# compiler and flags
COMP = ghdl -a
ELAB = ghdl -e
HIBI_COMFLAGS = --work=${HIBI_LIB} --workdir=$$DEST_PROJECTS/${HIBI_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 -Wno-hide
HIBI_ELABFLAGS = --work=${HIBI_LIB} --workdir=$$DEST_PROJECTS/${HIBI_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08

# to have an entry point
all: ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/receiver.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tb_basic_tester.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tb_basic_tester ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/double_fifo_demux_wr.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment_small.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/cfg_mem.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/rx_control.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/basic_tester_rx.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/basic_tester_pkg.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/dyn_arb.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/double_fifo_mux_rd.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_wrapper_r3.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/txt_util.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibiv3_pkg.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tx_control.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/lfsr.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_orbus_6p.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/addr_decoder.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_wrapper_r1.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment_6p.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/cfg_init_pkg.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibiv3_r4.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/fifo_mux_rd.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/transmitter.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_orbus_small.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_bridge_v2.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/addr_data_mux_write.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/addr_data_demux_read.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment_v3.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/basic_tester_tx.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/fifo_demux_wr.o ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_wrapper_r4.o

# targets to elaborate entities
${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tb_basic_tester: ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tb_basic_tester.o
	@echo "elaborate entity..." tb_basic_tester
	@$(ELAB) $(HIBI_ELABFLAGS) tb_basic_tester
	@echo -n "#/bin/bash\n\nghdl -r --work=${HIBI_LIB} --workdir=$$DEST_PROJECTS/${HIBI_LIB}/ghdl  -P${DEST_PROJECTS}/general/ghdl -P${DEST_PROJECTS}/hibi/ghdl -P${DEST_PROJECTS}/microsimd/ghdl -P${DEST_PROJECTS}/osvvm/ghdl -P${DEST_PROJECTS}/tech/ghdl -P${DEST_PROJECTS}/tools/ghdl -P${DEST_PROJECTS}/tta-dsp/ghdl -fexplicit --ieee=synopsys --std=08 " >> ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tb_basic_tester.sh
	@echo -n "tb_basic_tester " >> ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tb_basic_tester.sh
	@echo -n '$$' >> ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tb_basic_tester.sh
	@echo "1" >> ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tb_basic_tester.sh

# targets to analyze files
${DEST_PROJECTS}/${HIBI_LIB}/ghdl/receiver.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/receiver.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/receiver.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tb_basic_tester.o: ${GIT_PROJECTS}/vhdl/hibi/rtl_tb/tb_basic_tester.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tb_basic_tester.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/double_fifo_demux_wr.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/double_fifo_demux_wr.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/double_fifo_demux_wr.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment_small.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/hibi_segment_small.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment_small.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/cfg_mem.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/cfg_mem.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/cfg_mem.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/rx_control.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/rx_control.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/rx_control.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/basic_tester_rx.o: ${GIT_PROJECTS}/vhdl/hibi/beh/basic_tester_rx.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/basic_tester_rx.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/basic_tester_pkg.o: ${GIT_PROJECTS}/vhdl/hibi/beh/basic_tester_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/basic_tester_pkg.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/dyn_arb.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/dyn_arb.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/dyn_arb.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/double_fifo_mux_rd.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/double_fifo_mux_rd.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/double_fifo_mux_rd.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_wrapper_r3.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/hibi_wrapper_r3.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_wrapper_r3.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/txt_util.o: ${GIT_PROJECTS}/vhdl/hibi/beh/txt_util.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/txt_util.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibiv3_pkg.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/hibiv3_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibiv3_pkg.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/hibi_segment.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tx_control.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/tx_control.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tx_control.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/lfsr.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/lfsr.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/lfsr.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_orbus_6p.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/hibi_orbus_6p.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_orbus_6p.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/addr_decoder.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/addr_decoder.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/addr_decoder.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_wrapper_r1.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/hibi_wrapper_r1.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_wrapper_r1.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment_6p.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/hibi_segment_6p.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment_6p.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/cfg_init_pkg.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/cfg_init_pkg.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/cfg_init_pkg.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibiv3_r4.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/hibiv3_r4.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibiv3_r4.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/fifo_mux_rd.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/fifo_mux_rd.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/fifo_mux_rd.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/transmitter.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/transmitter.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/transmitter.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_orbus_small.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/hibi_orbus_small.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_orbus_small.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_bridge_v2.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/hibi_bridge_v2.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_bridge_v2.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/addr_data_mux_write.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/addr_data_mux_write.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/addr_data_mux_write.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/addr_data_demux_read.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/addr_data_demux_read.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/addr_data_demux_read.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment_v3.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/hibi_segment_v3.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment_v3.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/basic_tester_tx.o: ${GIT_PROJECTS}/vhdl/hibi/beh/basic_tester_tx.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/basic_tester_tx.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/fifo_demux_wr.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/fifo_demux_wr.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/fifo_demux_wr.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_wrapper_r4.o: ${GIT_PROJECTS}/vhdl/hibi/rtl/hibi_wrapper_r4.vhd
	@echo "compile file......." $<
	@$(COMP) $(HIBI_COMFLAGS) $<
	@touch ${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_wrapper_r4.o

# file dependencies
${DEST_PROJECTS}/${HIBI_LIB}/ghdl/receiver.o: ${DEST_PROJECTS}/hibi/ghdl/hibiv3_pkg.o ${DEST_PROJECTS}/hibi/ghdl/addr_decoder.o ${DEST_PROJECTS}/hibi/ghdl/rx_control.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tb_basic_tester.o: ${DEST_PROJECTS}/hibi/ghdl/hibiv3_pkg.o ${DEST_PROJECTS}/hibi/ghdl/basic_tester_tx.o ${DEST_PROJECTS}/hibi/ghdl/basic_tester_rx.o ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r4.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/double_fifo_demux_wr.o: ${DEST_PROJECTS}/hibi/ghdl/mixed_clk_fifo_v3.o ${DEST_PROJECTS}/hibi/ghdl/multiclk_fifo_v4.o ${DEST_PROJECTS}/hibi/ghdl/cdc_fifo.o ${DEST_PROJECTS}/hibi/ghdl/fifo.o ${DEST_PROJECTS}/hibi/ghdl/fifo_demux_wr.o ${DEST_PROJECTS}/hibi/ghdl/aif_read_top.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment_small.o: ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r4.o ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r3.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/cfg_mem.o: ${DEST_PROJECTS}/hibi/ghdl/cfg_init_pkg.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/rx_control.o: ${DEST_PROJECTS}/hibi/ghdl/hibiv3_pkg.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/basic_tester_rx.o: ${DEST_PROJECTS}/hibi/ghdl/txt_util.o ${DEST_PROJECTS}/hibi/ghdl/basic_tester_pkg.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/basic_tester_pkg.o:

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/dyn_arb.o: ${DEST_PROJECTS}/hibi/ghdl/lfsr.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/double_fifo_mux_rd.o: ${DEST_PROJECTS}/hibi/ghdl/mixed_clk_fifo_v3.o ${DEST_PROJECTS}/hibi/ghdl/multiclk_fifo_v4.o ${DEST_PROJECTS}/hibi/ghdl/aif_we_top.o ${DEST_PROJECTS}/hibi/ghdl/cdc_fifo.o ${DEST_PROJECTS}/hibi/ghdl/fifo_mux_rd.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_wrapper_r3.o: ${DEST_PROJECTS}/hibi/ghdl/addr_data_mux_write.o ${DEST_PROJECTS}/hibi/ghdl/addr_data_demux_read.o ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r1.o ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r1.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/txt_util.o:

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibiv3_pkg.o:

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment.o: ${DEST_PROJECTS}/hibi/ghdl/hibi_orbus_small.o ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r4.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/tx_control.o: ${DEST_PROJECTS}/hibi/ghdl/hibiv3_pkg.o ${DEST_PROJECTS}/hibi/ghdl/dyn_arb.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/lfsr.o:

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_orbus_6p.o:

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/addr_decoder.o: ${DEST_PROJECTS}/hibi/ghdl/hibiv3_pkg.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_wrapper_r1.o: ${DEST_PROJECTS}/hibi/ghdl/hibiv3_pkg.o ${DEST_PROJECTS}/hibi/ghdl/transmitter.o ${DEST_PROJECTS}/hibi/ghdl/double_fifo_mux_rd.o ${DEST_PROJECTS}/hibi/ghdl/receiver.o ${DEST_PROJECTS}/hibi/ghdl/double_fifo_demux_wr.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment_6p.o: ${DEST_PROJECTS}/hibi/ghdl/hibi_orbus_6p.o ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r4.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/cfg_init_pkg.o:

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibiv3_r4.o: ${DEST_PROJECTS}/hibi/ghdl/hibiv3_pkg.o ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r4.o ${DEST_PROJECTS}/hibi/ghdl/hibi_bridge_v2.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/fifo_mux_rd.o: ${DEST_PROJECTS}/hibi/ghdl/hibiv3_pkg.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/transmitter.o: ${DEST_PROJECTS}/hibi/ghdl/tx_control.o ${DEST_PROJECTS}/hibi/ghdl/cfg_mem.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_orbus_small.o:

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_bridge_v2.o: ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r1.o ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r1.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/addr_data_mux_write.o:

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/addr_data_demux_read.o:

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_segment_v3.o: ${DEST_PROJECTS}/hibi/ghdl/hibiv3_pkg.o ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r4.o ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r3.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/basic_tester_tx.o: ${DEST_PROJECTS}/hibi/ghdl/basic_tester_pkg.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/fifo_demux_wr.o: ${DEST_PROJECTS}/hibi/ghdl/hibiv3_pkg.o

${DEST_PROJECTS}/${HIBI_LIB}/ghdl/hibi_wrapper_r4.o: ${DEST_PROJECTS}/hibi/ghdl/fifo_demux_wr.o ${DEST_PROJECTS}/hibi/ghdl/fifo_mux_rd.o ${DEST_PROJECTS}/hibi/ghdl/hibi_wrapper_r1.o

