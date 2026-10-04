//-----------------------------------------------------------------------------
// 8-bit AXI-Stream output RX -> File capture
//
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (c) 2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module tb_axi_stream_io8_rxd_to_file
  #(parameter RXDFILENAME = "rxd.log",
    parameter WAITSTATE = 0,
    parameter VERBOSE = 0)
  (
  input  wire       aclk,
  input  wire       aresetn,
  output wire       end_of_file,
  output wire       rxd8_ready,
  input  wire       rxd8_valid,
  input  wire [7:0] rxd8_data
  );

 //----------------------------------------------
 //-- File I/O
 //----------------------------------------------


   integer        fd;       // channel descriptor for cmd file input
   integer        ch;
   integer        i;
`define EOF -1

   reg       ready;
   reg       eof;
   reg [7:0] data8;
   
   reg       nxt_end_simulation;
   reg       reg_end_simulation;
  
   initial
     begin
       eof <= 0;
       ready <= 0;
       nxt_end_simulation <= 1'b0;
       reg_end_simulation <= 1'b0;
       fd= $fopen(RXDFILENAME,"w");
       if (fd == 0)
          $write("** %m : output log file failed to open **\n");
       else begin
 //        $write("** %m : output log file opened **\n");
         @(posedge aresetn);
         while (!reg_end_simulation) begin
           @(posedge aclk);
           ready <= 1'b1;
           @(posedge aclk);
           while (rxd8_valid == 1'b0)
             @(posedge aclk);
           ready <=0;
           data8 <= rxd8_data;
//         $write("0x%02x", data8);
           ch = (rxd8_data & 8'hff);
           $fwrite(fd, "%c", ch);
           if  (ch==8'h04) begin // Stop simulation if 0x04 is received
             nxt_end_simulation <= 1'b1;
             end
           for (i=0; i < WAITSTATE; i=i+1)
             @(posedge aclk);
         end
         $write("** %m : log file closed after stream RX terminated **\n");
           @(posedge aclk);
           ready <= 1'b1;
           @(posedge aclk);
           while (rxd8_valid == 1'b0)
             @(posedge aclk);
           ready <=0;
         $fclose(fd);
       end
     end

always @(posedge aclk or negedge aresetn)
  if (!aresetn) begin
     reg_end_simulation <= 1'b0;
     eof <= 1'b0;
     end
  else begin
      reg_end_simulation <= nxt_end_simulation;
      eof <= reg_end_simulation;
     end
     
assign rxd8_ready = ready ;
assign end_of_file = eof;

endmodule
