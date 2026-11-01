// -----------------------------------------------------------------------------
// nsc_rtc_bind_only.sv — the rtc_control_2 bind from nsc_bind_sensing.sv on its
// own, for the RTC block bench (no adc_apb_wrapper_rev2 in that elaboration).
// Keep in sync with nsc_bind_sensing.sv.
// -----------------------------------------------------------------------------
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
