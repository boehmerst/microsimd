#!/bin/bash
# This script was automatically generated.

function usage() {
    echo "Usage: $0 [options]"
    echo "Prepares processor design for RTL simulation."
    echo "Options:"
    echo "  -c     Enables code coverage."
    echo "  -h     This helpful help text."
}

# Function to do clean up when this script exits.
function cleanup() {
    true # Dummy command. Can not have empty function.
}
trap cleanup EXIT

OPTIND=1
while getopts "ch" OPTION
do
    case $OPTION in
        c)
            enable_coverage=yes
            ;;
        h)
            usage
            exit 0
            ;;
        ?)  
            echo "Unknown option -$OPTARG"
            usage
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

rm -rf work
vlib work
vmap
if [ "$enable_coverage" = "yes" ]; then
    coverage_opt="+cover=sbcet"
fi

vcom vhdl/tce_util_pkg.vhdl || exit 1
vcom vhdl/tta0_imem_mau_pkg.vhdl || exit 1
vcom vhdl/tta0_globals_pkg.vhdl || exit 1
vcom vhdl/tta0_params_pkg.vhdl || exit 1
vcom vhdl/func_pkg.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/fu_lsu_always_3.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/fu_add_and_eq_gt_gtu_ior_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/fu_vec_lsu.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/fu_vextract_always_1.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/fu_vbcast_always_1.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/fu_add_and_eq_gt_gtu_ior_mac_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/fu_add_and_eq_gt_gtu_ior_mac_mul_shl_shr_shru_sub_sxhw_sxqw_xor_always_1_v4.vhdl || exit 1
vcom vhdl/util_pkg.vhdl || exit 1
vcom $coverage_opt -check_synthesis vhdl/rf_1wr_1rd_always_1_guarded_1.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/rf_1wr_2rd_always_1_guarded_1.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/rf_1wr_1rd_always_1_guarded_0.vhd || exit 1
vcom $coverage_opt -check_synthesis vhdl/tta0.vhdl || exit 1

vcom -check_synthesis gcu_ic/gcu_opcodes_pkg.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/datapath_gate.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/decoder.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/output_socket_3_1.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/idecompressor.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/ifetch.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/input_mux_1.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/input_mux_2.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/input_mux_3.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/output_socket_1_1.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/output_socket_2_1.vhdl || exit 1
vcom $coverage_opt -check_synthesis gcu_ic/ic.vhdl || exit 1

exit 0
