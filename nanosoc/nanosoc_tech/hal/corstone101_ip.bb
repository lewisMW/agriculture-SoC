//-----------------------------------------------------------------------------
// NanoSoC Corstone-101 Blackbox Lint Design Info File
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : HAL Design Info File for Blackboxing Arm IP
//-----------------------------------------------------------------------------

bb_list
{
    // Exclude APB Timer as Arm IP
    designunit = cmsdk_apb_timer;
    file = $ARM_CORSTONE_101_DIR/cmsdk_apb_timer/verilog/cmsdk_apb_timer.v;
    
    // Exclude APB Dual Timer as Arm IP
    designunit = cmsdk_apb_dualtimers;
    file = $ARM_CORSTONE_101_DIR/cmsdk_apb_dualtimers/verilog/cmsdk_apb_dualtimers.v;
    
    // Exclude APB UART as Arm IP
    designunit = cmsdk_apb_uart;
    file = $ARM_CORSTONE_101_DIR/cmsdk_apb_uart/verilog/cmsdk_apb_uart.v;
    
    // Exclude APB Watchdog as Arm IP
    designunit = cmsdk_apb_watchdog;
    file = $ARM_CORSTONE_101_DIR/cmsdk_apb_watchdog/verilog/cmsdk_apb_watchdog.v;
    
    // Exclude AHB Slave Mux as Arm IP
    designunit = cmsdk_ahb_slave_mux;
    file = $ARM_CORSTONE_101_DIR/cmsdk_ahb_slave_mux/verilog/cmsdk_ahb_slave_mux.v;
    
    // Exclude AHB Default Slave as Arm IP
    designunit = cmsdk_ahb_default_slave;
    file = $ARM_CORSTONE_101_DIR/cmsdk_ahb_default_slave/verilog/cmsdk_ahb_default_slave.v;
    
    // Exclude AHB GPIO as Arm IP
    designunit = cmsdk_ahb_gpio;
    file = $ARM_CORSTONE_101_DIR/cmsdk_ahb_gpio/verilog/cmsdk_ahb_gpio.v;
    
    // Exclude AHB to APB Bridge as Arm IP
    designunit = cmsdk_ahb_to_apb;
    file = $ARM_CORSTONE_101_DIR/cmsdk_ahb_to_apb/verilog/cmsdk_ahb_to_apb.v;
    
    // Exclude IOP to GPIO Bridge as Arm IP
    designunit = cmsdk_iop_gpio;
    file = $ARM_CORSTONE_101_DIR/cmsdk_iop_gpio/verilog/cmsdk_iop_gpio.v;
    
    // Exclude AHB to SRAM Bridge as Arm IP
    designunit = cmsdk_ahb_to_sram;
    file = $ARM_CORSTONE_101_DIR/cmsdk_ahb_to_sram/verilog/cmsdk_ahb_to_sram.v;
    
    // Exclude SRAM Model as Arm IP
    designunit = cmsdk_fpga_sram;
    file = $ARM_CORSTONE_101_DIR/models/memories/cmsdk_fpga_sram.v;
    
    // Exclude APB Slave Mux as Arm IP
    designunit = cmsdk_apb_slave_mux;
    file = $ARM_CORSTONE_101_DIR/cmsdk_apb_slave_mux/verilog/cmsdk_apb_slave_mux.v;
    
    // Exclude CMSDK FPGA ROM
    designunit = cmsdk_fpga_rom;
    file = $ARM_CORSTONE_101_DIR/models/memories/cmsdk_fpga_rom.v;
    
    // Exclude APB Test slave as Arm IP
    designunit = cmsdk_apb_test_slave;
    file = $ARM_CORSTONE_101_DIR/cmsdk_apb_subsystem/verilog/cmsdk_apb_test_slave.v;
}