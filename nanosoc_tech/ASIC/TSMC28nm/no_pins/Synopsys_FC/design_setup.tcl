set sc9mcpp240z_base_path /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc9mcpp140z_base_svt_c35/r0p0
set cln28ht_tech_path /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/arm_tech/r1p0

create_lib nanosoc_chip_pads.dlib \
    -technology $cln28ht_tech_path/milkyway/1p9m_5x1y2z_utalrdl/sc9mcpp140z_tech.tf \
    -ref_libs {./cln28ht_sc9mcpp140z/}

source $env(SOCLABS_PROJECT_DIR)/imp/ASIC/nanosoc/flist/dc_flist.tcl
analyze -format verilog $env(SOCLABS_PROJECT_DIR)/nanosoc_tech/nanosoc/nanosoc_chip/pads/glib/verilog/nanosoc_chip_pads.v

elaborate nanosoc_chip_pads
set_top_module nanosoc_chip_pads