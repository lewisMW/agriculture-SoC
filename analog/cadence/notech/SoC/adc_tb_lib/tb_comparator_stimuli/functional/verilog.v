//Verilog HDL for "adc_digital_lib", "tb_comparator_stimuli" "functional"

`timescale 1ns/1ps
module tb_comparator_stimuli (trima, trimb, clk);
	output trima, trimb, clk;
	reg [4:0] trima, trimb;
	reg clk;

	parameter real freq_s = 100000;
	parameter integer trimp = 8;
	parameter integer trimn = 8;

	real time_step;

	initial begin
		clk = 1'b0;
		time_step = 0.5e9/freq_s; // Hz - e.g. 100KHz passed as 100e3 from maestro

		forever #(time_step) clk = ~clk;
	end

	initial begin
		trima = trimp[4:0];
		trimb = trimn[4:0];
	end
endmodule
