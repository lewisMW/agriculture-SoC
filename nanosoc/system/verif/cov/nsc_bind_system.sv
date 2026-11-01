// -----------------------------------------------------------------------------
// nsc_bind_system.sv — binds for the nanosoc system-level coverage models.
// Targets are module TYPES, so these work unchanged in nanosoc_tb (real ARM IP,
// Xcelium/VCS/Questa) and in the Verilator harness. No RTL is modified.
// -----------------------------------------------------------------------------

// ---- Batch 1: sensing peripheral, AHB side ---------------------------------
bind accelerator_subsystem nsc_sens_ahb_cov u_nsc_sens_ahb_cov (
    .HCLK      (HCLK),
    .HRESETn   (HRESETn),
    .HSEL      (HSEL),
    .HADDR     (HADDR),
    .HTRANS    (HTRANS),
    .HSIZE     (HSIZE),
    .HPROT     (HPROT),
    .HWRITE    (HWRITE),
    .HREADY    (HREADY),
    .HREADYOUT (HREADYOUT),
    .HRESP     (HRESP),
    .clk1hz    (clk1hz),
    .EXP_IRQ   (EXP_IRQ)
);

// ---- Batch 2: bus matrix, every master port + every slave port ------------
bind nanosoc_busmatrix nsc_bus_cov u_nsc_bus_cov (
    .HCLK(HCLK), .HRESETn(HRESETn), .REMAP(REMAP),
    .HADDR_DEBUG(HADDR_DEBUG), .HTRANS_DEBUG(HTRANS_DEBUG), .HWRITE_DEBUG(HWRITE_DEBUG), .HSIZE_DEBUG(HSIZE_DEBUG),
    .HBURST_DEBUG(HBURST_DEBUG), .HPROT_DEBUG(HPROT_DEBUG), .HMASTLOCK_DEBUG(HMASTLOCK_DEBUG), .HREADY_DEBUG(HREADY_DEBUG),
    .HREADYOUT_DEBUG(HREADYOUT_DEBUG), .HRESP_DEBUG(HRESP_DEBUG),
    .HADDR_DMAC_0(HADDR_DMAC_0), .HTRANS_DMAC_0(HTRANS_DMAC_0), .HWRITE_DMAC_0(HWRITE_DMAC_0), .HSIZE_DMAC_0(HSIZE_DMAC_0),
    .HBURST_DMAC_0(HBURST_DMAC_0), .HPROT_DMAC_0(HPROT_DMAC_0), .HMASTLOCK_DMAC_0(HMASTLOCK_DMAC_0), .HREADY_DMAC_0(HREADY_DMAC_0),
    .HREADYOUT_DMAC_0(HREADYOUT_DMAC_0), .HRESP_DMAC_0(HRESP_DMAC_0),
    .HADDR_DMAC_1(HADDR_DMAC_1), .HTRANS_DMAC_1(HTRANS_DMAC_1), .HWRITE_DMAC_1(HWRITE_DMAC_1), .HSIZE_DMAC_1(HSIZE_DMAC_1),
    .HBURST_DMAC_1(HBURST_DMAC_1), .HPROT_DMAC_1(HPROT_DMAC_1), .HMASTLOCK_DMAC_1(HMASTLOCK_DMAC_1), .HREADY_DMAC_1(HREADY_DMAC_1),
    .HREADYOUT_DMAC_1(HREADYOUT_DMAC_1), .HRESP_DMAC_1(HRESP_DMAC_1),
    .HADDR_CPU_0(HADDR_CPU_0), .HTRANS_CPU_0(HTRANS_CPU_0), .HWRITE_CPU_0(HWRITE_CPU_0), .HSIZE_CPU_0(HSIZE_CPU_0),
    .HBURST_CPU_0(HBURST_CPU_0), .HPROT_CPU_0(HPROT_CPU_0), .HMASTLOCK_CPU_0(HMASTLOCK_CPU_0), .HREADY_CPU_0(HREADY_CPU_0),
    .HREADYOUT_CPU_0(HREADYOUT_CPU_0), .HRESP_CPU_0(HRESP_CPU_0)
);
bind nanosoc_target_output_BOOTROM_0 nsc_slave_port_cov #(.SLAVE_ID(0)) u_nsc_slave_port_cov (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .sel_op0(sel_op0), .trans_op0(trans_op0), .held_tran_op0(held_tran_op0), .active_op0(active_op0),
    .sel_op1(sel_op1), .trans_op1(trans_op1), .held_tran_op1(held_tran_op1), .active_op1(active_op1),
    .sel_op2(sel_op2), .trans_op2(trans_op2), .held_tran_op2(held_tran_op2), .active_op2(active_op2),
    .sel_op3(sel_op3), .trans_op3(trans_op3), .held_tran_op3(held_tran_op3), .active_op3(active_op3),
    .HSELM(HSELM), .HTRANSM(HTRANSM), .HWRITEM(HWRITEM), .HSIZEM(HSIZEM), .HREADYMUXM(HREADYMUXM)
);
bind nanosoc_target_output_IMEM_0 nsc_slave_port_cov #(.SLAVE_ID(1)) u_nsc_slave_port_cov (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .sel_op0(sel_op0), .trans_op0(trans_op0), .held_tran_op0(held_tran_op0), .active_op0(active_op0),
    .sel_op1(sel_op1), .trans_op1(trans_op1), .held_tran_op1(held_tran_op1), .active_op1(active_op1),
    .sel_op2(sel_op2), .trans_op2(trans_op2), .held_tran_op2(held_tran_op2), .active_op2(active_op2),
    .sel_op3(sel_op3), .trans_op3(trans_op3), .held_tran_op3(held_tran_op3), .active_op3(active_op3),
    .HSELM(HSELM), .HTRANSM(HTRANSM), .HWRITEM(HWRITEM), .HSIZEM(HSIZEM), .HREADYMUXM(HREADYMUXM)
);
bind nanosoc_target_output_DMEM_0 nsc_slave_port_cov #(.SLAVE_ID(2)) u_nsc_slave_port_cov (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .sel_op0(sel_op0), .trans_op0(trans_op0), .held_tran_op0(held_tran_op0), .active_op0(active_op0),
    .sel_op1(sel_op1), .trans_op1(trans_op1), .held_tran_op1(held_tran_op1), .active_op1(active_op1),
    .sel_op2(sel_op2), .trans_op2(trans_op2), .held_tran_op2(held_tran_op2), .active_op2(active_op2),
    .sel_op3(sel_op3), .trans_op3(trans_op3), .held_tran_op3(held_tran_op3), .active_op3(active_op3),
    .HSELM(HSELM), .HTRANSM(HTRANSM), .HWRITEM(HWRITEM), .HSIZEM(HSIZEM), .HREADYMUXM(HREADYMUXM)
);
bind nanosoc_target_output_SYSIO nsc_slave_port_cov #(.SLAVE_ID(3)) u_nsc_slave_port_cov (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .sel_op0(sel_op0), .trans_op0(trans_op0), .held_tran_op0(held_tran_op0), .active_op0(active_op0),
    .sel_op1(sel_op1), .trans_op1(trans_op1), .held_tran_op1(held_tran_op1), .active_op1(active_op1),
    .sel_op2(sel_op2), .trans_op2(trans_op2), .held_tran_op2(held_tran_op2), .active_op2(active_op2),
    .sel_op3(sel_op3), .trans_op3(trans_op3), .held_tran_op3(held_tran_op3), .active_op3(active_op3),
    .HSELM(HSELM), .HTRANSM(HTRANSM), .HWRITEM(HWRITEM), .HSIZEM(HSIZEM), .HREADYMUXM(HREADYMUXM)
);
bind nanosoc_target_output_EXPRAM_L nsc_slave_port_cov #(.SLAVE_ID(4)) u_nsc_slave_port_cov (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .sel_op0(sel_op0), .trans_op0(trans_op0), .held_tran_op0(held_tran_op0), .active_op0(active_op0),
    .sel_op1(sel_op1), .trans_op1(trans_op1), .held_tran_op1(held_tran_op1), .active_op1(active_op1),
    .sel_op2(sel_op2), .trans_op2(trans_op2), .held_tran_op2(held_tran_op2), .active_op2(active_op2),
    .sel_op3(sel_op3), .trans_op3(trans_op3), .held_tran_op3(held_tran_op3), .active_op3(active_op3),
    .HSELM(HSELM), .HTRANSM(HTRANSM), .HWRITEM(HWRITEM), .HSIZEM(HSIZEM), .HREADYMUXM(HREADYMUXM)
);
bind nanosoc_target_output_EXPRAM_H nsc_slave_port_cov #(.SLAVE_ID(5)) u_nsc_slave_port_cov (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .sel_op0(sel_op0), .trans_op0(trans_op0), .held_tran_op0(held_tran_op0), .active_op0(active_op0),
    .sel_op1(sel_op1), .trans_op1(trans_op1), .held_tran_op1(held_tran_op1), .active_op1(active_op1),
    .sel_op2(sel_op2), .trans_op2(trans_op2), .held_tran_op2(held_tran_op2), .active_op2(active_op2),
    .sel_op3(sel_op3), .trans_op3(trans_op3), .held_tran_op3(held_tran_op3), .active_op3(active_op3),
    .HSELM(HSELM), .HTRANSM(HTRANSM), .HWRITEM(HWRITEM), .HSIZEM(HSIZEM), .HREADYMUXM(HREADYMUXM)
);
bind nanosoc_target_output_EXP nsc_slave_port_cov #(.SLAVE_ID(6)) u_nsc_slave_port_cov (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .sel_op0(sel_op0), .trans_op0(trans_op0), .held_tran_op0(held_tran_op0), .active_op0(active_op0),
    .sel_op1(sel_op1), .trans_op1(trans_op1), .held_tran_op1(held_tran_op1), .active_op1(active_op1),
    .sel_op2(sel_op2), .trans_op2(trans_op2), .held_tran_op2(held_tran_op2), .active_op2(active_op2),
    .sel_op3(sel_op3), .trans_op3(trans_op3), .held_tran_op3(held_tran_op3), .active_op3(active_op3),
    .HSELM(HSELM), .HTRANSM(HTRANSM), .HWRITEM(HWRITEM), .HSIZEM(HSIZEM), .HREADYMUXM(HREADYMUXM)
);
bind nanosoc_target_output_SYSTABLE nsc_slave_port_cov #(.SLAVE_ID(7)) u_nsc_slave_port_cov (
    .HCLK(HCLK), .HRESETn(HRESETn),
    .sel_op0(sel_op0), .trans_op0(trans_op0), .held_tran_op0(held_tran_op0), .active_op0(active_op0),
    .sel_op1(1'b0), .trans_op1(2'b00), .held_tran_op1(1'b0), .active_op1(1'b0),
    .sel_op2(1'b0), .trans_op2(2'b00), .held_tran_op2(1'b0), .active_op2(1'b0),
    .sel_op3(sel_op3), .trans_op3(trans_op3), .held_tran_op3(held_tran_op3), .active_op3(active_op3),
    .HSELM(HSELM), .HTRANSM(HTRANSM), .HWRITEM(HWRITEM), .HSIZEM(HSIZEM), .HREADYMUXM(HREADYMUXM)
);

