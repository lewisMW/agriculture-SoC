//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
//Date        : Wed Jun 22 15:58:42 2022
//Host        : srv03335 running 64-bit Red Hat Enterprise Linux release 8.6 (Ootpa)
//Command     : generate_target nanosoc_design_wrapper.bd
//Design      : nanosoc_design_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module nanosoc_design_wrapper(
//------------------------------------------------------
// Port declarations
//------------------------------------------------------

// DDR
    // output wire         c0_ddr4_act_n,
    // output wire [16:0]  c0_ddr4_adr,
    // output wire [1:0]   c0_ddr4_ba,
    // output wire [0:0]   c0_ddr4_bg,
    // output wire [0:0]   c0_ddr4_cke,
    // output wire [0:0]   c0_ddr4_odt,
    // output wire [0:0]   c0_ddr4_cs_n,
    // output wire [0:0]   c0_ddr4_ck_t,
    // output wire [0:0]   c0_ddr4_ck_c,
    // output wire         c0_ddr4_reset_n,
    // inout  wire [7:0]   c0_ddr4_dm_dbi_n,
    // inout  wire [63:0]  c0_ddr4_dq,
    // inout  wire [7:0]   c0_ddr4_dqs_t,
    // inout  wire [7:0]   c0_ddr4_dqs_c,
    // input  wire         c0_sys_clk_p,
    // input  wire         c0_sys_clk_n,
    // input  wire         DDR_nALERT,
    // output wire         DDR_PARITY,
    // input               DDR_nEVENT,
    // output  wire        DDR_SCL,
    // inout   wire        DDR_SDA,
	
// SMB
//-----------
    output wire [6:0]   SMBF_ADDR,
    output wire         SMBF_FIFOSEL,
    inout  wire [15:0]  SMBF_DATA,
    output wire         SMBF_nOE,
    output wire         SMBF_nWE,
    output wire         SMBF_nRST,

    output wire         ETH_nCS,
    output wire         ETH_nOE,
    input  wire         ETH_INT,

    output wire         USB_nCS,
    output wire         USB_DACK,
    input  wire         USB_DREQ,
    input  wire         USB_INT,

// HDMI
//-----------
    output wire [23:0]  MMB_DATA,
    output wire         MMB_DE,
    output wire         MMB_HS,
    output wire         MMB_VS,
    output wire         MMB_IDCLK,
    output wire         MMB_SCK,
    output wire         MMB_WS,
    output wire [3:0]   MMB_SD,

    output wire         HDMI_CSCL,
    inout  wire         HDMI_CSDA,
    input  wire         HDMI_INT,

// Audio
//-----------
    output wire         AUD_MCLK,
    output wire         AUD_SCLK,
    output wire         AUD_LRCK,
    output wire         AUD_SDIN,
    input  wire         AUD_SDOUT,

    output wire         AUD_nRST,
    output wire         AUD_SCL,
    inout  wire         AUD_SDA,

// EMMC
//-----------
    inout  wire [7:0]   EMMC_DAT,
    inout  wire         EMMC_CMD,
    output wire         EMMC_CLK,
    output wire         EMMC_nRST,
    input  wire         EMMC_DS,

// CLCD
//-----------
    inout  wire [17:10] CLCD_PD,
    output wire         CLCD_RD,
    output wire         CLCD_RS,
    output wire         CLCD_CS,
    output wire         CLCD_WR_SCL,
    output wire         CLCD_BL,
    output wire         CLCD_RST,

    output wire         CLCD_TSCL,
    inout  wire         CLCD_TSDA,
    input  wire         CLCD_TINT,
    output wire         CLCD_TNC,

// UART
//-----------
    output wire [3:0]   UART_TX_F,

    input  wire [3:0]   UART_RX_F,

// DEBUG
//-----------
    input  wire         CS_TDI,
    output wire         CS_TDO,        // SWV     / JTAG TDO
    inout  wire         CS_TMS,        // SWD I/O / JTAG TMS
    input  wire         CS_TCK,        // SWD Clk / JTAG TCK
    input  wire         CS_nSRST,
    input  wire         CS_nTRST,
    input  wire         CS_nDET,

    output wire [15:0]  CS_T_D,        // Trace data
    output wire         CS_T_CLK,      // Trace clock
    output wire         CS_T_CTL,      // Trace control

// LED SW
//-----------
    output wire [9:0]   USER_nLED,
    input  wire [7:0]   USER_SW,
    input  wire [1:0]   USER_nPB,

// OSCCLK
//-----------
    input  wire [5:0]   OSCCLK,

// FMC
//-----------
    // input  wire [1:0]   CLK_M2C_P,
    // input  wire [1:0]   CLK_M2C_N,

    // input  wire         FMC_CLK_DIR,

    // inout  wire [3:2]   CLK_BIDIR_P,
    // inout  wire [3:2]   CLK_BIDIR_N,

    // inout  wire [23:0]  HA_P, // HA CLK=0,1,17
    // inout  wire [23:0]  HA_N,

    // inout  wire [21:0]  HB_P, // HB CLK=0,6,17
    // inout  wire [21:0]  HB_N,

    // inout  wire [33:0]  LA_P, // LA CLK=0,1,17,18
    // inout  wire [33:0]  LA_N,

    // input  wire [1:0]   GBTCLK_M2C_P,
    // input  wire [1:0]   GBTCLK_M2C_N,
