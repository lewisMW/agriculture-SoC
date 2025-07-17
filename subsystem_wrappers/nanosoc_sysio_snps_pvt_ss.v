

module nanosoc_sysio_snps_pvt_ss #(
    parameter  SNPS_PVT_TS_0_ENABLE=0,
    parameter  SNPS_PVT_TS_1_ENABLE=0,
    parameter  SNPS_PVT_TS_2_ENABLE=0,
    parameter  SNPS_PVT_TS_3_ENABLE=0,
    parameter  SNPS_PVT_TS_4_ENABLE=0,
    parameter  SNPS_PVT_TS_5_ENABLE=0,
    parameter  SNPS_PVT_PD_0_ENABLE=0,
    parameter  SNPS_PVT_VM_0_ENABLE=0,
      // If peripherals are generated with asynchronous clock domain to HCLK of the processor
    // You might need to add synchroniser to the IRQ signal.
    // In this example APB subsystem, the IRQ synchroniser is used to all peripherals
    // when the INCLUDE_IRQ_SYNCHRONIZER parameter is set to 1. In practice you may have
    // some IRQ signals need to be synchronised and some do not.
    parameter  INCLUDE_IRQ_SYNCHRONIZER=0,


    // By default the APB subsystem include a simple test slave use in ARM for
    // validation purpose.  You can remove this test slave by setting the
    // INCLUDE_APB_TEST_SLAVE paramater to 0,
    parameter  INCLUDE_APB_TEST_SLAVE = 1,

    // Big endian - Add additional endian conversion logic to support big endian.
    //              (for ARM internal testing and evaluation of the processor in
    //              big endian configuration).
    //              0 = little endian, 1 = big endian
    //
    //              The example systems including this APB subsystem are designed as
    //              little endian. Most of the peripherals and memory system are
    //              little endian. This parameter is introduced to allows ARM to
    //              perform system level tests to verified behaviour of bus
    //              components in big endian configuration, and to allow designers
    //              to evaluate the processor in big endian configuration.
    //
    //              Use of this parameter is not recommended for actual product
    //              development as this adds extra hardware. For big endian systems
    //              ideally the peripherals should be modified to use a big endian
    //              programmer's model.
    parameter  BE = 0)(
    input  wire           TS_VCAL,
    output wire           TS_VSS_SENSE,
    inout  wire [3:0]     TS_AN_TEST,
    output wire [5:0]     irq_ts_rdy,
    output wire           irq_pd_rdy,
    output wire           irq_vm_rdy,
    input  wire           HCLK,
    input  wire           HRESETn,

    input  wire           HSEL,
    input  wire   [15:0]  HADDR,
    input  wire    [1:0]  HTRANS,
    input  wire           HWRITE,
    input  wire    [2:0]  HSIZE,
    input  wire    [3:0]  HPROT,
    input  wire           HREADY,
    input  wire   [31:0]  HWDATA,
    output wire           HREADYOUT,
    output wire   [31:0]  HRDATA,
    output wire           HRESP,

    input  wire           PCLK,    // Peripheral clock
    input  wire           PCLKG,   // Gate PCLK for bus interface only
    input  wire           PCLKEN,  // Clock divider for AHB to APB bridge
    input  wire           PRESETn // APB reset

);

    // --------------------------------------------------------------------------
    // Internal wires
    // --------------------------------------------------------------------------
    wire     [15:0]  i_paddr;
    wire             i_psel;
    wire             i_penable;
    wire             i_pwrite;
    wire     [2:0]   i_pprot;
    wire     [3:0]   i_pstrb;
    wire     [31:0]  i_pwdata;

    // wire from APB slave mux to APB bridge
    wire             i_pready_mux;
    wire     [31:0]  i_prdata_mux;
    wire             i_pslverr_mux;

    wire            snps_PVT_ts0_psel;
    wire            snps_PVT_ts0_pready;
    wire [31:0]     snps_PVT_ts0_prdata;
    wire            snps_PVT_ts0_pslverr;

    wire            snps_PVT_ts1_psel;
    wire            snps_PVT_ts1_pready;
    wire [31:0]     snps_PVT_ts1_prdata;
    wire            snps_PVT_ts1_pslverr;

    wire            snps_PVT_ts2_psel;
    wire            snps_PVT_ts2_pready;
    wire [31:0]     snps_PVT_ts2_prdata;
    wire            snps_PVT_ts2_pslverr;

    wire            snps_PVT_ts3_psel;
    wire            snps_PVT_ts3_pready;
    wire [31:0]     snps_PVT_ts3_prdata;
    wire            snps_PVT_ts3_pslverr;

    wire            snps_PVT_ts4_psel;
    wire            snps_PVT_ts4_pready;
    wire [31:0]     snps_PVT_ts4_prdata;
    wire            snps_PVT_ts4_pslverr;

    wire            snps_PVT_ts5_psel;
    wire            snps_PVT_ts5_pready;
    wire [31:0]     snps_PVT_ts5_prdata;
    wire            snps_PVT_ts5_pslverr;

    wire            snps_PVT_pd0_psel;
    wire            snps_PVT_pd0_pready;
    wire [31:0]     snps_PVT_pd0_prdata;
    wire            snps_PVT_pd0_pslverr;
 
    wire            snps_PVT_vm0_psel;
    wire            snps_PVT_vm0_pready;
    wire [31:0]     snps_PVT_vm0_prdata;
    wire            snps_PVT_vm0_pslverr;

    // endian handling
    wire             bigendian;
    assign           bigendian = (BE!=0) ? 1'b1 : 1'b0;

    wire   [31:0]    hwdata_le; // Little endian write data
    wire   [31:0]    hrdata_le; // Little endian read data
    wire             reg_be_swap_ctrl_en = HSEL & HTRANS[1] & HREADY & bigendian;
    reg     [1:0]    reg_be_swap_ctrl; // registered byte swap control
    wire    [1:0]    nxt_be_swap_ctrl; // next state of byte swap control

    assign nxt_be_swap_ctrl[1] = bigendian & (HSIZE[1:0]==2'b10); // Swap upper and lower half word
    assign nxt_be_swap_ctrl[0] = bigendian & (HSIZE[1:0]!=2'b00); // Swap byte within hafword

    // Register byte swap control for data phase
    always @(posedge HCLK or negedge HRESETn)
        begin
        if (~HRESETn)
        reg_be_swap_ctrl <= 2'b00;
        else if (reg_be_swap_ctrl_en)
        reg_be_swap_ctrl <= nxt_be_swap_ctrl;
        end

    // swap byte within half word
    wire  [31:0] hwdata_mux_1 = (reg_be_swap_ctrl[0] & bigendian) ?
        {HWDATA[23:16],HWDATA[31:24],HWDATA[7:0],HWDATA[15:8]}:
        {HWDATA[31:24],HWDATA[23:16],HWDATA[15:8],HWDATA[7:0]};
    // swap lower and upper half word
    assign       hwdata_le    = (reg_be_swap_ctrl[1] & bigendian) ?
        {hwdata_mux_1[15: 0],hwdata_mux_1[31:16]}:
        {hwdata_mux_1[31:16],hwdata_mux_1[15:0]};
    // swap byte within half word
    wire  [31:0] hrdata_mux_1 = (reg_be_swap_ctrl[0] & bigendian) ?
        {hrdata_le[23:16],hrdata_le[31:24],hrdata_le[ 7:0],hrdata_le[15:8]}:
        {hrdata_le[31:24],hrdata_le[23:16],hrdata_le[15:8],hrdata_le[7:0]};
    // swap lower and upper half word
    assign       HRDATA       = (reg_be_swap_ctrl[1] & bigendian) ?
        {hrdata_mux_1[15: 0],hrdata_mux_1[31:16]}:
        {hrdata_mux_1[31:16],hrdata_mux_1[15:0]};

    // AHB to APB bus bridge
    cmsdk_ahb_to_apb
    #(.ADDRWIDTH      (16),
        .REGISTER_RDATA (1),
        .REGISTER_WDATA (0))
    u_ahb_to_apb(
        // AHB side
        .HCLK     (HCLK),
        .HRESETn  (HRESETn),
        .HSEL     (HSEL),
        .HADDR    (HADDR[15:0]),
        .HTRANS   (HTRANS),
        .HSIZE    (HSIZE),
        .HPROT    (HPROT),
        .HWRITE   (HWRITE),
        .HREADY   (HREADY),
        .HWDATA   (hwdata_le),

        .HREADYOUT(HREADYOUT), // AHB Outputs
        .HRDATA   (hrdata_le),
        .HRESP    (HRESP),

        .PADDR    (i_paddr[15:0]),
        .PSEL     (i_psel),
        .PENABLE  (i_penable),
        .PSTRB    (i_pstrb),
        .PPROT    (i_pprot),
        .PWRITE   (i_pwrite),
        .PWDATA   (i_pwdata),

        .APBACTIVE(APBACTIVE),
        .PCLKEN   (PCLKEN),     // APB clock enable signal

        .PRDATA   (i_prdata_mux),
        .PREADY   (i_pready_mux),
        .PSLVERR  (i_pslverr_mux)
        );

cmsdk_apb_slave_mux #(
    .PORT0_ENABLE  (SNPS_PVT_TS_0_ENABLE),
    .PORT1_ENABLE  (SNPS_PVT_TS_1_ENABLE),
    .PORT2_ENABLE  (SNPS_PVT_TS_2_ENABLE),
    .PORT3_ENABLE  (SNPS_PVT_TS_3_ENABLE),
    .PORT4_ENABLE  (SNPS_PVT_TS_4_ENABLE),
    .PORT5_ENABLE  (SNPS_PVT_TS_5_ENABLE),
    .PORT6_ENABLE  (SNPS_PVT_PD_0_ENABLE),
    .PORT7_ENABLE  (SNPS_PVT_VM_0_ENABLE),
    .PORT8_ENABLE  (0),
    .PORT9_ENABLE  (0),
    .PORT10_ENABLE (0),
    .PORT11_ENABLE (0),
    .PORT12_ENABLE (0),
    .PORT13_ENABLE (0),
    .PORT14_ENABLE (0),
    .PORT15_ENABLE (0)
) u_apb_PVT_slave_mux ( 
    // Inputs
    .DECODE4BIT        (i_paddr[7:4]),
    .PSEL              (i_psel),
    // PSEL (output) and return status & data (inputs) for each port
    .PSEL0             (snps_PVT_ts0_psel),
    .PREADY0           (snps_PVT_ts0_pready),
    .PRDATA0           (snps_PVT_ts0_prdata),
    .PSLVERR0          (snps_PVT_ts0_pslverr),

    .PSEL1             (snps_PVT_ts1_psel),
    .PREADY1           (snps_PVT_ts1_pready),
    .PRDATA1           (snps_PVT_ts1_prdata),
    .PSLVERR1          (snps_PVT_ts1_pslverr),

    .PSEL2             (snps_PVT_ts2_psel),
    .PREADY2           (snps_PVT_ts2_pready),
    .PRDATA2           (snps_PVT_ts2_prdata),
    .PSLVERR2          (snps_PVT_ts2_pslverr),

    .PSEL3             (snps_PVT_ts3_psel),
    .PREADY3           (snps_PVT_ts3_pready),
    .PRDATA3           (snps_PVT_ts3_prdata),
    .PSLVERR3          (snps_PVT_ts3_pslverr),

    .PSEL4             (snps_PVT_ts4_psel),
    .PREADY4           (snps_PVT_ts4_pready),
    .PRDATA4           (snps_PVT_ts4_prdata),
    .PSLVERR4          (snps_PVT_ts4_pslverr),

    .PSEL5             (snps_PVT_ts5_psel),
    .PREADY5           (snps_PVT_ts5_pready),
    .PRDATA5           (snps_PVT_ts5_prdata),
    .PSLVERR5          (snps_PVT_ts5_pslverr),

    .PSEL6             (snps_PVT_pd0_psel),
    .PREADY6           (snps_PVT_pd0_pready),
    .PRDATA6           (snps_PVT_pd0_prdata),
    .PSLVERR6          (snps_PVT_pd0_pslverr),

    .PSEL7             (snps_PVT_vm0_psel),
    .PREADY7           (snps_PVT_vm0_pready),
    .PRDATA7           (snps_PVT_vm0_prdata),
    .PSLVERR7          (snps_PVT_vm0_pslverr),

    .PSEL8             (psel8),
    .PREADY8           (1'b1),
    .PRDATA8           (32'h00000000),
    .PSLVERR8          (1'b1),

    .PSEL9             (psel9),
    .PREADY9           (1'b1),
    .PRDATA9           (32'h00000000),
    .PSLVERR9          (1'b1),

    .PSEL10            (psel10),
    .PREADY10          (1'b1),
    .PRDATA10          (32'h00000000),
    .PSLVERR10         (1'b1),

    .PSEL11            (psel11),
    .PREADY11          (1'b1),
    .PRDATA11          (32'h00000000),
    .PSLVERR11         (1'b1),

    .PSEL12            (psel12),
    .PREADY12          (1'b1),
    .PRDATA12          (32'h00000000),
    .PSLVERR12         (1'b1),

    .PSEL13            (psel13),
    .PREADY13          (1'b1),
    .PRDATA13          (32'h00000000),
    .PSLVERR13         (1'b1),

    .PSEL14            (psel14),
    .PREADY14          (1'b1),
    .PRDATA14          (32'h00000000),
    .PSLVERR14         (1'b1),

    .PSEL15            (psel15),
    .PREADY15          (1'b1),
    .PRDATA15          (32'h00000000),
    .PSLVERR15         (1'b1),

    // Output
    .PREADY            (i_pready_mux),
    .PRDATA            (i_prdata_mux),
    .PSLVERR           (i_pslverr_mux)
    );  

generate if(SNPS_PVT_TS_0_ENABLE==1)begin: gen_snps_PVT_ts0
    synopsys_TS_sensor_integration u_snps_PVT_ts0(
        .PCLK(PCLK),
        .aRESETn(HRESETn),

        .PSELx(snps_PVT_ts0_psel),     
        .PADDR(i_paddr[3:2]),    
        .PENABLE(i_penable), 
        .PPROT(i_pprot), 
        .PSTRB(i_pstrb),
        .PWRITE(i_pwrite),   
        .PWDATA(i_pwdata),   
        .PRDATA(snps_PVT_ts0_prdata),   
        .PREADY(snps_PVT_ts0_pready),   
        .PSLVERR(snps_PVT_ts0_pslverr),

        .ts_vcal(TS_VCAL),
        .ts_an_test(TS_AN_TEST),
        .ts_vss_sense(TS_VSS_SENSE),
        .irq_ts_rdy(irq_ts_rdy[0])
    );
end else begin: gen_no_snps_PVT_ts0
    assign snps_PVT_ts0_prdata = {32{1'b0}};
    assign snps_PVT_ts0_pready = 1'b1;
    assign snps_PVT_ts0_pslverr = 1'b1;
    assign irq_ts_rdy[0] = 1'b0;
end endgenerate 

generate if(SNPS_PVT_TS_1_ENABLE==1)begin: gen_snps_PVT_ts1
    synopsys_TS_sensor_integration u_snps_PVT_ts1(
        .PCLK(PCLK),
        .aRESETn(HRESETn),

        .PSELx(snps_PVT_ts1_psel),     
        .PADDR(i_paddr[3:2]),    
        .PENABLE(i_penable), 
        .PPROT(i_pprot), 
        .PSTRB(i_pstrb),
        .PWRITE(i_pwrite),   
        .PWDATA(i_pwdata),   
        .PRDATA(snps_PVT_ts1_prdata),   
        .PREADY(snps_PVT_ts1_pready),   
        .PSLVERR(snps_PVT_ts1_pslverr),

        .ts_vcal(TS_VCAL),
        .ts_an_test(TS_AN_TEST),
        .ts_vss_sense(TS_VSS_SENSE),
        .irq_ts_rdy(irq_ts_rdy[1])
    );
end else begin: gen_no_snps_PVT_ts1
    assign snps_PVT_ts1_prdata = {32{1'b0}};
    assign snps_PVT_ts1_pready = 1'b1;
    assign snps_PVT_ts1_pslverr = 1'b1;
    assign irq_ts_rdy[1] = 1'b0;
end endgenerate 

generate if(SNPS_PVT_TS_2_ENABLE==1)begin: gen_snps_PVT_ts2
    synopsys_TS_sensor_integration u_snps_PVT_ts2(
        .PCLK(PCLK),
        .aRESETn(HRESETn),

        .PSELx(snps_PVT_ts2_psel),     
        .PADDR(i_paddr[3:2]),    
        .PENABLE(i_penable), 
        .PPROT(i_pprot), 
        .PSTRB(i_pstrb),
        .PWRITE(i_pwrite),   
        .PWDATA(i_pwdata),   
        .PRDATA(snps_PVT_ts2_prdata),   
        .PREADY(snps_PVT_ts2_pready),   
        .PSLVERR(snps_PVT_ts2_pslverr),

        .ts_vcal(TS_VCAL),
        .ts_an_test(TS_AN_TEST),
        .ts_vss_sense(TS_VSS_SENSE),
        .irq_ts_rdy(irq_ts_rdy[2])
    );
end else begin: gen_no_snps_PVT_ts2
    assign snps_PVT_ts2_prdata = {32{1'b0}};
    assign snps_PVT_ts2_pready = 1'b1;
    assign snps_PVT_ts2_pslverr = 1'b1;
    assign irq_ts_rdy[2] = 1'b0;
end endgenerate 

generate if(SNPS_PVT_TS_3_ENABLE==1)begin: gen_snps_PVT_ts3
    synopsys_TS_sensor_integration u_snps_PVT_ts3(
        .PCLK(PCLK),
        .aRESETn(HRESETn),

        .PSELx(snps_PVT_ts3_psel),     
        .PADDR(i_paddr[3:2]),    
        .PENABLE(i_penable), 
        .PPROT(i_pprot), 
        .PSTRB(i_pstrb),
        .PWRITE(i_pwrite),   
        .PWDATA(i_pwdata),   
        .PRDATA(snps_PVT_ts3_prdata),   
        .PREADY(snps_PVT_ts3_pready),   
        .PSLVERR(snps_PVT_ts3_pslverr),

        .ts_vcal(TS_VCAL),
        .ts_an_test(TS_AN_TEST),
        .ts_vss_sense(TS_VSS_SENSE),
        .irq_ts_rdy(irq_ts_rdy[3])
    );
end else begin: gen_no_snps_PVT_ts3
    assign snps_PVT_ts3_prdata = {32{1'b0}};
    assign snps_PVT_ts3_pready = 1'b1;
    assign snps_PVT_ts3_pslverr = 1'b1;
    assign irq_ts_rdy[3] = 1'b0;
end endgenerate 

generate if(SNPS_PVT_TS_4_ENABLE==1)begin: gen_snps_PVT_ts4
    synopsys_TS_sensor_integration u_snps_PVT_ts4(
        .PCLK(PCLK),
        .aRESETn(HRESETn),

        .PSELx(snps_PVT_ts4_psel),     
        .PADDR(i_paddr[3:2]),    
        .PENABLE(i_penable), 
        .PPROT(i_pprot), 
        .PSTRB(i_pstrb),
        .PWRITE(i_pwrite),   
        .PWDATA(i_pwdata),   
        .PRDATA(snps_PVT_ts4_prdata),   
        .PREADY(snps_PVT_ts4_pready),   
        .PSLVERR(snps_PVT_ts4_pslverr),

        .ts_vcal(TS_VCAL),
        .ts_an_test(TS_AN_TEST),
        .ts_vss_sense(TS_VSS_SENSE),
        .irq_ts_rdy(irq_ts_rdy[4])
    );
end else begin: gen_no_snps_PVT_ts4
    assign snps_PVT_ts4_prdata = {32{1'b0}};
    assign snps_PVT_ts4_pready = 1'b1;
    assign snps_PVT_ts4_pslverr = 1'b1;
    assign irq_ts_rdy[4] = 1'b0;
end endgenerate 

generate if(SNPS_PVT_TS_5_ENABLE==1)begin: gen_snps_PVT_ts5
    synopsys_TS_sensor_integration u_snps_PVT_ts5(
        .PCLK(PCLK),
        .aRESETn(HRESETn),

        .PSELx(snps_PVT_ts5_psel),     
        .PADDR(i_paddr[3:2]),    
        .PENABLE(i_penable), 
        .PPROT(i_pprot), 
        .PSTRB(i_pstrb),
        .PWRITE(i_pwrite),   
        .PWDATA(i_pwdata),   
        .PRDATA(snps_PVT_ts5_prdata),   
        .PREADY(snps_PVT_ts5_pready),   
        .PSLVERR(snps_PVT_ts5_pslverr),

        .ts_vcal(TS_VCAL),
        .ts_an_test(TS_AN_TEST),
        .ts_vss_sense(TS_VSS_SENSE),
        .irq_ts_rdy(irq_ts_rdy[5])
    );
end else begin: gen_no_snps_PVT_ts5
    assign snps_PVT_ts5_prdata = {32{1'b0}};
    assign snps_PVT_ts5_pready = 1'b1;
    assign snps_PVT_ts5_pslverr = 1'b1;
    assign irq_ts_rdy[5] = 1'b0;
end endgenerate 

generate if(SNPS_PVT_PD_0_ENABLE==1)begin: gen_snps_PVT_pd0
    synopsys_PD_sensor_integration u_snps_PVT_pd0(
        .PCLK(PCLK),
        .aRESETn(HRESETn),
        .PSELx(snps_PVT_pd0_psel),     
        .PADDR(i_paddr[3:2]),    
        .PENABLE(i_penable), 
        .PPROT(i_pprot), 
        .PSTRB(i_pstrb),
        .PWRITE(i_pwrite),   
        .PWDATA(i_pwdata),   
        .PRDATA(snps_PVT_pd0_prdata),   
        .PREADY(snps_PVT_pd0_pready),   
        .PSLVERR(snps_PVT_pd0_pslverr),
        .irq_pd_rdy(irq_pd_rdy)
    );
end else begin: gen_no_snps_PVT_pd0
    assign snps_PVT_pd0_prdata = {32{1'b0}};
    assign snps_PVT_pd0_pready = 1'b1;
    assign snps_PVT_pd0_pslverr = 1'b1;
    assign irq_pd_rdy = 1'b0;
end endgenerate

generate if(SNPS_PVT_VM_0_ENABLE==1)begin: gen_snps_PVT_vm0


end else begin: gen_no_snps_PVT_vm0
    assign snps_PVT_vm0_prdata = {32{1'b0}};
    assign snps_PVT_vm0_pready = 1'b1;
    assign snps_PVT_vm0_pslverr = 1'b1;
    assign irq_vm_rdy = 1'b0;
end endgenerate

endmodule