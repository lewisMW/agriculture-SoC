//-----------------------------------------------------------------------------
// SoCDebug Top-level FT1248-AHB Debug Controller
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module socdebug_ahb #(
    parameter         PROMPT_CHAR   = "]"
)(  
    // AHB-lite Master Interface - ADP
    input  wire                     HCLK,
    input  wire                     HRESETn,
    output wire              [31:0] HADDR32_o,
    output wire              [ 2:0] HBURST3_o,
    output wire                     HMASTLOCK_o,
    output wire              [ 3:0] HPROT4_o,
    output wire              [ 2:0] HSIZE3_o,
    output wire              [ 1:0] HTRANS2_o,
    output wire              [31:0] HWDATA32_o,
    output wire                     HWRITE_o,
    input  wire              [31:0] HRDATA32_i,
    input  wire                     HREADY_i,
    input  wire                     HRESP_i,
    
    // USRT0 TXD axi byte stream
    output wire                     ADP_RXD_TVALID_o,
    output wire            [ 7:0]   ADP_RXD_TDATA_o ,
    input  wire                     ADP_RXD_TREADY_i,
      // USRT0 RXD axi byte stream
    input  wire                     ADP_TXD_TVALID_i,
    input  wire             [ 7:0]  ADP_TXD_TDATA_i ,
    output wire                     ADP_TXD_TREADY_o,
    
    // USRT0 TXD axi byte stream
    output wire                     STD_RXD_TVALID_o,
    output wire            [ 7:0]   STD_RXD_TDATA_o ,
    input  wire                     STD_RXD_TREADY_i,
      // USRT0 RXD axi byte stream
    input  wire                     STD_TXD_TVALID_i,
    input  wire             [ 7:0]  STD_TXD_TDATA_i ,
    output wire                     STD_TXD_TREADY_o,
    
    // GPIO interface
    output wire               [7:0] GPO8_o,
    input  wire               [7:0] GPI8_i
);


    // Instantiation of ADP AHB Controller
    socdebug_adp_control #(
        .PROMPT_CHAR (PROMPT_CHAR)
    ) u_adp_control (
        // AHB Interface
        .HCLK           (HCLK),
        .HRESETn        (HRESETn),
        .HADDR32_o      (HADDR32_o),
        .HBURST3_o      (HBURST3_o),
        .HMASTLOCK_o    (HMASTLOCK_o),
        .HPROT4_o       (HPROT4_o),
        .HSIZE3_o       (HSIZE3_o),
        .HTRANS2_o      (HTRANS2_o),
        .HWDATA32_o     (HWDATA32_o),
        .HWRITE_o       (HWRITE_o),
        .HRDATA32_i     (HRDATA32_i),
        .HREADY_i       (HREADY_i),
        .HRESP_i        (HRESP_i),
        
        // GPIO Interface
        .GPO8_o         (GPO8_o),
        .GPI8_i         (GPI8_i),
        
        // USRT Interface - From ADP to USRT
        .STDTX_TVALID_o (STD_RXD_TVALID_o),
        .STDTX_TDATA_o  (STD_RXD_TDATA_o ),
        .STDTX_TREADY_i (STD_RXD_TREADY_i),
        
        // USRT Interface - From USRT to ADP
        .STDRX_TVALID_i (STD_TXD_TVALID_i),
        .STDRX_TDATA_i  (STD_TXD_TDATA_i ),
        .STDRX_TREADY_o (STD_TXD_TREADY_o),
        
        // FT1248 Interface - From FT1248 to ADP
        .COMRX_TVALID_i (ADP_TXD_TVALID_i),
        .COMRX_TDATA_i  (ADP_TXD_TDATA_i ),
        .COMRX_TREADY_o (ADP_TXD_TREADY_o),
        
        // FT1248 Interface - From ADP to FT1248
        .COMTX_TVALID_o (ADP_RXD_TVALID_o),
        .COMTX_TDATA_o  (ADP_RXD_TDATA_o ),
        .COMTX_TREADY_i (ADP_RXD_TREADY_i)
    );

    
endmodule
