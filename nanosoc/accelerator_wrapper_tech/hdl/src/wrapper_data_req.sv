//-----------------------------------------------------------------------------
// SoC Labs AHB Wrapper Write Ready Generator
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
module wrapper_data_req #(
  parameter   ADDRWIDTH=11,
  parameter   PACKETWIDTH=512
)(
  input  logic                  hclk,       // clock
  input  logic                  hresetn,    // reset

  // AHB connection to master (Address-phase signals only)
  input  logic                  hsels,
  input  logic [ADDRWIDTH-1:0]  haddrs,
  input  logic [1:0]            htranss,
  input  logic                  hreadys,

  // Constructor/Deconstructor Ready Signal
  input  logic                  constructor_ready,

  // Connection to wrapper
  output logic                  data_req
);

localparam REGDWIDTH       = 32; // Register Data Width
localparam PACKETBYTEWIDTH = $clog2(PACKETWIDTH/8); // Number of Bytes in Packet
localparam REGDBYTEWIDTH   = $clog2(REGDWIDTH/8); // Number of Bytes in Register Data Word

logic trans_req;
assign trans_req  = hreadys & hsels & htranss[1];

// Check if current address is last word in packet
logic packet_last_word;
assign packet_last_word = &haddrs[PACKETBYTEWIDTH-1:REGDBYTEWIDTH];

// If constructor_ready => data_req EXCEPT if current address is last address
logic constructor_ready_reg;
logic data_req_latched;

always_ff @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
        constructor_ready_reg <= 1'b0;
        data_req_latched <= 1'b0;
    end else begin
        // Buffer engine ready signal to determine state change
        constructor_ready_reg <= constructor_ready;
        // Latch data request signal once seen last address of packet
        if (trans_req && packet_last_word && constructor_ready) begin
            // Latch data request signal
            data_req_latched <= 1'b1;
        // Unlatch when latched and data phase finished
        end else if (data_req_latched && hreadys) begin
            // Unlatch data request signal
            data_req_latched <= 1'b0;
        end
    end
end

always_comb begin
    if (~constructor_ready_reg) begin
        // If engine ready is transitioning from low to high
        data_req = constructor_ready;
    end else begin
        // If seeing last word of packet address and valid transfer request
        if ((trans_req && packet_last_word) || data_req_latched) begin
            // Drop data request signal after address phase of last word in packet
            data_req = 1'b0;
        end else begin
            // After data phase, take value of engine ready
            data_req = constructor_ready;
        end
    end
end
endmodule