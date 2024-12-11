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

module nanosoc_design_wrapper
   (PMOD0_0,
    PMOD0_1,
    PMOD0_2,
    PMOD0_3,
    PMOD0_4,
    PMOD0_5,
    PMOD0_6,
    PMOD0_7
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

  inout wire PMOD0_0;
  inout wire PMOD0_1;
  inout wire PMOD0_2;
  inout wire PMOD0_3;
  inout wire PMOD0_4;
  inout wire PMOD0_5;
  inout wire PMOD0_6;
  inout wire PMOD0_7;
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

  nanosoc_design nanosoc_design_i
       (.pmoda_tri_i(PMOD0_tri_i),
        .pmoda_tri_o(PMOD0_tri_o),
        .pmoda_tri_z(PMOD0_tri_z)//,
//        .PMOD1_tri_i(PMOD1_tri_i),
//        .PMOD1_tri_o(PMOD1_tri_o),
//        .PMOD1_tri_z(PMOD1_tri_z),
//        .dip_switch_4bits_tri_i(dip_switch_4bits_tri_i),
//        .led_4bits_tri_o(led_4bits_tri_o)
        );
endmodule