// ---- Batch 3: reset, clock control, system control -------------------------
bind nanosoc_system nsc_reset_cov u_nsc_reset_cov (
    .SYS_FCLK(SYS_FCLK), .SYS_SYSRESETn(SYS_SYSRESETn), .SYS_PORESETn(SYS_PORESETn),
    .SYS_HRESETn(SYS_HRESETn), .SYS_PRESETn(SYS_PRESETn),
    .CPU_SYSRESETREQ(CPU_SYSRESETREQ), .DEBUG_RESETREQ(DEBUG_RESETREQ),
    .SYS_WDOGRESETREQ(SYS_WDOGRESETREQ), .SYS_LOCKUPRESET(SYS_LOCKUPRESET),
    .CPU_LOCKUP(CPU_LOCKUP), .SYS_SYSRESETREQ(SYS_SYSRESETREQ), .CPU_SLEEPING(CPU_SLEEPING),
    .SYS_TESTMODE(SYS_TESTMODE), .CPU_0_HTRANS(CPU_0_HTRANS), .DEBUG_HTRANS(DEBUG_HTRANS),
    .DMAC_0_HTRANS(DMAC_0_HTRANS), .EXP_HSEL(EXP_HSEL), .EXP_HTRANS(EXP_HTRANS),
    .EXP_HREADYOUT(EXP_HREADYOUT), .SYSIO_HSEL(SYSIO_HSEL), .SYSIO_HTRANS(SYSIO_HTRANS)
);
bind nanosoc_clkctrl nsc_clkctrl_cov u_nsc_clkctrl_cov (
    .XTAL1(XTAL1), .NRST(NRST), .APBACTIVE(APBACTIVE), .SLEEPING(SLEEPING),
    .SLEEPDEEP(SLEEPDEEP), .SYSRESETREQ(SYSRESETREQ), .DBGRESETREQ(DBGRESETREQ),
    .LOCKUP(LOCKUP), .LOCKUPRESET(LOCKUPRESET), .CGBYPASS(CGBYPASS), .RSTBYPASS(RSTBYPASS),
    .XTAL2(XTAL2), .PCLKEN(PCLKEN), .PRESETn(PRESETn)
);
bind nanosoc_sysctrl nsc_sysctrl_cov u_nsc_sysctrl_cov (
    .HCLK(HCLK), .HRESETn(HRESETn), .FCLK(FCLK), .PORESETn(PORESETn), .HSEL(HSEL),
    .HREADY(HREADY), .HTRANS(HTRANS), .HSIZE(HSIZE), .HWRITE(HWRITE), .HADDR(HADDR),
    .HWDATA(HWDATA), .SYSRESETREQ(SYSRESETREQ), .WDOGRESETREQ(WDOGRESETREQ), .LOCKUP(LOCKUP),
    .reg_remap(reg_remap), .reg_pmuenable(reg_pmuenable), .reg_lockupreset(reg_lockupreset),
    .reg_resetinfo(reg_resetinfo), .reg_write_enable(reg_write_enable),
    .reg_read_enable(reg_read_enable), .reg_addr(reg_addr), .reg_byte_strobe(reg_byte_strobe),
    .read_mux_le(read_mux_le)
);

