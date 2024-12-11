// sldma230_udma.v
//-----------------------------------------------------------------------------
// soclabs developed enhancement to accelerate PL230 dma controller
//
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (c) 2022-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
// (C) COPYRIGHT 2006-2017 ARM Limited.
// ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
// File Name  : pl230_udma_plus.v
// Checked In : $Date: 2007-08-09 18:09:38 +0530 (Thu, 09 Aug 2007) $
// Revision   : $Revision: 16613 $
// State      : $state: PL230-DE-98007-r0p0-02rel0 $
//
//------------------------------------------------------------------------------
// Purpose : PL230 Micro DMA Controller top level module
//
//------------------------------------------------------------------------------

`include "pl230_defs.v"

module pl230_udma #(
    parameter NDMACHANS = `PL230_CHNLS
  )
  (  // Clock and Reset
  hclk,
  hresetn,
  // DMA Control
  dma_req,
  dma_sreq,
  dma_waitonreq,
  dma_stall,
  dma_active,
  dma_done,
  dma_err,
//// future additional export status signals
//  x_pl230_master_en,
//  x_pl230_en_chan,
//  x_pl230_fsm_state,
//  x_pl230_ahb_error,
//  x_pl230_chnl_active_early,
  // AHB-Lite Master Interface
  hready,
  hresp,
  hrdata,
  htrans,
  hwrite,
  haddr,
  hsize,
  hburst,
  hmastlock,
  hprot,
  hwdata,
  // APB Slave Interface
  pclken,
  psel,
  pen,
  pwrite,
  paddr,
  pwdata,
  prdata
  );

  //----------------------------------------------------------------------------
  // Port declarations
  //----------------------------------------------------------------------------
  // Clock and Reset
  input                     hclk;                 // AMBA bus clock
  input                     hresetn;              // AMBA bus reset

  // DMA Control
  input  [NDMACHANS-1:0]    dma_req;              // DMA transfer request
  input  [NDMACHANS-1:0]    dma_sreq;             // DMA single transfer request
  input  [NDMACHANS-1:0]    dma_waitonreq;        // DMA wait for request fall
  input                     dma_stall;            // DMA transfer stall
  output [NDMACHANS-1:0]    dma_active;           // DMA transfer active
  output [NDMACHANS-1:0]    dma_done;             // DMA transfer done
  output                    dma_err;              // DMA slave response not OK
