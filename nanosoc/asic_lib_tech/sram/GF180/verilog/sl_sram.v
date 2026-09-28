//-----------------------------------------------------------------------------
// SoCLabs ASIC RAM Wrapper 
// - substituted using the same name from the FPGA tech library
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.flynn@soton.ac.uk)
//
// Copyright 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module sl_sram #(
// --------------------------------------------------------------------------
// Parameter Declarations
// --------------------------------------------------------------------------
  parameter AW = 12
 )
 (
  `ifdef POWER_PINS
  inout  wire          VDD,
  inout  wire          VSS,
  `endif
  // Inputs
  input  wire          CLK,
  input  wire [AW-1:2] ADDR,
  input  wire [31:0]   WDATA,
  input  wire [3:0]    WREN,
  input  wire          CS,

  // Outputs
  output wire [31:0]   RDATA
  );

localparam N = 2**(AW-11); //default 2

wire [AW-3:0]   ADDR12 = ADDR[AW-1:2];
wire [8:0]      ADDR9 = ADDR12[8:0];
wire [AW-12:0]  ADDR_TOP = ADDR12[AW-3:9];

wire [31:0] WDATA32 = WDATA;
wire [31:0] RDATA32;
assign      RDATA = RDATA32;
wire        GWEN = &(~WREN);

wire [N-1:0] CEN;

wire [31:0] WEN32 = { {8{!WREN[3]}},{8{!WREN[2]}},{8{!WREN[1]}},{8{!WREN[0]}} };

genvar i;
generate
    for (i = 0; i<N ; i=i+1) begin: gen_sram
        assign CEN[i] = (i==ADDR_TOP) ? !CS : 1'b1;
        gf180mcu_fd_ip_sram__sram512x8m8wm1 u_sram_B0(
            .CLK(CLK),
            .CEN(CEN),
            .GWEN(GWEN),
            .WEN({8{!WREN[0]}}),
            .A(ADDR9),
            .D(WDATA32[7:0]),
            .Q(RDATA32[7:0])
        );
        gf180mcu_fd_ip_sram__sram512x8m8wm1 u_sram_B1(
            .CLK(CLK),
            .CEN(CEN),
            .GWEN(GWEN),
            .WEN({8{!WREN[1]}}),
            .A(ADDR9),
            .D(WDATA32[15:8]),
            .Q(RDATA32[15:8])
        );
        gf180mcu_fd_ip_sram__sram512x8m8wm1 u_sram_B2(
            .CLK(CLK),
            .CEN(CEN),
            .GWEN(GWEN),
            .WEN({8{!WREN[2]}}),
            .A(ADDR9),
            .D(WDATA32[23:16]),
            .Q(RDATA32[23:16])
        );
        gf180mcu_fd_ip_sram__sram512x8m8wm1 u_sram_B3(
            .CLK(CLK),
            .CEN(CEN),
            .GWEN(GWEN),
            .WEN({8{!WREN[3]}}),
            .A(ADDR9),
            .D(WDATA32[31:24]),
            .Q(RDATA32[31:24])
        );
    end
endgenerate

endmodule
