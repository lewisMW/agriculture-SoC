

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "axi_stream_io" "NUM_INSTANCES" "DEVICE_ID"  "C_axi_s_BASEADDR" "C_axi_s_HIGHADDR"
}
