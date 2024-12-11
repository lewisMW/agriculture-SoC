//-----------------------------------------------------------------------------
// SoC Labs Interrupt and DMA Control Registers
// - Adapted from ARM AHB-lite example slave interface module.
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright  2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module wrapper_req_ctrl_reg #(
  // parameter for address width
  parameter   ADDRWIDTH = 12,
  parameter   DATAWIDTH = 32
) (
  input  logic                   hclk,       // clock
  input  logic                   hresetn,    // reset

  // Register interface
  input  logic [ADDRWIDTH-1:0]   addr,
  input  logic                   read_en,
  input  logic                   write_en,
  input  logic [DATAWIDTH-1:0]   wdata,
  output logic [DATAWIDTH-1:0]   rdata,

  // Request Active from I/O constructors
  input  logic                   req_act_ch0,
  input  logic                   req_act_ch1,
  input  logic                   req_act_ch2,
  input  logic                   req_act_ch3,
  input  logic                   req_act_ch4,

  // DMA Output Request Signals
  output logic                   drq_ch0,
  output logic                   drq_ch1,
  output logic                   drq_ch2,
  output logic                   drq_ch3,
  output logic                   drq_ch4,

  // Interrupt Output Request Signals
  output logic                   irq_ch0,
  output logic                   irq_ch1,
  output logic                   irq_ch2,
  output logic                   irq_ch3,
  output logic                   irq_ch4,
  output logic                   irq_merged
);

  localparam REQ_ACT_REG_WIDTH   = 5;
  localparam REQ_ACT_BIT_MAX     = (REQ_ACT_REG_WIDTH-1);

  localparam DREQ_EN_REG_WIDTH   = 5;
  localparam DREQ_EN_BIT_MAX     = (DREQ_EN_REG_WIDTH-1);

  localparam ADDR_DREQ_EN         = 'h000;
  localparam ADDR_DREQ_EN_SET     = 'h004;
  localparam ADDR_DREQ_EN_CLR     = 'h008;
  localparam ADDR_REQ_ACT         = 'h010;

  localparam DREQ_EN_CH0_BIT         = 0;
  localparam DREQ_EN_CH1_BIT         = 1;
  localparam DREQ_EN_CH2_BIT         = 2;
  localparam DREQ_EN_CH3_BIT         = 3;
  localparam DREQ_EN_CH4_BIT         = 4;

  localparam DREQ_ACT_CH0_BIT         = 0;
  localparam DREQ_ACT_CH1_BIT         = 1;
  localparam DREQ_ACT_CH2_BIT         = 2;
  localparam DREQ_ACT_CH3_BIT         = 3;
  localparam DREQ_ACT_CH4_BIT         = 4;

  logic [DREQ_EN_BIT_MAX:0]  drq_en;
  logic [REQ_ACT_BIT_MAX:0] req_act;

  // Register Declaration
  assign req_act = {req_act_ch4,req_act_ch3,req_act_ch2,req_act_ch1,req_act_ch0};

  // Write Logic
  always_ff @(posedge hclk or negedge hresetn) begin
    if (!hresetn) begin
      drq_en <= {DREQ_EN_REG_WIDTH{1'b0}};
    end else begin
      if (write_en) begin
        case (addr)
          // Set appropriate DMAC Request Register
          ADDR_DREQ_EN:     drq_en <= wdata[DREQ_EN_BIT_MAX:0];
          ADDR_DREQ_EN_SET: drq_en <= drq_en | wdata[DREQ_EN_BIT_MAX:0];
          ADDR_DREQ_EN_CLR: drq_en <= drq_en & wdata[DREQ_EN_BIT_MAX:0];
          default: ;
        endcase
      end
    end
  end

  // Read Logic
  always_comb begin
    rdata = 32'h0bad0bad;
    if (read_en) begin
      case (addr)
        ADDR_DREQ_EN:  rdata = {{(32-DREQ_EN_REG_WIDTH){1'b0}},  drq_en[DREQ_EN_BIT_MAX:0]};
        ADDR_REQ_ACT:  rdata = {{(32-REQ_ACT_REG_WIDTH){1'b0}}, req_act[REQ_ACT_BIT_MAX:0]};
        default: rdata = 32'h0bad0bad;
      endcase
    end
  end

  // DMA Request Output Assignment
  assign drq_ch0 = req_act[0] & drq_en[0];
  assign drq_ch1 = req_act[1] & drq_en[1];
  assign drq_ch2 = req_act[2] & drq_en[2];
  assign drq_ch3 = req_act[3] & drq_en[3];
  assign drq_ch4 = req_act[4] & drq_en[4];

  // Interrupt Request Output Assignment
  assign irq_ch0 = req_act[0] & !drq_en[0];
  assign irq_ch1 = req_act[1] & !drq_en[1];
  assign irq_ch2 = req_act[2] & !drq_en[2];
  assign irq_ch3 = req_act[3] & !drq_en[3];
  assign irq_ch4 = req_act[4] & !drq_en[4];

  assign irq_merged = irq_ch0 | irq_ch1 | irq_ch2 | irq_ch3 | irq_ch4;

endmodule