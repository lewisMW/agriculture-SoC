`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// adc_apb_wrapper_rev2.v
//
// APB slave for the precision-agriculture sensing peripheral. Ties together:
//   - rtc_control_2  : autonomous PL031-based RTC. Arms a periodic alarm (period
//                    = alarm_offset seconds) and pulses rtc_trig. Also exposes
//                    the PL031 registers to firmware via APB passthrough.
//   - wrapper_control_2 (FSM) : on each trigger runs one ADC conversion and
//                    pushes the sample into the FIFO. Lets the CPU sleep between
//                    polls.
//   - dummy_adc / dummy_amux / dummy_pll : behavioural analog stand-ins.
//   - fifo_apb_adc : buffers samples until firmware drains them.
//
// Register map (byte offsets from the peripheral base) — keep in sync with
// software/.../sensing_ip.h:
//   0x004 status        (RO) [1:0]=FIFO [3:2]=ADC [4]=fifo-drop [5]=rtc-intr
//   0x008 measurement_hi(RO) upper sample bits (0 for an 8-bit ADC)
//   0x00C measurement_lo(RO) sample; reading it pops the FIFO
//   0x100 pll_control   (RW)
//   0x104 amux          (RW) [1:0] input select
//   0x108 adc_trigger   (WO) bit0=1 -> manual one-shot sample
//   0x10C adc_cal       (RW) bit0=1 -> next conversion runs the calibration path
//   0x200-0x21C RTC     (RW) PL031 regs via passthrough (address-translated)
//   0x220 fifo_clear    (WO) any write flushes the FIFO
//   0x224 rtc_alarm_off (RW) polling period in RTC seconds (default below)
//   0x228 rtc_ctrl      (RW) bit0 = autonomous-polling enable (reset = 1)
// -----------------------------------------------------------------------------
module adc_apb_wrapper_rev2 #(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 32,
    parameter SAMPLE_WIDTH = 8,
    parameter [31:0] DEFAULT_ALARM_OFFSET = 32'd5   // seconds between polls
)(
    // Clock and reset
    input  wire                  PCLK,
    input  wire                  CLK1HZ,     // ~1 Hz RTC tick
    input  wire                  PRESETn,    // active-low APB reset
    input  wire                  nPOR,       // power-on reset (survives APB reset) for RTC

    // APB
    input  wire                  PSEL,
    input  wire [ADDR_WIDTH-1:0] PADDR,
    input  wire                  PENABLE,
    input  wire                  PWRITE,
    input  wire [DATA_WIDTH-1:0] PWDATA,
    output reg  [DATA_WIDTH-1:0] PRDATA,
    output wire                  PREADY,
    output wire                  PSLVERR,

    // Unused APB sidebands (kept for interface parity)
    input  wire                  APBACTIVE,
    input  wire [2:0]            PPROT,
    input  wire [3:0]            PSTRB
);

    // --------------------------------------------------------------------------
    // Register addresses
    // --------------------------------------------------------------------------
    localparam STATUS_REG_ADDR   = 12'h004;
    localparam MEASUREMENT_HI    = 12'h008;
    localparam MEASUREMENT_LO    = 12'h00C;
    localparam PLL_CONTROL_ADDR  = 12'h100;
    localparam AMUX_ADDR         = 12'h104;
    localparam ADC_TRIGGER_ADDR  = 12'h108;
    localparam ADC_CAL_ADDR      = 12'h10C;
    localparam FIFO_CLEAR_ADDR   = 12'h220;
    localparam ALARM_OFFSET_ADDR = 12'h224;
    localparam RTC_CTRL_ADDR     = 12'h228;

    // RTC region: 0x200-0x21F. Forwarded to rtc_control_2 with the address
    // translated down to PL031 word space (0x200 -> RTCDR, 0x204 -> RTCMR, ...).
    wire rtc_region = ((PADDR & 12'hFE0) == 12'h200);

    // --------------------------------------------------------------------------
    // APB control strobes
    // --------------------------------------------------------------------------
    wire read_enable  = PSEL & ~PWRITE & PENABLE;
    wire write_enable = PSEL &  PWRITE & PENABLE;

    // --------------------------------------------------------------------------
    // Wrapper registers
    // --------------------------------------------------------------------------
    reg [DATA_WIDTH-1:0] pll_reg;
    reg [DATA_WIDTH-1:0] amux_reg;
    reg                  cal_reg;           // ADC calibration enable (bit0)
    reg [DATA_WIDTH-1:0] alarm_offset_reg;  // polling period (RTC seconds)
    reg                  poll_enable_reg;   // autonomous-polling enable (bit0, reset 1)
    reg [DATA_WIDTH-1:0] status_reg;

    // --------------------------------------------------------------------------
    // FIFO
    // --------------------------------------------------------------------------
    wire                    fifo_full, fifo_empty;
    wire [SAMPLE_WIDTH-1:0]  fifo_data_out;
    reg                     fifo_rd_en;
    reg                     fifo_clear;
    wire                    fifo_write_en;   // from FSM

    // --------------------------------------------------------------------------
    // ADC
    // --------------------------------------------------------------------------
    wire [SAMPLE_WIDTH-1:0]  adc_result;     // raw result from ADC (its clock domain)
    wire                    adc_raw_valid;
    wire                    adc_en;          // from FSM
    wire                    analog_passthrough;

    // --------------------------------------------------------------------------
    // FSM / trigger
    // --------------------------------------------------------------------------
    wire err_fifo_full;
    reg  manual_trig;                        // one-shot from an adc_trigger write
    wire rtc_trig;                           // periodic alarm pulse from RTC
    wire sample_trig = rtc_trig | manual_trig;

    // --------------------------------------------------------------------------
    // RTC
    // --------------------------------------------------------------------------
    wire        ctrl_intr_flag;
    wire [11:0] rtc_paddr   = {4'h0, PADDR[7:0]};   // 0x2xx -> 0x0xx
    wire        rtc_psel    = PSEL & rtc_region;
    wire [31:0] rtc_prdata;
    wire        rtc_pready;
    wire        rtc_pslverr;

    // --------------------------------------------------------------------------
    // ADC valid CDC: the real SAR ADC runs on a slower clock, so synchronise
    // its valid into PCLK and capture the result on the rising edge. (Harmless
    // extra latency when the dummy shares PCLK.)
    // --------------------------------------------------------------------------
    reg  adc_valid_s1, adc_valid_s2, adc_valid_s3;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            adc_valid_s1 <= 1'b0;
            adc_valid_s2 <= 1'b0;
            adc_valid_s3 <= 1'b0;
        end else begin
            adc_valid_s1 <= adc_raw_valid;
            adc_valid_s2 <= adc_valid_s1;
            adc_valid_s3 <= adc_valid_s2;
        end
    end
    wire adc_valid_sync = adc_valid_s2;
    wire adc_valid_rise = adc_valid_s2 & ~adc_valid_s3;

    reg [SAMPLE_WIDTH-1:0] adc_sample;
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)          adc_sample <= {SAMPLE_WIDTH{1'b0}};
        else if (adc_valid_rise) adc_sample <= adc_result;
    end

    // --------------------------------------------------------------------------
    // APB read mux
    // --------------------------------------------------------------------------
    always @(*) begin
        PRDATA = {DATA_WIDTH{1'b0}};
        if (read_enable) begin
            if (rtc_region) begin
                PRDATA = rtc_prdata;
            end else begin
                case (PADDR)
                    STATUS_REG_ADDR:   PRDATA = status_reg;
                    MEASUREMENT_HI:    PRDATA = {DATA_WIDTH{1'b0}};              // 8-bit sample: no high word
                    MEASUREMENT_LO:    PRDATA = {{(DATA_WIDTH-SAMPLE_WIDTH){1'b0}}, fifo_data_out};
                    PLL_CONTROL_ADDR:  PRDATA = pll_reg;
                    AMUX_ADDR:         PRDATA = amux_reg;
                    ADC_CAL_ADDR:      PRDATA = {{(DATA_WIDTH-1){1'b0}}, cal_reg};
                    ALARM_OFFSET_ADDR: PRDATA = alarm_offset_reg;
                    RTC_CTRL_ADDR:     PRDATA = {{(DATA_WIDTH-1){1'b0}}, poll_enable_reg};
                    default:           PRDATA = {DATA_WIDTH{1'b0}};
                endcase
            end
        end
    end

    // Wrapper-local registers never stall. The RTC passthrough now inserts wait
    // states (PREADY low) when an access collides with an autonomous arm cycle,
    // instead of returning PSLVERR — so an unguarded RTC access can no longer
    // fault/hang the CPU. Forward rtc_pready for RTC-region accesses; everything
    // else completes immediately. PSLVERR is tied off in rtc_control_2 (never
    // errors) but kept wired for interface parity.
    assign PREADY  = rtc_region ? rtc_pready : 1'b1;
    assign PSLVERR = rtc_region ? rtc_pslverr : 1'b0;

    // --------------------------------------------------------------------------
    // FIFO read-pop pulse: reading MEASUREMENT_LO advances the FIFO one entry.
    // --------------------------------------------------------------------------
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn)
            fifo_rd_en <= 1'b0;
        else
            fifo_rd_en <= (read_enable && (PADDR == MEASUREMENT_LO) && !fifo_empty);
    end

    // --------------------------------------------------------------------------
    // Status register
    // --------------------------------------------------------------------------
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            status_reg <= {DATA_WIDTH{1'b0}};
        end else begin
            status_reg[1:0]  <= fifo_empty ? 2'b00 : (fifo_full ? 2'b10 : 2'b01);
            status_reg[3:2]  <= adc_en ? 2'b01 : 2'b00;   // ADC running vs idle
            status_reg[4]    <= err_fifo_full;            // last sample dropped (FIFO full)
            status_reg[5]    <= ctrl_intr_flag;           // RTC interrupt pending
            status_reg[DATA_WIDTH-1:6] <= {(DATA_WIDTH-6){1'b0}};
        end
    end

    // --------------------------------------------------------------------------
    // Register writes
    // --------------------------------------------------------------------------
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) pll_reg <= {DATA_WIDTH{1'b0}};
        else if (write_enable && (PADDR == PLL_CONTROL_ADDR)) pll_reg <= PWDATA;
    end

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) amux_reg <= {DATA_WIDTH{1'b0}};
        else if (write_enable && (PADDR == AMUX_ADDR)) amux_reg <= PWDATA;
    end

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) cal_reg <= 1'b0;
        else if (write_enable && (PADDR == ADC_CAL_ADDR)) cal_reg <= PWDATA[0];
    end

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) alarm_offset_reg <= DEFAULT_ALARM_OFFSET;
        else if (write_enable && (PADDR == ALARM_OFFSET_ADDR)) alarm_offset_reg <= PWDATA;
    end

    // Autonomous-polling enable. Resets to 1 (polling on). Firmware clears bit0
    // to pause autonomous sampling (RTC counter keeps running); sets it to resume.
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) poll_enable_reg <= 1'b1;
        else if (write_enable && (PADDR == RTC_CTRL_ADDR)) poll_enable_reg <= PWDATA[0];
    end

    // Manual one-shot trigger (1-cycle pulse) on a write to adc_trigger.
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) manual_trig <= 1'b0;
        else          manual_trig <= (write_enable && (PADDR == ADC_TRIGGER_ADDR) && PWDATA[0]);
    end

    // FIFO clear (1-cycle pulse) on a write to fifo_clear.
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) fifo_clear <= 1'b0;
        else          fifo_clear <= (write_enable && (PADDR == FIFO_CLEAR_ADDR));
    end

    // --------------------------------------------------------------------------
    // Submodule instances
    // --------------------------------------------------------------------------
`ifdef SENSING_DEBUG
    // Trace of the sampling path. Enable with EXTRA_DEFINES=+define+SENSING_DEBUG.
    always @(posedge PCLK) if (PRESETn) begin
        if (write_enable)
            $display("[SENS %0t] APB WR  addr=0x%03h data=0x%08h", $time, PADDR, PWDATA);
        if (read_enable && (PADDR == STATUS_REG_ADDR))
            $display("[SENS %0t] APB RD  status=0x%08h (fifo=%0d adc=%0d) cnt=%0d",
                     $time, status_reg, status_reg[1:0], status_reg[3:2], u_fifo.count);
        if (rtc_trig)
            $display("[SENS %0t] rtc_trig      poll_en=%b cnt=%0d", $time, poll_enable_reg, u_fifo.count);
        if (manual_trig)
            $display("[SENS %0t] manual_trig   cnt=%0d", $time, u_fifo.count);
        if (fifo_clear)
            $display("[SENS %0t] fifo_clear    (cnt was %0d)", $time, u_fifo.count);
        if (fifo_write_en)
            $display("[SENS %0t] fifo_push     data=0x%02h cnt=%0d full=%b", $time, adc_sample, u_fifo.count, fifo_full);
    end
