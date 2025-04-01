`timescale 1ns/1ps

module rtc_control 
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 12
)
(
    // APB Interface Signals
    input  wire                  PCLK,      
    input  wire                  PRESETn,   
    input  wire                  PSEL,      
    input  wire                  PENABLE,
    input  wire                  PWRITE,
    input  wire [ADDR_WIDTH-1:0] PADDR,
    input  wire [DATA_WIDTH-1:0] PWDATA,
    output reg  [DATA_WIDTH-1:0] PRDATA,
    output reg                   PREADY,
    output wire                  PSLVERR,

    // RTC Domain Signals
    input  wire                  CLK1HZ,    // 1Hz clock (shortened period for simulation)
    input  wire                  nRTCRST,   // RTC reset (active-low)
    input  wire                  nPOR,      // Power-on reset (active-low)

    // Interrupt Outputs
    output wire                  RTCINTR,
    output wire                  rtc_trig,

    // Control Unit Interface Signals
    input  wire                  ctrl_read_time_en,   // Enable reading current time
    output reg  [DATA_WIDTH-1:0] ctrl_time_value,     // Output current counter value
    input  wire                  ctrl_set_match_en,   // Enable writing match value (from Control Unit)
    input  wire [DATA_WIDTH-1:0] ctrl_match_value,    // Match value calculated by Control Unit
    input  wire                  ctrl_clear_intr,     // Request to clear interrupt
    output wire                  ctrl_intr_flag,      // Interrupt flag (output)
    
    // Test Mask: force the counter to increment (for test only)
    input  wire                  test_mask_enable
);

assign PSLVERR = 1'b0;

// -------------------------------------------------------
// 1. APB FSM Implementation
// -------------------------------------------------------
localparam [2:0] ST_IDLE  = 3'b000,
                 ST_SETUP = 3'b001,
                 ST_WRITE = 3'b010,
                 ST_READ  = 3'b011,
                 ST_RESP  = 3'b100;

reg [2:0] state, next_state;

always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        state <= ST_IDLE;
    else
        state <= next_state;
end

always @* begin
    next_state = state;
    case (state)
        ST_IDLE: begin
            if (PSEL && !PENABLE)
                next_state = ST_SETUP;
        end
        ST_SETUP: begin
            if (PSEL && PENABLE) begin
                if (PWRITE)
                    next_state = ST_WRITE;
                else
                    next_state = ST_READ;
            end
        end
        ST_WRITE: next_state = ST_RESP;
        ST_READ:  next_state = ST_RESP;
        ST_RESP:  next_state = ST_IDLE;
        default:  next_state = ST_IDLE;
    endcase
end

// PREADY goes high for 1 cycle when write or read is done
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        PREADY <= 1'b0;
    else if (state == ST_WRITE || state == ST_READ)
        PREADY <= 1'b1;
    else
        PREADY <= 1'b0;
end

// -------------------------------------------------------
// 2. Register Mapping (APB offsets start at 0x200)
// -------------------------------------------------------
localparam [ADDR_WIDTH-1:0] ADDR_RTCDR   = 12'h200, // Read current counter
                            ADDR_RTCMR   = 12'h204, // Match register
                            ADDR_RTCLR   = 12'h208, // Load counter
                            ADDR_RTCCR   = 12'h20C, // Control register (bit[0] enable)
                            ADDR_RTCIMSC = 12'h210, // Interrupt mask
                            ADDR_RTCRIS  = 12'h214, // Raw interrupt status
                            ADDR_RTCMIS  = 12'h218, // Masked interrupt status
                            ADDR_RTCICR  = 12'h21C; // Interrupt clear

reg [DATA_WIDTH-1:0] RTCLR_reg;
reg                  RTCCR_enable;
reg                  RTCIMSC_reg;
reg                  apb_clear_req;

// RTCMR_reg is updated exclusively by the Control Unit
reg [DATA_WIDTH-1:0] RTCMR_reg;

// APB write operation: updates registers when state == ST_WRITE
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        RTCLR_reg     <= 32'd0;
        RTCCR_enable  <= 1'b0;
        RTCIMSC_reg   <= 1'b0;
        apb_clear_req <= 1'b0;
    end 
    else if (state == ST_WRITE) begin
        case (PADDR)
            ADDR_RTCLR:   RTCLR_reg     <= PWDATA;
            // RTCMR is updated by the Control Unit, not here
            ADDR_RTCCR:   RTCCR_enable  <= PWDATA[0];
            ADDR_RTCIMSC: RTCIMSC_reg   <= PWDATA[0];
            ADDR_RTCICR:  if (PWDATA[0]) apb_clear_req <= 1'b1;
            default: ;
        endcase
    end 
    else begin
        apb_clear_req <= 1'b0;
    end
end

// Control Unit updates RTCMR_reg (match register)
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        RTCMR_reg <= 32'd0;
    else if (ctrl_set_match_en)
        RTCMR_reg <= ctrl_match_value;
end

// -------------------------------------------------------
// 3. APB Read Operation
// -------------------------------------------------------
// During ST_READ or ST_RESP, PRDATA is driven according to address
reg [31:0] counter_sync;
always @* begin
    PRDATA = 32'd0;
    if (state == ST_READ || state == ST_RESP) begin
        case (PADDR)
            ADDR_RTCDR:   PRDATA = counter_sync;
            ADDR_RTCMR:   PRDATA = RTCMR_reg;
            ADDR_RTCLR:   PRDATA = RTCLR_reg;
            ADDR_RTCCR:   PRDATA = {31'd0, RTCCR_enable};
            ADDR_RTCIMSC: PRDATA = {31'd0, RTCIMSC_reg};
            ADDR_RTCRIS:  PRDATA = {31'd0, intr_flag};
            ADDR_RTCMIS:  PRDATA = {31'd0, intr_flag & RTCIMSC_reg};
            ADDR_RTCICR:  PRDATA = 32'd0;
            default:      PRDATA = 32'd0;
        endcase
    end
end

// -------------------------------------------------------
// 4. RTC Counter Logic (in CLK1HZ domain)
// -------------------------------------------------------
// load_req_latched / load_req_1hz handshake ensures the load operation
reg [31:0] rtc_counter_1hz;
reg load_req_latched;
reg load_req_1hz;
reg load_req_ack;  // indicates the load operation is done

// Latch the request to load RTCLR in PCLK domain
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        load_req_latched <= 1'b0;
    else if ((state == ST_WRITE) && (PADDR == ADDR_RTCLR))
        load_req_latched <= 1'b1;
    else if (load_req_ack)
        load_req_latched <= 1'b0;
end

// Synchronize to CLK1HZ domain
always @(posedge CLK1HZ or negedge nRTCRST) begin
    if (!nRTCRST)
        load_req_1hz <= 1'b0;
    else
        load_req_1hz <= load_req_latched;
end

// Update the counter on each rising edge of CLK1HZ
always @(posedge CLK1HZ or negedge nRTCRST) begin
    if (!nRTCRST) begin
        rtc_counter_1hz <= 32'd0;
        load_req_ack    <= 1'b0;
    end 
    else if (RTCCR_enable || test_mask_enable) begin
        if (load_req_1hz) begin
            rtc_counter_1hz <= RTCLR_reg;
            load_req_ack <= 1'b1;
        end else begin
            rtc_counter_1hz <= rtc_counter_1hz + 1;
            load_req_ack <= 1'b0;
        end
    end
end

// -------------------------------------------------------
// 5. Interrupt Generation Logic (in CLK1HZ domain)
// -------------------------------------------------------
reg intr_flag;
wire clear_intr_req = apb_clear_req | ctrl_clear_intr;

// Synchronize the clear request
reg clear_intr_req_sync_ff, clear_intr_req_sync;
always @(posedge CLK1HZ or negedge nRTCRST) begin
    if (!nRTCRST) begin
        clear_intr_req_sync_ff <= 1'b0;
        clear_intr_req_sync    <= 1'b0;
    end else begin
        clear_intr_req_sync_ff <= clear_intr_req;
        clear_intr_req_sync    <= clear_intr_req_sync_ff;
    end
end

always @(posedge CLK1HZ or negedge nRTCRST) begin
    if (!nRTCRST)
        intr_flag <= 1'b0;
    else if (RTCCR_enable || test_mask_enable) begin
        if (clear_intr_req_sync)
            intr_flag <= 1'b0;
        else if (rtc_counter_1hz == RTCMR_reg)
            intr_flag <= 1'b1;
    end
end

wire masked_intr = intr_flag & RTCIMSC_reg;
assign RTCINTR   = masked_intr;
assign rtc_trig  = RTCINTR;
assign ctrl_intr_flag = RTCINTR;

// -------------------------------------------------------
// 6. Synchronize RTC Counter to PCLK Domain
// -------------------------------------------------------
reg [31:0] counter_sync_ff;
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
        counter_sync_ff <= 32'd0;
        counter_sync    <= 32'd0;
    end else begin
        counter_sync_ff <= rtc_counter_1hz;
        counter_sync    <= counter_sync_ff;
    end
end

// -------------------------------------------------------
// 7. Control Unit Read Interface
// -------------------------------------------------------
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        ctrl_time_value <= 32'd0;
    else if (ctrl_read_time_en)
        ctrl_time_value <= counter_sync;
end

endmodule
