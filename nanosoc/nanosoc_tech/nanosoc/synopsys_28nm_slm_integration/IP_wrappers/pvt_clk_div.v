module pvt_clk_div(
    input  wire         clk_i,
    input  wire         resetn,
    input  wire [7:0]   clk_div,
    output wire         clk_o
);

reg [7:0]   clk_counter;
reg         slow_clk;
assign      clk_o = slow_clk;

always @(posedge clk_i or negedge resetn) begin
    if(~resetn) begin
        clk_counter <= 8'h00;
        slow_clk <= 1'b0;
    end else begin
        if(clk_counter >= clk_div - 1) begin
            clk_counter <= 8'h00;
            slow_clk <= ~ slow_clk;
        end else begin
            clk_counter <= clk_counter + 8'd1;
        end
    end
end

endmodule
