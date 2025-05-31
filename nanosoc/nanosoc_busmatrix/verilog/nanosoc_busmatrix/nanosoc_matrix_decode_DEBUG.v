//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2001-2023 Arm Limited or its affiliates.
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
//
//-----------------------------------------------------------------------------
//  Abstract             : The MatrixDecode is used to determine which output
//                         stage is required for a particular access. Addresses
//                         that do not map to an Output port are diverted to
//                         the local default slave.
//
//  Notes               : The bus matrix has sparse connectivity.
//
//-----------------------------------------------------------------------------



module nanosoc_matrix_decode_DEBUG (

    // Common AHB signals
    HCLK,
    HRESETn,

    // Internal address remapping control
    remapping_dec,

    // Signals from the Input stage
    HREADYS,
    sel_dec,
    decode_addr_dec,
    trans_dec,

    // Bus-switch output 0
    active_dec0,
    readyout_dec0,
    resp_dec0,
    rdata_dec0,

    // Bus-switch output 1
    active_dec1,
    readyout_dec1,
    resp_dec1,
    rdata_dec1,

    // Bus-switch output 2
    active_dec2,
    readyout_dec2,
    resp_dec2,
    rdata_dec2,

    // Bus-switch output 3
    active_dec3,
    readyout_dec3,
    resp_dec3,
    rdata_dec3,

    // Bus-switch output 4
    active_dec4,
    readyout_dec4,
    resp_dec4,
    rdata_dec4,

    // Bus-switch output 5
    active_dec5,
    readyout_dec5,
    resp_dec5,
    rdata_dec5,

    // Bus-switch output 6
    active_dec6,
    readyout_dec6,
    resp_dec6,
    rdata_dec6,

    // Bus-switch output 7
    active_dec7,
    readyout_dec7,
    resp_dec7,
    rdata_dec7,

    // Output port selection signals
    sel_dec0,
    sel_dec1,
    sel_dec2,
    sel_dec3,
    sel_dec4,
    sel_dec5,
    sel_dec6,
    sel_dec7,

    // Selected Output port data and control signals
    active_dec,
    HREADYOUTS,
    HRESPS,
    HRDATAS

    );


// -----------------------------------------------------------------------------
// Input and Output declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    input         HCLK;           // AHB System Clock
    input         HRESETn;        // AHB System Reset

    // Internal address remapping control
    input   [0:0] remapping_dec;      // Internal remap signal

    // Signals from the Input stage
    input         HREADYS;        // Transfer done
    input         sel_dec;            // HSEL input
    input [31:10] decode_addr_dec;     // HADDR decoder input
    input   [1:0] trans_dec;          // Input port HTRANS signal

    // Bus-switch output MI0
    input         active_dec0;        // Output stage MI0 active_dec signal
    input         readyout_dec0;      // HREADYOUT input
    input   [1:0] resp_dec0;          // HRESP input
    input  [31:0] rdata_dec0;         // HRDATA input

    // Bus-switch output MI1
    input         active_dec1;        // Output stage MI1 active_dec signal
    input         readyout_dec1;      // HREADYOUT input
    input   [1:0] resp_dec1;          // HRESP input
    input  [31:0] rdata_dec1;         // HRDATA input

    // Bus-switch output MI2
    input         active_dec2;        // Output stage MI2 active_dec signal
    input         readyout_dec2;      // HREADYOUT input
    input   [1:0] resp_dec2;          // HRESP input
    input  [31:0] rdata_dec2;         // HRDATA input

    // Bus-switch output MI3
    input         active_dec3;        // Output stage MI3 active_dec signal
    input         readyout_dec3;      // HREADYOUT input
    input   [1:0] resp_dec3;          // HRESP input
    input  [31:0] rdata_dec3;         // HRDATA input

    // Bus-switch output MI4
    input         active_dec4;        // Output stage MI4 active_dec signal
    input         readyout_dec4;      // HREADYOUT input
    input   [1:0] resp_dec4;          // HRESP input
    input  [31:0] rdata_dec4;         // HRDATA input

    // Bus-switch output MI5
    input         active_dec5;        // Output stage MI5 active_dec signal
    input         readyout_dec5;      // HREADYOUT input
    input   [1:0] resp_dec5;          // HRESP input
    input  [31:0] rdata_dec5;         // HRDATA input

    // Bus-switch output MI6
    input         active_dec6;        // Output stage MI6 active_dec signal
    input         readyout_dec6;      // HREADYOUT input
    input   [1:0] resp_dec6;          // HRESP input
    input  [31:0] rdata_dec6;         // HRDATA input

    // Bus-switch output MI7
    input         active_dec7;        // Output stage MI7 active_dec signal
    input         readyout_dec7;      // HREADYOUT input
    input   [1:0] resp_dec7;          // HRESP input
    input  [31:0] rdata_dec7;         // HRDATA input

    // Output port selection signals
    output        sel_dec0;           // HSEL output
    output        sel_dec1;           // HSEL output
    output        sel_dec2;           // HSEL output
    output        sel_dec3;           // HSEL output
    output        sel_dec4;           // HSEL output
    output        sel_dec5;           // HSEL output
    output        sel_dec6;           // HSEL output
    output        sel_dec7;           // HSEL output

    // Selected Output port data and control signals
    output        active_dec;         // Combinatorial active_dec O/P
    output        HREADYOUTS;     // HREADY feedback output
    output  [1:0] HRESPS;         // Transfer response
    output [31:0] HRDATAS;        // Read Data


