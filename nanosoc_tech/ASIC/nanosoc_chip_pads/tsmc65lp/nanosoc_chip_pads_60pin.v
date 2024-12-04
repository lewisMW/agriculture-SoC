//-----------------------------------------------------------------------------
// Top-Level Pad implementation for TSMC65nm
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2013 Arm Limited or its affiliates.
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
//-----------------------------------------------------------------------------
// Abstract : Top level for example Cortex-M0/Cortex-M0+ microcontroller
//-----------------------------------------------------------------------------
//
`define POWER_PINS
module nanosoc_chip_pads (
  inout  wire          VDDIO,
  inout  wire          VSSIO,
  inout  wire          VDD,
  inout  wire          VSS,
  inout  wire          VDDACC,

  input  wire          CLK, // input
  input  wire          TEST, // input
  input  wire          NRST,  // active low reset
  inout  wire  [15:0]  P0,
  inout  wire  [15:0]  P1,
  inout  wire          SWDIO,
  input  wire          SWDCK
  );


//------------------------------------
// internal wires

  wire          clk_i;
  wire          test_i;
  wire          nrst_i;
  wire  [15:0]  p0_i; // level-shifted input from pad
  wire  [15:0]  p0_o; // output port drive
  wire  [15:0]  p0_e; // active high output drive enable (pad tech dependent)
  wire  [15:0]  p0_z; // active low output drive enable (pad tech dependent)
  wire  [15:0]  p1_i; // level-shifted input from pad
  wire  [15:0]  p1_o; // output port drive
  wire  [15:0]  p1_e; // active high output drive enable (pad tech dependent)
  wire  [15:0]  p1_z; // active low output drive enable (pad tech dependent)

  wire          swdio_i;
  wire          swdio_o;
  wire          swdio_e;
  wire          swdio_z;
  wire          swdclk_i;

 // --------------------------------------------------------------------------------
 // Cortex-M0 nanosoc Microcontroller
 // --------------------------------------------------------------------------------

  nanosoc_chip u_nanosoc_chip (
`ifdef POWER_PINS
  .VDD        (VDD),
  .VSS        (VSS),
  .VDDACC     (VDDACC),
