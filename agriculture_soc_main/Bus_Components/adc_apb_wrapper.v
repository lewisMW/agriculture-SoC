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
reg [DATA_WIDTH - 1 : 0] PLL_CONTROL;
reg [DATA_WIDTH - 1 : 0] SAMPLING_TRIGGER;
reg [2 : 0] AMUX;
wire ADC_TRIGGER_OUT;

// --------------------------------------------------------------------------
// Status Register bits
// --------------------------------------------------------------------------

// ADC read addresses?
// Need to update this to have appropriate values.
	localparam STATUS_REG_ADDR      = ( 10'b0000_0000_00 );
	localparam PLL_CONTROL          = ( STATUS_REG_ADDR + 1 ); // 0x004
	localparam SAMPLING_TRIGGER     = (PLL_CONTROL + 1 );      // 0x008
	localparam AMUX                 = (SAMPLING_TRIGGER  + 1 );	  // 0X00C
	localparam ADC_TRIGGER 		    = ( SAMPLING_TRIGGER+ 1);       // 0x010 


// ADC write addresses
localparam ADC_VREF 		    = 0x000; // TODO: set
localparam ADC_W_EN 		    = 0x001; // TODO: set

// --------------------------------------------------------------------------
// Internal wires
// --------------------------------------------------------------------------
reg  [DATA_WIDTH - 1 : 0] read_mux;     // stores read data

// TODO this depends on the ADC spec
wire [DATA_WIDTH - 1 : 0] status_reg;
wire [DATA_WIDTH - 1 : 0] pll_wire;
wire [DATA_WIDTH - 1 : 0] sample_trig;
wire [DATA_WIDTH - 1 : 0] amux_wire;
wire [DATA_WIDTH - 1 : 0] adc_trigger_wire;

wire [DATA_WIDTH - 1 : 0] vref;
wire [DATA_WIDTH - 1 : 0] enable;

wire read_enable;
wire write_enable;



// --------------------------------------------------------------------------
// Read Mux
// --------------------------------------------------------------------------
assign read_enable = PSEL & ~PWRITE;
//DUMMY reading
always @(posedge PCLK) begin
    if (read_enable) begin
        case( PADDR )   // TODO: Add cases based on ADC specs
                        // TODO: shouldn't these be read parameters rather than write?
            STATUS_REG_ADDR  : read_mux = status_reg;       // 0x000
            PLL_CONTROL      : read_mux = pll_wire;         // 0x004
            SAMPLING_TRIGGER : read_mux = sample_trig;      // 0x008
            AMUX			 : read_mux = amux_wire;        // 0x00c
            ADC_TRIGGER      : read_mux = adc_trigger_wire; // 0x010
            default          : read_mux = {DATA_WIDTH{1'b0}};
        endcase
        else
			read_mux = {DATA_WIDTH{1'b0}};
    end
end
assign PRDATA = read_mux;


//--------------------------------------------------------------------------
// Write Mux
// --------------------------------------------------------------------------
assign write_enable = PSEL & PWRITE & PENABLE;

always @* begin
    write_vref = 1'b0;
    write_enable = 1'b0;

    if ( write_enable )
        case ( PADDR[ADDR_WIDTH - 1 : 2] )
            ADC_VREF : write_vref = 1'b1;
            ADC_W_EN : write_enable = 1'b1;

            default : begin
                write_vref = 1'b0;
                write_enable = 1'b0;
            end
        endcase
end
assign PRDATA = read_mux;


// --------------------------------------------------------------------------
// Write Operands
// --------------------------------------------------------------------------


always @ ( posedge PCLK, negedge PRESETn )
    if ( ~PRESETn )
        vref <= {DATA_WIDTH{1'b0}};
    else
        if ( write_data_b )
            vref <= PWDATA;

always @ ( posedge PCLK, negedge PRESETn )
    if ( ~PRESETn )
        enable <= {DATA_WIDTH{1'b0}};
    else
        if ( write_data_b )
            enable <= PWDATA;


// --------------------------------------------------------------------------
// INSERT ADC module here.
// --------------------------------------------------------------------------

endmodule