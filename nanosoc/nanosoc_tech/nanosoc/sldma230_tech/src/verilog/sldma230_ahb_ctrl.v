// sldma230_ahb_ctrl.v
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
//-----------------------------------------------------------------------------
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
// File Name  : pl230_ahb_ctrl.v
// Checked In : $Date: 2007-03-15 15:17:04 +0530 (Thu, 15 Mar 2007) $
// Revision   : $Revision: 10866 $
// State      : $state: PL230-DE-98007-r0p0-02rel0 $
//
//-----------------------------------------------------------------------------
// Purpose : AHB master and DMA handshake interface control
//
//-----------------------------------------------------------------------------

`include "pl230_defs.v"

`ifdef PL230_PLUS_PTR_CACHE
`undef  PL230_ST_RESVD_0
`undef  PL230_ST_RESVD_1
`undef  PL230_ST_RESVD_2
`undef  PL230_ST_RESVD_3
`define PL230_ST_XC_INI 4'hB
`define PL230_ST_XC_RDY  4'hC
`define PL230_ST_XR_SDAT 4'hD
`define PL230_ST_XW_DDAT 4'hE
`define PL230_ST_RESVD_0 4'hF
`define PL230_ST_RESVD_1 4'hF
`define PL230_ST_RESVD_2 4'hF
`define PL230_ST_RESVD_3 4'hF
`define PL230_ST_RESVD_4 4'hF
`endif // PL230_PLUS_PTR_CACHE

