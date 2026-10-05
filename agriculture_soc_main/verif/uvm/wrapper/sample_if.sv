// -----------------------------------------------------------------------------
// sample_if.sv — snoop of the FSM->FIFO push path, for the end-to-end
// scoreboard in sensing_uvm_pkg. Compiled before the package (it is referenced
// as a virtual interface there).
// -----------------------------------------------------------------------------
interface sample_if (input logic clk);
    logic       rst_n;
    logic       push;     // FSM fifo_write_en
    logic [7:0] data;     // sample being pushed
    logic       full;     // FIFO full at the push (-> dropped)
    logic       clear;    // fifo_clear pulse
endinterface
