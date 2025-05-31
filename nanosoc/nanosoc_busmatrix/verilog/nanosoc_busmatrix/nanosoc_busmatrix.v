//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2001-2023 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      SVN Information
//
//      Checked In          : $Date: 2017-10-10 15:55:38 +0100 (Tue, 10 Oct 2017) $
//
//      Revision            : $Revision: 371321 $
//
//      Release Information : Cortex-M System Design Kit-r1p1-00rel0
//
//-----------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
//  Abstract            : BusMatrix is the top-level which connects together
//                        the required Input Stages, MatrixDecodes, Output
//                        Stages and Output Arbitration blocks.
//
//                        Supports the following configured options:
//
//                         - Architecture type 'ahb2',
//                         - 4 slave ports (connecting to masters),
//                         - 8 master ports (connecting to slaves),
//                         - Routing address width of 32 bits,
//                         - Routing data width of 32 bits,
//                         - Arbiter type 'burst',
//                         - Connectivity mapping:
//                             _DEBUG -> _BOOTROM_0, _IMEM_0, _DMEM_0, _SYSIO, _EXP, _EXPRAM_L, _EXPRAM_H, _SYSTABLE, 
//                             _DMAC_0 -> _BOOTROM_0, _IMEM_0, _DMEM_0, _SYSIO, _EXP, _EXPRAM_L, _EXPRAM_H, 
//                             _DMAC_1 -> _BOOTROM_0, _IMEM_0, _DMEM_0, _SYSIO, _EXP, _EXPRAM_L, _EXPRAM_H, 
//                             _CPU_0 -> _BOOTROM_0, _IMEM_0, _DMEM_0, _SYSIO, _EXP, _EXPRAM_L, _EXPRAM_H, _SYSTABLE,
//                         - Connectivity type 'sparse'.
//
//------------------------------------------------------------------------------



module nanosoc_busmatrix (

    // Common AHB signals
    HCLK,
    HRESETn,

    // System address remapping control
    REMAP,

    // Input port SI0 (inputs from master 0)
    HSEL_DEBUG,
    HADDR_DEBUG,
    HTRANS_DEBUG,
    HWRITE_DEBUG,
    HSIZE_DEBUG,
    HBURST_DEBUG,
    HPROT_DEBUG,
    HMASTER_DEBUG,
    HWDATA_DEBUG,
    HMASTLOCK_DEBUG,
    HREADY_DEBUG,

    // Input port SI1 (inputs from master 1)
    HSEL_DMAC_0,
    HADDR_DMAC_0,
    HTRANS_DMAC_0,
    HWRITE_DMAC_0,
    HSIZE_DMAC_0,
    HBURST_DMAC_0,
    HPROT_DMAC_0,
    HMASTER_DMAC_0,
    HWDATA_DMAC_0,
    HMASTLOCK_DMAC_0,
    HREADY_DMAC_0,

    // Input port SI2 (inputs from master 2)
    HSEL_DMAC_1,
    HADDR_DMAC_1,
    HTRANS_DMAC_1,
    HWRITE_DMAC_1,
    HSIZE_DMAC_1,
    HBURST_DMAC_1,
    HPROT_DMAC_1,
    HMASTER_DMAC_1,
    HWDATA_DMAC_1,
    HMASTLOCK_DMAC_1,
    HREADY_DMAC_1,

    // Input port SI3 (inputs from master 3)
    HSEL_CPU_0,
    HADDR_CPU_0,
    HTRANS_CPU_0,
    HWRITE_CPU_0,
    HSIZE_CPU_0,
    HBURST_CPU_0,
    HPROT_CPU_0,
    HMASTER_CPU_0,
    HWDATA_CPU_0,
    HMASTLOCK_CPU_0,
    HREADY_CPU_0,

    // Output port MI0 (inputs from slave 0)
    HRDATA_BOOTROM_0,
    HREADYOUT_BOOTROM_0,
    HRESP_BOOTROM_0,

    // Output port MI1 (inputs from slave 1)
    HRDATA_IMEM_0,
    HREADYOUT_IMEM_0,
    HRESP_IMEM_0,

    // Output port MI2 (inputs from slave 2)
    HRDATA_DMEM_0,
    HREADYOUT_DMEM_0,
    HRESP_DMEM_0,

    // Output port MI3 (inputs from slave 3)
    HRDATA_SYSIO,
    HREADYOUT_SYSIO,
    HRESP_SYSIO,

    // Output port MI4 (inputs from slave 4)
    HRDATA_EXPRAM_L,
    HREADYOUT_EXPRAM_L,
    HRESP_EXPRAM_L,

    // Output port MI5 (inputs from slave 5)
    HRDATA_EXPRAM_H,
    HREADYOUT_EXPRAM_H,
    HRESP_EXPRAM_H,

    // Output port MI6 (inputs from slave 6)
    HRDATA_EXP,
    HREADYOUT_EXP,
    HRESP_EXP,

    // Output port MI7 (inputs from slave 7)
    HRDATA_SYSTABLE,
    HREADYOUT_SYSTABLE,
    HRESP_SYSTABLE,

    // Scan test dummy signals; not connected until scan insertion
    SCANENABLE,   // Scan Test Mode Enable
    SCANINHCLK,   // Scan Chain Input


    // Output port MI0 (outputs to slave 0)
    HSEL_BOOTROM_0,
    HADDR_BOOTROM_0,
    HTRANS_BOOTROM_0,
    HWRITE_BOOTROM_0,
    HSIZE_BOOTROM_0,
    HBURST_BOOTROM_0,
    HPROT_BOOTROM_0,
    HMASTER_BOOTROM_0,
    HWDATA_BOOTROM_0,
    HMASTLOCK_BOOTROM_0,
    HREADYMUX_BOOTROM_0,

    // Output port MI1 (outputs to slave 1)
    HSEL_IMEM_0,
    HADDR_IMEM_0,
    HTRANS_IMEM_0,
    HWRITE_IMEM_0,
    HSIZE_IMEM_0,
    HBURST_IMEM_0,
    HPROT_IMEM_0,
    HMASTER_IMEM_0,
    HWDATA_IMEM_0,
    HMASTLOCK_IMEM_0,
    HREADYMUX_IMEM_0,

    // Output port MI2 (outputs to slave 2)
    HSEL_DMEM_0,
    HADDR_DMEM_0,
    HTRANS_DMEM_0,
    HWRITE_DMEM_0,
    HSIZE_DMEM_0,
    HBURST_DMEM_0,
    HPROT_DMEM_0,
    HMASTER_DMEM_0,
    HWDATA_DMEM_0,
    HMASTLOCK_DMEM_0,
    HREADYMUX_DMEM_0,

    // Output port MI3 (outputs to slave 3)
    HSEL_SYSIO,
    HADDR_SYSIO,
    HTRANS_SYSIO,
    HWRITE_SYSIO,
    HSIZE_SYSIO,
    HBURST_SYSIO,
    HPROT_SYSIO,
    HMASTER_SYSIO,
    HWDATA_SYSIO,
    HMASTLOCK_SYSIO,
    HREADYMUX_SYSIO,

    // Output port MI4 (outputs to slave 4)
    HSEL_EXPRAM_L,
    HADDR_EXPRAM_L,
    HTRANS_EXPRAM_L,
    HWRITE_EXPRAM_L,
    HSIZE_EXPRAM_L,
    HBURST_EXPRAM_L,
    HPROT_EXPRAM_L,
    HMASTER_EXPRAM_L,
    HWDATA_EXPRAM_L,
    HMASTLOCK_EXPRAM_L,
    HREADYMUX_EXPRAM_L,

    // Output port MI5 (outputs to slave 5)
    HSEL_EXPRAM_H,
    HADDR_EXPRAM_H,
    HTRANS_EXPRAM_H,
    HWRITE_EXPRAM_H,
    HSIZE_EXPRAM_H,
    HBURST_EXPRAM_H,
    HPROT_EXPRAM_H,
    HMASTER_EXPRAM_H,
    HWDATA_EXPRAM_H,
    HMASTLOCK_EXPRAM_H,
    HREADYMUX_EXPRAM_H,

    // Output port MI6 (outputs to slave 6)
    HSEL_EXP,
    HADDR_EXP,
    HTRANS_EXP,
    HWRITE_EXP,
    HSIZE_EXP,
    HBURST_EXP,
    HPROT_EXP,
    HMASTER_EXP,
    HWDATA_EXP,
    HMASTLOCK_EXP,
    HREADYMUX_EXP,

    // Output port MI7 (outputs to slave 7)
    HSEL_SYSTABLE,
    HADDR_SYSTABLE,
    HTRANS_SYSTABLE,
    HWRITE_SYSTABLE,
    HSIZE_SYSTABLE,
    HBURST_SYSTABLE,
    HPROT_SYSTABLE,
    HMASTER_SYSTABLE,
    HWDATA_SYSTABLE,
    HMASTLOCK_SYSTABLE,
    HREADYMUX_SYSTABLE,

    // Input port SI0 (outputs to master 0)
    HRDATA_DEBUG,
    HREADYOUT_DEBUG,
    HRESP_DEBUG,

    // Input port SI1 (outputs to master 1)
    HRDATA_DMAC_0,
    HREADYOUT_DMAC_0,
    HRESP_DMAC_0,

    // Input port SI2 (outputs to master 2)
    HRDATA_DMAC_1,
    HREADYOUT_DMAC_1,
    HRESP_DMAC_1,

    // Input port SI3 (outputs to master 3)
    HRDATA_CPU_0,
    HREADYOUT_CPU_0,
    HRESP_CPU_0,

    // Scan test dummy signals; not connected until scan insertion
    SCANOUTHCLK   // Scan Chain Output

    );


