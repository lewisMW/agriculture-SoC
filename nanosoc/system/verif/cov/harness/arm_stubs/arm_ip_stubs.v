// -----------------------------------------------------------------------------
// arm_ip_stubs.v  —  NOT ARM IP.  HARNESS ONLY.
//
// Port-compatible stand-ins for the licensed ARM modules nanosoc instantiates,
// so the system-level coverage models (../../*.sv) can be compiled, elaborated
// and smoke-run with Verilator on a machine without ARM_IP_LIBRARY_PATH.
// Port lists were inferred from the instantiation sites in the nanosoc RTL
// (see coverage_plan.md "Compile harness"); directions follow the CMSDK /
// Cortex-M0 integration conventions.
//
// Fidelity, by group:
//   FUNCTIONAL (simplified) — so bus traffic driven by the ADP debug master
//   really reaches the SoCLabs/sensing RTL and its coverage:
//     cmsdk_ahb_to_apb, cmsdk_apb_slave_mux, cmsdk_ahb_slave_mux,
//     cmsdk_ahb_default_slave, cmsdk_ahb_to_sram (memory modelled inside),
//     cm0_rst_sync, cm0_rst_send_set, cm0_dbg_reset_sync, cortexm0_pmu
//     (pass-through, PMU never powers down)
//   IDLE SHELLS — outputs tied to reset/idle values; they do NOTHING:
//     CORTEXM0 (never issues a transfer: no firmware runs!), CORTEXM0DAP,
//     cortexm0_wic, cmsdk_apb_timer, cmsdk_apb_dualtimers, cmsdk_apb_watchdog,
//     cmsdk_apb_uart, cmsdk_apb_test_slave, cmsdk_ahb_gpio, cmsdk_fpga_rom,
//     cmsdk_fpga_sram
//
// Any coverage collected with these stubs only says the SURROUNDING SoCLabs
// logic was exercised. Sign-off coverage must come from a build with the real
// ARM IP (just drop this file and add the ARM flists - see ../Makefile).
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

// ============================== Cortex-M0 core ===============================
module CORTEXM0 #(
    parameter ACG = 1, AHBSLV = 0, BE = 0, BKPT = 4, DBG = 1, NUMIRQ = 32,
    parameter RAR = 0, SMUL = 0, SYST = 1, WIC = 1, WICLINES = 34, WPT = 2
)(
    input  wire        SCLK, HCLK, DCLK, DBGRESETn, HRESETn,
    output wire [31:0] HADDR,
    output wire [2:0]  HBURST,
    output wire        HMASTLOCK,
    output wire [3:0]  HPROT,
    output wire [2:0]  HSIZE,
    output wire [1:0]  HTRANS,
    output wire [31:0] HWDATA,
    output wire        HWRITE,
    input  wire [31:0] HRDATA,
    input  wire        HREADY,
    input  wire        HRESP,
    output wire        HMASTER,
    input  wire [31:0] SLVADDR,
    input  wire [1:0]  SLVSIZE,
    input  wire [1:0]  SLVTRANS,
    input  wire [31:0] SLVWDATA,
    input  wire        SLVWRITE,
    output wire [31:0] SLVRDATA,
    output wire        SLVREADY,
    output wire        SLVRESP,
    input  wire        DBGRESTART,
    output wire        DBGRESTARTED,
    input  wire        EDBGRQ,
    output wire        HALTED,
    input  wire        NMI,
    input  wire [31:0] IRQ,
    input  wire        RXEV,
    output wire        TXEV,
    output wire        LOCKUP,
    output wire        SYSRESETREQ,
    input  wire [25:0] STCALIB,
    input  wire        STCLKEN,
    input  wire [7:0]  IRQLATENCY,
    input  wire [19:0] ECOREVNUM,
    output wire        CODENSEQ,
    output wire [2:0]  CODEHINTDE,
    output wire        SPECHTRANS,
    output wire        SLEEPING,
    output wire        SLEEPDEEP,
    input  wire        SLEEPHOLDREQn,
    output wire        SLEEPHOLDACKn,
    input  wire        WICDSREQn,
    output wire        WICDSACKn,
    output wire [31:0] WICMASKISR,
    output wire        WICMASKNMI,
    output wire        WICMASKRXEV,
    output wire        WICLOAD,
    output wire        WICCLEAR,
    input  wire        SE
);
    // Idle master: no firmware executes on this stub.
    assign HADDR = 32'h0;  assign HBURST = 3'b000; assign HMASTLOCK = 1'b0;
    assign HPROT = 4'b0011; assign HSIZE = 3'b010; assign HTRANS = 2'b00;
    assign HWDATA = 32'h0; assign HWRITE = 1'b0;  assign HMASTER = 1'b0;
    assign SLVRDATA = 32'h0; assign SLVREADY = 1'b1; assign SLVRESP = 1'b0;
    assign DBGRESTARTED = 1'b0; assign HALTED = 1'b0; assign TXEV = 1'b0;
    assign LOCKUP = 1'b0; assign SYSRESETREQ = 1'b0;
    assign CODENSEQ = 1'b0; assign CODEHINTDE = 3'b000; assign SPECHTRANS = 1'b0;
    assign SLEEPING = 1'b0; assign SLEEPDEEP = 1'b0; assign SLEEPHOLDACKn = 1'b1;
    assign WICDSACKn = 1'b1; assign WICMASKISR = 32'h0; assign WICMASKNMI = 1'b0;
    assign WICMASKRXEV = 1'b0; assign WICLOAD = 1'b0; assign WICCLEAR = 1'b0;
