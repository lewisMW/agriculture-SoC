//-----------------------------------------------------------------------------
// AHB transaction logger, developed for DMA integration testing
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (C) 2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module nanosoc_dma_log_to_file
  #(parameter FILENAME = "dma.log",
    parameter NUM_CHNLS = 2,
    parameter NUM_CHNL_BITS = 1,
    parameter TIMESTAMP = 1)
  (
  input  wire        hclk,
  input  wire        hresetn,
  // AHB manager interface
  input  wire        hready,
  input  wire        hresp,
  input  wire [1:0]  htrans,
  input  wire [31:0] haddr,
  input  wire        hwrite,
  input  wire [3:0]  hprot,
  input  wire [2:0]  hsize,
  input  wire [2:0]  hburst,
  input  wire [31:0] hwdata,
  input  wire [31:0] hrdata,
  // APB control interface
  input  wire        pclken,
  input  wire        psel,
  input  wire        pen,
  input  wire        pwrite,
  input  wire [11:0] paddr,
  input  wire [31:0] pwdata,
  input  wire [31:0] prdata,
  // DMA state tracking
  input wire  [NUM_CHNLS-1:0]  dma_req,
  input wire  [NUM_CHNLS-1:0]  dma_active,
  input wire  [NUM_CHNLS-1:0]  dma_done,
  input wire  [NUM_CHNL_BITS-1:0]  dma_chnl,
  input wire  [3:0]  dma_ctrl_state
  );

function FN_one_hot_valid;
input [NUM_CHNLS-1:0] onehot;
integer b;
  begin
    FN_one_hot_valid = |onehot;
  end
endfunction

function [NUM_CHNL_BITS:0] FN_one_hot_to_chnl;
input [NUM_CHNLS-1:0] onehot;
integer b;
  begin
    b=0;
    while (!onehot[b])
      b = b+1;
    FN_one_hot_to_chnl = b;
  end
endfunction