// -----------------------------------------------------------------------------
// Input and Output declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    input         HCLK;            // AHB System Clock
    input         HRESETn;         // AHB System Reset

    // System address remapping control
    input   [3:0] REMAP;           // REMAP input

    // Input port SI0 (inputs from master 0)
    input         HSEL_DEBUG;          // Slave Select
    input  [31:0] HADDR_DEBUG;         // Address bus
    input   [1:0] HTRANS_DEBUG;        // Transfer type
    input         HWRITE_DEBUG;        // Transfer direction
    input   [2:0] HSIZE_DEBUG;         // Transfer size
    input   [2:0] HBURST_DEBUG;        // Burst type
    input   [3:0] HPROT_DEBUG;         // Protection control
    input   [3:0] HMASTER_DEBUG;       // Master select
    input  [31:0] HWDATA_DEBUG;        // Write data
    input         HMASTLOCK_DEBUG;     // Locked Sequence
    input         HREADY_DEBUG;        // Transfer done

    // Input port SI1 (inputs from master 1)
    input         HSEL_DMAC_0;          // Slave Select
    input  [31:0] HADDR_DMAC_0;         // Address bus
    input   [1:0] HTRANS_DMAC_0;        // Transfer type
    input         HWRITE_DMAC_0;        // Transfer direction
    input   [2:0] HSIZE_DMAC_0;         // Transfer size
    input   [2:0] HBURST_DMAC_0;        // Burst type
    input   [3:0] HPROT_DMAC_0;         // Protection control
    input   [3:0] HMASTER_DMAC_0;       // Master select
    input  [31:0] HWDATA_DMAC_0;        // Write data
    input         HMASTLOCK_DMAC_0;     // Locked Sequence
    input         HREADY_DMAC_0;        // Transfer done

    // Input port SI2 (inputs from master 2)
    input         HSEL_DMAC_1;          // Slave Select
    input  [31:0] HADDR_DMAC_1;         // Address bus
    input   [1:0] HTRANS_DMAC_1;        // Transfer type
    input         HWRITE_DMAC_1;        // Transfer direction
    input   [2:0] HSIZE_DMAC_1;         // Transfer size
    input   [2:0] HBURST_DMAC_1;        // Burst type
    input   [3:0] HPROT_DMAC_1;         // Protection control
    input   [3:0] HMASTER_DMAC_1;       // Master select
    input  [31:0] HWDATA_DMAC_1;        // Write data
    input         HMASTLOCK_DMAC_1;     // Locked Sequence
    input         HREADY_DMAC_1;        // Transfer done

    // Input port SI3 (inputs from master 3)
    input         HSEL_CPU_0;          // Slave Select
    input  [31:0] HADDR_CPU_0;         // Address bus
    input   [1:0] HTRANS_CPU_0;        // Transfer type
    input         HWRITE_CPU_0;        // Transfer direction
    input   [2:0] HSIZE_CPU_0;         // Transfer size
    input   [2:0] HBURST_CPU_0;        // Burst type
    input   [3:0] HPROT_CPU_0;         // Protection control
    input   [3:0] HMASTER_CPU_0;       // Master select
    input  [31:0] HWDATA_CPU_0;        // Write data
    input         HMASTLOCK_CPU_0;     // Locked Sequence
    input         HREADY_CPU_0;        // Transfer done

    // Output port MI0 (inputs from slave 0)
    input  [31:0] HRDATA_BOOTROM_0;        // Read data bus
    input         HREADYOUT_BOOTROM_0;     // HREADY feedback
    input   [1:0] HRESP_BOOTROM_0;         // Transfer response

    // Output port MI1 (inputs from slave 1)
    input  [31:0] HRDATA_IMEM_0;        // Read data bus
    input         HREADYOUT_IMEM_0;     // HREADY feedback
    input   [1:0] HRESP_IMEM_0;         // Transfer response

    // Output port MI2 (inputs from slave 2)
    input  [31:0] HRDATA_DMEM_0;        // Read data bus
    input         HREADYOUT_DMEM_0;     // HREADY feedback
    input   [1:0] HRESP_DMEM_0;         // Transfer response

    // Output port MI3 (inputs from slave 3)
    input  [31:0] HRDATA_SYSIO;        // Read data bus
    input         HREADYOUT_SYSIO;     // HREADY feedback
    input   [1:0] HRESP_SYSIO;         // Transfer response

    // Output port MI4 (inputs from slave 4)
    input  [31:0] HRDATA_EXPRAM_L;        // Read data bus
    input         HREADYOUT_EXPRAM_L;     // HREADY feedback
    input   [1:0] HRESP_EXPRAM_L;         // Transfer response

    // Output port MI5 (inputs from slave 5)
    input  [31:0] HRDATA_EXPRAM_H;        // Read data bus
    input         HREADYOUT_EXPRAM_H;     // HREADY feedback
    input   [1:0] HRESP_EXPRAM_H;         // Transfer response

    // Output port MI6 (inputs from slave 6)
    input  [31:0] HRDATA_EXP;        // Read data bus
    input         HREADYOUT_EXP;     // HREADY feedback
    input   [1:0] HRESP_EXP;         // Transfer response

    // Output port MI7 (inputs from slave 7)
    input  [31:0] HRDATA_SYSTABLE;        // Read data bus
    input         HREADYOUT_SYSTABLE;     // HREADY feedback
    input   [1:0] HRESP_SYSTABLE;         // Transfer response

    // Scan test dummy signals; not connected until scan insertion
    input         SCANENABLE;      // Scan enable signal
    input         SCANINHCLK;      // HCLK scan input


    // Output port MI0 (outputs to slave 0)
    output        HSEL_BOOTROM_0;          // Slave Select
    output [31:0] HADDR_BOOTROM_0;         // Address bus
    output  [1:0] HTRANS_BOOTROM_0;        // Transfer type
    output        HWRITE_BOOTROM_0;        // Transfer direction
    output  [2:0] HSIZE_BOOTROM_0;         // Transfer size
    output  [2:0] HBURST_BOOTROM_0;        // Burst type
    output  [3:0] HPROT_BOOTROM_0;         // Protection control
    output  [3:0] HMASTER_BOOTROM_0;       // Master select
    output [31:0] HWDATA_BOOTROM_0;        // Write data
    output        HMASTLOCK_BOOTROM_0;     // Locked Sequence
    output        HREADYMUX_BOOTROM_0;     // Transfer done

    // Output port MI1 (outputs to slave 1)
    output        HSEL_IMEM_0;          // Slave Select
    output [31:0] HADDR_IMEM_0;         // Address bus
    output  [1:0] HTRANS_IMEM_0;        // Transfer type
    output        HWRITE_IMEM_0;        // Transfer direction
    output  [2:0] HSIZE_IMEM_0;         // Transfer size
    output  [2:0] HBURST_IMEM_0;        // Burst type
    output  [3:0] HPROT_IMEM_0;         // Protection control
    output  [3:0] HMASTER_IMEM_0;       // Master select
    output [31:0] HWDATA_IMEM_0;        // Write data
    output        HMASTLOCK_IMEM_0;     // Locked Sequence
    output        HREADYMUX_IMEM_0;     // Transfer done

    // Output port MI2 (outputs to slave 2)
    output        HSEL_DMEM_0;          // Slave Select
    output [31:0] HADDR_DMEM_0;         // Address bus
    output  [1:0] HTRANS_DMEM_0;        // Transfer type
    output        HWRITE_DMEM_0;        // Transfer direction
    output  [2:0] HSIZE_DMEM_0;         // Transfer size
    output  [2:0] HBURST_DMEM_0;        // Burst type
    output  [3:0] HPROT_DMEM_0;         // Protection control
    output  [3:0] HMASTER_DMEM_0;       // Master select
    output [31:0] HWDATA_DMEM_0;        // Write data
    output        HMASTLOCK_DMEM_0;     // Locked Sequence
    output        HREADYMUX_DMEM_0;     // Transfer done

    // Output port MI3 (outputs to slave 3)
    output        HSEL_SYSIO;          // Slave Select
    output [31:0] HADDR_SYSIO;         // Address bus
    output  [1:0] HTRANS_SYSIO;        // Transfer type
    output        HWRITE_SYSIO;        // Transfer direction
    output  [2:0] HSIZE_SYSIO;         // Transfer size
    output  [2:0] HBURST_SYSIO;        // Burst type
    output  [3:0] HPROT_SYSIO;         // Protection control
    output  [3:0] HMASTER_SYSIO;       // Master select
    output [31:0] HWDATA_SYSIO;        // Write data
    output        HMASTLOCK_SYSIO;     // Locked Sequence
    output        HREADYMUX_SYSIO;     // Transfer done

    // Output port MI4 (outputs to slave 4)
    output        HSEL_EXPRAM_L;          // Slave Select
    output [31:0] HADDR_EXPRAM_L;         // Address bus
    output  [1:0] HTRANS_EXPRAM_L;        // Transfer type
    output        HWRITE_EXPRAM_L;        // Transfer direction
    output  [2:0] HSIZE_EXPRAM_L;         // Transfer size
    output  [2:0] HBURST_EXPRAM_L;        // Burst type
    output  [3:0] HPROT_EXPRAM_L;         // Protection control
    output  [3:0] HMASTER_EXPRAM_L;       // Master select
    output [31:0] HWDATA_EXPRAM_L;        // Write data
    output        HMASTLOCK_EXPRAM_L;     // Locked Sequence
    output        HREADYMUX_EXPRAM_L;     // Transfer done

    // Output port MI5 (outputs to slave 5)
    output        HSEL_EXPRAM_H;          // Slave Select
    output [31:0] HADDR_EXPRAM_H;         // Address bus
    output  [1:0] HTRANS_EXPRAM_H;        // Transfer type
    output        HWRITE_EXPRAM_H;        // Transfer direction
    output  [2:0] HSIZE_EXPRAM_H;         // Transfer size
    output  [2:0] HBURST_EXPRAM_H;        // Burst type
    output  [3:0] HPROT_EXPRAM_H;         // Protection control
    output  [3:0] HMASTER_EXPRAM_H;       // Master select
    output [31:0] HWDATA_EXPRAM_H;        // Write data
    output        HMASTLOCK_EXPRAM_H;     // Locked Sequence
    output        HREADYMUX_EXPRAM_H;     // Transfer done

    // Output port MI6 (outputs to slave 6)
    output        HSEL_EXP;          // Slave Select
    output [31:0] HADDR_EXP;         // Address bus
    output  [1:0] HTRANS_EXP;        // Transfer type
    output        HWRITE_EXP;        // Transfer direction
    output  [2:0] HSIZE_EXP;         // Transfer size
    output  [2:0] HBURST_EXP;        // Burst type
    output  [3:0] HPROT_EXP;         // Protection control
    output  [3:0] HMASTER_EXP;       // Master select
    output [31:0] HWDATA_EXP;        // Write data
    output        HMASTLOCK_EXP;     // Locked Sequence
    output        HREADYMUX_EXP;     // Transfer done

    // Output port MI7 (outputs to slave 7)
    output        HSEL_SYSTABLE;          // Slave Select
    output [31:0] HADDR_SYSTABLE;         // Address bus
    output  [1:0] HTRANS_SYSTABLE;        // Transfer type
    output        HWRITE_SYSTABLE;        // Transfer direction
    output  [2:0] HSIZE_SYSTABLE;         // Transfer size
    output  [2:0] HBURST_SYSTABLE;        // Burst type
    output  [3:0] HPROT_SYSTABLE;         // Protection control
    output  [3:0] HMASTER_SYSTABLE;       // Master select
    output [31:0] HWDATA_SYSTABLE;        // Write data
    output        HMASTLOCK_SYSTABLE;     // Locked Sequence
    output        HREADYMUX_SYSTABLE;     // Transfer done

    // Input port SI0 (outputs to master 0)
    output [31:0] HRDATA_DEBUG;        // Read data bus
    output        HREADYOUT_DEBUG;     // HREADY feedback
    output  [1:0] HRESP_DEBUG;         // Transfer response

    // Input port SI1 (outputs to master 1)
    output [31:0] HRDATA_DMAC_0;        // Read data bus
    output        HREADYOUT_DMAC_0;     // HREADY feedback
    output  [1:0] HRESP_DMAC_0;         // Transfer response

    // Input port SI2 (outputs to master 2)
    output [31:0] HRDATA_DMAC_1;        // Read data bus
    output        HREADYOUT_DMAC_1;     // HREADY feedback
    output  [1:0] HRESP_DMAC_1;         // Transfer response

    // Input port SI3 (outputs to master 3)
    output [31:0] HRDATA_CPU_0;        // Read data bus
    output        HREADYOUT_CPU_0;     // HREADY feedback
    output  [1:0] HRESP_CPU_0;         // Transfer response

    // Scan test dummy signals; not connected until scan insertion
    output        SCANOUTHCLK;     // Scan Chain Output


