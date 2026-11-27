# names are switched around for openframe!
# TEST - 18
# SE - 19
# CLK - 38
# NRST - resetb_l
# P0[0-3] - 24-27
# P1[0-3] - 0, 7, 8, 9
set TEST gpio_in[18]
set SE   gpio_in[19]
set CLK  gpio_in[38]
set NRST resetb_l
set P0_0 gpio_in[24]
set P0_1 gpio_in[25]
set P0_2 gpio_in[26]
set P0_3 gpio_in[27]
set P1_0 gpio_out[0]
set P1_1 gpio_out[7]
set P1_2 gpio_out[8]
set P1_3 gpio_out[9]

set_db dft_scan_style muxed_scan
set_db design:openframe_project_wrapper .dft_min_number_of_scan_chains 4
set_db hinst:openframe_project_wrapper/u_nanosoc_chip_cfg .dft_dont_scan true
define_test_signal -name TEST  -active high -shared_input -hookup_pin u_nanosoc_chip/test_i -function test_mode -index 0 $TEST
define_test_signal -name CLK  -active high -hookup_pin u_nanosoc_chip/clk_i -function test_clock -index 0 $CLK
define_test_signal -name NRST  -active low -hookup_pin u_nanosoc_chip/nrst_i -function async_set_reset -index 0 $NRST
define_test_signal -name SE  -active high -shared_input -hookup_pin u_nanosoc_chip_cfg/soc_scan_enable  -function shift_enable -default -index 0 $SE

define_scan_chain -name chain_ACCEL -sdi $P0_0 -hookup_pin_sdi u_nanosoc_chip_cfg/soc_scan_in[0] -sdo $P1_0 -hookup_pin_sdo u_nanosoc_chip_cfg/soc_scan_out[0] -shared_output -shared_input
define_scan_chain -name chain_TOP_1 -sdi $P0_1 -hookup_pin_sdi u_nanosoc_chip_cfg/soc_scan_in[1] -sdo $P1_1 -hookup_pin_sdo u_nanosoc_chip_cfg/soc_scan_out[1] -shared_output -shared_input
define_scan_chain -name chain_TOP_2 -sdi $P0_2 -hookup_pin_sdi u_nanosoc_chip_cfg/soc_scan_in[2] -sdo $P1_2 -hookup_pin_sdo u_nanosoc_chip_cfg/soc_scan_out[2] -shared_output -shared_input
define_scan_chain -name chain_TOP_3 -sdi $P0_3 -hookup_pin_sdi u_nanosoc_chip_cfg/soc_scan_in[3] -sdo $P1_3 -hookup_pin_sdo u_nanosoc_chip_cfg/soc_scan_out[3] -shared_output -shared_input

fix_pad_cfg -mode input -test_control TEST $P0_0
fix_pad_cfg -mode input -test_control TEST $P0_1
fix_pad_cfg -mode input -test_control TEST $P0_2
fix_pad_cfg -mode input -test_control TEST $P0_3

fix_pad_cfg -mode output -test_control TEST $P1_0
fix_pad_cfg -mode output -test_control TEST $P1_1
fix_pad_cfg -mode output -test_control TEST $P1_2
fix_pad_cfg -mode output -test_control TEST $P1_3

check_dft_rules
fix_dft_violations -test_control TEST -async_reset -add_observe_scan -scan_clock_pin $CLK
fix_dft_violations -test_control TEST -async_set