// -----------------------------------------------------------------------------
// Wire declarations
// -----------------------------------------------------------------------------

    // Common AHB signals
    wire          HCLK;            // AHB System Clock
    wire          HRESETn;         // AHB System Reset
    // Internal address remapping control
    wire    [0:0] remapping_dec;       // Internal remap signal

    // Signals from the Input stage
    wire          HREADYS;         // Transfer done
    wire          sel_dec;             // HSEL input
    wire  [31:10] decode_addr_dec;      // HADDR input
    wire    [1:0] trans_dec;           // Input port HTRANS signal

    // Bus-switch output MI0
    wire          active_dec0;         // active_dec signal
    wire          readyout_dec0;       // HREADYOUT input
    wire    [1:0] resp_dec0;           // HRESP input
    wire   [31:0] rdata_dec0;          // HRDATA input
    reg           sel_dec0;            // HSEL output

    // Bus-switch output MI1
    wire          active_dec1;         // active_dec signal
    wire          readyout_dec1;       // HREADYOUT input
    wire    [1:0] resp_dec1;           // HRESP input
    wire   [31:0] rdata_dec1;          // HRDATA input
    reg           sel_dec1;            // HSEL output

    // Bus-switch output MI2
    wire          active_dec2;         // active_dec signal
    wire          readyout_dec2;       // HREADYOUT input
    wire    [1:0] resp_dec2;           // HRESP input
    wire   [31:0] rdata_dec2;          // HRDATA input
    reg           sel_dec2;            // HSEL output

    // Bus-switch output MI3
    wire          active_dec3;         // active_dec signal
    wire          readyout_dec3;       // HREADYOUT input
    wire    [1:0] resp_dec3;           // HRESP input
    wire   [31:0] rdata_dec3;          // HRDATA input
    reg           sel_dec3;            // HSEL output

    // Bus-switch output MI4
    wire          active_dec4;         // active_dec signal
    wire          readyout_dec4;       // HREADYOUT input
    wire    [1:0] resp_dec4;           // HRESP input
    wire   [31:0] rdata_dec4;          // HRDATA input
    reg           sel_dec4;            // HSEL output

    // Bus-switch output MI5
    wire          active_dec5;         // active_dec signal
    wire          readyout_dec5;       // HREADYOUT input
    wire    [1:0] resp_dec5;           // HRESP input
    wire   [31:0] rdata_dec5;          // HRDATA input
    reg           sel_dec5;            // HSEL output

    // Bus-switch output MI6
    wire          active_dec6;         // active_dec signal
    wire          readyout_dec6;       // HREADYOUT input
    wire    [1:0] resp_dec6;           // HRESP input
    wire   [31:0] rdata_dec6;          // HRDATA input
    reg           sel_dec6;            // HSEL output

    // Bus-switch output MI7
    wire          active_dec7;         // active_dec signal
    wire          readyout_dec7;       // HREADYOUT input
    wire    [1:0] resp_dec7;           // HRESP input
    wire   [31:0] rdata_dec7;          // HRDATA input
    reg           sel_dec7;            // HSEL output


// -----------------------------------------------------------------------------
// Signal declarations
// -----------------------------------------------------------------------------

    // Selected Output port data and control signals
    reg           active_dec;          // Combinatorial active_dec O/P signal
    reg           HREADYOUTS;      // Combinatorial HREADYOUT signal
    reg     [1:0] HRESPS;          // Combinatorial HRESPS signal
    reg    [31:0] HRDATAS;         // Read data bus

    reg     [3:0] addr_out_port;     // Address output ports
    reg     [3:0] data_out_port;     // Data output ports

    // Default slave signals
    reg           sel_dft_slv;       // HSEL signal
    wire          readyout_dft_slv;  // HREADYOUT signal
    wire    [1:0] resp_dft_slv;      // Combinatorial HRESPS signal