// -----------------------------------------------------------------------------
// Wire declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    wire         HCLK;            // AHB System Clock
    wire         HRESETn;         // AHB System Reset

    // System address remapping control
    wire   [3:0] REMAP;           // REMAP signal

    // Input Port SI0
    wire         HSEL_DEBUG;          // Slave Select
    wire  [31:0] HADDR_DEBUG;         // Address bus
    wire   [1:0] HTRANS_DEBUG;        // Transfer type
    wire         HWRITE_DEBUG;        // Transfer direction
    wire   [2:0] HSIZE_DEBUG;         // Transfer size
    wire   [2:0] HBURST_DEBUG;        // Burst type
    wire   [3:0] HPROT_DEBUG;         // Protection control
    wire   [3:0] HMASTER_DEBUG;       // Master select
    wire  [31:0] HWDATA_DEBUG;        // Write data
    wire         HMASTLOCK_DEBUG;     // Locked Sequence
    wire         HREADY_DEBUG;        // Transfer done

    wire  [31:0] HRDATA_DEBUG;        // Read data bus
    wire         HREADYOUT_DEBUG;     // HREADY feedback
    wire   [1:0] HRESP_DEBUG;         // Transfer response

    // Input Port SI1
    wire         HSEL_DMAC_0;          // Slave Select
    wire  [31:0] HADDR_DMAC_0;         // Address bus
    wire   [1:0] HTRANS_DMAC_0;        // Transfer type
    wire         HWRITE_DMAC_0;        // Transfer direction
    wire   [2:0] HSIZE_DMAC_0;         // Transfer size
    wire   [2:0] HBURST_DMAC_0;        // Burst type
    wire   [3:0] HPROT_DMAC_0;         // Protection control
    wire   [3:0] HMASTER_DMAC_0;       // Master select
    wire  [31:0] HWDATA_DMAC_0;        // Write data
    wire         HMASTLOCK_DMAC_0;     // Locked Sequence
    wire         HREADY_DMAC_0;        // Transfer done

    wire  [31:0] HRDATA_DMAC_0;        // Read data bus
    wire         HREADYOUT_DMAC_0;     // HREADY feedback
    wire   [1:0] HRESP_DMAC_0;         // Transfer response

    // Input Port SI2
    wire         HSEL_DMAC_1;          // Slave Select
    wire  [31:0] HADDR_DMAC_1;         // Address bus
    wire   [1:0] HTRANS_DMAC_1;        // Transfer type
    wire         HWRITE_DMAC_1;        // Transfer direction
    wire   [2:0] HSIZE_DMAC_1;         // Transfer size
    wire   [2:0] HBURST_DMAC_1;        // Burst type
    wire   [3:0] HPROT_DMAC_1;         // Protection control
    wire   [3:0] HMASTER_DMAC_1;       // Master select
    wire  [31:0] HWDATA_DMAC_1;        // Write data
    wire         HMASTLOCK_DMAC_1;     // Locked Sequence
    wire         HREADY_DMAC_1;        // Transfer done

    wire  [31:0] HRDATA_DMAC_1;        // Read data bus
    wire         HREADYOUT_DMAC_1;     // HREADY feedback
    wire   [1:0] HRESP_DMAC_1;         // Transfer response

    // Input Port SI3
    wire         HSEL_CPU_0;          // Slave Select
    wire  [31:0] HADDR_CPU_0;         // Address bus
    wire   [1:0] HTRANS_CPU_0;        // Transfer type
    wire         HWRITE_CPU_0;        // Transfer direction
    wire   [2:0] HSIZE_CPU_0;         // Transfer size
    wire   [2:0] HBURST_CPU_0;        // Burst type
    wire   [3:0] HPROT_CPU_0;         // Protection control
    wire   [3:0] HMASTER_CPU_0;       // Master select
    wire  [31:0] HWDATA_CPU_0;        // Write data
    wire         HMASTLOCK_CPU_0;     // Locked Sequence
    wire         HREADY_CPU_0;        // Transfer done

    wire  [31:0] HRDATA_CPU_0;        // Read data bus
    wire         HREADYOUT_CPU_0;     // HREADY feedback
    wire   [1:0] HRESP_CPU_0;         // Transfer response

    // Output Port MI0
    wire         HSEL_BOOTROM_0;          // Slave Select
    wire  [31:0] HADDR_BOOTROM_0;         // Address bus
    wire   [1:0] HTRANS_BOOTROM_0;        // Transfer type
    wire         HWRITE_BOOTROM_0;        // Transfer direction
    wire   [2:0] HSIZE_BOOTROM_0;         // Transfer size
    wire   [2:0] HBURST_BOOTROM_0;        // Burst type
    wire   [3:0] HPROT_BOOTROM_0;         // Protection control
    wire   [3:0] HMASTER_BOOTROM_0;       // Master select
    wire  [31:0] HWDATA_BOOTROM_0;        // Write data
    wire         HMASTLOCK_BOOTROM_0;     // Locked Sequence
    wire         HREADYMUX_BOOTROM_0;     // Transfer done

    wire  [31:0] HRDATA_BOOTROM_0;        // Read data bus
    wire         HREADYOUT_BOOTROM_0;     // HREADY feedback
    wire   [1:0] HRESP_BOOTROM_0;         // Transfer response

    // Output Port MI1
    wire         HSEL_IMEM_0;          // Slave Select
    wire  [31:0] HADDR_IMEM_0;         // Address bus
    wire   [1:0] HTRANS_IMEM_0;        // Transfer type
    wire         HWRITE_IMEM_0;        // Transfer direction
    wire   [2:0] HSIZE_IMEM_0;         // Transfer size
    wire   [2:0] HBURST_IMEM_0;        // Burst type
    wire   [3:0] HPROT_IMEM_0;         // Protection control
    wire   [3:0] HMASTER_IMEM_0;       // Master select
    wire  [31:0] HWDATA_IMEM_0;        // Write data
    wire         HMASTLOCK_IMEM_0;     // Locked Sequence
    wire         HREADYMUX_IMEM_0;     // Transfer done

    wire  [31:0] HRDATA_IMEM_0;        // Read data bus
    wire         HREADYOUT_IMEM_0;     // HREADY feedback
    wire   [1:0] HRESP_IMEM_0;         // Transfer response

    // Output Port MI2
    wire         HSEL_DMEM_0;          // Slave Select
    wire  [31:0] HADDR_DMEM_0;         // Address bus
    wire   [1:0] HTRANS_DMEM_0;        // Transfer type
    wire         HWRITE_DMEM_0;        // Transfer direction
    wire   [2:0] HSIZE_DMEM_0;         // Transfer size
    wire   [2:0] HBURST_DMEM_0;        // Burst type
    wire   [3:0] HPROT_DMEM_0;         // Protection control
    wire   [3:0] HMASTER_DMEM_0;       // Master select
    wire  [31:0] HWDATA_DMEM_0;        // Write data
    wire         HMASTLOCK_DMEM_0;     // Locked Sequence
    wire         HREADYMUX_DMEM_0;     // Transfer done

    wire  [31:0] HRDATA_DMEM_0;        // Read data bus
    wire         HREADYOUT_DMEM_0;     // HREADY feedback
    wire   [1:0] HRESP_DMEM_0;         // Transfer response

    // Output Port MI3
    wire         HSEL_SYSIO;          // Slave Select
    wire  [31:0] HADDR_SYSIO;         // Address bus
    wire   [1:0] HTRANS_SYSIO;        // Transfer type
    wire         HWRITE_SYSIO;        // Transfer direction
    wire   [2:0] HSIZE_SYSIO;         // Transfer size
    wire   [2:0] HBURST_SYSIO;        // Burst type
    wire   [3:0] HPROT_SYSIO;         // Protection control
    wire   [3:0] HMASTER_SYSIO;       // Master select
    wire  [31:0] HWDATA_SYSIO;        // Write data
    wire         HMASTLOCK_SYSIO;     // Locked Sequence
    wire         HREADYMUX_SYSIO;     // Transfer done

    wire  [31:0] HRDATA_SYSIO;        // Read data bus
    wire         HREADYOUT_SYSIO;     // HREADY feedback
    wire   [1:0] HRESP_SYSIO;         // Transfer response

    // Output Port MI4
    wire         HSEL_EXPRAM_L;          // Slave Select
    wire  [31:0] HADDR_EXPRAM_L;         // Address bus
    wire   [1:0] HTRANS_EXPRAM_L;        // Transfer type
    wire         HWRITE_EXPRAM_L;        // Transfer direction
    wire   [2:0] HSIZE_EXPRAM_L;         // Transfer size
    wire   [2:0] HBURST_EXPRAM_L;        // Burst type
    wire   [3:0] HPROT_EXPRAM_L;         // Protection control
    wire   [3:0] HMASTER_EXPRAM_L;       // Master select
    wire  [31:0] HWDATA_EXPRAM_L;        // Write data
    wire         HMASTLOCK_EXPRAM_L;     // Locked Sequence
    wire         HREADYMUX_EXPRAM_L;     // Transfer done

    wire  [31:0] HRDATA_EXPRAM_L;        // Read data bus
    wire         HREADYOUT_EXPRAM_L;     // HREADY feedback
    wire   [1:0] HRESP_EXPRAM_L;         // Transfer response

    // Output Port MI5
    wire         HSEL_EXPRAM_H;          // Slave Select
    wire  [31:0] HADDR_EXPRAM_H;         // Address bus
    wire   [1:0] HTRANS_EXPRAM_H;        // Transfer type
    wire         HWRITE_EXPRAM_H;        // Transfer direction
    wire   [2:0] HSIZE_EXPRAM_H;         // Transfer size
    wire   [2:0] HBURST_EXPRAM_H;        // Burst type
    wire   [3:0] HPROT_EXPRAM_H;         // Protection control
    wire   [3:0] HMASTER_EXPRAM_H;       // Master select
    wire  [31:0] HWDATA_EXPRAM_H;        // Write data
    wire         HMASTLOCK_EXPRAM_H;     // Locked Sequence
    wire         HREADYMUX_EXPRAM_H;     // Transfer done

    wire  [31:0] HRDATA_EXPRAM_H;        // Read data bus
    wire         HREADYOUT_EXPRAM_H;     // HREADY feedback
    wire   [1:0] HRESP_EXPRAM_H;         // Transfer response

    // Output Port MI6
    wire         HSEL_EXP;          // Slave Select
    wire  [31:0] HADDR_EXP;         // Address bus
    wire   [1:0] HTRANS_EXP;        // Transfer type
    wire         HWRITE_EXP;        // Transfer direction
    wire   [2:0] HSIZE_EXP;         // Transfer size
    wire   [2:0] HBURST_EXP;        // Burst type
    wire   [3:0] HPROT_EXP;         // Protection control
    wire   [3:0] HMASTER_EXP;       // Master select
    wire  [31:0] HWDATA_EXP;        // Write data
    wire         HMASTLOCK_EXP;     // Locked Sequence
    wire         HREADYMUX_EXP;     // Transfer done

    wire  [31:0] HRDATA_EXP;        // Read data bus
    wire         HREADYOUT_EXP;     // HREADY feedback
    wire   [1:0] HRESP_EXP;         // Transfer response

    // Output Port MI7
    wire         HSEL_SYSTABLE;          // Slave Select
    wire  [31:0] HADDR_SYSTABLE;         // Address bus
    wire   [1:0] HTRANS_SYSTABLE;        // Transfer type
    wire         HWRITE_SYSTABLE;        // Transfer direction
    wire   [2:0] HSIZE_SYSTABLE;         // Transfer size
    wire   [2:0] HBURST_SYSTABLE;        // Burst type
    wire   [3:0] HPROT_SYSTABLE;         // Protection control
    wire   [3:0] HMASTER_SYSTABLE;       // Master select
    wire  [31:0] HWDATA_SYSTABLE;        // Write data
    wire         HMASTLOCK_SYSTABLE;     // Locked Sequence
    wire         HREADYMUX_SYSTABLE;     // Transfer done

    wire  [31:0] HRDATA_SYSTABLE;        // Read data bus
    wire         HREADYOUT_SYSTABLE;     // HREADY feedback
    wire   [1:0] HRESP_SYSTABLE;         // Transfer response


