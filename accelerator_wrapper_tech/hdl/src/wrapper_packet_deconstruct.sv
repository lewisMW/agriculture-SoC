//-----------------------------------------------------------------------------
// SoC Labs Wrapper Files
// - Accelerator Packet Deconstruction from AHB Read Transactions
// A joint work commissioned on behalf of SoC Labs; under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright 2023; SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
module  wrapper_packet_deconstruct #(
  parameter   ADDRWIDTH=11,
  parameter   PACKETWIDTH=256,
  localparam  PACKETBYTEWIDTH  = $clog2(PACKETWIDTH/8),     // Number of Bytes in Packet
  localparam  PACKETSPACEWIDTH = ADDRWIDTH-PACKETBYTEWIDTH // Number of Bits to represent all Packets in Address Space
)(
  input  logic                  hclk,       // clock
  input  logic                  hresetn,    // reset

   //Register interface
  input  logic [ADDRWIDTH-1:0]   addr,
  input  logic                   read_en,
  input  logic                   write_en,
  input  logic [3:0]             byte_strobe,
  input  logic [31:0]            wdata,
  output logic [31:0]            rdata,
  output logic                   wready,
  output logic                   rready,

  // Valid/Ready interface
  input  logic [PACKETWIDTH-1:0]      packet_data,
  input  logic                        packet_data_last,
  input  logic [PACKETSPACEWIDTH-1:0] packet_data_remain, // Number of remaining packets after this transfer
  input  logic                        packet_data_valid,
  output logic                        packet_data_ready,
  
  // Number of Packets in Current
  output logic [PACKETSPACEWIDTH:0]   block_packet_count,

  output logic                        deconstructor_ready
);



// Create Deconstruction Buffer
logic [(PACKETWIDTH/32)-1:0][31:0] deconst_buf;
assign deconst_buf = packet_data;

// Create Array to Flag which buffers have been read
logic [(PACKETWIDTH/32)-1:0] deconst_buf_flag;

// Select which word in buffer to read 
logic [$clog2(PACKETWIDTH/32)-1:0] buf_word_sel;
assign buf_word_sel = addr[($clog2(PACKETWIDTH/32)-1)+2:2];

// Curent Buffer Flag
logic [(PACKETWIDTH/32)-1:0] cur_deconst_buf_flag;
assign cur_deconst_buf_flag = 1'b1 << buf_word_sel;

// Check All Flags are High
logic deconst_buf_flag_reduced;
assign deconst_buf_flag_reduced = &(deconst_buf_flag | (cur_deconst_buf_flag));

logic deconst_buf_valid;
assign deconstructor_ready = deconst_buf_valid;

// Previous Packet Last
logic prev_packet_last;

// Dump data on one of two conditions
// - An address ends [5:0] in 0x3C i.e. [5:2] == 0xF
// - Address Moved to different 512 bit word
// Write Condition
always_ff @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
        // Reset Values
        block_packet_count <= {(PACKETSPACEWIDTH+1){1'b0}};
        packet_data_ready  <= 1'b0;
        deconst_buf_valid  <= 1'b0;
        deconst_buf_flag   <= {(PACKETWIDTH/32){1'b0}};
        prev_packet_last   <= 1'b1;
    end else begin
        if (packet_data_valid && packet_data_ready) begin
            packet_data_ready <= 1'b0;
        end
        // If buffer isn't valid but valid data on input, assert buffer valid
        if ((packet_data_valid && !packet_data_ready) && !deconst_buf_valid) begin
            deconst_buf_valid  <= 1'b1;
            deconst_buf_flag   <= {(PACKETWIDTH/32){1'b0}};
            packet_data_ready  <= 1'b0;
            // Update block_packet_count 
            block_packet_count <= prev_packet_last ? ({1'b0, packet_data_remain} + 'b1) : block_packet_count;
        end
        if (read_en) begin
            // Register which words in the Deconstruction buffer have been read
            // Check if All Words have been Read
            if (deconst_buf_flag_reduced && deconst_buf_valid) begin
                // Set Ready High To Get more Data into Buffer
                deconst_buf_valid  <= 1'b0;
                packet_data_ready  <= 1'b1;
                prev_packet_last   <= packet_data_last;
            end else begin
                deconst_buf_flag   <= deconst_buf_flag | cur_deconst_buf_flag;
            end
        end
    end
end

// Read Condition
always_comb begin
    if (read_en) begin
        // Read appropriate 32 bits from buffer - wrapping behaviour
        rdata = deconst_buf[buf_word_sel];
    end else begin
        rdata = 32'd0;
    end
end

// Register Ready Control
always_comb begin
    // Ready when data in deconstruction buffer
    rready = deconst_buf_valid;
    // Write Ready always high but doesn't do anywthing
    wready = 1'b1;
end

endmodule