`endif

    fifo_apb_adc #(
        .DATA_WIDTH(SAMPLE_WIDTH),
        .DEPTH(16)
    ) u_fifo (
        .clk         (PCLK),
        .rst_n       (PRESETn),
        .adc_wr_en   (fifo_write_en),
        .adc_data    (adc_sample),
        .fifo_full   (fifo_full),
        .apb_rd_en   (fifo_rd_en),
        .apb_rd_data (fifo_data_out),
        .fifo_empty  (fifo_empty),
        .fifo_clear  (fifo_clear)
    );

    // NOTE: the real SAR ADC needs its own ~100 kHz clock (from the PLL / a
    // divider). Here the dummy shares PCLK; the adc_valid synchroniser above
    // makes swapping in the slow-clock block safe.
    //
    // With SAR_AMS defined (AMS flow, xrun -ams) the behavioural Verilog-AMS
    // SAR is instantiated instead of the dummy; sar_ams_shim owns the analog
    // supplies, the differential input and the ADC clock divider.
`ifdef SAR_AMS
    sar_ams_shim #(
        .RESULT_WIDTH(SAMPLE_WIDTH),
        .CLK_DIV(4)
    ) u_adc (
        .clk       (PCLK),
        .rstn      (PRESETn),
        .en        (adc_en),
        .cal       (cal_reg),
        .ANALOG_IN (analog_passthrough),
        .valid     (adc_raw_valid),
        .result    (adc_result)
    );
