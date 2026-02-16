//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
// (C) COPYRIGHT 2006-2007 ARM Limited.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
// File Name  : pl230_undefs.v
// Checked In : $Date: 2007-03-15 15:17:04 +0530 (Thu, 15 Mar 2007) $
// Revision   : $Revision: 10866 $
// State      : $state: PL230-DE-98007-r0p0-02rel0 $
//
//-----------------------------------------------------------------------------
// Purpose : Undefine peripheral specific macro definitions
//
//-----------------------------------------------------------------------------






// Set the number of channels implemented
`undef PL230_CHNLS
`undef PL230_CHNL_BITS
`undef PL230_ONE_CHNL

// Include Integration Test Logic
`undef PL230_INCLUDE_TEST


// AHB Interface
`undef  PL230_AHB_TRANS_IDLE
`undef  PL230_AHB_TRANS_NONSEQ
`undef  PL230_AHB_READ
`undef  PL230_AHB_WRITE
`undef  PL230_AHB_SIZE_BYTE
`undef  PL230_AHB_SIZE_HWORD
`undef  PL230_AHB_SIZE_WORD

// PrimeCell Configuration
`undef  PL230_PERIPH_ID_0
`undef  PL230_PERIPH_ID_1
`undef  PL230_PERIPH_ID_2
`undef  PL230_PERIPH_ID_3
`undef  PL230_PERIPH_ID_4
`undef  PL230_PCELL_ID_0
`undef  PL230_PCELL_ID_1
`undef  PL230_PCELL_ID_2
`undef  PL230_PCELL_ID_3

// Memory Mapped Registers
//  Controller Configuration Registers
`undef  PL230_ADDR_DMA_STATUS
`undef  PL230_ADDR_DMA_CFG
`undef  PL230_ADDR_CTRL_BASE_PTR
`undef  PL230_ADDR_ALT_CTRL_BASE_PTR
`undef  PL230_ADDR_DMA_WAITONREQ_STATUS
`undef  PL230_ADDR_CHNL_SW_REQUEST
`undef  PL230_ADDR_CHNL_USEBURST_SET
`undef  PL230_ADDR_CHNL_USEBURST_CLR
`undef  PL230_ADDR_CHNL_REQ_MASK_SET
`undef  PL230_ADDR_CHNL_REQ_MASK_CLR
`undef  PL230_ADDR_CHNL_ENABLE_SET
`undef  PL230_ADDR_CHNL_ENABLE_CLR
`undef  PL230_ADDR_CHNL_PRI_ALT_SET
`undef  PL230_ADDR_CHNL_PRI_ALT_CLR
`undef  PL230_ADDR_CHNL_PRIORITY_SET
`undef  PL230_ADDR_CHNL_PRIORITY_CLR
//      Reserved
//      Reserved
//      Reserved
`undef  PL230_ADDR_ERR_CLR
//  Integration Test Registers
`undef  PL230_ADDR_INTEGRATION_CFG
//      Reserved
`undef  PL230_ADDR_STALL_STATUS
//      Reserved
`undef  PL230_ADDR_DMA_REQ_STATUS
//      Reserved
`undef  PL230_ADDR_DMA_SREQ_STATUS
//      Reserved
`undef  PL230_ADDR_DMA_DONE_SET
`undef  PL230_ADDR_DMA_DONE_CLR
`undef  PL230_ADDR_DMA_ACTIVE_SET
`undef  PL230_ADDR_DMA_ACTIVE_CLR
//      Reserved
//      Reserved
//      Reserved
//      Reserved
//      Reserved
//      Reserved
`undef  PL230_ADDR_ERR_SET
//      Reserved
//  PrimeCell Configuration Registers
`undef  PL230_ADDR_PERIPH_ID_4
//      Reserved
//      Reserved
//      Reserved
`undef  PL230_ADDR_PERIPH_ID_0
`undef  PL230_ADDR_PERIPH_ID_1
`undef  PL230_ADDR_PERIPH_ID_2
`undef  PL230_ADDR_PERIPH_ID_3
`undef  PL230_ADDR_PCELL_ID_0
`undef  PL230_ADDR_PCELL_ID_1
`undef  PL230_ADDR_PCELL_ID_2
`undef  PL230_ADDR_PCELL_ID_3


// Bit vector definitions for channel_cfg
`undef  PL230_CHANNEL_CFG_BITS
//  Destination address increment
`undef  PL230_CHANNEL_CFG_DST_INC
`undef  PL230_HRDATA_DST_INC
//  Destination transfer size
//   Source and destination sizes must match
//   so the same bits as the src_size are used
`undef  PL230_CHANNEL_CFG_DST_SIZE
`undef  PL230_HRDATA_DST_SIZE
//  Source address increment
`undef  PL230_CHANNEL_CFG_SRC_INC
`undef  PL230_HRDATA_SRC_INC
//  Source transfer size
`undef  PL230_CHANNEL_CFG_SRC_SIZE
`undef  PL230_HRDATA_SRC_SIZE
//  Destination AHB protection control
`undef  PL230_CHANNEL_CFG_DST_PROT_CTRL
`undef  PL230_HRDATA_DST_PROT_CTRL
//  Source AHB protection control
`undef  PL230_CHANNEL_CFG_SRC_PROT_CTRL
`undef  PL230_HRDATA_SRC_PROT_CTRL
//  Power of two transactions per request
`undef  PL230_CHANNEL_CFG_R
`undef  PL230_HRDATA_R
//  Number of bits in the N counter     - hrdata[13:4]
`undef  PL230_N_COUNT_BITS
//  Lsb bit offset for n_minus_1
`undef  PL230_N_COUNT_OFFSET
//  Set chnl_useburst_status
`undef  PL230_CHANNEL_CFG_NEXT_USEBURST
`undef  PL230_HRDATA_NEXT_USEBURST
//  DMA cycle control
`undef  PL230_CHANNEL_CFG_CYCLE_CTRL
`undef  PL230_HRDATA_CYCLE_CTRL


// Number of bits for the statemachine
`undef  PL230_STATE_BITS
// Statemachine state encoding
`undef  PL230_ST_IDLE
`undef  PL230_ST_RD_CTRL
`undef  PL230_ST_RD_SPTR
`undef  PL230_ST_RD_DPTR
`undef  PL230_ST_RD_SDAT
`undef  PL230_ST_WR_DDAT
`undef  PL230_ST_WAIT
`undef  PL230_ST_WR_CTRL
`undef  PL230_ST_STALL
`undef  PL230_ST_DONE
`undef  PL230_ST_PSGP
`undef  PL230_ST_RESVD_0
`undef  PL230_ST_RESVD_1
`undef  PL230_ST_RESVD_2
`undef  PL230_ST_RESVD_3
`undef  PL230_ST_RESVD_4

`undef PL230_SIZE_BYTE
`undef PL230_SIZE_HWORD
`undef PL230_SIZE_WORD
`undef PL230_SIZE_RESVD

// pl230_undefs.v end