// `ifdef GTH
    // input  wire [9:0]   DP_M2C_P,
    // input  wire [9:0]   DP_M2C_N,

    // output wire [9:0]   DP_C2M_P,
    // output wire [9:0]   DP_C2M_N,
// `endif
    // input  wire         FMC_nPRSNT,

    // input  wire         GTX_CLK_N,
    // input  wire         GTX_CLK_P,

    // input  wire         SATA_CLK_N,
    // input  wire         SATA_CLK_P,

// Quad SPI
//-----------	
	inout wire      	QSPI_D0,
	inout wire      	QSPI_D1,
	inout wire      	QSPI_D2,
	inout wire      	QSPI_D3,
	output wire     	QSPI_SCLK,
	output wire     	QSPI_nCS,

// USER SD
//-----------
    inout  wire [3:0]   USD_DAT,
    inout  wire         USD_CMD,
    output wire         USD_CLK,
    input  wire         USD_NCD,

// RESET
//-----------
    input  wire         CB_nPOR,
    input  wire         CB_nRST,
    input  wire         CB_RUN,

    input  wire         IOFPGA_NRST,
    input  wire         IOFPGA_NSPIR,

    output wire         IOFPGA_SYSWDT,
    input  wire         PB_IRQ,
    output wire         WDOG_RREQ,

// SCC
//-----------
    output wire         CFG_DATAOUT,
    input  wire         CFG_LOAD,
    input  wire         CFG_nRST,
    input  wire         CFG_CLK,
    input  wire         CFG_DATAIN,
    input  wire         CFG_WnR,

// MCC SMB
//-----------
    input  wire [25:16] SMBM_A,
    inout  wire [15:0]  SMBM_D,
    input  wire [4:1]   SMBM_nE,
    input  wire         SMBM_CLK,
    input  wire [1:0]   SMBM_nBL,
    input  wire         SMBM_nOE,
    input  wire         SMBM_nWE,
    output wire         SMBM_nWAIT,

// SHIELD
//-----------
    inout  wire [17:0]  SH0_IO,
    inout  wire [17:0]  SH1_IO,
    output wire         SH_nRST,

    output wire         SH_ADC_CS,
    output wire         SH_ADC_CK,
    output wire         SH_ADC_DI,
    input  wire         SH_ADC_DO
//   (PMOD0_0,
//    PMOD0_1,
//    PMOD0_2,
//    PMOD0_3,
//    PMOD0_4,
//    PMOD0_5,
//    PMOD0_6,
//    PMOD0_7
    );
//    PMOD1_0,
//    PMOD1_1,
//    PMOD1_2,
//    PMOD1_3,
//    PMOD1_4,
//    PMOD1_5,
//    PMOD1_6,
//    PMOD1_7,
//    dip_switch_4bits_tri_i,
//    led_4bits_tri_o);

  wire PMOD0_0;
  wire PMOD0_1;
  wire PMOD0_2;
  wire PMOD0_3;
  wire PMOD0_4;
  wire PMOD0_5;
  wire PMOD0_6;
  wire PMOD0_7;
//  inout wire PMOD1_0;
//  inout wire PMOD1_1;
//  inout wire PMOD1_2;
//  inout wire PMOD1_3;
//  inout wire PMOD1_4;
//  inout wire PMOD1_5;
//  inout wire PMOD1_6;
//  inout wire PMOD1_7;

//  input wire [3:0]dip_switch_4bits_tri_i;
//  output wire [3:0]led_4bits_tri_o;

  wire [7:0]PMOD0_tri_i;
  wire [7:0]PMOD0_tri_o;
  wire [7:0]PMOD0_tri_z;
  
  assign PMOD0_tri_i[0] = PMOD0_0;
  assign PMOD0_tri_i[1] = PMOD0_1;
  assign PMOD0_tri_i[2] = PMOD0_2;
  assign PMOD0_tri_i[3] = PMOD0_3;
  assign PMOD0_tri_i[4] = PMOD0_4;
  assign PMOD0_tri_i[5] = PMOD0_5;
  assign PMOD0_tri_i[6] = PMOD0_6;
  assign PMOD0_tri_i[7] = PMOD0_7;
  
  assign PMOD0_0 = PMOD0_tri_z[0] ? 1'bz : PMOD0_tri_o[0];
  assign PMOD0_1 = PMOD0_tri_z[1] ? 1'bz : PMOD0_tri_o[1];
  assign PMOD0_2 = PMOD0_tri_z[2] ? 1'bz : PMOD0_tri_o[2];
  assign PMOD0_3 = PMOD0_tri_z[3] ? 1'bz : PMOD0_tri_o[3];
  assign PMOD0_4 = PMOD0_tri_z[4] ? 1'bz : PMOD0_tri_o[4];
  assign PMOD0_5 = PMOD0_tri_z[5] ? 1'bz : PMOD0_tri_o[5];
  assign PMOD0_6 = PMOD0_tri_z[6] ? 1'bz : PMOD0_tri_o[6];
  assign PMOD0_7 = PMOD0_tri_z[7] ? 1'bz : PMOD0_tri_o[7];

  assign SH0_IO[0] = PMOD0_0;
  assign SH0_IO[1] = PMOD0_1;
  assign SH0_IO[2] = PMOD0_2;
  assign SH0_IO[3] = PMOD0_3;
  assign CS_TMS = PMOD0_4;
  assign SH0_IO[5] = PMOD0_5;
  assign SH0_IO[6] = PMOD0_6;
  assign CS_TCK = PMOD0_7;