// ---- Batch 4: interrupts, low power, boot ----------------------------------
// sens_sample uses a hierarchical path into the expansion region; it exists in
// the tape-out configuration (`define ACCELERATOR_SUBSYSTEM in gen_defines.v).
bind nanosoc_system nsc_irq_lp_cov u_nsc_irq_lp_cov (
    .SYS_HCLK(SYS_HCLK), .SYS_HRESETn(SYS_HRESETn), .SYS_PORESETn(SYS_PORESETn),
    .CPU_0_IRQ(CPU_0_IRQ), .CPU_0_NMI(CPU_0_NMI), .SYS_APB_IRQ(SYS_APB_IRQ), .EXP_IRQ(EXP_IRQ),
    .SYS_GPIO0_IRQ(SYS_GPIO0_IRQ), .SYS_GPIO1_IRQ(SYS_GPIO1_IRQ),
    .DMAC_ANY_DONE(DMAC_ANY_DONE), .DMAC_ANY_ERROR(DMAC_ANY_ERROR),
    .CPU_SLEEPING(CPU_SLEEPING), .CPU_SLEEPDEEP(CPU_SLEEPDEEP), .CPU_LOCKUP(CPU_LOCKUP),
    .CPU_0_TXEV(CPU_0_TXEV), .CPU_0_RXEV(CPU_0_RXEV),
    .CPU_0_HADDR(CPU_0_HADDR), .CPU_0_HTRANS(CPU_0_HTRANS), .CPU_0_HPROT(CPU_0_HPROT),
    .CPU_0_HWRITE(CPU_0_HWRITE), .CPU_0_HREADY(CPU_0_HREADY), .DEBUG_HTRANS(DEBUG_HTRANS),
    .REMAP_CTRL0(SYS_REMAP_CTRL[0]),
    .sens_sample(u_ss_expansion.u_region_exp.u_ss_accelerator.sensor_wrapper.fifo_write_en)
);
bind slcorem0 nsc_pmu_cov u_nsc_pmu_cov (
    .SYS_FCLK(SYS_FCLK), .SYS_HRESETn(SYS_HRESETn), .CORE_PMUENABLE(CORE_PMUENABLE),
    .CORE_WICENREQ(CORE_WICENREQ), .CORE_WICENACK(CORE_WICENACK), .CORE_WAKEUP(CORE_WAKEUP),
    .CORE_SLEEPHOLDREQn(CORE_SLEEPHOLDREQn), .CORE_SLEEPHOLDACKn(CORE_SLEEPHOLDACKn),
    .CORE_GATEHCLK(CORE_GATEHCLK), .CORE_CDBGPWRUPREQ(CORE_CDBGPWRUPREQ),
    .CORE_CDBGPWRUPACK(CORE_CDBGPWRUPACK), .CORE_SLEEPING(CORE_SLEEPING),
    .CORE_SLEEPDEEP(CORE_SLEEPDEEP), .slv_trans(slv_trans), .CORE_SWCLK(CORE_SWCLK),
    .CORE_SWDOEN(CORE_SWDOEN)
);

