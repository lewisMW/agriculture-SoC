//-----------------------------------------------------------------------------
// 8-bit AXI-Stream File TX playback
//
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (c) 2023-25, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module nanosoc_axi_stream_io_8_txd_from_datafile
  #(parameter TXDFILENAME = "data.txt",
    parameter WAITSTATE = 0,
    parameter VERBOSE = 0)
  (
  input  wire  aclk,
  input  wire  aresetn,
  input  wire  txd8_ready,
  output wire  txd8_valid,
  output wire  [7:0] txd8_data
  );


 //----------------------------------------------
 //-- File I/O
 //----------------------------------------------


   integer        fd;       // channel descriptor for cmd file input
   integer        ch;
   integer        i;
   
`define EOF -1

   reg       valid;
   reg [7:0] data8;
   reg       eot; // Ctrl-D encountered
   
   initial
     begin
       eot <= 1'b0;
       valid <= 1'b0;
//       $timeformat(-9, 0, " ns", 14);
       fd= $fopen(TXDFILENAME,"r");
       if (fd == 0)
          $write("** %m : input file failed to open **\n");
       else begin
         @(posedge aresetn);
         ch =  $fgetc(fd);
         while ((ch != `EOF) && (!eot)) begin
           @(posedge aclk);
           data8 <= (ch & 8'hff);
           valid <= 1'b1;
           if (ch == 8'h04)
               eot <= 1'b1;
           @(posedge aclk);
           while (txd8_ready == 1'b0)
             @(posedge aclk);
           valid <= 1'b0;
           ch =  (eot) ? `EOF : $fgetc(fd);
           for (i=0; i <  WAITSTATE; i=i+1)
             @(posedge aclk);
         end
         $write("** %m : file closed after stream TX completed **\n");
         $fclose(fd);
         valid <= 1'b0;
       end
     end

assign txd8_valid = valid;
assign txd8_data = data8;

endmodule
