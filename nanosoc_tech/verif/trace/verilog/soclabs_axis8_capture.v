//-----------------------------------------------------------------------------
// soclabs 8-bit-axi-character stream capture
// based on Arm UART RXD capture with file logging adapted from Arm CMSDK Uart Capture
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (C) 2024, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from Arm Limited or its affiliates.
//
//            (C) COPYRIGHT 2010-2013 Arm Limited or its affiliates.
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
// Abstract : A device to capture serial data
//-----------------------------------------------------------------------------
// This module assume CLK is same frequency as baud rate.
// In the example UART a test mode is used to enable data output as maximum
// speed (PCLK).  In such case we can connect CLK signal directly to PCLK.
// Otherwise, if the UART baud rate is reduced, the CLK rate has to be reduced
// accordingly as well.
//
// This module stop the simulation when character 0x04 is received.
// An output called SIMULATION_END is set for 1 cycle before simulation is
// terminated to allow other testbench component like profiler (if any)
// to output reports before the simulation stop.
//
// This model also support ESCAPE (0x1B, decimal 27) code sequence
// ESC - 0x10 - XY    Capture XY to AUXCTRL output
// ESC - 0x11         Set DEBUG_TESTER_ENABLE to 1
// ESC - 0x12         Clear DEBUG_TESTER_ENABLE to 0


module soclabs_axis8_capture
  #(parameter LOGFILENAME = "soc_capture.log",
    parameter VERBOSE = 0)
  (
  input  wire       RESETn,              // Power on reset
  input  wire       CLK,                 // Clock (baud rate)
  input  wire       RXD,                 // Received data

  output wire       RXD8_READY,
  input  wire       RXD8_VALID,
  input  wire [7:0] RXD8_DATA,

  output wire       SIMULATIONEND,       // Simulation end indicator
  output wire       DEBUG_TESTER_ENABLE, // Enable debug tester
  output wire [7:0] AUXCTRL);            // Auxiliary control

  reg [8:0]        rx_shift_reg;
  wire [8:0]       nxt_rx_shift;
  reg [6:0]        string_length;
  reg [7:0]        tube_string [127:0];
  reg [7:0]        text_char;
  integer          i;
  reg              nxt_end_simulation;
  reg              reg_end_simulation;
  wire             char_received;
  reg              reg_esc_code_mode;  // Escape code mode
  reg              reg_aux_ctrl_mode;  // Auxiliary control capture mode
  reg [7:0]        reg_aux_ctrl;       // Registered Auxiliary control
  reg              reg_dbgtester_enable;

   integer        mcd;       // channel descriptor for log file output
   reg [40*8-1:0] log_file;  // File name can't be > *40* characters


assign RXD8_READY = rx_shift_reg[0]; // ready except for a cycle processing

