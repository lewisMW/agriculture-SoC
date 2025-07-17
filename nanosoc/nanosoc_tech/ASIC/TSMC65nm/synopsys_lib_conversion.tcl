set RF_PATH $env(SOCLABS_PROJECT_DIR)/memories/rf_16k

read_lib $RF_PATH/rf_sp_hdf_ss_1p08v_1p08v_125c.lib
write_lib RF_LIB_ss_1p08v_1p08v_125c -output $RF_PATH/rf_sp_hdf_ss_1p08v_1p08v_125c.db

read_lib $RF_PATH/rf_sp_hdf_ss_1p08v_1p08v_m40c.lib
write_lib RF_LIB_ss_1p08v_1p08v_m40c -output $RF_PATH/rf_sp_hdf_ss_1p08v_1p08v_m40c.db

read_lib $RF_PATH/rf_sp_hdf_ff_1p32v_1p32v_125c.lib
write_lib RF_LIB_ff_1p32v_1p32v_125c -output $RF_PATH/rf_sp_hdf_ff_1p32v_1p32v_125c.db

read_lib $RF_PATH/rf_sp_hdf_ff_1p32v_1p32v_m40c.lib
write_lib RF_LIB_ff_1p32v_1p32v_m40c -output $RF_PATH/rf_sp_hdf_ff_1p32v_1p32v_m40c.db

read_lib $RF_PATH/rf_sp_hdf_tt_1p20v_1p20v_25c.lib
write_lib RF_LIB_tt_1p20v_1p20v_25c -output $RF_PATH/rf_sp_hdf_tt_1p20v_1p20v_25c.db

set ROM_PATH $env(SOCLABS_PROJECT_DIR)/memories/bootrom

read_lib $ROM_PATH/rom_via_ss_1p08v_1p08v_125c.lib
write_lib USERLIB_ss_1p08v_1p08v_125c -output $ROM_PATH/rom_via_ss_1p08v_1p08v_125c.db

read_lib $ROM_PATH/rom_via_ss_1p08v_1p08v_m40c.lib
write_lib USERLIB_ss_1p08v_1p08v_m40c -output $ROM_PATH/rom_via_ss_1p08v_1p08v_m40c.db

read_lib $ROM_PATH/rom_via_ff_1p32v_1p32v_125c.lib
write_lib USERLIB_ff_1p32v_1p32v_125c -output $ROM_PATH/rom_via_ff_1p32v_1p32v_125c.db

read_lib $ROM_PATH/rom_via_ff_1p32v_1p32v_m40c.lib
write_lib USERLIB_ff_1p32v_1p32v_m40c -output $ROM_PATH/rom_via_ff_1p32v_1p32v_m40c.db

read_lib $ROM_PATH/rom_via_tt_1p20v_1p20v_25c.lib
write_lib USERLIB_tt_1p20v_1p20v_25c -output $ROM_PATH/rom_via_tt_1p20v_1p20v_25c.db

exit