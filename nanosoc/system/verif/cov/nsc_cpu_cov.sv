`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// nsc_cpu_cov.sv — interrupts, low power and boot (batch 4)
//
//   nsc_irq_lp_cov  bound into nanosoc_system.
//     cg_irq_line   every CPU IRQ line 0..31 and NMI rising, x CPU context at
//                   arrival (running / sleeping / deep sleep / locked up /
//                   just after a vector fetch = exception entry in progress)
//     cg_irq_sys    simultaneous arrivals, number pending, NMI+IRQ together,
//                   each SHARED source on IRQ 6/7/15/16-31, interrupts that the
//                   nanosoc wiring DROPS (UART overflow 12-14, F4), EXP_IRQ (F3)
//     cg_vector     CPU data reads of the vector table (0x00-0xBC) = exception
//                   entry proxy, per vector, x where it was read (bootrom/IMEM)
//     cg_lp         sleep / deep-sleep entry, wake cause, sleep length,
//                   autonomous sensing sample while asleep (THE product use
//                   case), debugger traffic while asleep, IRQ racing sleep entry,
//                   TXEV/RXEV, LOCKUP
//     cg_boot       first CPU access after each reset (address, REMAP, cold vs
//                   warm), opcode-fetch region (incl. executing from the
//                   sensing peripheral / SYSIO = fault path), bootrom upper-
//                   half alias (F2), debugger active before first fetch, reset
//                   while the bootloader still has REMAP set
//   nsc_pmu_cov     bound into slcorem0: PMU / WIC / SLEEPHOLD / GATEHCLK /
//                   debug power-up handshakes, DAP (SWD) memory access, SWCLK
//                   activity, SWD access while sleeping.
//
// The vector-fetch proxy counts any CPU data read of 0x00-0xBC; real exception
// entry can be confirmed with the tarmac signals (nanosoc_tb USE_TARMAC) when
// the ARM IP is present. With the harness CPU stub, cg_irq_line/cg_vector/
// cg_lp/cg_boot are expected to be (almost) empty: no firmware runs.
// -----------------------------------------------------------------------------
module nsc_irq_lp_cov (
    input logic        SYS_HCLK,
    input logic        SYS_HRESETn,
    input logic        SYS_PORESETn,
    input logic [31:0] CPU_0_IRQ,
    input logic        CPU_0_NMI,
    input logic [31:0] SYS_APB_IRQ,
    input logic [3:0]  EXP_IRQ,
    input logic [15:0] SYS_GPIO0_IRQ,
    input logic [15:0] SYS_GPIO1_IRQ,
    input logic        DMAC_ANY_DONE,
    input logic        DMAC_ANY_ERROR,
    input logic        CPU_SLEEPING,
    input logic        CPU_SLEEPDEEP,
    input logic        CPU_LOCKUP,
    input logic        CPU_0_TXEV,
    input logic        CPU_0_RXEV,
    input logic [31:0] CPU_0_HADDR,
    input logic [1:0]  CPU_0_HTRANS,
    input logic [3:0]  CPU_0_HPROT,
    input logic        CPU_0_HWRITE,
    input logic        CPU_0_HREADY,
    input logic [1:0]  DEBUG_HTRANS,
    input logic        REMAP_CTRL0,     // 1 = IMEM at 0x0 (sysctrl REMAP cleared)
    input logic        sens_sample      // sensing FIFO push (autonomous or manual)
);
    // ---------------- edges / context --------------------------------------
    logic [31:0] irq_q;  logic nmi_q, sleep_q, lock_q, txev_q, rxev_q, h_q, po_q;
    always @(posedge SYS_HCLK) begin
        irq_q <= CPU_0_IRQ; nmi_q <= CPU_0_NMI; sleep_q <= CPU_SLEEPING;
        lock_q <= CPU_LOCKUP; txev_q <= CPU_0_TXEV; rxev_q <= CPU_0_RXEV;
        h_q <= SYS_HRESETn; po_q <= SYS_PORESETn;
    end
    wire [31:0] irq_rise = CPU_0_IRQ & ~irq_q;
    wire        nmi_rise = CPU_0_NMI && !nmi_q;

    wire cpu_ap   = CPU_0_HTRANS[1] && CPU_0_HREADY;
    wire vec_read = cpu_ap && !CPU_0_HWRITE && CPU_0_HPROT[0] && (CPU_0_HADDR < 32'hC0)
                    && (CPU_0_HADDR[1:0] == 2'b00);
    int unsigned since_vec;
    always @(posedge SYS_HCLK or negedge SYS_HRESETn)
        if (!SYS_HRESETn) since_vec <= 1000;
        else if (vec_read) since_vec <= 0;
        else if (since_vec < 1000) since_vec <= since_vec + 1;

    // context: 0 running, 1 sleeping, 2 deep sleep, 3 locked up, 4 exception entry
    function automatic logic [2:0] ctx();
        if (CPU_LOCKUP)                    return 3'd3;
        if (CPU_SLEEPING && CPU_SLEEPDEEP) return 3'd2;
        if (CPU_SLEEPING)                  return 3'd1;
        if (since_vec < 16)                return 3'd4;
        return 3'd0;
    endfunction

    covergroup cg_irq_line with function sample(int line, logic [2:0] c);
        option.per_instance = 1;
        cp_line : coverpoint line {
            bins irq[] = {[0:31]};
            bins nmi   = {32};
        }
        cp_ctx : coverpoint c {
            bins running = {0}; bins sleeping = {1}; bins deep_sleep = {2};
            bins locked_up = {3}; bins during_exception_entry = {4};
        }
        x_line_ctx : cross cp_line, cp_ctx;
    endgroup

    function automatic int popc(input logic [31:0] v);
        int n = 0; for (int i = 0; i < 32; i++) n += v[i]; return n;
    endfunction

    covergroup cg_irq_sys;
        option.per_instance = 1;
        cp_simultaneous_rise : coverpoint popc(irq_rise) + int'(nmi_rise) {
            bins two = {2}; bins three_plus = {[3:33]};
        }
        cp_pending : coverpoint popc(CPU_0_IRQ) {
            bins none = {0}; bins one = {1}; bins two = {2}; bins three_plus = {[3:32]};
        }
        cp_nmi_with_irq : coverpoint (CPU_0_NMI && |CPU_0_IRQ) { bins nmi_and_irq_pending = {1'b1}; }
        // shared lines: which source drove the shared IRQ
        cp_irq6_src  : coverpoint {SYS_APB_IRQ[6], |SYS_GPIO0_IRQ} iff (CPU_0_IRQ[6]) {
            bins apb = {2'b10}; bins gpio0_any = {2'b01}; bins both = {2'b11};
        }
        cp_irq7_src  : coverpoint {SYS_APB_IRQ[7], |SYS_GPIO1_IRQ} iff (CPU_0_IRQ[7]) {
            bins apb = {2'b10}; bins gpio1_any = {2'b01}; bins both = {2'b11};
        }
        cp_irq15_src : coverpoint {SYS_APB_IRQ[15], DMAC_ANY_DONE, DMAC_ANY_ERROR} iff (CPU_0_IRQ[15]) {
            bins apb = {3'b100}; bins dma_done = {3'b010}; bins dma_error = {3'b001};
            bins several = {3'b110, 3'b101, 3'b011, 3'b111};
        }
        cp_gpio0_line_on_16_31 : coverpoint (|SYS_GPIO0_IRQ) { bins gpio0_individual_irq = {1'b1}; }
        // interrupts the system wiring drops before the NVIC (F4)
        cp_dropped : coverpoint SYS_APB_IRQ[14:11] {
            // index 0 = APB IRQ 11 (unused), 1 = 12 UART0, 2 = 13 UART1, 3 = 14 UART2
            wildcard bins uart0_overflow_lost = {4'b??1?};
            wildcard bins uart1_overflow_lost = {4'b?1??};
            wildcard bins uart2_overflow_lost = {4'b1???};
        }
        cp_exp_irq : coverpoint EXP_IRQ {
            wildcard bins exp0 = {4'b???1}; wildcard bins exp1 = {4'b??1?};
            wildcard bins exp2 = {4'b?1??}; wildcard bins exp3 = {4'b1???};
        }
    endgroup

    // ---------------- vector reads ------------------------------------------
    wire [5:0] vec_num = CPU_0_HADDR[7:2];
    covergroup cg_vector;
        option.per_instance = 1;
        cp_vector : coverpoint vec_num iff (vec_read) {
            bins reset_sp = {0}; bins reset_pc = {1}; bins nmi = {2}; bins hardfault = {3};
            bins svcall = {11}; bins pendsv = {14}; bins systick = {15};
            bins irq[] = {[16:47]};
            bins reserved = {[4:10], 12, 13};
        }
        cp_vec_src : coverpoint REMAP_CTRL0 iff (vec_read) {
            bins from_bootrom = {1'b0}; bins from_imem = {1'b1};
        }
        x_vector_src : cross cp_vector, cp_vec_src;
    endgroup

    // ---------------- low power ---------------------------------------------
    int unsigned asleep_cycles;
    always @(posedge SYS_HCLK) asleep_cycles <= CPU_SLEEPING ? asleep_cycles + 1 : 0;
    wire sleep_rise = CPU_SLEEPING && !sleep_q;
    wire sleep_fall = !CPU_SLEEPING && sleep_q;

    covergroup cg_lp;
        option.per_instance = 1;
        cp_entry : coverpoint CPU_SLEEPDEEP iff (sleep_rise) { bins sleep = {0}; bins deep_sleep = {1}; }
        cp_wake_cause : coverpoint {CPU_0_NMI, |CPU_0_IRQ, CPU_0_RXEV} iff (sleep_fall) {
            bins nmi = {3'b100, 3'b110, 3'b101, 3'b111};
            bins irq = {3'b010, 3'b011};
            bins event_rxev = {3'b001};
            bins other_debug_or_reset = {3'b000};
        }
        cp_sleep_len : coverpoint asleep_cycles iff (sleep_fall) {
            bins short_lt16 = {[1:15]}; bins mid = {[16:1023]}; bins long_1k = {[1024:$]};
        }
        cp_sample_asleep : coverpoint {CPU_SLEEPING, CPU_SLEEPDEEP} iff (sens_sample) {
            bins awake = {2'b00}; bins asleep = {2'b10}; bins deep_asleep = {2'b11};
        }
        cp_debug_asleep : coverpoint DEBUG_HTRANS[1] iff (CPU_SLEEPING) { bins debugger_access_while_asleep = {1'b1}; }
        cp_irq_at_sleep_entry : coverpoint (|irq_rise) iff (sleep_rise || sleep_fall) {
            bins irq_races_sleep_edge = {1'b1};
        }
        cp_txev : coverpoint (CPU_0_TXEV && !txev_q) { bins sev = {1'b1}; }
        cp_rxev : coverpoint (CPU_0_RXEV && !rxev_q) { bins rxev = {1'b1}; }   // DMA done only: unreachable (F14)
        cp_lockup : coverpoint (CPU_LOCKUP && !lock_q) { bins lockup = {1'b1}; }
    endgroup

    // ---------------- boot ----------------------------------------------------
    logic first_pending, cold_boot, dbg_before_first;
    always @(posedge SYS_HCLK or negedge SYS_HRESETn)
        if (!SYS_HRESETn) begin first_pending <= 1'b1; dbg_before_first <= 1'b0; end
        else begin
            if (cpu_ap) first_pending <= 1'b0;
            if (first_pending && DEBUG_HTRANS[1]) dbg_before_first <= 1'b1;
        end
    // cold = PORESETn was low at some point during this HRESETn assertion
    initial cold_boot = 1'b1;    // first boot after power-up
    always @(posedge SYS_HCLK)
        if (!SYS_HRESETn) cold_boot <= (h_q ? 1'b0 : cold_boot) | !SYS_PORESETn;
    wire first_acc = cpu_ap && first_pending;
    wire h_fall    = !SYS_HRESETn && h_q;

    function automatic logic [2:0] fetch_rg(input logic [31:0] a);
        if (a < 32'h1000_0000) return 3'd0;     // zero page (bootrom/IMEM by REMAP)
        if (a < 32'h2000_0000) return 3'd1;     // bootrom
        if (a < 32'h3000_0000) return 3'd2;     // IMEM
        if (a < 32'h4000_0000) return 3'd3;     // DMEM
        if (a < 32'h6000_0000) return 3'd4;     // SYSIO (XN)
        if (a < 32'h8000_0000 || (a >= 32'hA000_0000 && a < 32'hE000_0000)) return 3'd5; // EXP
        if (a < 32'hA000_0000) return 3'd6;     // EXPRAM
        return 3'd7;
    endfunction
    wire boot_alias = (CPU_0_HADDR[31:28] == 4'h1 || (CPU_0_HADDR[31:28] == 4'h0 && !REMAP_CTRL0))
                      && CPU_0_HADDR[10];

    covergroup cg_boot;
        option.per_instance = 1;
        cp_first_addr : coverpoint CPU_0_HADDR iff (first_acc) {
            bins vector_sp = {32'h0000_0000}; bins other = default;
        }
        cp_first_remap : coverpoint REMAP_CTRL0 iff (first_acc) {
            bins boots_bootrom = {1'b0}; bins viol_boots_imem = {1'b1};
        }
        cp_boot_kind : coverpoint cold_boot iff (first_acc) { bins warm = {1'b0}; bins cold = {1'b1}; }
        cp_dbg_first : coverpoint dbg_before_first iff (first_acc) { bins debugger_before_cpu = {1'b1}; }
        cp_fetch_region : coverpoint fetch_rg(CPU_0_HADDR) iff (cpu_ap && !CPU_0_HPROT[0]) {
            bins zero_page = {0}; bins bootrom = {1}; bins imem = {2}; bins dmem = {3};
            bins sysio_xn = {4}; bins exp_sensing = {5}; bins expram = {6}; bins high = {7};
        }
        cp_bootrom_alias : coverpoint boot_alias iff (cpu_ap) { bins upper_1k_alias = {1'b1}; }
        cp_reset_in_bootloader : coverpoint REMAP_CTRL0 iff (h_fall) {
            bins before_remap_cleared = {1'b0}; bins after_remap_cleared = {1'b1};
        }
    endgroup

    cg_irq_line cg_line = new;
    cg_irq_sys  cg_sys  = new;
    cg_vector   cg_vec  = new;
    cg_lp       cg_lpw  = new;
    cg_boot     cg_bt   = new;
    always @(posedge SYS_HCLK) begin
        cg_bt.sample();
        if (SYS_HRESETn) begin
            for (int i = 0; i < 32; i++) if (irq_rise[i]) cg_line.sample(i, ctx());
            if (nmi_rise) cg_line.sample(32, ctx());
            cg_sys.sample(); cg_vec.sample(); cg_lpw.sample();
        end
    end
endmodule

// -----------------------------------------------------------------------------
module nsc_pmu_cov (
    input logic       SYS_FCLK,
    input logic       SYS_HRESETn,
    input logic       CORE_PMUENABLE,
    input logic       CORE_WICENREQ,
    input logic       CORE_WICENACK,
    input logic       CORE_WAKEUP,
    input logic       CORE_SLEEPHOLDREQn,
    input logic       CORE_SLEEPHOLDACKn,
    input logic       CORE_GATEHCLK,
    input logic       CORE_CDBGPWRUPREQ,
    input logic       CORE_CDBGPWRUPACK,
    input logic       CORE_SLEEPING,
    input logic       CORE_SLEEPDEEP,
    input logic [1:0] slv_trans,          // DAP (SWD) -> core AHB-AP transfer
    input logic       CORE_SWCLK,
    input logic       CORE_SWDOEN
);
    logic swclk_q; int unsigned swclk_edges;
    always @(posedge SYS_FCLK) begin
        swclk_q <= CORE_SWCLK;
        if (CORE_SWCLK && !swclk_q && swclk_edges < 1000) swclk_edges <= swclk_edges + 1;
    end
    covergroup cg_pmu;
        option.per_instance = 1;
        cp_pmuenable : coverpoint CORE_PMUENABLE { bins off = {0}; bins on = {1}; }
        cp_wic : coverpoint {CORE_WICENREQ, CORE_WICENACK} {
            bins idle = {2'b00}; bins req = {2'b10}; bins acked = {2'b11}; bins releasing = {2'b01};
        }
        cp_wakeup : coverpoint CORE_WAKEUP { bins wic_wakeup = {1'b1}; }
        cp_sleephold : coverpoint {CORE_SLEEPHOLDREQn, CORE_SLEEPHOLDACKn} {
            bins requested = {2'b01}; bins held = {2'b00};
        }
        cp_gatehclk : coverpoint {CORE_GATEHCLK, CORE_SLEEPDEEP} {
            bins hclk_gate_in_sleep = {2'b10}; bins hclk_gate_in_deep = {2'b11};
        }
        cp_dbgpwr : coverpoint {CORE_CDBGPWRUPREQ, CORE_CDBGPWRUPACK} {
            bins req = {2'b10}; bins powered = {2'b11}; bins powering_down = {2'b01};
        }
        cp_dap_access : coverpoint {slv_trans[1], CORE_SLEEPING} {
            bins swd_access_cpu_awake = {2'b10}; bins swd_access_cpu_asleep = {2'b11};
        }
        cp_swclk : coverpoint swclk_edges { bins no_swd = {0}; bins swd_active = {[1:$]}; }
        cp_swdoen : coverpoint CORE_SWDOEN { bins target_drives_swdio = {1'b1}; }
    endgroup
    cg_pmu cg = new;
    always @(posedge SYS_FCLK) if (SYS_HRESETn) cg.sample();
endmodule
