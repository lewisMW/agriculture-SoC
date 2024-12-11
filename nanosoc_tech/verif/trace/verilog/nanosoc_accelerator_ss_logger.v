//-----------------------------------------------------------------------------
// NanoSoC Accelerator Subsystem AHB Transaction Logger
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (C) 2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module nanosoc_accelerator_ss_logger #(
  parameter FILENAME = "accelerator.log",
  parameter SYS_ADDR_W = 32,
  parameter SYS_DATA_W = 32,
  parameter IRQ_NUM    = 4,
  parameter TIMESTAMP  = 1
)(
  input  wire                  HCLK,           // Clock
  input  wire                  HRESETn,        // Reset
  input  wire                  HSEL_i,         // Device select
  input  wire [SYS_ADDR_W-1:0] HADDR_i,        // Address for byte select
  input  wire [1:0]            HTRANS_i,       // Transfer control
  input  wire [2:0]            HSIZE_i,        // Transfer size
  input  wire [3:0]            HPROT_i,        // Protection control
  input  wire                  HWRITE_i,       // Write control
  input  wire                  HREADY_i,       // Transfer phase done
  input  wire [SYS_DATA_W-1:0] HWDATA_i,       // Write data
  input  wire                  HREADYOUT_o,    // Device ready
  input  wire [SYS_DATA_W-1:0] HRDATA_o,       // Read data output
  input  wire                  HRESP_o,        // Device response
  // AXI-Stream Data
  input  wire                  exp_drq_ip_o,   // (to) DMAC input burst request
  input  wire                  exp_dlast_ip_i, // (from) DMAC input burst end (last transfer)
  input  wire                  exp_drq_op_o,   // (to) DMAC output dma burst request
  input  wire                  exp_dlast_op_i, // (from) DMAC output burst end (last transfer)
  input  wire [IRQ_NUM-1:0]    exp_irq_o
);


 // AHB transction de-pipelining
 
  // --------------------------------------------------------------------------
  // Internal regs/wires
  // --------------------------------------------------------------------------

  reg                  sel_r;
  reg [SYS_ADDR_W-1:0] addr_r;
  reg                  wcyc_r;
  reg                  rcyc_r;
  reg [3:0]            byte4_r;
  reg [3:0]            dma_ctrl_state_r;
  
  // --------------------------------------------------------------------------
  // AHB slave byte buffer interface, support for unaligned data transfers
  // --------------------------------------------------------------------------

  wire   [1:0] byte_addr = HADDR_i[1:0];
  // generate next byte enable decodes for Word/Half/Byte CPU/DMA accesses
  wire   [3:0] byte_nxt;
  assign byte_nxt[0] = (HSIZE_i[1])|((HSIZE_i[0])&(!byte_addr[1]))|(byte_addr[1:0]==2'b00);
  assign byte_nxt[1] = (HSIZE_i[1])|((HSIZE_i[0])&(!byte_addr[1]))|(byte_addr[1:0]==2'b01);
  assign byte_nxt[2] = (HSIZE_i[1])|((HSIZE_i[0])&( byte_addr[1]))|(byte_addr[1:0]==2'b10);
  assign byte_nxt[3] = (HSIZE_i[1])|((HSIZE_i[0])&( byte_addr[1]))|(byte_addr[1:0]==2'b11);

  // de-pipelined registered access signals
  always @(posedge HCLK or negedge HRESETn)
    if (!HRESETn)
    begin
      addr_r   <= 16'h0000;
      sel_r    <= 1'b0;
      wcyc_r   <= 1'b0;
      rcyc_r   <= 1'b0;
      byte4_r  <= 4'b0000;
    end else if (HREADY_i)
    begin
      addr_r   <= (HSEL_i & HTRANS_i[1]) ?  HADDR_i : addr_r;
      sel_r    <= (HSEL_i & HTRANS_i[1]);
      wcyc_r   <= (HSEL_i & HTRANS_i[1]  &  HWRITE_i);
      rcyc_r   <= (HSEL_i & HTRANS_i[1]  & !HWRITE_i);
      byte4_r  <= (HSEL_i & HTRANS_i[1]) ?  byte_nxt[3:0] : 4'b0000;
    end 

  wire [SYS_DATA_W-1:0] hdata;
  assign hdata = (wcyc_r)? HWDATA_i : HRDATA_o;

 //----------------------------------------------
 //-- File I/O
 //----------------------------------------------

  integer           fd;       // channel descriptor for cmd file input
  integer           ch;

  reg               exp_drq_ip_o_prev;
  reg               exp_dlast_ip_i_prev;
  reg               exp_drq_op_o_prev;
  reg               exp_dlast_op_i_prev;
  reg [IRQ_NUM-1:0] exp_irq_prev;

  wire               exp_drq_ip_change;
  wire               exp_dlast_ip_change;
  wire               exp_drq_op_change;
  wire               exp_dlast_op_change;
  wire [IRQ_NUM-1:0] exp_irq_change;
  wire               irq_change;
  wire               drq_change;
  wire               any_change;
        
  reg [31:0]     cyc_count;
`define EOF -1

  reg [7:0] ctrl_reg;
  reg [2:0] dreq_reg;
  reg [2:0] ireq_reg;
  
  always @(posedge HCLK or negedge HRESETn)
    if (!HRESETn)
    begin
       exp_drq_ip_o_prev   <= 1'b0;
       exp_dlast_ip_i_prev <= 1'b0;
       exp_drq_op_o_prev   <= 1'b0;
       exp_dlast_op_i_prev <= 1'b0;
       exp_irq_prev        <= {IRQ_NUM{1'b0}};

    end else if (HREADY_i)
    begin
       exp_drq_ip_o_prev   <= exp_drq_ip_o  ;
       exp_dlast_ip_i_prev <= exp_dlast_ip_i;
       exp_drq_op_o_prev   <= exp_drq_op_o  ;
       exp_dlast_op_i_prev <= exp_dlast_op_i;
       exp_irq_prev        <= exp_irq_o     ;
    end 

    assign exp_drq_ip_change   = (exp_drq_ip_o_prev   ^ exp_drq_ip_o  );
    assign exp_dlast_ip_change = (exp_dlast_ip_i_prev ^ exp_dlast_ip_i);
    assign exp_drq_op_change   = (exp_drq_op_o_prev   ^ exp_drq_op_o  );
    assign exp_dlast_op_change = (exp_dlast_op_i_prev ^ exp_dlast_op_i);
    assign drq_change          = exp_drq_ip_change | exp_drq_op_change
                               | exp_dlast_ip_change | exp_dlast_op_change;
    assign exp_irq_change      = (exp_irq_prev ^ exp_irq_o);
    assign irq_change          = |(exp_irq_change);

    assign any_change = drq_change
                      | irq_change
                      ;
                         
   initial
     begin
       fd= $fopen(FILENAME,"w");
       cyc_count <= 0;
       if (fd == 0)
          $write("** %m : output log file failed to open **\n");
       else begin
         @(posedge HRESETn);
         while (1) begin
           @(posedge HCLK);
           cyc_count <= cyc_count +1;
           if (sel_r & HREADY_i) begin
               $fwrite(fd, "ACC: A+0x%08x, %s, D=0x",  addr_r, (wcyc_r) ? "W" : "R");
               if (byte4_r[3]) $fwrite(fd, "%02x", hdata[31:24]); else $fwrite(fd, "--");
               if (byte4_r[2]) $fwrite(fd, "%02x", hdata[23:16]); else $fwrite(fd, "--");
               if (byte4_r[1]) $fwrite(fd, "%02x", hdata[15: 8]); else $fwrite(fd, "--");
               if (byte4_r[0]) $fwrite(fd, "%02x", hdata[ 7: 0]); else $fwrite(fd, "--");
              if (TIMESTAMP) $fwrite(fd, ", CYC=%8d (@%t)\n", cyc_count, $time); else $fwrite(fd, "\n");
           end
           if (any_change) begin
             $fwrite(fd, "ACC-DRQ: ");
             if (drq_change) begin
               $fwrite(fd, " exp_drq_ip_o=%b,",exp_drq_ip_o);
               $fwrite(fd, " exp_dlast_ip_i=%b,",exp_dlast_ip_i);
               $fwrite(fd, " exp_drq_op_o=%b,",exp_drq_op_o);
               $fwrite(fd, " exp_dlast_op_i=%b",exp_dlast_op_i);
             end
             if (irq_change) begin
               if (drq_change)  $fwrite(fd, ",");
               $fwrite(fd, " ACC-IRQ=%b,",exp_irq_o);
             end
             if (TIMESTAMP) $fwrite(fd, ", CYC=%8d (@%t)\n",cyc_count, $time); else $fwrite(fd, "\n");
           end
         end
         $fclose(fd);
       end
     end

endmodule
