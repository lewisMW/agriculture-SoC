
################################################################
# This is a generated script based on design: nanosoc_design
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################


namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2021.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcku115-flvb1760-1-c
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: cmsdk_socket
proc create_hier_cell_cmsdk_socket { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_cmsdk_socket() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I UART_RX
  create_bd_pin -dir O UART_TX
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst ext_reset_in
  create_bd_pin -dir O -from 15 -to 0 p0_tri_i
  create_bd_pin -dir I -from 15 -to 0 p0_tri_o
  create_bd_pin -dir I -from 15 -to 0 p0_tri_z
  create_bd_pin -dir O -from 15 -to 0 p1_tri_i
  create_bd_pin -dir I -from 15 -to 0 p1_tri_o
  create_bd_pin -dir I -from 15 -to 0 p1_tri_z
  create_bd_pin -dir I -from 7 -to 0 pmoda_tri_i
  create_bd_pin -dir O -from 7 -to 0 pmoda_tri_o
  create_bd_pin -dir O -from 7 -to 0 pmoda_tri_z
  create_bd_pin -dir O -from 0 -to 0 swdclk_i
  create_bd_pin -dir O -from 0 -to 0 swdio_tri_i
  create_bd_pin -dir I swdio_tri_o
  create_bd_pin -dir I swdio_tri_z

  # Create instance: ADPcontrol_0, and set properties
  set ADPcontrol_0 [ create_bd_cell -type ip -vlnv soclabs.org:user:ADPcontrol:1.0 ADPcontrol_0 ]

  # Create instance: ahblite_axi_bridge_0, and set properties
  set ahblite_axi_bridge_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ahblite_axi_bridge:3.0 ahblite_axi_bridge_0 ]

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]
  set_property -dict [ list \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_0

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_GPIO2_WIDTH {16} \
   CONFIG.C_GPIO_WIDTH {16} \
   CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_0

  # Create instance: axi_gpio_1, and set properties
  set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
  set_property -dict [ list \
   CONFIG.C_GPIO2_WIDTH {16} \
   CONFIG.C_GPIO_WIDTH {16} \
   CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_1

  # Create instance: axi_stream_io_0, and set properties
  set axi_stream_io_0 [ create_bd_cell -type ip -vlnv soclabs.org:user:axi_stream_io:1.0 axi_stream_io_0 ]

  # Create instance: axi_stream_io_1, and set properties
  set axi_stream_io_1 [ create_bd_cell -type ip -vlnv soclabs.org:user:axi_stream_io:1.0 axi_stream_io_1 ]

  # Create instance: axi_stream_io_2, and set properties
  set axi_stream_io_2 [ create_bd_cell -type ip -vlnv soclabs.org:user:axi_stream_io:1.0 axi_stream_io_2 ]

  # Create instance: axi_stream_io_3, and set properties
  set axi_stream_io_3 [ create_bd_cell -type ip -vlnv soclabs.org:user:axi_stream_io:1.0 axi_stream_io_3 ]

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]
  set_property -dict [ list \
   CONFIG.C_S_AXI_ACLK_FREQ_HZ {50000000} \
 ] $axi_uartlite_0

  # Create instance: axi_uartlite_1, and set properties
  set axi_uartlite_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_1 ]
  set_property -dict [ list \
   CONFIG.C_S_AXI_ACLK_FREQ_HZ {50000000} \
 ] $axi_uartlite_1

  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {64} \
 ] $axis_data_fifo_0

  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_1 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {64} \
 ] $axis_data_fifo_1

  # Create instance: axis_data_fifo_2, and set properties
  set axis_data_fifo_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_2 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {64} \
 ] $axis_data_fifo_2

  # Create instance: axis_data_fifo_3, and set properties
  set axis_data_fifo_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_3 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {64} \
 ] $axis_data_fifo_3

  # Create instance: axis_data_fifo_4, and set properties
  set axis_data_fifo_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_4 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {64} \
 ] $axis_data_fifo_4

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [ list \
   CONFIG.EN_SAFETY_CKT {true} \
   CONFIG.Enable_32bit_Address {true} \
   CONFIG.Read_Width_A {32} \
   CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
   CONFIG.Use_RSTA_Pin {true} \
   CONFIG.Write_Width_A {32} \
   CONFIG.use_bram_block {BRAM_Controller} \
 ] $blk_mem_gen_0

  # Create instance: ft1248x1_to_axi_stream_0, and set properties
  set ft1248x1_to_axi_stream_0 [ create_bd_cell -type ip -vlnv soclabs.org:user:ft1248x1_to_axi_streamio:1.0 ft1248x1_to_axi_stream_0 ]

  # Create instance: p1_i_bit15to6, and set properties
  set p1_i_bit15to6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 p1_i_bit15to6 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {15} \
   CONFIG.DIN_TO {6} \
   CONFIG.DIN_WIDTH {16} \
   CONFIG.DOUT_WIDTH {10} \
 ] $p1_i_bit15to6

  # Create instance: p1_i_concat, and set properties
  set p1_i_concat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 p1_i_concat ]
  set_property -dict [ list \
   CONFIG.IN0_WIDTH {1} \
   CONFIG.IN1_WIDTH {1} \
   CONFIG.IN2_WIDTH {1} \
   CONFIG.IN3_WIDTH {1} \
   CONFIG.IN4_WIDTH {1} \
   CONFIG.IN5_WIDTH {1} \
   CONFIG.IN6_WIDTH {10} \
   CONFIG.IN7_WIDTH {1} \
   CONFIG.IN8_WIDTH {8} \
   CONFIG.NUM_PORTS {7} \
 ] $p1_i_concat

  # Create instance: p1_o_bit1, and set properties
  set p1_o_bit1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 p1_o_bit1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {16} \
   CONFIG.DOUT_WIDTH {1} \
 ] $p1_o_bit1

  # Create instance: p1_o_bit15to6, and set properties
  set p1_o_bit15to6 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 p1_o_bit15to6 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {15} \
   CONFIG.DIN_TO {6} \
   CONFIG.DIN_WIDTH {16} \
   CONFIG.DOUT_WIDTH {10} \
 ] $p1_o_bit15to6

  # Create instance: p1_o_bit2, and set properties
  set p1_o_bit2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 p1_o_bit2 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {2} \
   CONFIG.DIN_TO {2} \
   CONFIG.DIN_WIDTH {16} \
   CONFIG.DOUT_WIDTH {1} \
 ] $p1_o_bit2

  # Create instance: p1_o_bit3, and set properties
  set p1_o_bit3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 p1_o_bit3 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {3} \
   CONFIG.DIN_TO {3} \
   CONFIG.DIN_WIDTH {16} \
   CONFIG.DOUT_WIDTH {1} \
 ] $p1_o_bit3

  # Create instance: p1_o_bit5, and set properties
  set p1_o_bit5 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 p1_o_bit5 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {5} \
   CONFIG.DIN_TO {5} \
   CONFIG.DIN_WIDTH {16} \
   CONFIG.DOUT_WIDTH {1} \
 ] $p1_o_bit5

  # Create instance: p1_z_bit2, and set properties
  set p1_z_bit2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 p1_z_bit2 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {2} \
   CONFIG.DIN_TO {2} \
   CONFIG.DIN_WIDTH {16} \
   CONFIG.DOUT_WIDTH {1} \
 ] $p1_z_bit2

  # Create instance: pmoda_i_bit2, and set properties
  set pmoda_i_bit2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 pmoda_i_bit2 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {2} \
   CONFIG.DIN_TO {2} \
   CONFIG.DIN_WIDTH {8} \
   CONFIG.DOUT_WIDTH {1} \
 ] $pmoda_i_bit2

  # Create instance: pmoda_i_bit3, and set properties
  set pmoda_i_bit3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 pmoda_i_bit3 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {3} \
   CONFIG.DIN_TO {3} \
   CONFIG.DIN_WIDTH {8} \
   CONFIG.DOUT_WIDTH {1} \
 ] $pmoda_i_bit3

  # Create instance: pmoda_i_bit4, and set properties
  set pmoda_i_bit4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 pmoda_i_bit4 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {4} \
   CONFIG.DIN_TO {4} \
   CONFIG.DIN_WIDTH {8} \
   CONFIG.DOUT_WIDTH {1} \
 ] $pmoda_i_bit4

  # Create instance: pmoda_i_bit7, and set properties
  set pmoda_i_bit7 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 pmoda_i_bit7 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {7} \
   CONFIG.DIN_TO {7} \
   CONFIG.DIN_WIDTH {8} \
   CONFIG.DOUT_WIDTH {1} \
 ] $pmoda_i_bit7

  # Create instance: pmoda_o_concat8, and set properties
  set pmoda_o_concat8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 pmoda_o_concat8 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {8} \
 ] $pmoda_o_concat8

  # Create instance: pmoda_z_concat8, and set properties
  set pmoda_z_concat8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 pmoda_z_concat8 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {8} \
 ] $pmoda_z_concat8

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
   CONFIG.ADVANCED_PROPERTIES {0} \
   CONFIG.NUM_MI {8} \
   CONFIG.NUM_SI {1} \
 ] $smartconnect_0

  # Create instance: uart_to_AXI_master_0, and set properties
  set uart_to_AXI_master_0 [ create_bd_cell -type ip -vlnv ultraembedded:user:uart_axi_master:1.0 uart_to_AXI_master_0 ]
  set_property -dict [ list \
   CONFIG.CLK_SPEED {50000000} \
   CONFIG.C_M00_AXI_ARUSER_WIDTH {4} \
   CONFIG.C_M00_AXI_AWUSER_WIDTH {4} \
   CONFIG.C_M00_AXI_BUSER_WIDTH {4} \
   CONFIG.C_M00_AXI_ID_WIDTH {4} \
   CONFIG.C_M00_AXI_RUSER_WIDTH {4} \
   CONFIG.C_M00_AXI_WUSER_WIDTH {4} \
 ] $uart_to_AXI_master_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]

  # Create interface connections
  connect_bd_intf_net -intf_net ADPcontrol_0_ahb [get_bd_intf_pins ADPcontrol_0/ahb] [get_bd_intf_pins ahblite_axi_bridge_0/AHB_INTERFACE]
  connect_bd_intf_net -intf_net ADPcontrol_0_com_tx [get_bd_intf_pins ADPcontrol_0/com_tx] [get_bd_intf_pins axis_data_fifo_3/S_AXIS]
  connect_bd_intf_net -intf_net ADPcontrol_0_stdio_tx [get_bd_intf_pins ADPcontrol_0/stdio_tx] [get_bd_intf_pins axis_data_fifo_4/S_AXIS]
  connect_bd_intf_net -intf_net ahblite_axi_bridge_0_M_AXI [get_bd_intf_pins ahblite_axi_bridge_0/M_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_stream_io_0_tx [get_bd_intf_pins axi_stream_io_0/tx] [get_bd_intf_pins ft1248x1_to_axi_stream_0/rxd8]
  connect_bd_intf_net -intf_net axi_stream_io_1_tx [get_bd_intf_pins axi_stream_io_1/rx] [get_bd_intf_pins axi_stream_io_1/tx]
  connect_bd_intf_net -intf_net axi_stream_io_2_tx [get_bd_intf_pins axi_stream_io_2/tx] [get_bd_intf_pins axis_data_fifo_1/S_AXIS]
  connect_bd_intf_net -intf_net axi_stream_io_3_tx [get_bd_intf_pins axi_stream_io_3/tx] [get_bd_intf_pins axis_data_fifo_2/S_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins axi_stream_io_0/rx] [get_bd_intf_pins axis_data_fifo_0/M_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_1_M_AXIS [get_bd_intf_pins axi_stream_io_2/rx] [get_bd_intf_pins axis_data_fifo_1/M_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_2_M_AXIS [get_bd_intf_pins ADPcontrol_0/com_rx] [get_bd_intf_pins axis_data_fifo_2/M_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_3_M_AXIS [get_bd_intf_pins axi_stream_io_3/rx] [get_bd_intf_pins axis_data_fifo_3/M_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_4_M_AXIS [get_bd_intf_pins ADPcontrol_0/stdio_rx] [get_bd_intf_pins axis_data_fifo_4/M_AXIS]
  connect_bd_intf_net -intf_net ft1248x1_to_axi_stre_0_txd8 [get_bd_intf_pins axis_data_fifo_0/S_AXIS] [get_bd_intf_pins ft1248x1_to_axi_stream_0/txd8]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins smartconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins axi_gpio_1/S_AXI] [get_bd_intf_pins smartconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins smartconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins axi_uartlite_1/S_AXI] [get_bd_intf_pins smartconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins axi_stream_io_0/S_AXI] [get_bd_intf_pins smartconnect_0/M04_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M05_AXI [get_bd_intf_pins axi_stream_io_1/S_AXI] [get_bd_intf_pins smartconnect_0/M05_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M06_AXI [get_bd_intf_pins axi_stream_io_2/S_AXI] [get_bd_intf_pins smartconnect_0/M06_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M07_AXI [get_bd_intf_pins axi_stream_io_3/S_AXI] [get_bd_intf_pins smartconnect_0/M07_AXI]
  connect_bd_intf_net -intf_net uart_to_AXI_master_0_M00_AXI [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins uart_to_AXI_master_0/M00_AXI]

  # Create port connections
  connect_bd_net -net ADPcontrol_0_gpo8 [get_bd_pins ADPcontrol_0/gpi8] [get_bd_pins ADPcontrol_0/gpo8]
  connect_bd_net -net UART2_TXD [get_bd_pins axi_uartlite_0/rx] [get_bd_pins p1_o_bit5/Dout]
  connect_bd_net -net UART_RX_1 [get_bd_pins UART_RX] [get_bd_pins uart_to_AXI_master_0/UART_RX]
  connect_bd_net -net ahblite_axi_bridge_0_s_ahb_hready_out [get_bd_pins ADPcontrol_0/ahb_hready] [get_bd_pins ahblite_axi_bridge_0/s_ahb_hready_in] [get_bd_pins ahblite_axi_bridge_0/s_ahb_hready_out]
  connect_bd_net -net axi_bram_ctrl_0_bram_addr_a [get_bd_pins axi_bram_ctrl_0/bram_addr_a] [get_bd_pins blk_mem_gen_0/addra]
  connect_bd_net -net axi_bram_ctrl_0_bram_clk_a [get_bd_pins axi_bram_ctrl_0/bram_clk_a] [get_bd_pins blk_mem_gen_0/clka]
  connect_bd_net -net axi_bram_ctrl_0_bram_en_a [get_bd_pins axi_bram_ctrl_0/bram_en_a] [get_bd_pins blk_mem_gen_0/ena]
  connect_bd_net -net axi_bram_ctrl_0_bram_we_a [get_bd_pins axi_bram_ctrl_0/bram_we_a] [get_bd_pins blk_mem_gen_0/wea]
  connect_bd_net -net axi_bram_ctrl_0_bram_wrdata_a [get_bd_pins axi_bram_ctrl_0/bram_wrdata_a] [get_bd_pins blk_mem_gen_0/dina]
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins p0_tri_i] [get_bd_pins axi_gpio_0/gpio_io_o]
  connect_bd_net -net axi_gpio_1_gpio_io_o [get_bd_pins axi_gpio_1/gpio_io_o] [get_bd_pins p1_i_bit15to6/Din]
  connect_bd_net -net axi_stream_io_0_tx_tdata [get_bd_pins axi_stream_io_0/tx_tdata] [get_bd_pins ft1248x1_to_axi_stream_0/rxd_tdata8_i]
  connect_bd_net -net axi_stream_io_0_tx_tvalid [get_bd_pins axi_stream_io_0/tx_tvalid] [get_bd_pins ft1248x1_to_axi_stream_0/rxd_tvalid_i]
  connect_bd_net -net axi_uartlite_0_tx [get_bd_pins axi_uartlite_0/tx] [get_bd_pins p1_i_concat/In4]
  connect_bd_net -net axi_uartlite_1_tx [get_bd_pins axi_uartlite_1/rx] [get_bd_pins axi_uartlite_1/tx]
  connect_bd_net -net blk_mem_gen_0_douta [get_bd_pins axi_bram_ctrl_0/bram_rddata_a] [get_bd_pins blk_mem_gen_0/douta]
  connect_bd_net -net cmsdk_mcu_chip_0_p0_o [get_bd_pins p0_tri_o] [get_bd_pins axi_gpio_0/gpio_io_i]
  connect_bd_net -net cmsdk_mcu_chip_0_p0_z [get_bd_pins p0_tri_z] [get_bd_pins axi_gpio_0/gpio2_io_i]
  connect_bd_net -net cmsdk_mcu_chip_0_p1_o [get_bd_pins p1_tri_o] [get_bd_pins axi_gpio_1/gpio_io_i] [get_bd_pins p1_o_bit1/Din] [get_bd_pins p1_o_bit15to6/Din] [get_bd_pins p1_o_bit2/Din] [get_bd_pins p1_o_bit3/Din] [get_bd_pins p1_o_bit5/Din]
  connect_bd_net -net const0 [get_bd_pins p1_i_concat/In1] [get_bd_pins p1_i_concat/In3] [get_bd_pins p1_i_concat/In5] [get_bd_pins pmoda_o_concat8/In2] [get_bd_pins pmoda_o_concat8/In5] [get_bd_pins pmoda_o_concat8/In6] [get_bd_pins pmoda_o_concat8/In7] [get_bd_pins pmoda_z_concat8/In0] [get_bd_pins pmoda_z_concat8/In1] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net const1 [get_bd_pins ahblite_axi_bridge_0/s_ahb_hsel] [get_bd_pins pmoda_z_concat8/In2] [get_bd_pins pmoda_z_concat8/In5] [get_bd_pins pmoda_z_concat8/In6] [get_bd_pins pmoda_z_concat8/In7] [get_bd_pins xlconstant_1/dout]
  connect_bd_net -net ft1248x1_to_axi_stre_0_ft_miosio_o [get_bd_pins ft1248x1_to_axi_stream_0/ft_miosio_o] [get_bd_pins p1_i_concat/In2]
  connect_bd_net -net ft1248x1_to_axi_stre_0_ft_miso_o [get_bd_pins ft1248x1_to_axi_stream_0/ft_miso_o] [get_bd_pins p1_i_concat/In0]
  connect_bd_net -net ft1248x1_to_axi_stream_0_rxd_tready_o [get_bd_pins axi_stream_io_0/tx_tready] [get_bd_pins ft1248x1_to_axi_stream_0/rxd_tready_o]
  connect_bd_net -net ftclk_o [get_bd_pins ft1248x1_to_axi_stream_0/ft_clk_i] [get_bd_pins p1_o_bit1/Dout] [get_bd_pins pmoda_o_concat8/In0]
  connect_bd_net -net ftmiosio_o [get_bd_pins p1_o_bit2/Dout] [get_bd_pins pmoda_o_concat8/In3]
  connect_bd_net -net ftmiosio_z [get_bd_pins p1_z_bit2/Dout] [get_bd_pins pmoda_z_concat8/In3]
  connect_bd_net -net ftssn_n [get_bd_pins ft1248x1_to_axi_stream_0/ft_ssn_i] [get_bd_pins p1_o_bit3/Dout] [get_bd_pins pmoda_o_concat8/In1]
  connect_bd_net -net p1_i [get_bd_pins p1_tri_i] [get_bd_pins p1_i_concat/dout]
  connect_bd_net -net p1_i_bit15to6_Dout [get_bd_pins p1_i_bit15to6/Dout] [get_bd_pins p1_i_concat/In6]
  connect_bd_net -net p1_z [get_bd_pins p1_tri_z] [get_bd_pins axi_gpio_1/gpio2_io_i] [get_bd_pins p1_z_bit2/Din]
  connect_bd_net -net pmoda_i_1 [get_bd_pins pmoda_tri_i] [get_bd_pins pmoda_i_bit2/Din] [get_bd_pins pmoda_i_bit3/Din] [get_bd_pins pmoda_i_bit4/Din] [get_bd_pins pmoda_i_bit7/Din]
  connect_bd_net -net pmoda_i_bit3_Dout [get_bd_pins ft1248x1_to_axi_stream_0/ft_miosio_i] [get_bd_pins pmoda_i_bit3/Dout]
  connect_bd_net -net pmoda_i_bit4_Dout [get_bd_pins swdio_tri_i] [get_bd_pins pmoda_i_bit4/Dout]
  connect_bd_net -net pmoda_i_bit7_Dout [get_bd_pins swdclk_i] [get_bd_pins pmoda_i_bit7/Dout]
  connect_bd_net -net pmoda_o_concat9_dout [get_bd_pins pmoda_tri_z] [get_bd_pins pmoda_z_concat8/dout]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins ext_reset_in] [get_bd_pins ADPcontrol_0/ahb_hresetn] [get_bd_pins ahblite_axi_bridge_0/s_ahb_hresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_gpio_1/s_axi_aresetn] [get_bd_pins axi_stream_io_0/S_AXI_ARESETN] [get_bd_pins axi_stream_io_1/S_AXI_ARESETN] [get_bd_pins axi_stream_io_2/S_AXI_ARESETN] [get_bd_pins axi_stream_io_3/S_AXI_ARESETN] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins axi_uartlite_1/s_axi_aresetn] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins axis_data_fifo_1/s_axis_aresetn] [get_bd_pins axis_data_fifo_2/s_axis_aresetn] [get_bd_pins axis_data_fifo_3/s_axis_aresetn] [get_bd_pins axis_data_fifo_4/s_axis_aresetn] [get_bd_pins ft1248x1_to_axi_stream_0/aresetn] [get_bd_pins smartconnect_0/aresetn] [get_bd_pins uart_to_AXI_master_0/m00_axi_aresetn]
  connect_bd_net -net swdio_o_1 [get_bd_pins swdio_tri_o] [get_bd_pins pmoda_o_concat8/In4]
  connect_bd_net -net swdio_z_1 [get_bd_pins swdio_tri_z] [get_bd_pins pmoda_z_concat8/In4]
  connect_bd_net -net uart_to_AXI_master_0_UART_TX [get_bd_pins UART_TX] [get_bd_pins uart_to_AXI_master_0/UART_TX]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins pmoda_tri_o] [get_bd_pins pmoda_o_concat8/dout]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins aclk] [get_bd_pins ADPcontrol_0/ahb_hclk] [get_bd_pins ahblite_axi_bridge_0/s_ahb_hclk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_gpio_1/s_axi_aclk] [get_bd_pins axi_stream_io_0/S_AXI_ACLK] [get_bd_pins axi_stream_io_1/S_AXI_ACLK] [get_bd_pins axi_stream_io_2/S_AXI_ACLK] [get_bd_pins axi_stream_io_3/S_AXI_ACLK] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins axi_uartlite_1/s_axi_aclk] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins axis_data_fifo_1/s_axis_aclk] [get_bd_pins axis_data_fifo_2/s_axis_aclk] [get_bd_pins axis_data_fifo_3/s_axis_aclk] [get_bd_pins axis_data_fifo_4/s_axis_aclk] [get_bd_pins ft1248x1_to_axi_stream_0/aclk] [get_bd_pins smartconnect_0/aclk] [get_bd_pins uart_to_AXI_master_0/m00_axi_aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set EXT_CLK [ create_bd_port -dir I -type clk -freq_hz 50000000 EXT_CLK ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_ASYNC_RESET {nRST_CPU} \
   CONFIG.ASSOCIATED_RESET {nRST_CPU} \
 ] $EXT_CLK
  set UART_RX [ create_bd_port -dir I UART_RX ]
  set UART_TX [ create_bd_port -dir O UART_TX ]
  set nRST_CPU [ create_bd_port -dir I -type rst nRST_CPU ]
  set pmoda_tri_i [ create_bd_port -dir I -from 7 -to 0 pmoda_tri_i ]
  set pmoda_tri_o [ create_bd_port -dir O -from 7 -to 0 pmoda_tri_o ]
  set pmoda_tri_z [ create_bd_port -dir O -from 7 -to 0 pmoda_tri_z ]

  # Create instance: cmsdk_socket
  create_hier_cell_cmsdk_socket [current_bd_instance .] cmsdk_socket

  # Create instance: nanosoc_chip_0, and set properties
  set nanosoc_chip_0 [ create_bd_cell -type ip -vlnv soclabs.org:user:nanosoc_chip:1.0 nanosoc_chip_0 ]

  # Create port connections
  connect_bd_net -net EXT_CLK_1 [get_bd_ports EXT_CLK] [get_bd_pins cmsdk_socket/aclk] [get_bd_pins nanosoc_chip_0/clk_i]
  connect_bd_net -net UART_RX_1 [get_bd_ports UART_RX] [get_bd_pins cmsdk_socket/UART_RX]
  connect_bd_net -net cmsdk_socket_UART_TX [get_bd_ports UART_TX] [get_bd_pins cmsdk_socket/UART_TX]
  connect_bd_net -net cmsdk_socket_p0_tri_i [get_bd_pins cmsdk_socket/p0_tri_i] [get_bd_pins nanosoc_chip_0/p0_i]
  connect_bd_net -net cmsdk_socket_p1_tri_i [get_bd_pins cmsdk_socket/p1_tri_i] [get_bd_pins nanosoc_chip_0/p1_i]
  connect_bd_net -net cmsdk_socket_swdclk_i [get_bd_pins cmsdk_socket/swdclk_i] [get_bd_pins nanosoc_chip_0/swdclk_i]
  connect_bd_net -net cmsdk_socket_swdio_i [get_bd_pins cmsdk_socket/swdio_tri_i] [get_bd_pins nanosoc_chip_0/swdio_i]
  connect_bd_net -net p0_tri_o_1 [get_bd_pins cmsdk_socket/p0_tri_o] [get_bd_pins nanosoc_chip_0/p0_o]
  connect_bd_net -net p0_tri_z_1 [get_bd_pins cmsdk_socket/p0_tri_z] [get_bd_pins nanosoc_chip_0/p0_z]
  connect_bd_net -net p1_tri_o_1 [get_bd_pins cmsdk_socket/p1_tri_o] [get_bd_pins nanosoc_chip_0/p1_o]
  connect_bd_net -net p1_tri_z_1 [get_bd_pins cmsdk_socket/p1_tri_z] [get_bd_pins nanosoc_chip_0/p1_z]
  connect_bd_net -net pmoda_i_1 [get_bd_ports pmoda_tri_i] [get_bd_pins cmsdk_socket/pmoda_tri_i]
  connect_bd_net -net pmoda_o_concat9_dout [get_bd_ports pmoda_tri_z] [get_bd_pins cmsdk_socket/pmoda_tri_z]
  connect_bd_net -net rst_sync_0_reset [get_bd_ports nRST_CPU] [get_bd_pins cmsdk_socket/ext_reset_in] [get_bd_pins nanosoc_chip_0/nrst_i]
  connect_bd_net -net swdio_tri_o_1 [get_bd_pins cmsdk_socket/swdio_tri_o] [get_bd_pins nanosoc_chip_0/swdio_o]
  connect_bd_net -net swdio_tri_z_1 [get_bd_pins cmsdk_socket/swdio_tri_z] [get_bd_pins nanosoc_chip_0/swdio_z]
  connect_bd_net -net xlconcat_0_dout [get_bd_ports pmoda_tri_o] [get_bd_pins cmsdk_socket/pmoda_tri_o]

  # Create address segments
  assign_bd_address -offset 0xC0000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces cmsdk_socket/ADPcontrol_0/ahb] [get_bd_addr_segs cmsdk_socket/axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x80000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cmsdk_socket/uart_to_AXI_master_0/M00_AXI] [get_bd_addr_segs cmsdk_socket/axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x80010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cmsdk_socket/uart_to_AXI_master_0/M00_AXI] [get_bd_addr_segs cmsdk_socket/axi_gpio_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x80020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cmsdk_socket/uart_to_AXI_master_0/M00_AXI] [get_bd_addr_segs cmsdk_socket/axi_stream_io_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x80030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cmsdk_socket/uart_to_AXI_master_0/M00_AXI] [get_bd_addr_segs cmsdk_socket/axi_stream_io_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x80040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cmsdk_socket/uart_to_AXI_master_0/M00_AXI] [get_bd_addr_segs cmsdk_socket/axi_stream_io_2/S_AXI/Reg] -force
  assign_bd_address -offset 0x80050000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cmsdk_socket/uart_to_AXI_master_0/M00_AXI] [get_bd_addr_segs cmsdk_socket/axi_stream_io_3/S_AXI/Reg] -force
  assign_bd_address -offset 0x80060000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cmsdk_socket/uart_to_AXI_master_0/M00_AXI] [get_bd_addr_segs cmsdk_socket/axi_uartlite_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x80070000 -range 0x00010000 -target_address_space [get_bd_addr_spaces cmsdk_socket/uart_to_AXI_master_0/M00_AXI] [get_bd_addr_segs cmsdk_socket/axi_uartlite_1/S_AXI/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()



proc available_tcl_procs { } {
   puts "##################################################################"
   puts "# Available Tcl procedures to recreate hierarchical blocks:"
   puts "#"
   puts "#    create_hier_cell_cmsdk_socket parentCell nameHier"
   puts "#    create_root_design"
   puts "#"
   puts "#"
   puts "# The following procedures will create hiearchical blocks with addressing "
   puts "# for IPs within those blocks and their sub-hierarchical blocks. Addressing "
   puts "# will not be handled outside those blocks:"
   puts "#"
   puts "#    create_root_design"
   puts "#"
   puts "##################################################################"
}

available_tcl_procs
