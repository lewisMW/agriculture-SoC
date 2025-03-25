// module rtc_control(
//     input wire PCLK,
//     input wire PRESETn,


//     input wire [DATA_WIDTH-1 : 0]  PWDATA,
//     input wire CLK1HZ,
//     input wire nRTCRST,
//     input wire nPOR,

//     output wire [DATA_WIDTH-1 : 0 ] PRDATA,
//     output reg PREADY,
//     output wire RTCINTR,
//     output wire rtc_trig
// );

// wire [ADDR_WIDTH -1 : 0] PADDR;
// wire PWRITE;
// wire PSEL;
// wire PENABLE;

// // assign nRTCRST = PRESETn;
// // assign nPOR = PRESETn;

// Rtc rtc(
//     // Inputs
//     .PCLK(PCLK),
//     .PRESETn(PRESETn),
//     .PSEL(PSEL),
//     .PENABLE(PENABLE),
//     .PWRITE(PWRITE),
//     .PADDR(PADDR),
//     .PWDATA(PWDATA),
//     .CLK1HZ(CLK1HZ),
//     .nRTCRST(nRTCRST),
//     .nPOR(nPOR),
    
//     // Outputs
//     .PRDATA(PRDATA),
//     .RTCINTR(RTCINTR),
    
//     // Testing
//     .SCANENABLE(),
//     .SCANINPCLK(),
//     .SCANINCLK1HZ(),
//     .SCANOUTPCLK(),
//     .SCANOUTCLK1HZ()
// );

// assign rtc_trig = RTCINTR;

// // TODO: create FSM using array indexing to reflect the FSM diagram on draw.io

// always @(posedge PCLK or negedge PRESETn) begin
//     if (!PRESETn)
//         PREADY <= 0;
//     else if (PSEL && PENABLE)
//         PREADY <= 1;
//     else
//         PREADY <= 0;
// end

// endmodule
module rtc_control 
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 12
)
(
    // APB接口信号
    input  wire                  PCLK,      // APB 时钟
    input  wire                  PRESETn,   // APB 异步复位，低有效
    input  wire                  PSEL,      
    input  wire                  PENABLE,
    input  wire                  PWRITE,
    input  wire [ADDR_WIDTH-1:0] PADDR,
    input  wire [DATA_WIDTH-1:0] PWDATA,
    output reg  [DATA_WIDTH-1:0] PRDATA,
    output reg                   PREADY,
    output wire                  PSLVERR,   // 此处固定为0，不报错

    // RTC时钟与复位
    input  wire                  CLK1HZ,    // 1Hz 时钟输入
    input  wire                  nRTCRST,   // RTC 域复位(低有效)
    input  wire                  nPOR,      // 上电复位(低有效)，可根据需求使用

    // 中断输出
    output wire                  RTCINTR,

    // 示例：输出一个触发信号(可根据需要使用)
    output wire                  rtc_trig
);

assign PSLVERR = 1'b0;  // 不使用 SLVERR，固定为0

// ====================================================================
// 1) APB 读写 FSM
// ====================================================================
localparam [2:0] ST_IDLE  = 3'b000,
                 ST_SETUP = 3'b001,
                 ST_WRITE = 3'b010,
                 ST_READ  = 3'b011,
                 ST_RESP  = 3'b100;

reg [2:0]  state, next_state;

// 状态寄存
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        state <= ST_IDLE;
    else
        state <= next_state;
end

// 状态转移
always @* begin
    next_state = state;
    case(state)
        ST_IDLE: begin
            // 等待PSEL=1 & PENABLE=0，表示一次新的APB传输开始
            if (PSEL && !PENABLE)
                next_state = ST_SETUP;
        end
        ST_SETUP: begin
            // 当PSEL=1 & PENABLE=1时，区分读或写
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

// PREADY 在一次传输完成后拉高1个周期
always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn)
        PREADY <= 1'b0;
    else if (state == ST_WRITE || state == ST_READ)
        PREADY <= 1'b1;
    else
        PREADY <= 1'b0;
end