//  // simply export status signals
//  output                    x_pl230_master_en;      // export UDMA master enable control
//  output [NDMACHANS-1:0]    x_pl230_en_chan;        // export UDMA enabled channel status
//  output [NDMACHANS-1:0]    x_pl230_chnl_active_early; // export channel number ahead of dma_active
//  output [`PL230_STATE_BITS-1:0] x_pl230_fsm_state; // export the UDMA state
//  output                    x_pl230_ahb_error;      // export access error (not just sticky dma_err)
  // AHB-Lite Master Interface
  input                     hready;               // AHB slave ready
  input                     hresp;                // AHB slave response
  input  [31:0]             hrdata;               // AHB read data
  output [1:0]              htrans;               // AHB transfer enable
  output                    hwrite;               // AHB transfer direction
  output [31:0]             haddr;                // AHB address
  output [2:0]              hsize;                // AHB transfer size
  output [2:0]              hburst;               // AHB burst length
  output                    hmastlock;            // AHB locked access control
  output [3:0]              hprot;                // AHB protection control
  output [31:0]             hwdata;               // AHB write data

  // APB Slave Interface
  input                     pclken;               // APB clock enable
  input                     psel;                 // APB peripheral select
  input                     pen;                  // APB transfer enable
  input                     pwrite;               // APB transfer direction
  input  [11:0]             paddr;                // APB address
  input  [31:0]             pwdata;               // APB write data
  output [31:0]             prdata;               // APB read data

  //----------------------------------------------------------------------------
  // Local signal declarations
  //----------------------------------------------------------------------------
  // Memory Mapped Registers
  //  Controller Configuration Registers
  wire   [31-1-`PL230_CHNL_BITS-2-2:0]
                            ctrl_base_ptr;        // control data base pointer
  wire   [NDMACHANS-1:0] chnl_sw_request;      // channel manual request
  wire   [NDMACHANS-1:0] chnl_useburst_status; // channel use bursts status
  wire   [NDMACHANS-1:0] chnl_req_mask_status; // channel request mask status
  wire   [NDMACHANS-1:0] chnl_enable_status;   // channel enable status
  wire   [NDMACHANS-1:0] chnl_pri_alt_status;  // channel primary/alternate
  wire   [NDMACHANS-1:0] chnl_priority_status; // channel priority status
  //  Integration Registers
  wire   [NDMACHANS-1:0] dma_done_status;      // dma_done output status
  wire   [NDMACHANS-1:0] dma_active_status;    // dma_active output status
  wire                      int_test_en;          // Integration test enable

  // Register Control
  wire                      master_enable;        // master enable
  wire   [`PL230_STATE_BITS-1:0]
                            ctrl_state;           // AHB control state
  wire                      clr_useburst;         // clear chnl_useburst_status
  wire                      set_useburst;         // set chnl_useburst_status
  wire                      toggle_channel;       // toggle current channel
  wire                      disable_channel;      // disable current channel
  wire   [NDMACHANS-1:0] data_current_chnl_onehot;
                                                  // current channel (one hot)
  wire                      slave_err;            // AHB slave response not OK
  wire   [2:0]              chnl_ctrl_hprot3to1;  // AHB protection control

  //----------------------------------------------------------------------------
  //
  // Beginning of main code
  //
  //----------------------------------------------------------------------------

  // APB slave interface memory mapped registers
  pl230_apb_regs u_pl230_apb_regs
  (
    // Clock and Reset
    .hclk                   (hclk),
    .hresetn                (hresetn),
    // APB Slave Interface
    .pclken                 (pclken),
    .psel                   (psel),
    .pen                    (pen),
    .pwrite                 (pwrite),
    .paddr                  (paddr),
    .pwdata                 (pwdata),
    .prdata                 (prdata),
    // Memory Mapped Registers
    //  Controller Configuration Registers
    .dma_waitonreq          (dma_waitonreq),
    .dma_err                (dma_err),
    .ctrl_base_ptr          (ctrl_base_ptr),
    .chnl_sw_request        (chnl_sw_request),
    .chnl_useburst_status   (chnl_useburst_status),
    .chnl_req_mask_status   (chnl_req_mask_status),
    .chnl_enable_status     (chnl_enable_status),
    .chnl_pri_alt_status    (chnl_pri_alt_status),
    .chnl_priority_status   (chnl_priority_status),
    //  Integration Registers
    .dma_stall              (dma_stall),
    .dma_req                (dma_req),
    .dma_sreq               (dma_sreq),
    .dma_done_status        (dma_done_status),
    .dma_active_status      (dma_active_status),
    .int_test_en            (int_test_en),
    // Register Control
    .ctrl_state             (ctrl_state),
    .clr_useburst           (clr_useburst),
    .set_useburst           (set_useburst),
    .toggle_channel         (toggle_channel),
    .disable_channel        (disable_channel),
    .data_current_chnl_onehot
                            (data_current_chnl_onehot),
    .slave_err              (slave_err),
    .master_enable          (master_enable),
    .chnl_ctrl_hprot3to1    (chnl_ctrl_hprot3to1)
  );


  sldma230_ahb_ctrl u_pl230_ahb_ctrl
  (
    // Clock and Reset
    .hclk                   (hclk),
    .hresetn                (hresetn),
    // DMA Control
    .dma_req                (dma_req),
    .dma_sreq               (dma_sreq),
    .dma_waitonreq          (dma_waitonreq),
    .dma_stall              (dma_stall),
    .dma_active             (dma_active),
    .dma_done               (dma_done),
    // AHB-Lite Master Interface
    .hready                 (hready),
    .hresp                  (hresp),
    .hrdata                 (hrdata),
    .htrans                 (htrans),
    .hwrite                 (hwrite),
    .haddr                  (haddr),
    .hsize                  (hsize),
    .hburst                 (hburst),
    .hmastlock              (hmastlock),
    .hprot                  (hprot),
    .hwdata                 (hwdata),
    // Memory Mapped Registers
    //  Controller Configuration Registers
    .ctrl_base_ptr          (ctrl_base_ptr),
    .chnl_sw_request        (chnl_sw_request),
    .chnl_useburst_status   (chnl_useburst_status),
    .chnl_req_mask_status   (chnl_req_mask_status),
    .chnl_enable_status     (chnl_enable_status),
    .chnl_pri_alt_status    (chnl_pri_alt_status),
    .chnl_priority_status   (chnl_priority_status),
    //  Integration Registers
    .dma_done_status        (dma_done_status),
    .dma_active_status      (dma_active_status),
    .int_test_en            (int_test_en),
    // Register Control
    .master_enable          (master_enable),
    .chnl_ctrl_hprot3to1    (chnl_ctrl_hprot3to1),
    .ctrl_state             (ctrl_state),
    .clr_useburst           (clr_useburst),
    .set_useburst           (set_useburst),
    .toggle_channel         (toggle_channel),
    .disable_channel        (disable_channel),
    .data_current_chnl_onehot
                            (data_current_chnl_onehot),
    .x_current_chnl_onehot  ( ), //(x_pl230_chnl_active_early),
    .slave_err              (slave_err)
  );

