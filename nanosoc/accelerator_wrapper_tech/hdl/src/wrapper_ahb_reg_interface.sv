//-----------------------------------------------------------------------------
// SoC Labs AHB Wrapper Interface
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
module wrapper_ahb_reg_interface #(
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

   // Register interface
  output logic [ADDRWIDTH-1:0]  addr,
  output logic                  read_en,
  output logic                  write_en,
  output logic [3:0]            byte_strobe,
  output logic [31:0]           wdata,
  input  logic [31:0]           rdata,
  input  logic                  wready,
  input  logic                  rready);

  // ----------------------------------------
  // Internal logics declarations
   logic                   trans_req;
   assign                  trans_req = hreadys & hsels & htranss[1];
    // transfer request issued only in SEQ and NONSEQ status and slave is
    // selected and last transfer finish

   logic                   ahb_read_req;// AHB read request
   logic                   ahb_write_req;  // AHB write request
   logic                   update_read_req;    // To update the read enable register
   logic                   update_write_req;   // To update the write enable register

   logic  [ADDRWIDTH-1:0]   addr_reg;     // address signal, registered
   logic                    read_en_reg;  // read enable signal, registered
   logic                    write_en_reg; // write enable signal, registered

   logic  [3:0]             byte_strobe_reg; // registered output for byte strobe
   logic  [3:0]             byte_strobe_nxt; // next state for byte_strobe_reg

   logic  [1:0]             haddrs_byte_sel; // Select which byte to enable
   logic                    haddrs_halfword_sel; // Select which byte to enable

   assign                  ahb_read_req  = trans_req & (~hwrites);
   assign                  ahb_write_req = trans_req &  hwrites; 
   
   assign haddrs_byte_sel     = haddrs[1:0];
   assign haddrs_halfword_sel = haddrs[1];
  //-----------------------------------------------------------
  // Module logic start
  //----------------------------------------------------------

  // Address signal registering, to make the address and data active at the same cycle
  always_ff @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      addr_reg <= {(ADDRWIDTH){1'b0}}; //default address 0 is selected
    else if (trans_req)
      addr_reg <= haddrs[ADDRWIDTH-1:0];
  end


  // register read signal generation
  assign update_read_req = ahb_read_req | (read_en_reg & hreadys); // Update read enable control if
                                 //  1. When there is a valid read request
                                 //  2. When there is an active read, update it at the end of transfer (HREADY=1)

  always_ff @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      begin
        read_en_reg <= 1'b0;
      end
    else if (update_read_req)
      begin
        read_en_reg  <= ahb_read_req;
      end
  end

  // register write signal generation
  assign update_write_req = ahb_write_req |( write_en_reg & hreadys);  // Update write enable control if
                                 //  1. When there is a valid write request
                                 //  2. When there is an active write, update it at the end of transfer (HREADY=1)

  always_ff @(posedge hclk or negedge hresetn)
  begin
    if (~hresetn)
      begin
        write_en_reg <= 1'b0;
      end
    else if (update_write_req)
      begin
        write_en_reg  <= ahb_write_req;
      end
  end

  // byte strobe signal
   always_comb
   begin
     if (hsizes == 3'b000)    //byte
       begin
         case(haddrs_byte_sel)
           2'b00: byte_strobe_nxt = 4'b0001;
           2'b01: byte_strobe_nxt = 4'b0010;
           2'b10: byte_strobe_nxt = 4'b0100;
           2'b11: byte_strobe_nxt = 4'b1000;
           default: byte_strobe_nxt = 4'bxxxx;
         endcase
       end
     else if (hsizes == 3'b001) //half word
       begin
         if(haddrs_halfword_sel == 1'b1)
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
    if (~hresetn)
      byte_strobe_reg <= {4{1'b0}};
    else if (update_read_req|update_write_req)
      // Update byte strobe registers if
      // 1. if there is a valid read/write transfer request
      // 2. if there is an on going transfer
      byte_strobe_reg  <= byte_strobe_nxt;
  end

  //-----------------------------------------------------------
  // Outputs
  //-----------------------------------------------------------
  // For simplify the timing, the master and slave signals are connected directly, execpt data bus.
  assign addr        = addr_reg[ADDRWIDTH-1:0];
  assign read_en     = read_en_reg;
  assign write_en    = write_en_reg;
  assign wdata       = hwdatas;
  assign byte_strobe = byte_strobe_reg;

  // Hreadyout Assignment 
  // If neither write_en or read_en, set hreadyouts to 0, if write or read, set to appropriate ready, if both, set to x
  assign hreadyouts = write_en ? (read_en ? 1'bx : wready) : (read_en ? rready : 1'b1);

  assign hresps      = 1'b0;  // OKAY response from slave
  assign hrdatas     = rdata;
  //-----------------------------------------------------------
  //Module logic end
  //----------------------------------------------------------


endmodule

