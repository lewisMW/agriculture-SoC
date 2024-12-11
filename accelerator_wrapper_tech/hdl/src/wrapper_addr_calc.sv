//-----------------------------------------------------------------------------
// SoC Labs Relative Address Calculator
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright  2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
module wrapper_addr_calc #(
  //parameter for address width
  parameter   ADDRWIDTH=11,
  parameter   PACKETWIDTH=256,
  localparam  PACKETBYTES      = (PACKETWIDTH+7)/8,         // Number of Bytes in Packet
  localparam  PACKETBYTEWIDTH  = $clog2(PACKETBYTES),       // Number of Bits to represent Bytes in Packet
  localparam  PACKETSPACEWIDTH = ADDRWIDTH-PACKETBYTEWIDTH  // Number of Bits to represent all Packets in Address Space
)(
  // Number of Packets in Current Block
  input logic [PACKETSPACEWIDTH:0]   block_packet_count,

  // Start Address
  output logic [ADDRWIDTH-1:0]       block_addr
);


 
 logic [ADDRWIDTH-1:0] block_byte_count;   // Number of Bytes taken up by Block
 logic [ADDRWIDTH:0] end_word_addr;        // First Address at start of next region
 logic [ADDRWIDTH:0] block_addr_ext;  // Relative Address extended by 1 bit
 
 assign block_byte_count = block_packet_count * PACKETBYTES;
 assign end_word_addr = {1'b1,{(ADDRWIDTH){1'b0}}};
 assign block_addr_ext = end_word_addr - block_byte_count;
 assign block_addr = block_addr_ext[ADDRWIDTH-1:0];
 
endmodule