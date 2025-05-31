//-----------------------------------------------------------------------------
// SoC Labs Valid Signal Filter Module
// A joint work commissioned on behalf of SoC Labs; under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright 2023; SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module wrapper_valid_filter(
   input  logic 	  clk,
   input  logic 	  rst,
   input  logic	      data_in_last,
   input  logic	      data_in_valid,
   input  logic 	  data_in_ready,
   input  logic	      data_out_valid,
   output logic       payload_out_valid
); 

logic [63:0] block_count, count_check, digest_count;
logic prev_last;
logic prev_data_out_valid;

always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
        block_count  <= 'd0;
        count_check  <= 'd0;
        digest_count <= 'd0;
        prev_data_out_valid <= 'd0;
        // payload_out_valid <= 1'd0;
        prev_last <= 1'd0;
    end else begin
        prev_data_out_valid <= data_out_valid;
        if (data_in_valid && data_in_ready) begin
            prev_last <= data_in_last;
            if (data_in_last) begin
                block_count <= 'd0;
                count_check <= block_count + 1'd1;
            end else begin
                block_count <= block_count + 64'd1;
            end
        end
        if (data_out_valid == 1'd0 && prev_data_out_valid == 1'd1) begin
            if (digest_count == (count_check - 64'd1)) begin
                digest_count <= 'd0;
                // payload_out_valid <= 1'b1;
            end else begin
                digest_count <= digest_count + 'd1;
            end
        end
    end
end

// Only takes Valid High for 1 Clock Cycle (Requires Change) and only takes valid high on when correct number of output packets seen
assign payload_out_valid = (digest_count == (count_check - 64'd1)) && ~prev_data_out_valid ? data_out_valid : 1'b0;
endmodule