// -----------------------------------------------------------------------------
// apb_if.sv — APB3 pin interface (master side driven by apb_driver).
// -----------------------------------------------------------------------------
interface apb_if #(parameter ADDR_WIDTH = 12) (input logic PCLK);
    logic                  PRESETn;
    logic                  PSEL;
    logic                  PENABLE;
    logic                  PWRITE;
    logic [ADDR_WIDTH-1:0] PADDR;
    logic [31:0]           PWDATA;
    logic [31:0]           PRDATA;
    logic                  PREADY;
    logic                  PSLVERR;
endinterface
