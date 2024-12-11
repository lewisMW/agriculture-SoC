//-----------------------------------------------------------------------------
// SoC Labs AHB Packet Deconstructor
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright  2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
module wrapper_ahb_packet_deconstructor #(
  //parameter for address width
  parameter   ADDRWIDTH=11,
  parameter   PACKETWIDTH=256,
  localparam  PACKETBYTEWIDTH  = $clog2(PACKETWIDTH/8),     // Number of Bytes in Packet
  localparam  PACKETSPACEWIDTH = ADDRWIDTH-PACKETBYTEWIDTH  // Number of Bits to represent all Packets in Address Space
)(
  input  logic                  hclk,       // clock
  input  logic                  hresetn,    // reset

  // AHB Input Port
  input  logic                  hsels,
  input  logic [ADDRWIDTH-1:0]  haddrs,
  input  logic [1:0]            htranss,
  input  logic [2:0]            hsizes,
  input  logic                  hwrites,
  input  logic                  hreadys,
  input  logic [31:0]           hwdatas,

  output logic                  hreadyouts,
  output logic                  hresps,
  output logic [31:0]           hrdatas,

  // Valid/Ready Input Port
  input  logic [PACKETWIDTH-1:0]      packet_data,
  input  logic                        packet_data_last,
  input  logic [PACKETSPACEWIDTH-1:0] packet_data_remain, // Number of remaining packets after this transfer
  input  logic                        packet_data_valid,
  output logic                        packet_data_ready,

  // Data Request Signal
  output logic                   data_req,

  // Start Read Address for Current Block
  output logic [ADDRWIDTH-1:0]  block_read_addr
 );



 // Register Interface Connections
 logic [ADDRWIDTH-1:0]  addr;
 logic                  read_en;
 logic                  write_en;
 logic [3:0]            byte_strobe;
 logic [31:0]           wdata;
 logic [31:0]           rdata;
 logic                  wready;
 logic                  rready;

 // Deconstructor Ready for more Data
 logic deconstructor_ready;
 
 // Number of Packets in Block
 logic [PACKETSPACEWIDTH:0] block_packet_count;

 // AHB Interface Instantiation
 wrapper_ahb_reg_interface #(
    ADDRWIDTH
 ) ahb_reg_interface_inst (
    .hclk         (hclk),
    .hresetn      (hresetn),

    // Input slave port: 32 bit data bus interface
    .hsels        (hsels),
    .haddrs       (haddrs),
    .htranss      (htranss),
    .hsizes       (hsizes),
    .hwrites      (hwrites),
    .hreadys      (hreadys),
    .hwdatas      (hwdatas),

    .hreadyouts   (hreadyouts),
    .hresps       (hresps),
    .hrdatas      (hrdatas),

    // Register Output interface
    .addr        (addr),
    .read_en     (read_en),
    .write_en    (write_en),
    .byte_strobe (byte_strobe),
    .wdata       (wdata),
    .rdata       (rdata),
    .wready      (wready),
    .rready      (rready)
 );

 // Data Request Signal Generator
 wrapper_data_req #(
    ADDRWIDTH,   // Only half address map allocated to this device
    PACKETWIDTH  // Packet Width
  ) u_wrapper_data_req (
    .hclk              (hclk),
    .hresetn           (hresetn),

    // AHB Address Phase Signaling
    .hsels             (hsels),
    .haddrs            (haddrs),
    .htranss           (htranss),
    .hreadys           (hreadys),

    // Constructor Data Ready Signal
    .constructor_ready (deconstructor_ready),

    // Data Request Signal 
    .data_req          (data_req)
 );
 
 // Relative Read Address Calculator
 wrapper_addr_calc #(
    ADDRWIDTH,  // Only half address map allocated to this device
    PACKETWIDTH // Packet Width
 ) u_wrapper_addr_calc (
   // Address Interfaces
   .block_packet_count   (block_packet_count),
   .block_addr           (block_read_addr)
 );

 // Valid/Ready Packet Generator
 wrapper_packet_deconstruct #(
    ADDRWIDTH,  // Only half address map allocated to this device
    PACKETWIDTH // Packet Width
 ) u_wrapper_packet_deconstruct (
    .hclk                (hclk),
    .hresetn             (hresetn),

    // Register interface
    .addr                (addr),
    .read_en             (read_en),
    .write_en            (write_en),
    .byte_strobe         (byte_strobe),
    .wdata               (wdata),
    .rdata               (rdata),
    .wready              (wready),
    .rready              (rready),

    // Valid/Ready Interface
    .packet_data         (packet_data),
    .packet_data_last    (packet_data_last),
    .packet_data_remain  (packet_data_remain),
    .packet_data_valid   (packet_data_valid),
    .packet_data_ready   (packet_data_ready),

    // Block Packet Count
    .block_packet_count  (block_packet_count),

    // Data Request 
    .deconstructor_ready (deconstructor_ready)
  );
endmodule