//Verilog HDL for "SoC_AFE", "sarlogic" "functional"

`timescale 1ns/10ps

module sarlogic (
	input clk,
	input rstn,
	input en,
	input comp,
	input cal,
	output valid,
	output reg [7:0] result,
	output sample,
	output [7:0] ctlp,
	output [7:0] ctln,
	output [4:0] trim,
	output [4:0] trimb,
	output reg clkc);

	reg calibrate;
	reg [2:0] state;
	reg [7:0] mask;
	reg [4:0] trim_mask;
	reg [4:0] trim_val;
	reg co_clk;
	reg en_co_clk;
	reg [3:0] cal_count;
	reg [3:0] cal_itt;
	reg res_valid;

	parameter sInit = 0, sWait=1, sSample=2, sConv=3, sDone=4, sCal=5;
	
	initial begin
        state <= sInit;
        mask <= 0;
        trim_mask <= 0;
        result <= 0;
        co_clk <= 0;
        en_co_clk <= 0;
        cal_itt <= 0;
        cal_count <= 7;
        trim_val <= 0;
        calibrate <= 0;
        res_valid <= 0;
    end

	always @(clk) begin
		clkc <= (~clk & en_co_clk);
	end

	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			state <= sInit;
            mask <= 0;
            trim_mask <= 0;
            result <= 0;
            co_clk <= 0;
            en_co_clk <= 0;
            cal_itt <= 0;
            cal_count <= 7;
            trim_val <= 0;
            calibrate <= 0;
            res_valid <= 0;
		end else begin
			case (state)
				// Initial state of fsm.
				sInit : begin
					trim_val <= 5'b10000; 
					state <= sWait;
				end

				// Waiting for trigger at en input.
				sWait : begin
					if(en) begin
						result <= 0;
						cal_itt <= 0;
						cal_count <= 7;
						state <= sSample;
						calibrate <= cal; // 1 -> sCal after sSample, otherwise sConv
						mask <= 8'b10000000; // mask for ctl buses
						en_co_clk <= 1; // enabling clkn
						res_valid <= 0;
					end
					else state <= sWait;
				end

				// Sampling signal from input. clk should be 100kHz
				sSample : begin
					if (calibrate) begin
						state <= sCal; 
						trim_val <= 5'b00000; // resetting
						trim_mask <= 5'b10000; // resetting
					end else begin
						state <= sConv;
					end
				end

				// Conversion stage. 
				// Result bus changes depending on comp input
				sConv : begin
					if (comp) result <= result | mask;
					mask <= mask >> 1;
					if (mask[0]) begin
						state <= sDone;
						en_co_clk <= 0;
					end
				end

				// Calibrate comparator adding a voltage offset
				// depending on trm value
				sCal : begin
					if(cal_itt == 7) begin // after 7 iterations
						if (cal_count > 7) begin // if comp out is too low, add offset
							trim_val <= trim_val | trim_mask;
						end
						trim_mask <= trim_mask >> 1;
						if (trim_mask[0]) begin // finish calibrating
							state <= sDone; 
							en_co_clk <= 0;
							calibrate <= 0;
						end else begin
							cal_itt <= 0;
							state <= sCal;
						end
						cal_count <= 7;
					end else begin
						if (comp) begin
							cal_count <= cal_count - 1; // no offset needed
						end else begin
							cal_count <= cal_count + 1; // offset might be needed
						end
						cal_itt <= cal_itt + 1; // adding iterations
					end
				end

				// Finished either calibrating or converting
				// result can be read
				sDone : begin
					state <= sWait;
					res_valid <= 1;
				end
			endcase
		end
	end

	assign trim = (trim_val | trim_mask); // adding an extra 1 in n-1 after each itt.
	assign trimb = ~(trim_val | trim_mask); // complement of trim
	assign sample = (state==sSample) || (state==sCal); // sample trigger (remain on during cal)
	assign valid = (1 && res_valid); // result is valid and ready to be read
	assign ctlp = result | mask; // ctl signals for non inverter dac. extra 1 in n-1
	assign ctln = ~(result | mask); // ctl signals for inverter dac
endmodule
