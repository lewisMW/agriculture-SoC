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
// Abstract : track output stream for testbench signalling
//-----------------------------------------------------------------------------

module nanosoc_track_tb_iostream
  (
  input  wire       aclk,
  input  wire       aresetn,
  input  wire       rxd8_ready,
  input  wire       rxd8_valid,
  input  wire [7:0] rxd8_data,
  output wire       SIMULATIONEND,       // Simulation end indicator
  output wire       DEBUG_TESTER_ENABLE, // Enable debug tester
  output wire [7:0] AUXCTRL);            // Auxiliary control

   reg       ready;
   reg [7:0] data8;
   
   wire      nxt_end_simulation;
   reg       reg_end_simulation;
   reg       reg_esc_code_mode;  // Escape code mode
   reg       reg_aux_ctrl_mode;  // Auxiliary control capture mode
   reg [7:0] reg_aux_ctrl;       // Registered Auxiliary control
   reg       reg_dbgtester_enable;


assign nxt_end_simulation = (rxd8_valid & rxd8_ready & (rxd8_data==8'h04));

  // Delay for simulation end
  always @ (posedge aclk or negedge aresetn)
  begin: p_sim_end
  if (!aresetn)
    begin
    reg_end_simulation <= 1'b0;
    end
  else
    begin
    reg_end_simulation  <= nxt_end_simulation;
    if (reg_end_simulation==1'b1)
      begin
        $display("Test Ended due to Ctrl-D\n");
        $stop;
      end
    end
  end

  assign SIMULATIONEND = nxt_end_simulation & (!reg_end_simulation);

  // Escape code mode register
  always @(posedge aclk or negedge aresetn)
  begin
    if (!aresetn)
      reg_esc_code_mode <= 1'b0;
    else // Set to escape mode if ESC code is detected
      if (rxd8_valid & rxd8_ready & (reg_esc_code_mode==1'b0) & (rxd8_data==8'h1B))
        reg_esc_code_mode <= 1'b1;
      else if (rxd8_valid & rxd8_ready)
        reg_esc_code_mode <= 1'b0;
  end

  // Aux Ctrl capture mode register
  always @(posedge aclk or negedge aresetn)
  begin
    if (!aresetn)
      reg_aux_ctrl_mode <= 1'b0;
    else // Set to Aux control capture mode if ESC-0x10 sequence is detected
      if (rxd8_valid & rxd8_ready & (reg_esc_code_mode==1'b1) & (rxd8_data==8'h10))
        reg_aux_ctrl_mode <= 1'b1;
      else if (rxd8_valid & rxd8_ready)
        reg_aux_ctrl_mode <= 1'b0;
  end

  // Aux Ctrl capture data register
  always @(posedge aclk or negedge aresetn)
  begin
    if (!aresetn)
      reg_aux_ctrl <= {8{1'b0}};
    else // Capture received data to Aux control output if reg_aux_ctrl_mode is set
      if (rxd8_valid & rxd8_ready & (reg_aux_ctrl_mode==1'b1))
        reg_aux_ctrl <= rxd8_data;
  end

  assign AUXCTRL = reg_aux_ctrl;

  // Debug tester enable
  always @(posedge aclk or negedge aresetn)
  begin
    if (!aresetn)
      reg_dbgtester_enable <= 1'b0;
    else // Enable debug tester if ESC-0x11 sequence is detected
      if (rxd8_valid & rxd8_ready & (reg_esc_code_mode==1'b1) & (rxd8_data==8'h11))
        reg_dbgtester_enable <= 1'b1;
      else if (rxd8_valid & rxd8_ready & (reg_esc_code_mode==1'b1) & (rxd8_data==8'h12))
        // Disable debug tester if ESC-0x12 sequence is detected
        reg_dbgtester_enable <= 1'b0;
  end

  assign DEBUG_TESTER_ENABLE = reg_dbgtester_enable;

endmodule
