
/*******************************************************************
*
* CAUTION: This file is automatically generated by libgen.
* Version: Xilinx EDK 9.2.01 EDK_Jm_SP1.2
* DO NOT EDIT.
*
* Copyright (c) 2005 Xilinx, Inc.  All rights reserved. 
* 
* Description: Driver parameters
*
*******************************************************************/

#define STDIN_BASEADDRESS 0x80040000
#define STDOUT_BASEADDRESS 0x80040000

/******************************************************************/


/* Definitions for peripheral LMB_DMEM_CTRLI0 */
#define XPAR_LMB_DMEM_CTRLI0_BASEADDR 0x00000000
#define XPAR_LMB_DMEM_CTRLI0_HIGHADDR 0x0000FFFF


/* Definitions for peripheral LMB_IMEM_CTRLI0 */
#define XPAR_LMB_IMEM_CTRLI0_BASEADDR 0x00000000
#define XPAR_LMB_IMEM_CTRLI0_HIGHADDR 0x0000FFFF


/* Definitions for peripheral OPB_BRAM_IF_CNTLR_0 */
#define XPAR_OPB_BRAM_IF_CNTLR_0_BASEADDR 0x80010000
#define XPAR_OPB_BRAM_IF_CNTLR_0_HIGHADDR 0x8001ffff


/******************************************************************/

/* Definitions for driver OPBARB */
#define XPAR_XOPBARB_NUM_INSTANCES 1

/* Definitions for peripheral OPB_V20_0 */
#define XPAR_OPB_V20_0_BASEADDR 0xFFFFFFFF
#define XPAR_OPB_V20_0_HIGHADDR 0x00000000
#define XPAR_OPB_V20_0_DEVICE_ID 0
#define XPAR_OPB_V20_0_NUM_MASTERS 3


/******************************************************************/


/* Definitions for peripheral OPB_SDRAMI0 */
#define XPAR_OPB_SDRAMI0_BASEADDR 0xA0000000
#define XPAR_OPB_SDRAMI0_HIGHADDR 0xAFFFFFFF


/******************************************************************/

/* Definitions for driver DMACENTRAL */
#define XPAR_XDMACENTRAL_NUM_INSTANCES 1

/* Definitions for peripheral OPB_DMAI0 */
#define XPAR_OPB_DMAI0_DEVICE_ID 0
#define XPAR_OPB_DMAI0_BASEADDR 0x20000000
#define XPAR_OPB_DMAI0_HIGHADDR 0x2000FFFF
#define XPAR_OPB_DMAI0_READ_OPTIONAL_REGS 0


/******************************************************************/


/* Canonical definitions for peripheral OPB_DMAI0 */
#define XPAR_DMACENTRAL_0_DEVICE_ID XPAR_OPB_DMAI0_DEVICE_ID
#define XPAR_DMACENTRAL_0_BASEADDR 0x20000000
#define XPAR_DMACENTRAL_0_HIGHADDR 0x2000FFFF
#define XPAR_DMACENTRAL_0_READ_OPTIONAL_REGS 0


/******************************************************************/

/* Definitions for driver UARTLITE */
#define XPAR_XUARTLITE_NUM_INSTANCES 1

/* Definitions for peripheral MDMI0 */
#define XPAR_MDMI0_BASEADDR 0x80040000
#define XPAR_MDMI0_HIGHADDR 0x8004FFFF
#define XPAR_MDMI0_DEVICE_ID 0
#define XPAR_MDMI0_BAUDRATE 0
#define XPAR_MDMI0_USE_PARITY 0
#define XPAR_MDMI0_ODD_PARITY 0
#define XPAR_MDMI0_DATA_BITS 0


/******************************************************************/


