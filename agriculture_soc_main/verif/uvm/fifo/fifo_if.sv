// -----------------------------------------------------------------------------
// fifo_if.sv — pin interface between the UVM FIFO environment and fifo_apb_adc.
// The driver changes inputs on the falling edge; the monitor samples on the
// rising edge, so there is never a race with the DUT's posedge logic.
// -----------------------------------------------------------------------------
interface fifo_if #(parameter DATA_WIDTH = 8) (input logic clk);
    logic                  rst_n;
    logic                  adc_wr_en;
    logic [DATA_WIDTH-1:0] adc_data;
    logic                  apb_rd_en;
    logic                  fifo_clear;
    logic                  fifo_full;
    logic                  fifo_empty;
    logic [DATA_WIDTH-1:0] apb_rd_data;
endinterface
