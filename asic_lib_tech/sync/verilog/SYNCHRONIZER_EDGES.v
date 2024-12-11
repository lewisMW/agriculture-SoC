// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright © 2022, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module SYNCHRONIZER_EDGES (
	input wire        testmode_i
	,input wire       clk_i
        ,input wire       reset_n_i
	,input wire       asyn_i
	,output wire      syn_o
	,output wire      syn_del_o
	,output wire      posedge_o
	,output wire      negedge_o
	);

reg sync_stage1;
reg sync_stage2;
reg sync_stage3;

  always @(posedge clk_i or negedge reset_n_i)
    if(~reset_n_i) begin
        sync_stage1 <= 1'b0;
        sync_stage2 <= 1'b0;
        sync_stage3 <= 1'b0;
      end
    else begin
        sync_stage1 <= asyn_i;
        sync_stage2 <= sync_stage1;
        sync_stage3 <= sync_stage2;
      end

assign syn_o     = (testmode_i) ? asyn_i : sync_stage2;
assign syn_del_o = (testmode_i) ? asyn_i : sync_stage3;
assign posedge_o = (testmode_i) ? asyn_i : ( sync_stage2 & !sync_stage3);
assign negedge_o = (testmode_i) ? asyn_i : (!sync_stage2 &  sync_stage3);

endmodule
