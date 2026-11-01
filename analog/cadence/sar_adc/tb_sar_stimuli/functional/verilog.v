//Verilog HDL for "sar_adc", "tb_sar_stimuli" "functional"
`timescale 1ns/10ps

module tb_sar_stimuli #(
	parameter real TCLK = 1000.0, 	// clock period in ns (1 MHZ)
	parameter real T_RST = 3000.0, 	// rstn low time in ns
	parameter	  DO_CAL = 0 		// 1 -> calibration
	)(
	output reg clk,
	output reg rstn,
	output reg en,
	output reg cal
	);

	initial begin
		clk = 1'b0;
		rstn = 1'b0;
		en = 1'b0;
		cal = DO_CAL;
	
		#(T_RST) rstn = 1'b1;
		#(2*TCLK) en = 1'b1;
	end

	always #(TCLK/2) clk = ~clk;
endmodule
