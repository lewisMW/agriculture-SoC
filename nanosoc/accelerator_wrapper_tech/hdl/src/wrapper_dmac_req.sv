//-----------------------------------------------------------------------------
// SoC Labs DMAC Request Controller
// - Adapted from ARM AHB-lite example slave interface module.
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright  2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : Looks for last word address of packet during address phase 
//            to de-assert accelerator ready signal.
//-----------------------------------------------------------------------------
module wrapper_dmac_req #(
  parameter   ADDRWIDTH=11,
  parameter   DATAWIDTH=32
)(
  input  logic                  hclk,       // clock
  input  logic                  hresetn,    // reset
  
  // Request Channel 0
  input  logic                 data_req_active_0,
  input  logic                 data_req_en_0,
  output logic                 data_req_0,

  // Request Channel 1
  input  logic                 data_req_active_1,
  input  logic                 data_req_en_1,
  output logic                 data_req_1,

  // Request Channel 2
  input  logic                 data_req_active_2,
  input  logic                 data_req_en_2,
  output logic                 data_req_2,

  // Request Channel 3
  input  logic                 data_req_active_3,
  input  logic                 data_req_en_3,
  output logic                 data_req_3,

  // Request Channel 4
  input  logic                 data_req_active_4,
  input  logic                 data_req_en_4,
  output logic                 data_req_4
);

  assign data_req_0 = data_req_active_0 & data_req_en_0;
  assign data_req_1 = data_req_active_1 & data_req_en_1;
  assign data_req_2 = data_req_active_2 & data_req_en_2;
  assign data_req_3 = data_req_active_3 & data_req_en_3;
  assign data_req_4 = data_req_active_4 & data_req_en_4;

endmodule