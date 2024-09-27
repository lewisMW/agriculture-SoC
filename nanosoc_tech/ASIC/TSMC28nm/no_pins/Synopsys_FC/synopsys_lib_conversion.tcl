set sc9mcpp140z_base_path /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/sc9mcpp140z_base_svt_c35/r0p0
set cln28ht_tech_path /home/dwn1c21/SoC-Labs/phys_ip/arm/tsmc/cln28ht/arm_tech/r1p0

set cln28ht_tech_file   $cln28ht_tech_path/milkyway/1p9m_5x1y2z_utalrdl/sc9mcpp140z_tech.tf
set cln28ht_lef_file    $cln28ht_tech_path/lef/1p9m_5x1y2z_utalrdl/sc9mcpp140z_tech.lef

set sc9mcpp140z_lef_file    $sc9mcpp140z_base_path/lef/sc9mcpp140z_cln28ht_base_svt_c35.lef
set sc9mcpp140z_gds_file    $sc9mcpp140z_base_path/gds2/sc9mcpp140z_cln28ht_base_svt_c35.gds2
set sc9mcpp140z_db_file     $sc9mcpp140z_base_path/db/sc9mcpp140z_cln28ht_base_svt_c35_ssg_cworstt_max_0p81v_125c.db
set sc9mcpp140z_antenna_file   $sc9mcpp140z_base_path/milkyway/1p9m_5x1y2z_utalrdl/sc9mcpp140z_cln28ht_base_svt_c35_antenna.clf

create_physical_lib -technology $cln28ht_tech_file cln28ht
read_lef -library cln28ht $sc9mcpp140z_lef_file
read_gds -library cln28ht $sc9mcpp140z_gds_file
set_cell_site -site_def unit
update_physical_properties -library cln28ht -format clf -file $sc9mcpp140z_antenna_file

update_physical_properties -library cln28ht -format db -file $sc9mcpp140z_db_file
create_frame

set_app_options -name

write_physical_lib -output cln28ht.ndm
report_lib -all cln28ht 

set_check_library_options -logic_vs_physical -physical 
check_library -physical_library_name cln28ht -logic_library_name $sc9mcpp140z_db_file