`endif
  .clk_i(clk_i),
  .test_i(test_i),
  .nrst_i(nrst_i),
  .p0_i(p0_i), // level-shifted input from pad
  .p0_o(p0_o), // output port drive
  .p0_e(p0_e), // active high output drive enable (pad tech dependent)
  .p0_z(p0_z), // active low output drive enable (pad tech dependent)
  .p1_i(p1_i), // level-shifted input from pad
  .p1_o(p1_o), // output port drive
  .p1_e(p1_e), // active high output drive enable (pad tech dependent)
  .p1_z(p1_z), // active low output drive enable (pad tech dependent)
  .swdio_i(swdio_i),
  .swdio_o(swdio_o),
  .swdio_e(swdio_e),
  .swdio_z(swdio_z),
  .swdclk_i(swdclk_i)
  );


//TIE_HI uTIEHI (.tiehi(tiehi));
 wire tiehi = 1'b1;
//TIE_LO uTIELO (.tielo(tielo));
 wire tielo = 1'b0;


 wire dft_sdi_1, dft_sdi_2, dft_sdo_1, dft_sdo_2;
 // --------------------------------------------------------------------------------
 // IO pad (GLIB Generic Library napping)
 // --------------------------------------------------------------------------------

// Pad IO power supplies

PVDD2CDG uPAD_VDDIO_0(
   .VDDPST(VDDIO)
   );
PVDD2CDG uPAD_VDDIO_1(
   .VDDPST(VDDIO)
   );
PVDD2CDG uPAD_VDDIO_2(
   .VDDPST(VDDIO)
   );
PVDD2POC uPAD_VDDIO_3(
   .VDDPST(VDDIO)
   );

PVSS3CDG uPAD_VSSIO_0(
   .VSS(VSS)
   );
PVSS3CDG uPAD_VSSIO_1(
   .VSS(VSS)
   );


// Core power supplies

PVDD1CDG uPAD_VDD_0(
   .VDD(VDD)
   );
PVDD1CDG uPAD_VDD_1(
   .VDD(VDD)
   );
PVDD1CDG uPAD_VDD_2(
   .VDD(VDD)
   );
PVDD1CDG uPAD_VDD_3(
   .VDD(VDD)
   );

PVSS3CDG uPAD_VSS_0(
   .VSS(VSS)
   );
PVSS3CDG uPAD_VSS_1(
   .VSS(VSS)
   );
PVSS3CDG uPAD_VSS_2(
   .VSS(VSS)
   );
PVSS3CDG uPAD_VSS_3(
   .VSS(VSS)
   );
// Accelerator Power supplies
PVDD1CDG uPAD_VDDACC_0(
   .VDD(VDDACC)
   );
PVDD1CDG uPAD_VDDACC_1(
   .VDD(VDDACC)
   );
PVDD1CDG uPAD_VDDACC_2(
   .VDD(VDDACC)
   );

// Clock, Reset and Serial Wire Debug ports

PRDW0408SCDG uPAD_CLK_I (
    .IE(tiehi),
    .C(clk_i),
    .PE(tielo),
    .DS(tielo),
    .I(tielo),
    .OEN(tiehi),
    .PAD(CLK)
   );

PRDW0408SCDG uPAD_TEST_I (
    .IE(tiehi),
    .C(test_i),
    .PE(tielo),
    .DS(tielo),
    .I(tielo),
    .OEN(tiehi),
    .PAD(TEST)
   );

PRDW0408SCDG uPAD_NRST_I (
    .IE(tiehi),
    .C(nrst_i),
    .PE(tielo),
    .DS(tielo),
    .I(tielo),
    .OEN(tiehi),
    .PAD(NRST)
   );

PRDW0408SCDG uPAD_SWDIO_IO (
    .IE(swdio_z),
    .C(swdio_i),
    .PE(tielo),
    .DS(tielo),
    .I(swdio_o),
    .OEN(swdio_z),
    .PAD(SWDIO)
   );

PRDW0408SCDG uPAD_SWDCK_I (
    .IE(tiehi),
    .C(swdclk_i),
    .PE(tielo),
    .DS(tielo),
    .I(tielo),
    .OEN(tiehi),
    .PAD(SWDCK)
   );

// GPI.I Port 0 x 16

PRDW0408SCDG uPAD_P0_00 (
    .IE(p0_z[00]),
    .C(p0_i[00]),
    .PE(p0_z[00]&p0_o[00]),
    .DS(tielo),
    .I(p0_o[00]),
    .OEN(p0_z[00]),
    .PAD(P0[00])
   );

PRDW0408SCDG uPAD_P0_01 (
    .IE(p0_z[01]),
    .C(p0_i[01]),
    .PE(p0_z[01]&p0_o[01]),
    .DS(tielo),
    .I(p0_o[01]),
    .OEN(p0_z[01]),
    .PAD(P0[01])
   );
  
PRDW0408SCDG uPAD_P0_02 (
    .IE(p0_z[02]),
    .C(p0_i[02]),
    .PE(p0_z[02]&p0_o[02]),
    .DS(tielo),
    .I(p0_o[02]),
    .OEN(p0_z[02]),
    .PAD(P0[02])
   );

PRDW0408SCDG uPAD_P0_03 (
    .IE(p0_z[03]),
    .C(p0_i[03]),
    .PE(p0_z[03]&p0_o[03]),
    .DS(tielo),
    .I(p0_o[03]),
    .OEN(p0_z[03]),
    .PAD(P0[03])
   );

PRDW0408SCDG uPAD_P0_04 (
    .IE(p0_z[04]),
    .C(p0_i[04]),
    .PE(p0_z[04]&p0_o[04]),
    .DS(tielo),
    .I(p0_o[04]),
    .OEN(p0_z[04]),
    .PAD(P0[04])
   );

PRDW0408SCDG uPAD_P0_05 (
    .IE(p0_z[05]),
    .C(p0_i[05]),
    .PE(p0_z[05]&p0_o[05]),
    .DS(tielo),
    .I(p0_o[05]),
    .OEN(p0_z[05]),
    .PAD(P0[05])
   );
  
PRDW0408SCDG uPAD_P0_06 (
    .IE(p0_z[06]),
    .C(p0_i[06]),
    .PE(p0_z[06]&p0_o[06]),
    .DS(tielo),
    .I(p0_o[06]),
    .OEN(p0_z[06]),
    .PAD(P0[06])
   );

PRDW0408SCDG uPAD_P0_07 (
    .IE(p0_z[07]),
    .C(p0_i[07]),
    .PE(p0_z[07]&p0_o[07]),
    .DS(tielo),
    .I(p0_o[07]),
    .OEN(p0_z[07]),
    .PAD(P0[07])
   );
  
PRDW0408SCDG uPAD_P0_08 (
    .IE(p0_z[08]),
    .C(p0_i[08]),
    .PE(p0_z[08]&p0_o[08]),
    .DS(tielo),
    .I(p0_o[08]),
    .OEN(p0_z[08]),
    .PAD(P0[08])
   );

PRDW0408SCDG uPAD_P0_09 (
    .IE(p0_z[09]),
    .C(p0_i[09]),
    .PE(p0_z[09]&p0_o[09]),
    .DS(tielo),
    .I(p0_o[09]),
    .OEN(p0_z[09]),
    .PAD(P0[09])
   );
  
PRDW0408SCDG uPAD_P0_10 (
    .IE(p0_z[10]),
    .C(p0_i[10]),
    .PE(p0_z[10]&p0_o[10]),
    .DS(tielo),
    .I(p0_o[10]),
    .OEN(p0_z[10]),
    .PAD(P0[10])
   );

PRDW0408SCDG uPAD_P0_11 (
    .IE(p0_z[11]),
    .C(p0_i[11]),
    .PE(p0_z[11]&p0_o[11]),
    .DS(tielo),
    .I(p0_o[11]),
    .OEN(p0_z[11]),
    .PAD(P0[11])
   );
  
PRDW0408SCDG uPAD_P0_12 (
    .IE(p0_z[12]),
    .C(p0_i[12]),
    .PE(p0_z[12]&p0_o[12]),
    .DS(tielo),
    .I(p0_o[12]),
    .OEN(p0_z[12]),
    .PAD(P0[12])
   );

PRDW0408SCDG uPAD_P0_13 (
    .IE(p0_z[13]),
    .C(p0_i[13]),
    .PE(p0_z[13]&p0_o[13]),
    .DS(tielo),
    .I(p0_o[13]),
    .OEN(p0_z[13]),
    .PAD(P0[13])
   );
  
PRDW0408SCDG uPAD_P0_14 (
    .IE(p0_z[14]),
    .C(p0_i[14]),
    .PE(p0_z[14]&p0_o[14]),
    .DS(tielo),
    .I(p0_o[14]),
    .OEN(p0_z[14]),
    .PAD(P0[14])
   );

PRDW0408SCDG uPAD_P0_15 (
    .IE(p0_z[15]),
    .C(p0_i[15]),
    .PE(p0_z[15]&p0_o[15]),
    .DS(tielo),
    .I(p0_o[15]),
    .OEN(p0_z[15]),
    .PAD(P0[15])
   );
  
// GPI.I Port 1 x 16

PRDW0408SCDG uPAD_P1_00 (
    .IE(p1_z[00]),
    .C(p1_i[00]),
    .PE(p1_z[00]&p1_o[00]),
    .DS(tielo),
    .I(p1_o[00]),
    .OEN(p1_z[00]),
    .PAD(P1[00])
   );

PRDW0408SCDG uPAD_P1_01 (
    .IE(p1_z[01]),
    .C(p1_i[01]),
    .PE(p1_z[01]&p1_o[01]),
    .DS(tielo),
    .I(p1_o[01]),
    .OEN(p1_z[01]),
    .PAD(P1[01])
   );
  
PRDW0408SCDG uPAD_P1_02 (
    .IE(p1_z[02]),
    .C(p1_i[02]),
    .PE(p1_z[02]&p1_o[02]),
    .DS(tielo),
    .I(p1_o[02]),
    .OEN(p1_z[02]),
    .PAD(P1[02])
   );

PRDW0408SCDG uPAD_P1_03 (
    .IE(p1_z[03]),
    .C(p1_i[03]),
    .PE(p1_z[03]&p1_o[03]),
    .DS(tielo),
    .I(p1_o[03]),
    .OEN(p1_z[03]),
    .PAD(P1[03])
   );

PRDW0408SCDG uPAD_P1_04 (
    .IE(p1_z[04]),
    .C(p1_i[04]),
    .PE(p1_z[04]&p1_o[04]),
    .DS(tielo),
    .I(p1_o[04]),
    .OEN(p1_z[04]),
    .PAD(P1[04])
   );

PRDW0408SCDG uPAD_P1_05 (
    .IE(p1_z[05]),
    .C(p1_i[05]),
    .PE(p1_z[05]&p1_o[05]),
    .DS(tielo),
    .I(p1_o[05]),
    .OEN(p1_z[05]),
    .PAD(P1[05])
   );
  
PRDW0408SCDG uPAD_P1_06 (
    .IE(p1_z[06]),
    .C(p1_i[06]),
    .PE(p1_z[06]&p1_o[06]),
    .DS(tielo),
    .I(p1_o[06]),
    .OEN(p1_z[06]),
    .PAD(P1[06])
   );

PRDW0408SCDG uPAD_P1_07 (
    .IE(p1_z[07]),
    .C(p1_i[07]),
    .PE(p1_z[07]&p1_o[07]),
    .DS(tielo),
    .I(p1_o[07]),
    .OEN(p1_z[07]),
    .PAD(P1[07])
   );
  
PRDW0408SCDG uPAD_P1_08 (
    .IE(p1_z[08]),
    .C(p1_i[08]),
    .PE(p1_z[08]&p1_o[08]),
    .DS(tielo),
    .I(p1_o[08]),
    .OEN(p1_z[08]),
    .PAD(P1[08])
   );

PRDW0408SCDG uPAD_P1_09 (
    .IE(p1_z[09]),
    .C(p1_i[09]),
    .PE(p1_z[09]&p1_o[09]),
    .DS(tielo),
    .I(p1_o[09]),
    .OEN(p1_z[09]),
    .PAD(P1[09])
   );
  
PRDW0408SCDG uPAD_P1_10 (
    .IE(p1_z[10]),
    .C(p1_i[10]),
    .PE(p1_z[10]&p1_o[10]),
    .DS(tielo),
    .I(p1_o[10]),
    .OEN(p1_z[10]),
    .PAD(P1[10])
   );

PRDW0408SCDG uPAD_P1_11 (
    .IE(p1_z[11]),
    .C(p1_i[11]),
    .PE(p1_z[11]&p1_o[11]),
    .DS(tielo),
    .I(p1_o[11]),
    .OEN(p1_z[11]),
    .PAD(P1[11])
   );
  
PRDW0408SCDG uPAD_P1_12 (
    .IE(p1_z[12]),
    .C(p1_i[12]),
    .PE(p1_z[12]&p1_o[12]),
    .DS(tielo),
    .I(p1_o[12]),
    .OEN(p1_z[12]),
    .PAD(P1[12])
   );

PRDW0408SCDG uPAD_P1_13 (
    .IE(p1_z[13]),
    .C(p1_i[13]),
    .PE(p1_z[13]&p1_o[13]),
    .DS(tielo),
    .I(p1_o[13]),
    .OEN(p1_z[13]),
    .PAD(P1[13])
   );
  
PRDW0408SCDG uPAD_P1_14 (
    .IE(p1_z[14]),
    .C(p1_i[14]),
    .PE(p1_z[14]&p1_o[14]),
    .DS(tielo),
    .I(p1_o[14]),
    .OEN(p1_z[14]),
    .PAD(P1[14])
   );

PRDW0408SCDG uPAD_P1_15 (
    .IE(p1_z[15]),
    .C(p1_i[15]),
    .PE(p1_z[15]&p1_o[15]),
    .DS(tielo),
    .I(p1_o[15]),
    .OEN(p1_z[15]),
    .PAD(P1[15])
   );

endmodule



