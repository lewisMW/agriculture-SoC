
set_db dft_scan_style muxed_scan
set_db design:nanosoc_chip_pads .dft_min_number_of_scan_chains 4
set_db hinst:nanosoc_chip_pads/u_nanosoc_chip_cfg .dft_dont_scan true
define_test_signal -name TEST  -active high -shared_input -hookup_pin u_nanosoc_chip/test_i -function test_mode -index 0 TEST
define_test_signal -name CLK  -active high -hookup_pin u_nanosoc_chip/clk_i -function test_clock -index 0 CLK
define_test_signal -name NRST  -active low -hookup_pin u_nanosoc_chip/nrst_i -function async_set_reset -index 0 NRST
define_test_signal -name SE  -active high -shared_input -hookup_pin u_nanosoc_chip_cfg/soc_scan_enable  -function shift_enable -default -index 0 SE
define_scan_chain -name chain_ACCEL -sdi P0[0] -hookup_pin_sdi u_nanosoc_chip_cfg/soc_scan_in[0] -sdo P1[0] -hookup_pin_sdo u_nanosoc_chip_cfg/soc_scan_out[0] -shared_output -shared_input
define_scan_chain -name chain_TOP_1 -sdi P0[1] -hookup_pin_sdi u_nanosoc_chip_cfg/soc_scan_in[1] -sdo P1[1] -hookup_pin_sdo u_nanosoc_chip_cfg/soc_scan_out[1] -shared_output -shared_input
define_scan_chain -name chain_TOP_2 -sdi P0[2] -hookup_pin_sdi u_nanosoc_chip_cfg/soc_scan_in[2] -sdo P1[2] -hookup_pin_sdo u_nanosoc_chip_cfg/soc_scan_out[2] -shared_output -shared_input
define_scan_chain -name chain_TOP_3 -sdi P0[3] -hookup_pin_sdi u_nanosoc_chip_cfg/soc_scan_in[3] -sdo P1[3] -hookup_pin_sdo u_nanosoc_chip_cfg/soc_scan_out[3] -shared_output -shared_input

fix_pad_cfg -mode input -test_control TEST P0[0]
fix_pad_cfg -mode input -test_control TEST P0[1]
fix_pad_cfg -mode input -test_control TEST P0[2]
fix_pad_cfg -mode input -test_control TEST P0[3]

fix_pad_cfg -mode output -test_control TEST P1[0]
fix_pad_cfg -mode output -test_control TEST P1[1]
fix_pad_cfg -mode output -test_control TEST P1[2]
fix_pad_cfg -mode output -test_control TEST P1[3]

check_dft_rules
fix_dft_violations -test_control TEST -async_reset -add_observe_scan -scan_clock_pin CLK
fix_dft_violations -test_control TEST -async_set
