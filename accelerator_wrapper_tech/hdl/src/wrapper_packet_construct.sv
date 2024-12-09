//-----------------------------------------------------------------------------
// SoC Labs Wrapper Files
// - Accelerator Packet Construction from Register Write Transactions
// A joint work commissioned on behalf of SoC Labs; under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright 2023; SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
module  wrapper_packet_construct #(
  parameter   ADDRWIDTH=11,
  parameter   PACKETWIDTH=512
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
  output logic [PACKETWIDTH-1:0] packet_data,
  output logic                   packet_data_last,
  output logic                   packet_data_valid,
  input  logic                   packet_data_ready,

  // Data Input Request
  output logic                   constructor_ready
);

localparam REGDWIDTH       = 32; // Register Data Width
localparam PACKETBYTEWIDTH = $clog2(PACKETWIDTH/8); // Number of Bytes in Packet
localparam REGDBYTEWIDTH   = $clog2(REGDWIDTH/8); // Number of Bytes in Register Data Word

// 4KiB of Address Space for Accelerator (11:0)
// Capture Address to be used for comparision to test for address jumping
logic [ADDRWIDTH-1:0] prev_wr_addr;

// Create Construction Buffer
logic [PACKETWIDTH-1:0] const_buffer;
logic const_buffer_last;

// Calculate which word in packet is to be written to/read from
// PacketSize/Register Data Width = number of Register Words per Packet
// Bytes Per Packet = Bytes per Word * Word per Packet
// example 512-bit packet, 32-bit register data
// addr[5:0]             -> Number of bytes in packet
// addr[5:2]             -> Number of 32-bit words in packet
// addr[5:2] * 32        -> bottom bit of 32-bit word in packet
// (addr[5:2] * 32) + 31 -> top bit of 32-bit word in packet
logic [ADDRWIDTH-1:0] addr_top_bit;
assign addr_top_bit = (addr[PACKETBYTEWIDTH-1:REGDBYTEWIDTH] * REGDWIDTH) + (REGDWIDTH - 1);

// Check if current Register address is last word in packet
logic packet_last_word, prev_packet_last_word;
assign packet_last_word      = &addr         [PACKETBYTEWIDTH-1:REGDBYTEWIDTH];
assign prev_packet_last_word = &prev_wr_addr [PACKETBYTEWIDTH-1:REGDBYTEWIDTH];

// Packet Address - Address of Packet
logic [ADDRWIDTH-PACKETBYTEWIDTH-1:0] packet_addr, prev_packet_addr;
assign packet_addr      = addr         [ADDRWIDTH-1:PACKETBYTEWIDTH];
assign prev_packet_addr = prev_wr_addr [ADDRWIDTH-1:PACKETBYTEWIDTH];

// Packet Last - When packet address all 1's
logic packet_addr_last, prev_packet_addr_last;
assign packet_addr_last      = &packet_addr;
assign prev_packet_addr_last = &prev_packet_addr;

// Engine Ready Assignment
assign constructor_ready = packet_data_ready;

// Write data out when either:
// - Word is last address of current packet
// - Address Moved to address of different packet
// Write Condition
always_ff @(posedge hclk or negedge hresetn) begin
    if (~hresetn) begin
        // Reset Construction Buffer
        const_buffer      <= {PACKETWIDTH{1'b0}};
        // Reset Values
        packet_data_valid <= 1'b0;
        packet_data_last  <= 1'b0;
        packet_data       <= {PACKETWIDTH{1'b0}};
        prev_wr_addr      <= {ADDRWIDTH{1'b0}};
    end else begin
        // Handshake Output
        if (packet_data_ready && packet_data_valid) begin
            packet_data_valid <= 1'b0;
        end
        if (write_en) begin
            // If not (awaiting handshake on output AND address generates new data payload)
            if (!((packet_data_valid && !packet_data_ready) && packet_last_word)) begin
                // Buffer Address for future Comparison
                prev_wr_addr <= addr;

                // If Packet Address Changed - write out value in construction buffer
                // - The output will get overwritten if the current address also causes generation of packet
                // - Check that previous address isn't 0 (just out of reset and no packet actually in buffer)
                if (packet_addr != prev_packet_addr && (prev_wr_addr != {ADDRWIDTH{1'b0}})) begin
                    // Produce Data Output 
                    // packet_data       <= const_buffer; // Write out Previous value of construction buffer
                    // // Calculate Last Flag on previous address 
                    // packet_data_last  <= prev_packet_addr_last;
                    // // Take Valid High
                    // packet_data_valid <= 1'b1;
                    // Clear Construction Buffer
                    const_buffer <= {PACKETWIDTH{1'b0}};
                end

                // Write Word into Construction Buffer
                const_buffer[addr_top_bit -: REGDWIDTH] <= wdata;
                
                // If last register word in packet construction buffer
                if (packet_last_word) begin
                    // Produce Data Output 
                    packet_data       <= {wdata,const_buffer[(PACKETWIDTH-REGDWIDTH-1):0]}; // Top word won't be in const_buffer 
                    // - until next cycle to splice it in to out data combinatorially
                    // Calculate Last Flag
                    packet_data_last  <= packet_addr_last;
                    // Take Valid High
                    packet_data_valid <= 1'b1;
                    // Reset Construction Buffer
                    const_buffer      <= {PACKETWIDTH{1'b0}};
                end
            end
        end
    end
end

// Read Condition
// Read appropriate Register Word from buffer - wrapping behaviour - otherwise read 0
assign rdata = read_en ? const_buffer[addr_top_bit -: REGDWIDTH] : {REGDWIDTH{1'b0}};

// Register Ready Control
// Always able to read
assign rready = 1'b1; 
// Write Ready EXCEPT (when Packet waiting at output AND the current address triggers another packet to be generated at the output 
// - when last word of packet
assign wready = ~((packet_data_valid && ~packet_data_ready) && packet_last_word);

endmodule