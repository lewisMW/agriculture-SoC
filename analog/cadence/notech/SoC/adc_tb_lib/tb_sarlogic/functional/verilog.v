//Verilog HDL for "adc_tb_lib", "tb_sarlogic" "functional"

`timescale 1ns/1ps

module tb_sarlogic;

// -------------------------------------------------------
// Parameters
// -------------------------------------------------------
parameter real SAMPLE_F = 800.0e3; // 800kHz

// -------------------------------------------------------
// DUT ports
// -------------------------------------------------------
reg        clk;
reg        rstn;
reg        en;
reg        comp;
reg        cal;

wire        valid;
wire [7:0]  result;
wire        sample;
wire [7:0]  ctlp;
wire [7:0]  ctln;
wire [4:0]  trima;
wire [4:0]  trimb;
wire        clkc;

// -------------------------------------------------------
// DUT instantiation
// -------------------------------------------------------
sarlogic DUT (
    .clk   (clk),
    .rstn  (rstn),
    .en    (en),
    .comp  (comp),
    .cal   (cal),
    .valid (valid),
    .result(result),
    .sample(sample),
    .ctlp  (ctlp),
    .ctln  (ctln),
    .trima (trima),
    .trimb (trimb),
    .clkc  (clkc)
);

// -------------------------------------------------------
// Clock
// -------------------------------------------------------
initial clk = 0;
always #(0.5e9/SAMPLE_F) clk = ~clk;

// -------------------------------------------------------
// Waveform dump (SHM for ViVA)
// -------------------------------------------------------
initial begin
    $shm_open("waves.shm");
    $shm_probe(tb_sarlogic, "AS"); // all signals, all levels
end

// -------------------------------------------------------
// Main stimulus
// -------------------------------------------------------
integer bit_idx;

initial begin
    // --- initialise inputs ---
    rstn = 0;
    en   = 0;
    comp = 0;
    cal  = 0;

    // =====================================================
    // Phase 0: Reset
    // =====================================================
    $display("[t=%0t] Asserting reset", $time);
    repeat(4) @(posedge clk);
    rstn = 1;
    @(posedge clk);
	rstn = 0;
	@(posedge clk);
	rstn = 1;
    $display("[t=%0t] Reset released ? FSM should be in sWait", $time);

    // let it settle one cycle
    @(posedge clk);

    // =====================================================
    // Phase 1: Single conversion
    //   comp pattern: 8'b10110001 => expected result 0xB1
    //   bit order: MSB first (mask starts at 8'b10000000)
    // =====================================================
    $display("[t=%0t] Asserting en ? starting conversion", $time);
 	en = 1;   
	//@(posedge clk); #1;
    //en = 0;

    // FSM moves sWait->sSample on that posedge.
    // Wait for sample to confirm we are in sSample.
    @(posedge sample);
    $display("[t=%0t] sample asserted ? FSM in sSample", $time);

    // sSample lasts one cycle, then sConv begins.
    // Drive comp bit-by-bit: FSM captures comp at each posedge in sConv.
    // comp_vec = 8'b10110001, drive MSB first.
    @(posedge clk); #1; comp = 1; // bit 7  mask=10000000
	en = 0;
    @(posedge clk); #1; comp = 0; // bit 6  mask=01000000
    @(posedge clk); #1; comp = 1; // bit 5  mask=00100000
    @(posedge clk); #1; comp = 1; // bit 4  mask=00010000
    @(posedge clk); #1; comp = 0; // bit 3  mask=00001000
    @(posedge clk); #1; comp = 0; // bit 2  mask=00000100
    @(posedge clk); #1; comp = 0; // bit 1  mask=00000010
    @(posedge clk); #1; comp = 1; // bit 0  mask=00000001

    // Wait for sDone to assert valid
    @(posedge valid);
	comp = 0;
    $display("[t=%0t] valid asserted ? result=0x%02X (expected 0xB1)", $time, result);

    if (result === 8'hB1)
        $display("  PASS");
    else
        $display("  FAIL ? got 0x%02X", result);

    // Let FSM return to sWait
    @(posedge clk);
    $display("[t=%0t] Done. valid=%b sample=%b", $time, valid, sample);

    repeat(4) @(posedge clk);

	
	// =====================================================
    // Phase 2: Calibration
    //  taget trima = 5'b10100
	//	bit 4: comp=0000111 (4 zeros -> set)
	//	bit 3: comp=1111000 (4 ones -> clear)
	//	bit 2: comp=0000111 (4 zeros -> set)
	//	bit 1: comp=1111000 (4 ones -> clear)
	//	bit 0: comp=1010101 (4 ones -> clear)
    // =====================================================
	$display("[t=%0t] Starting calibration", $time);

	// trigger with cal=1
	en = 1;
	cal = 1;
	@(posedge sample);
	$display("[t=%0t] sample asserted - FSM in sSample, entering sCal", $time);
	
	// bit 4 => set (4 zeros, 3 ones)
	@(posedge clk); #1; comp = 0;
	en = 0;
	cal = 0;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1;

	// bit 3 => clear (4 ones, 3 zeros)
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1;

	// bit 2 => set (4 zeros, 3 ones)
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1;

	// bit 1 => clear (4 ones, 3 zeros)
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1;

	// bit 0 => clear (4 ones, 3 zeros)
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 1;
	@(posedge clk); #1; comp = 0;
	@(posedge clk); #1; comp = 1;

	// wait for FSM to finish calibration
	@(posedge valid);
	$display("[t=%0t] calibration done - trima=%05b trimb=%05b (expected trima=10100)",
			$time, trima, trimb);

	if (trima == 5'b10100)
		$display(" PASS");
	else
		$display(" FAIL - got trima=%05b", trima);

	repeat(4) @(posedge clk);

    $shm_close;
    $finish;
end

endmodule
