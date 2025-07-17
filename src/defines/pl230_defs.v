//-----------------------------------------------------------------------------
// NanoSoC customised Cortex-M0 controller DMA230 configuration
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright � 2021, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

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
// File Name  : pl230_defs.v
// Checked In : $Date: 2007-06-06 21:55:22 +0530 (Wed, 06 Jun 2007) $
// Revision   : $Revision: 13823 $
// State      : $state: PL230-DE-98007-r0p0-02rel0 $
//
//-----------------------------------------------------------------------------
// Purpose : Peripheral specific macro definitions
//
//-----------------------------------------------------------------------------


`ifdef ARM_TIMESCALE_DEFINED
  `timescale 1ns/1ps
`endif

// Set the number of channels implemented
`define PL230_CHNLS                     4
`define PL230_CHNL_BITS                 2
//`define PL230_ONE_CHNL

// Include Integration Test Logic
`define PL230_INCLUDE_TEST

`define PL230_PLUS_PTR_CACHE            1

// AHB Interface
`define PL230_AHB_TRANS_IDLE            2'b00
`define PL230_AHB_TRANS_NONSEQ          2'b10
`define PL230_AHB_READ                  1'b0
`define PL230_AHB_WRITE                 1'b1
`define PL230_AHB_SIZE_BYTE             3'b000
`define PL230_AHB_SIZE_HWORD            3'b001
`define PL230_AHB_SIZE_WORD             3'b010

// PrimeCell Configuration
`define PL230_PERIPH_ID_0               8'h30
`define PL230_PERIPH_ID_1               8'hB2
`define PL230_PERIPH_ID_2               8'h0B
`define PL230_PERIPH_ID_3               8'h00
`define PL230_PERIPH_ID_4               8'h04
`define PL230_PCELL_ID_0                8'h0D
`define PL230_PCELL_ID_1                8'hF0
`define PL230_PCELL_ID_2                8'h05
`define PL230_PCELL_ID_3                8'hB1

