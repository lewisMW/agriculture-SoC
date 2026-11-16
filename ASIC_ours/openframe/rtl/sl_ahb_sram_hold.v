//-----------------------------------------------------------------------------
// sl_ahb_sram for memories built with the DFFRAM compiler (RAM512, RAM1024).
//
// Same module name, parameters and ports as nanosoc/asic_lib_tech/sram/verilog/
// sl_ahb_sram.v; read after it, so this is the definition synthesis keeps
// (Cadence/inputs/custom_hdl_file_list.tcl, memory sets compiler_latch and
// compiler_dff).
//
// Why the standard bridge cannot be used. The compiler's blocks keep an output
// register per 16 words and select among those registers with the address
// pins as they are NOW (models/ram/model.v: the output muxes take A0 itself).
// Read data is therefore only right while the address of that read is still
// on the pins. An AHB bridge for a synchronous SRAM presents the next
// address in the cycle in which it takes the data of the previous read, so
// every read that crosses a 16-word boundary would return another register's
// content (zero). ChipFoundry's pre-hardened blocks register that select
// inside the macro; the compiler's do not.
//
// What this bridge does. It latches each transfer and holds address, write
// data and controls steady on the macro until the access is over, and takes
// the read data into a register of its own:
//   read   address phase | RD1 macro captures | RD2 Do0 settles | RD3 HRDATA valid
//   write  address phase | WR1 HWDATA latched | WR2 macro written
// HREADYOUT is low in RD1, RD2 and WR1, so a read costs two wait states and a
// write one. Nothing between the bus and the macro is combinational: every
// macro input and HRDATA come straight from flops here, which is what the
// compiler blocks' long input set-up and clock-to-output times need.
//
// RAM_ADDR_W (bytes) selects the macro: 12 -> RAM1024 (4 kbyte), 11 -> RAM512
// (2 kbyte). Any other value instantiates a module that does not exist and
// stops elaboration.
//-----------------------------------------------------------------------------

module sl_ahb_sram #(
    parameter SYS_DATA_W = 32,
    parameter RAM_ADDR_W = 14,
    parameter RAM_DATA_W = 32
)(
    `ifdef POWER_PINS
    inout  wire          VDD,
    inout  wire          VSS,
    `endif
    input  wire                  HCLK,
    input  wire                  HRESETn,
    input  wire                  HSEL,
    input  wire                  HREADY,
    input  wire            [1:0] HTRANS,
    input  wire            [2:0] HSIZE,
    input  wire                  HWRITE,
    input  wire [RAM_ADDR_W-1:0] HADDR,
    input  wire [SYS_DATA_W-1:0] HWDATA,
    output wire                  HREADYOUT,
    output wire                  HRESP,
    output wire [SYS_DATA_W-1:0] HRDATA
);

    localparam [2:0] S_IDLE = 3'd0, S_RD1 = 3'd1, S_RD2 = 3'd2, S_RD3 = 3'd3,
                     S_WR1  = 3'd4, S_WR2 = 3'd5;

    reg  [2:0]            state;
    reg  [RAM_ADDR_W-1:2] addr_q;
    reg  [3:0]            we_q;
    reg  [31:0]           wdata_q;
    reg  [31:0]           rdata_q;
    wire [31:0]           ram_do;

    // a transfer is accepted on the edge that ends its address phase
    wire acc = HSEL & HTRANS[1] & HREADY;

    // byte lanes of the transfer (little-endian)
    wire [3:0] lanes = (HSIZE[1:0] == 2'b00) ? (4'b0001 << HADDR[1:0]) :
                       (HSIZE[1:0] == 2'b01) ? (HADDR[1] ? 4'b1100 : 4'b0011) :
                                               4'b1111;

    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            state <= S_IDLE;
        end else begin
            case (state)
                S_RD1:   state <= S_RD2;
                S_RD2:   state <= S_RD3;
                S_WR1:   state <= S_WR2;
                default: state <= acc ? (HWRITE ? S_WR1 : S_RD1) : S_IDLE;   // S_IDLE, S_RD3, S_WR2
            endcase
        end
    end

    // Held until the next transfer is accepted. No reset: they are only used
    // after a transfer has loaded them.
    always @(posedge HCLK) begin
        if (acc) begin
            addr_q <= HADDR[RAM_ADDR_W-1:2];
            we_q   <= HWRITE ? lanes : 4'b0000;
        end
        if (state == S_WR1) wdata_q <= HWDATA;
        if (state == S_RD2) rdata_q <= ram_do;
    end

    wire       ram_en = (state == S_RD1) | (state == S_RD2) | (state == S_WR2);
    wire [3:0] ram_we = (state == S_WR2) ? we_q : 4'b0000;

    assign HREADYOUT = (state == S_IDLE) | (state == S_RD3) | (state == S_WR2);
    assign HRESP     = 1'b0;
    assign HRDATA    = rdata_q;

generate
    if (RAM_ADDR_W == 12) begin : g_4k
        RAM1024 u_ram (.CLK(HCLK), .WE0(ram_we), .EN0(ram_en), .A0(addr_q[11:2]), .Di0(wdata_q), .Do0(ram_do));
    end else if (RAM_ADDR_W == 11) begin : g_2k
        RAM512  u_ram (.CLK(HCLK), .WE0(ram_we), .EN0(ram_en), .A0(addr_q[10:2]), .Di0(wdata_q), .Do0(ram_do));
    end else begin : g_unsupported
        sl_ahb_sram_hold_has_no_macro_for_this_RAM_ADDR_W u_stop ();
    end
endgenerate

endmodule