// -----------------------------------------------------------------------------
// Signal declarations
// -----------------------------------------------------------------------------

    // Bus-switch input SI0
    wire         i_sel0;            // HSEL signal
    wire  [31:0] i_addr0;           // HADDR signal
    wire   [1:0] i_trans0;          // HTRANS signal
    wire         i_write0;          // HWRITE signal
    wire   [2:0] i_size0;           // HSIZE signal
    wire   [2:0] i_burst0;          // HBURST signal
    wire   [3:0] i_prot0;           // HPROTS signal
    wire   [3:0] i_master0;         // HMASTER signal
    wire         i_mastlock0;       // HMASTLOCK signal
    wire         i_active0;         // Active signal
    wire         i_held_tran0;       // HeldTran signal
    wire         i_readyout0;       // Readyout signal
    wire   [1:0] i_resp0;           // Response signal

    // Bus-switch input SI1
    wire         i_sel1;            // HSEL signal
    wire  [31:0] i_addr1;           // HADDR signal
    wire   [1:0] i_trans1;          // HTRANS signal
    wire         i_write1;          // HWRITE signal
    wire   [2:0] i_size1;           // HSIZE signal
    wire   [2:0] i_burst1;          // HBURST signal
    wire   [3:0] i_prot1;           // HPROTS signal
    wire   [3:0] i_master1;         // HMASTER signal
    wire         i_mastlock1;       // HMASTLOCK signal
    wire         i_active1;         // Active signal
    wire         i_held_tran1;       // HeldTran signal
    wire         i_readyout1;       // Readyout signal
    wire   [1:0] i_resp1;           // Response signal

    // Bus-switch input SI2
    wire         i_sel2;            // HSEL signal
    wire  [31:0] i_addr2;           // HADDR signal
    wire   [1:0] i_trans2;          // HTRANS signal
    wire         i_write2;          // HWRITE signal
    wire   [2:0] i_size2;           // HSIZE signal
    wire   [2:0] i_burst2;          // HBURST signal
    wire   [3:0] i_prot2;           // HPROTS signal
    wire   [3:0] i_master2;         // HMASTER signal
    wire         i_mastlock2;       // HMASTLOCK signal
    wire         i_active2;         // Active signal
    wire         i_held_tran2;       // HeldTran signal
    wire         i_readyout2;       // Readyout signal
    wire   [1:0] i_resp2;           // Response signal

    // Bus-switch input SI3
    wire         i_sel3;            // HSEL signal
    wire  [31:0] i_addr3;           // HADDR signal
    wire   [1:0] i_trans3;          // HTRANS signal
    wire         i_write3;          // HWRITE signal
    wire   [2:0] i_size3;           // HSIZE signal
    wire   [2:0] i_burst3;          // HBURST signal
    wire   [3:0] i_prot3;           // HPROTS signal
    wire   [3:0] i_master3;         // HMASTER signal
    wire         i_mastlock3;       // HMASTLOCK signal
    wire         i_active3;         // Active signal
    wire         i_held_tran3;       // HeldTran signal
    wire         i_readyout3;       // Readyout signal
    wire   [1:0] i_resp3;           // Response signal

    // Bus-switch SI0 to MI0 signals
    wire         i_sel0to0;         // Routing selection signal
    wire         i_active0to0;      // Active signal

    // Bus-switch SI0 to MI1 signals
    wire         i_sel0to1;         // Routing selection signal
    wire         i_active0to1;      // Active signal

    // Bus-switch SI0 to MI2 signals
    wire         i_sel0to2;         // Routing selection signal
    wire         i_active0to2;      // Active signal

    // Bus-switch SI0 to MI3 signals
    wire         i_sel0to3;         // Routing selection signal
    wire         i_active0to3;      // Active signal

    // Bus-switch SI0 to MI4 signals
    wire         i_sel0to4;         // Routing selection signal
    wire         i_active0to4;      // Active signal

    // Bus-switch SI0 to MI5 signals
    wire         i_sel0to5;         // Routing selection signal
    wire         i_active0to5;      // Active signal

    // Bus-switch SI0 to MI6 signals
    wire         i_sel0to6;         // Routing selection signal
    wire         i_active0to6;      // Active signal

    // Bus-switch SI0 to MI7 signals
    wire         i_sel0to7;         // Routing selection signal
    wire         i_active0to7;      // Active signal

    // Bus-switch SI1 to MI0 signals
    wire         i_sel1to0;         // Routing selection signal
    wire         i_active1to0;      // Active signal

    // Bus-switch SI1 to MI1 signals
    wire         i_sel1to1;         // Routing selection signal
    wire         i_active1to1;      // Active signal

    // Bus-switch SI1 to MI2 signals
    wire         i_sel1to2;         // Routing selection signal
    wire         i_active1to2;      // Active signal

    // Bus-switch SI1 to MI3 signals
    wire         i_sel1to3;         // Routing selection signal
    wire         i_active1to3;      // Active signal

    // Bus-switch SI1 to MI4 signals
    wire         i_sel1to4;         // Routing selection signal
    wire         i_active1to4;      // Active signal

    // Bus-switch SI1 to MI5 signals
    wire         i_sel1to5;         // Routing selection signal
    wire         i_active1to5;      // Active signal

    // Bus-switch SI1 to MI6 signals
    wire         i_sel1to6;         // Routing selection signal
    wire         i_active1to6;      // Active signal

    // Bus-switch SI2 to MI0 signals
    wire         i_sel2to0;         // Routing selection signal
    wire         i_active2to0;      // Active signal

    // Bus-switch SI2 to MI1 signals
    wire         i_sel2to1;         // Routing selection signal
    wire         i_active2to1;      // Active signal

    // Bus-switch SI2 to MI2 signals
    wire         i_sel2to2;         // Routing selection signal
    wire         i_active2to2;      // Active signal

    // Bus-switch SI2 to MI3 signals
    wire         i_sel2to3;         // Routing selection signal
    wire         i_active2to3;      // Active signal

    // Bus-switch SI2 to MI4 signals
    wire         i_sel2to4;         // Routing selection signal
    wire         i_active2to4;      // Active signal

    // Bus-switch SI2 to MI5 signals
    wire         i_sel2to5;         // Routing selection signal
    wire         i_active2to5;      // Active signal

    // Bus-switch SI2 to MI6 signals
    wire         i_sel2to6;         // Routing selection signal
    wire         i_active2to6;      // Active signal

    // Bus-switch SI3 to MI0 signals
    wire         i_sel3to0;         // Routing selection signal
    wire         i_active3to0;      // Active signal

    // Bus-switch SI3 to MI1 signals
    wire         i_sel3to1;         // Routing selection signal
    wire         i_active3to1;      // Active signal

    // Bus-switch SI3 to MI2 signals
    wire         i_sel3to2;         // Routing selection signal
    wire         i_active3to2;      // Active signal

    // Bus-switch SI3 to MI3 signals
    wire         i_sel3to3;         // Routing selection signal
    wire         i_active3to3;      // Active signal

    // Bus-switch SI3 to MI4 signals
    wire         i_sel3to4;         // Routing selection signal
    wire         i_active3to4;      // Active signal

    // Bus-switch SI3 to MI5 signals
    wire         i_sel3to5;         // Routing selection signal
    wire         i_active3to5;      // Active signal

    // Bus-switch SI3 to MI6 signals
    wire         i_sel3to6;         // Routing selection signal
    wire         i_active3to6;      // Active signal

    // Bus-switch SI3 to MI7 signals
    wire         i_sel3to7;         // Routing selection signal
    wire         i_active3to7;      // Active signal

    wire         i_hready_mux__bootrom_0;    // Internal HREADYMUXM for MI0
    wire         i_hready_mux__imem_0;    // Internal HREADYMUXM for MI1
    wire         i_hready_mux__dmem_0;    // Internal HREADYMUXM for MI2
    wire         i_hready_mux__sysio;    // Internal HREADYMUXM for MI3
    wire         i_hready_mux__expram_l;    // Internal HREADYMUXM for MI4
    wire         i_hready_mux__expram_h;    // Internal HREADYMUXM for MI5
    wire         i_hready_mux__exp;    // Internal HREADYMUXM for MI6
    wire         i_hready_mux__systable;    // Internal HREADYMUXM for MI7