// Memory Mapped Registers
//  Controller Configuration Registers
`define PL230_ADDR_DMA_STATUS           12'h000
`define PL230_ADDR_DMA_CFG              12'h004
`define PL230_ADDR_CTRL_BASE_PTR        12'h008
`define PL230_ADDR_ALT_CTRL_BASE_PTR    12'h00C
`define PL230_ADDR_DMA_WAITONREQ_STATUS 12'h010
`define PL230_ADDR_CHNL_SW_REQUEST      12'h014
`define PL230_ADDR_CHNL_USEBURST_SET    12'h018
`define PL230_ADDR_CHNL_USEBURST_CLR    12'h01C
`define PL230_ADDR_CHNL_REQ_MASK_SET    12'h020
`define PL230_ADDR_CHNL_REQ_MASK_CLR    12'h024
`define PL230_ADDR_CHNL_ENABLE_SET      12'h028
`define PL230_ADDR_CHNL_ENABLE_CLR      12'h02C
`define PL230_ADDR_CHNL_PRI_ALT_SET     12'h030
`define PL230_ADDR_CHNL_PRI_ALT_CLR     12'h034
`define PL230_ADDR_CHNL_PRIORITY_SET    12'h038
`define PL230_ADDR_CHNL_PRIORITY_CLR    12'h03C
//      Reserved                        12'h040
//      Reserved                        12'h044
//      Reserved                        12'h048
`define PL230_ADDR_ERR_CLR              12'h04C
//  Integration Test Registers
`define PL230_ADDR_INTEGRATION_CFG      12'hE00
//      Reserved                        12'hE04
`define PL230_ADDR_STALL_STATUS         12'hE08
//      Reserved                        12'hE0C
`define PL230_ADDR_DMA_REQ_STATUS       12'hE10
//      Reserved                        12'hE14
`define PL230_ADDR_DMA_SREQ_STATUS      12'hE18
//      Reserved                        12'hE1C
`define PL230_ADDR_DMA_DONE_SET         12'hE20
`define PL230_ADDR_DMA_DONE_CLR         12'hE24
`define PL230_ADDR_DMA_ACTIVE_SET       12'hE28
`define PL230_ADDR_DMA_ACTIVE_CLR       12'hE2C
//      Reserved                        12'hE30
//      Reserved                        12'hE34
//      Reserved                        12'hE38
//      Reserved                        12'hE3C
//      Reserved                        12'hE40
//      Reserved                        12'hE44
`define PL230_ADDR_ERR_SET              12'hE48
//      Reserved                        12'hE4C
//  PrimeCell Configuration Registers
`define PL230_ADDR_PERIPH_ID_4          12'hFD0
//      Reserved                        12'hFD4
//      Reserved                        12'hFD8
//      Reserved                        12'hFDC
`define PL230_ADDR_PERIPH_ID_0          12'hFE0
`define PL230_ADDR_PERIPH_ID_1          12'hFE4
`define PL230_ADDR_PERIPH_ID_2          12'hFE8
`define PL230_ADDR_PERIPH_ID_3          12'hFEC
`define PL230_ADDR_PCELL_ID_0           12'hFF0
`define PL230_ADDR_PCELL_ID_1           12'hFF4
`define PL230_ADDR_PCELL_ID_2           12'hFF8
`define PL230_ADDR_PCELL_ID_3           12'hFFC


// Bit vector definitions for channel_cfg
`define PL230_CHANNEL_CFG_BITS          20
//  Destination address increment
`define PL230_CHANNEL_CFG_DST_INC       channel_cfg[19:18]
`define PL230_HRDATA_DST_INC            hrdata[31:30]
//  Destination transfer size
//   Source and destination sizes must match
//   so the same bits as the src_size are used
`define PL230_CHANNEL_CFG_DST_SIZE      channel_cfg[15:14]
`define PL230_HRDATA_DST_SIZE           hrdata[29:28]
//  Source address increment
`define PL230_CHANNEL_CFG_SRC_INC       channel_cfg[17:16]
`define PL230_HRDATA_SRC_INC            hrdata[27:26]
//  Source transfer size
`define PL230_CHANNEL_CFG_SRC_SIZE      channel_cfg[15:14]
`define PL230_HRDATA_SRC_SIZE           hrdata[25:24]
//  Destination AHB protection control
`define PL230_CHANNEL_CFG_DST_PROT_CTRL channel_cfg[13:11]
`define PL230_HRDATA_DST_PROT_CTRL      hrdata[23:21]
//  Source AHB protection control
`define PL230_CHANNEL_CFG_SRC_PROT_CTRL channel_cfg[10:8]
`define PL230_HRDATA_SRC_PROT_CTRL      hrdata[20:18]
//  Power of two transactions per request
`define PL230_CHANNEL_CFG_R             channel_cfg[7:4]
`define PL230_HRDATA_R                  hrdata[17:14]
//  Number of bits in the N counter     - hrdata[13:4]
`define PL230_N_COUNT_BITS              10
//  Lsb bit offset for n_minus_1
`define PL230_N_COUNT_OFFSET            4
//  Set chnl_useburst_status
`define PL230_CHANNEL_CFG_NEXT_USEBURST channel_cfg[3]
`define PL230_HRDATA_NEXT_USEBURST      hrdata[3]
//  DMA cycle control
`define PL230_CHANNEL_CFG_CYCLE_CTRL    channel_cfg[2:0]
`define PL230_HRDATA_CYCLE_CTRL         hrdata[2:0]


// Number of bits for the statemachine
`define PL230_STATE_BITS 4
// Statemachine state encoding
`define PL230_ST_IDLE    4'h0
`define PL230_ST_RD_CTRL 4'h1
`define PL230_ST_RD_SPTR 4'h2
`define PL230_ST_RD_DPTR 4'h3
`define PL230_ST_RD_SDAT 4'h4
`define PL230_ST_WR_DDAT 4'h5
`define PL230_ST_WAIT    4'h6
`define PL230_ST_WR_CTRL 4'h7
`define PL230_ST_STALL   4'h8
`define PL230_ST_DONE    4'h9
`define PL230_ST_PSGP    4'hA

//`ifdef PL230_PLUS_PTR_CACHE
`define PL230_ST_XC_INI  4'hB
`define PL230_ST_XC_RDY  4'hC
`define PL230_ST_XR_SDAT 4'hD
`define PL230_ST_XW_DDAT 4'hE
`define PL230_ST_RESVD_0 4'hF
`define PL230_ST_RESVD_1 4'hF
`define PL230_ST_RESVD_2 4'hF
`define PL230_ST_RESVD_3 4'hF
`define PL230_ST_RESVD_4 4'hF
//`else // !PL230_PLUS_PTR_CACHE
//`define PL230_ST_RESVD_0 4'hB
//`define PL230_ST_RESVD_1 4'hC
//`define PL230_ST_RESVD_2 4'hD
//`define PL230_ST_RESVD_3 4'hE
//`define PL230_ST_RESVD_4 4'hF
//`endif

`define PL230_SIZE_BYTE  2'b00
`define PL230_SIZE_HWORD 2'b01
`define PL230_SIZE_WORD  2'b10
`define PL230_SIZE_RESVD 2'b11

// pl230_defs.v end