`define SimSTDOUT 32'h00000001
   initial
     begin
       $timeformat(-9, 0, " ns", 14);
       log_file = LOGFILENAME;
       mcd = $fopen(log_file);
       mcd = mcd | `SimSTDOUT; // always echo to console
       if(mcd == 0) begin
         $fwrite(mcd,"soclabs_axis8_capture: Error, zero returned in response to $fopen\n");
         $finish(2);
       end
       $fwrite(mcd,"soclabs_axis8_capture: Generating output file %0s using MCD %x @ %m\n",
              log_file, mcd);
     end

  // Receive shift register
  assign nxt_rx_shift  = {RXD,rx_shift_reg[8:1]};
  assign char_received = (rx_shift_reg[0]==1'b0);
/*
  always @(posedge CLK or negedge RESETn)
  begin
    if (~RESETn)
      rx_shift_reg <= {9{1'b0}};
    else
      if (rx_shift_reg[0]==1'b0) // Start bit reach bit[0]
        rx_shift_reg <= {9{1'b1}};
      else
        rx_shift_reg <= nxt_rx_shift;
  end
*/

// ARM design wants valid char in rx_shift_reg[9:1]
// and a zero in rx_shift_reg[0] to indicate valid start bit (so preset back to 1 after a clock cycle)
  always @(posedge CLK or negedge RESETn)
  begin
    if (~RESETn)
      rx_shift_reg <= {9{1'b1}};
    else if (rx_shift_reg[0]== 1'b0) // if LSB zero, preset a clock cycle later
      rx_shift_reg <= {9{1'b1}};
    else if (rx_shift_reg[0] & RXD8_VALID) //ready and valid data capture
      rx_shift_reg[8:0] <= {RXD8_DATA[7:0], 1'b0}; 
  end


  // Escape code mode register
  always @(posedge CLK or negedge RESETn)
  begin
    if (~RESETn)
      reg_esc_code_mode <= 1'b0;
    else // Set to escape mode if ESC code is detected
      if (char_received & (reg_esc_code_mode==1'b0) & (rx_shift_reg[8:1]==8'h1B))
        reg_esc_code_mode <= 1'b1;
      else if (char_received)
        reg_esc_code_mode <= 1'b0;
  end

  // Aux Ctrl capture mode register
  always @(posedge CLK or negedge RESETn)
  begin
    if (~RESETn)
      reg_aux_ctrl_mode <= 1'b0;
    else // Set to Aux control capture mode if ESC-0x10 sequence is detected
      if (char_received & (reg_esc_code_mode==1'b1) & (rx_shift_reg[8:1]==8'h10))
        reg_aux_ctrl_mode <= 1'b1;
      else if (char_received)
        reg_aux_ctrl_mode <= 1'b0;
  end

  // Aux Ctrl capture data register
  always @(posedge CLK or negedge RESETn)
  begin
    if (~RESETn)
      reg_aux_ctrl <= {8{1'b0}};
    else // Capture received data to Aux control output if reg_aux_ctrl_mode is set
      if (char_received & (reg_aux_ctrl_mode==1'b1))
        reg_aux_ctrl <= rx_shift_reg[8:1];
  end

  assign AUXCTRL = reg_aux_ctrl;

  // Debug tester enable
  always @(posedge CLK or negedge RESETn)
  begin
    if (~RESETn)
      reg_dbgtester_enable <= 1'b0;
    else // Enable debug tester if ESC-0x11 sequence is detected
      if (char_received & (reg_esc_code_mode==1'b1) & (rx_shift_reg[8:1]==8'h11))
        reg_dbgtester_enable <= 1'b1;
      else if (char_received & (reg_esc_code_mode==1'b1) & (rx_shift_reg[8:1]==8'h12))
        // Disable debug tester if ESC-0x12 sequence is detected
        reg_dbgtester_enable <= 1'b0;
  end

  assign DEBUG_TESTER_ENABLE = reg_dbgtester_enable;

  // Message display
  always @ (posedge CLK or negedge RESETn)
  begin: p_tube
  if (~RESETn)
    begin
    string_length = 7'b0;
    nxt_end_simulation <= 1'b0;
    for (i=0; i<= 127; i=i+1) begin
       tube_string [i] = 8'h00;
    end
    end
  else
    if (char_received)
        begin
        if ((rx_shift_reg[8:1]==8'h1B) | reg_esc_code_mode | reg_aux_ctrl_mode )
          begin
          // Escape code, or in escape code mode
          // Data receive can be command, aux ctrl data
          // Ignore this data
          end
        else if  (rx_shift_reg[8:1]==8'h04) // Stop simulation if 0x04 is received
          nxt_end_simulation <= 1'b1;
        else if ((rx_shift_reg[8:1]==8'h0d)|(rx_shift_reg[8:1]==8'h0A))
          // New line
          begin
          tube_string[string_length] = 8'h00;
          if (VERBOSE != 0)
            $fwrite(mcd,"%t UART<%m>: ",$time);

          for (i=0; i<= string_length; i=i+1)
            begin
            text_char = tube_string[i];
            $fwrite(mcd,"%s",text_char);
            end

          $fwrite(mcd,"\n");
          string_length = 7'b0;
          end
        else
          begin
          tube_string[string_length] = rx_shift_reg[8:1];
          string_length = string_length + 1;
          if (string_length >79) // line too long, display and clear buffer
            begin
            tube_string[string_length] = 8'h00;
            if (VERBOSE != 0)
              $fwrite(mcd,"%t UART<%m>: ",$time);

            for (i=0; i<= string_length; i=i+1)
              begin
              text_char = tube_string[i];
              $fwrite(mcd,"%s",text_char);
              end

            $fwrite(mcd,"\n");
            string_length = 7'b0;

            end

          end

        end

  end // p_TUBE

  // Delay for simulation end
  always @ (posedge CLK or negedge RESETn)
  begin: p_sim_end
  if (~RESETn)
    begin
    reg_end_simulation <= 1'b0;
    end
  else
    begin
    reg_end_simulation  <= nxt_end_simulation;
    if (reg_end_simulation==1'b1)
      begin
        if (VERBOSE != 0)
          $fwrite(mcd,"%t stream_capture<%m>: Test Ended\n",$time);
        else
          $fwrite(mcd,"Test Ended\n");
      $stop;
      end
    end
  end

  assign SIMULATIONEND = nxt_end_simulation & (~reg_end_simulation);

endmodule
