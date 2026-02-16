
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
##set scripts_vivado_version 2024.1
##set current_vivado_version [version -short]

##if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
##   puts ""
##   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
##      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

##   } else {
##     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

##   }

##   return 1
##}

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
   create_project project_1 myproj -part xc7z020clg400-1
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
xilinx.com:ip:processing_system7:5.5\
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
  connect_bd_net -net p1_z [get_bd_pins p1_tri_z] [get_bd_pins axi_gpio_1/gpio2_io_i] [get_bd_pins p1_z6to0/Din]
  connect_bd_net -net pmod_i_6to0 [get_bd_pins pmoda_6to0/Dout] [get_bd_pins pmod_I_8/In0]
  connect_bd_net -net pmod_i_8 [get_bd_pins pmod_I_8/dout] [get_bd_pins rpi_p0_o/Op2]
  connect_bd_net -net pmod_tri_o [get_bd_pins pmoda_mux_o/Res] [get_bd_pins pmoda_tri_o]
  connect_bd_net -net pmod_tri_z [get_bd_pins pmoda_mux_z/Res] [get_bd_pins pmoda_tri_z]
  connect_bd_net -net pmoda_concat_o_dout [get_bd_pins pmoda_concat_o/dout] [get_bd_pins rpi_extio_o/Op2]
  connect_bd_net -net pmoda_concat_z_dout [get_bd_pins pmoda_concat_z/dout] [get_bd_pins rpi_extio_z/Op1]
  connect_bd_net -net pmoda_i_bit7_rpimode1_Dout [get_bd_pins p1_o15to8/Dout] [get_bd_pins gpio1_concat_i/In1]
  connect_bd_net -net pmoda_tri_i_1 [get_bd_pins pmoda_tri_i] [get_bd_pins pmoda_6to0/Din] [get_bd_pins pmoda_i_bit7_notrpimode/Din]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_gpio_1/s_axi_aresetn] [get_bd_pins axi_stream_io_0/S_AXI_ARESETN] [get_bd_pins axi_stream_io_1/S_AXI_ARESETN] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins axis_data_fifo_1/s_axis_aresetn] [get_bd_pins extio8x4_axis_target_0/resetn] [get_bd_pins smartconnect_0/aresetn]
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
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_gpio_1/s_axi_aclk] [get_bd_pins axi_stream_io_0/S_AXI_ACLK] [get_bd_pins axi_stream_io_1/S_AXI_ACLK] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins axis_data_fifo_1/s_axis_aclk] [get_bd_pins extio8x4_axis_target_0/clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins smartconnect_0/aclk]
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
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]


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

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
   CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
   CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
   CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {25.000000} \
   CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_CLK0_FREQ {25000000} \
   CONFIG.PCW_CLK1_FREQ {10000000} \
   CONFIG.PCW_CLK2_FREQ {10000000} \
   CONFIG.PCW_CLK3_FREQ {10000000} \
   CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
   CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
   CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
   CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
   CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {8} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {8} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {25} \
   CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK1_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
   CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {25} \
   CONFIG.PCW_IOPLL_CTRL_FBDIV {48} \
   CONFIG.PCW_IO_IO_PLL_FREQMHZ {1600.000} \
   CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {8} \
   CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
 ] $processing_system7_0


  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins cmsdk_socket/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]

  # Create port connections
  connect_bd_net -net cmsdk_socket_nrst [get_bd_pins cmsdk_socket/nrst] [get_bd_pins nanosoc_chip_0/nrst_i]
  connect_bd_net -net cmsdk_socket_p0_tri_i [get_bd_pins cmsdk_socket/p0_tri_i] [get_bd_pins nanosoc_chip_0/p0_i]
  connect_bd_net -net cmsdk_socket_p1_tri_i [get_bd_pins cmsdk_socket/p1_tri_i] [get_bd_pins nanosoc_chip_0/p1_i]
  connect_bd_net -net cmsdk_socket_swdclk_i [get_bd_pins cmsdk_socket/swdclk_i] [get_bd_pins nanosoc_chip_0/swdclk_i]
  connect_bd_net -net cmsdk_socket_swdio_i [get_bd_pins cmsdk_socket/swdio_tri_i] [get_bd_pins nanosoc_chip_0/swdio_i]
  connect_bd_net -net p0_tri_o_1 [get_bd_pins nanosoc_chip_0/p0_o] [get_bd_pins cmsdk_socket/p0_tri_o]
  connect_bd_net -net p0_tri_z_1 [get_bd_pins nanosoc_chip_0/p0_z] [get_bd_pins cmsdk_socket/p0_tri_z]
  connect_bd_net -net p1_tri_o_1 [get_bd_pins nanosoc_chip_0/p1_o] [get_bd_pins cmsdk_socket/p1_tri_o]
  connect_bd_net -net p1_tri_z_1 [get_bd_pins nanosoc_chip_0/p1_z] [get_bd_pins cmsdk_socket/p1_tri_z]
  connect_bd_net -net pmoda_i_1 [get_bd_ports pmoda_tri_i] [get_bd_pins cmsdk_socket/pmoda_tri_i]
  connect_bd_net -net pmoda_o_concat9_dout [get_bd_pins cmsdk_socket/pmoda_tri_z] [get_bd_ports pmoda_tri_z]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins cmsdk_socket/ext_reset_in]
  connect_bd_net -net swdio_tri_o_1 [get_bd_pins nanosoc_chip_0/swdio_o] [get_bd_pins cmsdk_socket/swdio_tri_o]
  connect_bd_net -net swdio_tri_z_1 [get_bd_pins nanosoc_chip_0/swdio_z] [get_bd_pins cmsdk_socket/swdio_tri_z]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins cmsdk_socket/pmoda_tri_o] [get_bd_ports pmoda_tri_o]
  connect_bd_net -net xlconstant_zero_dout [get_bd_pins xlconstant_zero/dout] [get_bd_pins nanosoc_chip_0/diag_mode] [get_bd_pins nanosoc_chip_0/diag_ctrl] [get_bd_pins nanosoc_chip_0/scan_mode] [get_bd_pins nanosoc_chip_0/scan_enable] [get_bd_pins nanosoc_chip_0/bist_mode] [get_bd_pins nanosoc_chip_0/bist_enable] [get_bd_pins nanosoc_chip_0/alt_mode] [get_bd_pins nanosoc_chip_0/uart_rxd_i] [get_bd_pins nanosoc_chip_0/swd_mode] [get_bd_pins nanosoc_chip_0/test_i]
  connect_bd_net -net xlconstant_zerox4_dout [get_bd_pins xlconstant_zerox4/dout] [get_bd_pins nanosoc_chip_0/scan_in] [get_bd_pins nanosoc_chip_0/bist_in]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0 [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins cmsdk_socket/aclk] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins nanosoc_chip_0/clk_i]

  # Create address segments
  assign_bd_address -offset 0x41200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs cmsdk_socket/axi_gpio_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x41210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs cmsdk_socket/axi_gpio_1/S_AXI/Reg] -force
  assign_bd_address -offset 0x43C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs cmsdk_socket/axi_stream_io_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x43C10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs cmsdk_socket/axi_stream_io_1/S_AXI/Reg] -force


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


