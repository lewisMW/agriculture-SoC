//Verilog HDL for "SoC_probe", "dig_sti_tb" "functional"


module dig_sti_tb #(parameter real FS=100e3, parameter integer BITS=8)(
	output reg clk,
	output reg resetn
);
	
	always #(1250) clk = ~clk; // 800 kHz for 8-bits @100kHz

	initial begin
		clk=0;
		resetn = 1;
		#(1250) resetn = 0; // release once
		#(5*1250) resetn = 1;
		
	end
endmodule
