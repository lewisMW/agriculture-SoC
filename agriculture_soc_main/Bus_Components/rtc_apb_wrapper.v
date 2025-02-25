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
// Internal wires
// --------------------------------------------------------------------------

wire CLK1HZ;
wire nRTCRST;
wire nPOR;

assign nRTCRST = PRESETn;
assign nPOR = PRESETn;

// --------------------------------------------------------------------------
// Interrupts
// --------------------------------------------------------------------------

wire RTCINTR;

// --------------------------------------------------------------------------
// Internal Signals for FSM and Data
// --------------------------------------------------------------------------
reg [2:0] read_state;     // FSM for read process
reg [2:0] write_state;    // FSM for write process

assign PADDR = 0;

localparam READ_IDLE      = 3'b000;
localparam READ_SETUP     = 3'b001;
localparam READ_ACCESS    = 3'b010;
localparam WRITE_IDLE     = 3'b000;
localparam WRITE_SETUP    = 3'b001;
localparam WRITE_ACCESS   = 3'b010;
localparam WRITE_FINISH   = 3'b011;

// --------------------------------------------------------------------------
// Read Access State Machine
// --------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn) begin
    if (~PRESETn) begin
        read_state <= READ_IDLE;
        PREADY <= 1'b0;
    end else begin
        case (read_state)
            READ_IDLE: begin
                if (PSEL && ~PWRITE) begin
                    read_state <= READ_SETUP;
                    PREADY <= 1'b0;
                end
            end
            READ_SETUP: begin
                if (PENABLE) begin
                read_state <= READ_ACCESS;
                end
            end
            READ_ACCESS: begin
                read_state <= READ_IDLE;
                PREADY <= 1'b1;
            end
        endcase
    end
end

// --------------------------------------------------------------------------
// Write Access State Machine
// --------------------------------------------------------------------------
always @(posedge PCLK or negedge PRESETn) begin
    if (~PRESETn) begin
        write_state <= WRITE_IDLE;
        PREADY <= 1'b0;
    end else begin
        case (write_state)
            WRITE_IDLE: begin
                if (PSEL && PWRITE && ~PENABLE) begin
                    write_state <= WRITE_SETUP;
                    PREADY <= 1'b0;
                end
            end
            WRITE_SETUP: begin
                if (PENABLE) begin
                    write_state <= WRITE_ACCESS;
                end
            end
            WRITE_ACCESS: begin
                // Output the time value to PWDATA
                write_state <= WRITE_FINISH;
                PREADY <= 1'b1;
            end
            WRITE_FINISH: begin
                // Finish the write process and reset
                write_state <= WRITE_IDLE;
                PREADY <= 1'b0;
            end
        endcase
    end
end

// --------------------------------------------------------------------------
// IP Instantiation
// --------------------------------------------------------------------------

Rtc rtc(
    // Inputs
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .CLK1HZ(CLK1HZ),
    .nRTCRST(nRTCRST),
    .nPOR(nPOR),
    
    // Outputs
    .PRDATA(PRDATA),
    .RTCINTR(RTCINTR),
    
    // Testing
    .SCANENABLE(),
    .SCANINPCLK(),
    .SCANINCLK1HZ(),
    .SCANOUTPCLK(),
    .SCANOUTCLK1HZ()
);

endmodule