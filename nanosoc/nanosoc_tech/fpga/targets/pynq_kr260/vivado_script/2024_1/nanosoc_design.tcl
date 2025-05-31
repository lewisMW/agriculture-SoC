
################################################################
# This is a generated script based on design: extio8x4_io
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
set scripts_vivado_version 2024.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source extio8x4_io_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xck26-sfvc784-2LV-c
   set_property BOARD_PART xilinx.com:kr260_som:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name extio8x4_io

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

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
soclabs.org:user:nanosoc_chip:1.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:zynq_ultra_ps_e:3.5\
xilinx.com:ip:axi_gpio:2.0\
soclabs.org:user:axi_stream_io:1.0\
xilinx.com:ip:axis_data_fifo:2.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlslice:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:smartconnect:1.0\
soclabs.org:slip:extio8x4_axis_target:1.0\
xilinx.com:ip:util_vector_logic:2.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst ext_reset_in
  create_bd_pin -dir O -from 0 -to 0 -type rst nrst
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

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [list \
    CONFIG.C_GPIO2_WIDTH {16} \
    CONFIG.C_GPIO_WIDTH {16} \
    CONFIG.C_IS_DUAL {1} \
  ] $axi_gpio_0


  set_property SELECTED_SIM_MODEL rtl  $axi_gpio_0

  # Create instance: axi_gpio_1, and set properties
  set axi_gpio_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_1 ]
  set_property -dict [list \
    CONFIG.C_GPIO2_WIDTH {16} \
    CONFIG.C_GPIO_WIDTH {16} \
    CONFIG.C_IS_DUAL {1} \
  ] $axi_gpio_1


  set_property SELECTED_SIM_MODEL rtl  $axi_gpio_1

  # Create instance: axi_stream_io_0, and set properties
  set axi_stream_io_0 [ create_bd_cell -type ip -vlnv soclabs.org:user:axi_stream_io:1.0 axi_stream_io_0 ]

  set_property SELECTED_SIM_MODEL rtl  $axi_stream_io_0

  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_0 ]
  set_property CONFIG.FIFO_DEPTH {64} $axis_data_fifo_0


  set_property SELECTED_SIM_MODEL rtl  $axis_data_fifo_0

  # Create instance: extio_concat_z, and set properties
  set extio_concat_z [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 extio_concat_z ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {1} \
    CONFIG.IN1_WIDTH {1} \
    CONFIG.IN2_WIDTH {1} \
    CONFIG.IN3_WIDTH {4} \
    CONFIG.IN4_WIDTH {1} \
    CONFIG.IN5_WIDTH {1} \
    CONFIG.IN6_WIDTH {1} \
    CONFIG.IN7_WIDTH {1} \
    CONFIG.NUM_PORTS {5} \
  ] $extio_concat_z


  set_property SELECTED_SIM_MODEL rtl  $extio_concat_z

  # Create instance: extio_i_bit1_ioreq2, and set properties
  set extio_i_bit1_ioreq2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 extio_i_bit1_ioreq2 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {1} \
    CONFIG.DIN_TO {1} \
    CONFIG.DIN_WIDTH {8} \
    CONFIG.DOUT_WIDTH {1} \
  ] $extio_i_bit1_ioreq2


  set_property SELECTED_SIM_MODEL rtl  $extio_i_bit1_ioreq2

  # Create instance: extio_i_bit6to3_iodatata4, and set properties
  set extio_i_bit6to3_iodatata4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 extio_i_bit6to3_iodatata4 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {6} \
    CONFIG.DIN_TO {3} \
    CONFIG.DIN_WIDTH {8} \
    CONFIG.DOUT_WIDTH {4} \
  ] $extio_i_bit6to3_iodatata4


  set_property SELECTED_SIM_MODEL rtl  $extio_i_bit6to3_iodatata4

  # Create instance: extio_i_bit0_ioreq1, and set properties
  set extio_i_bit0_ioreq1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 extio_i_bit0_ioreq1 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {0} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {8} \
    CONFIG.DOUT_WIDTH {1} \
  ] $extio_i_bit0_ioreq1


  set_property SELECTED_SIM_MODEL rtl  $extio_i_bit0_ioreq1

  # Create instance: extio_concat_o, and set properties
  set extio_concat_o [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 extio_concat_o ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {1} \
    CONFIG.IN1_WIDTH {1} \
    CONFIG.IN2_WIDTH {1} \
    CONFIG.IN3_WIDTH {4} \
    CONFIG.IN4_WIDTH {1} \
    CONFIG.NUM_PORTS {5} \
  ] $extio_concat_o


  set_property SELECTED_SIM_MODEL rtl  $extio_concat_o

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  set_property SELECTED_SIM_MODEL rtl  $proc_sys_reset_0

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [list \
    CONFIG.NUM_MI {4} \
    CONFIG.NUM_SI {1} \
  ] $smartconnect_0


  set_property SELECTED_SIM_MODEL rtl  $smartconnect_0

  # Create instance: soc_p1_i_concat16, and set properties
  set soc_p1_i_concat16 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 soc_p1_i_concat16 ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {8} \
    CONFIG.IN1_WIDTH {8} \
  ] $soc_p1_i_concat16


  # Create instance: xlconst_zerox9, and set properties
  set xlconst_zerox9 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconst_zerox9 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {8} \
  ] $xlconst_zerox9


  set_property SELECTED_SIM_MODEL rtl  $xlconst_zerox9

  # Create instance: xlconst_zero, and set properties
  set xlconst_zero [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconst_zero ]
  set_property CONFIG.CONST_VAL {0} $xlconst_zero


  set_property SELECTED_SIM_MODEL rtl  $xlconst_zero

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]

  set_property SELECTED_SIM_MODEL rtl  $xlconstant_1

  # Create instance: extio8x4_axis_target_0, and set properties
  set extio8x4_axis_target_0 [ create_bd_cell -type ip -vlnv soclabs.org:slip:extio8x4_axis_target:1.0 extio8x4_axis_target_0 ]

  # Create instance: p1_z6to0, and set properties
  set p1_z6to0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 p1_z6to0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {6} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {16} \
    CONFIG.DOUT_WIDTH {7} \
  ] $p1_z6to0


  set_property SELECTED_SIM_MODEL rtl  $p1_z6to0

  # Create instance: p1_o6to0, and set properties
  set p1_o6to0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 p1_o6to0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {6} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {16} \
    CONFIG.DOUT_WIDTH {7} \
  ] $p1_o6to0


  set_property SELECTED_SIM_MODEL rtl  $p1_o6to0

  # Create instance: pmoda_i_bit7_notrpimode, and set properties
  set pmoda_i_bit7_notrpimode [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 pmoda_i_bit7_notrpimode ]
  set_property -dict [list \
    CONFIG.DIN_FROM {7} \
    CONFIG.DIN_TO {7} \
    CONFIG.DIN_WIDTH {8} \
    CONFIG.DOUT_WIDTH {1} \
  ] $pmoda_i_bit7_notrpimode


  set_property SELECTED_SIM_MODEL rtl  $pmoda_i_bit7_notrpimode

  # Create instance: rpi_extio_o, and set properties
  set rpi_extio_o [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 rpi_extio_o ]

  set_property SELECTED_SIM_MODEL rtl  $rpi_extio_o

  # Create instance: zynq_extio_o, and set properties
  set zynq_extio_o [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 zynq_extio_o ]

  set_property SELECTED_SIM_MODEL rtl  $zynq_extio_o

  # Create instance: pmoda_mux_o, and set properties
  set pmoda_mux_o [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 pmoda_mux_o ]
  set_property CONFIG.C_OPERATION {or} $pmoda_mux_o


  set_property SELECTED_SIM_MODEL rtl  $pmoda_mux_o

  # Create instance: rpi_enable8, and set properties
  set rpi_enable8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 rpi_enable8 ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {1} \
    CONFIG.IN1_WIDTH {1} \
    CONFIG.IN2_WIDTH {1} \
    CONFIG.IN3_WIDTH {1} \
    CONFIG.IN4_WIDTH {1} \
    CONFIG.IN5_WIDTH {1} \
    CONFIG.IN6_WIDTH {1} \
    CONFIG.IN7_WIDTH {1} \
    CONFIG.NUM_PORTS {8} \
  ] $rpi_enable8


  set_property SELECTED_SIM_MODEL rtl  $rpi_enable8

  # Create instance: axi_stream_io_1, and set properties
  set axi_stream_io_1 [ create_bd_cell -type ip -vlnv soclabs.org:user:axi_stream_io:1.0 axi_stream_io_1 ]

  set_property SELECTED_SIM_MODEL rtl  $axi_stream_io_1

  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_1 ]
  set_property CONFIG.FIFO_DEPTH {64} $axis_data_fifo_1


  set_property SELECTED_SIM_MODEL rtl  $axis_data_fifo_1

  # Create instance: pmoda_concat_z, and set properties
  set pmoda_concat_z [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 pmoda_concat_z ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {7} \
    CONFIG.IN1_WIDTH {1} \
    CONFIG.IN2_WIDTH {1} \
    CONFIG.IN3_WIDTH {1} \
    CONFIG.IN4_WIDTH {1} \
    CONFIG.IN5_WIDTH {1} \
    CONFIG.IN6_WIDTH {1} \
    CONFIG.IN7_WIDTH {1} \
    CONFIG.NUM_PORTS {2} \
  ] $pmoda_concat_z


  set_property SELECTED_SIM_MODEL rtl  $pmoda_concat_z

  # Create instance: pmoda_concat_o, and set properties
  set pmoda_concat_o [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 pmoda_concat_o ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {7} \
    CONFIG.IN1_WIDTH {1} \
    CONFIG.IN2_WIDTH {1} \
    CONFIG.IN3_WIDTH {1} \
    CONFIG.IN4_WIDTH {1} \
    CONFIG.IN5_WIDTH {1} \
    CONFIG.IN6_WIDTH {1} \
    CONFIG.IN7_WIDTH {1} \
    CONFIG.NUM_PORTS {2} \
  ] $pmoda_concat_o


  set_property SELECTED_SIM_MODEL rtl  $pmoda_concat_o

  # Create instance: zynq_extio_z, and set properties
  set zynq_extio_z [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 zynq_extio_z ]

  set_property SELECTED_SIM_MODEL rtl  $zynq_extio_z

  # Create instance: rpi_extio_z, and set properties
  set rpi_extio_z [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 rpi_extio_z ]

  set_property SELECTED_SIM_MODEL rtl  $rpi_extio_z

  # Create instance: pmoda_mux_z, and set properties
  set pmoda_mux_z [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 pmoda_mux_z ]
  set_property CONFIG.C_OPERATION {or} $pmoda_mux_z


  set_property SELECTED_SIM_MODEL rtl  $pmoda_mux_z

  # Create instance: zynq_extio_i_maskx8, and set properties
  set zynq_extio_i_maskx8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 zynq_extio_i_maskx8 ]

  set_property SELECTED_SIM_MODEL rtl  $zynq_extio_i_maskx8

  # Create instance: p1_o15to8, and set properties
  set p1_o15to8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 p1_o15to8 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {15} \
    CONFIG.DIN_TO {8} \
    CONFIG.DIN_WIDTH {16} \
    CONFIG.DOUT_WIDTH {8} \
  ] $p1_o15to8


  set_property SELECTED_SIM_MODEL rtl  $p1_o15to8

  # Create instance: soc_p1_mux_o, and set properties
  set soc_p1_mux_o [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 soc_p1_mux_o ]
  set_property CONFIG.C_OPERATION {or} $soc_p1_mux_o


  set_property SELECTED_SIM_MODEL rtl  $soc_p1_mux_o

  # Create instance: rpi_p0_o, and set properties
  set rpi_p0_o [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 rpi_p0_o ]

  set_property SELECTED_SIM_MODEL rtl  $rpi_p0_o

  # Create instance: zynq_p0_o, and set properties
  set zynq_p0_o [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 zynq_p0_o ]

  set_property SELECTED_SIM_MODEL rtl  $zynq_p0_o

  # Create instance: pmoda_6to0, and set properties
  set pmoda_6to0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 pmoda_6to0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {6} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {8} \
    CONFIG.DOUT_WIDTH {7} \
  ] $pmoda_6to0


  set_property SELECTED_SIM_MODEL rtl  $pmoda_6to0

  # Create instance: pmod_I_8, and set properties
  set pmod_I_8 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 pmod_I_8 ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {7} \
    CONFIG.IN1_WIDTH {1} \
  ] $pmod_I_8


  # Create instance: soc_p1_0_7to0, and set properties
  set soc_p1_0_7to0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 soc_p1_0_7to0 ]
  set_property -dict [list \
    CONFIG.DIN_FROM {7} \
    CONFIG.DIN_TO {0} \
    CONFIG.DIN_WIDTH {16} \
    CONFIG.DOUT_WIDTH {8} \
  ] $soc_p1_0_7to0


  set_property SELECTED_SIM_MODEL rtl  $soc_p1_0_7to0

  # Create instance: gpio1_concat_i, and set properties
  set gpio1_concat_i [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 gpio1_concat_i ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {8} \
    CONFIG.IN1_WIDTH {8} \
  ] $gpio1_concat_i


  set_property SELECTED_SIM_MODEL rtl  $gpio1_concat_i

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_0


  # Create instance: not_rpi_enable9, and set properties
  set not_rpi_enable9 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 not_rpi_enable9 ]
  set_property -dict [list \
    CONFIG.IN0_WIDTH {1} \
    CONFIG.IN1_WIDTH {1} \
    CONFIG.IN2_WIDTH {1} \
    CONFIG.IN3_WIDTH {1} \
    CONFIG.IN4_WIDTH {1} \
    CONFIG.IN5_WIDTH {1} \
    CONFIG.IN6_WIDTH {1} \
    CONFIG.IN7_WIDTH {1} \
    CONFIG.NUM_PORTS {8} \
  ] $not_rpi_enable9


  set_property SELECTED_SIM_MODEL rtl  $not_rpi_enable9

  # Create instance: extio_ip_sel, and set properties
  set extio_ip_sel [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 extio_ip_sel ]
  set_property CONFIG.C_SIZE {4} $extio_ip_sel


  set_property SELECTED_SIM_MODEL rtl  $extio_ip_sel

  # Create instance: extio_op_sel1, and set properties
  set extio_op_sel1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 extio_op_sel1 ]
  set_property CONFIG.C_SIZE {4} $extio_op_sel1


  set_property SELECTED_SIM_MODEL rtl  $extio_op_sel1

  # Create instance: extio_io_mux, and set properties
  set extio_io_mux [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 extio_io_mux ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {4} \
  ] $extio_io_mux


  set_property SELECTED_SIM_MODEL rtl  $extio_io_mux

  # Create interface connections
  connect_bd_intf_net -intf_net axi_stream_io_0_tx [get_bd_intf_pins axi_stream_io_0/tx] [get_bd_intf_pins extio8x4_axis_target_0/axis_rx0]
  connect_bd_intf_net -intf_net axi_stream_io_1_tx [get_bd_intf_pins extio8x4_axis_target_0/axis_rx1] [get_bd_intf_pins axi_stream_io_1/tx]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins axi_stream_io_0/rx] [get_bd_intf_pins axis_data_fifo_0/M_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_1_M_AXIS [get_bd_intf_pins axis_data_fifo_1/M_AXIS] [get_bd_intf_pins axi_stream_io_1/rx]
  connect_bd_intf_net -intf_net extio8x4_axis_target_0_axis_tx0 [get_bd_intf_pins axis_data_fifo_0/S_AXIS] [get_bd_intf_pins extio8x4_axis_target_0/axis_tx0]
  connect_bd_intf_net -intf_net extio8x4_axis_target_0_axis_tx1 [get_bd_intf_pins axis_data_fifo_1/S_AXIS] [get_bd_intf_pins extio8x4_axis_target_0/axis_tx1]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins smartconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins axi_gpio_1/S_AXI] [get_bd_intf_pins smartconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins axi_stream_io_0/S_AXI] [get_bd_intf_pins smartconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins axi_stream_io_1/S_AXI] [get_bd_intf_pins smartconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_M_AXI_HPM0_LPD [get_bd_intf_pins S00_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]

  # Create port connections
  connect_bd_net -net P1_op6to0_Dout [get_bd_pins p1_o6to0/Dout] [get_bd_pins pmoda_concat_o/In0]
  connect_bd_net -net P1_ts6to0_Dout [get_bd_pins p1_z6to0/Dout] [get_bd_pins pmoda_concat_z/In0]
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins axi_gpio_0/gpio_io_o] [get_bd_pins p0_tri_i]
  connect_bd_net -net cmsdk_mcu_chip_0_p0_o [get_bd_pins p0_tri_o] [get_bd_pins axi_gpio_0/gpio_io_i]
  connect_bd_net -net cmsdk_mcu_chip_0_p0_z [get_bd_pins p0_tri_z] [get_bd_pins axi_gpio_0/gpio2_io_i]
  connect_bd_net -net const0 [get_bd_pins xlconst_zero/dout] [get_bd_pins swdio_tri_i] [get_bd_pins swdclk_i] [get_bd_pins extio8x4_axis_target_0/testmode] [get_bd_pins extio_concat_z/In2] [get_bd_pins pmoda_concat_o/In1] [get_bd_pins extio_concat_o/In4] [get_bd_pins pmod_I_8/In1]
  connect_bd_net -net const1 [get_bd_pins xlconstant_1/dout] [get_bd_pins pmoda_concat_z/In1] [get_bd_pins extio_concat_z/In0] [get_bd_pins extio_concat_z/In1] [get_bd_pins extio_concat_z/In4]
  connect_bd_net -net extio8x4_axis_target_0_ioack_o [get_bd_pins extio8x4_axis_target_0/ioack_o] [get_bd_pins extio_concat_o/In2]
  connect_bd_net -net extio8x4_axis_target_0_iodata4_e [get_bd_pins extio8x4_axis_target_0/iodata4_e] [get_bd_pins extio_op_sel1/Op1]
  connect_bd_net -net extio8x4_axis_target_0_iodata4_o [get_bd_pins extio8x4_axis_target_0/iodata4_o] [get_bd_pins extio_op_sel1/Op2]
  connect_bd_net -net extio8x4_axis_target_0_iodata4_t [get_bd_pins extio8x4_axis_target_0/iodata4_t] [get_bd_pins extio_concat_z/In3] [get_bd_pins extio_ip_sel/Op1]
  connect_bd_net -net extio_concat_z_dout [get_bd_pins extio_concat_z/dout] [get_bd_pins zynq_extio_z/Op1]
  connect_bd_net -net extio_io_mux_Res [get_bd_pins extio_io_mux/Res] [get_bd_pins extio_concat_o/In3]
  connect_bd_net -net extio_ip_sel_Res [get_bd_pins extio_ip_sel/Res] [get_bd_pins extio_io_mux/Op2]
  connect_bd_net -net extio_op_sel1_Res [get_bd_pins extio_op_sel1/Res] [get_bd_pins extio_io_mux/Op1]
  connect_bd_net -net gpio1_concat_i_dout [get_bd_pins gpio1_concat_i/dout] [get_bd_pins axi_gpio_1/gpio_io_i]
  connect_bd_net -net not_rpimode [get_bd_pins pmoda_i_bit7_notrpimode/Dout] [get_bd_pins not_rpi_enable9/In0] [get_bd_pins not_rpi_enable9/In1] [get_bd_pins not_rpi_enable9/In2] [get_bd_pins not_rpi_enable9/In3] [get_bd_pins not_rpi_enable9/In4] [get_bd_pins not_rpi_enable9/In5] [get_bd_pins not_rpi_enable9/In6] [get_bd_pins not_rpi_enable9/In7] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net not_rpimodex8 [get_bd_pins not_rpi_enable9/dout] [get_bd_pins zynq_extio_o/Op1] [get_bd_pins zynq_extio_i_maskx8/Op1] [get_bd_pins rpi_extio_z/Op2] [get_bd_pins zynq_p0_o/Op1]
  connect_bd_net -net p1_o_bit0_ioreq1_Dout [get_bd_pins extio_i_bit0_ioreq1/Dout] [get_bd_pins extio8x4_axis_target_0/ioreq1_a] [get_bd_pins extio_concat_o/In0]
  connect_bd_net -net p1_o_bit1_ioreq2_Dout [get_bd_pins extio_i_bit1_ioreq2/Dout] [get_bd_pins extio8x4_axis_target_0/ioreq2_a] [get_bd_pins extio_concat_o/In1]
  connect_bd_net -net p1_o_bit3_iodatata4_Dout [get_bd_pins extio_i_bit6to3_iodatata4/Dout] [get_bd_pins extio8x4_axis_target_0/iodata4_i] [get_bd_pins extio_ip_sel/Op2]
  connect_bd_net -net p1_tri_o_1 [get_bd_pins p1_tri_o] [get_bd_pins p1_o6to0/Din] [get_bd_pins soc_p1_0_7to0/Din] [get_bd_pins p1_o15to8/Din]
  connect_bd_net -net p1_z [get_bd_pins p1_tri_z] [get_bd_pins p1_z6to0/Din] [get_bd_pins axi_gpio_1/gpio2_io_i]
  connect_bd_net -net pmod_i_6to0 [get_bd_pins pmoda_6to0/Dout] [get_bd_pins pmod_I_8/In0]
  connect_bd_net -net pmod_i_8 [get_bd_pins pmod_I_8/dout] [get_bd_pins rpi_p0_o/Op2]
  connect_bd_net -net pmod_tri_o [get_bd_pins pmoda_mux_o/Res] [get_bd_pins pmoda_tri_o]
  connect_bd_net -net pmod_tri_z [get_bd_pins pmoda_mux_z/Res] [get_bd_pins pmoda_tri_z]
  connect_bd_net -net pmoda_concat_o_dout [get_bd_pins pmoda_concat_o/dout] [get_bd_pins rpi_extio_o/Op2]
  connect_bd_net -net pmoda_concat_z_dout [get_bd_pins pmoda_concat_z/dout] [get_bd_pins rpi_extio_z/Op1]
  connect_bd_net -net pmoda_i_bit7_rpimode1_Dout [get_bd_pins p1_o15to8/Dout] [get_bd_pins gpio1_concat_i/In1]
  connect_bd_net -net pmoda_tri_i_1 [get_bd_pins pmoda_tri_i] [get_bd_pins pmoda_6to0/Din] [get_bd_pins pmoda_i_bit7_notrpimode/Din]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins axi_stream_io_0/S_AXI_ARESETN] [get_bd_pins axi_stream_io_1/S_AXI_ARESETN] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins axis_data_fifo_1/s_axis_aresetn] [get_bd_pins extio8x4_axis_target_0/resetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_gpio_1/s_axi_aresetn] [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins nrst]
  connect_bd_net -net rpi_extio_o_Res [get_bd_pins rpi_extio_o/Res] [get_bd_pins pmoda_mux_o/Op1]
  connect_bd_net -net rpi_extio_z_sel [get_bd_pins rpi_extio_z/Res] [get_bd_pins pmoda_mux_z/Op2]
  connect_bd_net -net rpi_p0_o_Res [get_bd_pins rpi_p0_o/Res] [get_bd_pins soc_p1_mux_o/Op1]
  connect_bd_net -net rpimode [get_bd_pins util_vector_logic_0/Res] [get_bd_pins rpi_enable8/In0] [get_bd_pins rpi_enable8/In1] [get_bd_pins rpi_enable8/In2] [get_bd_pins rpi_enable8/In3] [get_bd_pins rpi_enable8/In4] [get_bd_pins rpi_enable8/In5] [get_bd_pins rpi_enable8/In6] [get_bd_pins rpi_enable8/In7]
  connect_bd_net -net rpimodex8 [get_bd_pins rpi_enable8/dout] [get_bd_pins rpi_p0_o/Op1] [get_bd_pins rpi_extio_o/Op1] [get_bd_pins zynq_extio_z/Op2]
  connect_bd_net -net soc_p1_0_7to0_Dout [get_bd_pins soc_p1_0_7to0/Dout] [get_bd_pins zynq_extio_i_maskx8/Op2]
  connect_bd_net -net soc_p1_mux_o [get_bd_pins soc_p1_mux_o/Res] [get_bd_pins soc_p1_i_concat16/In0]
  connect_bd_net -net soc_p1_tri_i16 [get_bd_pins soc_p1_i_concat16/dout] [get_bd_pins p1_tri_i]
  connect_bd_net -net xlconst_zerox9 [get_bd_pins xlconst_zerox9/dout] [get_bd_pins soc_p1_i_concat16/In1]
  connect_bd_net -net zynq_extio_o [get_bd_pins extio_concat_o/dout] [get_bd_pins zynq_extio_o/Op2] [get_bd_pins zynq_p0_o/Op2]
  connect_bd_net -net zynq_extio_o_Res [get_bd_pins zynq_extio_o/Res] [get_bd_pins pmoda_mux_o/Op2]
  connect_bd_net -net zynq_extio_z_sel [get_bd_pins zynq_extio_z/Res] [get_bd_pins pmoda_mux_z/Op1]
  connect_bd_net -net zynq_p0_o [get_bd_pins zynq_p0_o/Res] [get_bd_pins soc_p1_mux_o/Op2]
  connect_bd_net -net zynq_pmoda_i_maskx8 [get_bd_pins zynq_extio_i_maskx8/Res] [get_bd_pins extio_i_bit1_ioreq2/Din] [get_bd_pins extio_i_bit6to3_iodatata4/Din] [get_bd_pins extio_i_bit0_ioreq1/Din] [get_bd_pins gpio1_concat_i/In0]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins aclk] [get_bd_pins axi_stream_io_0/S_AXI_ACLK] [get_bd_pins axi_stream_io_1/S_AXI_ACLK] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins axis_data_fifo_1/s_axis_aclk] [get_bd_pins extio8x4_axis_target_0/clk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_gpio_1/s_axi_aclk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_resetn0 [get_bd_pins ext_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in]

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
  set pmoda_tri_i [ create_bd_port -dir I -from 7 -to 0 pmoda_tri_i ]
  set pmoda_tri_o [ create_bd_port -dir O -from 7 -to 0 pmoda_tri_o ]
  set pmoda_tri_z [ create_bd_port -dir O -from 7 -to 0 pmoda_tri_z ]

  # Create instance: cmsdk_socket
  create_hier_cell_cmsdk_socket [current_bd_instance .] cmsdk_socket

  # Create instance: nanosoc_chip_0, and set properties
  set nanosoc_chip_0 [ create_bd_cell -type ip -vlnv soclabs.org:user:nanosoc_chip:1.0 nanosoc_chip_0 ]

  set_property SELECTED_SIM_MODEL rtl  $nanosoc_chip_0

  # Create instance: xlconstant_zero, and set properties
  set xlconstant_zero [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_zero ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_zero


  # Create instance: xlconstant_zerox4, and set properties
  set xlconstant_zerox4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_zerox4 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {4} \
  ] $xlconstant_zerox4


  set_property SELECTED_SIM_MODEL rtl  $xlconstant_zerox4

  # Create instance: zynq_ultra_ps_e_0, and set properties
  set zynq_ultra_ps_e_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e_0 ]
  set_property -dict [list \
    CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_DDR_RAM_HIGHADDR {0xFFFFFFFF} \
    CONFIG.PSU_DDR_RAM_HIGHADDR_OFFSET {0x800000000} \
    CONFIG.PSU_DDR_RAM_LOWADDR_OFFSET {0x80000000} \
    CONFIG.PSU_MIO_0_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_0_SLEW {slow} \
    CONFIG.PSU_MIO_10_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_10_SLEW {slow} \
    CONFIG.PSU_MIO_11_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_11_SLEW {slow} \
    CONFIG.PSU_MIO_12_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_12_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_12_POLARITY {Default} \
    CONFIG.PSU_MIO_12_SLEW {slow} \
    CONFIG.PSU_MIO_13_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_13_POLARITY {Default} \
    CONFIG.PSU_MIO_13_SLEW {slow} \
    CONFIG.PSU_MIO_14_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_14_POLARITY {Default} \
    CONFIG.PSU_MIO_14_SLEW {slow} \
    CONFIG.PSU_MIO_15_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_15_POLARITY {Default} \
    CONFIG.PSU_MIO_15_SLEW {slow} \
    CONFIG.PSU_MIO_16_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_16_POLARITY {Default} \
    CONFIG.PSU_MIO_16_SLEW {slow} \
    CONFIG.PSU_MIO_17_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_17_POLARITY {Default} \
    CONFIG.PSU_MIO_17_SLEW {slow} \
    CONFIG.PSU_MIO_18_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_18_POLARITY {Default} \
    CONFIG.PSU_MIO_18_SLEW {slow} \
    CONFIG.PSU_MIO_19_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_19_POLARITY {Default} \
    CONFIG.PSU_MIO_19_SLEW {slow} \
    CONFIG.PSU_MIO_1_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_1_SLEW {slow} \
    CONFIG.PSU_MIO_20_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_20_POLARITY {Default} \
    CONFIG.PSU_MIO_20_SLEW {slow} \
    CONFIG.PSU_MIO_21_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_21_POLARITY {Default} \
    CONFIG.PSU_MIO_21_SLEW {slow} \
    CONFIG.PSU_MIO_22_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_22_POLARITY {Default} \
    CONFIG.PSU_MIO_22_SLEW {slow} \
    CONFIG.PSU_MIO_23_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_23_POLARITY {Default} \
    CONFIG.PSU_MIO_23_SLEW {slow} \
    CONFIG.PSU_MIO_24_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_24_SLEW {slow} \
    CONFIG.PSU_MIO_25_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_25_SLEW {slow} \
    CONFIG.PSU_MIO_27_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_27_POLARITY {Default} \
    CONFIG.PSU_MIO_27_SLEW {slow} \
    CONFIG.PSU_MIO_28_POLARITY {Default} \
    CONFIG.PSU_MIO_29_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_29_POLARITY {Default} \
    CONFIG.PSU_MIO_29_SLEW {slow} \
    CONFIG.PSU_MIO_2_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_2_SLEW {slow} \
    CONFIG.PSU_MIO_30_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_30_POLARITY {Default} \
    CONFIG.PSU_MIO_30_SLEW {fast} \
    CONFIG.PSU_MIO_32_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_32_POLARITY {Default} \
    CONFIG.PSU_MIO_32_SLEW {slow} \
    CONFIG.PSU_MIO_33_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_33_POLARITY {Default} \
    CONFIG.PSU_MIO_33_SLEW {slow} \
    CONFIG.PSU_MIO_34_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_34_POLARITY {Default} \
    CONFIG.PSU_MIO_34_SLEW {slow} \
    CONFIG.PSU_MIO_35_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_35_SLEW {slow} \
    CONFIG.PSU_MIO_36_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_36_POLARITY {Default} \
    CONFIG.PSU_MIO_36_SLEW {slow} \
    CONFIG.PSU_MIO_37_POLARITY {Default} \
    CONFIG.PSU_MIO_38_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_38_POLARITY {Default} \
    CONFIG.PSU_MIO_38_SLEW {slow} \
    CONFIG.PSU_MIO_39_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_39_POLARITY {Default} \
    CONFIG.PSU_MIO_39_SLEW {slow} \
    CONFIG.PSU_MIO_3_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_3_SLEW {slow} \
    CONFIG.PSU_MIO_40_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_40_POLARITY {Default} \
    CONFIG.PSU_MIO_40_SLEW {slow} \
    CONFIG.PSU_MIO_41_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_41_POLARITY {Default} \
    CONFIG.PSU_MIO_41_SLEW {slow} \
    CONFIG.PSU_MIO_42_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_42_POLARITY {Default} \
    CONFIG.PSU_MIO_42_SLEW {slow} \
    CONFIG.PSU_MIO_43_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_43_POLARITY {Default} \
    CONFIG.PSU_MIO_43_SLEW {slow} \
    CONFIG.PSU_MIO_44_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_44_POLARITY {Default} \
    CONFIG.PSU_MIO_44_SLEW {slow} \
    CONFIG.PSU_MIO_45_POLARITY {Default} \
    CONFIG.PSU_MIO_46_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_46_POLARITY {Default} \
    CONFIG.PSU_MIO_46_SLEW {slow} \
    CONFIG.PSU_MIO_47_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_47_POLARITY {Default} \
    CONFIG.PSU_MIO_47_SLEW {slow} \
    CONFIG.PSU_MIO_48_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_48_POLARITY {Default} \
    CONFIG.PSU_MIO_48_SLEW {slow} \
    CONFIG.PSU_MIO_49_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_49_POLARITY {Default} \
    CONFIG.PSU_MIO_49_SLEW {slow} \
    CONFIG.PSU_MIO_4_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_4_SLEW {slow} \
    CONFIG.PSU_MIO_50_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_50_POLARITY {Default} \
    CONFIG.PSU_MIO_50_SLEW {slow} \
    CONFIG.PSU_MIO_51_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_51_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_51_POLARITY {Default} \
    CONFIG.PSU_MIO_51_SLEW {slow} \
    CONFIG.PSU_MIO_54_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_54_SLEW {slow} \
    CONFIG.PSU_MIO_56_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_56_SLEW {slow} \
    CONFIG.PSU_MIO_57_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_57_SLEW {slow} \
    CONFIG.PSU_MIO_58_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_58_SLEW {slow} \
    CONFIG.PSU_MIO_59_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_59_SLEW {slow} \
    CONFIG.PSU_MIO_5_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_5_SLEW {slow} \
    CONFIG.PSU_MIO_60_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_60_SLEW {slow} \
    CONFIG.PSU_MIO_61_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_61_SLEW {slow} \
    CONFIG.PSU_MIO_62_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_62_SLEW {slow} \
    CONFIG.PSU_MIO_63_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_63_SLEW {slow} \
    CONFIG.PSU_MIO_64_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_64_SLEW {slow} \
    CONFIG.PSU_MIO_65_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_65_SLEW {slow} \
    CONFIG.PSU_MIO_66_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_66_SLEW {slow} \
    CONFIG.PSU_MIO_67_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_67_SLEW {slow} \
    CONFIG.PSU_MIO_68_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_68_SLEW {slow} \
    CONFIG.PSU_MIO_69_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_69_SLEW {slow} \
    CONFIG.PSU_MIO_6_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_6_SLEW {slow} \
    CONFIG.PSU_MIO_76_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_76_SLEW {slow} \
    CONFIG.PSU_MIO_77_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_77_SLEW {slow} \
    CONFIG.PSU_MIO_7_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_7_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_7_POLARITY {Default} \
    CONFIG.PSU_MIO_7_SLEW {slow} \
    CONFIG.PSU_MIO_8_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_8_POLARITY {Default} \
    CONFIG.PSU_MIO_8_SLEW {slow} \
    CONFIG.PSU_MIO_9_DRIVE_STRENGTH {4} \
    CONFIG.PSU_MIO_9_SLEW {slow} \
    CONFIG.PSU_MIO_TREE_PERIPHERALS {Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#SPI 1#GPIO0 MIO#GPIO0 MIO#SPI 1#SPI 1#SPI 1#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0\
MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#I2C 1#I2C 1#PMU GPI 0#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#PMU GPI 5#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#PMU GPO 3#GPIO1\
MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO##########################} \
    CONFIG.PSU_MIO_TREE_SIGNALS {sclk_out#miso_mo1#mo2#mo3#mosi_mi0#n_ss_out#sclk_out#gpio0[7]#gpio0[8]#n_ss_out[0]#miso#mosi#gpio0[12]#gpio0[13]#gpio0[14]#gpio0[15]#gpio0[16]#gpio0[17]#gpio0[18]#gpio0[19]#gpio0[20]#gpio0[21]#gpio0[22]#gpio0[23]#scl_out#sda_out#gpi[0]#gpio1[27]#gpio1[28]#gpio1[29]#gpio1[30]#gpi[5]#gpio1[32]#gpio1[33]#gpio1[34]#gpo[3]#gpio1[36]#gpio1[37]#gpio1[38]#gpio1[39]#gpio1[40]#gpio1[41]#gpio1[42]#gpio1[43]#gpio1[44]#gpio1[45]#gpio1[46]#gpio1[47]#gpio1[48]#gpio1[49]#gpio1[50]#gpio1[51]##########################}\
\
    CONFIG.PSU__ACT_DDR_FREQ_MHZ {1066.656006} \
    CONFIG.PSU__CAN1__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__ACT_FREQMHZ {1333.333008} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__FREQMHZ {1333.333} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__ACPU__FRAC_ENABLED {1} \
    CONFIG.PSU__CRF_APB__APLL_CTRL__FRACFREQ {1333.333} \
    CONFIG.PSU__CRF_APB__APLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__APLL_FRAC_CFG__ENABLED {1} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_TRACE_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__ACT_FREQMHZ {533.328003} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1200} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__ACT_FREQMHZ {444.444336} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__SRCSEL {APLL} \
    CONFIG.PSU__CRF_APB__DPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__ACT_FREQMHZ {533.328003} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__ACT_FREQMHZ {499.994995} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__ACT_FREQMHZ {533.328003} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__FREQMHZ {533.33} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__VPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__ACT_FREQMHZ {499.994995} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__AMS_REF_CTRL__ACT_FREQMHZ {49.999500} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__ACT_FREQMHZ {533.328003} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__FREQMHZ {533.333} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__DLL_REF_CTRL__ACT_FREQMHZ {999.989990} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__I2C1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__IOPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__ACT_FREQMHZ {249.997498} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__ACT_FREQMHZ {499.994995} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__FREQMHZ {500} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__ACT_FREQMHZ {199.998001} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__FREQMHZ {200} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__ACT_FREQMHZ {39.999599} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {40} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PL1_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__ACT_FREQMHZ {124.998749} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__FREQMHZ {125} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__RPLL_CTRL__SRCSEL {PSS_REF_CLK} \
    CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__ACT_FREQMHZ {199.998001} \
    CONFIG.PSU__CRL_APB__SPI1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__FREQMHZ {100} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CSUPMU__PERIPHERAL__VALID {1} \
    CONFIG.PSU__DDRC__BG_ADDR_COUNT {1} \
    CONFIG.PSU__DDRC__BRC_MAPPING {ROW_BANK_COL} \
    CONFIG.PSU__DDRC__BUS_WIDTH {64 Bit} \
    CONFIG.PSU__DDRC__CL {16} \
    CONFIG.PSU__DDRC__CLOCK_STOP_EN {0} \
    CONFIG.PSU__DDRC__COMPONENTS {Components} \
    CONFIG.PSU__DDRC__CWL {14} \
    CONFIG.PSU__DDRC__DDR4_ADDR_MAPPING {0} \
    CONFIG.PSU__DDRC__DDR4_CAL_MODE_ENABLE {0} \
    CONFIG.PSU__DDRC__DDR4_CRC_CONTROL {0} \
    CONFIG.PSU__DDRC__DDR4_T_REF_MODE {0} \
    CONFIG.PSU__DDRC__DDR4_T_REF_RANGE {Normal (0-85)} \
    CONFIG.PSU__DDRC__DEVICE_CAPACITY {8192 MBits} \
    CONFIG.PSU__DDRC__DM_DBI {DM_NO_DBI} \
    CONFIG.PSU__DDRC__DRAM_WIDTH {16 Bits} \
    CONFIG.PSU__DDRC__ECC {Disabled} \
    CONFIG.PSU__DDRC__FGRM {1X} \
    CONFIG.PSU__DDRC__LP_ASR {manual normal} \
    CONFIG.PSU__DDRC__MEMORY_TYPE {DDR 4} \
    CONFIG.PSU__DDRC__PARITY_ENABLE {0} \
    CONFIG.PSU__DDRC__PER_BANK_REFRESH {0} \
    CONFIG.PSU__DDRC__PHY_DBI_MODE {0} \
    CONFIG.PSU__DDRC__RANK_ADDR_COUNT {0} \
    CONFIG.PSU__DDRC__ROW_ADDR_COUNT {16} \
    CONFIG.PSU__DDRC__SELF_REF_ABORT {0} \
    CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2400R} \
    CONFIG.PSU__DDRC__STATIC_RD_MODE {0} \
    CONFIG.PSU__DDRC__TRAIN_DATA_EYE {1} \
    CONFIG.PSU__DDRC__TRAIN_READ_GATE {1} \
    CONFIG.PSU__DDRC__TRAIN_WRITE_LEVEL {1} \
    CONFIG.PSU__DDRC__T_FAW {30.0} \
    CONFIG.PSU__DDRC__T_RAS_MIN {33} \
    CONFIG.PSU__DDRC__T_RC {47.06} \
    CONFIG.PSU__DDRC__T_RCD {16} \
    CONFIG.PSU__DDRC__T_RP {16} \
    CONFIG.PSU__DDRC__VREF {1} \
    CONFIG.PSU__DDR_HIGH_ADDRESS_GUI_ENABLE {1} \
    CONFIG.PSU__DDR__INTERFACE__FREQMHZ {600.000} \
    CONFIG.PSU__FPD_SLCR__WDT1__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__FPGA_PL0_ENABLE {1} \
    CONFIG.PSU__FPGA_PL1_ENABLE {0} \
    CONFIG.PSU__GPIO0_MIO__IO {MIO 0 .. 25} \
    CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPIO1_MIO__IO {MIO 26 .. 51} \
    CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPIO_EMIO_WIDTH {1} \
    CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__I2C1__PERIPHERAL__IO {MIO 24 .. 25} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC0_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC1_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC2_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__IOU_TTC_APB_CLK__TTC3_SEL {APB} \
    CONFIG.PSU__IOU_SLCR__TTC0__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC1__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC2__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC3__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__WDT0__ACT_FREQMHZ {99.999001} \
    CONFIG.PSU__LPD_SLCR__CSUPMU__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__MAXIGP2__DATA_WIDTH {32} \
    CONFIG.PSU__OVERRIDE__BASIC_CLOCK {0} \
    CONFIG.PSU__PL_CLK0_BUF {TRUE} \
    CONFIG.PSU__PMU_COHERENCY {0} \
    CONFIG.PSU__PMU__AIBACK__ENABLE {0} \
    CONFIG.PSU__PMU__EMIO_GPI__ENABLE {0} \
    CONFIG.PSU__PMU__EMIO_GPO__ENABLE {0} \
    CONFIG.PSU__PMU__GPI0__ENABLE {1} \
    CONFIG.PSU__PMU__GPI0__IO {MIO 26} \
    CONFIG.PSU__PMU__GPI1__ENABLE {0} \
    CONFIG.PSU__PMU__GPI2__ENABLE {0} \
    CONFIG.PSU__PMU__GPI3__ENABLE {0} \
    CONFIG.PSU__PMU__GPI4__ENABLE {0} \
    CONFIG.PSU__PMU__GPI5__ENABLE {1} \
    CONFIG.PSU__PMU__GPI5__IO {MIO 31} \
    CONFIG.PSU__PMU__GPO0__ENABLE {0} \
    CONFIG.PSU__PMU__GPO1__ENABLE {0} \
    CONFIG.PSU__PMU__GPO2__ENABLE {0} \
    CONFIG.PSU__PMU__GPO3__ENABLE {1} \
    CONFIG.PSU__PMU__GPO3__IO {MIO 35} \
    CONFIG.PSU__PMU__GPO3__POLARITY {low} \
    CONFIG.PSU__PMU__GPO4__ENABLE {0} \
    CONFIG.PSU__PMU__GPO5__ENABLE {0} \
    CONFIG.PSU__PMU__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__PMU__PLERROR__ENABLE {0} \
    CONFIG.PSU__PRESET_APPLIED {1} \
    CONFIG.PSU__PROTECTION__FPD_SEGMENTS {SA:0xFD1A0000; SIZE:1280; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware  |   SA:0xFD000000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware  |   SA:0xFD010000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware  |   SA:0xFD020000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware  |   SA:0xFD030000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware  |   SA:0xFD040000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware  |   SA:0xFD050000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware  |   SA:0xFD610000; SIZE:512; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write;\
subsystemId:PMU Firmware  |   SA:0xFD5D0000; SIZE:64; UNIT:KB; RegionTZ:Secure; WrAllowed:Read/Write; subsystemId:PMU Firmware  |  SA:0xFD1A0000 ; SIZE:1280; UNIT:KB; RegionTZ:Secure ; WrAllowed:Read/Write;\
subsystemId:Secure Subsystem} \
    CONFIG.PSU__PROTECTION__MASTERS {USB1:NonSecure;0|USB0:NonSecure;0|S_AXI_LPD:NA;0|S_AXI_HPC1_FPD:NA;0|S_AXI_HPC0_FPD:NA;0|S_AXI_HP3_FPD:NA;0|S_AXI_HP2_FPD:NA;0|S_AXI_HP1_FPD:NA;0|S_AXI_HP0_FPD:NA;0|S_AXI_ACP:NA;0|S_AXI_ACE:NA;0|SD1:NonSecure;0|SD0:NonSecure;0|SATA1:NonSecure;0|SATA0:NonSecure;0|RPU1:Secure;1|RPU0:Secure;1|QSPI:NonSecure;1|PMU:NA;1|PCIe:NonSecure;0|NAND:NonSecure;0|LDMA:NonSecure;1|GPU:NonSecure;1|GEM3:NonSecure;0|GEM2:NonSecure;0|GEM1:NonSecure;0|GEM0:NonSecure;0|FDMA:NonSecure;1|DP:NonSecure;0|DAP:NA;1|Coresight:NA;1|CSU:NA;1|APU:NA;1}\
\
    CONFIG.PSU__PROTECTION__SLAVES {LPD;USB3_1_XHCI;FE300000;FE3FFFFF;0|LPD;USB3_1;FF9E0000;FF9EFFFF;0|LPD;USB3_0_XHCI;FE200000;FE2FFFFF;0|LPD;USB3_0;FF9D0000;FF9DFFFF;0|LPD;UART1;FF010000;FF01FFFF;0|LPD;UART0;FF000000;FF00FFFF;0|LPD;TTC3;FF140000;FF14FFFF;1|LPD;TTC2;FF130000;FF13FFFF;1|LPD;TTC1;FF120000;FF12FFFF;1|LPD;TTC0;FF110000;FF11FFFF;1|FPD;SWDT1;FD4D0000;FD4DFFFF;1|LPD;SWDT0;FF150000;FF15FFFF;1|LPD;SPI1;FF050000;FF05FFFF;1|LPD;SPI0;FF040000;FF04FFFF;0|FPD;SMMU_REG;FD5F0000;FD5FFFFF;1|FPD;SMMU;FD800000;FDFFFFFF;1|FPD;SIOU;FD3D0000;FD3DFFFF;1|FPD;SERDES;FD400000;FD47FFFF;1|LPD;SD1;FF170000;FF17FFFF;0|LPD;SD0;FF160000;FF16FFFF;0|FPD;SATA;FD0C0000;FD0CFFFF;0|LPD;RTC;FFA60000;FFA6FFFF;1|LPD;RSA_CORE;FFCE0000;FFCEFFFF;1|LPD;RPU;FF9A0000;FF9AFFFF;1|LPD;R5_TCM_RAM_GLOBAL;FFE00000;FFE3FFFF;1|LPD;R5_1_Instruction_Cache;FFEC0000;FFECFFFF;1|LPD;R5_1_Data_Cache;FFED0000;FFEDFFFF;1|LPD;R5_1_BTCM_GLOBAL;FFEB0000;FFEBFFFF;1|LPD;R5_1_ATCM_GLOBAL;FFE90000;FFE9FFFF;1|LPD;R5_0_Instruction_Cache;FFE40000;FFE4FFFF;1|LPD;R5_0_Data_Cache;FFE50000;FFE5FFFF;1|LPD;R5_0_BTCM_GLOBAL;FFE20000;FFE2FFFF;1|LPD;R5_0_ATCM_GLOBAL;FFE00000;FFE0FFFF;1|LPD;QSPI_Linear_Address;C0000000;DFFFFFFF;1|LPD;QSPI;FF0F0000;FF0FFFFF;1|LPD;PMU_RAM;FFDC0000;FFDDFFFF;1|LPD;PMU_GLOBAL;FFD80000;FFDBFFFF;1|FPD;PCIE_MAIN;FD0E0000;FD0EFFFF;0|FPD;PCIE_LOW;E0000000;EFFFFFFF;0|FPD;PCIE_HIGH2;8000000000;BFFFFFFFFF;0|FPD;PCIE_HIGH1;600000000;7FFFFFFFF;0|FPD;PCIE_DMA;FD0F0000;FD0FFFFF;0|FPD;PCIE_ATTRIB;FD480000;FD48FFFF;0|LPD;OCM_XMPU_CFG;FFA70000;FFA7FFFF;1|LPD;OCM_SLCR;FF960000;FF96FFFF;1|OCM;OCM;FFFC0000;FFFFFFFF;1|LPD;NAND;FF100000;FF10FFFF;0|LPD;MBISTJTAG;FFCF0000;FFCFFFFF;1|LPD;LPD_XPPU_SINK;FF9C0000;FF9CFFFF;1|LPD;LPD_XPPU;FF980000;FF98FFFF;1|LPD;LPD_SLCR_SECURE;FF4B0000;FF4DFFFF;1|LPD;LPD_SLCR;FF410000;FF4AFFFF;1|LPD;LPD_GPV;FE100000;FE1FFFFF;1|LPD;LPD_DMA_7;FFAF0000;FFAFFFFF;1|LPD;LPD_DMA_6;FFAE0000;FFAEFFFF;1|LPD;LPD_DMA_5;FFAD0000;FFADFFFF;1|LPD;LPD_DMA_4;FFAC0000;FFACFFFF;1|LPD;LPD_DMA_3;FFAB0000;FFABFFFF;1|LPD;LPD_DMA_2;FFAA0000;FFAAFFFF;1|LPD;LPD_DMA_1;FFA90000;FFA9FFFF;1|LPD;LPD_DMA_0;FFA80000;FFA8FFFF;1|LPD;IPI_CTRL;FF380000;FF3FFFFF;1|LPD;IOU_SLCR;FF180000;FF23FFFF;1|LPD;IOU_SECURE_SLCR;FF240000;FF24FFFF;1|LPD;IOU_SCNTRS;FF260000;FF26FFFF;1|LPD;IOU_SCNTR;FF250000;FF25FFFF;1|LPD;IOU_GPV;FE000000;FE0FFFFF;1|LPD;I2C1;FF030000;FF03FFFF;1|LPD;I2C0;FF020000;FF02FFFF;0|FPD;GPU;FD4B0000;FD4BFFFF;1|LPD;GPIO;FF0A0000;FF0AFFFF;1|LPD;GEM3;FF0E0000;FF0EFFFF;0|LPD;GEM2;FF0D0000;FF0DFFFF;0|LPD;GEM1;FF0C0000;FF0CFFFF;0|LPD;GEM0;FF0B0000;FF0BFFFF;0|FPD;FPD_XMPU_SINK;FD4F0000;FD4FFFFF;1|FPD;FPD_XMPU_CFG;FD5D0000;FD5DFFFF;1|FPD;FPD_SLCR_SECURE;FD690000;FD6CFFFF;1|FPD;FPD_SLCR;FD610000;FD68FFFF;1|FPD;FPD_DMA_CH7;FD570000;FD57FFFF;1|FPD;FPD_DMA_CH6;FD560000;FD56FFFF;1|FPD;FPD_DMA_CH5;FD550000;FD55FFFF;1|FPD;FPD_DMA_CH4;FD540000;FD54FFFF;1|FPD;FPD_DMA_CH3;FD530000;FD53FFFF;1|FPD;FPD_DMA_CH2;FD520000;FD52FFFF;1|FPD;FPD_DMA_CH1;FD510000;FD51FFFF;1|FPD;FPD_DMA_CH0;FD500000;FD50FFFF;1|LPD;EFUSE;FFCC0000;FFCCFFFF;1|FPD;Display\
Port;FD4A0000;FD4AFFFF;0|FPD;DPDMA;FD4C0000;FD4CFFFF;0|FPD;DDR_XMPU5_CFG;FD050000;FD05FFFF;1|FPD;DDR_XMPU4_CFG;FD040000;FD04FFFF;1|FPD;DDR_XMPU3_CFG;FD030000;FD03FFFF;1|FPD;DDR_XMPU2_CFG;FD020000;FD02FFFF;1|FPD;DDR_XMPU1_CFG;FD010000;FD01FFFF;1|FPD;DDR_XMPU0_CFG;FD000000;FD00FFFF;1|FPD;DDR_QOS_CTRL;FD090000;FD09FFFF;1|FPD;DDR_PHY;FD080000;FD08FFFF;1|DDR;DDR_LOW;0;7FFFFFFF;1|DDR;DDR_HIGH;800000000;87FFFFFFF;1|FPD;DDDR_CTRL;FD070000;FD070FFF;1|LPD;Coresight;FE800000;FEFFFFFF;1|LPD;CSU_DMA;FFC80000;FFC9FFFF;1|LPD;CSU;FFCA0000;FFCAFFFF;1|LPD;CRL_APB;FF5E0000;FF85FFFF;1|FPD;CRF_APB;FD1A0000;FD2DFFFF;1|FPD;CCI_REG;FD5E0000;FD5EFFFF;1|LPD;CAN1;FF070000;FF07FFFF;0|LPD;CAN0;FF060000;FF06FFFF;0|FPD;APU;FD5C0000;FD5CFFFF;1|LPD;APM_INTC_IOU;FFA20000;FFA2FFFF;1|LPD;APM_FPD_LPD;FFA30000;FFA3FFFF;1|FPD;APM_5;FD490000;FD49FFFF;1|FPD;APM_0;FD0B0000;FD0BFFFF;1|LPD;APM2;FFA10000;FFA1FFFF;1|LPD;APM1;FFA00000;FFA0FFFF;1|LPD;AMS;FFA50000;FFA5FFFF;1|FPD;AFI_5;FD3B0000;FD3BFFFF;1|FPD;AFI_4;FD3A0000;FD3AFFFF;1|FPD;AFI_3;FD390000;FD39FFFF;1|FPD;AFI_2;FD380000;FD38FFFF;1|FPD;AFI_1;FD370000;FD37FFFF;1|FPD;AFI_0;FD360000;FD36FFFF;1|LPD;AFIFM6;FF9B0000;FF9BFFFF;1|FPD;ACPU_GIC;F9010000;F907FFFF;1}\
\
    CONFIG.PSU__PSS_REF_CLK__FREQMHZ {33.333} \
    CONFIG.PSU__QSPI_COHERENCY {0} \
    CONFIG.PSU__QSPI_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {0} \
    CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4} \
    CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__QSPI__PERIPHERAL__IO {MIO 0 .. 5} \
    CONFIG.PSU__QSPI__PERIPHERAL__MODE {Single} \
    CONFIG.PSU__SPI1__GRP_SS0__IO {MIO 9} \
    CONFIG.PSU__SPI1__GRP_SS1__ENABLE {0} \
    CONFIG.PSU__SPI1__GRP_SS2__ENABLE {0} \
    CONFIG.PSU__SPI1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SPI1__PERIPHERAL__IO {MIO 6 .. 11} \
    CONFIG.PSU__SWDT0__CLOCK__ENABLE {0} \
    CONFIG.PSU__SWDT0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SWDT0__RESET__ENABLE {0} \
    CONFIG.PSU__SWDT1__CLOCK__ENABLE {0} \
    CONFIG.PSU__SWDT1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SWDT1__RESET__ENABLE {0} \
    CONFIG.PSU__TTC0__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC0__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC1__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC1__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC2__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC2__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC2__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC3__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC3__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC3__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__USE__IRQ0 {1} \
    CONFIG.PSU__USE__M_AXI_GP0 {0} \
    CONFIG.PSU__USE__M_AXI_GP1 {0} \
    CONFIG.PSU__USE__M_AXI_GP2 {1} \
  ] $zynq_ultra_ps_e_0


  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins cmsdk_socket/S00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_LPD]

  # Create port connections
  connect_bd_net -net cmsdk_socket_nrst [get_bd_pins cmsdk_socket/nrst] [get_bd_pins nanosoc_chip_0/nrst_i]
  connect_bd_net -net cmsdk_socket_p0_tri_i [get_bd_pins cmsdk_socket/p0_tri_i] [get_bd_pins nanosoc_chip_0/p0_i]
  connect_bd_net -net cmsdk_socket_p1_tri_i [get_bd_pins cmsdk_socket/p1_tri_i] [get_bd_pins nanosoc_chip_0/p1_i]
  connect_bd_net -net cmsdk_socket_swdclk_i [get_bd_pins cmsdk_socket/swdclk_i] [get_bd_pins nanosoc_chip_0/swdclk_i]
  connect_bd_net -net cmsdk_socket_swdio_i [get_bd_pins cmsdk_socket/swdio_tri_i] [get_bd_pins nanosoc_chip_0/swdio_i]
  connect_bd_net -net ext_reset_in_1 [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins cmsdk_socket/ext_reset_in]
  connect_bd_net -net p0_tri_o_1 [get_bd_pins nanosoc_chip_0/p0_o] [get_bd_pins cmsdk_socket/p0_tri_o]
  connect_bd_net -net p0_tri_z_1 [get_bd_pins nanosoc_chip_0/p0_z] [get_bd_pins cmsdk_socket/p0_tri_z]
  connect_bd_net -net p1_tri_o_1 [get_bd_pins nanosoc_chip_0/p1_o] [get_bd_pins cmsdk_socket/p1_tri_o]
  connect_bd_net -net p1_tri_z_1 [get_bd_pins nanosoc_chip_0/p1_z] [get_bd_pins cmsdk_socket/p1_tri_z]
  connect_bd_net -net pmoda_i_1 [get_bd_ports pmoda_tri_i] [get_bd_pins cmsdk_socket/pmoda_tri_i]
  connect_bd_net -net pmoda_o_concat9_dout [get_bd_pins cmsdk_socket/pmoda_tri_z] [get_bd_ports pmoda_tri_z]
  connect_bd_net -net swdio_tri_o_1 [get_bd_pins nanosoc_chip_0/swdio_o] [get_bd_pins cmsdk_socket/swdio_tri_o]
  connect_bd_net -net swdio_tri_z_1 [get_bd_pins nanosoc_chip_0/swdio_z] [get_bd_pins cmsdk_socket/swdio_tri_z]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins cmsdk_socket/pmoda_tri_o] [get_bd_ports pmoda_tri_o]
  connect_bd_net -net xlconstant_zero_dout [get_bd_pins xlconstant_zero/dout] [get_bd_pins nanosoc_chip_0/diag_mode] [get_bd_pins nanosoc_chip_0/diag_ctrl] [get_bd_pins nanosoc_chip_0/scan_mode] [get_bd_pins nanosoc_chip_0/scan_enable] [get_bd_pins nanosoc_chip_0/bist_mode] [get_bd_pins nanosoc_chip_0/bist_enable] [get_bd_pins nanosoc_chip_0/alt_mode] [get_bd_pins nanosoc_chip_0/uart_rxd_i] [get_bd_pins nanosoc_chip_0/swd_mode] [get_bd_pins nanosoc_chip_0/test_i]
  connect_bd_net -net xlconstant_zerox4_dout [get_bd_pins xlconstant_zerox4/dout] [get_bd_pins nanosoc_chip_0/scan_in] [get_bd_pins nanosoc_chip_0/bist_in]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins cmsdk_socket/aclk] [get_bd_pins nanosoc_chip_0/clk_i] [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_lpd_aclk]

  # Create address segments
  assign_bd_address -offset 0x80000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs cmsdk_socket/axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x80010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs cmsdk_socket/axi_gpio_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x80020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs cmsdk_socket/axi_stream_io_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x80030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs cmsdk_socket/axi_stream_io_1/S_AXI/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

#create_root_design ""