endmodule

module CORTEXM0DAP #(parameter JTAGnSW = 0, DBG = 1, RAR = 0)(
    input  wire        SWCLKTCK, nTRST, DPRESETn, APRESETn, SWDITMS, TDI,
    input  wire        CDBGPWRUPACK, DEVICEEN, DCLK, SE,
    output wire        SWDO, SWDOEN, TDO, nTDOEN, CDBGPWRUPREQ,
    output wire [31:0] SLVADDR, SLVWDATA,
    output wire [1:0]  SLVTRANS, SLVSIZE,
    output wire        SLVWRITE,
    input  wire [31:0] SLVRDATA,
    input  wire        SLVREADY, SLVRESP,
    input  wire [31:0] BASEADDR,
    input  wire [7:0]  ECOREVNUM
);
    assign SWDO = 1'b0; assign SWDOEN = 1'b0; assign TDO = 1'b0; assign nTDOEN = 1'b1;
    assign CDBGPWRUPREQ = 1'b0;
    assign SLVADDR = 32'h0; assign SLVWDATA = 32'h0; assign SLVTRANS = 2'b00;
    assign SLVSIZE = 2'b10; assign SLVWRITE = 1'b0;
endmodule

module cortexm0_wic #(parameter WIC = 1, WICLINES = 34)(
    input  wire                FCLK, nRESET, WICLOAD, WICCLEAR, WICENREQ, WICDSACKn,
    input  wire [WICLINES-1:0] WICINT, WICMASK,
    output wire                WAKEUP, WICDSREQn, WICENACK,
    output wire [WICLINES-1:0] WICSENSE, WICPEND
);
    assign WAKEUP = 1'b0; assign WICDSREQn = 1'b1; assign WICENACK = 1'b0;
    assign WICSENSE = {WICLINES{1'b0}}; assign WICPEND = {WICLINES{1'b0}};
endmodule