// -----------------------------------------------------------------------------
// Beginning of main code
// -----------------------------------------------------------------------------

  // Input stage for SI0
  nanosoc_inititator_input u_nanosoc_inititator_input_0 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Input Port Address/Control Signals
    .HSELS      (HSEL_DEBUG),
    .HADDRS     (HADDR_DEBUG),
    .HTRANSS    (HTRANS_DEBUG),
    .HWRITES    (HWRITE_DEBUG),
    .HSIZES     (HSIZE_DEBUG),
    .HBURSTS    (HBURST_DEBUG),
    .HPROTS     (HPROT_DEBUG),
    .HMASTERS   (HMASTER_DEBUG),
    .HMASTLOCKS (HMASTLOCK_DEBUG),
    .HREADYS    (HREADY_DEBUG),

    // Internal Response
    .active_ip     (i_active0),
    .readyout_ip   (i_readyout0),
    .resp_ip       (i_resp0),

    // Input Port Response
    .HREADYOUTS (HREADYOUT_DEBUG),
    .HRESPS     (HRESP_DEBUG),

    // Internal Address/Control Signals
    .sel_ip        (i_sel0),
    .addr_ip       (i_addr0),
    .trans_ip      (i_trans0),
    .write_ip      (i_write0),
    .size_ip       (i_size0),
    .burst_ip      (i_burst0),
    .prot_ip       (i_prot0),
    .master_ip     (i_master0),
    .mastlock_ip   (i_mastlock0),
    .held_tran_ip   (i_held_tran0)

    );


  // Input stage for SI1
  nanosoc_inititator_input u_nanosoc_inititator_input_1 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Input Port Address/Control Signals
    .HSELS      (HSEL_DMAC_0),
    .HADDRS     (HADDR_DMAC_0),
    .HTRANSS    (HTRANS_DMAC_0),
    .HWRITES    (HWRITE_DMAC_0),
    .HSIZES     (HSIZE_DMAC_0),
    .HBURSTS    (HBURST_DMAC_0),
    .HPROTS     (HPROT_DMAC_0),
    .HMASTERS   (HMASTER_DMAC_0),
    .HMASTLOCKS (HMASTLOCK_DMAC_0),
    .HREADYS    (HREADY_DMAC_0),

    // Internal Response
    .active_ip     (i_active1),
    .readyout_ip   (i_readyout1),
    .resp_ip       (i_resp1),

    // Input Port Response
    .HREADYOUTS (HREADYOUT_DMAC_0),
    .HRESPS     (HRESP_DMAC_0),

    // Internal Address/Control Signals
    .sel_ip        (i_sel1),
    .addr_ip       (i_addr1),
    .trans_ip      (i_trans1),
    .write_ip      (i_write1),
    .size_ip       (i_size1),
    .burst_ip      (i_burst1),
    .prot_ip       (i_prot1),
    .master_ip     (i_master1),
    .mastlock_ip   (i_mastlock1),
    .held_tran_ip   (i_held_tran1)

    );


  // Input stage for SI2
  nanosoc_inititator_input u_nanosoc_inititator_input_2 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Input Port Address/Control Signals
    .HSELS      (HSEL_DMAC_1),
    .HADDRS     (HADDR_DMAC_1),
    .HTRANSS    (HTRANS_DMAC_1),
    .HWRITES    (HWRITE_DMAC_1),
    .HSIZES     (HSIZE_DMAC_1),
    .HBURSTS    (HBURST_DMAC_1),
    .HPROTS     (HPROT_DMAC_1),
    .HMASTERS   (HMASTER_DMAC_1),
    .HMASTLOCKS (HMASTLOCK_DMAC_1),
    .HREADYS    (HREADY_DMAC_1),

    // Internal Response
    .active_ip     (i_active2),
    .readyout_ip   (i_readyout2),
    .resp_ip       (i_resp2),

    // Input Port Response
    .HREADYOUTS (HREADYOUT_DMAC_1),
    .HRESPS     (HRESP_DMAC_1),

    // Internal Address/Control Signals
    .sel_ip        (i_sel2),
    .addr_ip       (i_addr2),
    .trans_ip      (i_trans2),
    .write_ip      (i_write2),
    .size_ip       (i_size2),
    .burst_ip      (i_burst2),
    .prot_ip       (i_prot2),
    .master_ip     (i_master2),
    .mastlock_ip   (i_mastlock2),
    .held_tran_ip   (i_held_tran2)

    );


  // Input stage for SI3
  nanosoc_inititator_input u_nanosoc_inititator_input_3 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Input Port Address/Control Signals
    .HSELS      (HSEL_CPU_0),
    .HADDRS     (HADDR_CPU_0),
    .HTRANSS    (HTRANS_CPU_0),
    .HWRITES    (HWRITE_CPU_0),
    .HSIZES     (HSIZE_CPU_0),
    .HBURSTS    (HBURST_CPU_0),
    .HPROTS     (HPROT_CPU_0),
    .HMASTERS   (HMASTER_CPU_0),
    .HMASTLOCKS (HMASTLOCK_CPU_0),
    .HREADYS    (HREADY_CPU_0),

    // Internal Response
    .active_ip     (i_active3),
    .readyout_ip   (i_readyout3),
    .resp_ip       (i_resp3),

    // Input Port Response
    .HREADYOUTS (HREADYOUT_CPU_0),
    .HRESPS     (HRESP_CPU_0),

    // Internal Address/Control Signals
    .sel_ip        (i_sel3),
    .addr_ip       (i_addr3),
    .trans_ip      (i_trans3),
    .write_ip      (i_write3),
    .size_ip       (i_size3),
    .burst_ip      (i_burst3),
    .prot_ip       (i_prot3),
    .master_ip     (i_master3),
    .mastlock_ip   (i_mastlock3),
    .held_tran_ip   (i_held_tran3)

    );


  // Matrix decoder for SI0
  nanosoc_matrix_decode_DEBUG u_nanosoc_matrix_decode_debug (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Internal address remapping control
    .remapping_dec  ( REMAP[0] ),

    // Signals from Input stage SI0
    .HREADYS    (HREADY_DEBUG),
    .sel_dec        (i_sel0),
    .decode_addr_dec (i_addr0[31:10]),   // HADDR[9:0] is not decoded
    .trans_dec      (i_trans0),

    // Control/Response for Output Stage MI0
    .active_dec0    (i_active0to0),
    .readyout_dec0  (i_hready_mux__bootrom_0),
    .resp_dec0      (HRESP_BOOTROM_0),
    .rdata_dec0     (HRDATA_BOOTROM_0),

    // Control/Response for Output Stage MI1
    .active_dec1    (i_active0to1),
    .readyout_dec1  (i_hready_mux__imem_0),
    .resp_dec1      (HRESP_IMEM_0),
    .rdata_dec1     (HRDATA_IMEM_0),

    // Control/Response for Output Stage MI2
    .active_dec2    (i_active0to2),
    .readyout_dec2  (i_hready_mux__dmem_0),
    .resp_dec2      (HRESP_DMEM_0),
    .rdata_dec2     (HRDATA_DMEM_0),

    // Control/Response for Output Stage MI3
    .active_dec3    (i_active0to3),
    .readyout_dec3  (i_hready_mux__sysio),
    .resp_dec3      (HRESP_SYSIO),
    .rdata_dec3     (HRDATA_SYSIO),

    // Control/Response for Output Stage MI4
    .active_dec4    (i_active0to4),
    .readyout_dec4  (i_hready_mux__expram_l),
    .resp_dec4      (HRESP_EXPRAM_L),
    .rdata_dec4     (HRDATA_EXPRAM_L),

    // Control/Response for Output Stage MI5
    .active_dec5    (i_active0to5),
    .readyout_dec5  (i_hready_mux__expram_h),
    .resp_dec5      (HRESP_EXPRAM_H),
    .rdata_dec5     (HRDATA_EXPRAM_H),

    // Control/Response for Output Stage MI6
    .active_dec6    (i_active0to6),
    .readyout_dec6  (i_hready_mux__exp),
    .resp_dec6      (HRESP_EXP),
    .rdata_dec6     (HRDATA_EXP),

    // Control/Response for Output Stage MI7
    .active_dec7    (i_active0to7),
    .readyout_dec7  (i_hready_mux__systable),
    .resp_dec7      (HRESP_SYSTABLE),
    .rdata_dec7     (HRDATA_SYSTABLE),

    .sel_dec0       (i_sel0to0),
    .sel_dec1       (i_sel0to1),
    .sel_dec2       (i_sel0to2),
    .sel_dec3       (i_sel0to3),
    .sel_dec4       (i_sel0to4),
    .sel_dec5       (i_sel0to5),
    .sel_dec6       (i_sel0to6),
    .sel_dec7       (i_sel0to7),

    .active_dec     (i_active0),
    .HREADYOUTS (i_readyout0),
    .HRESPS     (i_resp0),
    .HRDATAS    (HRDATA_DEBUG)

    );


  // Matrix decoder for SI1
  nanosoc_matrix_decode_DMAC_0 u_nanosoc_matrix_decode_dmac_0 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Signals from Input stage SI1
    .HREADYS    (HREADY_DMAC_0),
    .sel_dec        (i_sel1),
    .decode_addr_dec (i_addr1[31:10]),   // HADDR[9:0] is not decoded
    .trans_dec      (i_trans1),

    // Control/Response for Output Stage MI0
    .active_dec0    (i_active1to0),
    .readyout_dec0  (i_hready_mux__bootrom_0),
    .resp_dec0      (HRESP_BOOTROM_0),
    .rdata_dec0     (HRDATA_BOOTROM_0),

    // Control/Response for Output Stage MI1
    .active_dec1    (i_active1to1),
    .readyout_dec1  (i_hready_mux__imem_0),
    .resp_dec1      (HRESP_IMEM_0),
    .rdata_dec1     (HRDATA_IMEM_0),

    // Control/Response for Output Stage MI2
    .active_dec2    (i_active1to2),
    .readyout_dec2  (i_hready_mux__dmem_0),
    .resp_dec2      (HRESP_DMEM_0),
    .rdata_dec2     (HRDATA_DMEM_0),

    // Control/Response for Output Stage MI3
    .active_dec3    (i_active1to3),
    .readyout_dec3  (i_hready_mux__sysio),
    .resp_dec3      (HRESP_SYSIO),
    .rdata_dec3     (HRDATA_SYSIO),

    // Control/Response for Output Stage MI4
    .active_dec4    (i_active1to4),
    .readyout_dec4  (i_hready_mux__expram_l),
    .resp_dec4      (HRESP_EXPRAM_L),
    .rdata_dec4     (HRDATA_EXPRAM_L),

    // Control/Response for Output Stage MI5
    .active_dec5    (i_active1to5),
    .readyout_dec5  (i_hready_mux__expram_h),
    .resp_dec5      (HRESP_EXPRAM_H),
    .rdata_dec5     (HRDATA_EXPRAM_H),

    // Control/Response for Output Stage MI6
    .active_dec6    (i_active1to6),
    .readyout_dec6  (i_hready_mux__exp),
    .resp_dec6      (HRESP_EXP),
    .rdata_dec6     (HRDATA_EXP),

    .sel_dec0       (i_sel1to0),
    .sel_dec1       (i_sel1to1),
    .sel_dec2       (i_sel1to2),
    .sel_dec3       (i_sel1to3),
    .sel_dec4       (i_sel1to4),
    .sel_dec5       (i_sel1to5),
    .sel_dec6       (i_sel1to6),

    .active_dec     (i_active1),
    .HREADYOUTS (i_readyout1),
    .HRESPS     (i_resp1),
    .HRDATAS    (HRDATA_DMAC_0)

    );


  // Matrix decoder for SI2
  nanosoc_matrix_decode_DMAC_1 u_nanosoc_matrix_decode_dmac_1 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Signals from Input stage SI2
    .HREADYS    (HREADY_DMAC_1),
    .sel_dec        (i_sel2),
    .decode_addr_dec (i_addr2[31:10]),   // HADDR[9:0] is not decoded
    .trans_dec      (i_trans2),

    // Control/Response for Output Stage MI0
    .active_dec0    (i_active2to0),
    .readyout_dec0  (i_hready_mux__bootrom_0),
    .resp_dec0      (HRESP_BOOTROM_0),
    .rdata_dec0     (HRDATA_BOOTROM_0),

    // Control/Response for Output Stage MI1
    .active_dec1    (i_active2to1),
    .readyout_dec1  (i_hready_mux__imem_0),
    .resp_dec1      (HRESP_IMEM_0),
    .rdata_dec1     (HRDATA_IMEM_0),

    // Control/Response for Output Stage MI2
    .active_dec2    (i_active2to2),
    .readyout_dec2  (i_hready_mux__dmem_0),
    .resp_dec2      (HRESP_DMEM_0),
    .rdata_dec2     (HRDATA_DMEM_0),

    // Control/Response for Output Stage MI3
    .active_dec3    (i_active2to3),
    .readyout_dec3  (i_hready_mux__sysio),
    .resp_dec3      (HRESP_SYSIO),
    .rdata_dec3     (HRDATA_SYSIO),

    // Control/Response for Output Stage MI4
    .active_dec4    (i_active2to4),
    .readyout_dec4  (i_hready_mux__expram_l),
    .resp_dec4      (HRESP_EXPRAM_L),
    .rdata_dec4     (HRDATA_EXPRAM_L),

    // Control/Response for Output Stage MI5
    .active_dec5    (i_active2to5),
    .readyout_dec5  (i_hready_mux__expram_h),
    .resp_dec5      (HRESP_EXPRAM_H),
    .rdata_dec5     (HRDATA_EXPRAM_H),

    // Control/Response for Output Stage MI6
    .active_dec6    (i_active2to6),
    .readyout_dec6  (i_hready_mux__exp),
    .resp_dec6      (HRESP_EXP),
    .rdata_dec6     (HRDATA_EXP),

    .sel_dec0       (i_sel2to0),
    .sel_dec1       (i_sel2to1),
    .sel_dec2       (i_sel2to2),
    .sel_dec3       (i_sel2to3),
    .sel_dec4       (i_sel2to4),
    .sel_dec5       (i_sel2to5),
    .sel_dec6       (i_sel2to6),

    .active_dec     (i_active2),
    .HREADYOUTS (i_readyout2),
    .HRESPS     (i_resp2),
    .HRDATAS    (HRDATA_DMAC_1)

    );


  // Matrix decoder for SI3
  nanosoc_matrix_decode_CPU_0 u_nanosoc_matrix_decode_cpu_0 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Internal address remapping control
    .remapping_dec  ( REMAP[0] ),

    // Signals from Input stage SI3
    .HREADYS    (HREADY_CPU_0),
    .sel_dec        (i_sel3),
    .decode_addr_dec (i_addr3[31:10]),   // HADDR[9:0] is not decoded
    .trans_dec      (i_trans3),

    // Control/Response for Output Stage MI0
    .active_dec0    (i_active3to0),
    .readyout_dec0  (i_hready_mux__bootrom_0),
    .resp_dec0      (HRESP_BOOTROM_0),
    .rdata_dec0     (HRDATA_BOOTROM_0),

    // Control/Response for Output Stage MI1
    .active_dec1    (i_active3to1),
    .readyout_dec1  (i_hready_mux__imem_0),
    .resp_dec1      (HRESP_IMEM_0),
    .rdata_dec1     (HRDATA_IMEM_0),

    // Control/Response for Output Stage MI2
    .active_dec2    (i_active3to2),
    .readyout_dec2  (i_hready_mux__dmem_0),
    .resp_dec2      (HRESP_DMEM_0),
    .rdata_dec2     (HRDATA_DMEM_0),

    // Control/Response for Output Stage MI3
    .active_dec3    (i_active3to3),
    .readyout_dec3  (i_hready_mux__sysio),
    .resp_dec3      (HRESP_SYSIO),
    .rdata_dec3     (HRDATA_SYSIO),

    // Control/Response for Output Stage MI4
    .active_dec4    (i_active3to4),
    .readyout_dec4  (i_hready_mux__expram_l),
    .resp_dec4      (HRESP_EXPRAM_L),
    .rdata_dec4     (HRDATA_EXPRAM_L),

    // Control/Response for Output Stage MI5
    .active_dec5    (i_active3to5),
    .readyout_dec5  (i_hready_mux__expram_h),
    .resp_dec5      (HRESP_EXPRAM_H),
    .rdata_dec5     (HRDATA_EXPRAM_H),

    // Control/Response for Output Stage MI6
    .active_dec6    (i_active3to6),
    .readyout_dec6  (i_hready_mux__exp),
    .resp_dec6      (HRESP_EXP),
    .rdata_dec6     (HRDATA_EXP),

    // Control/Response for Output Stage MI7
    .active_dec7    (i_active3to7),
    .readyout_dec7  (i_hready_mux__systable),
    .resp_dec7      (HRESP_SYSTABLE),
    .rdata_dec7     (HRDATA_SYSTABLE),

    .sel_dec0       (i_sel3to0),
    .sel_dec1       (i_sel3to1),
    .sel_dec2       (i_sel3to2),
    .sel_dec3       (i_sel3to3),
    .sel_dec4       (i_sel3to4),
    .sel_dec5       (i_sel3to5),
    .sel_dec6       (i_sel3to6),
    .sel_dec7       (i_sel3to7),

    .active_dec     (i_active3),
    .HREADYOUTS (i_readyout3),
    .HRESPS     (i_resp3),
    .HRDATAS    (HRDATA_CPU_0)

    );


  // Output stage for MI0
  nanosoc_target_output_BOOTROM_0 u_nanosoc_target_output_bootrom_0_0 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to0),
    .addr_op0      (i_addr0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATA_DEBUG),
    .held_tran_op0  (i_held_tran0),

    // Port 1 Signals
    .sel_op1       (i_sel1to0),
    .addr_op1      (i_addr1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATA_DMAC_0),
    .held_tran_op1  (i_held_tran1),

    // Port 2 Signals
    .sel_op2       (i_sel2to0),
    .addr_op2      (i_addr2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATA_DMAC_1),
    .held_tran_op2  (i_held_tran2),

    // Port 3 Signals
    .sel_op3       (i_sel3to0),
    .addr_op3      (i_addr3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATA_CPU_0),
    .held_tran_op3  (i_held_tran3),

    // Slave read data and response
    .HREADYOUTM (HREADYOUT_BOOTROM_0),

    .active_op0    (i_active0to0),
    .active_op1    (i_active1to0),
    .active_op2    (i_active2to0),
    .active_op3    (i_active3to0),

    // Slave Address/Control Signals
    .HSELM      (HSEL_BOOTROM_0),
    .HADDRM     (HADDR_BOOTROM_0),
    .HTRANSM    (HTRANS_BOOTROM_0),
    .HWRITEM    (HWRITE_BOOTROM_0),
    .HSIZEM     (HSIZE_BOOTROM_0),
    .HBURSTM    (HBURST_BOOTROM_0),
    .HPROTM     (HPROT_BOOTROM_0),
    .HMASTERM   (HMASTER_BOOTROM_0),
    .HMASTLOCKM (HMASTLOCK_BOOTROM_0),
    .HREADYMUXM (i_hready_mux__bootrom_0),
    .HWDATAM    (HWDATA_BOOTROM_0)

    );

  // Drive output with internal version
  assign HREADYMUX_BOOTROM_0 = i_hready_mux__bootrom_0;


  // Output stage for MI1
  nanosoc_target_output_IMEM_0 u_nanosoc_target_output_imem_0_1 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to1),
    .addr_op0      (i_addr0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATA_DEBUG),
    .held_tran_op0  (i_held_tran0),

    // Port 1 Signals
    .sel_op1       (i_sel1to1),
    .addr_op1      (i_addr1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATA_DMAC_0),
    .held_tran_op1  (i_held_tran1),

    // Port 2 Signals
    .sel_op2       (i_sel2to1),
    .addr_op2      (i_addr2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATA_DMAC_1),
    .held_tran_op2  (i_held_tran2),

    // Port 3 Signals
    .sel_op3       (i_sel3to1),
    .addr_op3      (i_addr3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATA_CPU_0),
    .held_tran_op3  (i_held_tran3),

    // Slave read data and response
    .HREADYOUTM (HREADYOUT_IMEM_0),

    .active_op0    (i_active0to1),
    .active_op1    (i_active1to1),
    .active_op2    (i_active2to1),
    .active_op3    (i_active3to1),

    // Slave Address/Control Signals
    .HSELM      (HSEL_IMEM_0),
    .HADDRM     (HADDR_IMEM_0),
    .HTRANSM    (HTRANS_IMEM_0),
    .HWRITEM    (HWRITE_IMEM_0),
    .HSIZEM     (HSIZE_IMEM_0),
    .HBURSTM    (HBURST_IMEM_0),
    .HPROTM     (HPROT_IMEM_0),
    .HMASTERM   (HMASTER_IMEM_0),
    .HMASTLOCKM (HMASTLOCK_IMEM_0),
    .HREADYMUXM (i_hready_mux__imem_0),
    .HWDATAM    (HWDATA_IMEM_0)

    );

  // Drive output with internal version
  assign HREADYMUX_IMEM_0 = i_hready_mux__imem_0;


  // Output stage for MI2
  nanosoc_target_output_DMEM_0 u_nanosoc_target_output_dmem_0_2 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to2),
    .addr_op0      (i_addr0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATA_DEBUG),
    .held_tran_op0  (i_held_tran0),

    // Port 1 Signals
    .sel_op1       (i_sel1to2),
    .addr_op1      (i_addr1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATA_DMAC_0),
    .held_tran_op1  (i_held_tran1),

    // Port 2 Signals
    .sel_op2       (i_sel2to2),
    .addr_op2      (i_addr2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATA_DMAC_1),
    .held_tran_op2  (i_held_tran2),

    // Port 3 Signals
    .sel_op3       (i_sel3to2),
    .addr_op3      (i_addr3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATA_CPU_0),
    .held_tran_op3  (i_held_tran3),

    // Slave read data and response
    .HREADYOUTM (HREADYOUT_DMEM_0),

    .active_op0    (i_active0to2),
    .active_op1    (i_active1to2),
    .active_op2    (i_active2to2),
    .active_op3    (i_active3to2),

    // Slave Address/Control Signals
    .HSELM      (HSEL_DMEM_0),
    .HADDRM     (HADDR_DMEM_0),
    .HTRANSM    (HTRANS_DMEM_0),
    .HWRITEM    (HWRITE_DMEM_0),
    .HSIZEM     (HSIZE_DMEM_0),
    .HBURSTM    (HBURST_DMEM_0),
    .HPROTM     (HPROT_DMEM_0),
    .HMASTERM   (HMASTER_DMEM_0),
    .HMASTLOCKM (HMASTLOCK_DMEM_0),
    .HREADYMUXM (i_hready_mux__dmem_0),
    .HWDATAM    (HWDATA_DMEM_0)

    );

  // Drive output with internal version
  assign HREADYMUX_DMEM_0 = i_hready_mux__dmem_0;


  // Output stage for MI3
  nanosoc_target_output_SYSIO u_nanosoc_target_output_sysio_3 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to3),
    .addr_op0      (i_addr0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATA_DEBUG),
    .held_tran_op0  (i_held_tran0),

    // Port 1 Signals
    .sel_op1       (i_sel1to3),
    .addr_op1      (i_addr1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATA_DMAC_0),
    .held_tran_op1  (i_held_tran1),

    // Port 2 Signals
    .sel_op2       (i_sel2to3),
    .addr_op2      (i_addr2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATA_DMAC_1),
    .held_tran_op2  (i_held_tran2),

    // Port 3 Signals
    .sel_op3       (i_sel3to3),
    .addr_op3      (i_addr3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATA_CPU_0),
    .held_tran_op3  (i_held_tran3),

    // Slave read data and response
    .HREADYOUTM (HREADYOUT_SYSIO),

    .active_op0    (i_active0to3),
    .active_op1    (i_active1to3),
    .active_op2    (i_active2to3),
    .active_op3    (i_active3to3),

    // Slave Address/Control Signals
    .HSELM      (HSEL_SYSIO),
    .HADDRM     (HADDR_SYSIO),
    .HTRANSM    (HTRANS_SYSIO),
    .HWRITEM    (HWRITE_SYSIO),
    .HSIZEM     (HSIZE_SYSIO),
    .HBURSTM    (HBURST_SYSIO),
    .HPROTM     (HPROT_SYSIO),
    .HMASTERM   (HMASTER_SYSIO),
    .HMASTLOCKM (HMASTLOCK_SYSIO),
    .HREADYMUXM (i_hready_mux__sysio),
    .HWDATAM    (HWDATA_SYSIO)

    );

  // Drive output with internal version
  assign HREADYMUX_SYSIO = i_hready_mux__sysio;


  // Output stage for MI4
  nanosoc_target_output_EXPRAM_L u_nanosoc_target_output_expram_l_4 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to4),
    .addr_op0      (i_addr0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATA_DEBUG),
    .held_tran_op0  (i_held_tran0),

    // Port 1 Signals
    .sel_op1       (i_sel1to4),
    .addr_op1      (i_addr1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATA_DMAC_0),
    .held_tran_op1  (i_held_tran1),

    // Port 2 Signals
    .sel_op2       (i_sel2to4),
    .addr_op2      (i_addr2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATA_DMAC_1),
    .held_tran_op2  (i_held_tran2),

    // Port 3 Signals
    .sel_op3       (i_sel3to4),
    .addr_op3      (i_addr3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATA_CPU_0),
    .held_tran_op3  (i_held_tran3),

    // Slave read data and response
    .HREADYOUTM (HREADYOUT_EXPRAM_L),

    .active_op0    (i_active0to4),
    .active_op1    (i_active1to4),
    .active_op2    (i_active2to4),
    .active_op3    (i_active3to4),

    // Slave Address/Control Signals
    .HSELM      (HSEL_EXPRAM_L),
    .HADDRM     (HADDR_EXPRAM_L),
    .HTRANSM    (HTRANS_EXPRAM_L),
    .HWRITEM    (HWRITE_EXPRAM_L),
    .HSIZEM     (HSIZE_EXPRAM_L),
    .HBURSTM    (HBURST_EXPRAM_L),
    .HPROTM     (HPROT_EXPRAM_L),
    .HMASTERM   (HMASTER_EXPRAM_L),
    .HMASTLOCKM (HMASTLOCK_EXPRAM_L),
    .HREADYMUXM (i_hready_mux__expram_l),
    .HWDATAM    (HWDATA_EXPRAM_L)

    );

  // Drive output with internal version
  assign HREADYMUX_EXPRAM_L = i_hready_mux__expram_l;


  // Output stage for MI5
  nanosoc_target_output_EXPRAM_H u_nanosoc_target_output_expram_h_5 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to5),
    .addr_op0      (i_addr0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATA_DEBUG),
    .held_tran_op0  (i_held_tran0),

    // Port 1 Signals
    .sel_op1       (i_sel1to5),
    .addr_op1      (i_addr1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATA_DMAC_0),
    .held_tran_op1  (i_held_tran1),

    // Port 2 Signals
    .sel_op2       (i_sel2to5),
    .addr_op2      (i_addr2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATA_DMAC_1),
    .held_tran_op2  (i_held_tran2),

    // Port 3 Signals
    .sel_op3       (i_sel3to5),
    .addr_op3      (i_addr3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATA_CPU_0),
    .held_tran_op3  (i_held_tran3),

    // Slave read data and response
    .HREADYOUTM (HREADYOUT_EXPRAM_H),

    .active_op0    (i_active0to5),
    .active_op1    (i_active1to5),
    .active_op2    (i_active2to5),
    .active_op3    (i_active3to5),

    // Slave Address/Control Signals
    .HSELM      (HSEL_EXPRAM_H),
    .HADDRM     (HADDR_EXPRAM_H),
    .HTRANSM    (HTRANS_EXPRAM_H),
    .HWRITEM    (HWRITE_EXPRAM_H),
    .HSIZEM     (HSIZE_EXPRAM_H),
    .HBURSTM    (HBURST_EXPRAM_H),
    .HPROTM     (HPROT_EXPRAM_H),
    .HMASTERM   (HMASTER_EXPRAM_H),
    .HMASTLOCKM (HMASTLOCK_EXPRAM_H),
    .HREADYMUXM (i_hready_mux__expram_h),
    .HWDATAM    (HWDATA_EXPRAM_H)

    );

  // Drive output with internal version
  assign HREADYMUX_EXPRAM_H = i_hready_mux__expram_h;


  // Output stage for MI6
  nanosoc_target_output_EXP u_nanosoc_target_output_exp_6 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to6),
    .addr_op0      (i_addr0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATA_DEBUG),
    .held_tran_op0  (i_held_tran0),

    // Port 1 Signals
    .sel_op1       (i_sel1to6),
    .addr_op1      (i_addr1),
    .trans_op1     (i_trans1),
    .write_op1     (i_write1),
    .size_op1      (i_size1),
    .burst_op1     (i_burst1),
    .prot_op1      (i_prot1),
    .master_op1    (i_master1),
    .mastlock_op1  (i_mastlock1),
    .wdata_op1     (HWDATA_DMAC_0),
    .held_tran_op1  (i_held_tran1),

    // Port 2 Signals
    .sel_op2       (i_sel2to6),
    .addr_op2      (i_addr2),
    .trans_op2     (i_trans2),
    .write_op2     (i_write2),
    .size_op2      (i_size2),
    .burst_op2     (i_burst2),
    .prot_op2      (i_prot2),
    .master_op2    (i_master2),
    .mastlock_op2  (i_mastlock2),
    .wdata_op2     (HWDATA_DMAC_1),
    .held_tran_op2  (i_held_tran2),

    // Port 3 Signals
    .sel_op3       (i_sel3to6),
    .addr_op3      (i_addr3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATA_CPU_0),
    .held_tran_op3  (i_held_tran3),

    // Slave read data and response
    .HREADYOUTM (HREADYOUT_EXP),

    .active_op0    (i_active0to6),
    .active_op1    (i_active1to6),
    .active_op2    (i_active2to6),
    .active_op3    (i_active3to6),

    // Slave Address/Control Signals
    .HSELM      (HSEL_EXP),
    .HADDRM     (HADDR_EXP),
    .HTRANSM    (HTRANS_EXP),
    .HWRITEM    (HWRITE_EXP),
    .HSIZEM     (HSIZE_EXP),
    .HBURSTM    (HBURST_EXP),
    .HPROTM     (HPROT_EXP),
    .HMASTERM   (HMASTER_EXP),
    .HMASTLOCKM (HMASTLOCK_EXP),
    .HREADYMUXM (i_hready_mux__exp),
    .HWDATAM    (HWDATA_EXP)

    );

  // Drive output with internal version
  assign HREADYMUX_EXP = i_hready_mux__exp;


  // Output stage for MI7
  nanosoc_target_output_SYSTABLE u_nanosoc_target_output_systable_7 (

    // Common AHB signals
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),

    // Port 0 Signals
    .sel_op0       (i_sel0to7),
    .addr_op0      (i_addr0),
    .trans_op0     (i_trans0),
    .write_op0     (i_write0),
    .size_op0      (i_size0),
    .burst_op0     (i_burst0),
    .prot_op0      (i_prot0),
    .master_op0    (i_master0),
    .mastlock_op0  (i_mastlock0),
    .wdata_op0     (HWDATA_DEBUG),
    .held_tran_op0  (i_held_tran0),

    // Port 3 Signals
    .sel_op3       (i_sel3to7),
    .addr_op3      (i_addr3),
    .trans_op3     (i_trans3),
    .write_op3     (i_write3),
    .size_op3      (i_size3),
    .burst_op3     (i_burst3),
    .prot_op3      (i_prot3),
    .master_op3    (i_master3),
    .mastlock_op3  (i_mastlock3),
    .wdata_op3     (HWDATA_CPU_0),
    .held_tran_op3  (i_held_tran3),

    // Slave read data and response
    .HREADYOUTM (HREADYOUT_SYSTABLE),

    .active_op0    (i_active0to7),
    .active_op3    (i_active3to7),

    // Slave Address/Control Signals
    .HSELM      (HSEL_SYSTABLE),
    .HADDRM     (HADDR_SYSTABLE),
    .HTRANSM    (HTRANS_SYSTABLE),
    .HWRITEM    (HWRITE_SYSTABLE),
    .HSIZEM     (HSIZE_SYSTABLE),
    .HBURSTM    (HBURST_SYSTABLE),
    .HPROTM     (HPROT_SYSTABLE),
    .HMASTERM   (HMASTER_SYSTABLE),
    .HMASTLOCKM (HMASTLOCK_SYSTABLE),
    .HREADYMUXM (i_hready_mux__systable),
    .HWDATAM    (HWDATA_SYSTABLE)

    );

  // Drive output with internal version
  assign HREADYMUX_SYSTABLE = i_hready_mux__systable;


endmodule

// --================================= End ===================================--