wire hsel = 1'b1;
 // AHB transction de-pipelining
 
  // --------------------------------------------------------------------------
  // Internal regs/wires
  // --------------------------------------------------------------------------

  reg          sel_r;
  reg   [31:0] addr_r;
  reg          wcyc_r;
  reg          rcyc_r;
  reg    [3:0] byte4_r;
  reg    [3:0] dma_ctrl_state_r;
  wire  [31:0] hdata;
  
  
  // --------------------------------------------------------------------------
  // AHB slave byte buffer interface, support for unaligned data transfers
  // --------------------------------------------------------------------------

  wire   [1:0] byte_addr = haddr[1:0];
  // generate next byte enable decodes for Word/Half/Byte CPU/DMA accesses
  wire   [3:0] byte_nxt;
  assign byte_nxt[0] = (hsize[1])|((hsize[0])&(!byte_addr[1]))|(byte_addr[1:0]==2'b00);
  assign byte_nxt[1] = (hsize[1])|((hsize[0])&(!byte_addr[1]))|(byte_addr[1:0]==2'b01);
  assign byte_nxt[2] = (hsize[1])|((hsize[0])&( byte_addr[1]))|(byte_addr[1:0]==2'b10);
  assign byte_nxt[3] = (hsize[1])|((hsize[0])&( byte_addr[1]))|(byte_addr[1:0]==2'b11);

  // de-pipelined registered access signals
  always @(posedge hclk or negedge hresetn)
    if (!hresetn)
    begin
      addr_r   <= 32'h0000;
      sel_r    <= 1'b0;
      wcyc_r   <= 1'b0;
      rcyc_r   <= 1'b0;
      byte4_r  <= 4'b0000;
    end else if (hready)
    begin
      addr_r   <= (hsel & htrans[1]) ?  haddr : addr_r;
      sel_r    <= (hsel & htrans[1]);
      wcyc_r   <= (hsel & htrans[1]  &  hwrite);
      rcyc_r   <= (hsel & htrans[1]  & !hwrite);
      byte4_r  <= (hsel & htrans[1]) ?  byte_nxt[3:0] : 4'b0000;
    end 

  assign hdata = (wcyc_r)? hwdata : hrdata;
  
  wire dma_ctrl_state_change = |(dma_ctrl_state_r ^ dma_ctrl_state);

  wire dma_control_access = pclken & pen & psel;

  wire state_nowait = (dma_ctrl_state_r == 0) |  (dma_ctrl_state_r == 6)
                    | (dma_ctrl_state_r == 8) |  (dma_ctrl_state_r == 9)
                    | (dma_ctrl_state_r == 10) |  (dma_ctrl_state_r == 15)
                    ;
                    
  wire report_cycle = (sel_r & hready) | (dma_ctrl_state_change & state_nowait);

  always @(posedge hclk or negedge hresetn)
    if (!hresetn)
    begin
      dma_ctrl_state_r  <= 4'b0000;
    end else if (report_cycle)
    begin
      dma_ctrl_state_r <= dma_ctrl_state;
    end 


  reg  [NUM_CHNLS-1:0] active_one_hot_r;
  reg  [NUM_CHNLS-1:0] done_one_hot_r;
  
   always @(posedge hclk or negedge hresetn)
    if (!hresetn) begin
      active_one_hot_r <= {NUM_CHNLS{1'b0}};
      done_one_hot_r   <= {NUM_CHNLS{1'b0}};
    end else begin
      active_one_hot_r <= dma_active;
      done_one_hot_r   <= dma_done  ;
    end 
 
   wire chnl_change = ((active_one_hot_r != dma_active) & |dma_active)
                    | ((done_one_hot_r != dma_done) & |dma_done);
   
 //----------------------------------------------
 //-- File I/O
 //----------------------------------------------


   integer        fd;       // channel descriptor for cmd file input
   integer        ch;
   reg [NUM_CHNLS-1:0] dma_req_last;
   reg [31:0]     cyc_count;
`define EOF -1

`define PL230_ST_XC_INI 4'hB
`define PL230_ST_XC_RDY  4'hC
`define PL230_ST_XR_SDAT 4'hD
`define PL230_ST_XW_DDAT 4'hE

   initial
     begin
       fd= $fopen(FILENAME,"w");
       dma_req_last <= 2'b00;
       cyc_count <= 0;
       if (fd == 0)
          $write("** %m : output log file failed to open **\n");
       else begin
         @(posedge hresetn);
         while (1) begin
           @(posedge hclk);
           cyc_count <= cyc_count +1;
           if (report_cycle) begin
             $fwrite(fd, "DMA-M: C#%02x ", dma_chnl);
             case (dma_ctrl_state_r)
             0 : $fwrite(fd, "PL230_ST_IDLE         ");
             1 : $fwrite(fd, "PL230_ST_RD_CTRL [%s]", (addr_r & (16 << NUM_CHNL_BITS)) ? "ALT" : "PRI");
             2 : $fwrite(fd, "PL230_ST_RD_SPTR [%s]", (addr_r & (16 << NUM_CHNL_BITS)) ? "ALT" : "PRI");
             3 : $fwrite(fd, "PL230_ST_RD_DPTR [%s]", (addr_r & (16 << NUM_CHNL_BITS)) ? "ALT" : "PRI");
             4 : $fwrite(fd, "PL230_ST_RD_SDAT      ");
             5 : $fwrite(fd, "PL230_ST_WR_DDAT      ");
             6 : $fwrite(fd, "PL230_ST_WAIT         ");
             7 : $fwrite(fd, "PL230_ST_WR_CTRL [%s]", (addr_r & (16 << NUM_CHNL_BITS)) ? "ALT" : "PRI");
             8 : $fwrite(fd, "PL230_ST_STALL        ");
             9 : $fwrite(fd, "PL230_ST_DONE         ");
             10: $fwrite(fd, "PL230_ST_PSGP         ");
             11: $fwrite(fd, "PL230_ST_XC_INI*      ");
             12: $fwrite(fd, "PL230_ST_XC_RDY*      ");
             13: $fwrite(fd, "PL230_ST_XR_SDAT*     ");
             14: $fwrite(fd, "PL230_ST_XW_DDAT*     ");
             default: $fwrite(fd, "PL230_ST_RESVD   ");
             endcase
             case (dma_ctrl_state_r)
             0, 6, 8, 9, 10, 11, 12, 15 :
               $fwrite(fd, "                                  ");
             default: begin
               $fwrite(fd, "     A=0x%03x, %s, D=0x",  addr_r, (wcyc_r) ? "W" : "R");
               if (byte4_r[3]) $fwrite(fd, "%02x", hdata[31:24]); else $fwrite(fd, "--");
               if (byte4_r[2]) $fwrite(fd, "%02x", hdata[23:16]); else $fwrite(fd, "--");
               if (byte4_r[1]) $fwrite(fd, "%02x", hdata[15: 8]); else $fwrite(fd, "--");
               if (byte4_r[0]) $fwrite(fd, "%02x", hdata[ 7: 0]); else $fwrite(fd, "--");
               end
             endcase
             if (TIMESTAMP) $fwrite(fd, ", CYC=%8d (@%t)\n", cyc_count, $time); else $fwrite(fd, "\n");
           end
           if (dma_control_access) begin
             $fwrite(fd, "DMA-C:      ");
             case (paddr[11:2])
             0 : $fwrite(fd, "PL230_DMA_STATUS          ");
             1 : $fwrite(fd, "PL230_DMA_CFG             ");
             2 : $fwrite(fd, "PL230_CTRL_BASE_PTR       ");
             3 : $fwrite(fd, "PL230_ALT_CTRL_BASE_PTR   ");
             4 : $fwrite(fd, "PL230_DMA_WAITONREQ_STATUS");
             5 : $fwrite(fd, "PL230_CHNL_SW_REQUEST     ");
             6 : $fwrite(fd, "PL230_CHNL_USEBURST_SET   ");
             7 : $fwrite(fd, "PL230_CHNL_USEBURST_CLR   ");
             8 : $fwrite(fd, "PL230_CHNL_REQ_MASK_SET   ");
             9 : $fwrite(fd, "PL230_CHNL_REQ_MASK_CLR   ");
             10: $fwrite(fd, "PL230_CHNL_ENABLE_SET     ");
             11: $fwrite(fd, "PL230_CHNL_ENABLE_CLR     ");
             12: $fwrite(fd, "PL230_CHNL_PRI_ALT_SET    ");
             13: $fwrite(fd, "PL230_CHNL_PRI_ALT_CLR    ");
             14: $fwrite(fd, "PL230_CHNL_PRIORITY_SET   ");
             15: $fwrite(fd, "PL230_CHNL_PRIORITY_CLR   ");
             default: $fwrite(fd, "PL230_ADDR_RESVD          ");
             endcase
              $fwrite(fd, "       A+0x%03x %s, D=0x%08x", paddr, (pwrite) ? "W" : "R", (pwrite)? pwdata : prdata);
              if (TIMESTAMP) $fwrite(fd, ", CYC=%8d (@%t)\n", cyc_count, $time); else $fwrite(fd, "\n");
           end
           if (dma_req != dma_req_last) begin
              $fwrite(fd, "DMARQ: [%b]", dma_req);
              if (TIMESTAMP) $fwrite(fd, ", CYC=%8d (@%t)\n",
                                         cyc_count, $time); else $fwrite(fd, "\n");
              dma_req_last <= dma_req;
           end
           if (chnl_change) begin
              $fwrite(fd, "DMAIO: ");
              if (|dma_active) $fwrite(fd, "dma_active[%d], ", FN_one_hot_to_chnl(dma_active)); else $fwrite(fd, "dma_in_active, ");
              if (|dma_done )  $fwrite(fd, "dma_done[%d], ", FN_one_hot_to_chnl(dma_done));
              if (TIMESTAMP)   $fwrite(fd, "CYC=%8d (@%t)\n",
                                         cyc_count, $time); else $fwrite(fd, "\n");
              dma_req_last <= dma_req;
           end
         end
         $fclose(fd);
       end
     end

endmodule