// PMU: never gates or powers down. Forwards the reset request (one FCLK later)
// so SYSRESETREQ-driven warm resets still propagate through slcorem0_rstctrl.
module cortexm0_pmu (
    input  wire FCLK, PORESETn, HRESETREQ, PMUENABLE, WICENACK, WAKEUP,
    input  wire CDBGPWRUPREQ, SLEEPDEEP, SLEEPHOLDACKn, GATEHCLK,
    input  wire SYSPWRDOWNACK, DBGPWRDOWNACK, CGBYPASS,
    output wire HCLK, DCLK, SCLK,
    output wire WICENREQ, CDBGPWRUPACK,
    output wire SYSISOLATEn, SYSRETAINn, SYSPWRDOWN, DBGISOLATEn, DBGPWRDOWN,
    output wire SLEEPHOLDREQn,
    output reg  PMUDBGRESETREQ,
    output reg  PMUHRESETREQ
);
    assign HCLK = FCLK; assign DCLK = FCLK; assign SCLK = FCLK;
    assign WICENREQ = 1'b0; assign CDBGPWRUPACK = CDBGPWRUPREQ;
    assign SYSISOLATEn = 1'b1; assign SYSRETAINn = 1'b1; assign SYSPWRDOWN = 1'b0;
    assign DBGISOLATEn = 1'b1; assign DBGPWRDOWN = 1'b0; assign SLEEPHOLDREQn = 1'b1;
    always @(posedge FCLK or negedge PORESETn)
        if (!PORESETn) begin PMUHRESETREQ <= 1'b0; PMUDBGRESETREQ <= 1'b0; end
        else           begin PMUHRESETREQ <= HRESETREQ; PMUDBGRESETREQ <= 1'b0; end
endmodule