//  wire [7:0]PMOD1_tri_i;
//  wire [7:0]PMOD1_tri_o;
//  wire [7:0]PMOD1_tri_z;
  
//  assign PMOD1_tri_i[0] = PMOD1_0;
//  assign PMOD1_tri_i[1] = PMOD1_1;
//  assign PMOD1_tri_i[2] = PMOD1_2;
//  assign PMOD1_tri_i[3] = PMOD1_3;
//  assign PMOD1_tri_i[4] = PMOD1_4;
//  assign PMOD1_tri_i[5] = PMOD1_5;
//  assign PMOD1_tri_i[6] = PMOD1_6;
//  assign PMOD1_tri_i[7] = PMOD1_7;
  
//  assign PMOD1_0 = PMOD1_tri_z[0] ? 1'bz : PMOD1_tri_o[0];
//  assign PMOD1_1 = PMOD1_tri_z[1] ? 1'bz : PMOD1_tri_o[1];
//  assign PMOD1_2 = PMOD1_tri_z[2] ? 1'bz : PMOD1_tri_o[2];
//  assign PMOD1_3 = PMOD1_tri_z[3] ? 1'bz : PMOD1_tri_o[3];
//  assign PMOD1_4 = PMOD1_tri_z[4] ? 1'bz : PMOD1_tri_o[4];
//  assign PMOD1_5 = PMOD1_tri_z[5] ? 1'bz : PMOD1_tri_o[5];
//  assign PMOD1_6 = PMOD1_tri_z[6] ? 1'bz : PMOD1_tri_o[6];
//  assign PMOD1_7 = PMOD1_tri_z[7] ? 1'bz : PMOD1_tri_o[7];
//REFCLK24MHZ                 24        MHz
//******************************************************************************
BUFG uBUFG_REFCLK24MHZ    (.I(OSCCLK[0]), .O(REFCLK24MHZ));

//ACLK  Big CPU        50        MHz
//******************************************************************************
BUFG uBUFG_iACLK        (.I(OSCCLK[1]), .O(ACLK));        //Big CPU        50        MHz
BUFG uBUFG_iBCLK        (.I(OSCCLK[2]), .O(BCLK)); 
//******************************************************************************
// SMBMCLK     Micro SMB            25    MHz
//******************************************************************************
BUFG uBUFG_SMBM        (.I(SMBM_CLK),     .O(iSMBMCLK));    //Micro SMB

//******************************************************************************
// Main body of code
// =================
//******************************************************************************
  assign SMBF_FIFOSEL  = 1'b0;
  assign SMBF_ADDR	   = {7{1'b0}};
  assign CLCD_BL       = 1'b0;                     // Extinguish LCD back light
  // Minimum design tie-offs
  assign MMB_IDCLK     = 1'b0;
  assign EMMC_CLK      = 1'b0;
  assign QSPI_nCS      = 1'b1;
  assign QSPI_SCLK     = 1'b0;
  assign IOFPGA_SYSWDT = 1'b0;
  assign WDOG_RREQ     = 1'b0;
  assign SMBM_nWAIT    = 1'b1;
  assign CFG_DATAOUT   = 1'b0;
  wire nRST;
  reg  rst_sync0, rst_sync1, rst_sync2;
  assign nRST_in = CB_nRST || CS_nSRST;
  assign nRST = rst_sync2;

  always @(posedge ACLK)
    if (~nRST_in) begin
      rst_sync0 <= 1'b0;
      rst_sync1 <= 1'b0;
    end else begin
      rst_sync0 <= 1'b1;
      rst_sync1 <= rst_sync0;
      rst_sync2 <= rst_sync1;
    end

  nanosoc_design nanosoc_design_i
       (.UART_RX(UART_RX_F[2]),
       .UART_TX(UART_TX_F[2]),
       .EXT_CLK(ACLK),
       .nRST_CPU(nRST),   
       .pmoda_tri_i(PMOD0_tri_i),
       .pmoda_tri_o(PMOD0_tri_o),
       .pmoda_tri_z(PMOD0_tri_z)
//       .PMOD1_tri_i(PMOD1_tri_i),
//       .PMOD1_tri_o(PMOD1_tri_o),
//       .PMOD1_tri_z(PMOD1_tri_z),
//        .dip_switch_4bits_tri_i(dip_switch_4bits_tri_i),
//        .led_4bits_tri_o(led_4bits_tri_o)
        );
endmodule
