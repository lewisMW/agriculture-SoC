
set_mismatch_message_filter -warn FMR_ELAB-147
set_svf -append $env(SOCLABS_PROJECT_DIR)/nanosoc_tech/synthesis/default.svf
set IO_FRONTEND_DIR /home/dwn1c21/SoC-Labs/phys_ip/tsmc/cln65lp/Front_End/timing_power_noise/NLDM/tpdn65lpnv2od3_200a

source $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/formality_flist.tcl
read_db -r $env(SOCLABS_PROJECT_DIR)/memories/rf/rf_sp_hdf_ss_1p08v_1p08v_125c.db
read_db -r $env(SOCLABS_PROJECT_DIR)/memories/bootrom/rom_via_ss_1p08v_1p08v_125c.db
read_db -r $IO_FRONTEND_DIR/tpdn65lpnv2od3wc.db
set_top nanosoc_chip_pads

# Read db files
read_db -i $env(PHYS_IP)/arm/tsmc/cln65lp/sc12_base_rvt/r0p0/db/sc12_cln65lp_base_rvt_ss_typical_max_1p08v_125c.db
read_db -i $env(SOCLABS_PROJECT_DIR)/memories/rf/rf_sp_hdf_ss_1p08v_1p08v_125c.db
read_db -i $env(SOCLABS_PROJECT_DIR)/memories/bootrom/rom_via_ss_1p08v_1p08v_125c.db
read_db -i $IO_FRONTEND_DIR/tpdn65lpnv2od3wc.db
# Read Gate netlist

read_verilog -i $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/netlist/nanosoc_chip_pads.vm

set_top nanosoc_chip_pads

match
verify

analyze_points -failing

save_session nanosoc_chip_pads_formal_equivalence