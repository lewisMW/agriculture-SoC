## Paths Please Edit for your system
set via_map_file    /home/dwn1c21/SoC-Labs/phys_ip/TSMC/28/CMOS/util/PRTF_ICC_28nm_Syn_V19_1a/PR_tech/Synopsys/DFMViaSwapTcl/n28_ICC_DFMSWAP_5X1Y1Z1U_VHV.tcl
set_app_options -list {signoff.check_drc.runset {/home/dwn1c21/SoC-Labs/phys_ip/TSMC/28/CMOS/util/LOGIC_TopMz+Mu_DRC/ICVLN28HP_9M_5X1Y1Z1U_002.22a.encrypt}}
set_app_options -list {signoff.physical.layer_map_file {/home/dwn1c21/SoC-Labs/phys_ip/TSMC/28/CMOS/util/PRTF_ICC_28nm_Syn_V19_1a/PR_tech/Synopsys/GdsOutMap/gdsout_5X1Y1Z1U.map}}
set_app_options -list {signoff.check_drc_live.runset {/home/dwn1c21/SoC-Labs/phys_ip/TSMC/28/CMOS/util/LOGIC_TopMz+Mu_DRC/ICVLN28HP_9M_5X1Y1Z1U_002.22a.encrypt}}
set TLU_dir /home/dwn1c21/SoC-Labs/phys_ip/TSMC/28/CMOS/HPC+/util/ULL/TLUplus/1p9m_5x1y1z1u_ut-alrdl


# Removed ../libs/cln28ht_ret/ from lib for now

set PG_NETS [list VDD VDDACC VSS]

set tie_hi_cells cln28ht/TIEHI_X1M_A7PP140ZTS_C30
set tie_lo_cells cln28ht/TIELO_X1M_A7PP140ZTS_C30

set fill_cells  {FILL128_A7PP140ZTS_C30 \
 FILL32_A7PP140ZTS_C30 \
 FILL16_A7PP140ZTS_C30 \
 FILL4_A7PP140ZTS_C30\
 FILL3_A7PP140ZTS_C30 \
 FILL2_A7PP140ZTS_C30 \
 FILL1_A7PP140ZTS_C30 \
 }
