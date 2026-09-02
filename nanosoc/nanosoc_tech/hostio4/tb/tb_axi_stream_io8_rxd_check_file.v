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

module tb_axi_stream_io8_rxd_check_file
  #(parameter FILENAME = "rxd-ref.log",
    parameter VERBOSE = 0)
  (
  input  wire       aclk,
  input  wire       aresetn,
  output wire       rxd8_ready,
  input  wire       rxd8_valid,
  input  wire [7:0] rxd8_data
  );

 //----------------------------------------------
 //-- File I/O
 //----------------------------------------------


   integer        fd;       // channel descriptor for cmd file input
   integer        ch;
   integer        warnings;
`define EOF -1

   reg       ready;
   reg [7:0] data8;
   
   initial
     begin
       ready <= 0;
       fd= $fopen(FILENAME,"r");
       warnings = 0;
       if (fd == 0)
          $write("** %m : reference log file failed to open **\n");
       else begin
 //        $write("** %m : output log file opened **\n");
         @(posedge aresetn);
//         while (!nxt_end_simulation) begin
         while (!$feof(fd)) begin
           ch = $fgetc(fd);
           @(posedge aclk);
           ready <= 1'b1;
           @(posedge aclk);
           while (rxd8_valid == 1'b0)
             @(posedge aclk);
           ready <=0;
           data8 <= rxd8_data;
           if ((ch == `EOF) & (warnings==0))
             $write("** TEST PASSED ** (log file matches reference log) ** \n");
           else if (ch == `EOF)
             $write("** TEST FAILED ** (`diff` log file with reference log) - warning count %d** \n",warnings);
           else if ((rxd8_data != ch)) begin
             $write("**WARNING** Expected: 0x%02x, Read: 0x%02x\n", ch, rxd8_data);
             warnings = warnings+1;
             end
         end
         $fclose(fd);
         ready <= 0;
       end
     end

assign rxd8_ready = ready ;

endmodule
