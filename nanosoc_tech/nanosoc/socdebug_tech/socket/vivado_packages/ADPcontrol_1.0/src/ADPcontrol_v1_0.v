//-----------------------------------------------------------------------------
// top-level soclabs ASCII Debug Protocol controller
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright � 2021-2, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

	module ADPcontrol_v1_0 #
	(
		// Users to add parameters here
    parameter PROMPT_CHAR          = "]"

		// User parameters ends
		// Do not modify the parameters beyond this line

	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line

		// Ports of Axi Slave Bus Interface com_rx
		input wire  ahb_hclk,
		input wire  ahb_hresetn,
		
		output wire com_rx_tready,
		input wire [7 : 0] com_rx_tdata,
		input wire  com_rx_tvalid,

		// Ports of Axi Master Bus Interface com_tx
		output wire  com_tx_tvalid,
		output wire [7 : 0] com_tx_tdata,
		input wire  com_tx_tready,

		// Ports of Axi Slave Bus Interface stdio_rx
		output wire  stdio_rx_tready,
		input wire [7 : 0] stdio_rx_tdata,
		input wire  stdio_rx_tvalid,

		// Ports of Axi Master Bus Interface stdio_tx
		output wire  stdio_tx_tvalid,
		output wire [7 : 0] stdio_tx_tdata,
		input wire  stdio_tx_tready,

		output wire [7 : 0]    gpo8,
		input  wire [7 : 0]    gpi8,
		
        output wire [31:0]     ahb_haddr    ,
        output wire [ 2:0]     ahb_hburst   ,
        output wire            ahb_hmastlock,
        output wire [ 3:0]     ahb_hprot    ,
        output wire [ 2:0]     ahb_hsize    ,
        output wire [ 1:0]     ahb_htrans   ,
        output wire [31:0]     ahb_hwdata   ,
        output wire            ahb_hwrite   ,
        input  wire  [31:0]    ahb_hrdata   ,
        input  wire            ahb_hready   ,
        input  wire            ahb_hresp    
	);

	// Add user logic here

ADPmanager
   #(.PROMPT_CHAR     (PROMPT_CHAR))
 ADPmanager(
  .HCLK        (ahb_hclk      ),
  .HRESETn     (ahb_hresetn   ),
  .HADDR32_o   (ahb_haddr     ),
  .HBURST3_o   (ahb_hburst    ),
  .HMASTLOCK_o (ahb_hmastlock ),
  .HPROT4_o    (ahb_hprot     ),
  .HSIZE3_o    (ahb_hsize     ),
  .HTRANS2_o   (ahb_htrans    ),
  .HWDATA32_o  (ahb_hwdata    ),
  .HWRITE_o    (ahb_hwrite    ),
  .HRDATA32_i  (ahb_hrdata    ),
  .HREADY_i    (ahb_hready    ),
  .HRESP_i     (ahb_hresp     ),
  .GPO8_o      (gpo8          ),
  .GPI8_i      (gpi8          ),
  .COMRX_TREADY_o(com_rx_tready),
  .COMRX_TDATA_i(com_rx_tdata),
  .COMRX_TVALID_i(com_rx_tvalid),
  .STDRX_TREADY_o(stdio_rx_tready),
  .STDRX_TDATA_i(stdio_rx_tdata),
  .STDRX_TVALID_i(stdio_rx_tvalid),
  .COMTX_TVALID_o(com_tx_tvalid),
  .COMTX_TDATA_o(com_tx_tdata),
  .COMTX_TREADY_i(com_tx_tready),
  .STDTX_TVALID_o(stdio_tx_tvalid),
  .STDTX_TDATA_o(stdio_tx_tdata),
  .STDTX_TREADY_i(stdio_tx_tready)

  );


endmodule