/* Canonical definitions for peripheral MDMI0 */
#define XPAR_UARTLITE_0_DEVICE_ID XPAR_MDMI0_DEVICE_ID
#define XPAR_UARTLITE_0_BASEADDR 0x80040000
#define XPAR_UARTLITE_0_HIGHADDR 0x8004FFFF
#define XPAR_UARTLITE_0_BAUDRATE 0
#define XPAR_UARTLITE_0_USE_PARITY 0
#define XPAR_UARTLITE_0_ODD_PARITY 0
#define XPAR_UARTLITE_0_DATA_BITS 0


/******************************************************************/

#define XPAR_CPU_CORE_CLOCK_FREQ_HZ 125000000

/******************************************************************/


/* Definitions for peripheral MICROBLAZE_0 */
#define XPAR_MICROBLAZE_0_SCO 0
#define XPAR_MICROBLAZE_0_DATA_SIZE 32
#define XPAR_MICROBLAZE_0_DYNAMIC_BUS_SIZING 1
#define XPAR_MICROBLAZE_0_AREA_OPTIMIZED 0
#define XPAR_MICROBLAZE_0_INTERCONNECT 0
#define XPAR_MICROBLAZE_0_DPLB_DWIDTH 32
#define XPAR_MICROBLAZE_0_DPLB_NATIVE_DWIDTH 32
#define XPAR_MICROBLAZE_0_DPLB_BURST_EN 0
#define XPAR_MICROBLAZE_0_DPLB_P2P 0
#define XPAR_MICROBLAZE_0_IPLB_DWIDTH 32
#define XPAR_MICROBLAZE_0_IPLB_NATIVE_DWIDTH 32
#define XPAR_MICROBLAZE_0_IPLB_BURST_EN 0
#define XPAR_MICROBLAZE_0_IPLB_P2P 0
#define XPAR_MICROBLAZE_0_D_PLB 0
#define XPAR_MICROBLAZE_0_D_OPB 1
#define XPAR_MICROBLAZE_0_D_LMB 1
#define XPAR_MICROBLAZE_0_I_PLB 0
#define XPAR_MICROBLAZE_0_I_OPB 1
#define XPAR_MICROBLAZE_0_I_LMB 1
#define XPAR_MICROBLAZE_0_USE_MSR_INSTR 1
#define XPAR_MICROBLAZE_0_USE_PCMP_INSTR 1
#define XPAR_MICROBLAZE_0_USE_BARREL 0
#define XPAR_MICROBLAZE_0_USE_DIV 0
#define XPAR_MICROBLAZE_0_USE_HW_MUL 1
#define XPAR_MICROBLAZE_0_USE_FPU 0
#define XPAR_MICROBLAZE_0_UNALIGNED_EXCEPTIONS 0
#define XPAR_MICROBLAZE_0_ILL_OPCODE_EXCEPTION 0
#define XPAR_MICROBLAZE_0_IOPB_BUS_EXCEPTION 0
#define XPAR_MICROBLAZE_0_DOPB_BUS_EXCEPTION 0
#define XPAR_MICROBLAZE_0_IPLB_BUS_EXCEPTION 0
#define XPAR_MICROBLAZE_0_DPLB_BUS_EXCEPTION 0
#define XPAR_MICROBLAZE_0_DIV_ZERO_EXCEPTION 0
#define XPAR_MICROBLAZE_0_FPU_EXCEPTION 0
#define XPAR_MICROBLAZE_0_FSL_EXCEPTION 0
#define XPAR_MICROBLAZE_0_PVR 0
#define XPAR_MICROBLAZE_0_PVR_USER1 0x00
#define XPAR_MICROBLAZE_0_PVR_USER2 0x00000000
#define XPAR_MICROBLAZE_0_DEBUG_ENABLED 0
#define XPAR_MICROBLAZE_0_NUMBER_OF_PC_BRK 1
#define XPAR_MICROBLAZE_0_NUMBER_OF_RD_ADDR_BRK 0
#define XPAR_MICROBLAZE_0_NUMBER_OF_WR_ADDR_BRK 0
#define XPAR_MICROBLAZE_0_INTERRUPT_IS_EDGE 0
#define XPAR_MICROBLAZE_0_EDGE_IS_POSITIVE 1
#define XPAR_MICROBLAZE_0_RESET_MSR 0x00000000
#define XPAR_MICROBLAZE_0_OPCODE_0X0_ILLEGAL 0
#define XPAR_MICROBLAZE_0_FSL_LINKS 0
#define XPAR_MICROBLAZE_0_FSL_DATA_SIZE 32
#define XPAR_MICROBLAZE_0_USE_EXTENDED_FSL_INSTR 0
#define XPAR_MICROBLAZE_0_ICACHE_BASEADDR 0x00000000
#define XPAR_MICROBLAZE_0_ICACHE_HIGHADDR 0x3FFFFFFF
#define XPAR_MICROBLAZE_0_USE_ICACHE 0
#define XPAR_MICROBLAZE_0_ALLOW_ICACHE_WR 1
#define XPAR_MICROBLAZE_0_ADDR_TAG_BITS 0
#define XPAR_MICROBLAZE_0_CACHE_BYTE_SIZE 8192
#define XPAR_MICROBLAZE_0_ICACHE_USE_FSL 1
#define XPAR_MICROBLAZE_0_ICACHE_LINE_LEN 4
#define XPAR_MICROBLAZE_0_DCACHE_BASEADDR 0x00000000
#define XPAR_MICROBLAZE_0_DCACHE_HIGHADDR 0x3FFFFFFF
#define XPAR_MICROBLAZE_0_USE_DCACHE 0
#define XPAR_MICROBLAZE_0_ALLOW_DCACHE_WR 1
#define XPAR_MICROBLAZE_0_DCACHE_ADDR_TAG 0
#define XPAR_MICROBLAZE_0_DCACHE_BYTE_SIZE 8192
#define XPAR_MICROBLAZE_0_DCACHE_USE_FSL 1
#define XPAR_MICROBLAZE_0_DCACHE_LINE_LEN 4
#define XPAR_MICROBLAZE_0_USE_MMU 0
#define XPAR_MICROBLAZE_0_MMU_DTLB_SIZE 4
#define XPAR_MICROBLAZE_0_MMU_ITLB_SIZE 2
#define XPAR_MICROBLAZE_0_MMU_TLB_ACCESS 3
#define XPAR_MICROBLAZE_0_MMU_ZONES 16

