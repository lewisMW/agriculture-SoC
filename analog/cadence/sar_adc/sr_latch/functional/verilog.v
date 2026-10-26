//Verilog HDL for "adc_digital_lib", "sr_latch" "functional"


module sr_latch ( s, r, q, qn);
	input s, r;
	output q, qn;
	
	reg q, qn;	

	always @(*) begin
		case ({s,r})
			2'b00 : begin q <= q; qn <= qn; end
			2'b01 : begin q <= 0; qn <= 1; end
			2'b10 : begin q <= 1; qn <= 0; end
			2'b11 : begin q <= 1'bx; qn <= 1'bx; end
		endcase
	end	
endmodule
