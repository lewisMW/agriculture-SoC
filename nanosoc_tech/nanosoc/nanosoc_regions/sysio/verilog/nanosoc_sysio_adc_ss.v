//-----------------------------------------------------------------------------
// NanoSoC APB Subsystem adapted from Arm CMSDK APB Subsystem
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2011 Arm Limited or its affiliates.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Arm Limited or its affiliates.
//
//      SVN Information
//
//      Checked In          : $Date: 2017-10-10 15:55:38 +0100 (Tue, 10 Oct 2017) $
//
//      Revision            : $Revision: 371321 $
//
//      Release Information : Cortex-M System Design Kit-r1p1-00rel0
//
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : APB sub system
//-----------------------------------------------------------------------------
module nanosoc_sysio_adc_ss #(
  // Enable setting for APB extension ports
  // By default, all four extension ports are not used.
  // This can be overriden by parameters at instantiations.
  parameter  ADC_0_ENABLE=0,
  parameter  ADC_1_ENABLE=0,
  parameter  ADC_2_ENABLE=0,
  parameter  ADC_3_ENABLE=0,

  // If peripherals are generated with asynchronous clock domain to HCLK of the processor
  // You might need to add synchroniser to the IRQ signal.
  // In this example APB subsystem, the IRQ synchroniser is used to all peripherals
  // when the INCLUDE_IRQ_SYNCHRONIZER parameter is set to 1. In practice you may have
  // some IRQ signals need to be synchronised and some do not.
  parameter  INCLUDE_IRQ_SYNCHRONIZER=0,


  // By default the APB subsystem include a simple test slave use in ARM for
  // validation purpose.  You can remove this test slave by setting the
  // INCLUDE_APB_TEST_SLAVE paramater to 0,
  parameter  INCLUDE_APB_TEST_SLAVE = 1,

  // Big endian - Add additional endian conversion logic to support big endian.
  //              (for ARM internal testing and evaluation of the processor in
  //              big endian configuration).
  //              0 = little endian, 1 = big endian
  //
  //              The example systems including this APB subsystem are designed as
  //              little endian. Most of the peripherals and memory system are
  //              little endian. This parameter is introduced to allows ARM to
  //              perform system level tests to verified behaviour of bus
  //              components in big endian configuration, and to allow designers
  //              to evaluate the processor in big endian configuration.
  //
  //              Use of this parameter is not recommended for actual product
  //              development as this adds extra hardware. For big endian systems
  //              ideally the peripherals should be modified to use a big endian
  //              programmer's model.
  parameter  BE = 0)
 (
// --------------------------------------------------------------------------
// Port Definitions
// --------------------------------------------------------------------------
  // AHB interface for AHB to APB bridge
  // Peripherals
  // ADC 
`ifdef ADC_0_ENABLE
  electrical      adc_0_in,
`endif
`ifdef ADC_1_ENABLE
  electrical      adc_1_in,
`endif
`ifdef ADC_2_ENABLE
  electrical      adc_2_in,
`endif
`ifdef ADC_3_ENABLE
  electrical      adc_3_in,
`endif
  output wire           i_adc_0_irq,
  output wire           i_adc_1_irq,
  output wire           i_adc_2_irq,
  output wire           i_adc_3_irq,

  input  wire           HCLK,
  input  wire           HRESETn,

  input  wire           HSEL,
  input  wire   [15:0]  HADDR,
  input  wire    [1:0]  HTRANS,
  input  wire           HWRITE,
  input  wire    [2:0]  HSIZE,
  input  wire    [3:0]  HPROT,
  input  wire           HREADY,
  input  wire   [31:0]  HWDATA,
  output wire           HREADYOUT,
  output wire   [31:0]  HRDATA,
  output wire           HRESP,

  input  wire           PCLK,    // Peripheral clock
  input  wire           PCLKG,   // Gate PCLK for bus interface only
  input  wire           PCLKEN,  // Clock divider for AHB to APB bridge
  input  wire           PRESETn // APB reset
  );

  // --------------------------------------------------------------------------
  // Internal wires
  // --------------------------------------------------------------------------
  wire     [15:0]  i_paddr;
  wire             i_psel;
  wire             i_penable;
  wire             i_pwrite;
  wire     [2:0]   i_pprot;
  wire     [3:0]   i_pstrb;
  wire     [31:0]  i_pwdata;

  // wire from APB slave mux to APB bridge
  wire             i_pready_mux;
  wire     [31:0]  i_prdata_mux;
  wire             i_pslverr_mux;

  // Peripheral signals
  wire             adc_0_psel;
  wire     [31:0]  adc_0_prdata;
  wire             adc_0_pready;
  wire             adc_0_pslverr;

  wire             adc_1_psel;
  wire     [31:0]  adc_1_prdata;
  wire             adc_1_pready;
  wire             adc_1_pslverr;

  wire             adc_2_psel;
  wire     [31:0]  adc_2_prdata;
  wire             adc_2_pready;
  wire             adc_2_pslverr;

  wire             adc_3_psel;
  wire     [31:0]  adc_3_prdata;
  wire             adc_3_pready;
  wire             adc_3_pslverr;

  wire             test_slave_psel;
  wire     [31:0]  test_slave_prdata;
  wire             test_slave_pready;
  wire             test_slave_pslverr;

  wire             psel4;
  wire             psel5;
  wire             psel6;
  wire             psel7;
  wire             psel8;
  wire             psel9;
  wire             psel10;
  wire             psel11;
  wire             psel12;
  wire             psel13;
  wire             psel14;
  wire             psel15;

  // Interrupt signals from peripherals
  wire             adc_0_irq;
  wire             adc_1_irq;
  wire             adc_2_irq;
  wire             adc_3_irq;

  // endian handling
  wire             bigendian;
  assign           bigendian = (BE!=0) ? 1'b1 : 1'b0;

  wire   [31:0]    hwdata_le; // Little endian write data
  wire   [31:0]    hrdata_le; // Little endian read data
  wire             reg_be_swap_ctrl_en = HSEL & HTRANS[1] & HREADY & bigendian;
  reg     [1:0]    reg_be_swap_ctrl; // registered byte swap control
  wire    [1:0]    nxt_be_swap_ctrl; // next state of byte swap control

  assign nxt_be_swap_ctrl[1] = bigendian & (HSIZE[1:0]==2'b10); // Swap upper and lower half word
  assign nxt_be_swap_ctrl[0] = bigendian & (HSIZE[1:0]!=2'b00); // Swap byte within hafword

  // Register byte swap control for data phase
  always @(posedge HCLK or negedge HRESETn)
    begin
    if (~HRESETn)
      reg_be_swap_ctrl <= 2'b00;
    else if (reg_be_swap_ctrl_en)
      reg_be_swap_ctrl <= nxt_be_swap_ctrl;
    end

  // swap byte within half word
  wire  [31:0] hwdata_mux_1 = (reg_be_swap_ctrl[0] & bigendian) ?
     {HWDATA[23:16],HWDATA[31:24],HWDATA[7:0],HWDATA[15:8]}:
     {HWDATA[31:24],HWDATA[23:16],HWDATA[15:8],HWDATA[7:0]};
  // swap lower and upper half word
  assign       hwdata_le    = (reg_be_swap_ctrl[1] & bigendian) ?
     {hwdata_mux_1[15: 0],hwdata_mux_1[31:16]}:
     {hwdata_mux_1[31:16],hwdata_mux_1[15:0]};
  // swap byte within half word
  wire  [31:0] hrdata_mux_1 = (reg_be_swap_ctrl[0] & bigendian) ?
     {hrdata_le[23:16],hrdata_le[31:24],hrdata_le[ 7:0],hrdata_le[15:8]}:
     {hrdata_le[31:24],hrdata_le[23:16],hrdata_le[15:8],hrdata_le[7:0]};
  // swap lower and upper half word
  assign       HRDATA       = (reg_be_swap_ctrl[1] & bigendian) ?
     {hrdata_mux_1[15: 0],hrdata_mux_1[31:16]}:
     {hrdata_mux_1[31:16],hrdata_mux_1[15:0]};

  // AHB to APB bus bridge
  cmsdk_ahb_to_apb
  #(.ADDRWIDTH      (16),
    .REGISTER_RDATA (1),
    .REGISTER_WDATA (0))
  u_ahb_to_apb(
    // AHB side
    .HCLK     (HCLK),
    .HRESETn  (HRESETn),
    .HSEL     (HSEL),
    .HADDR    (HADDR[15:0]),
    .HTRANS   (HTRANS),
    .HSIZE    (HSIZE),
    .HPROT    (HPROT),
    .HWRITE   (HWRITE),
    .HREADY   (HREADY),
    .HWDATA   (hwdata_le),

    .HREADYOUT(HREADYOUT), // AHB Outputs
    .HRDATA   (hrdata_le),
    .HRESP    (HRESP),

    .PADDR    (i_paddr[15:0]),
    .PSEL     (i_psel),
    .PENABLE  (i_penable),
    .PSTRB    (i_pstrb),
    .PPROT    (i_pprot),
    .PWRITE   (i_pwrite),
    .PWDATA   (i_pwdata),

    .APBACTIVE(APBACTIVE),
    .PCLKEN   (PCLKEN),     // APB clock enable signal

    .PRDATA   (i_prdata_mux),
    .PREADY   (i_pready_mux),
    .PSLVERR  (i_pslverr_mux)
    );

  // APB slave multiplexer
  cmsdk_apb_slave_mux #( // Parameter to determine which ports are used
    .PORT0_ENABLE  (ADC_0_ENABLE), // ADC 0 APB Port Enable 
    .PORT1_ENABLE  (ADC_1_ENABLE), // ADC 1 APB Port Enable 
    .PORT2_ENABLE  (ADC_2_ENABLE), // ADC 2 APB Port Enable 
    .PORT3_ENABLE  (ADC_3_ENABLE), // ADC 3 APB Port Enable
    .PORT4_ENABLE  (1), // not used 
    .PORT5_ENABLE  (1), // not used 
    .PORT6_ENABLE  (1), // not used 
    .PORT7_ENABLE  (1), // not used
    .PORT8_ENABLE  (1), // not used 
    .PORT9_ENABLE  (1), // not used
    .PORT10_ENABLE (1), // not used
    .PORT11_ENABLE (1), // not used
    .PORT12_ENABLE (1), // not used
    .PORT13_ENABLE (1), // not used
    .PORT14_ENABLE (1), // not used
    .PORT15_ENABLE (1)  // not used
  ) u_apb_slave_mux (
    // Inputs
    .DECODE4BIT        (i_paddr[15:12]),
    .PSEL              (i_psel),
    // PSEL (output) and return status & data (inputs) for each port
    .PSEL0             (adc_0_psel),
    .PREADY0           (adc_0_pready),
    .PRDATA0           (adc_0_prdata),
    .PSLVERR0          (adc_0_pslverr),

    .PSEL1             (adc_1_psel),
    .PREADY1           (adc_1_pready),
    .PRDATA1           (adc_1_prdata),
    .PSLVERR1          (adc_1_pslverr),

    .PSEL2             (adc_2_psel),
    .PREADY2           (adc_2_pready),
    .PRDATA2           (adc_2_prdata),
    .PSLVERR2          (adc_2_pslverr),

    .PSEL3             (adc_3_psel),
    .PREADY3           (adc_3_pready),
    .PRDATA3           (adc_3_prdata),
    .PSLVERR3          (adc_3_pslverr),

    .PSEL4             (psel4),
    .PREADY4           (1'b1),
    .PRDATA4           (32'h00000000),
    .PSLVERR4          (1'b1),

    .PSEL5             (psel5),
    .PREADY5           (1'b1),
    .PRDATA5           (32'h00000000),
    .PSLVERR5          (1'b1),

    .PSEL6             (psel6),
    .PREADY6           (1'b1),
    .PRDATA6           (32'h00000000),
    .PSLVERR6          (1'b1),

    .PSEL7             (psel7),
    .PREADY7           (1'b1),
    .PRDATA7           (32'h00000000),
    .PSLVERR7          (1'b1),

    .PSEL8             (psel8),
    .PREADY8           (1'b1),
    .PRDATA8           (32'h00000000),
    .PSLVERR8          (1'b1),

    .PSEL9             (psel9),
    .PREADY9           (1'b1),
    .PRDATA9           (32'h00000000),
    .PSLVERR9          (1'b1),

    .PSEL10            (psel10),
    .PREADY10          (1'b1),
    .PRDATA10          (32'h00000000),
    .PSLVERR10         (1'b1),

    .PSEL11            (test_slave_psel),
    .PREADY11          (test_slave_pready),
    .PRDATA11          (test_slave_prdata),
    .PSLVERR11         (test_slave_pslverr),

    .PSEL12            (psel12),
    .PREADY12          (1'b1),
    .PRDATA12          (32'h00000000),
    .PSLVERR12         (1'b1),

    .PSEL13            (psel13),
    .PREADY13          (1'b1),
    .PRDATA13          (32'h00000000),
    .PSLVERR13         (1'b1),

    .PSEL14            (psel14),
    .PREADY14          (1'b1),
    .PRDATA14          (32'h00000000),
    .PSLVERR14         (1'b1),

    .PSEL15            (psel15),
    .PREADY15          (1'b1),
    .PRDATA15          (32'h00000000),
    .PSLVERR15         (1'b1),

    // Output
    .PREADY            (i_pready_mux),
    .PRDATA            (i_prdata_mux),
    .PSLVERR           (i_pslverr_mux)
    );

  // -----------------------------------------------------------------
  // Timers

  generate if (ADC_0_ENABLE == 1) begin : gen_adc_0
  soclabs_adc u_adc_0 (
    .PCLK              (PCLK),     // PCLK for timer operation
    .PCLKG             (PCLKG),    // Gated PCLK for bus
    .PRESETn           (PRESETn),  // Reset
    // APB interface inputs
    .PSEL              (adc_0_psel),
    .PADDR             (i_paddr[11:2]),
    .PENABLE           (i_penable),
    .PWRITE            (i_pwrite),
    .PWDATA            (i_pwdata),
      // APB interface outputs
    .PRDATA            (adc_0_prdata),
    .PREADY            (adc_0_pready),
    .PSLVERR           (adc_0_pslverr),

    .EXTIN             (adc_0_in),  // Extenal input
    .ADCINT            (adc_0_irq)     // interrupt output
  );
  end else
  begin : gen_no_adc_0
    assign adc_0_prdata  = {32{1'b0}};
    assign adc_0_pready  = 1'b1;
    assign adc_0_pslverr = 1'b0;
    assign adc_0_irq     = 1'b0;
  end endgenerate


  generate if (ADC_1_ENABLE == 1) begin : gen_adc_1
  soclabs_adc u_adc_1 (
    .PCLK              (PCLK),     // PCLK for timer operation
    .PCLKG             (PCLKG),    // Gated PCLK for bus
    .PRESETn           (PRESETn),  // Reset
    // APB interface inputs
    .PSEL              (adc_1_psel),
    .PADDR             (i_paddr[11:2]),
    .PENABLE           (i_penable),
    .PWRITE            (i_pwrite),
    .PWDATA            (i_pwdata),
      // APB interface outputs
    .PRDATA            (adc_1_prdata),
    .PREADY            (adc_1_pready),
    .PSLVERR           (adc_1_pslverr),

    .EXTIN             (adc_1_in),  // Extenal input
    .ADCINT            (adc_1_irq)     // interrupt output
  );
  end else
  begin : gen_no_adc_1
    assign adc_1_prdata  = {32{1'b0}};
    assign adc_1_pready  = 1'b1;
    assign adc_1_pslverr = 1'b0;
    assign adc_1_irq     = 1'b0;
  end endgenerate


  generate if (ADC_2_ENABLE == 1) begin : gen_adc_2
  soclabs_adc u_adc_2 (
    .PCLK              (PCLK),     // PCLK for timer operation
    .PCLKG             (PCLKG),    // Gated PCLK for bus
    .PRESETn           (PRESETn),  // Reset
    // APB interface inputs
    .PSEL              (adc_2_psel),
    .PADDR             (i_paddr[11:2]),
    .PENABLE           (i_penable),
    .PWRITE            (i_pwrite),
    .PWDATA            (i_pwdata),
      // APB interface outputs
    .PRDATA            (adc_2_prdata),
    .PREADY            (adc_2_pready),
    .PSLVERR           (adc_2_pslverr),

    .EXTIN             (adc_2_in),  // Extenal input
    .ADCINT            (adc_2_irq)     // interrupt output
  );
  end else
  begin : gen_no_adc_2
    assign adc_2_prdata  = {32{1'b0}};
    assign adc_2_pready  = 1'b1;
    assign adc_2_pslverr = 1'b0;
    assign adc_2_irq     = 1'b0;
  end endgenerate


  generate if (ADC_3_ENABLE == 1) begin : gen_adc_3
  soclabs_adc u_adc_3 (
    .PCLK              (PCLK),     // PCLK for timer operation
    .PCLKG             (PCLKG),    // Gated PCLK for bus
    .PRESETn           (PRESETn),  // Reset
    // APB interface inputs
    .PSEL              (adc_3_psel),
    .PADDR             (i_paddr[11:2]),
    .PENABLE           (i_penable),
    .PWRITE            (i_pwrite),
    .PWDATA            (i_pwdata),
      // APB interface outputs
    .PRDATA            (adc_3_prdata),
    .PREADY            (adc_3_pready),
    .PSLVERR           (adc_3_pslverr),

    .EXTIN             (adc_3_in),  // Extenal input
    .ADCINT            (adc_3_irq)     // interrupt output
  );
  end else
  begin : gen_no_adc_3
    assign adc_3_prdata  = {32{1'b0}};
    assign adc_3_pready  = 1'b1;
    assign adc_3_pslverr = 1'b0;
    assign adc_3_irq     = 1'b0;
  end endgenerate

  generate if (INCLUDE_IRQ_SYNCHRONIZER == 0) begin : gen_irq_synchroniser
    // If PCLK is syncrhonous to HCLK, no need to have synchronizers
    assign i_adc_0_irq = adc_0_irq;
    assign i_adc_1_irq = adc_1_irq;
    assign i_adc_2_irq = adc_2_irq;
    assign i_adc_3_irq = adc_3_irq;
  end else
  begin : gen_no_irq_synchroniser
    // If IRQ source are asyncrhonous to HCLK, then we
    // need to add synchronizers to prevent metastability
    // on interrupt signals.
    cmsdk_irq_sync u_irq_sync_0 (
      .RSTn  (HRESETn),
      .CLK   (HCLK),
      .IRQIN (adc_0_irq),
      .IRQOUT(i_adc_0_irq)
      );

    cmsdk_irq_sync u_irq_sync_1 (
      .RSTn  (HRESETn),
      .CLK   (HCLK),
      .IRQIN (adc_1_irq),
      .IRQOUT(i_adc_1_irq)
      );

    cmsdk_irq_sync u_irq_sync_2 (
      .RSTn  (HRESETn),
      .CLK   (HCLK),
      .IRQIN (adc_2_irq),
      .IRQOUT(i_adc_2_irq)
      );

    cmsdk_irq_sync u_irq_sync_3 (
      .RSTn  (HRESETn),
      .CLK   (HCLK),
      .IRQIN (adc_3_irq),
      .IRQOUT(i_adc_3_irq)
      );

  end endgenerate



 `ifdef ARM_APB_ASSERT_ON
   // ------------------------------------------------------------
   // Assertions
   // ------------------------------------------------------------
`include "std_ovl_defines.h"

   // PSEL should be one-hot
   // If this OVL fires - there is an error in the design of the address decoder
   assert_zero_one_hot
     #(`OVL_FATAL,16,`OVL_ASSERT,
       "Only one PSEL input can be activated.")
   u_ovl_psel_one_hot
     (.clk(PCLK), .reset_n(PRESETn),
      .test_expr({adc_0_psel,adc_1_psel,adc_2_psel,adc_3_psel,
                  psel4,psel5,psel6,psel7,psel8,psel9,psel10,psel11,psel12,psel13,psel14,psel15}));


   // All Writes to the APB peripherals must be word size since PSTRB only
   // supported on the APB test slave. Therefore, the AHB bridge can generate
   // non-word sized writes which can break the APB peripherals (not
   // including the the test slave) since they don't support this (i.e. PSTRB
   // is not present). Hence, restrict the appropriate accesses to word sized
   // writes.
   assert_implication
     #(`OVL_ERROR,`OVL_ASSERT,
       "All Writes to the APB peripherals must be word size not including the test slave")
   u_ovl_apb_write_word_size_32bits
     (.clk              (PCLK),
      .reset_n          (PRESETn),
      .antecedent_expr  (i_penable && i_psel && i_pwrite && (~test_slave_psel)),
      .consequent_expr  (i_pstrb == 4'b1111)
      );

  // This protocol checker is placed here and attached to the PCLK and PCLKEN.
  // A note should be made that this means that the value of PCLKEN may not
  // necessarily be the same as the enable term that is gating PCLK to generate
  // PCLKG.
  ApbPC  #(.ADDR_WIDTH                   (16),
           .DATA_WIDTH                   (32),
           .SEL_WIDTH                    (1),
           // OVL instances property_type (0=assert, 1=assume, 2=ignore)
           .MASTER_REQUIREMENT_PROPTYPE  (0),
           .SLAVE_REQUIREMENT_PROPTYPE   (0),

           .PREADY_FUNCTIONAL            (1),
           .PSLVERR_FUNCTIONAL           (1),
           .PPROT_FUNCTIONAL             (1),
           .PSTRB_FUNCTIONAL             (1)
           ) u_ApbPC
    (
     // Inputs
     .PCLK       (PCLK),
     .PRESETn    (PRESETn),
     .PSELx      (i_psel),
     .PPROT      (i_pprot),
     .PSTRB      (i_pstrb),
     .PENABLE    (i_penable),
     .PREADY     (i_pready_mux),
     .PSLVERR    (i_pslverr_mux),
     .PADDR      (i_paddr),
     .PWRITE     (i_pwrite),
     .PWDATA     (i_pwdata),
     .PRDATA     (i_prdata_mux)
     );


`endif

endmodule
