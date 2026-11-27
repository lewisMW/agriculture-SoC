`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// nsc_sysio_cov.sv — SYSIO peripherals, APB slots, memories, ROM table (batch 5)
//
//   nsc_sysio_region_cov  bound into nanosoc_region_sysio (0x4000_0000-0x5FFF_FFFF):
//                         which internal target was selected (APB subsystem,
//                         GPIO0, GPIO1, sysctrl, internal DEFAULT SLAVE) x dir x
//                         size, and the response each one gave.
//   nsc_apbss_cov         bound into nanosoc_sysio_apb_ss: each of the 16 APB slots
//                         x dir, PSLVERR per slot (unused 3/7/9/10 and the absent
//                         DMA slots 12/13/15 must answer PSLVERR = AHB ERROR,
//                         F14), wait states per slot, sub-word PSTRB per slot,
//                         APBACTIVE.
//   nsc_mem_region_cov    bound into each memory region (BOOTROM_0, IMEM_0, DMEM_0,
//                         EXPRAM_L, EXPRAM_H) and the SYSTABLE ROM table: first /
//                         last physical word, ALIAS above the physical size
//                         inside the 256 MB window, writes to ROMs, sub-word x
//                         dir, any ERROR response (viol for RAMs).
// Instances of one covergroup type merge in the Verilator coverage file, so a
// region-id coverpoint is crossed with everything that matters.
// -----------------------------------------------------------------------------
module nsc_sysio_region_cov (
    input logic        HCLK,
    input logic        HRESETn,
    input logic        HSEL,
    input logic [31:0] HADDR,
    input logic [1:0]  HTRANS,
    input logic        HWRITE,
    input logic [2:0]  HSIZE,
    input logic        HREADY,
    input logic        HREADYOUT,
    input logic        HRESP,
    input logic        apbsys_hsel,
    input logic        gpio0_hsel,
    input logic        gpio1_hsel,
    input logic        sysctrl_hsel,
    input logic        defslv_hsel
);
    wire ap = HSEL && HTRANS[1] && HREADY;
    logic [2:0] tgt, dp_tgt;  logic dp_valid;
    always_comb begin
        tgt = 3'd7;
        if (apbsys_hsel)       tgt = 3'd0;
        else if (gpio0_hsel)   tgt = 3'd1;
        else if (gpio1_hsel)   tgt = 3'd2;
        else if (sysctrl_hsel) tgt = 3'd3;
        else if (defslv_hsel)  tgt = 3'd4;
    end
    always @(posedge HCLK or negedge HRESETn)
        if (!HRESETn) begin dp_valid <= 1'b0; dp_tgt <= 3'd7; end
        else if (HREADY) begin dp_valid <= ap; dp_tgt <= tgt; end
    wire dp_done = dp_valid && HREADY;

    covergroup cg_sysio;
        option.per_instance = 1;
        cp_target : coverpoint tgt iff (ap) {
            bins apb_subsystem = {0}; bins gpio0 = {1}; bins gpio1 = {2};
            bins sysctrl = {3}; bins default_slave = {4};
        }
        cp_dir  : coverpoint HWRITE iff (ap) { bins read = {0}; bins write = {1}; }
        cp_size : coverpoint HSIZE iff (ap)  { bins byte_ = {0}; bins half = {1}; bins word = {2}; }
        x_target_dir  : cross cp_target, cp_dir;
        x_target_size : cross cp_target, cp_size;
        cp_resp_target : coverpoint dp_tgt iff (dp_done) {
            bins apb_subsystem = {0}; bins gpio0 = {1}; bins gpio1 = {2};
            bins sysctrl = {3}; bins default_slave = {4};
        }
        cp_resp : coverpoint HRESP iff (dp_done) { bins okay = {0}; bins error = {1}; }
        x_target_resp : cross cp_resp_target, cp_resp;
        cp_defslv_hole : coverpoint HADDR[31:16] iff (ap && tgt == 3'd4) {
            bins in_0x4001_page = {16'h4001};          // 0x4001_2000-0x4001_EFFF
            bins above_0x4002   = {[16'h4002:16'h5FFF]};
        }
    endgroup
    cg_sysio cg = new;
    always @(posedge HCLK) if (HRESETn) cg.sample();
endmodule

// -----------------------------------------------------------------------------
module nsc_apbss_cov (
    input logic        PCLK,
    input logic        PRESETn,
    input logic [15:0] i_paddr,
    input logic        i_psel,
    input logic        i_penable,
    input logic        i_pwrite,
    input logic [3:0]  i_pstrb,
    input logic        i_pready_mux,
    input logic        i_pslverr_mux,
    input logic        PCLKEN,
    input logic        APBACTIVE
);
    wire [3:0] slot = i_paddr[15:12];
    wire done   = i_psel && i_penable && i_pready_mux;
    wire stall  = i_psel && i_penable && !i_pready_mux;
    int unsigned waits;
    always @(posedge PCLK or negedge PRESETn)
        if (!PRESETn) waits <= 0;
        else if (stall) waits <= waits + 1;
        else if (done)  waits <= 0;

    covergroup cg_apbss;
        option.per_instance = 1;
        cp_slot : coverpoint slot iff (done) {
            bins timer0 = {0}; bins timer1 = {1}; bins dualtimer = {2}; bins unused3 = {3};
            bins usrt0 = {4}; bins usrt1 = {5}; bins uart2 = {6}; bins unused7 = {7};
            bins watchdog = {8}; bins unused9 = {9}; bins unused10 = {10}; bins test_slave = {11};
            bins dmac1_absent = {12}; bins dmac1_hi_absent = {13}; bins debug_usrt = {14};
            bins dmac0_absent = {15};
        }
        cp_dir : coverpoint i_pwrite iff (done) { bins read = {0}; bins write = {1}; }
        x_slot_dir : cross cp_slot, cp_dir;
        cp_err : coverpoint i_pslverr_mux iff (done) { bins okay = {0}; bins pslverr = {1}; }
        x_slot_err : cross cp_slot, cp_err;
        cp_strb : coverpoint i_pstrb iff (done && i_pwrite) {
            bins word = {4'hF}; bins half = {4'h3, 4'hC}; bins byte_ = {4'h1, 4'h2, 4'h4, 4'h8};
        }
        x_slot_strb : cross cp_slot, cp_strb;
        cp_wait : coverpoint waits iff (done) { bins zero = {0}; bins one_plus = {[1:$]}; }
        x_slot_wait : cross cp_slot, cp_wait;
        cp_pclken : coverpoint PCLKEN { bins every_cycle = {1}; bins divided = {0}; }
        cp_apbactive : coverpoint APBACTIVE { bins active = {1}; bins idle = {0}; }
    endgroup
    cg_apbss cg = new;
    always @(posedge PCLK) if (PRESETn) cg.sample();
endmodule

// -----------------------------------------------------------------------------
module nsc_mem_region_cov #(
    parameter int REGION_ID = 0,   // 0 BOOTROM_0 1 IMEM_0 2 DMEM_0 3 EXPRAM_L 4 EXPRAM_H 5 SYSTABLE
    parameter int PHYS_BYTES = 16384,
    parameter bit IS_ROM = 1'b0
)(
    input logic        HCLK,
    input logic        HRESETn,
    input logic        HSEL,
    input logic [31:0] HADDR,
    input logic [1:0]  HTRANS,
    input logic        HWRITE,
    input logic [2:0]  HSIZE,
    input logic        HREADY,
    input logic        HREADYOUT,
    input logic        HRESP
);
    wire        ap   = HSEL && HTRANS[1] && HREADY;
    wire [27:0] off  = HADDR[27:0];
    wire [2:0]  rid  = REGION_ID[2:0];
    logic dp_valid;
    always @(posedge HCLK) if (!HRESETn) dp_valid <= 1'b0; else if (HREADY) dp_valid <= ap;
    // 0 first word, 1 last physical word, 2 middle, 3 alias above physical size
    function automatic logic [1:0] where(input logic [27:0] o);
        if (o >= PHYS_BYTES)            return 2'd3;
        if (o < 4)                      return 2'd0;
        if (o >= PHYS_BYTES - 4)        return 2'd1;
        return 2'd2;
    endfunction

    covergroup cg_mem;
        option.per_instance = 1;
        cp_region : coverpoint rid {
            bins bootrom_0 = {0}; bins imem_0 = {1}; bins dmem_0 = {2};
            bins expram_l = {3}; bins expram_h = {4}; bins systable = {5};
        }
        cp_where : coverpoint where(off) iff (ap) {
            bins first_word = {0}; bins last_word = {1}; bins middle = {2}; bins alias_above_phys = {3};
        }
        cp_dir  : coverpoint HWRITE iff (ap) { bins read = {0}; bins write = {1}; }
        cp_size : coverpoint HSIZE iff (ap)  { bins byte_ = {0}; bins half = {1}; bins word = {2}; }
        x_region_where : cross cp_region, cp_where;
        x_region_dir_size : cross cp_region, cp_dir, cp_size;
        cp_rom_write : coverpoint (IS_ROM && HWRITE) iff (ap) { bins write_to_rom = {1'b1}; }
        x_region_rom_write : cross cp_region, cp_rom_write;
        cp_resp : coverpoint HRESP iff (dp_valid && HREADY) { bins okay = {0}; bins viol_error = {1}; }
    endgroup
    cg_mem cg = new;
    always @(posedge HCLK) cg.sample();
endmodule
