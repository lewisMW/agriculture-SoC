//-----------------------------------------------------------------------------
// SoC Labs AHB to Valid/Ready Wrapper Interface
// - Adapted from ARM AHB-lite example slave interface module.
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright  2023, SoC Labs (www.soclabs.org)
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
// Abstract : AHB-lite example slave interface module. Transfer AHB-Lite BUS protocol to
//            simple register read write protocol
//-----------------------------------------------------------------------------
module wrapper_ahb_vr_interface #(
  //parameter for address width
  parameter   ADDRWIDTH=12)
 (
  input  logic                  hclk,       // clock
  input  logic                  hresetn,    // reset

  // AHB connection to master
  input  logic                  hsels,
  input  logic [ADDRWIDTH-1:0]  haddrs,
  input  logic [1:0]            htranss,
  input  logic [2:0]            hsizes,
  input  logic                  hwrites,
  input  logic                  hreadys,
  input  logic [31:0]           hwdatas,

  output logic                  hreadyouts,
  output logic                  hresps,
  output logic [31:0]           hrdatas,

   // Register interface - Accelerator Engine Input
  output logic [ADDRWIDTH-2:0]  input_addr,
  output logic                  input_read_en,
  output logic                  input_write_en,
  output logic [3:0]            input_byte_strobe,
  output logic [31:0]           input_wdata,
  input  logic [31:0]           input_rdata,
  input  logic                  input_wready,
  input  logic                  input_rready,

   // Register interface - Accelerator Engine Output
  output logic [ADDRWIDTH-2:0]  output_addr,
  output logic                  output_read_en,
  output logic                  output_write_en,
  output logic [3:0]            output_byte_strobe,
  output logic [31:0]           output_wdata,
  input  logic [31:0]           output_rdata,
  input                         output_wready,
  input                         output_rready
  );

  // ----------------------------------------
  // Internal wires declarations
   logic input_trans_req;
   logic output_trans_req;
   
   assign input_trans_req  = hreadys & hsels & htranss[1] & (~haddrs[ADDRWIDTH-1]);
   assign output_trans_req = hreadys & hsels & htranss[1] & haddrs[ADDRWIDTH-1];
  // use top bit of address to decifer which channel to communciate with
  // transfer request issued only in SEQ and NONSEQ status and slave is
  // selected and last transfer finish

   // Engine Input Signal Generation
   logic                    input_ahb_read_req;  // AHB read request
   logic                    input_ahb_write_req; // AHB write request
   logic                    input_update_read_req;    // To update the read enable register
   logic                    input_update_write_req;   // To update the write enable register

   logic  [ADDRWIDTH-2:0]   input_addr_reg;     // address signal, logicistered
   logic                    input_read_en_reg;  // read enable signal, registered
   logic                    input_write_en_reg; // write enable signal, registered

   logic  [3:0]             input_byte_strobe_reg; // registered output for byte strobe

   assign input_ahb_read_req  = input_trans_req & (~hwrites);// AHB read request
   assign input_ahb_write_req = input_trans_req &  hwrites;  // AHB write request

   // Engine Output Signal Generation
   logic                    output_ahb_read_req;// AHB read request
   logic                    output_ahb_write_req;  // AHB write request
   logic                    output_update_read_req;    // To update the read enable register
   logic                    output_update_write_req;   // To update the write enable register

   logic  [ADDRWIDTH-2:0]   output_addr_reg;     // address signal, logicistered
   logic                    output_read_en_reg;  // read enable signal, registered
   logic                    output_write_en_reg; // write enable signal, registered

   logic  [3:0]             output_byte_strobe_reg; // registered output for byte strobe

   assign                   output_ahb_read_req  = output_trans_req & (~hwrites);// AHB read request
   assign                   output_ahb_write_req = output_trans_req &  hwrites;  // AHB write request

   logic  [3:0]             byte_strobe_nxt; // next state for byte_strobe_reg

    // Channel Selection Register
   logic                    channel_sel;
  //-----------------------------------------------------------
  // Module logic start
  //----------------------------------------------------------

  // Address signal registering, to make the address and data active at the same cycle
  always_ff @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn) begin
      input_addr_reg  <= {(ADDRWIDTH-1){1'b0}}; //default address 0 is selected
      output_addr_reg <= {(ADDRWIDTH-1){1'b0}}; //default address 0 is selected
    end else begin 
        if (input_trans_req) begin
            input_addr_reg  <= haddrs[ADDRWIDTH-2:0]; // register address for data phase
            channel_sel     <= haddrs[ADDRWIDTH-1];
        end else if (output_trans_req) begin
            output_addr_reg <= haddrs[ADDRWIDTH-2:0]; // register address for data phase
            channel_sel     <= haddrs[ADDRWIDTH-1];
        end
    end
  end


  // register read signal generation
  assign input_update_read_req = input_ahb_read_req | (input_read_en_reg & hreadys); // Update read enable control if
                                 //  1. When there is a valid read request
                                 //  2. When there is an active read, update it at the end of transfer (HREADY=1)

  assign output_update_read_req = output_ahb_read_req | (output_read_en_reg & hreadys); // Update read enable control if
                                 //  1. When there is a valid read request
                                 //  2. When there is an active read, update it at the end of transfer (HREADY=1)

  always_ff @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn) begin
        input_read_en_reg  <= 1'b0;
        output_read_en_reg <= 1'b0;
    end else begin
        if (input_update_read_req) begin
            input_read_en_reg   <= input_ahb_read_req;
        end else if (output_update_read_req) begin
            output_read_en_reg  <= output_ahb_read_req;
        end
    end
  end

  // register write signal generation
  assign input_update_write_req = input_ahb_write_req | (input_write_en_reg & hreadys);  // Update write enable control if
                                 //  1. When there is a valid write request
                                 //  2. When there is an active write, update it at the end of transfer (HREADY=1)
  assign output_update_write_req = output_ahb_write_req | (output_write_en_reg & hreadys);  // Update write enable control if
                                 //  1. When there is a valid write request
                                 //  2. When there is an active write, update it at the end of transfer (HREADY=1)

  always_ff @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      begin
        input_write_en_reg  <= 1'b0;
        output_write_en_reg <= 1'b0;
      end
    else begin 
        if (input_update_write_req)  begin
            input_write_en_reg  <= input_ahb_write_req;
        end else if (output_update_write_req) begin
            output_write_en_reg  <= output_ahb_write_req;
        end
    end
  end

  // byte strobe signal
   always @(hsizes or haddrs)
   begin
     if (hsizes == 3'b000)    //byte
       begin
         case(haddrs[1:0])
           2'b00: byte_strobe_nxt = 4'b0001;
           2'b01: byte_strobe_nxt = 4'b0010;
           2'b10: byte_strobe_nxt = 4'b0100;
           2'b11: byte_strobe_nxt = 4'b1000;
           default: byte_strobe_nxt = 4'bxxxx;
         endcase
       end
     else if (hsizes == 3'b001) //half word
       begin
         if(haddrs[1]==1'b1)
           byte_strobe_nxt = 4'b1100;
         else
           byte_strobe_nxt = 4'b0011;
       end
     else // default 32 bits, word
       begin
           byte_strobe_nxt = 4'b1111;
       end
   end

  always_ff @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn) begin
      input_byte_strobe_reg <= {4{1'b0}};
      output_byte_strobe_reg <= {4{1'b0}};
    end else begin 
        if (input_update_read_req|input_update_write_req) begin
            // Update byte strobe registers if
            // 1. if there is a valid read/write transfer request
            // 2. if there is an on going transfer
            input_byte_strobe_reg  <= byte_strobe_nxt;
        end else if (output_update_read_req|output_update_write_req) begin
            // Update byte strobe registers if
            // 1. if there is a valid read/write transfer request
            // 2. if there is an on going transfer
            output_byte_strobe_reg  <= byte_strobe_nxt;
        end
    end
  end

  //-----------------------------------------------------------
  // Outputs
  //-----------------------------------------------------------
  // Input Channel Data Assignments
  assign input_addr         = input_addr_reg[ADDRWIDTH-2:0];
  assign input_read_en      = input_read_en_reg;
  assign input_write_en     = input_write_en_reg;
  assign input_wdata        = hwdatas;
  assign input_byte_strobe  = input_byte_strobe_reg;

  // Output Channel Data Assignments
  assign output_addr        = output_addr_reg[ADDRWIDTH-2:0];
  assign output_read_en     = output_read_en_reg;
  assign output_write_en    = output_write_en_reg;
  assign output_wdata       = hwdatas;
  assign output_byte_strobe = output_byte_strobe_reg;

  assign hresps      = 1'b0;  // OKAY response from slave
    // Always has okay response - won't generate error
    // just wait until buffers able to be read from/written to

  // Multiplex Read data back onto AHB
  assign hrdatas     = channel_sel ? output_rdata : input_rdata;
  
  logic       read_en_sel;
  logic       write_en_sel;
  logic [2:0] hready_sel;

  assign write_en_sel = input_write_en | output_write_en;
  assign read_en_sel  = input_read_en  | output_read_en;
  assign hready_sel    = {channel_sel,write_en_sel,read_en_sel};

  // Hreadyout Assignment 
  // - Need to assign combinatorially depending on channel connected to and whether channel is being written to/read from
  // - 4-way MUX
  always_comb begin
    // Channel Selection
    case(hready_sel)
        // Input Channel Selects
        3'b000: hreadyouts =  1'b1; // Defaultly Ready when no transaction taking place
        3'b001: hreadyouts =  input_rready; // Read Transaction Response
        3'b010: hreadyouts =  input_wready; // Write Transaction Response
        3'b011: hreadyouts =  1'bx; // Both Read & Write Selected - Error State
        // Output Channel Selects
        3'b100: hreadyouts =  1'b1; // Defaultly Ready when no transaction taking place
        3'b101: hreadyouts =  output_rready; // Read Transaction Response
        3'b110: hreadyouts =  output_wready; // Write Transaction Response
        3'b111: hreadyouts =  1'bx;  // Both Read & Write Selected - Error State
        default: hreadyouts = 1'bx;
    endcase

  end
  //-----------------------------------------------------------
  //Module logic end
  //----------------------------------------------------------


endmodule

