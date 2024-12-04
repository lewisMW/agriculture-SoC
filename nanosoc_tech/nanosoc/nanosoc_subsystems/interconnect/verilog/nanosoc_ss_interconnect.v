//-----------------------------------------------------------------------------
// NanoSoC Interconnect Subsystem
// - Contains AHB Lite Bus Matrix
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright (C) 2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module nanosoc_ss_interconnect  #(
    parameter    SYS_ADDR_W    = 32,  // System Address Width
    parameter    SYS_DATA_W    = 32   // System Data Width
)(
    // System Clocks, Resets and Control
    input  wire         SYS_HCLK,            // AHB System Clock
    input  wire         SYS_HRESETn,         // AHB System Reset
    input  wire         SYS_SCANENABLE,      // Scan enable signal
    input  wire         SYS_SCANINHCLK,      // HCLK scan input  wire
    output wire         SYS_SCANOUTHCLK,     // Scan Chain Output
    
    // System Address Remap control
    input  wire   [3:0] SYS_REMAP_CTRL,      // System Address REMAP control

    // Debug Master Port
    input  wire  [31:0] DEBUG_HADDR,         // Address bus
    input  wire   [1:0] DEBUG_HTRANS,        // Transfer type
    input  wire         DEBUG_HWRITE,        // Transfer direction
    input  wire   [2:0] DEBUG_HSIZE,         // Transfer size
    input  wire   [2:0] DEBUG_HBURST,        // Burst type
    input  wire   [3:0] DEBUG_HPROT,         // Protection control
    input  wire  [31:0] DEBUG_HWDATA,        // Write data
    input  wire         DEBUG_HMASTLOCK,     // Locked Sequence
    output wire  [31:0] DEBUG_HRDATA,        // Read data bus
    output wire         DEBUG_HREADY,        // HREADY feedback
    output wire         DEBUG_HRESP,         // Transfer response

    // DMA Controller 0 Master Port
    input  wire  [31:0] DMAC_0_HADDR,         // Address bus
    input  wire   [1:0] DMAC_0_HTRANS,        // Transfer type
    input  wire         DMAC_0_HWRITE,        // Transfer direction
    input  wire   [2:0] DMAC_0_HSIZE,         // Transfer size
    input  wire   [2:0] DMAC_0_HBURST,        // Burst type
    input  wire   [3:0] DMAC_0_HPROT,         // Protection control
    input  wire  [31:0] DMAC_0_HWDATA,        // Write data
    input  wire         DMAC_0_HMASTLOCK,     // Locked Sequence
    output wire  [31:0] DMAC_0_HRDATA,        // Read data bus
    output wire         DMAC_0_HREADY,        // HREADY feedback
    output wire         DMAC_0_HRESP,         // Transfer response
    

    // DMAC Controller 1 Master Port
    input  wire  [31:0] DMAC_1_HADDR,         // Address bus
    input  wire   [1:0] DMAC_1_HTRANS,        // Transfer type
    input  wire         DMAC_1_HWRITE,        // Transfer direction
    input  wire   [2:0] DMAC_1_HSIZE,         // Transfer size
    input  wire   [2:0] DMAC_1_HBURST,        // Burst type
    input  wire   [3:0] DMAC_1_HPROT,         // Protection control
    input  wire  [31:0] DMAC_1_HWDATA,        // Write data
    input  wire         DMAC_1_HMASTLOCK,     // Locked Sequence
    output wire  [31:0] DMAC_1_HRDATA,        // Read data bus
    output wire         DMAC_1_HREADY,        // HREADY feedback
    output wire         DMAC_1_HRESP,         // Transfer response

    // CPU 0 Master Port
    input  wire  [31:0] CPU_0_HADDR,         // Address bus
    input  wire   [1:0] CPU_0_HTRANS,        // Transfer type
    input  wire         CPU_0_HWRITE,        // Transfer direction
    input  wire   [2:0] CPU_0_HSIZE,         // Transfer size
    input  wire   [2:0] CPU_0_HBURST,        // Burst type
    input  wire   [3:0] CPU_0_HPROT,         // Protection control
    input  wire  [31:0] CPU_0_HWDATA,        // Write data
    input  wire         CPU_0_HMASTLOCK,     // Locked Sequence
    output wire  [31:0] CPU_0_HRDATA,        // Read data bus
    output wire         CPU_0_HREADY,        // HREADY feedback
    output wire         CPU_0_HRESP,         // Transfer response

    // Bootrom 0 Region Slave Port
    input  wire  [31:0] BOOTROM_0_HRDATA,        // Read data bus
    input  wire         BOOTROM_0_HREADYOUT,     // HREADY feedback
    input  wire         BOOTROM_0_HRESP,         // Transfer response
    output wire         BOOTROM_0_HSEL,          // Slave Select
    output wire  [31:0] BOOTROM_0_HADDR,         // Address bus
    output wire   [1:0] BOOTROM_0_HTRANS,        // Transfer type
    output wire         BOOTROM_0_HWRITE,        // Transfer direction
    output wire   [2:0] BOOTROM_0_HSIZE,         // Transfer size
    output wire   [2:0] BOOTROM_0_HBURST,        // Burst type
    output wire   [3:0] BOOTROM_0_HPROT,         // Protection control
    output wire  [31:0] BOOTROM_0_HWDATA,        // Write data
    output wire         BOOTROM_0_HMASTLOCK,     // Locked Sequence
    output wire         BOOTROM_0_HREADYMUX,     // Transfer done

    // CPU 0 Instruction Memory Region Slave Port
    input  wire  [31:0] IMEM_0_HRDATA,        // Read data bus
    input  wire         IMEM_0_HREADYOUT,     // HREADY feedback
    input  wire         IMEM_0_HRESP,         // Transfer response
    output wire         IMEM_0_HSEL,          // Slave Select
    output wire  [31:0] IMEM_0_HADDR,         // Address bus
    output wire   [1:0] IMEM_0_HTRANS,        // Transfer type
    output wire         IMEM_0_HWRITE,        // Transfer direction
    output wire   [2:0] IMEM_0_HSIZE,         // Transfer size
    output wire   [2:0] IMEM_0_HBURST,        // Burst type
    output wire   [3:0] IMEM_0_HPROT,         // Protection control
    output wire  [31:0] IMEM_0_HWDATA,        // Write data
    output wire         IMEM_0_HMASTLOCK,     // Locked Sequence
    output wire         IMEM_0_HREADYMUX,     // Transfer done

    // CPU 0 Data Memory Region Slave Port
    input  wire  [31:0] DMEM_0_HRDATA,        // Read data bus
    input  wire         DMEM_0_HREADYOUT,     // HREADY feedback
    input  wire         DMEM_0_HRESP,         // Transfer response
    output wire         DMEM_0_HSEL,          // Slave Select
    output wire  [31:0] DMEM_0_HADDR,         // Address bus
    output wire   [1:0] DMEM_0_HTRANS,        // Transfer type
    output wire         DMEM_0_HWRITE,        // Transfer direction
    output wire   [2:0] DMEM_0_HSIZE,         // Transfer size
    output wire   [2:0] DMEM_0_HBURST,        // Burst type
    output wire   [3:0] DMEM_0_HPROT,         // Protection control
    output wire  [31:0] DMEM_0_HWDATA,        // Write data
    output wire         DMEM_0_HMASTLOCK,     // Locked Sequence
    output wire         DMEM_0_HREADYMUX,     // Transfer done

    // System Peripheral Region Slave Port
    input  wire  [31:0] SYSIO_HRDATA,        // Read data bus
    input  wire         SYSIO_HREADYOUT,     // HREADY feedback
    input  wire         SYSIO_HRESP,         // Transfer response
    output wire         SYSIO_HSEL,          // Slave Select
    output wire  [31:0] SYSIO_HADDR,         // Address bus
    output wire   [1:0] SYSIO_HTRANS,        // Transfer type
    output wire         SYSIO_HWRITE,        // Transfer direction
    output wire   [2:0] SYSIO_HSIZE,         // Transfer size
    output wire   [2:0] SYSIO_HBURST,        // Burst type
    output wire   [3:0] SYSIO_HPROT,         // Protection control
    output wire  [31:0] SYSIO_HWDATA,        // Write data
    output wire         SYSIO_HMASTLOCK,     // Locked Sequence
    output wire         SYSIO_HREADYMUX,     // Transfer done

    // Expansion Memory Low Region Slave Port
    input  wire  [31:0] EXPRAM_L_HRDATA,        // Read data bus
    input  wire         EXPRAM_L_HREADYOUT,     // HREADY feedback
    input  wire         EXPRAM_L_HRESP,         // Transfer response
    output wire         EXPRAM_L_HSEL,          // Slave Select
    output wire  [31:0] EXPRAM_L_HADDR,         // Address bus
    output wire   [1:0] EXPRAM_L_HTRANS,        // Transfer type
    output wire         EXPRAM_L_HWRITE,        // Transfer direction
    output wire   [2:0] EXPRAM_L_HSIZE,         // Transfer size
    output wire   [2:0] EXPRAM_L_HBURST,        // Burst type
    output wire   [3:0] EXPRAM_L_HPROT,         // Protection control
    output wire  [31:0] EXPRAM_L_HWDATA,        // Write data
    output wire         EXPRAM_L_HMASTLOCK,     // Locked Sequence
    output wire         EXPRAM_L_HREADYMUX,     // Transfer done

    // Expansion Memory High Region Slave Port
    input  wire  [31:0] EXPRAM_H_HRDATA,        // Read data bus
    input  wire         EXPRAM_H_HREADYOUT,     // HREADY feedback
    input  wire         EXPRAM_H_HRESP,         // Transfer response
    output wire         EXPRAM_H_HSEL,          // Slave Select
    output wire  [31:0] EXPRAM_H_HADDR,         // Address bus
    output wire   [1:0] EXPRAM_H_HTRANS,        // Transfer type
    output wire         EXPRAM_H_HWRITE,        // Transfer direction
    output wire   [2:0] EXPRAM_H_HSIZE,         // Transfer size
    output wire   [2:0] EXPRAM_H_HBURST,        // Burst type
    output wire   [3:0] EXPRAM_H_HPROT,         // Protection control
    output wire  [31:0] EXPRAM_H_HWDATA,        // Write data
    output wire         EXPRAM_H_HMASTLOCK,     // Locked Sequence
    output wire         EXPRAM_H_HREADYMUX,     // Transfer done

    // Expansion Region Slave Port
    input  wire  [31:0] EXP_HRDATA,        // Read data bus
    input  wire         EXP_HREADYOUT,     // HREADY feedback
    input  wire         EXP_HRESP,         // Transfer response
    output wire         EXP_HSEL,          // Slave Select
    output wire  [31:0] EXP_HADDR,         // Address bus
    output wire   [1:0] EXP_HTRANS,        // Transfer type
    output wire         EXP_HWRITE,        // Transfer direction
    output wire   [2:0] EXP_HSIZE,         // Transfer size
    output wire   [2:0] EXP_HBURST,        // Burst type
    output wire   [3:0] EXP_HPROT,         // Protection control
    output wire  [31:0] EXP_HWDATA,        // Write data
    output wire         EXP_HMASTLOCK,     // Locked Sequence
    output wire         EXP_HREADYMUX,     // Transfer done

    // System ROM Table Region Slave Port
    input  wire  [31:0] SYSTABLE_HRDATA,        // Read data bus
    input  wire         SYSTABLE_HREADYOUT,     // HREADY feedback
    input  wire         SYSTABLE_HRESP,         // Transfer response
    output wire         SYSTABLE_HSEL,          // Slave Select
    output wire  [31:0] SYSTABLE_HADDR,         // Address bus
    output wire   [1:0] SYSTABLE_HTRANS,        // Transfer type
    output wire         SYSTABLE_HWRITE,        // Transfer direction
    output wire   [2:0] SYSTABLE_HSIZE,         // Transfer size
    output wire   [2:0] SYSTABLE_HBURST,        // Burst type
    output wire   [3:0] SYSTABLE_HPROT,         // Protection control
    output wire  [31:0] SYSTABLE_HWDATA,        // Write data
    output wire         SYSTABLE_HMASTLOCK,     // Locked Sequence
    output wire         SYSTABLE_HREADYMUX      // Transfer done
);
    // -------------------------------
    // Bus Matrix Instantiation
    // -------------------------------
    nanosoc_busmatrix_lite u_busmatrix (
        // System Clocks, Resets and Control
        .HCLK            (SYS_HCLK),            // AHB System Clock
        .HRESETn         (SYS_HRESETn),         // AHB System Reset
        .SCANENABLE      (SYS_SCANENABLE),      // Scan enable signal
        .SCANINHCLK      (SYS_SCANINHCLK),      // HCLK scan input  wire
        .SCANOUTHCLK     (SYS_SCANOUTHCLK),     // Scan Chain Output
        
        // System Address Remap control
        .REMAP           (SYS_REMAP_CTRL),      // System Address REMAP control

        // Debug Master Port
        .HADDR_DEBUG         (DEBUG_HADDR),         // Address bus
        .HTRANS_DEBUG        (DEBUG_HTRANS),        // Transfer type
        .HWRITE_DEBUG        (DEBUG_HWRITE),        // Transfer direction
        .HSIZE_DEBUG         (DEBUG_HSIZE),         // Transfer size
        .HBURST_DEBUG        (DEBUG_HBURST),        // Burst type
        .HPROT_DEBUG         (DEBUG_HPROT),         // Protection control
        .HWDATA_DEBUG        (DEBUG_HWDATA),        // Write data
        .HMASTLOCK_DEBUG     (DEBUG_HMASTLOCK),     // Locked Sequence
        .HRDATA_DEBUG        (DEBUG_HRDATA),        // Read data bus
        .HREADY_DEBUG        (DEBUG_HREADY),        // HREADY feedback
        .HRESP_DEBUG         (DEBUG_HRESP),         // Transfer response

        // DMA Controller 0 Master Port
        .HADDR_DMAC_0        (DMAC_0_HADDR),        // Address bus
        .HTRANS_DMAC_0       (DMAC_0_HTRANS),       // Transfer type
        .HWRITE_DMAC_0       (DMAC_0_HWRITE),       // Transfer direction
        .HSIZE_DMAC_0        (DMAC_0_HSIZE),        // Transfer size
        .HBURST_DMAC_0       (DMAC_0_HBURST),       // Burst type
        .HPROT_DMAC_0        (DMAC_0_HPROT),        // Protection control
        .HWDATA_DMAC_0       (DMAC_0_HWDATA),       // Write data
        .HMASTLOCK_DMAC_0    (DMAC_0_HMASTLOCK),    // Locked Sequence
        .HRDATA_DMAC_0       (DMAC_0_HRDATA),       // Read data bus
        .HREADY_DMAC_0       (DMAC_0_HREADY),       // HREADY feedback
        .HRESP_DMAC_0        (DMAC_0_HRESP),        // Transfer response
        
        // DMA Controller 1 Master Port
        .HADDR_DMAC_1        (DMAC_1_HADDR),        // Address bus
        .HTRANS_DMAC_1       (DMAC_1_HTRANS),       // Transfer type
        .HWRITE_DMAC_1       (DMAC_1_HWRITE),       // Transfer direction
        .HSIZE_DMAC_1        (DMAC_1_HSIZE),        // Transfer size
        .HBURST_DMAC_1       (DMAC_1_HBURST),       // Burst type
        .HPROT_DMAC_1        (DMAC_1_HPROT),        // Protection control
        .HWDATA_DMAC_1       (DMAC_1_HWDATA),       // Write data
        .HMASTLOCK_DMAC_1    (DMAC_1_HMASTLOCK),    // Locked Sequence
        .HRDATA_DMAC_1       (DMAC_1_HRDATA),       // Read data bus
        .HREADY_DMAC_1       (DMAC_1_HREADY),       // HREADY feedback
        .HRESP_DMAC_1        (DMAC_1_HRESP),        // Transfer response
        
        // DMA Controller 1 Master Port
        .HADDR_CPU_0         (CPU_0_HADDR),        // Address bus
        .HTRANS_CPU_0        (CPU_0_HTRANS),       // Transfer type
        .HWRITE_CPU_0        (CPU_0_HWRITE),       // Transfer direction
        .HSIZE_CPU_0         (CPU_0_HSIZE),        // Transfer size
        .HBURST_CPU_0        (CPU_0_HBURST),       // Burst type
        .HPROT_CPU_0         (CPU_0_HPROT),        // Protection control
        .HWDATA_CPU_0        (CPU_0_HWDATA),       // Write data
        .HMASTLOCK_CPU_0     (CPU_0_HMASTLOCK),    // Locked Sequence
        .HRDATA_CPU_0        (CPU_0_HRDATA),       // Read data bus
        .HREADY_CPU_0        (CPU_0_HREADY),       // HREADY feedback
        .HRESP_CPU_0         (CPU_0_HRESP),        // Transfer response
        
        // CPU 0 Bootrom Memory Region Slave Port
        .HRDATA_BOOTROM_0        (BOOTROM_0_HRDATA),        // Read data bus
        .HREADYOUT_BOOTROM_0     (BOOTROM_0_HREADYOUT),     // HREADY feedback
        .HRESP_BOOTROM_0         (BOOTROM_0_HRESP),         // Transfer response
        .HSEL_BOOTROM_0          (BOOTROM_0_HSEL),          // Slave Select
        .HADDR_BOOTROM_0         (BOOTROM_0_HADDR),         // Address bus
        .HTRANS_BOOTROM_0        (BOOTROM_0_HTRANS),        // Transfer type
        .HWRITE_BOOTROM_0        (BOOTROM_0_HWRITE),        // Transfer direction
        .HSIZE_BOOTROM_0         (BOOTROM_0_HSIZE),         // Transfer size
        .HBURST_BOOTROM_0        (BOOTROM_0_HBURST),        // Burst type
        .HPROT_BOOTROM_0         (BOOTROM_0_HPROT),         // Protection control
        .HWDATA_BOOTROM_0        (BOOTROM_0_HWDATA),        // Write data
        .HMASTLOCK_BOOTROM_0     (BOOTROM_0_HMASTLOCK),     // Locked Sequence
        .HREADYMUX_BOOTROM_0     (BOOTROM_0_HREADYMUX),     // Transfer done
        
        // CPU 0 Instruction Memory Region Slave Port
        .HRDATA_IMEM_0        (IMEM_0_HRDATA),        // Read data bus
        .HREADYOUT_IMEM_0     (IMEM_0_HREADYOUT),     // HREADY feedback
        .HRESP_IMEM_0         (IMEM_0_HRESP),         // Transfer response
        .HSEL_IMEM_0          (IMEM_0_HSEL),          // Slave Select
        .HADDR_IMEM_0         (IMEM_0_HADDR),         // Address bus
        .HTRANS_IMEM_0        (IMEM_0_HTRANS),        // Transfer type
        .HWRITE_IMEM_0        (IMEM_0_HWRITE),        // Transfer direction
        .HSIZE_IMEM_0         (IMEM_0_HSIZE),         // Transfer size
        .HBURST_IMEM_0        (IMEM_0_HBURST),        // Burst type
        .HPROT_IMEM_0         (IMEM_0_HPROT),         // Protection control
        .HWDATA_IMEM_0        (IMEM_0_HWDATA),        // Write data
        .HMASTLOCK_IMEM_0     (IMEM_0_HMASTLOCK),     // Locked Sequence
        .HREADYMUX_IMEM_0     (IMEM_0_HREADYMUX),     // Transfer done

        // CPU 0 Data Memory Region Slave Port
        .HRDATA_DMEM_0        (DMEM_0_HRDATA),        // Read data bus
        .HREADYOUT_DMEM_0     (DMEM_0_HREADYOUT),     // HREADY feedback
        .HRESP_DMEM_0         (DMEM_0_HRESP),         // Transfer response
        .HSEL_DMEM_0          (DMEM_0_HSEL),          // Slave Select
        .HADDR_DMEM_0         (DMEM_0_HADDR),         // Address bus
        .HTRANS_DMEM_0        (DMEM_0_HTRANS),        // Transfer type
        .HWRITE_DMEM_0        (DMEM_0_HWRITE),        // Transfer direction
        .HSIZE_DMEM_0         (DMEM_0_HSIZE),         // Transfer size
        .HBURST_DMEM_0        (DMEM_0_HBURST),        // Burst type
        .HPROT_DMEM_0         (DMEM_0_HPROT),         // Protection control
        .HWDATA_DMEM_0        (DMEM_0_HWDATA),        // Write data
        .HMASTLOCK_DMEM_0     (DMEM_0_HMASTLOCK),     // Locked Sequence
        .HREADYMUX_DMEM_0     (DMEM_0_HREADYMUX),     // Transfer done

        // System Peripheral Region Slave Port
        .HRDATA_SYSIO         (SYSIO_HRDATA),         // Read data bus
        .HREADYOUT_SYSIO      (SYSIO_HREADYOUT),      // HREADY feedback
        .HRESP_SYSIO          (SYSIO_HRESP),          // Transfer response
        .HSEL_SYSIO           (SYSIO_HSEL),           // Slave Select
        .HADDR_SYSIO          (SYSIO_HADDR),          // Address bus
        .HTRANS_SYSIO         (SYSIO_HTRANS),         // Transfer type
        .HWRITE_SYSIO         (SYSIO_HWRITE),         // Transfer direction
        .HSIZE_SYSIO          (SYSIO_HSIZE),          // Transfer size
        .HBURST_SYSIO         (SYSIO_HBURST),         // Burst type
        .HPROT_SYSIO          (SYSIO_HPROT),          // Protection control
        .HWDATA_SYSIO         (SYSIO_HWDATA),         // Write data
        .HMASTLOCK_SYSIO      (SYSIO_HMASTLOCK),      // Locked Sequence
        .HREADYMUX_SYSIO      (SYSIO_HREADYMUX),      // Transfer done

        // Expansion Memory Low Region Slave Port
        .HRDATA_EXPRAM_L      (EXPRAM_L_HRDATA),      // Read data bus
        .HREADYOUT_EXPRAM_L   (EXPRAM_L_HREADYOUT),   // HREADY feedback
        .HRESP_EXPRAM_L       (EXPRAM_L_HRESP),       // Transfer response
        .HSEL_EXPRAM_L        (EXPRAM_L_HSEL),        // Slave Select
        .HADDR_EXPRAM_L       (EXPRAM_L_HADDR),       // Address bus
        .HTRANS_EXPRAM_L      (EXPRAM_L_HTRANS),      // Transfer type
        .HWRITE_EXPRAM_L      (EXPRAM_L_HWRITE),      // Transfer direction
        .HSIZE_EXPRAM_L       (EXPRAM_L_HSIZE),       // Transfer size
        .HBURST_EXPRAM_L      (EXPRAM_L_HBURST),      // Burst type
        .HPROT_EXPRAM_L       (EXPRAM_L_HPROT),       // Protection control
        .HWDATA_EXPRAM_L      (EXPRAM_L_HWDATA),      // Write data
        .HMASTLOCK_EXPRAM_L   (EXPRAM_L_HMASTLOCK),   // Locked Sequence
        .HREADYMUX_EXPRAM_L   (EXPRAM_L_HREADYMUX),   // Transfer done

        // Expansion Memory High Region Slave Port
        .HRDATA_EXPRAM_H      (EXPRAM_H_HRDATA),      // Read data bus
        .HREADYOUT_EXPRAM_H   (EXPRAM_H_HREADYOUT),   // HREADY feedback
        .HRESP_EXPRAM_H       (EXPRAM_H_HRESP),       // Transfer response
        .HSEL_EXPRAM_H        (EXPRAM_H_HSEL),        // Slave Select
        .HADDR_EXPRAM_H       (EXPRAM_H_HADDR),       // Address bus
        .HTRANS_EXPRAM_H      (EXPRAM_H_HTRANS),      // Transfer type
        .HWRITE_EXPRAM_H      (EXPRAM_H_HWRITE),      // Transfer direction
        .HSIZE_EXPRAM_H       (EXPRAM_H_HSIZE),       // Transfer size
        .HBURST_EXPRAM_H      (EXPRAM_H_HBURST),      // Burst type
        .HPROT_EXPRAM_H       (EXPRAM_H_HPROT),       // Protection control
        .HWDATA_EXPRAM_H      (EXPRAM_H_HWDATA),      // Write data
        .HMASTLOCK_EXPRAM_H   (EXPRAM_H_HMASTLOCK),   // Locked Sequence
        .HREADYMUX_EXPRAM_H   (EXPRAM_H_HREADYMUX),   // Transfer done

        // Expansion Region Slave Port
        .HRDATA_EXP           (EXP_HRDATA),           // Read data bus
        .HREADYOUT_EXP        (EXP_HREADYOUT),        // HREADY feedback
        .HRESP_EXP            (EXP_HRESP),            // Transfer response
        .HSEL_EXP             (EXP_HSEL),             // Slave Select
        .HADDR_EXP            (EXP_HADDR),            // Address bus
        .HTRANS_EXP           (EXP_HTRANS),           // Transfer type
        .HWRITE_EXP           (EXP_HWRITE),           // Transfer direction
        .HSIZE_EXP            (EXP_HSIZE),            // Transfer size
        .HBURST_EXP           (EXP_HBURST),           // Burst type
        .HPROT_EXP            (EXP_HPROT),            // Protection control
        .HWDATA_EXP           (EXP_HWDATA),           // Write data
        .HMASTLOCK_EXP        (EXP_HMASTLOCK),        // Locked Sequence
        .HREADYMUX_EXP        (EXP_HREADYMUX),        // Transfer done

        // System ROM Table Region Slave Port
        .HRDATA_SYSTABLE      (SYSTABLE_HRDATA),      // Read data bus
        .HREADYOUT_SYSTABLE   (SYSTABLE_HREADYOUT),   // HREADY feedback
        .HRESP_SYSTABLE       (SYSTABLE_HRESP),       // Transfer response
        .HSEL_SYSTABLE        (SYSTABLE_HSEL),        // Slave Select
        .HADDR_SYSTABLE       (SYSTABLE_HADDR),       // Address bus
        .HTRANS_SYSTABLE      (SYSTABLE_HTRANS),      // Transfer type
        .HWRITE_SYSTABLE      (SYSTABLE_HWRITE),      // Transfer direction
        .HSIZE_SYSTABLE       (SYSTABLE_HSIZE),       // Transfer size
        .HBURST_SYSTABLE      (SYSTABLE_HBURST),      // Burst type
        .HPROT_SYSTABLE       (SYSTABLE_HPROT),       // Protection control
        .HWDATA_SYSTABLE      (SYSTABLE_HWDATA),      // Write data
        .HMASTLOCK_SYSTABLE   (SYSTABLE_HMASTLOCK),   // Locked Sequence
        .HREADYMUX_SYSTABLE   (SYSTABLE_HREADYMUX)    // Transfer done
    );
endmodule