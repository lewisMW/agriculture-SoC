// -----------------------------------------------------------------------------
// nsc_bind_sensing.sv — binds for the sensing peripheral models that work at
// BLOCK level too (adc_apb_wrapper_rev2, rtc_control_2). Included by
// nanosoc_cov.flist for system runs and by agriculture_soc_main/verif/cov
// (`make wrapper`) for block runs. No RTL is modified.
// -----------------------------------------------------------------------------
bind adc_apb_wrapper_rev2 nsc_sens_apb_cov #(.ADDR_WIDTH(ADDR_WIDTH)) u_nsc_sens_apb_cov (
    .PCLK          (PCLK),
    .PRESETn       (PRESETn),
    .nPOR          (nPOR),
    .PSEL          (PSEL),
    .PENABLE       (PENABLE),
    .PWRITE        (PWRITE),
    .PADDR         (PADDR),
    .PWDATA        (PWDATA),
    .PRDATA        (PRDATA),
    .PSTRB         (PSTRB),
    .PPROT         (PPROT),
    .PREADY        (PREADY),
    .PSLVERR       (PSLVERR),
    .adc_en        (adc_en),
    .fifo_empty    (fifo_empty),
    .fifo_write_en (fifo_write_en),
    .fifo_rd_en    (fifo_rd_en),
    .fifo_clear    (fifo_clear),
    .rtc_state     (u_rtc.state),
    .fifo_rd_ptr   (u_fifo.rd_ptr),
    .fifo_wr_ptr   (u_fifo.wr_ptr)
);

bind rtc_control_2 nsc_rtc_boundary_cov u_nsc_rtc_boundary_cov (
    .PCLK        (PCLK),
    .PRESETn     (PRESETn),
    .nPOR        (nPOR),
    .CLK1HZ      (CLK1HZ),
    .nRTCRST     (nRTCRST),
    .rtc_psel    (rtc_psel),
    .rtc_penable (rtc_penable),
    .rtc_pwrite  (rtc_pwrite),
    .rtc_paddr   (rtc_paddr),
    .rtc_pwdata  (rtc_pwdata),
    .RTCINTR     (RTCINTR),
    .ext_sel     (ext_sel),
    .state       (state),
    .alarm_offset(alarm_offset),
    .poll_enable (poll_enable),
    .PSEL        (PSEL),
    .PENABLE     (PENABLE),
    .PREADY      (PREADY),
    .PSLVERR     (PSLVERR)
);
