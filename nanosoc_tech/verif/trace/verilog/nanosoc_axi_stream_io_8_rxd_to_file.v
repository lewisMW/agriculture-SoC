//-----------------------------------------------------------------------------
// customised example Cortex-M0 controller UART with file logging
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (C) 2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Abstract : FT1248 1-bit data off-chip interface (emulate FT232H device)
// and allows cmsdk_uart_capture testbench models to log ADP ip, op streams
//-----------------------------------------------------------------------------


module nanosoc_axi_stream_io_8_rxd_to_file
  #(parameter RXDFILENAME = "rxd.log",
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
`define EOF -1

   reg       ready;
   reg [7:0] data8;
   
   reg       nxt_end_simulation;
   reg       reg_end_simulation;
  
   initial
     begin
       ready <= 0;
       nxt_end_simulation <= 1'b0;
       reg_end_simulation <= 1'b0;
       fd= $fopen(RXDFILENAME,"w");
       if (fd == 0)
          $write("** %m : output log file failed to open **\n");
       else begin
         @(posedge aresetn);
         while (!nxt_end_simulation) begin
           @(posedge aclk);
           ready <= 1'b1;
           @(posedge aclk);
           while (rxd8_valid == 1'b0)
             @(posedge aclk);
           ready <=0;
           data8 <= rxd8_data;
           ch = (rxd8_data & 8'hff);
           if  (ch==8'h04) // Stop simulation if 0x04 is received
             nxt_end_simulation <= 1'b1;
           else
             $fwrite(fd, "%c", ch);
         end
         $write("** %m : log file closed after stream RX terminated **\n");
         $fclose(fd);
         ready <= 0;
       end
     end

assign rxd8_ready = ready ;

endmodule
