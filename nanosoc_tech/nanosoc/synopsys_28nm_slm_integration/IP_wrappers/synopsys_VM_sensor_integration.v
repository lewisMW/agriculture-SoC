module synopsys_VM_sensor_integration(
    input  wire             PCLK,
    input  wire             aRESETn,

    input  wire             PSELx,     
    input  wire [1:0]       PADDR,    
    input  wire             PENABLE, 
    input  wire [2:0]       PPROT, 
    input  wire [3:0]       PSTRB,
    input  wire             PWRITE,   
    input  wire [31:0]      PWDATA,   
    output wire [31:0]      PRDATA,   
    output wire             PREADY,   
    output wire             PSLVERR,

    output wire             irq_vm_rdy
);



mr74140 u_snps_VM(
    .clk(),    
    .pd(),     
    .run(),    
    .rstn(),   
    .sde(1'b0),    
    .tm_se(),  
    .tm_si(),  
    .tm_tval(),
    .tm_ld(),  
    .tm_te(),  
    .sel_vin0(),
    .sel_vin1(),
    .sel_vin2(),
    .sel_vin3(),
    .trim0(),  
    .trim1(),  
    .trim2(),  
    .trim3(),  
    .tm_a0(),  
    .tm_a1(),  
    .tm_a2(),  
    .tm_a3(),  
    .an_vm0(), 
    .an_vm1(), 
    .an_vm2(), 
    .an_vm3(), 
    .an_vm4(), 
    .an_vm5(), 
    .an_vm6(), 
    .an_vm7(), 
    .an_vref(),
    .rdy(),    
    .dout0(),  
    .dout1(),  
    .dout2(),  
    .dout3(),  
    .dout4(),  
    .dout5(),  
    .dout6(),  
    .dout7(),  
    .dout8(),  
    .dout9(),  
    .dout10(), 
    .dout11(), 
    .tm_so()   
);

endmodule