/******************************************************************/

#define XPAR_CPU_ID 0
#define XPAR_MICROBLAZE_ID 0
#define XPAR_MICROBLAZE_CORE_CLOCK_FREQ_HZ 125000000
#define XPAR_MICROBLAZE_SCO 0
#define XPAR_MICROBLAZE_DATA_SIZE 32
#define XPAR_MICROBLAZE_DYNAMIC_BUS_SIZING 1
#define XPAR_MICROBLAZE_AREA_OPTIMIZED 0
#define XPAR_MICROBLAZE_INTERCONNECT 0
#define XPAR_MICROBLAZE_DPLB_DWIDTH 32
#define XPAR_MICROBLAZE_DPLB_NATIVE_DWIDTH 32
#define XPAR_MICROBLAZE_DPLB_BURST_EN 0
#define XPAR_MICROBLAZE_DPLB_P2P 0
#define XPAR_MICROBLAZE_IPLB_DWIDTH 32
#define XPAR_MICROBLAZE_IPLB_NATIVE_DWIDTH 32
#define XPAR_MICROBLAZE_IPLB_BURST_EN 0
#define XPAR_MICROBLAZE_IPLB_P2P 0
#define XPAR_MICROBLAZE_D_PLB 0
#define XPAR_MICROBLAZE_D_OPB 1
#define XPAR_MICROBLAZE_D_LMB 1
#define XPAR_MICROBLAZE_I_PLB 0
#define XPAR_MICROBLAZE_I_OPB 1
#define XPAR_MICROBLAZE_I_LMB 1
#define XPAR_MICROBLAZE_USE_MSR_INSTR 1
#define XPAR_MICROBLAZE_USE_PCMP_INSTR 1
#define XPAR_MICROBLAZE_USE_BARREL 0
#define XPAR_MICROBLAZE_USE_DIV 0
#define XPAR_MICROBLAZE_USE_HW_MUL 1
#define XPAR_MICROBLAZE_USE_FPU 0
#define XPAR_MICROBLAZE_UNALIGNED_EXCEPTIONS 0
#define XPAR_MICROBLAZE_ILL_OPCODE_EXCEPTION 0
#define XPAR_MICROBLAZE_IOPB_BUS_EXCEPTION 0
#define XPAR_MICROBLAZE_DOPB_BUS_EXCEPTION 0
#define XPAR_MICROBLAZE_IPLB_BUS_EXCEPTION 0
#define XPAR_MICROBLAZE_DPLB_BUS_EXCEPTION 0
#define XPAR_MICROBLAZE_DIV_ZERO_EXCEPTION 0
#define XPAR_MICROBLAZE_FPU_EXCEPTION 0
#define XPAR_MICROBLAZE_FSL_EXCEPTION 0
#define XPAR_MICROBLAZE_PVR 0
#define XPAR_MICROBLAZE_PVR_USER1 0x00
#define XPAR_MICROBLAZE_PVR_USER2 0x00000000
#define XPAR_MICROBLAZE_DEBUG_ENABLED 0
#define XPAR_MICROBLAZE_NUMBER_OF_PC_BRK 1
#define XPAR_MICROBLAZE_NUMBER_OF_RD_ADDR_BRK 0
#define XPAR_MICROBLAZE_NUMBER_OF_WR_ADDR_BRK 0
#define XPAR_MICROBLAZE_INTERRUPT_IS_EDGE 0
#define XPAR_MICROBLAZE_EDGE_IS_POSITIVE 1
#define XPAR_MICROBLAZE_RESET_MSR 0x00000000
#define XPAR_MICROBLAZE_OPCODE_0X0_ILLEGAL 0
#define XPAR_MICROBLAZE_FSL_LINKS 0
#define XPAR_MICROBLAZE_FSL_DATA_SIZE 32
#define XPAR_MICROBLAZE_USE_EXTENDED_FSL_INSTR 0
#define XPAR_MICROBLAZE_ICACHE_BASEADDR 0x00000000
#define XPAR_MICROBLAZE_ICACHE_HIGHADDR 0x3FFFFFFF
#define XPAR_MICROBLAZE_USE_ICACHE 0
#define XPAR_MICROBLAZE_ALLOW_ICACHE_WR 1
#define XPAR_MICROBLAZE_ADDR_TAG_BITS 0
#define XPAR_MICROBLAZE_CACHE_BYTE_SIZE 8192
#define XPAR_MICROBLAZE_ICACHE_USE_FSL 1
#define XPAR_MICROBLAZE_ICACHE_LINE_LEN 4
#define XPAR_MICROBLAZE_DCACHE_BASEADDR 0x00000000
#define XPAR_MICROBLAZE_DCACHE_HIGHADDR 0x3FFFFFFF
#define XPAR_MICROBLAZE_USE_DCACHE 0
#define XPAR_MICROBLAZE_ALLOW_DCACHE_WR 1
#define XPAR_MICROBLAZE_DCACHE_ADDR_TAG 0
#define XPAR_MICROBLAZE_DCACHE_BYTE_SIZE 8192
#define XPAR_MICROBLAZE_DCACHE_USE_FSL 1
#define XPAR_MICROBLAZE_DCACHE_LINE_LEN 4
#define XPAR_MICROBLAZE_USE_MMU 0
#define XPAR_MICROBLAZE_MMU_DTLB_SIZE 4
#define XPAR_MICROBLAZE_MMU_ITLB_SIZE 2
#define XPAR_MICROBLAZE_MMU_TLB_ACCESS 3
#define XPAR_MICROBLAZE_MMU_ZONES 16
#define XPAR_MICROBLAZE_HW_VER "7.00.a"

/******************************************************************/