module sldma230_ahb_ctrl (
  // Clock and Reset
  hclk,
  hresetn,
  // DMA Control
  dma_req,
  dma_sreq,
  dma_waitonreq,
  dma_stall,
  dma_active,
  dma_done,
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
  // Memory Mapped Registers
  //  Controller Configuration Registers
  ctrl_base_ptr,
  chnl_sw_request,
  chnl_useburst_status,
  chnl_req_mask_status,
  chnl_enable_status,
  chnl_pri_alt_status,
  chnl_priority_status,
  //  Integration Registers
  dma_done_status,
  dma_active_status,
  int_test_en,
  // Register Control
  master_enable,
  chnl_ctrl_hprot3to1,
  ctrl_state,
  clr_useburst,
  set_useburst,
  toggle_channel,
  disable_channel,
  data_current_chnl_onehot,
  x_current_chnl_onehot,
  slave_err
  );

  //----------------------------------------------------------------------------
  // Port declarations
  //----------------------------------------------------------------------------
  // Clock and Reset
  input                     hclk;                 // AMBA bus clock
  input                     hresetn;              // AMBA bus reset

  // DMA Control
  input  [`PL230_CHNLS-1:0] dma_req;              // DMA transfer request
  input  [`PL230_CHNLS-1:0] dma_sreq;             // DMA transfer request
  input  [`PL230_CHNLS-1:0] dma_waitonreq;        // DMA request mode
  input                     dma_stall;            // DMA transfer stall
  output [`PL230_CHNLS-1:0] dma_active;           // DMA transfer active
  output [`PL230_CHNLS-1:0] dma_done;             // DMA transfer done

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

  // Memory Mapped Registers
  //  Controller Configuration Registers
  input  [31-1-`PL230_CHNL_BITS-2-2:0]
                            ctrl_base_ptr;        // control data base pointer
  input  [`PL230_CHNLS-1:0] chnl_sw_request;      // channel manual request
  input  [`PL230_CHNLS-1:0] chnl_useburst_status; // channel use bursts status
  input  [`PL230_CHNLS-1:0] chnl_req_mask_status; // channel request mask status
  input  [`PL230_CHNLS-1:0] chnl_enable_status;   // channel enable status
  input  [`PL230_CHNLS-1:0] chnl_pri_alt_status;  // channel primary/alternate
  input  [`PL230_CHNLS-1:0] chnl_priority_status; // channel priority status
  //  Integration Registers
  input  [`PL230_CHNLS-1:0] dma_done_status;      // dma_done output status
  input  [`PL230_CHNLS-1:0] dma_active_status;    // dma_active output status
  input                     int_test_en;          // Integration test enable

  // Register Control
  input                     master_enable;        // master enable
  input  [2:0]              chnl_ctrl_hprot3to1;  // hprot for chnl ctrl access
  output [`PL230_STATE_BITS-1:0]
                            ctrl_state;           // AHB control state
  output                    toggle_channel;       // toggle current channel
  output                    disable_channel;      // disable current channel
  output                    clr_useburst;         // clear chnl_useburst_status
  output                    set_useburst;         // set chnl_useburst_status
  output [`PL230_CHNLS-1:0] data_current_chnl_onehot;
                                                  // current channel (one hot)
  output [`PL230_CHNLS-1:0] x_current_chnl_onehot;
                                                  // early current channel (one hot)
  output                    slave_err;            // AHB slave response not OK

  //----------------------------------------------------------------------------
  // Port signal declarations
  //----------------------------------------------------------------------------
  reg    [1:0]              htrans;               // AHB transfer enable
  reg                       hwrite;               // AHB transfer direction
  reg    [2:0]              hsize;                // AHB transfer size
  reg    [31:0]             haddr;                // AHB address
  reg    [`PL230_CHNLS-1:0] dma_active;           // DMA transfer active
  reg    [`PL230_CHNLS-1:0] dma_done;             // DMA transfer done
`ifdef PL230_ONE_CHNL
  wire   [`PL230_CHNLS-1:0] data_current_chnl_onehot;
                                                  // current channel (one hot)
`else
  reg    [`PL230_CHNLS-1:0] data_current_chnl_onehot;
                                                  // current channel (one hot)
`endif

  //----------------------------------------------------------------------------
  // Local signal declarations
  //----------------------------------------------------------------------------
  // Loop index for generating channel specific logic
  integer                   i,j,k,m,n,p,q,u,v,w,x,y,z;
  // Control which primary request input can generate a request
  reg    [`PL230_CHNLS-1:0] request;
  // Automatic request
  wire                      auto_request;
  // Override R next value
  wire                      override_r_nxt;
  // Override the value of R for single requests
  reg                       override_r;
  // Pending request next value
  reg    [`PL230_CHNLS-1:0] pending_reqs_nxt;
  // Pending request registers
  reg    [`PL230_CHNLS-1:0] pending_reqs;
  // Current request for edge detection
  wire                      req_delay_nxt;
  // Delayed version of the current request for edge detection
  reg                       req_delay;
  // Current channel value enable
  wire                      current_chnl_en;
`ifdef PL230_ONE_CHNL
  // Current channel - one hot encoded
  wire   [`PL230_CHNLS-1:0] current_chnl_onehot;
`else
  // Select which priority level to priority encode
  wire   [`PL230_CHNLS-1:0] current_chnl_sel_pri;
  // Priority encoder input
  reg    [31:0]             priority_ip;
  // Priority encode the pending requests
  reg    [4:0]              priority_enc;
  // Current channel next value
  wire   [`PL230_CHNL_BITS-1:0]
                            current_chnl_nxt;
  // Current channel
  reg    [`PL230_CHNL_BITS-1:0]
                            current_chnl;
  // Current channel - one hot encoded
  reg    [`PL230_CHNLS-1:0] current_chnl_onehot;
  // Hold the index of the current channel being serviced
  reg    [`PL230_CHNL_BITS-1:0]
                            data_current_chnl;
`endif
  // Channel index valid next value
  wire                      current_chnl_valid_nxt;
  // Channel index valid
  reg                       current_chnl_valid;
  // Cycle_ctrl override
  wire   [2:0]              cycle_ctrl_override;
  // Current channel control data next value
  wire   [`PL230_CHANNEL_CFG_BITS-1:0]
                            channel_cfg_nxt;
  // Current channel control data loaded from memory
`ifdef PL230_PLUS_PTR_CACHE
  wire   [`PL230_CHANNEL_CFG_BITS-1:0]
                            channel_cfg;
`else // !PL230_PLUS_PTR_CACHE
  reg    [`PL230_CHANNEL_CFG_BITS-1:0]
                            channel_cfg;
`endif  // Destination address increment
  wire   [1:0]              dst_inc;
  // Destination transfer size
  wire   [1:0]              dst_size;
  // Source address increment
  wire   [1:0]              src_inc;
  // Source transfer size
  wire   [1:0]              src_size;
  // Destination AHB protection control
  wire   [2:0]              dst_prot_ctrl;
  // Source AHB protection control
  wire   [2:0]              src_prot_ctrl;
  // Power of two transactions per request
  wire   [3:0]              r;
  // Set chnl_useburst_status
  wire                      next_useburst;
  // DMA cycle control
  wire   [2:0]              cycle_ctrl;
  // DMA cycle control written back to memory
  wire   [2:0]              cycle_ctrl_writeback;
  // Limit the source size to 32bit on the AHB interface
  wire   [1:0]              src_size_limit;
  // Limit the destination size to 32bit on the AHB interface
  wire   [1:0]              dst_size_limit;
  // Multiplex control, source and destination hprot values
  reg    [2:0]              hprot3to1;
  // 2 to the power of R transfers complete
  wire                      twotor_complete;
  // R forced to zero when dma_sreq is the request source
  wire   [3:0]              r_override;
  // 2 to the power of R
  reg    [`PL230_N_COUNT_BITS-1:0]
                            twotor;
  // 2 to the power of R counter enable
  wire                      twotor_count_en;
  // 2 to the power of R counter next value
  wire   [`PL230_N_COUNT_BITS-1:0]
                            twotor_count_nxt;
  // 2 to the power of R counter - counts down
  reg    [`PL230_N_COUNT_BITS-1:0]
                            twotor_count;
  // N transfers complete enable
  wire                      n_complete_en;
  // N transfers complete next value
  wire                      n_complete_nxt;
  // N transfers complete
  reg                       n_complete;
  // N counter eanble
  wire                      n_count_en;
  // N counter next value
  wire   [`PL230_N_COUNT_BITS-1:0]
                            n_count_nxt;
  // N counter - counts down
`ifdef PL230_PLUS_PTR_CACHE
  wire   [`PL230_N_COUNT_BITS-1:0]
                            n_count;
`else
  reg    [`PL230_N_COUNT_BITS-1:0]
                            n_count;
`endif
  // Channel specific request wait
  reg    [`PL230_CHNLS-1:0] chnl_req_wait;
  // Statemachine request wait
  wire                      req_wait;
  // AHB control phase statemachine next value
  reg    [`PL230_STATE_BITS-1:0]
                            ctrl_state_nxt;
  // AHB control phase statemachine
  reg    [`PL230_STATE_BITS-1:0]
                            ctrl_state;
  // AHB data phase statemachine enable
  wire                      data_state_en;
  // AHB data phase statemachine
  reg    [`PL230_STATE_BITS-1:0]
                            data_state;
  // Initialise signals at the start of a DMA cycle
  wire                      initialise;
  // Load the channnel configuration and the N counter
  wire                      channel_cfg_load;
  // Load the two to the power of R counter
  reg                       twotor_count_load;
  // Decrement counters after a transfer
  wire                      counter_decrement;
  // Data phase statemachine in an AHB transfer state
  wire                      ahb_data_state;
  // Active states of data phase staemachine
  wire                      active_states;
  // Write channel_cfg back to memory
  wire                      channel_cfg_store;
  // Channel stall
  wire                      stall;
  // Channel done
  wire                      done;
  // Disable channel when the last DMA transfer has completed
  wire                      disable_on_done;
  // Disable channel when the channel_cfg data is flagged as invalid
  wire                      disable_on_invalid;
  // Disable the current channel when AHB response is not OK
  wire                      disable_on_slave_err;
  // Source four byte address delayed from source data read address phase
  reg    [1:0]              src_addr;
  // DMA data next value
  wire   [31:0]             dma_data_nxt;
  // DMA data update enable
  wire                      dma_data_en;
  // Byte adjusted DMA data
  reg    [31:0]             dma_data;
  // Hold slave response enable
  wire                      current_slave_err_en;
  // Hold slave response next value
  wire                      current_slave_err_nxt;
  // Hold slave response when not OK until statemachine is idle
  reg                       current_slave_err;
  // Select source or destination transfer size
  wire   [1:0]              mux_size;
  // Select source or destination address increment
  wire   [1:0]              mux_inc;
  // Control for the address offset
  reg    [1:0]              ctrl_offset;
  // Address offset
  reg    [`PL230_N_COUNT_BITS+1:0]
                            addr_offset;
  // Address offset fixed for scatter/gather primary channel
  wire   [`PL230_N_COUNT_BITS+1:0]
                            addr_offset_sg_pri;
  // Channel control data word select
  reg    [1:0]              ctrl_dat_sel;
  // Current channel control data address
  wire   [31:0]             ctrl_dat_addr;
  // Source/Destination end address
  reg    [31:0]             src_dst_end_addr;
  // Calcualted source/destination address
  wire   [31:0]             dma_addr;
  // AHB interface address next value
  wire   [31:0]             haddr_nxt;

`ifdef PL230_PLUS_PTR_CACHE
  reg    [31:0]              xcached_src_end_addr_chnl [0:(`PL230_CHNLS-1)];
  reg    [31:0]              xcached_dst_end_addr_chnl [0:(`PL230_CHNLS-1)];
  reg    [`PL230_CHANNEL_CFG_BITS-1:0] xchannel_cfg_regs[0:(`PL230_CHNLS-1)];
  reg    [(`PL230_CHNLS-1):0] xnot_idle_chnl;
  wire   [`PL230_CHANNEL_CFG_BITS-1:0] xchannel_cfg;
  reg    [`PL230_N_COUNT_BITS-1:0] xn_count_chnl[0:(`PL230_CHNLS-1)];
  wire   [31:0]              xcached_src_end_addr_r;
  wire   [31:0]              xcached_dst_end_addr_r;
  wire                       xcached_src_end_addr_load_en;
  wire                       xcached_dst_end_addr_load_en;
  wire   [(`PL230_CHNLS-1):0] xcached_chnl;
  wire                       xcached_chnl_valid_nxt;
`endif

  //----------------------------------------------------------------------------
  //
  // Beginning of main code
  //
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // Hold Pending Requests
  //----------------------------------------------------------------------------
  // Control which primary request input can generate a request
  always @( dma_req or dma_sreq or dma_waitonreq or chnl_useburst_status )
  begin : p_request
    for ( i = 0; i < `PL230_CHNLS; i=i+1 )
    begin
      request[i] = dma_req[i] ||
                    (dma_sreq[i] &&
                      // Single requests are only used when
                      dma_waitonreq[i] && !chnl_useburst_status[i]);
    end
  end // p_request

  // Automatic request
  assign auto_request = (((cycle_ctrl == 3'b010) &&
                          (twotor_complete && !n_complete)) ||
                         ((cycle_ctrl[2:1] == 2'b10) &&
                          (twotor_complete ||  n_complete))) &&
`ifdef PL230_PLUS_PTR_CACHE
                        ((ctrl_state == `PL230_ST_WR_DDAT) || ((ctrl_state == `PL230_ST_XW_DDAT) && !n_complete_nxt));
`else
                        (ctrl_state == `PL230_ST_WR_DDAT);
`endif

  // Set the use burst request signal when N transfers are complete for
  // Peripheral Scatter/Gather Alternate channel control data
  // This signal takes priority over clr_useburst
  assign set_useburst = n_complete && channel_cfg_store &&
                          next_useburst && (cycle_ctrl == 3'b111);

  // Clear the use burst request signal when less that 2^R transfers remain
  // unless Peripheral Scatter/Gater Primary is completing
  assign clr_useburst = (n_count < twotor) && channel_cfg_store &&
                          (cycle_ctrl != 3'b110);

  // Override R next value
  assign override_r_nxt = |(current_chnl_onehot &
                         ~dma_req & dma_sreq & ~chnl_useburst_status);

  // Override the value of R for single requests
  always @( negedge hresetn or posedge hclk )
  begin : p_override_r
    if ( hresetn == 1'b0 )
      override_r <= 1'b0;
    else
      if ( initialise )
        override_r <= override_r_nxt;
  end // p_override_r

  // Current request for edge detection
  assign req_delay_nxt = initialise ? |(current_chnl_onehot & request)
                                    : |(data_current_chnl_onehot & request);

  // Delayed version of the current request for edge detection
  always @( negedge hresetn or posedge hclk )
  begin : p_req_delay
    if ( hresetn == 1'b0 )
      req_delay <= 1'b0;
    else
      req_delay <= req_delay_nxt;
  end // p_req_delay

  // Pending request control
  always @( master_enable or chnl_enable_status or
            data_current_chnl_onehot or disable_channel or
            current_chnl_onehot or initialise or req_delay or request or
            chnl_req_mask_status or dma_active or stall or
            chnl_sw_request or auto_request or pending_reqs )
  begin : p_pending_reqs_nxt
    for ( j = 0; j < `PL230_CHNLS; j=j+1 )
    begin
      pending_reqs_nxt[j] =
        // If the channel is enabled
        master_enable && chnl_enable_status[j] &&
        // and is not about to be disabled
        !(data_current_chnl_onehot[j] && disable_channel) &&
        // and not cleared by starting a dma cycle
        !(current_chnl_onehot[j] && initialise) &&
        // then hold request
        ( // external request which can be masked
          ( // if request high and not active or stalled
            ((request[j] && !(dma_active[j] ||
               (stall && data_current_chnl_onehot[j]))) ||
             // or request low-high transition when active or stalled
             (!req_delay && request[j] && (dma_active[j] || stall))) &&
             // and the mask is not set
             !chnl_req_mask_status[j] ) ||
          // internal request via memory mapped registers
          chnl_sw_request[j] ||
          // automatic request
          (auto_request && current_chnl_onehot[j]) ||
          // or maintain state
          pending_reqs[j]
        );
    end
  end // p_pending_reqs_nxt

  // Pending requests register
  always @( negedge hresetn or posedge hclk )
  begin : p_pending_reqs
    if ( hresetn == 1'b0 )
      pending_reqs <= {`PL230_CHNLS{1'b0}};
    else
      pending_reqs <= pending_reqs_nxt;
  end // p_pending_reqs

  // Channel specific request wait
  always @( request or dma_waitonreq or current_chnl_onehot )
  begin : p_chnl_req_wait
    for ( k = 0; k < `PL230_CHNLS; k=k+1 )
    begin
      chnl_req_wait[k] = dma_waitonreq[k] && request[k] &&
                           current_chnl_onehot[k];
    end
  end // p_chnl_req_wait

  // Satemachine request wait
  assign req_wait = |chnl_req_wait;

  //----------------------------------------------------------------------------
  // Priority Encode Pending Requests
  //----------------------------------------------------------------------------
`ifdef PL230_ONE_CHNL
  // Current channel one-hot select
  assign current_chnl_onehot = 1'b1;

  // AHB data phase current channel one-hot select
  assign data_current_chnl_onehot = 1'b1;
`else
  // Select which priority level to priority encode
  assign current_chnl_sel_pri = ( |(pending_reqs & chnl_priority_status) )
            ? pending_reqs & chnl_priority_status
            : pending_reqs;

  // Priority encode the pending requests
  // The priority encoder is fixed width but the connections to it
  // depend on the number of channels implemented.
  always @( current_chnl_sel_pri )
  begin : p_priority_enc
    priority_ip = {32{1'b0}};
    priority_ip[`PL230_CHNLS-1:0] = current_chnl_sel_pri;
    priority_enc =
      (priority_ip[0]    ==  1'b1             ) ? 5'h00:
      (priority_ip[1:0]  == {1'b1,     1'b0  }) ? 5'h01:
      (priority_ip[2:0]  == {1'b1,  {2{1'b0}}}) ? 5'h02:
      (priority_ip[3:0]  == {1'b1,  {3{1'b0}}}) ? 5'h03:
      (priority_ip[4:0]  == {1'b1,  {4{1'b0}}}) ? 5'h04:
      (priority_ip[5:0]  == {1'b1,  {5{1'b0}}}) ? 5'h05:
      (priority_ip[6:0]  == {1'b1,  {6{1'b0}}}) ? 5'h06:
      (priority_ip[7:0]  == {1'b1,  {7{1'b0}}}) ? 5'h07:
      (priority_ip[8:0]  == {1'b1,  {8{1'b0}}}) ? 5'h08:
      (priority_ip[9:0]  == {1'b1,  {9{1'b0}}}) ? 5'h09:
      (priority_ip[10:0] == {1'b1, {10{1'b0}}}) ? 5'h0a:
      (priority_ip[11:0] == {1'b1, {11{1'b0}}}) ? 5'h0b:
      (priority_ip[12:0] == {1'b1, {12{1'b0}}}) ? 5'h0c:
      (priority_ip[13:0] == {1'b1, {13{1'b0}}}) ? 5'h0d:
      (priority_ip[14:0] == {1'b1, {14{1'b0}}}) ? 5'h0e:
      (priority_ip[15:0] == {1'b1, {15{1'b0}}}) ? 5'h0f:
      (priority_ip[16:0] == {1'b1, {16{1'b0}}}) ? 5'h10:
      (priority_ip[17:0] == {1'b1, {17{1'b0}}}) ? 5'h11:
      (priority_ip[18:0] == {1'b1, {18{1'b0}}}) ? 5'h12:
      (priority_ip[19:0] == {1'b1, {19{1'b0}}}) ? 5'h13:
      (priority_ip[20:0] == {1'b1, {20{1'b0}}}) ? 5'h14:
      (priority_ip[21:0] == {1'b1, {21{1'b0}}}) ? 5'h15:
      (priority_ip[22:0] == {1'b1, {22{1'b0}}}) ? 5'h16:
      (priority_ip[23:0] == {1'b1, {23{1'b0}}}) ? 5'h17:
      (priority_ip[24:0] == {1'b1, {24{1'b0}}}) ? 5'h18:
      (priority_ip[25:0] == {1'b1, {25{1'b0}}}) ? 5'h19:
      (priority_ip[26:0] == {1'b1, {26{1'b0}}}) ? 5'h1a:
      (priority_ip[27:0] == {1'b1, {27{1'b0}}}) ? 5'h1b:
      (priority_ip[28:0] == {1'b1, {28{1'b0}}}) ? 5'h1c:
      (priority_ip[29:0] == {1'b1, {29{1'b0}}}) ? 5'h1d:
      (priority_ip[30:0] == {1'b1, {30{1'b0}}}) ? 5'h1e:
      (priority_ip[31:0] == {1'b1, {31{1'b0}}}) ? 5'h1f:
                                                  5'h00;
  end // p_priority_enc

  // Current channel next value
  assign current_chnl_nxt = priority_enc[`PL230_CHNL_BITS-1:0];

  // Hold the index of the current channel being serviced
  always @( negedge hresetn or posedge hclk )
  begin : p_current_chnl
    if ( hresetn == 1'b0 )
      current_chnl <= {`PL230_CHNL_BITS{1'b0}};
    else
      if ( current_chnl_en )
        current_chnl <= current_chnl_nxt;
  end // p_current_chnl

  // Convert current channel to a one-hot select
  always @( current_chnl )
  begin : p_current_chnl_onehot
    for ( m = 0; m < `PL230_CHNLS; m=m+1 )
    begin
      current_chnl_onehot[m] = (current_chnl == m);
    end
  end // p_current_chnl_onehot

  // Hold the index of the current channel being serviced
  always @( negedge hresetn or posedge hclk )
  begin : p_data_current_chnl
    if ( hresetn == 1'b0 )
      data_current_chnl <= {`PL230_CHNL_BITS{1'b0}};
    else
      if ( initialise && data_state_en )
        data_current_chnl <= current_chnl;
  end // p_current_chnl

  // Convert the AHB data phase current channel to a one-hot select
  always @( data_current_chnl )
  begin : p_data_current_chnl_onehot
    for ( n = 0; n < `PL230_CHNLS; n=n+1 )
    begin
      data_current_chnl_onehot[n] = (data_current_chnl == n);
    end
  end // p_data_current_chnl_onehot
`endif

  // Current channel update enable
  assign current_chnl_en =
           // Update when idle
           ((ctrl_state == `PL230_ST_IDLE) && !current_chnl_valid) ||
           // or when channel_cfg data was invalid or AHB response is not OK
           disable_on_invalid || disable_on_slave_err ||
           // or when completing 2^R or N transfers
           //   except for Peripheral Scatter/Gather Primary which transitions
           //   to Alternate without arbitration
           (data_state_en && (cycle_ctrl != 3'b110) &&
            ((ctrl_state == `PL230_ST_WR_CTRL) ||
             (ctrl_state == `PL230_ST_STALL) ||
             (ctrl_state == `PL230_ST_DONE))
           );

  // Channel index valid next value
  assign current_chnl_valid_nxt =
                          // Valid if there is a pending request
                          |pending_reqs &&
                          // and the channel is not being disabled
                          !(disable_on_invalid || disable_on_slave_err);

  // Channel index valid
  always @( negedge hresetn or posedge hclk )
  begin : p_current_chnl_valid
    if ( hresetn == 1'b0 )
      current_chnl_valid <= 1'b0;
    else
      if ( current_chnl_en )
        current_chnl_valid <= current_chnl_valid_nxt;
  end // p_current_chnl_valid


  //----------------------------------------------------------------------------
  // Channel active and done
  //----------------------------------------------------------------------------
  // Channel done output
  always @( int_test_en or dma_done_status or
            master_enable or chnl_enable_status or
            data_current_chnl_onehot or done or
            request )
  begin : p_dma_done
    for ( p = 0; p < `PL230_CHNLS; p=p+1 )
    begin
      dma_done[p] = // If integration test logic is enabled
                    ( int_test_en ) ?
                      // drive from test logic
                      dma_done_status[p] :
                    // or the channel is enabled
                    ( master_enable && chnl_enable_status[p] ) ?
                      // decode the done state
                      (data_current_chnl_onehot[p] && done) :
                    // otherwise bypass
                      request[p];
    end
  end // p_dma_done

  // Channel active output
  always @( int_test_en or dma_active_status or
            data_current_chnl_onehot or active_states )
  begin : p_dma_active
    for ( q = 0; q < `PL230_CHNLS; q=q+1 )
    begin
      dma_active[q] = // If integration test logic is enabled
                      ( int_test_en ) ?
                        // drive from test logic
                        dma_active_status[q] :
                        // decode the active states
                        data_current_chnl_onehot[q] && active_states;
    end
  end // p_dma_active

  //----------------------------------------------------------------------------
  // Statemachine
  //----------------------------------------------------------------------------
  // AHB control phase statemachine next value
  always @( ctrl_state or master_enable or current_chnl_valid or cycle_ctrl or
            twotor_complete or n_complete or disable_on_slave_err or
`ifdef PL230_PLUS_PTR_CACHE
            n_complete_nxt or xcached_chnl_valid_nxt or
`endif
            req_wait or dma_stall )
  begin : p_ctrl_state_nxt
    ctrl_state_nxt = ctrl_state;
    case ( ctrl_state )
      `PL230_ST_IDLE:                                // Idle
`ifdef PL230_PLUS_PTR_CACHE
        begin
          if ( master_enable && xcached_chnl_valid_nxt )
            ctrl_state_nxt = `PL230_ST_XC_INI;
          else if ( master_enable && current_chnl_valid )
            ctrl_state_nxt = `PL230_ST_RD_CTRL;
        end
`else // !PL230_PLUS_PTR_CACHE
        begin
          if ( master_enable && current_chnl_valid )
            ctrl_state_nxt = `PL230_ST_RD_CTRL;
        end
`endif
      `PL230_ST_RD_CTRL:                             // Read Chnl Control Data
        ctrl_state_nxt = `PL230_ST_RD_SPTR;
      `PL230_ST_RD_SPTR:                             // Read Source End Pointer
        ctrl_state_nxt = `PL230_ST_RD_DPTR;
      `PL230_ST_RD_DPTR:                             // Read Dest End Pointer
        begin
          if ( cycle_ctrl == 3'b000 || disable_on_slave_err )
            ctrl_state_nxt = `PL230_ST_IDLE;
          else
            ctrl_state_nxt = `PL230_ST_RD_SDAT;
          end
      `PL230_ST_RD_SDAT:                             // Read Source Data
        ctrl_state_nxt = `PL230_ST_WR_DDAT;
      `PL230_ST_WR_DDAT:                             // Write Destination Data
        begin
          if ( twotor_complete || n_complete || disable_on_slave_err )
            begin
              if ( req_wait && (cycle_ctrl != 3'b110))
                ctrl_state_nxt = `PL230_ST_WAIT;
              else
                ctrl_state_nxt = `PL230_ST_WR_CTRL;
            end
          else
`ifdef PL230_PLUS_PTR_CACHE
            ctrl_state_nxt = `PL230_ST_XR_SDAT; // cached continuation
`else
            ctrl_state_nxt = `PL230_ST_RD_SPTR;
`endif
        end
      `PL230_ST_WAIT:                                // Wait for request
        begin
          if ( !req_wait )
            ctrl_state_nxt = `PL230_ST_WR_CTRL;
        end
      `PL230_ST_WR_CTRL:                             // Write Chnl Control Data
        begin
          if ( cycle_ctrl == 3'b110 )
            ctrl_state_nxt = `PL230_ST_PSGP;
          else
            begin
              if ( dma_stall )
                ctrl_state_nxt = `PL230_ST_STALL;
              else
                begin
                  if ( !n_complete || (cycle_ctrl[2] == 1'b1) )
                    ctrl_state_nxt = `PL230_ST_IDLE;
                  else
                    ctrl_state_nxt = `PL230_ST_DONE;
                end
            end
        end
      `PL230_ST_STALL:                               // Stall
        begin
          if ( !dma_stall )
            begin
              if ( !n_complete || (cycle_ctrl[2] == 1'b1) )
                ctrl_state_nxt = `PL230_ST_IDLE;
              else
                ctrl_state_nxt = `PL230_ST_DONE;
            end
        end
      `PL230_ST_DONE:                                // Done
        ctrl_state_nxt = `PL230_ST_IDLE;
      `PL230_ST_PSGP:                                // Periph Scatter/Gather
        ctrl_state_nxt = `PL230_ST_RD_CTRL;

`ifdef PL230_PLUS_PTR_CACHE
      `PL230_ST_XC_INI:                             // address Src End Pointer
        ctrl_state_nxt = `PL230_ST_XC_RDY ;
      `PL230_ST_XC_RDY :                             // address Dst End Pointer
        ctrl_state_nxt = `PL230_ST_XR_SDAT;
      `PL230_ST_XR_SDAT:                             // Read Src Data
        ctrl_state_nxt = `PL230_ST_XW_DDAT;
      `PL230_ST_XW_DDAT:                             // Wite Dst Data
        begin
          if ( twotor_complete || n_complete_nxt || disable_on_slave_err ) // pipelined nxt
            begin
              if ( req_wait && (cycle_ctrl != 3'b110))
                ctrl_state_nxt = `PL230_ST_WAIT;
              else
                ctrl_state_nxt = `PL230_ST_WR_CTRL;
            end
          else
            begin
              ctrl_state_nxt = `PL230_ST_XR_SDAT;
            end
        end
`else
      `PL230_ST_RESVD_0,                             // Reserved States
      `PL230_ST_RESVD_1,
      `PL230_ST_RESVD_2,
      `PL230_ST_RESVD_3,
`endif
      `PL230_ST_RESVD_4:
        ctrl_state_nxt = `PL230_ST_IDLE;
      default:
        ctrl_state_nxt = {`PL230_STATE_BITS{1'bx}};
    endcase
  end

  // AHB control statemachine register
  always @( negedge hresetn or posedge hclk )
  begin : p_ctrl_state
    if ( hresetn == 1'b0 )
      ctrl_state <= {`PL230_STATE_BITS{1'b0}};
    else
      if ( data_state_en )
        ctrl_state <= ctrl_state_nxt;
  end // p_ctrl_state

  // AHB data phase statemachine enable
  assign data_state_en = hready || !ahb_data_state;

  // AHB data phase statemachine register
  always @( negedge hresetn or posedge hclk )
  begin : p_data_state
    if ( hresetn == 1'b0 )
      data_state <= {`PL230_STATE_BITS{1'b0}};
    else
      if ( data_state_en )
        data_state <= ctrl_state;
  end // p_data_state

`ifdef PL230_PLUS_PTR_CACHE
  assign  xcached_src_end_addr_load_en = hready & (data_state == `PL230_ST_RD_SPTR);
  always @( negedge hresetn or posedge hclk )
  begin : p_xcached_src_end_addr_chnl
    if ( hresetn == 1'b0 ) begin
      for ( x = 0; x < `PL230_CHNLS; x=x+1 )
        xcached_src_end_addr_chnl[x] <= {8'he5,{3{3'b000,x[4:0]}}};
    end else
      if ( xcached_src_end_addr_load_en )
        case ( mux_size )
          2'b00:
            xcached_src_end_addr_chnl[current_chnl] <= hrdata;
          2'b01:
            xcached_src_end_addr_chnl[current_chnl] <= {hrdata[31:1], 1'b0};
          2'b10:
            xcached_src_end_addr_chnl[current_chnl] <= {hrdata[31:2], 2'b00};
          2'b11:
            xcached_src_end_addr_chnl[current_chnl] <= {hrdata[31:2], 2'b00};
          default:
            xcached_src_end_addr_chnl[current_chnl] <= {32{1'bx}};
        endcase
  end // p_xcached_src_end_addr_chnl

  assign  xcached_dst_end_addr_load_en = hready & (data_state == `PL230_ST_RD_DPTR);
  always @( negedge hresetn or posedge hclk )
  begin : p_xcached_dst_end_addr_chnl
    if ( hresetn == 1'b0 ) begin
      for ( y = 0; y < `PL230_CHNLS; y=y+1 )
        xcached_dst_end_addr_chnl[y] <= {8'hed,{3{3'b000,y[4:0]}}};
    end else
      if ( xcached_dst_end_addr_load_en )
        case ( mux_size )
          2'b00:
            xcached_dst_end_addr_chnl[current_chnl] <= hrdata;
          2'b01:
            xcached_dst_end_addr_chnl[current_chnl] <= {hrdata[31:1], 1'b0};
          2'b10:
            xcached_dst_end_addr_chnl[current_chnl] <= {hrdata[31:2], 2'b00};
          2'b11:
            xcached_dst_end_addr_chnl[current_chnl] <= {hrdata[31:2], 2'b00};
          default:
            xcached_dst_end_addr_chnl[current_chnl] <= {32{1'bx}};
        endcase
  end // p_xcached_dst_end_addr_chnl

  assign xcached_src_end_addr_r = xcached_src_end_addr_chnl[data_current_chnl];
  assign xcached_dst_end_addr_r = xcached_dst_end_addr_chnl[data_current_chnl];
`endif

  //----------------------------------------------------------------------------
  // Control signals derived from the statemachine
  //----------------------------------------------------------------------------
  // Initialise signals at the start of a DMA cycle
  //   unless a Peripheral Scatter/Gather Primary transfer has just happened
`ifdef PL230_PLUS_PTR_CACHE
  assign initialise = ( ((ctrl_state == `PL230_ST_RD_CTRL)
                       ||(ctrl_state == `PL230_ST_XC_INI) )
                      && (data_state != `PL230_ST_PSGP) );
`else // !PL230_PLUS_PTR_CACHE
  assign initialise = ( (ctrl_state == `PL230_ST_RD_CTRL) &&
                        (data_state != `PL230_ST_PSGP) );
`endif
  // Disable the current channel when done
  assign disable_on_invalid = ( ctrl_state == `PL230_ST_RD_DPTR) &&
                              ( cycle_ctrl == 3'b000 );

  // Channel stall
  assign stall = (ctrl_state == `PL230_ST_STALL);

  // Load the channnel configuration and the N counter
  //  This happens when the control data is valid on hrdata
  assign channel_cfg_load = hready && (data_state == `PL230_ST_RD_CTRL);

`ifdef PL230_PLUS_PTR_CACHE
 // Load the two to the power of R counter
  //  This happens one clock cyle after the channnel configuration is loaded
  //  as the value of R held in channel_cfg is used
  always @( negedge hresetn or posedge hclk )
  begin : p_twotor_count_load
    if ( hresetn == 1'b0 )
      twotor_count_load <= 1'b0;
    else
      twotor_count_load <= channel_cfg_load | channel_cfg_store;
  end // p_twotor_count_load
`else // !PL230_PLUS_PTR_CACHE
 // Load the two to the power of R counter
  //  This happens one clock cyle after the channnel configuration is loaded
  //  as the value of R held in channel_cfg is used
  always @( negedge hresetn or posedge hclk )
  begin : p_twotor_count_load
    if ( hresetn == 1'b0 )
      twotor_count_load <= 1'b0;
    else
      twotor_count_load <= channel_cfg_load;
  end // p_twotor_count_load
`endif

  // Decrement counters after a transfer
`ifdef PL230_PLUS_PTR_CACHE
  assign counter_decrement = hready && ((data_state == `PL230_ST_WR_DDAT) || (data_state == `PL230_ST_XW_DDAT));
`else
  assign counter_decrement = hready && (data_state == `PL230_ST_WR_DDAT);
`endif
  // Data phase statemachine in an AHB transfer state
  assign ahb_data_state =  !((data_state == `PL230_ST_IDLE)  ||
                             (data_state == `PL230_ST_WAIT)  ||
                             (data_state == `PL230_ST_STALL) ||
                             (data_state == `PL230_ST_DONE)  ||
                             (data_state == `PL230_ST_PSGP));

  // Define states when the dma_active signal is asserted
  assign active_states =     (data_state != `PL230_ST_IDLE)  &&
                             (data_state != `PL230_ST_STALL) &&
                             (data_state != `PL230_ST_DONE);

  // Write channel_cfg back to memory
  assign channel_cfg_store = (data_state == `PL230_ST_WR_CTRL);

  // Channel done
  assign done = (data_state == `PL230_ST_DONE);

  // Disable the current channel when done
  assign disable_on_done = done &&
                           ((cycle_ctrl == 3'b001) || (cycle_ctrl == 3'b010));

  // Disable the current channel when the last DMA transfer has completed
  // or when the channel_cfg data is flagged as invalid (cycle_ctrl = 0)
  // or when the slave response is not OK.
  assign disable_channel = disable_on_done ||
                           disable_on_invalid ||
                           disable_on_slave_err;

  // Toggle the chnl_pri_alt_status bit
  assign toggle_channel = counter_decrement &&
                          ((((cycle_ctrl == 3'b011) ||  // Ping-Pong Pri/Alt
                             (cycle_ctrl == 3'b101) ||  // S/G Memory Alt
                             (cycle_ctrl == 3'b111))    // S/G Periph Alt
                             && n_complete) ||          //  only after N
                           (((cycle_ctrl == 3'b100) ||  // S/G Memory Pri
                             (cycle_ctrl == 3'b110)) && // S/G Periph Pri
                             (twotor_complete ||
                              n_complete)));            //  after 2^R or N

  //----------------------------------------------------------------------------
  // AHB data interface
  //----------------------------------------------------------------------------
  // Write Data
  //  The write data is either the updated channel control data or the dma date
  //  to move to the destination address.
  //  The number of transactions remaining is held in the ncount counter so the
  //  channel control data is derived from channel_cfg and ncount.
  assign hwdata = ( channel_cfg_store ) ?
                           {
                             `PL230_CHANNEL_CFG_DST_INC,
                             `PL230_CHANNEL_CFG_DST_SIZE,
                             `PL230_CHANNEL_CFG_SRC_INC,
                             `PL230_CHANNEL_CFG_SRC_SIZE,
                             `PL230_CHANNEL_CFG_DST_PROT_CTRL,
                             `PL230_CHANNEL_CFG_SRC_PROT_CTRL,
                             `PL230_CHANNEL_CFG_R,
                             n_count,
                             `PL230_CHANNEL_CFG_NEXT_USEBURST,
                             cycle_ctrl_writeback
                           } :             // Update channel control data
                           dma_data;       // or write DMA data

  // Override the value of cycle_ctrl if the AHB slave response is not OK.
  assign cycle_ctrl_override = ( slave_err ) ?
                               3'b000 : `PL230_HRDATA_CYCLE_CTRL;

  // Current channel control data next value
  assign channel_cfg_nxt = {
                             `PL230_HRDATA_DST_INC,
                             `PL230_HRDATA_SRC_INC,
                             `PL230_HRDATA_SRC_SIZE,
                             `PL230_HRDATA_DST_PROT_CTRL,
                             `PL230_HRDATA_SRC_PROT_CTRL,
                             `PL230_HRDATA_R,
                             `PL230_HRDATA_NEXT_USEBURST,
                             cycle_ctrl_override
                           };

`ifdef PL230_PLUS_PTR_CACHE
  always @( negedge hresetn or posedge hclk )
  begin : p_xchannel_cfg
    if ( hresetn == 1'b0 ) begin
      for ( z = 0; z < `PL230_CHNLS; z=z+1 ) begin
        xchannel_cfg_regs[z] <= {`PL230_CHANNEL_CFG_BITS{1'b0}};
        xnot_idle_chnl[z] <= 1'b0;
      end
    end else
      if ( channel_cfg_load ) begin
        xchannel_cfg_regs[current_chnl] <= channel_cfg_nxt;
        xnot_idle_chnl[z] <= (channel_cfg_nxt[2:0] != 3'b000);
      end
  end // p_channel_cfg

  assign xchannel_cfg = xchannel_cfg_regs[data_current_chnl];

  assign channel_cfg = xchannel_cfg;

`else

  // Current channel control data loaded from memory
  always @( negedge hresetn or posedge hclk )
  begin : p_channel_cfg
    if ( hresetn == 1'b0 )
      channel_cfg <= {`PL230_CHANNEL_CFG_BITS{1'b0}};
    else
      if ( channel_cfg_load )
        channel_cfg <= channel_cfg_nxt;
  end // p_channel_cfg
`endif

  // Source address lower two bits
  always @( negedge hresetn or posedge hclk )
  begin : p_src_addr
    if ( hresetn == 1'b0 )
      src_addr <= 2'b00;
    else
      if ( hready )
        src_addr <= haddr[1:0];
  end // p_src_addr

  // Byte Lane Multiplex
  pl230_dma_data upl230_dma_data
  (
    // DMA Data Control
    .src_size               (src_size),
    .src_addr               (src_addr),
    // DMA Source Data
    .hrdata                 (hrdata),

    // DMA Destination Data
    .dma_data_nxt           (dma_data_nxt)
  );

  // DMA data enable
`ifdef PL230_PLUS_PTR_CACHE
  assign dma_data_en = hready && ((data_state == `PL230_ST_RD_SDAT) || (data_state == `PL230_ST_XR_SDAT));
`else // !PL230_PLUS_PTR_CACHE
  assign dma_data_en = hready && (data_state == `PL230_ST_RD_SDAT);
`endif

  // DMA data buffer
  always @( negedge hresetn or posedge hclk )
  begin : p_dma_data
    if ( hresetn == 1'b0 )
      dma_data <= 32'h0000_0000;
    else
      if ( dma_data_en )
        dma_data <= dma_data_nxt;
  end // p_dma_data

  // AHB slave response not OK
  assign slave_err = ahb_data_state && hready && hresp;

  // Hold slave response enable
  assign current_slave_err_en = slave_err || (data_state == `PL230_ST_IDLE);

  // Hold slave response next value
  assign current_slave_err_nxt = slave_err;

  // Hold slave response when not OK until statemachine is idle
  always @( negedge hresetn or posedge hclk )
  begin : p_current_slave_err
    if ( hresetn == 1'b0 )
      current_slave_err <= 1'b0;
    else
      if ( current_slave_err_en )
        current_slave_err <= current_slave_err_nxt;
  end // p_current_slave_err

  // Disable the current channel when AHB response is not OK
  assign disable_on_slave_err = current_slave_err || slave_err;

  //----------------------------------------------------------------------------
  // Decode channel control data
  //----------------------------------------------------------------------------
  // The control data for the current channel being serviced is held in
  // channel_cfg.
  //  Destination address increment
  assign dst_inc       = `PL230_CHANNEL_CFG_DST_INC;
  //  Destination transfer size
  assign dst_size      = `PL230_CHANNEL_CFG_DST_SIZE;
  //  Source address increment
  assign src_inc       = `PL230_CHANNEL_CFG_SRC_INC;
  //  Source transfer size
  assign src_size      = `PL230_CHANNEL_CFG_SRC_SIZE;
  //  Destination AHB protection control
  assign dst_prot_ctrl = `PL230_CHANNEL_CFG_DST_PROT_CTRL;
  //  Source AHB protection control
  assign src_prot_ctrl = `PL230_CHANNEL_CFG_SRC_PROT_CTRL;
  //  Power of two transactions per request
  assign r             = `PL230_CHANNEL_CFG_R;
  //  Number of transactions remaining
  //   This is not held in the channel_cfg register as the decremented value is
  //   written back to memory. So the n_count counter is loaded at the same time
  //   as channel_cfg is loaded.
  //  Set chnl_useburst_status
  //   Used for Peripheral Scatter/Gather Alternate DMA cycles
  assign next_useburst = `PL230_CHANNEL_CFG_NEXT_USEBURST;
  //  DMA cycle control
  assign cycle_ctrl    = `PL230_CHANNEL_CFG_CYCLE_CTRL;
  //  DMA cycle control written back to memory
  //  When N transfers are complete it is set to 0 to indicate that channel_cfg
  //  is no longer valid.
  assign cycle_ctrl_writeback = (n_complete) ? 3'b000 :
                                   `PL230_CHANNEL_CFG_CYCLE_CTRL;

  //----------------------------------------------------------------------------
  // AHB Control Interface Definitions
  //----------------------------------------------------------------------------
  // Limit the source size to 32bit on the AHB interface
  assign src_size_limit = (src_size == 2'b11) ? 2'b10 : src_size;
  // Limit the destination size to 32bit on the AHB interface
  assign dst_size_limit = (dst_size == 2'b11) ? 2'b10 : dst_size;

  // htrans, hwrite, hsize and hprot3to1 definition
  //  htrans bit 0 is always assigned to zero
  //  as only Idle and Non-sequential transfers are supported
  always @( ctrl_state or chnl_ctrl_hprot3to1 or
            src_size_limit or src_prot_ctrl or
            dst_size_limit or dst_prot_ctrl )
  begin : p_ahb_ctrl
    case (ctrl_state)
      `PL230_ST_IDLE,
      `PL230_ST_PSGP,
      `PL230_ST_WAIT,
      `PL230_ST_STALL,
`ifdef PL230_PLUS_PTR_CACHE
      `PL230_ST_XC_INI,
      `PL230_ST_XC_RDY ,
`endif
      `PL230_ST_DONE:
        begin
          htrans    = `PL230_AHB_TRANS_IDLE;
          hwrite    = `PL230_AHB_READ;
          hsize     = `PL230_AHB_SIZE_WORD;
          hprot3to1 = chnl_ctrl_hprot3to1;
        end
      `PL230_ST_RD_CTRL,
      `PL230_ST_RD_SPTR,
      `PL230_ST_RD_DPTR:
        begin
          htrans    = `PL230_AHB_TRANS_NONSEQ;
          hwrite    = `PL230_AHB_READ;
          hsize     = `PL230_AHB_SIZE_WORD;
          hprot3to1 = chnl_ctrl_hprot3to1;
        end
      `PL230_ST_RD_SDAT:
        begin
          htrans    = `PL230_AHB_TRANS_NONSEQ;
          hwrite    = `PL230_AHB_READ;
          hsize     = {1'b0, src_size_limit};
          hprot3to1 = src_prot_ctrl;
        end
      `PL230_ST_WR_DDAT:
        begin
          htrans    = `PL230_AHB_TRANS_NONSEQ;
          hwrite    = `PL230_AHB_WRITE;
          hsize     = {1'b0, dst_size_limit};
          hprot3to1 = dst_prot_ctrl;
        end
      `PL230_ST_WR_CTRL:
        begin
          htrans    = `PL230_AHB_TRANS_NONSEQ;
          hwrite    = `PL230_AHB_WRITE;
          hsize     = `PL230_AHB_SIZE_WORD;
          hprot3to1 = chnl_ctrl_hprot3to1;
        end
`ifdef PL230_PLUS_PTR_CACHE
      `PL230_ST_XR_SDAT:
        begin
          htrans    = `PL230_AHB_TRANS_NONSEQ;
          hwrite    = `PL230_AHB_READ;
          hsize     = {1'b0, src_size_limit};
          hprot3to1 = src_prot_ctrl;
        end
      `PL230_ST_XW_DDAT:
        begin
          htrans    = `PL230_AHB_TRANS_NONSEQ;
          hwrite    = `PL230_AHB_WRITE;
          hsize     = {1'b0, dst_size_limit};
          hprot3to1 = dst_prot_ctrl;
        end
`else
      `PL230_ST_RESVD_0,
      `PL230_ST_RESVD_1,
      `PL230_ST_RESVD_2,
      `PL230_ST_RESVD_3,
`endif
      `PL230_ST_RESVD_4:
        begin
          htrans    = `PL230_AHB_TRANS_IDLE;
          hwrite    = `PL230_AHB_READ;
          hsize     = `PL230_AHB_SIZE_WORD;
          hprot3to1 = chnl_ctrl_hprot3to1;
        end
      default:
        begin
          htrans    = 2'bxx;
          hwrite    = 1'bx;
          hsize     = 3'bxxx;
          hprot3to1 = 3'bxxx;
        end
    endcase
  end // p_ahb_ctrl

  // AHB interface protection control
  //  The lsb selects data or opcode fetch
  //  AHB accesses are always classed as data
  assign hprot = {hprot3to1, 1'b1};
  // AHB interface burst length
  //  Only single transactions are supported
  assign hburst = 3'b000;
  // AHB locked access control
  //  Locked accesses are not supported
  assign hmastlock = 1'b0;

  //----------------------------------------------------------------------------
  // Address Calculation
  //----------------------------------------------------------------------------
  // Select source or destination transfer size
  // This is done one cycle ahead of the actual AHB address phase
`ifdef PL230_PLUS_PTR_CACHE
  assign mux_size = ((ctrl_state == `PL230_ST_RD_SDAT) || (ctrl_state == `PL230_ST_XR_SDAT)) ? dst_size : src_size;
`else
  assign mux_size = (ctrl_state == `PL230_ST_RD_SDAT) ? dst_size : src_size;
`endif
  // Select source or destination address increment
  // This is done one cycle ahead of the actual AHB address phase
`ifdef PL230_PLUS_PTR_CACHE
  assign mux_inc  = ((ctrl_state == `PL230_ST_RD_SDAT) || (ctrl_state == `PL230_ST_XR_SDAT)) ? dst_inc  : src_inc;
`else
  assign mux_inc  = (ctrl_state == `PL230_ST_RD_SDAT) ? dst_inc  : src_inc;
`endif

  // Control for the address offset
  always @( mux_size or mux_inc )
  begin : p_ctrl_offset
    case ( mux_size )
      `PL230_SIZE_BYTE:
      begin
        case ( mux_inc )
          2'b00: ctrl_offset = 2'b00;
          2'b01: ctrl_offset = 2'b01;
          2'b10: ctrl_offset = 2'b10;
          2'b11: ctrl_offset = 2'b11;
          default: ctrl_offset = 2'bxx;
        endcase
      end
      `PL230_SIZE_HWORD:
      begin
        case ( mux_inc )
          2'b00: ctrl_offset = 2'b01;
          2'b01: ctrl_offset = 2'b01;
          2'b10: ctrl_offset = 2'b10;
          2'b11: ctrl_offset = 2'b11;
          default: ctrl_offset = 2'bxx;
        endcase
      end
      `PL230_SIZE_WORD:
      begin
        case ( mux_inc )
          2'b00: ctrl_offset = 2'b10;
          2'b01: ctrl_offset = 2'b10;
          2'b10: ctrl_offset = 2'b10;
          2'b11: ctrl_offset = 2'b11;
          default: ctrl_offset = 2'bxx;
        endcase
      end
      `PL230_SIZE_RESVD:
      begin
        case ( mux_inc )
          2'b00: ctrl_offset = 2'b10;
          2'b01: ctrl_offset = 2'b10;
          2'b10: ctrl_offset = 2'b10;
          2'b11: ctrl_offset = 2'b11;
          default: ctrl_offset = 2'bxx;
        endcase
      end
      default:
        ctrl_offset = 2'bxx;
    endcase
  end // p_ctrl_offset

  // Address offset
  always @( ctrl_offset or n_count )
  begin : p_addr_offset
    case ( ctrl_offset )
      2'b00:                             // Address offset - byte
        addr_offset = {2'b00, n_count};
      2'b01:                             // Address offset - halfword
        addr_offset = {1'b0, n_count, 1'b0};
      2'b10:                             // Address offset - word
        addr_offset = {n_count, 2'b00};
      2'b11:                             // Address offset - fixed address
        addr_offset = {`PL230_N_COUNT_BITS+2{1'b0}};
      default:
        addr_offset = {`PL230_N_COUNT_BITS+2{1'bx}};
    endcase
  end // p_addr_offset

  // Address offset fixed for scatter/gather primary channel
  assign addr_offset_sg_pri =
           // If using primary control data for scatter gather
           (((cycle_ctrl == 3'b100) || (cycle_ctrl == 3'b110)) &&
           // and the destination address is being calculated
`ifdef PL230_PLUS_PTR_CACHE
           ((ctrl_state == `PL230_ST_RD_SDAT) || (ctrl_state == `PL230_ST_XR_SDAT)) )
`else // !PL230_PLUS_PTR_CACHE
           (ctrl_state == `PL230_ST_RD_SDAT))
`endif
           // only use two bits of N as the same four alternate control data
           // locations must be written to multiple times
           ? {{`PL230_N_COUNT_BITS-2{1'b0}}, n_count[1:0], 2'b00}
           // otherwise use the full address offset
           : addr_offset;

  // Source/Destination end address
  //  Lower bits are masked for word and half-word transfers
  //  to stop the user causing unaligned transfer addresses
  always @( mux_size or hrdata )
  begin : p_src_dst_end_addr
    case ( mux_size )
      2'b00:
        src_dst_end_addr = hrdata;
      2'b01:
        src_dst_end_addr = {hrdata[31:1], 1'b0};
      2'b10:
        src_dst_end_addr = {hrdata[31:2], 2'b00};
      2'b11:
        src_dst_end_addr = {hrdata[31:2], 2'b00};
      default:
        src_dst_end_addr = {32{1'bx}};
    endcase
  end // p_src_dst_end_addr

`ifdef PL230_PLUS_PTR_CACHE
  reg [31:0] xcached_src_end_addr_adj32;
  always @( src_size or xcached_src_end_addr_r)
  begin : p_xcached_src_end_addr_adj32
    case ( src_size )
      2'b00:
        xcached_src_end_addr_adj32 = {(xcached_src_end_addr_r[31:0] + 32'h00000001)};
      2'b01:
        xcached_src_end_addr_adj32 = {(xcached_src_end_addr_r[31:1] + 31'h00000001),1'b0};
      2'b10:
        xcached_src_end_addr_adj32 = {(xcached_src_end_addr_r[31:2] + 30'h00000001),2'b00};
      2'b11:
        xcached_src_end_addr_adj32 = {(xcached_src_end_addr_r[31:2] + 30'h00000001),2'b00};
      default:
        xcached_src_end_addr_adj32 = {32{1'bx}};
    endcase
  end // p_xcached_src_end_addr_adj32
  reg [31:0] xcached_src_end_addr_fix;
  always @( src_size or xcached_src_end_addr_r or xcached_src_end_addr_adj32 or src_inc)
  begin : p_xcached_src_end_addr_fix
    case ( src_size )
      2'b00:
        xcached_src_end_addr_fix = (src_inc == 2'b11) ? xcached_src_end_addr_r : xcached_src_end_addr_adj32;
      2'b01:
        xcached_src_end_addr_fix = (src_inc == 2'b11) ? {xcached_src_end_addr_r[31:1],1'b0} : xcached_src_end_addr_adj32;
      2'b10:
        xcached_src_end_addr_fix = xcached_src_end_addr_adj32;
      2'b11:
        xcached_src_end_addr_fix = xcached_src_end_addr_adj32;
      default:
        xcached_src_end_addr_fix = {32{1'bx}};
    endcase
  end // p_xcached_src_end_addr_fix

  reg [31:0] xcached_dst_end_addr_adj32;
  always @( dst_size or xcached_dst_end_addr_r)
  begin : p_xcached_dst_end_addr_adj32
    case ( dst_size )
      2'b00:
        xcached_dst_end_addr_adj32 = {(xcached_dst_end_addr_r[31:0] + 32'h00000001)};
      2'b01:
        xcached_dst_end_addr_adj32 = {(xcached_dst_end_addr_r[31:1] + 31'h00000001),1'b0};
      2'b10:
        xcached_dst_end_addr_adj32 = {(xcached_dst_end_addr_r[31:2] + 30'h00000001),2'b00};
      2'b11:
        xcached_dst_end_addr_adj32 = {(xcached_dst_end_addr_r[31:2] + 30'h00000001),2'b00};
      default:
        xcached_dst_end_addr_adj32 = {32{1'bx}};
    endcase
  end // p_xcached_dst_end_addr_adj32
  reg [31:0] xcached_dst_end_addr_fix;
  always @( dst_size or xcached_dst_end_addr_r or xcached_dst_end_addr_adj32 or dst_inc)
  begin : p_xcached_dst_end_addr_fix
    case ( dst_size )
      2'b00:
        xcached_dst_end_addr_fix = (dst_inc == 2'b11) ? xcached_dst_end_addr_r : xcached_dst_end_addr_adj32;
      2'b01:
        xcached_dst_end_addr_fix = (dst_inc == 2'b11) ? {xcached_dst_end_addr_r[31:1],1'b0} : xcached_dst_end_addr_adj32;
      2'b10:
        xcached_dst_end_addr_fix = xcached_dst_end_addr_adj32;
      2'b11:
        xcached_dst_end_addr_fix = xcached_dst_end_addr_adj32;
      default:
        xcached_dst_end_addr_fix = {32{1'bx}};
    endcase
  end // p_xcached_dst_end_addr_fix
 
  wire [31:0] xcached_dma_addr_fix = ((ctrl_state_nxt == `PL230_ST_XR_SDAT) && (data_state == `PL230_ST_RD_SDAT)) ? xcached_src_end_addr_fix
                                   : ((ctrl_state_nxt == `PL230_ST_XW_DDAT) && (data_state == `PL230_ST_WR_DDAT)) ? xcached_dst_end_addr_fix
                                   : ((ctrl_state_nxt == `PL230_ST_XR_SDAT) && (data_state != `PL230_ST_XR_SDAT)) ? xcached_src_end_addr_r
                                   : ((ctrl_state_nxt == `PL230_ST_XR_SDAT) && (data_state == `PL230_ST_XR_SDAT)) ? xcached_src_end_addr_fix
                                   : ((ctrl_state_nxt == `PL230_ST_XW_DDAT) && (data_state != `PL230_ST_XW_DDAT)) ? xcached_dst_end_addr_r
                                   : ((ctrl_state_nxt == `PL230_ST_XW_DDAT) && (data_state == `PL230_ST_XW_DDAT)) ? xcached_dst_end_addr_fix
                                   : src_dst_end_addr;
 
  assign dma_addr = xcached_dma_addr_fix -
                      {{32-`PL230_N_COUNT_BITS-2{1'b0}}, addr_offset_sg_pri};
`else
  // DMA data address calculation for source and destination
  assign dma_addr = src_dst_end_addr -
                      {{32-`PL230_N_COUNT_BITS-2{1'b0}}, addr_offset_sg_pri};
`endif

  // Channel control data select
  always @( ctrl_state_nxt )
  begin : p_ctrl_dat_sel
    case (ctrl_state_nxt)
      `PL230_ST_RD_CTRL:
        ctrl_dat_sel = 2'b10;
      `PL230_ST_RD_SPTR:
        ctrl_dat_sel = 2'b00;
      `PL230_ST_RD_DPTR:
        ctrl_dat_sel = 2'b01;
      `PL230_ST_WR_CTRL:
        ctrl_dat_sel = 2'b10;
      `PL230_ST_IDLE,
      `PL230_ST_RD_SDAT,
      `PL230_ST_WR_DDAT,
      `PL230_ST_WAIT,
      `PL230_ST_STALL,
      `PL230_ST_DONE,
      `PL230_ST_PSGP,
`ifdef PL230_PLUS_PTR_CACHE
      `PL230_ST_XC_INI,
      `PL230_ST_XC_RDY,
      `PL230_ST_XR_SDAT,
      `PL230_ST_XW_DDAT,
`else
      `PL230_ST_RESVD_0,
      `PL230_ST_RESVD_1,
      `PL230_ST_RESVD_2,
      `PL230_ST_RESVD_3,
`endif
      `PL230_ST_RESVD_4:
        ctrl_dat_sel = 2'b10;
      default:
        ctrl_dat_sel = 2'bxx;
    endcase
  end // p_ctrl_dat_sel

  // Channel control data address calculation
  assign ctrl_dat_addr = {ctrl_base_ptr,
                          |(chnl_pri_alt_status & current_chnl_onehot),
`ifdef PL230_ONE_CHNL
`else
                          current_chnl,
`endif
                          ctrl_dat_sel,
                          2'b00};

  // AHB interface address next value
`ifdef PL230_PLUS_PTR_CACHE
  assign haddr_nxt = (     (data_state == `PL230_ST_RD_SPTR)
                       || ((data_state == `PL230_ST_RD_DPTR) && (cycle_ctrl != 3'b000))
                       || ((ctrl_state_nxt == `PL230_ST_XR_SDAT))
                       || ((ctrl_state_nxt == `PL230_ST_XW_DDAT))
                     )
                     ? dma_addr
                     : ctrl_dat_addr;
`else
  assign haddr_nxt = ((data_state == `PL230_ST_RD_SPTR) ||
                      ((data_state == `PL230_ST_RD_DPTR) &&
                       (cycle_ctrl != 3'b000)))
                     ? dma_addr
                     : ctrl_dat_addr;
`endif

  // AHB interface address
  always @( negedge hresetn or posedge hclk )
  begin : p_haddr
    if ( hresetn == 1'b0 )
      haddr <= 32'h0000_0000;
    else
      if ( data_state_en )
        haddr <= haddr_nxt;
  end // p_haddr

  //----------------------------------------------------------------------------
  // Two to the power of R counter
  //----------------------------------------------------------------------------
  // 2^R transfers complete
  assign twotor_complete = (twotor_count == {`PL230_N_COUNT_BITS{1'b0}});

  // R forced to zero when dma_sreq is the request source
  //   except for Peripheral Scatter/Gather Primary
  assign r_override = ( override_r && (cycle_ctrl != 3'b110) ) ? 4'b0000 : r;

  // Power of 2 calculation using R in the channel_cfg register
  always @( r_override )
  begin : p_twotor
    case ( r_override )
      4'b0000: twotor = 10'h000;
      4'b0001: twotor = 10'h001;
      4'b0010: twotor = 10'h003;
      4'b0011: twotor = 10'h007;
      4'b0100: twotor = 10'h00f;
      4'b0101: twotor = 10'h01f;
      4'b0110: twotor = 10'h03f;
      4'b0111: twotor = 10'h07f;
      4'b1000: twotor = 10'h0ff;
      4'b1001: twotor = 10'h1ff;
      4'b1010,
      4'b1011,
      4'b1100,
      4'b1101,
      4'b1110,
      4'b1111: twotor = 10'h3ff;
      default: twotor = 10'hxxx;
    endcase
  end // p_twotor

  // 2^R counter enable
  assign twotor_count_en  = twotor_count_load ||             // Load
                            (counter_decrement &&            // Decrement
                              !twotor_complete);

  // 2^R counter load
  assign twotor_count_nxt = twotor_count_load
                            ? twotor                         // Load
                            : twotor_count - {{`PL230_N_COUNT_BITS-1{1'b0}},1'b1};              // Decrement

  // 2^R counter
  always @( negedge hresetn or posedge hclk )
  begin : p_twotor_count
    if ( hresetn == 1'b0 )
      twotor_count <= {`PL230_N_COUNT_BITS{1'b0}};
    else
      if ( twotor_count_en )
        twotor_count <= twotor_count_nxt;
  end // p_twotor_count

  //----------------------------------------------------------------------------
  // N counter
  //----------------------------------------------------------------------------
  // N transfers complete enable
`ifdef PL230_PLUS_PTR_CACHE
  assign n_complete_en  = hready &
                          ((data_state == `PL230_ST_RD_SPTR)
                          || (data_state == `PL230_ST_XR_SDAT)
                          );
`else
  assign n_complete_en  = hready && (data_state == `PL230_ST_RD_SPTR);
`endif
  // N transfers complete next value
  assign n_complete_nxt = (n_count == {`PL230_N_COUNT_BITS{1'b0}});

  // N transfers complete
  always @( negedge hresetn or posedge hclk )
  begin : p_n_complete
    if ( hresetn == 1'b0 )
      n_complete <= 1'b0;
    else
      if ( n_complete_en )
        n_complete <= n_complete_nxt;
  end // p_n_complete

  // N counter enable
  assign n_count_en = channel_cfg_load ||                    // Load
                      (counter_decrement &&                  // Decrement
                        !n_complete && !disable_on_slave_err);

  // N counter load
  assign n_count_nxt = channel_cfg_load
                       ? hrdata[`PL230_N_COUNT_BITS-1+`PL230_N_COUNT_OFFSET
                                :`PL230_N_COUNT_OFFSET]           // Load
                       : n_count - {{`PL230_N_COUNT_BITS-1{1'b0}},1'b1}; // Decrement

  // N counter
`ifdef PL230_PLUS_PTR_CACHE
  reg [(`PL230_CHNLS-1):0] xnzero_chnl;
  always @( negedge hresetn or posedge hclk )
  begin : p_xn_count
    if ( hresetn == 1'b0 ) begin
      for ( u = 0; u < `PL230_CHNLS; u=u+1 ) begin
        xn_count_chnl[u] <= {`PL230_N_COUNT_BITS{1'b0}};
        xnzero_chnl[u] <= 1'b0;
      end
    end else
      if ( n_count_en ) begin
        xn_count_chnl[current_chnl] <= n_count_nxt;
        xnzero_chnl[current_chnl] <= |(n_count_nxt);
      end
  end // p_xn_count

//  always @( negedge hresetn or posedge hclk )
//  begin : p_xnzero_chnl
//    if ( hresetn == 1'b0 ) begin
//      for ( v = 0; v < `PL230_CHNLS; v=v+1 )
//        xnzero_chnl[v] <= 1'b0;
//    end else
//      if ( ctrl_state != `PL230_ST_IDLE ) begin
//        for ( w = 0; w < `PL230_CHNLS; w=w+1 )
//          xnzero_chnl[w] <= |xn_count_chnl[w];
//    end
//  end // p_xnzero_chnl
  
  assign n_count = xn_count_chnl[data_current_chnl];

  assign xcached_chnl = chnl_enable_status & xnzero_chnl & xnot_idle_chnl;

  assign xcached_chnl_valid_nxt = (|pending_reqs) & xcached_chnl[priority_enc[`PL230_CHNL_BITS-1:0]];

`else // !PL230_PLUS_PTR_CACHE
  always @( negedge hresetn or posedge hclk )
  begin : p_n_count
    if ( hresetn == 1'b0 )
      n_count <= {`PL230_N_COUNT_BITS{1'b0}};
    else
      if ( n_count_en )
        n_count <= n_count_nxt;
  end // p_n_count
`endif

  assign x_current_chnl_onehot = current_chnl_onehot;

endmodule // pl230_ahb_ctrl

`include "pl230_undefs.v"