`else
    dummy_adc #(
        .RESULT_WIDTH(SAMPLE_WIDTH),
        .CONV_CYCLES(8),
        .RAND_SEED(8'h5A)
    ) u_adc (
        .clk       (PCLK),
        .rstn      (PRESETn),
        .en        (adc_en),
        .cal       (cal_reg),
        .ANALOG_IN (analog_passthrough),
        .valid     (adc_raw_valid),
        .result    (adc_result)
    );
`endif

    dummy_amux u_amux (
        .INPUT_SEL          (amux_reg[1:0]),
        .ANALOG_PASSTHROUGH (analog_passthrough),
        .clk                (PCLK),
        .reset              (~PRESETn)
    );

    dummy_pll u_pll (
        .PLL_CONTROL (pll_reg),
        .clk         (PCLK),
        .reset       (PRESETn)
    );

    wrapper_control_2 u_ctrl (
        .clk           (PCLK),
        .rstn          (PRESETn),
        .sample_trig   (sample_trig),
        .fifo_full     (fifo_full),
        .fifo_write_en (fifo_write_en),
        .adc_en        (adc_en),
        .adc_valid     (adc_valid_sync),
        .err_fifo_full (err_fifo_full)
    );

    rtc_control_2 #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(12)
    ) u_rtc (
        .PCLK            (PCLK),
        .PRESETn         (PRESETn),
        .CLK1HZ          (CLK1HZ),
        .nPOR            (nPOR),
        .alarm_offset    (alarm_offset_reg),
        .poll_enable     (poll_enable_reg),
        .ctrl_time_value (),                 // firmware reads live time via passthrough (RTCDR)
        .ctrl_intr_flag  (ctrl_intr_flag),
        .rtc_trig        (rtc_trig),
        // APB passthrough (address-translated RTC region)
        .PSEL            (rtc_psel),
        .PENABLE         (PENABLE),
        .PWRITE          (PWRITE),
        .PADDR           (rtc_paddr),
        .PWDATA          (PWDATA),
        .PRDATA          (rtc_prdata),
        .PREADY          (rtc_pready),
        .PSLVERR         (rtc_pslverr)
    );

endmodule
