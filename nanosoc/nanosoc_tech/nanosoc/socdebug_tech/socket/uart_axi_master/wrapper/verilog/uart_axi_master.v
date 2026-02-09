
`timescale 1 ns / 1 ps

	module uart_axi_master #
	(
		// Users to add parameters here
		parameter integer CLK_SPEED = 10000000,
        parameter integer UART_BAUD_RATE = 115200,

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Master Bus Interface M00_AXI
		parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
		parameter integer C_M00_AXI_BURST_LEN	= 16,
		parameter integer C_M00_AXI_ID_WIDTH	= 4,
		parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
		parameter integer C_M00_AXI_DATA_WIDTH	= 32,
		parameter integer C_M00_AXI_AWUSER_WIDTH	= 4,
		parameter integer C_M00_AXI_ARUSER_WIDTH	= 4,
		parameter integer C_M00_AXI_WUSER_WIDTH	= 4,
		parameter integer C_M00_AXI_RUSER_WIDTH	= 4,
		parameter integer C_M00_AXI_BUSER_WIDTH	= 4
	)
	(
		// Users to add ports her
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Master Bus Interface M00_AXI
		input wire UART_RX,
		output wire UART_TX,
		input wire  m00_axi_aclk,
		input wire  m00_axi_aresetn,
		output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_awid,
		output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
		output wire [7 : 0] m00_axi_awlen,
		output wire [2 : 0] m00_axi_awsize,
		output wire [1 : 0] m00_axi_awburst,
		output wire  m00_axi_awlock,
		output wire [3 : 0] m00_axi_awcache,
		output wire [2 : 0] m00_axi_awprot,
		output wire [3 : 0] m00_axi_awqos,
		output wire [C_M00_AXI_AWUSER_WIDTH-1 : 0] m00_axi_awuser,
		output wire  m00_axi_awvalid,
		input wire  m00_axi_awready,
		output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
		output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
		output wire  m00_axi_wlast,
		output wire [C_M00_AXI_WUSER_WIDTH-1 : 0] m00_axi_wuser,
		output wire  m00_axi_wvalid,
		input wire  m00_axi_wready,
		input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_bid,
		input wire [1 : 0] m00_axi_bresp,
		input wire [C_M00_AXI_BUSER_WIDTH-1 : 0] m00_axi_buser,
		input wire  m00_axi_bvalid,
		output wire  m00_axi_bready,
		output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_arid,
		output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
		output wire [7 : 0] m00_axi_arlen,
		output wire [2 : 0] m00_axi_arsize,
		output wire [1 : 0] m00_axi_arburst,
		output wire  m00_axi_arlock,
		output wire [3 : 0] m00_axi_arcache,
		output wire [2 : 0] m00_axi_arprot,
		output wire [3 : 0] m00_axi_arqos,
		output wire [C_M00_AXI_ARUSER_WIDTH-1 : 0] m00_axi_aruser,
		output wire  m00_axi_arvalid,
		input wire  m00_axi_arready,
		input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_rid,
		input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
		input wire [1 : 0] m00_axi_rresp,
		input wire  m00_axi_rlast,
		input wire [C_M00_AXI_RUSER_WIDTH-1 : 0] m00_axi_ruser,
		input wire  m00_axi_rvalid,
		output wire  m00_axi_rready
	);
// Instantiation of Axi Bus Interface M00_AXI
	
	// Add user logic here
    dbg_bridge #(.CLK_FREQ(CLK_SPEED),
     .UART_SPEED(UART_BAUD_RATE),
     .AXI_ID(4'd0),
     .GPIO_ADDRESS(32'hf0000000),
     .STS_ADDRESS(32'hf0000004)) 
    dbg_bridge_inst (
        .clk_i (m00_axi_aclk),
        .rst_i (~m00_axi_aresetn),
        .uart_rxd_i (UART_RX),
        .uart_txd_o (UART_TX),
        .gpio_inputs_i (),
        .gpio_outputs_o (),
        .mem_awready_i (m00_axi_awready),
        .mem_wready_i (m00_axi_wready),
        .mem_bvalid_i (m00_axi_bvalid),
        .mem_bresp_i (m00_axi_bresp),
        .mem_bid_i (m00_axi_bid),
        .mem_arready_i (m00_axi_arready),
        .mem_rvalid_i (m00_axi_rvalid),
        .mem_rdata_i (m00_axi_rdata),
        .mem_rresp_i (m00_axi_rresp),
        .mem_rid_i (m00_axi_rid),
        .mem_rlast_i (m00_axi_rlast),
        .mem_awvalid_o (m00_axi_awvalid),
        .mem_awaddr_o (m00_axi_awaddr),
        .mem_awid_o (m00_axi_awid),
        .mem_awlen_o (m00_axi_awlen),
        .mem_awburst_o (m00_axi_awburst),
        .mem_wvalid_o (m00_axi_wvalid),
        .mem_wdata_o (m00_axi_wdata),
        .mem_wstrb_o (m00_axi_wstrb),
        .mem_wlast_o (m00_axi_wlast),
        .mem_bready_o (m00_axi_bready),
        .mem_arvalid_o (m00_axi_arvalid),
        .mem_araddr_o (m00_axi_araddr),
        .mem_arid_o (m00_axi_arid),
        .mem_arlen_o (m00_axi_arlen),
        .mem_arburst_o (m00_axi_arburst),
        .mem_rready_o (m00_axi_rready)
    );
	// User logic ends

	endmodule
