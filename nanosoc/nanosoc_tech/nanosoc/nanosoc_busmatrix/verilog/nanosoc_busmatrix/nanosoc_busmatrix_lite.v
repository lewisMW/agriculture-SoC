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
//  Abstract            : BusMatrixLite is a wrapper module that wraps around
//                        the BusMatrix module to give AHB Lite compliant
//                        slave and master interfaces.
//
//-----------------------------------------------------------------------------



module nanosoc_busmatrix_lite (

    // Common AHB signals
    HCLK,
    HRESETn,

    // System Address Remap control
    REMAP,

    // Input port SI0 (inputs from master 0)
    HADDR_DEBUG,
    HTRANS_DEBUG,
    HWRITE_DEBUG,
    HSIZE_DEBUG,
    HBURST_DEBUG,
    HPROT_DEBUG,
    HWDATA_DEBUG,
    HMASTLOCK_DEBUG,

    // Input port SI1 (inputs from master 1)
    HADDR_DMAC_0,
    HTRANS_DMAC_0,
    HWRITE_DMAC_0,
    HSIZE_DMAC_0,
    HBURST_DMAC_0,
    HPROT_DMAC_0,
    HWDATA_DMAC_0,
    HMASTLOCK_DMAC_0,

    // Input port SI2 (inputs from master 2)
    HADDR_DMAC_1,
    HTRANS_DMAC_1,
    HWRITE_DMAC_1,
    HSIZE_DMAC_1,
    HBURST_DMAC_1,
    HPROT_DMAC_1,
    HWDATA_DMAC_1,
    HMASTLOCK_DMAC_1,

    // Input port SI3 (inputs from master 3)
    HADDR_CPU_0,
    HTRANS_CPU_0,
    HWRITE_CPU_0,
    HSIZE_CPU_0,
    HBURST_CPU_0,
    HPROT_CPU_0,
    HWDATA_CPU_0,
    HMASTLOCK_CPU_0,

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
    HWDATA_SYSTABLE,
    HMASTLOCK_SYSTABLE,
    HREADYMUX_SYSTABLE,

    // Input port SI0 (outputs to master 0)
    HRDATA_DEBUG,
    HREADY_DEBUG,
    HRESP_DEBUG,

    // Input port SI1 (outputs to master 1)
    HRDATA_DMAC_0,
    HREADY_DMAC_0,
    HRESP_DMAC_0,

    // Input port SI2 (outputs to master 2)
    HRDATA_DMAC_1,
    HREADY_DMAC_1,
    HRESP_DMAC_1,

    // Input port SI3 (outputs to master 3)
    HRDATA_CPU_0,
    HREADY_CPU_0,
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

    // System Address Remap control
    input   [3:0] REMAP;           // System Address REMAP control

    // Input port SI0 (inputs from master 0)
    input  [31:0] HADDR_DEBUG;         // Address bus
    input   [1:0] HTRANS_DEBUG;        // Transfer type
    input         HWRITE_DEBUG;        // Transfer direction
    input   [2:0] HSIZE_DEBUG;         // Transfer size
    input   [2:0] HBURST_DEBUG;        // Burst type
    input   [3:0] HPROT_DEBUG;         // Protection control
    input  [31:0] HWDATA_DEBUG;        // Write data
    input         HMASTLOCK_DEBUG;     // Locked Sequence

    // Input port SI1 (inputs from master 1)
    input  [31:0] HADDR_DMAC_0;         // Address bus
    input   [1:0] HTRANS_DMAC_0;        // Transfer type
    input         HWRITE_DMAC_0;        // Transfer direction
    input   [2:0] HSIZE_DMAC_0;         // Transfer size
    input   [2:0] HBURST_DMAC_0;        // Burst type
    input   [3:0] HPROT_DMAC_0;         // Protection control
    input  [31:0] HWDATA_DMAC_0;        // Write data
    input         HMASTLOCK_DMAC_0;     // Locked Sequence

    // Input port SI2 (inputs from master 2)
    input  [31:0] HADDR_DMAC_1;         // Address bus
    input   [1:0] HTRANS_DMAC_1;        // Transfer type
    input         HWRITE_DMAC_1;        // Transfer direction
    input   [2:0] HSIZE_DMAC_1;         // Transfer size
    input   [2:0] HBURST_DMAC_1;        // Burst type
    input   [3:0] HPROT_DMAC_1;         // Protection control
    input  [31:0] HWDATA_DMAC_1;        // Write data
    input         HMASTLOCK_DMAC_1;     // Locked Sequence

    // Input port SI3 (inputs from master 3)
    input  [31:0] HADDR_CPU_0;         // Address bus
    input   [1:0] HTRANS_CPU_0;        // Transfer type
    input         HWRITE_CPU_0;        // Transfer direction
    input   [2:0] HSIZE_CPU_0;         // Transfer size
    input   [2:0] HBURST_CPU_0;        // Burst type
    input   [3:0] HPROT_CPU_0;         // Protection control
    input  [31:0] HWDATA_CPU_0;        // Write data
    input         HMASTLOCK_CPU_0;     // Locked Sequence

    // Output port MI0 (inputs from slave 0)
    input  [31:0] HRDATA_BOOTROM_0;        // Read data bus
    input         HREADYOUT_BOOTROM_0;     // HREADY feedback
    input         HRESP_BOOTROM_0;         // Transfer response

    // Output port MI1 (inputs from slave 1)
    input  [31:0] HRDATA_IMEM_0;        // Read data bus
    input         HREADYOUT_IMEM_0;     // HREADY feedback
    input         HRESP_IMEM_0;         // Transfer response

    // Output port MI2 (inputs from slave 2)
    input  [31:0] HRDATA_DMEM_0;        // Read data bus
    input         HREADYOUT_DMEM_0;     // HREADY feedback
    input         HRESP_DMEM_0;         // Transfer response

    // Output port MI3 (inputs from slave 3)
    input  [31:0] HRDATA_SYSIO;        // Read data bus
    input         HREADYOUT_SYSIO;     // HREADY feedback
    input         HRESP_SYSIO;         // Transfer response

    // Output port MI4 (inputs from slave 4)
    input  [31:0] HRDATA_EXPRAM_L;        // Read data bus
    input         HREADYOUT_EXPRAM_L;     // HREADY feedback
    input         HRESP_EXPRAM_L;         // Transfer response

    // Output port MI5 (inputs from slave 5)
    input  [31:0] HRDATA_EXPRAM_H;        // Read data bus
    input         HREADYOUT_EXPRAM_H;     // HREADY feedback
    input         HRESP_EXPRAM_H;         // Transfer response

    // Output port MI6 (inputs from slave 6)
    input  [31:0] HRDATA_EXP;        // Read data bus
    input         HREADYOUT_EXP;     // HREADY feedback
    input         HRESP_EXP;         // Transfer response

    // Output port MI7 (inputs from slave 7)
    input  [31:0] HRDATA_SYSTABLE;        // Read data bus
    input         HREADYOUT_SYSTABLE;     // HREADY feedback
    input         HRESP_SYSTABLE;         // Transfer response

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
    output [31:0] HWDATA_SYSTABLE;        // Write data
    output        HMASTLOCK_SYSTABLE;     // Locked Sequence
    output        HREADYMUX_SYSTABLE;     // Transfer done

    // Input port SI0 (outputs to master 0)
    output [31:0] HRDATA_DEBUG;        // Read data bus
    output        HREADY_DEBUG;     // HREADY feedback
    output        HRESP_DEBUG;         // Transfer response

    // Input port SI1 (outputs to master 1)
    output [31:0] HRDATA_DMAC_0;        // Read data bus
    output        HREADY_DMAC_0;     // HREADY feedback
    output        HRESP_DMAC_0;         // Transfer response

    // Input port SI2 (outputs to master 2)
    output [31:0] HRDATA_DMAC_1;        // Read data bus
    output        HREADY_DMAC_1;     // HREADY feedback
    output        HRESP_DMAC_1;         // Transfer response

    // Input port SI3 (outputs to master 3)
    output [31:0] HRDATA_CPU_0;        // Read data bus
    output        HREADY_CPU_0;     // HREADY feedback
    output        HRESP_CPU_0;         // Transfer response

    // Scan test dummy signals; not connected until scan insertion
    output        SCANOUTHCLK;     // Scan Chain Output

// -----------------------------------------------------------------------------
// Wire declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    wire         HCLK;            // AHB System Clock
    wire         HRESETn;         // AHB System Reset

    // System Address Remap control
    wire   [3:0] REMAP;           // System REMAP signal

    // Input Port SI0
    wire  [31:0] HADDR_DEBUG;         // Address bus
    wire   [1:0] HTRANS_DEBUG;        // Transfer type
    wire         HWRITE_DEBUG;        // Transfer direction
    wire   [2:0] HSIZE_DEBUG;         // Transfer size
    wire   [2:0] HBURST_DEBUG;        // Burst type
    wire   [3:0] HPROT_DEBUG;         // Protection control
    wire  [31:0] HWDATA_DEBUG;        // Write data
    wire         HMASTLOCK_DEBUG;     // Locked Sequence

    wire  [31:0] HRDATA_DEBUG;        // Read data bus
    wire         HREADY_DEBUG;     // HREADY feedback
    wire         HRESP_DEBUG;         // Transfer response

    // Input Port SI1
    wire  [31:0] HADDR_DMAC_0;         // Address bus
    wire   [1:0] HTRANS_DMAC_0;        // Transfer type
    wire         HWRITE_DMAC_0;        // Transfer direction
    wire   [2:0] HSIZE_DMAC_0;         // Transfer size
    wire   [2:0] HBURST_DMAC_0;        // Burst type
    wire   [3:0] HPROT_DMAC_0;         // Protection control
    wire  [31:0] HWDATA_DMAC_0;        // Write data
    wire         HMASTLOCK_DMAC_0;     // Locked Sequence

    wire  [31:0] HRDATA_DMAC_0;        // Read data bus
    wire         HREADY_DMAC_0;     // HREADY feedback
    wire         HRESP_DMAC_0;         // Transfer response

    // Input Port SI2
    wire  [31:0] HADDR_DMAC_1;         // Address bus
    wire   [1:0] HTRANS_DMAC_1;        // Transfer type
    wire         HWRITE_DMAC_1;        // Transfer direction
    wire   [2:0] HSIZE_DMAC_1;         // Transfer size
    wire   [2:0] HBURST_DMAC_1;        // Burst type
    wire   [3:0] HPROT_DMAC_1;         // Protection control
    wire  [31:0] HWDATA_DMAC_1;        // Write data
    wire         HMASTLOCK_DMAC_1;     // Locked Sequence

    wire  [31:0] HRDATA_DMAC_1;        // Read data bus
    wire         HREADY_DMAC_1;     // HREADY feedback
    wire         HRESP_DMAC_1;         // Transfer response

    // Input Port SI3
    wire  [31:0] HADDR_CPU_0;         // Address bus
    wire   [1:0] HTRANS_CPU_0;        // Transfer type
    wire         HWRITE_CPU_0;        // Transfer direction
    wire   [2:0] HSIZE_CPU_0;         // Transfer size
    wire   [2:0] HBURST_CPU_0;        // Burst type
    wire   [3:0] HPROT_CPU_0;         // Protection control
    wire  [31:0] HWDATA_CPU_0;        // Write data
    wire         HMASTLOCK_CPU_0;     // Locked Sequence

    wire  [31:0] HRDATA_CPU_0;        // Read data bus
    wire         HREADY_CPU_0;     // HREADY feedback
    wire         HRESP_CPU_0;         // Transfer response

    // Output Port MI0
    wire         HSEL_BOOTROM_0;          // Slave Select
    wire  [31:0] HADDR_BOOTROM_0;         // Address bus
    wire   [1:0] HTRANS_BOOTROM_0;        // Transfer type
    wire         HWRITE_BOOTROM_0;        // Transfer direction
    wire   [2:0] HSIZE_BOOTROM_0;         // Transfer size
    wire   [2:0] HBURST_BOOTROM_0;        // Burst type
    wire   [3:0] HPROT_BOOTROM_0;         // Protection control
    wire  [31:0] HWDATA_BOOTROM_0;        // Write data
    wire         HMASTLOCK_BOOTROM_0;     // Locked Sequence
    wire         HREADYMUX_BOOTROM_0;     // Transfer done

    wire  [31:0] HRDATA_BOOTROM_0;        // Read data bus
    wire         HREADYOUT_BOOTROM_0;     // HREADY feedback
    wire         HRESP_BOOTROM_0;         // Transfer response

    // Output Port MI1
    wire         HSEL_IMEM_0;          // Slave Select
    wire  [31:0] HADDR_IMEM_0;         // Address bus
    wire   [1:0] HTRANS_IMEM_0;        // Transfer type
    wire         HWRITE_IMEM_0;        // Transfer direction
    wire   [2:0] HSIZE_IMEM_0;         // Transfer size
    wire   [2:0] HBURST_IMEM_0;        // Burst type
    wire   [3:0] HPROT_IMEM_0;         // Protection control
    wire  [31:0] HWDATA_IMEM_0;        // Write data
    wire         HMASTLOCK_IMEM_0;     // Locked Sequence
    wire         HREADYMUX_IMEM_0;     // Transfer done

    wire  [31:0] HRDATA_IMEM_0;        // Read data bus
    wire         HREADYOUT_IMEM_0;     // HREADY feedback
    wire         HRESP_IMEM_0;         // Transfer response

    // Output Port MI2
    wire         HSEL_DMEM_0;          // Slave Select
    wire  [31:0] HADDR_DMEM_0;         // Address bus
    wire   [1:0] HTRANS_DMEM_0;        // Transfer type
    wire         HWRITE_DMEM_0;        // Transfer direction
    wire   [2:0] HSIZE_DMEM_0;         // Transfer size
    wire   [2:0] HBURST_DMEM_0;        // Burst type
    wire   [3:0] HPROT_DMEM_0;         // Protection control
    wire  [31:0] HWDATA_DMEM_0;        // Write data
    wire         HMASTLOCK_DMEM_0;     // Locked Sequence
    wire         HREADYMUX_DMEM_0;     // Transfer done

    wire  [31:0] HRDATA_DMEM_0;        // Read data bus
    wire         HREADYOUT_DMEM_0;     // HREADY feedback
    wire         HRESP_DMEM_0;         // Transfer response

    // Output Port MI3
    wire         HSEL_SYSIO;          // Slave Select
    wire  [31:0] HADDR_SYSIO;         // Address bus
    wire   [1:0] HTRANS_SYSIO;        // Transfer type
    wire         HWRITE_SYSIO;        // Transfer direction
    wire   [2:0] HSIZE_SYSIO;         // Transfer size
    wire   [2:0] HBURST_SYSIO;        // Burst type
    wire   [3:0] HPROT_SYSIO;         // Protection control
    wire  [31:0] HWDATA_SYSIO;        // Write data
    wire         HMASTLOCK_SYSIO;     // Locked Sequence
    wire         HREADYMUX_SYSIO;     // Transfer done

    wire  [31:0] HRDATA_SYSIO;        // Read data bus
    wire         HREADYOUT_SYSIO;     // HREADY feedback
    wire         HRESP_SYSIO;         // Transfer response

    // Output Port MI4
    wire         HSEL_EXPRAM_L;          // Slave Select
    wire  [31:0] HADDR_EXPRAM_L;         // Address bus
    wire   [1:0] HTRANS_EXPRAM_L;        // Transfer type
    wire         HWRITE_EXPRAM_L;        // Transfer direction
    wire   [2:0] HSIZE_EXPRAM_L;         // Transfer size
    wire   [2:0] HBURST_EXPRAM_L;        // Burst type
    wire   [3:0] HPROT_EXPRAM_L;         // Protection control
    wire  [31:0] HWDATA_EXPRAM_L;        // Write data
    wire         HMASTLOCK_EXPRAM_L;     // Locked Sequence
    wire         HREADYMUX_EXPRAM_L;     // Transfer done

    wire  [31:0] HRDATA_EXPRAM_L;        // Read data bus
    wire         HREADYOUT_EXPRAM_L;     // HREADY feedback
    wire         HRESP_EXPRAM_L;         // Transfer response

    // Output Port MI5
    wire         HSEL_EXPRAM_H;          // Slave Select
    wire  [31:0] HADDR_EXPRAM_H;         // Address bus
    wire   [1:0] HTRANS_EXPRAM_H;        // Transfer type
    wire         HWRITE_EXPRAM_H;        // Transfer direction
    wire   [2:0] HSIZE_EXPRAM_H;         // Transfer size
    wire   [2:0] HBURST_EXPRAM_H;        // Burst type
    wire   [3:0] HPROT_EXPRAM_H;         // Protection control
    wire  [31:0] HWDATA_EXPRAM_H;        // Write data
    wire         HMASTLOCK_EXPRAM_H;     // Locked Sequence
    wire         HREADYMUX_EXPRAM_H;     // Transfer done

    wire  [31:0] HRDATA_EXPRAM_H;        // Read data bus
    wire         HREADYOUT_EXPRAM_H;     // HREADY feedback
    wire         HRESP_EXPRAM_H;         // Transfer response

    // Output Port MI6
    wire         HSEL_EXP;          // Slave Select
    wire  [31:0] HADDR_EXP;         // Address bus
    wire   [1:0] HTRANS_EXP;        // Transfer type
    wire         HWRITE_EXP;        // Transfer direction
    wire   [2:0] HSIZE_EXP;         // Transfer size
    wire   [2:0] HBURST_EXP;        // Burst type
    wire   [3:0] HPROT_EXP;         // Protection control
    wire  [31:0] HWDATA_EXP;        // Write data
    wire         HMASTLOCK_EXP;     // Locked Sequence
    wire         HREADYMUX_EXP;     // Transfer done

    wire  [31:0] HRDATA_EXP;        // Read data bus
    wire         HREADYOUT_EXP;     // HREADY feedback
    wire         HRESP_EXP;         // Transfer response

    // Output Port MI7
    wire         HSEL_SYSTABLE;          // Slave Select
    wire  [31:0] HADDR_SYSTABLE;         // Address bus
    wire   [1:0] HTRANS_SYSTABLE;        // Transfer type
    wire         HWRITE_SYSTABLE;        // Transfer direction
    wire   [2:0] HSIZE_SYSTABLE;         // Transfer size
    wire   [2:0] HBURST_SYSTABLE;        // Burst type
    wire   [3:0] HPROT_SYSTABLE;         // Protection control
    wire  [31:0] HWDATA_SYSTABLE;        // Write data
    wire         HMASTLOCK_SYSTABLE;     // Locked Sequence
    wire         HREADYMUX_SYSTABLE;     // Transfer done

    wire  [31:0] HRDATA_SYSTABLE;        // Read data bus
    wire         HREADYOUT_SYSTABLE;     // HREADY feedback
    wire         HRESP_SYSTABLE;         // Transfer response


// -----------------------------------------------------------------------------
// Signal declarations
// -----------------------------------------------------------------------------
    wire   [3:0] tie_hi_4;
    wire         tie_hi;
    wire         tie_low;
    wire   [1:0] i_hresp_DEBUG;
    wire   [1:0] i_hresp_DMAC_0;
    wire   [1:0] i_hresp_DMAC_1;
    wire   [1:0] i_hresp_CPU_0;

    wire   [3:0]        i_hmaster_BOOTROM_0;
    wire   [1:0] i_hresp_BOOTROM_0;
    wire   [3:0]        i_hmaster_IMEM_0;
    wire   [1:0] i_hresp_IMEM_0;
    wire   [3:0]        i_hmaster_DMEM_0;
    wire   [1:0] i_hresp_DMEM_0;
    wire   [3:0]        i_hmaster_SYSIO;
    wire   [1:0] i_hresp_SYSIO;
    wire   [3:0]        i_hmaster_EXPRAM_L;
    wire   [1:0] i_hresp_EXPRAM_L;
    wire   [3:0]        i_hmaster_EXPRAM_H;
    wire   [1:0] i_hresp_EXPRAM_H;
    wire   [3:0]        i_hmaster_EXP;
    wire   [1:0] i_hresp_EXP;
    wire   [3:0]        i_hmaster_SYSTABLE;
    wire   [1:0] i_hresp_SYSTABLE;

// -----------------------------------------------------------------------------
// Beginning of main code
// -----------------------------------------------------------------------------

    assign tie_hi   = 1'b1;
    assign tie_hi_4 = 4'b1111;
    assign tie_low  = 1'b0;


    assign HRESP_DEBUG  = i_hresp_DEBUG[0];

    assign HRESP_DMAC_0  = i_hresp_DMAC_0[0];

    assign HRESP_DMAC_1  = i_hresp_DMAC_1[0];

    assign HRESP_CPU_0  = i_hresp_CPU_0[0];

    assign i_hresp_BOOTROM_0 = {{1{tie_low}}, HRESP_BOOTROM_0};
    assign i_hresp_IMEM_0 = {{1{tie_low}}, HRESP_IMEM_0};
    assign i_hresp_DMEM_0 = {{1{tie_low}}, HRESP_DMEM_0};
    assign i_hresp_SYSIO = {{1{tie_low}}, HRESP_SYSIO};
    assign i_hresp_EXPRAM_L = {{1{tie_low}}, HRESP_EXPRAM_L};
    assign i_hresp_EXPRAM_H = {{1{tie_low}}, HRESP_EXPRAM_H};
    assign i_hresp_EXP = {{1{tie_low}}, HRESP_EXP};
    assign i_hresp_SYSTABLE = {{1{tie_low}}, HRESP_SYSTABLE};

// BusMatrix instance
  nanosoc_busmatrix unanosoc_busmatrix (
    .HCLK       (HCLK),
    .HRESETn    (HRESETn),
    .REMAP      (REMAP),

    // Input port SI0 signals
    .HSEL_DEBUG       (tie_hi),
    .HADDR_DEBUG      (HADDR_DEBUG),
    .HTRANS_DEBUG     (HTRANS_DEBUG),
    .HWRITE_DEBUG     (HWRITE_DEBUG),
    .HSIZE_DEBUG      (HSIZE_DEBUG),
    .HBURST_DEBUG     (HBURST_DEBUG),
    .HPROT_DEBUG      (HPROT_DEBUG),
    .HWDATA_DEBUG     (HWDATA_DEBUG),
    .HMASTLOCK_DEBUG  (HMASTLOCK_DEBUG),
    .HMASTER_DEBUG    (tie_hi_4),
    .HREADY_DEBUG     (HREADY_DEBUG),
    .HRDATA_DEBUG     (HRDATA_DEBUG),
    .HREADYOUT_DEBUG  (HREADY_DEBUG),
    .HRESP_DEBUG      (i_hresp_DEBUG),

    // Input port SI1 signals
    .HSEL_DMAC_0       (tie_hi),
    .HADDR_DMAC_0      (HADDR_DMAC_0),
    .HTRANS_DMAC_0     (HTRANS_DMAC_0),
    .HWRITE_DMAC_0     (HWRITE_DMAC_0),
    .HSIZE_DMAC_0      (HSIZE_DMAC_0),
    .HBURST_DMAC_0     (HBURST_DMAC_0),
    .HPROT_DMAC_0      (HPROT_DMAC_0),
    .HWDATA_DMAC_0     (HWDATA_DMAC_0),
    .HMASTLOCK_DMAC_0  (HMASTLOCK_DMAC_0),
    .HMASTER_DMAC_0    (tie_hi_4),
    .HREADY_DMAC_0     (HREADY_DMAC_0),
    .HRDATA_DMAC_0     (HRDATA_DMAC_0),
    .HREADYOUT_DMAC_0  (HREADY_DMAC_0),
    .HRESP_DMAC_0      (i_hresp_DMAC_0),

    // Input port SI2 signals
    .HSEL_DMAC_1       (tie_hi),
    .HADDR_DMAC_1      (HADDR_DMAC_1),
    .HTRANS_DMAC_1     (HTRANS_DMAC_1),
    .HWRITE_DMAC_1     (HWRITE_DMAC_1),
    .HSIZE_DMAC_1      (HSIZE_DMAC_1),
    .HBURST_DMAC_1     (HBURST_DMAC_1),
    .HPROT_DMAC_1      (HPROT_DMAC_1),
    .HWDATA_DMAC_1     (HWDATA_DMAC_1),
    .HMASTLOCK_DMAC_1  (HMASTLOCK_DMAC_1),
    .HMASTER_DMAC_1    (tie_hi_4),
    .HREADY_DMAC_1     (HREADY_DMAC_1),
    .HRDATA_DMAC_1     (HRDATA_DMAC_1),
    .HREADYOUT_DMAC_1  (HREADY_DMAC_1),
    .HRESP_DMAC_1      (i_hresp_DMAC_1),

    // Input port SI3 signals
    .HSEL_CPU_0       (tie_hi),
    .HADDR_CPU_0      (HADDR_CPU_0),
    .HTRANS_CPU_0     (HTRANS_CPU_0),
    .HWRITE_CPU_0     (HWRITE_CPU_0),
    .HSIZE_CPU_0      (HSIZE_CPU_0),
    .HBURST_CPU_0     (HBURST_CPU_0),
    .HPROT_CPU_0      (HPROT_CPU_0),
    .HWDATA_CPU_0     (HWDATA_CPU_0),
    .HMASTLOCK_CPU_0  (HMASTLOCK_CPU_0),
    .HMASTER_CPU_0    (tie_hi_4),
    .HREADY_CPU_0     (HREADY_CPU_0),
    .HRDATA_CPU_0     (HRDATA_CPU_0),
    .HREADYOUT_CPU_0  (HREADY_CPU_0),
    .HRESP_CPU_0      (i_hresp_CPU_0),


    // Output port MI0 signals
    .HSEL_BOOTROM_0       (HSEL_BOOTROM_0),
    .HADDR_BOOTROM_0      (HADDR_BOOTROM_0),
    .HTRANS_BOOTROM_0     (HTRANS_BOOTROM_0),
    .HWRITE_BOOTROM_0     (HWRITE_BOOTROM_0),
    .HSIZE_BOOTROM_0      (HSIZE_BOOTROM_0),
    .HBURST_BOOTROM_0     (HBURST_BOOTROM_0),
    .HPROT_BOOTROM_0      (HPROT_BOOTROM_0),
    .HWDATA_BOOTROM_0     (HWDATA_BOOTROM_0),
    .HMASTER_BOOTROM_0    (i_hmaster_BOOTROM_0),
    .HMASTLOCK_BOOTROM_0  (HMASTLOCK_BOOTROM_0),
    .HREADYMUX_BOOTROM_0  (HREADYMUX_BOOTROM_0),
    .HRDATA_BOOTROM_0     (HRDATA_BOOTROM_0),
    .HREADYOUT_BOOTROM_0  (HREADYOUT_BOOTROM_0),
    .HRESP_BOOTROM_0      (i_hresp_BOOTROM_0),

    // Output port MI1 signals
    .HSEL_IMEM_0       (HSEL_IMEM_0),
    .HADDR_IMEM_0      (HADDR_IMEM_0),
    .HTRANS_IMEM_0     (HTRANS_IMEM_0),
    .HWRITE_IMEM_0     (HWRITE_IMEM_0),
    .HSIZE_IMEM_0      (HSIZE_IMEM_0),
    .HBURST_IMEM_0     (HBURST_IMEM_0),
    .HPROT_IMEM_0      (HPROT_IMEM_0),
    .HWDATA_IMEM_0     (HWDATA_IMEM_0),
    .HMASTER_IMEM_0    (i_hmaster_IMEM_0),
    .HMASTLOCK_IMEM_0  (HMASTLOCK_IMEM_0),
    .HREADYMUX_IMEM_0  (HREADYMUX_IMEM_0),
    .HRDATA_IMEM_0     (HRDATA_IMEM_0),
    .HREADYOUT_IMEM_0  (HREADYOUT_IMEM_0),
    .HRESP_IMEM_0      (i_hresp_IMEM_0),

    // Output port MI2 signals
    .HSEL_DMEM_0       (HSEL_DMEM_0),
    .HADDR_DMEM_0      (HADDR_DMEM_0),
    .HTRANS_DMEM_0     (HTRANS_DMEM_0),
    .HWRITE_DMEM_0     (HWRITE_DMEM_0),
    .HSIZE_DMEM_0      (HSIZE_DMEM_0),
    .HBURST_DMEM_0     (HBURST_DMEM_0),
    .HPROT_DMEM_0      (HPROT_DMEM_0),
    .HWDATA_DMEM_0     (HWDATA_DMEM_0),
    .HMASTER_DMEM_0    (i_hmaster_DMEM_0),
    .HMASTLOCK_DMEM_0  (HMASTLOCK_DMEM_0),
    .HREADYMUX_DMEM_0  (HREADYMUX_DMEM_0),
    .HRDATA_DMEM_0     (HRDATA_DMEM_0),
    .HREADYOUT_DMEM_0  (HREADYOUT_DMEM_0),
    .HRESP_DMEM_0      (i_hresp_DMEM_0),

    // Output port MI3 signals
    .HSEL_SYSIO       (HSEL_SYSIO),
    .HADDR_SYSIO      (HADDR_SYSIO),
    .HTRANS_SYSIO     (HTRANS_SYSIO),
    .HWRITE_SYSIO     (HWRITE_SYSIO),
    .HSIZE_SYSIO      (HSIZE_SYSIO),
    .HBURST_SYSIO     (HBURST_SYSIO),
    .HPROT_SYSIO      (HPROT_SYSIO),
    .HWDATA_SYSIO     (HWDATA_SYSIO),
    .HMASTER_SYSIO    (i_hmaster_SYSIO),
    .HMASTLOCK_SYSIO  (HMASTLOCK_SYSIO),
    .HREADYMUX_SYSIO  (HREADYMUX_SYSIO),
    .HRDATA_SYSIO     (HRDATA_SYSIO),
    .HREADYOUT_SYSIO  (HREADYOUT_SYSIO),
    .HRESP_SYSIO      (i_hresp_SYSIO),

    // Output port MI4 signals
    .HSEL_EXPRAM_L       (HSEL_EXPRAM_L),
    .HADDR_EXPRAM_L      (HADDR_EXPRAM_L),
    .HTRANS_EXPRAM_L     (HTRANS_EXPRAM_L),
    .HWRITE_EXPRAM_L     (HWRITE_EXPRAM_L),
    .HSIZE_EXPRAM_L      (HSIZE_EXPRAM_L),
    .HBURST_EXPRAM_L     (HBURST_EXPRAM_L),
    .HPROT_EXPRAM_L      (HPROT_EXPRAM_L),
    .HWDATA_EXPRAM_L     (HWDATA_EXPRAM_L),
    .HMASTER_EXPRAM_L    (i_hmaster_EXPRAM_L),
    .HMASTLOCK_EXPRAM_L  (HMASTLOCK_EXPRAM_L),
    .HREADYMUX_EXPRAM_L  (HREADYMUX_EXPRAM_L),
    .HRDATA_EXPRAM_L     (HRDATA_EXPRAM_L),
    .HREADYOUT_EXPRAM_L  (HREADYOUT_EXPRAM_L),
    .HRESP_EXPRAM_L      (i_hresp_EXPRAM_L),

    // Output port MI5 signals
    .HSEL_EXPRAM_H       (HSEL_EXPRAM_H),
    .HADDR_EXPRAM_H      (HADDR_EXPRAM_H),
    .HTRANS_EXPRAM_H     (HTRANS_EXPRAM_H),
    .HWRITE_EXPRAM_H     (HWRITE_EXPRAM_H),
    .HSIZE_EXPRAM_H      (HSIZE_EXPRAM_H),
    .HBURST_EXPRAM_H     (HBURST_EXPRAM_H),
    .HPROT_EXPRAM_H      (HPROT_EXPRAM_H),
    .HWDATA_EXPRAM_H     (HWDATA_EXPRAM_H),
    .HMASTER_EXPRAM_H    (i_hmaster_EXPRAM_H),
    .HMASTLOCK_EXPRAM_H  (HMASTLOCK_EXPRAM_H),
    .HREADYMUX_EXPRAM_H  (HREADYMUX_EXPRAM_H),
    .HRDATA_EXPRAM_H     (HRDATA_EXPRAM_H),
    .HREADYOUT_EXPRAM_H  (HREADYOUT_EXPRAM_H),
    .HRESP_EXPRAM_H      (i_hresp_EXPRAM_H),

    // Output port MI6 signals
    .HSEL_EXP       (HSEL_EXP),
    .HADDR_EXP      (HADDR_EXP),
    .HTRANS_EXP     (HTRANS_EXP),
    .HWRITE_EXP     (HWRITE_EXP),
    .HSIZE_EXP      (HSIZE_EXP),
    .HBURST_EXP     (HBURST_EXP),
    .HPROT_EXP      (HPROT_EXP),
    .HWDATA_EXP     (HWDATA_EXP),
    .HMASTER_EXP    (i_hmaster_EXP),
    .HMASTLOCK_EXP  (HMASTLOCK_EXP),
    .HREADYMUX_EXP  (HREADYMUX_EXP),
    .HRDATA_EXP     (HRDATA_EXP),
    .HREADYOUT_EXP  (HREADYOUT_EXP),
    .HRESP_EXP      (i_hresp_EXP),

    // Output port MI7 signals
    .HSEL_SYSTABLE       (HSEL_SYSTABLE),
    .HADDR_SYSTABLE      (HADDR_SYSTABLE),
    .HTRANS_SYSTABLE     (HTRANS_SYSTABLE),
    .HWRITE_SYSTABLE     (HWRITE_SYSTABLE),
    .HSIZE_SYSTABLE      (HSIZE_SYSTABLE),
    .HBURST_SYSTABLE     (HBURST_SYSTABLE),
    .HPROT_SYSTABLE      (HPROT_SYSTABLE),
    .HWDATA_SYSTABLE     (HWDATA_SYSTABLE),
    .HMASTER_SYSTABLE    (i_hmaster_SYSTABLE),
    .HMASTLOCK_SYSTABLE  (HMASTLOCK_SYSTABLE),
    .HREADYMUX_SYSTABLE  (HREADYMUX_SYSTABLE),
    .HRDATA_SYSTABLE     (HRDATA_SYSTABLE),
    .HREADYOUT_SYSTABLE  (HREADYOUT_SYSTABLE),
    .HRESP_SYSTABLE      (i_hresp_SYSTABLE),


    // Scan test dummy signals; not connected until scan insertion
    .SCANENABLE            (SCANENABLE),
    .SCANINHCLK            (SCANINHCLK),
    .SCANOUTHCLK           (SCANOUTHCLK)
  );


endmodule
