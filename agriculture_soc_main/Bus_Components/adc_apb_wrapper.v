// Module inspired by fpu_apb_wrapper.v

module adc_apb_wrapper #(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 32
)
// TODO: Instantiate - cmsdk_apb_slave_mux 

// APB wires
(
// Clock and reset signals
// Clock signal which synchronises bus operations
input wire PCLK, 
// Active-low reest signal, used to initialise bus preripherals.
input wire PRESETn,

//Address and control signals
// Periphal select. There is one of these wires for every peripheral on the bus.
input wire PSEL,
// Address bys that specifies peripheral memory location
input wire [ADDR_WIDTH -1 : 0] PADDR,
// Indicates start of accessing phase. 
input wire PENABLE,
//indicates direction of data transfer. High is a write, low is read.
input wire PWRITE,

// Data Signals
// Write data bus. Carries data from master to peripheral during write transaction.
input wire [DATA_WIDTH-1 : 0]  PWDATA,

// Read data bus. Peripheral places data on bus during read transaction.
output wire [DATA_WIDTH-1 : 0 ] PRDATA,

// Handshake signals
// Slave indicates ready to complete data transfer.
output reg PREADY,
// Signal that indicates if an error occured during transaction. Can flag misaligned or invalid transfers.
output wire PSLVERR
);

// --------------------------------------------------------------------------
// ADC wires - Connect from read and write to the actual adc.
// --------------------------------------------------------------------------
// THE fpu_apb_wrapper gives an example of using this to write to the correct item.
// This should be implemented.
// Consider what actual inputs and outputs are needed.
reg [DATA_WIDTH - 1 : 0] pll_reg;
reg [DATA_WIDTH - 1 : 0] amux_reg;
reg [DATA_WIDTH - 1 : 0] trig_reg;

wire [DATA_WIDTH - 1 : 0] status_wire;
wire [DATA_WIDTH - 1 : 0] measurement_wire;

// --------------------------------------------------------------------------
// APB addresses for various ADC functionality
// --------------------------------------------------------------------------
//TODO: change these addresses 

// ADC Reads
localparam STATUS_REG_ADDR          = 0x000;
localparam MEASUREMENT_ADDR         = 0x001;

// ADC Writes
localparam PLL_CONTROL_ADDR         = 0x000;
localparam AMUX_ADDR                = 0x001;
localparam ADC_TRIGGER_ADDR         = 0x002;

// --------------------------------------------------------------------------
// Internal wires
// --------------------------------------------------------------------------
reg  [DATA_WIDTH - 1 : 0] read_mux;     // stores read data

wire read_enable;
wire write_enable;


// --------------------------------------------------------------------------
// Read
// --------------------------------------------------------------------------
assign read_enable = PSEL & ~PWRITE;

always @(posedge PCLK) begin
    if (read_enable) begin
        case( PADDR )
            STATUS_REG_ADDR  : read_mux = status_wire;
            MEASUREMENT_ADDR : read_mux = measurement_wire;
            default          : read_mux = {DATA_WIDTH{1'b0}};
        endcase
    end else begin
        read_mux = {DATA_WIDTH{1'b0}};
    end
end
assign PRDATA = read_mux;


//--------------------------------------------------------------------------
// Write
// --------------------------------------------------------------------------
assign write_enable = PSEL & PWRITE & PENABLE;

always @* begin
    write_enable = 1'b0;

    if ( write_enable )
        case ( PADDR[ADDR_WIDTH - 1 : 2] )
            PLL_CONTROL_ADDR : write_pll = 1'b1;
            AMUX_ADDR : write_amux = 1'b1;
            ADC_TRIGGER_ADDR : write_trig = 1'b1;
            default : begin
                write_pll = 1'b0;
                write_amux = 1'b0;
                write_trig = 1'b0;
            end
        endcase
    else begin
        write_pll = 1'b0;
        write_amux = 1'b0;
        write_trig = 1'b0;
    end
end


// --------------------------------------------------------------------------
// Write Operands
// --------------------------------------------------------------------------

always @ ( posedge PCLK, negedge PRESETn )
    if ( ~PRESETn )
        pll_reg <= {DATA_WIDTH{1'b0}};
    else
        if ( write_pll )
            pll_reg <= PWDATA;

always @ ( posedge PCLK, negedge PRESETn )
    if ( ~PRESETn )
        amux_reg <= {DATA_WIDTH{1'b0}};
    else
        if ( write_amux )
            amux_reg <= PWDATA;

always @ ( posedge PCLK, negedge PRESETn )
    if ( ~PRESETn )
        trig_reg <= {DATA_WIDTH{1'b0}};
    else
        if ( write_trig )
            trig_reg <= PWDATA;


// --------------------------------------------------------------------------
// INSERT ADC module here.
// --------------------------------------------------------------------------

dummy_adc(
    .STATUS_REG_ADDR(status_wire),
    .MEASUREMENT(measurement_wire),
    .PLL_CONTROL(pll_reg),
    .AMUX(amux_reg),
    .ADC_TRIGGER(trig_reg)
);

endmodule