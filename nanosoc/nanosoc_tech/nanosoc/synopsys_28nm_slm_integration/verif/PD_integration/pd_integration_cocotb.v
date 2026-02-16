
module pd_integration_cocotb(
    input  wire                 HCLK,
    input  wire                 HRESETn,

    input  wire [32-1:0]        config_HADDR,
    input  wire [1:0]           config_HTRANS,
    input  wire                 config_HWRITE,
    input  wire [2:0]           config_HSIZE,
    input  wire [2:0]           config_HBURST,
    input  wire [32-1:0]        config_HWDATA,
    input  wire                 config_HSEL,
    output wire [32-1:0]        config_HRDATA,
    input  wire                 config_HREADY_IN,
    output wire                 config_HREADY,
    output wire                 config_HRESP
);

wire [3:0]       config_HPROT;
assign config_HPROT = 4'b0010;

wire [15:0]          PADDR;
wire [2:0]           PPROT;
wire                 PSEL;
wire                 PENABLE;
wire                 PWRITE;
wire [31:0]          PWDATA;
wire [3:0]           PSTRB;
wire [31:0]          PRDATA;
wire                 PREADY;
wire                 PSLVERR;

wire   irq_pd_rdy;

cmsdk_ahb_to_apb #(
    .ADDRWIDTH(16),
    .REGISTER_RDATA(1),
    .REGISTER_WDATA(0)
) u_cmsdk_ahb_to_apb (
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .PCLKEN(1'b1),

    .HSEL(config_HSEL),
    .HADDR(config_HADDR[15:0]),
    .HTRANS(config_HTRANS),
    .HSIZE(config_HSIZE),
    .HPROT(config_HPROT),
    .HWRITE(config_HWRITE),
    .HREADY(config_HREADY_IN),
    .HWDATA(config_HWDATA),

    .HREADYOUT(config_HREADY),
    .HRDATA(config_HRDATA),
    .HRESP(config_HRESP),

    .PADDR(PADDR),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PSTRB(PSTRB),
    .PPROT(PPROT),
    .PWDATA(PWDATA),
    .PSEL(PSEL),
    .APBACTIVE(),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR)
);

initial begin 
    $sdf_annotate("/home/dwn1c21/SoC-Labs/synopsys_28nm_slm_integration/imp/PD/PD_integration_layer_gates.sdf", u_synopsys_PD_sensor_integration);
end


synopsys_PD_sensor_integration u_synopsys_PD_sensor_integration(
    .PCLK(HCLK),
    .PRESETn(HRESETn),
    .PSELx(PSEL),
    .PADDR(PADDR[3:0]),
    .PENABLE(PENABLE),
    .PPROT(PPROT),
    .PSTRB(PSTRB),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR),
    .irq_pd_rdy(irq_pd_rdy)
);

endmodule