//  assign x_pl230_fsm_state = ctrl_state;
//  assign x_pl230_ahb_error = slave_err;
//  assign x_pl230_en_chan   = chnl_enable_status;
//  assign x_pl230_master_en = master_enable;
////  assign x_pl230_chnl_active_early = data_current_chnl_onehot;
  
  //----------------------------------------------------------------------------
  // OVL assertions
  //----------------------------------------------------------------------------
`ifdef ASSERT_ON
  `include "std_ovl_defines.h"

  // Configuration Restrictions
  // --------------------------

  // The parameter to define the number of channels to be implemented
  // must be an integer number between 1 and 32
  // ERS C-1 & ARS A43
  // -----------------------
  assert_always #(`OVL_ERROR,`OVL_ASSUME,
    "PL230_E01: The number of channels must be between 1 and NUM_CHNLS")
    pl230_ovl_assume_A43
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr(NDMACHANS > 0 && NDMACHANS < 33)
    );

  // The parameter to define the number bits required to hold the number of
  // channels as a binary number must be an integer number between 0 and 5
  // ARS A44
  assert_always #(`OVL_ERROR,`OVL_ASSUME,
    "PL230_E02: The number of channel bits must be between 0 and NUM_CHNL_BITS")
    pl230_ovl_assume_A44
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr(`PL230_CHNL_BITS >= 0 && `PL230_CHNL_BITS < 6)
    );

  // User-Warnings
  // -------------

  // Only word aligned addresses on the APB slave interface are supported.
  // Byte and half-word aligned accesses will be treated as word.
  // FR W-01
  assert_always  #(`OVL_WARNING,`OVL_ASSERT,
    "PL230_W01: paddr[1:0] is non-zero. Only word aligned accesses supported")
    pl230_ovl_assert_W01
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr(paddr[1:0] == 2'b00 && psel)
    );

  // The channel configuration data (channel_cfg) read from memory is invalid
  // (cycle_ctrl == 3'b000) and will be ignored. The channel will be
  // automatically disabled and do data transfered.
  // FR W-02
  assert_always  #(`OVL_WARNING,`OVL_ASSERT,
    "PL230_W02: cycle_ctrl channel configuration read from memory was zero")
    pl230_ovl_assert_W02
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr(!u_pl230_ahb_ctrl.channel_cfg_load |
        ( u_pl230_ahb_ctrl.channel_cfg_load &
        ( `PL230_HRDATA_CYCLE_CTRL != 3'b000) ) )
    );

  // The channel configuration data (channel_cfg) read from memory has
  // the destination transfer size (dst_size) set to a different value to the
  // source transfer size and will be ignored. When the channel configuration
  // data is updated by the controller destination size will be changed to
  // match the source size.
  // FR W-03
  assert_never #(`OVL_WARNING,`OVL_ASSERT,
    "PL230_W03: dst_size != src_size in channel config read from memory")
    pl230_ovl_assert_W03
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr( u_pl230_ahb_ctrl.channel_cfg_load &
        ( `PL230_HRDATA_SRC_SIZE != `PL230_HRDATA_DST_SIZE ))
    );

  // The channel configuration data (channel_cfg) read from memory has
  // the source address increment (src_inc) set to a value which is less
  // than the source transfer size (src_size). An address increment equal to
  // the source transfer size will be used.
  // FR W-04
  assert_always #(`OVL_WARNING,`OVL_ASSERT,
    "PL230_W04: src_inc value reserved in channel config read from memory")
    pl230_ovl_assert_W04
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr( !u_pl230_ahb_ctrl.channel_cfg_load |
        ((`PL230_HRDATA_SRC_INC != 2'b00) & (`PL230_HRDATA_SRC_SIZE == 2'b01)) |
        ((`PL230_HRDATA_SRC_INC >  2'b01) & (`PL230_HRDATA_SRC_SIZE == 2'b10)) |
        (`PL230_HRDATA_SRC_SIZE == 2'b00))
    );

  // The channel configuration data (channel_cfg) read from memory has
  // the destination address increment (dst_inc) set to a value which is less
  // than the destination transfer size (dst_size). An address increment equal
  // to the destination transfer size will be used.
  // FR W-05
  assert_always #(`OVL_WARNING,`OVL_ASSERT,
    "PL230_W05: dst_inc value reserved in channel config read from memory")
    pl230_ovl_assert_W05
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr( !u_pl230_ahb_ctrl.channel_cfg_load |
        ((`PL230_HRDATA_DST_INC != 2'b00) & (`PL230_HRDATA_SRC_SIZE == 2'b01)) |
        ((`PL230_HRDATA_DST_INC >  2'b01) & (`PL230_HRDATA_SRC_SIZE == 2'b10)) |
        (`PL230_HRDATA_SRC_SIZE == 2'b00))
    );

  // Use of dma_sreq is only supported when dma_waitonreq is asserted. Any
  // activity on the dma_sreq input when dma_waitonreq is de-asserted will not
  // result in a any data being transferred.
  // FR W-06
  assert_never #(`OVL_WARNING,`OVL_ASSERT,
    "PL230_W06: dma_sreq will not start a transfer when dma_waitonreq is low")
    pl230_ovl_assert_W06
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr( |(~dma_waitonreq & dma_sreq) )
    );

  // The number of bits implemented in the memory mapped register ctrl_base_ptr
  // depends on the number of channels implemented. Bits that are not
  // implemented must be written as zero. This limits the base address to be
  // integer multiples of a power of 2 (bytes). If 32 channels are implemented
  // then the base address must be a multiple of 2^10. For upto 16 channels it's
  // a multiple of 2^9, for upto 8 channels it's a multiple of 2^8 and so on
  // down to 1 channel which has to be a multiple of 2^5.
  // FR W-07
  assert_never #(`OVL_WARNING,`OVL_ASSERT,
    "PL230_W07: ctrl_base_ptr bits not implemented should be written as zero")
    pl230_ovl_assert_W07
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr( u_pl230_apb_regs.write_reg &&
        (pwdata[`PL230_CHNL_BITS+4:0] != {`PL230_CHNL_BITS+5{1'b0}}) &&
        (paddr[11:2] == u_pl230_apb_regs.addr_ctrl_base_ptr[11:2]))
    );

  // Generating a software request via the memory mapped register will not
  // start a transfer if the channel is disabled.
  // FR W-08
  assert_never #(`OVL_WARNING,`OVL_ASSERT,
    "PL230_W08: chnl_sw_request asserted on a disabled channel")
    pl230_ovl_assert_W08
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr( |(~chnl_enable_status & chnl_sw_request) )
    );

  // Design Constraints
  // ------------------

  // The AHB master interface only supports transfer types IDLE and NONSEQ.
  // ARS A-25
  assert_never  #(`OVL_ERROR,`OVL_ASSERT,
    "PL230_E03: htrans is not IDLE or NONSEQ")
    pl230_ovl_assert_A25
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr(htrans[0] == 1'b1)
    );

  // The AHB master interface only supports transfer sizes of byte,
  // half-word or word.
  // ARS A-26
  assert_never  #(`OVL_ERROR,`OVL_ASSERT,
    "PL230_E04: hsize is not byte, half-word or word")
    pl230_ovl_assert_A26
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr(hsize > 3)
    );

  // The AHB master interface only supports burst sizes of SINGLE
  // ARS A-27
  assert_always #(`OVL_ERROR,`OVL_ASSERT,
    "PL230_E05: hburst is not 3'b000 to define SINGLE")
    pl230_ovl_assert_A27
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr(hburst == 3'b000)
    );

  // The AHB master interface only supports protection control defined as
  // data access
  // ARS A-28
  assert_always #(`OVL_ERROR,`OVL_ASSERT,
    "PL230_E06: hprot bit 0 is not 1 to define a data access")
    pl230_ovl_assert_A28
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr(hprot[0] == 1'b1)
    );

  // dma_active should only be one-hot encoded or zero
  // ARS A-37
  assert_zero_one_hot #(`OVL_ERROR, NDMACHANS, `OVL_ASSERT,
    "PL230_E07: Only one dma_active signal should be asserted at any time")
    pl230_ovl_assert_A37
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr(dma_active & ~{NDMACHANS{int_test_en}})
    );

  // dma_done should only be one-hot encoded or zero
  // ARS A-38
  assert_zero_one_hot #(`OVL_ERROR, NDMACHANS, `OVL_ASSERT,
    "PL230_E08: Only one dma_done signal should be asserted at any time")
    pl230_ovl_assert_A38
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr(!master_enable & (chnl_enable_status & dma_done) &
        ~{NDMACHANS{int_test_en}})
    );

  // dma_active should correspond to the channel being serviced
  // ARS A-39
  assert_always #(`OVL_ERROR,`OVL_ASSERT,
    "PL230_E09: dma_active does not match the channel being serviced")
    pl230_ovl_assert_A39
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr(int_test_en || (dma_active == 0) ||
        (dma_active == data_current_chnl_onehot)
      )
    );

  // dma_done should correspond to the channel being serviced
  // ARS A-40
  assert_always #(`OVL_ERROR,`OVL_ASSERT,
    "PL230_E10: dma_done does not match the channel being serviced")
    pl230_ovl_assert_A40
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr(!master_enable || int_test_en ||
        ((chnl_enable_status & dma_done) == 0) ||
        ((chnl_enable_status & dma_done) == data_current_chnl_onehot))
    );

  // control phase statemachine is always in a valid state
  // ARS F-18
  assert_never #(`OVL_ERROR,`OVL_ASSERT,
    "PL230_E11: control statemachine is in an invalid state")
    pl230_ovl_assert_F18
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr((u_pl230_ahb_ctrl.ctrl_state == `PL230_ST_RESVD_0) ||
                 (u_pl230_ahb_ctrl.ctrl_state == `PL230_ST_RESVD_1) ||
                 (u_pl230_ahb_ctrl.ctrl_state == `PL230_ST_RESVD_2) ||
                 (u_pl230_ahb_ctrl.ctrl_state == `PL230_ST_RESVD_3) ||
                 (u_pl230_ahb_ctrl.ctrl_state == `PL230_ST_RESVD_4))
    );

  // data phase statemachine is always in a valid state
  // ARS F-19
  assert_never #(`OVL_ERROR,`OVL_ASSERT,
    "PL230_E12: data statemachine is in an invalid state")
    pl230_ovl_assert_F19
    ( .clk(hclk),
      .reset_n(hresetn),
      .test_expr((u_pl230_ahb_ctrl.data_state == `PL230_ST_RESVD_0) ||
                 (u_pl230_ahb_ctrl.data_state == `PL230_ST_RESVD_1) ||
                 (u_pl230_ahb_ctrl.data_state == `PL230_ST_RESVD_2) ||
                 (u_pl230_ahb_ctrl.data_state == `PL230_ST_RESVD_3) ||
                 (u_pl230_ahb_ctrl.data_state == `PL230_ST_RESVD_4))
    );

`endif

endmodule // pl230_udma

`include "pl230_undefs.v"