// ---- Batch 5: SYSIO, APB slots, memory regions, ROM table -----------------
bind nanosoc_region_sysio nsc_sysio_region_cov u_nsc_sysio_region_cov (
    .HCLK(HCLK), .HRESETn(HRESETn), .HSEL(HSEL), .HADDR(HADDR), .HTRANS(HTRANS), .HWRITE(HWRITE),
    .HSIZE(HSIZE), .HREADY(HREADY), .HREADYOUT(HREADYOUT), .HRESP(HRESP),
    .apbsys_hsel(apbsys_hsel), .gpio0_hsel(gpio0_hsel), .gpio1_hsel(gpio1_hsel),
    .sysctrl_hsel(sysctrl_hsel), .defslv_hsel(defslv_hsel)
);
bind nanosoc_sysio_apb_ss nsc_apbss_cov u_nsc_apbss_cov (
    .PCLK(PCLK), .PRESETn(PRESETn), .i_paddr(i_paddr), .i_psel(i_psel), .i_penable(i_penable),
    .i_pwrite(i_pwrite), .i_pstrb(i_pstrb), .i_pready_mux(i_pready_mux), .i_pslverr_mux(i_pslverr_mux),
    .PCLKEN(PCLKEN), .APBACTIVE(APBACTIVE)
);
bind nanosoc_region_bootrom_0 nsc_mem_region_cov #(.REGION_ID(0), .PHYS_BYTES(1024), .IS_ROM(1'b1)) u_nsc_mem_region_cov (
    .HCLK(HCLK), .HRESETn(1'b1), .HSEL(HSEL), .HADDR(HADDR), .HTRANS(HTRANS), .HWRITE(HWRITE),
    .HSIZE(HSIZE), .HREADY(HREADY), .HREADYOUT(HREADYOUT), .HRESP(HRESP)
);
bind nanosoc_region_imem_0 nsc_mem_region_cov #(.REGION_ID(1), .PHYS_BYTES(16384), .IS_ROM(1'b0)) u_nsc_mem_region_cov (
    .HCLK(HCLK), .HRESETn(HRESETn), .HSEL(HSEL), .HADDR(HADDR), .HTRANS(HTRANS), .HWRITE(HWRITE),
    .HSIZE(HSIZE), .HREADY(HREADY), .HREADYOUT(HREADYOUT), .HRESP(HRESP)
);
bind nanosoc_region_dmem_0 nsc_mem_region_cov #(.REGION_ID(2), .PHYS_BYTES(16384), .IS_ROM(1'b0)) u_nsc_mem_region_cov (
    .HCLK(HCLK), .HRESETn(HRESETn), .HSEL(HSEL), .HADDR(HADDR), .HTRANS(HTRANS), .HWRITE(HWRITE),
    .HSIZE(HSIZE), .HREADY(HREADY), .HREADYOUT(HREADYOUT), .HRESP(HRESP)
);
bind nanosoc_region_expram_l nsc_mem_region_cov #(.REGION_ID(3), .PHYS_BYTES(16384), .IS_ROM(1'b0)) u_nsc_mem_region_cov (
    .HCLK(HCLK), .HRESETn(HRESETn), .HSEL(HSEL), .HADDR(HADDR), .HTRANS(HTRANS), .HWRITE(HWRITE),
    .HSIZE(HSIZE), .HREADY(HREADY), .HREADYOUT(HREADYOUT), .HRESP(HRESP)
);
bind nanosoc_region_expram_h nsc_mem_region_cov #(.REGION_ID(4), .PHYS_BYTES(16384), .IS_ROM(1'b0)) u_nsc_mem_region_cov (
    .HCLK(HCLK), .HRESETn(HRESETn), .HSEL(HSEL), .HADDR(HADDR), .HTRANS(HTRANS), .HWRITE(HWRITE),
    .HSIZE(HSIZE), .HREADY(HREADY), .HREADYOUT(HREADYOUT), .HRESP(HRESP)
);
bind nanosoc_region_systable nsc_mem_region_cov #(.REGION_ID(5), .PHYS_BYTES(4096), .IS_ROM(1'b1)) u_nsc_mem_region_cov (
    .HCLK(HCLK), .HRESETn(1'b1), .HSEL(HSEL), .HADDR(HADDR), .HTRANS(HTRANS), .HWRITE(HWRITE),
    .HSIZE(HSIZE), .HREADY(HREADY), .HREADYOUT(HREADYOUT), .HRESP(HRESP)
);