// -----------------------------------------------------------------------------
// Beginning of main code
// -----------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Default slave (accessed when HADDR is unmapped)
//------------------------------------------------------------------------------

  nanosoc_busmatrix_default_slave u_nanosoc_busmatrix_default_slave (

    // Common AHB signals
    .HCLK        (HCLK),
    .HRESETn     (HRESETn),

    // AHB Control signals
    .HSEL        (sel_dft_slv),
    .HTRANS      (trans_dec),
    .HREADY      (HREADYS),
    .HREADYOUT   (readyout_dft_slv),
    .HRESP       (resp_dft_slv)

    );


//------------------------------------------------------------------------------
// Address phase signals
//------------------------------------------------------------------------------

// The address decode is done in two stages. This is so that the address
//  decode occurs in only one process, p_addr_out_portComb, and then the select
//  signal is factored in.
//
// Note that the hexadecimal address values are reformatted to align with the
//  lower bound of decode_addr_dec[31:10], which is not a hex character boundary

  always @ (
             decode_addr_dec or
             remapping_dec or data_out_port or trans_dec
           )
    begin : p_addr_out_port_comb

      // Only switch if there is an active transfer
      if (trans_dec != 2'b00)
      begin

        case (remapping_dec)  // Composition: REMAP[0]
          1'b0 : begin
            // Static address region 0x00000000-0x0fffffff
            if ((decode_addr_dec >= 22'h000000) & (decode_addr_dec <= 22'h03ffff))
               addr_out_port = 4'b0000;  // Select Output port MI0
            // Static address region 0x10000000-0x1fffffff
            else if ((decode_addr_dec >= 22'h040000) & (decode_addr_dec <= 22'h07ffff))
               addr_out_port = 4'b0000;  // Select Output port MI0

            // Static address region 0x20000000-0x2fffffff
            else if ((decode_addr_dec >= 22'h080000) & (decode_addr_dec <= 22'h0bffff))
               addr_out_port = 4'b0001;  // Select Output port MI1

            // Static address region 0x30000000-0x3fffffff
            else if ((decode_addr_dec >= 22'h0c0000) & (decode_addr_dec <= 22'h0fffff))
               addr_out_port = 4'b0010;  // Select Output port MI2

            // Static address region 0x40000000-0x5fffffff
            else if ((decode_addr_dec >= 22'h100000) & (decode_addr_dec <= 22'h17ffff))
               addr_out_port = 4'b0011;  // Select Output port MI3

            // Static address region 0x80000000-0x8fffffff
            else if ((decode_addr_dec >= 22'h200000) & (decode_addr_dec <= 22'h23ffff))
               addr_out_port = 4'b0100;  // Select Output port MI4

            // Static address region 0x90000000-0x9fffffff
            else if ((decode_addr_dec >= 22'h240000) & (decode_addr_dec <= 22'h27ffff))
               addr_out_port = 4'b0101;  // Select Output port MI5

            // Static address region 0x60000000-0x7fffffff
            else if ((decode_addr_dec >= 22'h180000) & (decode_addr_dec <= 22'h1fffff))
               addr_out_port = 4'b0110;  // Select Output port MI6
            // Static address region 0xa0000000-0xdfffffff
            else if ((decode_addr_dec >= 22'h280000) & (decode_addr_dec <= 22'h37ffff))
               addr_out_port = 4'b0110;  // Select Output port MI6

            // Static address region 0xf0000000-0xf003ffff
            else if ((decode_addr_dec >= 22'h3c0000) & (decode_addr_dec <= 22'h3c00ff))
               addr_out_port = 4'b0111;  // Select Output port MI7

            else
              addr_out_port = 4'b1000;   // Select the default slave
          end

          1'b1 : begin
            // Remapped address region 0x00000000-0x0fffffff due to REMAP[0]
            if ((decode_addr_dec >= 22'h000000) & (decode_addr_dec <= 22'h03ffff))
               addr_out_port = 4'b0001;  // Select Output port MI1

            // Static address region 0x00000000-0x0fffffff
            else if ((decode_addr_dec >= 22'h000000) & (decode_addr_dec <= 22'h03ffff))
               addr_out_port = 4'b0000;  // Select Output port MI0
            // Static address region 0x10000000-0x1fffffff
            else if ((decode_addr_dec >= 22'h040000) & (decode_addr_dec <= 22'h07ffff))
               addr_out_port = 4'b0000;  // Select Output port MI0

            // Static address region 0x20000000-0x2fffffff
            else if ((decode_addr_dec >= 22'h080000) & (decode_addr_dec <= 22'h0bffff))
               addr_out_port = 4'b0001;  // Select Output port MI1

            // Static address region 0x30000000-0x3fffffff
            else if ((decode_addr_dec >= 22'h0c0000) & (decode_addr_dec <= 22'h0fffff))
               addr_out_port = 4'b0010;  // Select Output port MI2

            // Static address region 0x40000000-0x5fffffff
            else if ((decode_addr_dec >= 22'h100000) & (decode_addr_dec <= 22'h17ffff))
               addr_out_port = 4'b0011;  // Select Output port MI3

            // Static address region 0x80000000-0x8fffffff
            else if ((decode_addr_dec >= 22'h200000) & (decode_addr_dec <= 22'h23ffff))
               addr_out_port = 4'b0100;  // Select Output port MI4

            // Static address region 0x90000000-0x9fffffff
            else if ((decode_addr_dec >= 22'h240000) & (decode_addr_dec <= 22'h27ffff))
               addr_out_port = 4'b0101;  // Select Output port MI5

            // Static address region 0x60000000-0x7fffffff
            else if ((decode_addr_dec >= 22'h180000) & (decode_addr_dec <= 22'h1fffff))
               addr_out_port = 4'b0110;  // Select Output port MI6
            // Static address region 0xa0000000-0xdfffffff
            else if ((decode_addr_dec >= 22'h280000) & (decode_addr_dec <= 22'h37ffff))
               addr_out_port = 4'b0110;  // Select Output port MI6

            // Static address region 0xf0000000-0xf003ffff
            else if ((decode_addr_dec >= 22'h3c0000) & (decode_addr_dec <= 22'h3c00ff))
               addr_out_port = 4'b0111;  // Select Output port MI7

            else
              addr_out_port = 4'b1000;   // Select the default slave
          end

          default : addr_out_port = {4{1'bx}};
        endcase

      end // if (trans_dec != 2'b00)
      else
        addr_out_port = data_out_port;   // Stay on last port if no activity

    end // block: p_addr_out_port_comb

  // Select signal decode
  always @ (sel_dec or addr_out_port)
    begin : p_sel_comb
      sel_dec0 = 1'b0;
      sel_dec1 = 1'b0;
      sel_dec2 = 1'b0;
      sel_dec3 = 1'b0;
      sel_dec4 = 1'b0;
      sel_dec5 = 1'b0;
      sel_dec6 = 1'b0;
      sel_dec7 = 1'b0;
      sel_dft_slv = 1'b0;

      if (sel_dec)
        case (addr_out_port)
          4'b0000 : sel_dec0 = 1'b1;
          4'b0001 : sel_dec1 = 1'b1;
          4'b0010 : sel_dec2 = 1'b1;
          4'b0011 : sel_dec3 = 1'b1;
          4'b0100 : sel_dec4 = 1'b1;
          4'b0101 : sel_dec5 = 1'b1;
          4'b0110 : sel_dec6 = 1'b1;
          4'b0111 : sel_dec7 = 1'b1;
          4'b1000 : sel_dft_slv = 1'b1;    // Select the default slave
          default : begin
            sel_dec0 = 1'bx;
            sel_dec1 = 1'bx;
            sel_dec2 = 1'bx;
            sel_dec3 = 1'bx;
            sel_dec4 = 1'bx;
            sel_dec5 = 1'bx;
            sel_dec6 = 1'bx;
            sel_dec7 = 1'bx;
            sel_dft_slv = 1'bx;
          end
        endcase // case(addr_out_port)
    end // block: p_sel_comb

// The decoder selects the appropriate active_dec signal depending on which
//  output stage is required for the transfer.
  always @ (
             active_dec0 or
             active_dec1 or
             active_dec2 or
             active_dec3 or
             active_dec4 or
             active_dec5 or
             active_dec6 or
             active_dec7 or
             addr_out_port
           )
    begin : p_active_comb
      case (addr_out_port)
        4'b0000 : active_dec = active_dec0;
        4'b0001 : active_dec = active_dec1;
        4'b0010 : active_dec = active_dec2;
        4'b0011 : active_dec = active_dec3;
        4'b0100 : active_dec = active_dec4;
        4'b0101 : active_dec = active_dec5;
        4'b0110 : active_dec = active_dec6;
        4'b0111 : active_dec = active_dec7;
        4'b1000 : active_dec = 1'b1;         // Select the default slave
        default : active_dec = 1'bx;
      endcase // case(addr_out_port)
    end // block: p_active_comb


//------------------------------------------------------------------------------
// Data phase signals
//------------------------------------------------------------------------------

// The data_out_port needs to be updated when HREADY from the input stage is high.
//  Note: HREADY must be used, not HREADYOUT, because there are occaisions
//  (namely when the holding register gets loaded) when HREADYOUT may be low
//  but HREADY is high, and in this case it is important that the data_out_port
//  gets updated.
//  When the port is inactive, the default slave is selected to prevent toggling.

  always @ (negedge HRESETn or posedge HCLK)
    begin : p_data_out_port_seq
      if (~HRESETn)
        data_out_port <= 4'b1000;
      else
        if (HREADYS)
          if (sel_dec & trans_dec[1])
            data_out_port <= addr_out_port;
          else
            data_out_port <= 4'b1000;
    end // block: p_data_out_port_seq

  // HREADYOUTS output decode
  always @ (
             readyout_dft_slv or
             readyout_dec0 or
             readyout_dec1 or
             readyout_dec2 or
             readyout_dec3 or
             readyout_dec4 or
             readyout_dec5 or
             readyout_dec6 or
             readyout_dec7 or
             data_out_port
           )
  begin : p_ready_comb
    case (data_out_port)
      4'b0000 : HREADYOUTS = readyout_dec0;
      4'b0001 : HREADYOUTS = readyout_dec1;
      4'b0010 : HREADYOUTS = readyout_dec2;
      4'b0011 : HREADYOUTS = readyout_dec3;
      4'b0100 : HREADYOUTS = readyout_dec4;
      4'b0101 : HREADYOUTS = readyout_dec5;
      4'b0110 : HREADYOUTS = readyout_dec6;
      4'b0111 : HREADYOUTS = readyout_dec7;
      4'b1000 : HREADYOUTS = readyout_dft_slv;    // Select the default slave
      default : HREADYOUTS = 1'bx;
    endcase // case(data_out_port)
  end // block: p_ready_comb

  // HRESPS output decode
  always @ (
             resp_dft_slv or
             resp_dec0 or
             resp_dec1 or
             resp_dec2 or
             resp_dec3 or
             resp_dec4 or
             resp_dec5 or
             resp_dec6 or
             resp_dec7 or
             data_out_port
           )
  begin : p_resp_comb
    case (data_out_port)
      4'b0000 : HRESPS = resp_dec0;
      4'b0001 : HRESPS = resp_dec1;
      4'b0010 : HRESPS = resp_dec2;
      4'b0011 : HRESPS = resp_dec3;
      4'b0100 : HRESPS = resp_dec4;
      4'b0101 : HRESPS = resp_dec5;
      4'b0110 : HRESPS = resp_dec6;
      4'b0111 : HRESPS = resp_dec7;
      4'b1000 : HRESPS = resp_dft_slv;     // Select the default slave
      default : HRESPS = {2{1'bx}};
    endcase // case (data_out_port)
  end // block: p_resp_comb

  // HRDATAS output decode
  always @ (
             rdata_dec0 or
             rdata_dec1 or
             rdata_dec2 or
             rdata_dec3 or
             rdata_dec4 or
             rdata_dec5 or
             rdata_dec6 or
             rdata_dec7 or
             data_out_port
           )
  begin : p_rdata_comb
    case (data_out_port)
      4'b0000 : HRDATAS = rdata_dec0;
      4'b0001 : HRDATAS = rdata_dec1;
      4'b0010 : HRDATAS = rdata_dec2;
      4'b0011 : HRDATAS = rdata_dec3;
      4'b0100 : HRDATAS = rdata_dec4;
      4'b0101 : HRDATAS = rdata_dec5;
      4'b0110 : HRDATAS = rdata_dec6;
      4'b0111 : HRDATAS = rdata_dec7;
      4'b1000 : HRDATAS = {32{1'b0}};   // Select the default slave
      default : HRDATAS = {32{1'bx}};
    endcase // case (data_out_port)
  end // block: p_rdata_comb


endmodule

// --================================= End ===================================--