// Reset synchroniser: asynchronous assert (RSTINn low), synchronous assert on
// RSTREQ, synchronous de-assert after two CLK edges.
module cm0_rst_sync (
    input  wire RSTINn, RSTREQ, CLK, SE, RSTBYPASS,
    output wire RSTOUTn
);
    reg [1:0] q;
    always @(posedge CLK or negedge RSTINn)
        if (!RSTINn)     q <= 2'b00;
        else if (RSTREQ) q <= 2'b00;
        else             q <= {q[0], 1'b1};
    assign RSTOUTn = RSTBYPASS ? RSTINn : q[1];
endmodule

module cm0_rst_send_set (
    input  wire RSTn, CLK, RSTREQIN,
    output reg  RSTREQOUT
);
    always @(posedge CLK or negedge RSTn)
        if (!RSTn) RSTREQOUT <= 1'b0;
        else       RSTREQOUT <= RSTREQIN;
endmodule

module cm0_dbg_reset_sync #(parameter PRESENT = 1)(
    input  wire RSTIN, CLK, SE, RSTBYPASS,
    output wire RSTOUT
);
    reg [1:0] q;
    always @(posedge CLK or negedge RSTIN)
        if (!RSTIN) q <= 2'b00;
        else        q <= {q[0], 1'b1};
    assign RSTOUT = RSTBYPASS ? RSTIN : q[1];
endmodule

// ================================ CMSDK bus ==================================
// AHB-to-APB bridge: SETUP/ACCESS sequencing, wait states from PREADY, two-cycle
// AHB ERROR on PSLVERR, optional registered read data (as REGISTER_RDATA=1).
module cmsdk_ahb_to_apb #(
    parameter ADDRWIDTH = 16, REGISTER_RDATA = 1, REGISTER_WDATA = 0
)(
    input  wire                 HCLK, HRESETn, PCLKEN, HSEL,
    input  wire [ADDRWIDTH-1:0] HADDR,
    input  wire [1:0]           HTRANS,
    input  wire [2:0]           HSIZE,
    input  wire [3:0]           HPROT,
    input  wire                 HWRITE, HREADY,
    input  wire [31:0]          HWDATA,
    output wire                 HREADYOUT,
    output wire [31:0]          HRDATA,
    output wire                 HRESP,
    output wire [ADDRWIDTH-1:0] PADDR,
    output wire                 PENABLE, PWRITE,
    output wire [3:0]           PSTRB,
    output wire [2:0]           PPROT,
    output wire [31:0]          PWDATA,
    output wire                 PSEL, APBACTIVE,
    input  wire [31:0]          PRDATA,
    input  wire                 PREADY, PSLVERR
);
    localparam ST_IDLE = 3'd0, ST_WAIT = 3'd1, ST_SETUP = 3'd2, ST_ACCESS = 3'd3,
               ST_ERR1 = 3'd4, ST_ERR2 = 3'd5, ST_DONE = 3'd6;
    reg [2:0]           state;
    reg [ADDRWIDTH-3:0] addr_q;
    reg                 write_q;
    reg [3:0]           strb_q;
    reg [2:0]           prot_q;
    reg [31:0]          rdata_q, wdata_q;

    wire ready_out = (state == ST_IDLE) || (state == ST_DONE) || (state == ST_ERR2);
    wire trans_req = HSEL && HTRANS[1] && HREADY;
    wire [3:0] strb_nxt = !HWRITE ? 4'b0000 :
                          (HSIZE[1]) ? 4'b1111 :
                          (HSIZE[0]) ? (HADDR[1] ? 4'b1100 : 4'b0011) :
                                       (4'b0001 << HADDR[1:0]);

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            state <= ST_IDLE; addr_q <= 0; write_q <= 1'b0; strb_q <= 4'h0;
            prot_q <= 3'h0; rdata_q <= 32'h0; wdata_q <= 32'h0;
        end else begin
            case (state)
                ST_SETUP:  begin if (PCLKEN) state <= ST_ACCESS; wdata_q <= HWDATA; end
                ST_WAIT:   if (PCLKEN) state <= ST_SETUP;
                ST_ACCESS: if (PCLKEN && PREADY) begin
                               if (PSLVERR) state <= ST_ERR1;
                               else begin
                                   rdata_q <= PRDATA;
                                   state   <= REGISTER_RDATA ? ST_DONE : ST_IDLE;
                               end
                           end
                ST_ERR1:   state <= ST_ERR2;
                default:   state <= ST_IDLE;   // IDLE / DONE / ERR2
            endcase
            if (ready_out && trans_req) begin
                addr_q  <= HADDR[ADDRWIDTH-1:2];
                write_q <= HWRITE;
                strb_q  <= strb_nxt;
                prot_q  <= {!HPROT[0], 1'b0, HPROT[1]};
                state   <= PCLKEN ? ST_SETUP : ST_WAIT;
            end
        end
    end

    assign HREADYOUT = ready_out ||
                       (!REGISTER_RDATA && state == ST_ACCESS && PCLKEN && PREADY && !PSLVERR);
    assign HRESP     = (state == ST_ERR1) || (state == ST_ERR2);
    assign HRDATA    = REGISTER_RDATA ? rdata_q : PRDATA;
    assign PADDR     = {addr_q, 2'b00};
    assign PSEL      = (state == ST_SETUP) || (state == ST_ACCESS);
    assign PENABLE   = (state == ST_ACCESS);
    assign PWRITE    = write_q;
    assign PSTRB     = strb_q;
    assign PPROT     = prot_q;
    assign PWDATA    = REGISTER_WDATA ? wdata_q : HWDATA;
    assign APBACTIVE = trans_req || (state != ST_IDLE);
endmodule

module cmsdk_apb_slave_mux #(
    parameter PORT0_ENABLE = 1, PORT1_ENABLE = 1, PORT2_ENABLE = 1, PORT3_ENABLE = 1,
    parameter PORT4_ENABLE = 1, PORT5_ENABLE = 1, PORT6_ENABLE = 1, PORT7_ENABLE = 1,
    parameter PORT8_ENABLE = 1, PORT9_ENABLE = 1, PORT10_ENABLE = 1, PORT11_ENABLE = 1,
    parameter PORT12_ENABLE = 1, PORT13_ENABLE = 1, PORT14_ENABLE = 1, PORT15_ENABLE = 1
)(
    input  wire [3:0]  DECODE4BIT,
    input  wire        PSEL,
    output wire        PSEL0, PSEL1, PSEL2, PSEL3, PSEL4, PSEL5, PSEL6, PSEL7,
    output wire        PSEL8, PSEL9, PSEL10, PSEL11, PSEL12, PSEL13, PSEL14, PSEL15,
    input  wire        PREADY0, PREADY1, PREADY2, PREADY3, PREADY4, PREADY5, PREADY6, PREADY7,
    input  wire        PREADY8, PREADY9, PREADY10, PREADY11, PREADY12, PREADY13, PREADY14, PREADY15,
    input  wire [31:0] PRDATA0, PRDATA1, PRDATA2, PRDATA3, PRDATA4, PRDATA5, PRDATA6, PRDATA7,
    input  wire [31:0] PRDATA8, PRDATA9, PRDATA10, PRDATA11, PRDATA12, PRDATA13, PRDATA14, PRDATA15,
    input  wire        PSLVERR0, PSLVERR1, PSLVERR2, PSLVERR3, PSLVERR4, PSLVERR5, PSLVERR6, PSLVERR7,
    input  wire        PSLVERR8, PSLVERR9, PSLVERR10, PSLVERR11, PSLVERR12, PSLVERR13, PSLVERR14, PSLVERR15,
    output wire        PREADY,
    output wire [31:0] PRDATA,
    output wire        PSLVERR
);
    wire [15:0] en = {PORT15_ENABLE[0], PORT14_ENABLE[0], PORT13_ENABLE[0], PORT12_ENABLE[0],
                      PORT11_ENABLE[0], PORT10_ENABLE[0], PORT9_ENABLE[0],  PORT8_ENABLE[0],
                      PORT7_ENABLE[0],  PORT6_ENABLE[0],  PORT5_ENABLE[0],  PORT4_ENABLE[0],
                      PORT3_ENABLE[0],  PORT2_ENABLE[0],  PORT1_ENABLE[0],  PORT0_ENABLE[0]};
    wire [15:0] dec = en & (16'h1 << DECODE4BIT);
    wire [15:0] sel = {16{PSEL}} & dec;
    assign {PSEL15, PSEL14, PSEL13, PSEL12, PSEL11, PSEL10, PSEL9, PSEL8,
            PSEL7,  PSEL6,  PSEL5,  PSEL4,  PSEL3,  PSEL2,  PSEL1, PSEL0} = sel;
    wire [15:0] rdy = {PREADY15, PREADY14, PREADY13, PREADY12, PREADY11, PREADY10, PREADY9, PREADY8,
                       PREADY7,  PREADY6,  PREADY5,  PREADY4,  PREADY3,  PREADY2,  PREADY1, PREADY0};
    wire [15:0] err = {PSLVERR15, PSLVERR14, PSLVERR13, PSLVERR12, PSLVERR11, PSLVERR10, PSLVERR9, PSLVERR8,
                       PSLVERR7,  PSLVERR6,  PSLVERR5,  PSLVERR4,  PSLVERR3,  PSLVERR2,  PSLVERR1, PSLVERR0};
    wire [31:0] rd [0:15];
    assign rd[0] = PRDATA0;   assign rd[1] = PRDATA1;   assign rd[2] = PRDATA2;   assign rd[3] = PRDATA3;
    assign rd[4] = PRDATA4;   assign rd[5] = PRDATA5;   assign rd[6] = PRDATA6;   assign rd[7] = PRDATA7;
    assign rd[8] = PRDATA8;   assign rd[9] = PRDATA9;   assign rd[10] = PRDATA10; assign rd[11] = PRDATA11;
    assign rd[12] = PRDATA12; assign rd[13] = PRDATA13; assign rd[14] = PRDATA14; assign rd[15] = PRDATA15;
    wire hit = |dec;
    assign PREADY  = hit ? rdy[DECODE4BIT] : 1'b1;
    assign PSLVERR = hit ? (PSEL & err[DECODE4BIT]) : 1'b0;
    assign PRDATA  = (hit && PSEL) ? rd[DECODE4BIT] : 32'h0;
endmodule

module cmsdk_ahb_slave_mux #(
    parameter PORT0_ENABLE = 1, PORT1_ENABLE = 1, PORT2_ENABLE = 1, PORT3_ENABLE = 1,
    parameter PORT4_ENABLE = 1, PORT5_ENABLE = 1, PORT6_ENABLE = 1, PORT7_ENABLE = 1,
    parameter PORT8_ENABLE = 1, PORT9_ENABLE = 1, DW = 32
)(
    input  wire          HCLK, HRESETn, HREADY,
    input  wire          HSEL0, HSEL1, HSEL2, HSEL3, HSEL4, HSEL5, HSEL6, HSEL7, HSEL8, HSEL9,
    input  wire          HREADYOUT0, HREADYOUT1, HREADYOUT2, HREADYOUT3, HREADYOUT4,
    input  wire          HREADYOUT5, HREADYOUT6, HREADYOUT7, HREADYOUT8, HREADYOUT9,
    input  wire          HRESP0, HRESP1, HRESP2, HRESP3, HRESP4, HRESP5, HRESP6, HRESP7, HRESP8, HRESP9,
    input  wire [DW-1:0] HRDATA0, HRDATA1, HRDATA2, HRDATA3, HRDATA4,
    input  wire [DW-1:0] HRDATA5, HRDATA6, HRDATA7, HRDATA8, HRDATA9,
    output wire          HREADYOUT,
    output wire          HRESP,
    output wire [DW-1:0] HRDATA
);
    wire [9:0] hsel = {HSEL9, HSEL8, HSEL7, HSEL6, HSEL5, HSEL4, HSEL3, HSEL2, HSEL1, HSEL0};
    reg  [9:0] sel_q;
    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn)    sel_q <= 10'h0;
        else if (HREADY) sel_q <= hsel;
    assign HREADYOUT = sel_q[0] ? HREADYOUT0 : sel_q[1] ? HREADYOUT1 : sel_q[2] ? HREADYOUT2 :
                       sel_q[3] ? HREADYOUT3 : sel_q[4] ? HREADYOUT4 : sel_q[5] ? HREADYOUT5 :
                       sel_q[6] ? HREADYOUT6 : sel_q[7] ? HREADYOUT7 : sel_q[8] ? HREADYOUT8 :
                       sel_q[9] ? HREADYOUT9 : 1'b1;
    assign HRESP     = sel_q[0] ? HRESP0 : sel_q[1] ? HRESP1 : sel_q[2] ? HRESP2 : sel_q[3] ? HRESP3 :
                       sel_q[4] ? HRESP4 : sel_q[5] ? HRESP5 : sel_q[6] ? HRESP6 : sel_q[7] ? HRESP7 :
                       sel_q[8] ? HRESP8 : sel_q[9] ? HRESP9 : 1'b0;
    assign HRDATA    = sel_q[0] ? HRDATA0 : sel_q[1] ? HRDATA1 : sel_q[2] ? HRDATA2 : sel_q[3] ? HRDATA3 :
                       sel_q[4] ? HRDATA4 : sel_q[5] ? HRDATA5 : sel_q[6] ? HRDATA6 : sel_q[7] ? HRDATA7 :
                       sel_q[8] ? HRDATA8 : sel_q[9] ? HRDATA9 : {DW{1'b0}};
endmodule

// Two-cycle ERROR response to any NONSEQ/SEQ transfer; OKAY to IDLE/BUSY.
module cmsdk_ahb_default_slave (
    input  wire       HCLK, HRESETn, HSEL, HREADY,
    input  wire [1:0] HTRANS,
    output wire       HREADYOUT,
    output wire       HRESP
);
    reg [1:0] resp_state;   // [0]=first error cycle, [1]=second
    wire trans_req = HSEL && HTRANS[1] && HREADY;
    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn) resp_state <= 2'b00;
        else          resp_state <= {resp_state[0], trans_req};
    assign HREADYOUT = !resp_state[0];
    assign HRESP     = resp_state[0] || resp_state[1];
endmodule

// AHB-to-SRAM bridge with the memory array modelled inside (the external SRAM
// port is driven idle and the cmsdk_fpga_* stubs below are inert). No wait
// states, OKAY only - like the CMSDK block.
module cmsdk_ahb_to_sram #(parameter AW = 16)(
    input  wire          HCLK, HRESETn, HSEL, HREADY, HWRITE,
    input  wire [AW-1:0] HADDR,
    input  wire [1:0]    HTRANS,
    input  wire [2:0]    HSIZE,
    input  wire [31:0]   HWDATA,
    output wire          HREADYOUT,
    output wire [31:0]   HRDATA,
    output wire          HRESP,
    input  wire [31:0]   SRAMRDATA,
    output wire [AW-3:0] SRAMADDR,
    output wire [31:0]   SRAMWDATA,
    output wire [3:0]    SRAMWEN,
    output wire          SRAMCS
);
    reg [31:0]   mem [0:(1 << (AW-2)) - 1];
    reg [AW-3:0] addr_q;
    reg [3:0]    wstrb_q;
    wire trans_req = HSEL && HTRANS[1] && HREADY;
    wire [3:0] strb = HSIZE[1] ? 4'b1111 :
                      HSIZE[0] ? (HADDR[1] ? 4'b1100 : 4'b0011) : (4'b0001 << HADDR[1:0]);
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            addr_q <= {(AW-2){1'b0}}; wstrb_q <= 4'h0;
        end else begin
            if (wstrb_q[0]) mem[addr_q][7:0]   <= HWDATA[7:0];
            if (wstrb_q[1]) mem[addr_q][15:8]  <= HWDATA[15:8];
            if (wstrb_q[2]) mem[addr_q][23:16] <= HWDATA[23:16];
            if (wstrb_q[3]) mem[addr_q][31:24] <= HWDATA[31:24];
            if (HREADY) begin
                addr_q  <= HADDR[AW-1:2];
                wstrb_q <= (trans_req && HWRITE) ? strb : 4'h0;
            end
        end
    end
    assign HREADYOUT = 1'b1;
    assign HRESP     = 1'b0;
    assign HRDATA    = mem[addr_q];
    assign SRAMADDR  = {(AW-2){1'b0}};
    assign SRAMWDATA = 32'h0;
    assign SRAMWEN   = 4'h0;
    assign SRAMCS    = 1'b0;
    wire _unused = &{1'b0, SRAMRDATA};
endmodule

module cmsdk_fpga_rom #(parameter AW = 16, parameter filename = "")(
    input  wire          CLK,
    input  wire [AW-3:0] ADDR,
    input  wire [31:0]   WDATA,
    input  wire [3:0]    WREN,
    input  wire          CS,
    output wire [31:0]   RDATA
);
    assign RDATA = 32'h0;
endmodule

module cmsdk_fpga_sram #(parameter AW = 16)(
    input  wire          CLK,
    input  wire [AW-3:0] ADDR,
    input  wire [31:0]   WDATA,
    input  wire [3:0]    WREN,
    input  wire          CS,
    output wire [31:0]   RDATA
);
    // Byte-lane arrays exist only because nanosoc_tb preloads the EXPRAMs by
    // hierarchical reference to BRAM0..3; the stub's memory lives in
    // cmsdk_ahb_to_sram, so that preload has no effect in the harness.
    reg [7:0] BRAM0 [0:(1 << (AW-2)) - 1];
    reg [7:0] BRAM1 [0:(1 << (AW-2)) - 1];
    reg [7:0] BRAM2 [0:(1 << (AW-2)) - 1];
    reg [7:0] BRAM3 [0:(1 << (AW-2)) - 1];
    assign RDATA = 32'h0;
endmodule

// ============================ CMSDK peripherals ==============================
// Idle APB shells: zero read data, never wait, never error, no interrupts.
module cmsdk_apb_timer (
    input  wire        PCLK, PCLKG, PRESETn, PSEL, PENABLE, PWRITE, EXTIN,
    input  wire [11:2] PADDR,
    input  wire [31:0] PWDATA,
    input  wire [3:0]  ECOREVNUM,
    output wire [31:0] PRDATA,
    output wire        PREADY, PSLVERR, TIMERINT
);
    assign PRDATA = 32'h0; assign PREADY = 1'b1; assign PSLVERR = 1'b0; assign TIMERINT = 1'b0;
endmodule

module cmsdk_apb_dualtimers (
    input  wire        PCLK, PRESETn, PENABLE, PSEL, PWRITE,
    input  wire [11:2] PADDR,
    input  wire [31:0] PWDATA,
    input  wire        TIMCLK, TIMCLKEN1, TIMCLKEN2,
    input  wire [3:0]  ECOREVNUM,
    output wire [31:0] PRDATA,
    output wire        TIMINT1, TIMINT2, TIMINTC
);
    assign PRDATA = 32'h0; assign TIMINT1 = 1'b0; assign TIMINT2 = 1'b0; assign TIMINTC = 1'b0;
endmodule

module cmsdk_apb_watchdog (
    input  wire        PCLK, PRESETn, PENABLE, PSEL, PWRITE,
    input  wire [11:2] PADDR,
    input  wire [31:0] PWDATA,
    input  wire        WDOGCLK, WDOGCLKEN, WDOGRESn,
    input  wire [3:0]  ECOREVNUM,
    output wire [31:0] PRDATA,
    output wire        WDOGINT, WDOGRES
);
    assign PRDATA = 32'h0; assign WDOGINT = 1'b0; assign WDOGRES = 1'b0;
endmodule

module cmsdk_apb_uart (
    input  wire        PCLK, PCLKG, PRESETn, PSEL, PENABLE, PWRITE, RXD,
    input  wire [11:2] PADDR,
    input  wire [31:0] PWDATA,
    input  wire [3:0]  ECOREVNUM,
    output wire [31:0] PRDATA,
    output wire        PREADY, PSLVERR, TXD, TXEN, BAUDTICK,
    output wire        TXINT, RXINT, TXOVRINT, RXOVRINT, UARTINT
);
    assign PRDATA = 32'h0; assign PREADY = 1'b1; assign PSLVERR = 1'b0;
    assign TXD = 1'b1; assign TXEN = 1'b0; assign BAUDTICK = 1'b0;
    assign TXINT = 1'b0; assign RXINT = 1'b0; assign TXOVRINT = 1'b0;
    assign RXOVRINT = 1'b0; assign UARTINT = 1'b0;
endmodule

module cmsdk_apb_test_slave (
    input  wire        PCLK, PRESETn, PSEL, PENABLE, PWRITE,
    input  wire [11:2] PADDR,
    input  wire [3:0]  PSTRB,
    input  wire [31:0] PWDATA,
    output wire [31:0] PRDATA,
    output wire        PREADY, PSLVERR
);
    assign PRDATA = 32'h0; assign PREADY = 1'b1; assign PSLVERR = 1'b0;
endmodule

module cmsdk_ahb_gpio #(
    parameter ALTERNATE_FUNC_MASK = 16'h0000, ALTERNATE_FUNC_DEFAULT = 16'h0000, BE = 0
)(
    input  wire        HCLK, HRESETn, FCLK, HSEL, HREADY, HWRITE,
    input  wire [1:0]  HTRANS,
    input  wire [2:0]  HSIZE,
    input  wire [11:0] HADDR,
    input  wire [31:0] HWDATA,
    input  wire [3:0]  ECOREVNUM,
    input  wire [15:0] PORTIN,
    output wire        HREADYOUT, HRESP,
    output wire [31:0] HRDATA,
    output wire [15:0] PORTOUT, PORTEN, PORTFUNC, GPIOINT,
    output wire        COMBINT
);
    assign HREADYOUT = 1'b1; assign HRESP = 1'b0; assign HRDATA = 32'h0;
    assign PORTOUT = 16'h0; assign PORTEN = 16'h0;
    assign PORTFUNC = ALTERNATE_FUNC_DEFAULT & ALTERNATE_FUNC_MASK;
    assign GPIOINT = 16'h0; assign COMBINT = 1'b0;
endmodule

// ============================ Testbench-side IP ==============================
// nanosoc_tb's SWD debug tester (itself a Cortex-M0 system). Idle: it never
// drives SWCLK/SWDIO, so no SWD traffic exists in the harness.
module cmsdk_debug_tester #(parameter ROM_MEMFILE = "")(
    input  wire       CLK, PORESETn,
    input  wire [5:0] DBGCMD,
    output wire       DBGRUNNING, DBGERROR,
    input  wire       TRACECLK,
    input  wire [3:0] TRACEDATA,
    input  wire       SWV,
    input  wire       TDO,
    inout  wire       nTRST, SWCLKTCK, TDI, SWDIOTMS
);
    assign DBGRUNNING = 1'b0;
    assign DBGERROR   = 1'b0;
endmodule