// ---- Batch 6: debug paths, pads / pin-mux, DMA tie-offs --------------------
bind socdebug_adp_control nsc_adp_cov u_nsc_adp_cov (
    .HCLK(HCLK), .HRESETn(HRESETn), .adp_state(adp_state), .adp_cmd(adp_cmd),
    .adp_bus_err(adp_bus_err), .HTRANS2_o(HTRANS2_o), .HSIZE3_o(HSIZE3_o), .HWRITE_o(HWRITE_o),
    .HREADY_i(HREADY_i), .HRESP_i(HRESP_i), .GPO8_o(GPO8_o), .GPI8_i(GPI8_i),
    .COMRX_TVALID_i(COMRX_TVALID_i), .COMRX_TREADY_o(COMRX_TREADY_o),
    .COMTX_TVALID_o(COMTX_TVALID_o), .COMTX_TREADY_i(COMTX_TREADY_i),
    .STDRX_TVALID_i(STDRX_TVALID_i), .STDRX_TREADY_o(STDRX_TREADY_o),
    .STDTX_TVALID_o(STDTX_TVALID_o), .STDTX_TREADY_i(STDTX_TREADY_i)
);
bind nanosoc_system nsc_debug_path_cov u_nsc_debug_path_cov (
    .SYS_HCLK(SYS_HCLK), .SYS_HRESETn(SYS_HRESETn), .FT1248MODE(FT1248MODE),
    .FT_ADP_RXD_TVALID(FT_ADP_RXD_TVALID), .FT_ADP_TXD_TVALID(FT_ADP_TXD_TVALID),
    .EXT_ADP_RXD_TVALID(EXT_ADP_RXD_TVALID), .EXT_ADP_TXD_TVALID(EXT_ADP_TXD_TVALID),
    .EXT_DAT_RXD_TVALID(EXT_DAT_RXD_TVALID), .EXT_DAT_TXD_TVALID(EXT_DAT_TXD_TVALID),
    .USRT0_TXD_TVALID(USRT0_TXD_TVALID), .USRT1_TXD_TVALID(USRT1_TXD_TVALID), .FT_CLK_O(FT_CLK_O)
);
bind nanosoc_system nsc_pinmux_cov u_nsc_pinmux_cov (
    .SYS_HCLK(SYS_HCLK), .SYS_HRESETn(SYS_HRESETn), .FT1248MODE(FT1248MODE),
    .SYS_P1_ALTFUNC(SYS_P1_ALTFUNC), .P1_OUTEN(P1_OUTEN), .SYS_P1_OUT_EN_MUX(SYS_P1_OUT_EN_MUX)
);
bind nanosoc_chip nsc_pins_cov u_nsc_pins_cov (
    .clk_i(clk_i), .nrst_i(nrst_i), .test_i(test_i),
    .p0_i(p0_i), .p0_o(p0_o), .p0_e(p0_e), .p1_i(p1_i), .p1_o(p1_o), .p1_e(p1_e),
    .swdclk_i(swdclk_i), .swdio_e(swdio_e)
);
bind nanosoc_ss_dma nsc_dma_cov u_nsc_dma_cov (
    .SYS_HCLK(SYS_HCLK), .SYS_HRESETn(SYS_HRESETn), .DMAC_0_HTRANS(DMAC_0_HTRANS),
    .DMAC_1_HTRANS(DMAC_1_HTRANS), .DMAC_0_DMA_REQ(DMAC_0_DMA_REQ),
    .DMAC_0_PSEL(DMAC_0_PSEL), .DMAC_1_PSEL(DMAC_1_PSEL)
);
