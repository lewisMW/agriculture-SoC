#-----------------------------------------------------------------------------
# SoCDebug FPGA Flow Makefile 
# - Used for Packaging Up Socket IP
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

IMPLEMENTATION_DIR   ?= $(SOCLABS_PROJECT_DIR)/imp/fpga
IMP_SOCKET_DIR       ?= $(IMPLEMENTATION_DIR)/socket
RTL_SOCKET_DIR       ?= $(SOCLABS_SOCDEBUG_TECH_DIR)/socket/vivado_packages

# Temporary Make recipies until actual package flow for components is implemented
package_adp_control:
	@echo Packaging Uart To AXI Master
	@mkdir -p $(IMP_SOCKET_DIR)
	@cp -r $(RTL_SOCKET_DIR)/ADPcontrol_1.0 $(IMP_SOCKET_DIR)/ADPcontrol_1.0

package_extio_control:
	@echo Packaging Uart To AXI Master
	@mkdir -p $(IMP_SOCKET_DIR)
	@cp -r $(RTL_SOCKET_DIR)/extio8x4_axis_target_1.0 $(IMP_SOCKET_DIR)/extio8x4_axis_target_1.0
	
package_axi_stream_io:
	@echo Packaging Uart To AXI Master
	@mkdir -p $(IMP_SOCKET_DIR)
	@cp -r $(RTL_SOCKET_DIR)/axi_stream_io_1.0 $(IMP_SOCKET_DIR)/axi_stream_io_1.0
	
package_ft1248_to_stream:
	@echo Packaging FT1248 to AXI Stream
	@mkdir -p $(IMP_SOCKET_DIR)
	@cp -r $(RTL_SOCKET_DIR)/ft1248x1_to_axi_streamio_1.0 $(IMP_SOCKET_DIR)/ft1248x1_to_axi_streamio_1.0
	
package_uart_to_axi:
	@echo Packaging Uart To AXI Master
	@mkdir -p $(IMP_SOCKET_DIR)
	@cp -r $(RTL_SOCKET_DIR)/uart_to_AXI_master_1.0 $(IMP_SOCKET_DIR)/uart_to_AXI_master_1.0

package_socket: clean_socket package_uart package_ft1248_to_stream package_axi_stream_io package_adp_control package_extio_control
# package_socket: clean_socket package_uart package_f232h package_streamio package_adp_control

clean_socket:
	@echo Cleaning FPGA Implementation Socket Directory
	@rm -rf $(IMP_SOCKET_DIR)


# UART Packaging
UART_FLIST := $(SOCLABS_SOCDEBUG_TECH_DIR)/flist/uart_axi_master_ip.flist

IMPLEMENTATION_DIR   ?= $(SOCLABS_PROJECT_DIR)/imp/fpga
RUN_DIR              := $(IMPLEMENTATION_DIR)/run
IMP_SOCKET_DIR       := $(IMPLEMENTATION_DIR)/socket



UART_IMP_DIR              := $(IMP_SOCKET_DIR)/uart_axi_master
UART_TCL_FLIST_DIR        := $(UART_IMP_DIR)/flist
UART_TCL_OUTPUT_FILELIST  := $(UART_TCL_FLIST_DIR)/gen_flist.tcl

UART_TOP        := uart_axi_master
UART_VENDOR     := ultraembedded
UART_CORE_REV   ?= 1


flist_uart:
	@mkdir -p $(UART_TCL_FLIST_DIR)
	@(cd $(TCL_FLIST_DIR); \
	$(SOCLABS_SOCTOOLS_FLOW_DIR)/bin/filelist_compile.py -t -f $(UART_FLIST) -o $(UART_TCL_OUTPUT_FILELIST) -r $(UART_IMP_DIR)/src;)
	
# Environment Variables for Packaging UART to AXI Master
package_uart: export FPGA_COMPONENT_FILELIST = $(UART_TCL_OUTPUT_FILELIST)
package_uart: export FPGA_COMPONENT_LIB      = $(UART_IMP_DIR)
package_uart: export FPGA_COMPONENT_TOP      = $(UART_TOP)
package_uart: export FPGA_VENDOR             = $(UART_VENDOR)
package_uart: export FPGA_CORE_REV           = $(UART_CORE_REV)
	
# Package UART to AXI Master IP
package_uart: flist_uart
	@echo Packaging UART to AXI Master Component
	@mkdir -p $(RUN_DIR)
	@cd $(RUN_DIR); vivado -mode batch -source $(SOCLABS_SOCTOOLS_FLOW_DIR)/resources/fpga/package_component.tcl
	@mkdir -p $(UART_IMP_DIR)/logs
	@cp $(RUN_DIR)/vivado.log $(UART_IMP_DIR)/logs
	@echo UART to AXI Master Packaged

# F232H Emulator Packaging
F232H_FLIST    := $(SOCLABS_SOCDEBUG_TECH_DIR)/flist/f232h_ft1248_stream_ip.flist
F232H_IMP_DIR  := $(IMP_SOCKET_DIR)/f232h_ft1248_stream

F232H_TCL_FLIST_DIR        := $(F232H_IMP_DIR)/flist
F232H_TCL_OUTPUT_FILELIST  := $(F232H_TCL_FLIST_DIR)/gen_flist.tcl

F232H_TOP                  := f232h_ft1248_stream
F232H_VENDOR               := soclabs.org
F232H_CORE_REV             ?= 1

flist_f232h:
	@mkdir -p $(F232H_TCL_FLIST_DIR)
	@(cd $(F232H_TCL_FLIST_DIR); \
	$(SOCLABS_SOCTOOLS_FLOW_DIR)/bin/filelist_compile.py -t -f $(F232H_FLIST) -o $(F232H_TCL_OUTPUT_FILELIST) -r $(F232H_IMP_DIR)/src;)
	
# Environment Variables for Packaging F232H Emulator
package_f232h: export FPGA_COMPONENT_FILELIST = $(F232H_TCL_OUTPUT_FILELIST)
package_f232h: export FPGA_COMPONENT_LIB      = $(F232H_IMP_DIR)
package_f232h: export FPGA_COMPONENT_TOP      = $(F232H_TOP)
package_f232h: export FPGA_VENDOR             = $(F232H_VENDOR)
package_f232h: export FPGA_CORE_REV           = $(F232H_CORE_REV)
	
# Package F232H Emulator IP
package_f232h: flist_f232h
	@echo Packaging F232H FT1248 to AXI Stream Component
	@mkdir -p $(RUN_DIR)
	@cd $(RUN_DIR); vivado -mode batch -source $(SOCLABS_SOCTOOLS_FLOW_DIR)/resources/fpga/package_component.tcl
	@mkdir -p $(F232H_IMP_DIR)/logs
	@cp $(RUN_DIR)/vivado.log $(F232H_IMP_DIR)/logs
	@echo F232H FT1248 to AXI Stream Packaged
	
# AXI Stream IO Packaging
STREAMIO_FLIST    := $(SOCLABS_SOCDEBUG_TECH_DIR)/flist/axi_stream_io_ip.flist
STREAMIO_IMP_DIR  := $(IMP_SOCKET_DIR)/axi_stream_io

STREAMIO_TCL_FLIST_DIR        := $(STREAMIO_IMP_DIR)/flist
STREAMIO_TCL_OUTPUT_FILELIST  := $(STREAMIO_TCL_FLIST_DIR)/gen_flist.tcl

STREAMIO_TOP                  := axi_stream_io
STREAMIO_VENDOR               := soclabs.org
STREAMIO_CORE_REV             ?= 1

flist_streamio:
	@mkdir -p $(STREAMIO_TCL_FLIST_DIR)
	@(cd $(STREAMIO_TCL_FLIST_DIR); \
	$(SOCLABS_SOCTOOLS_FLOW_DIR)/bin/filelist_compile.py -t -f $(STREAMIO_FLIST) -o $(STREAMIO_TCL_OUTPUT_FILELIST) -r $(STREAMIO_IMP_DIR)/src;)
	
# Environment Variables for Packaging NanoSoC
package_streamio: export FPGA_COMPONENT_FILELIST = $(STREAMIO_TCL_OUTPUT_FILELIST)
package_streamio: export FPGA_COMPONENT_LIB      = $(STREAMIO_IMP_DIR)
package_streamio: export FPGA_COMPONENT_TOP      = $(STREAMIO_TOP)
package_streamio: export FPGA_VENDOR             = $(STREAMIO_VENDOR)
package_streamio: export FPGA_CORE_REV           = $(STREAMIO_CORE_REV)
	
# Package NanoSoC IP
package_streamio: flist_streamio
	@echo Packaging AXI Stream Interface Component
	@mkdir -p $(RUN_DIR)
	@cd $(RUN_DIR); vivado -mode batch -source $(SOCLABS_SOCTOOLS_FLOW_DIR)/resources/fpga/package_component.tcl
	@mkdir -p $(STREAMIO_IMP_DIR)/logs
	@cp $(RUN_DIR)/vivado.log $(STREAMIO_IMP_DIR)/logs
	@echo AXI Stream Interface Packaged
	
# AXI Stream IO Packaging
ADP_MANAGER_FLIST    := $(SOCLABS_SOCDEBUG_TECH_DIR)/flist/axi_stream_io_ip.flist
ADP_MANAGER_IMP_DIR  := $(IMP_SOCKET_DIR)/axi_stream_io

ADP_MANAGER_TCL_FLIST_DIR        := $(ADP_MANAGER_IMP_DIR)/flist
ADP_MANAGER_TCL_OUTPUT_FILELIST  := $(ADP_MANAGER_TCL_FLIST_DIR)/gen_flist.tcl

ADP_MANAGER_TOP                  := axi_stream_io
ADP_MANAGER_VENDOR               := soclabs.org
ADP_MANAGER_CORE_REV             ?= 1

flist_adp_manager:
	@mkdir -p $(ADP_MANAGER_TCL_FLIST_DIR)
	@(cd $(ADP_MANAGER_TCL_FLIST_DIR); \
	$(SOCLABS_SOCTOOLS_FLOW_DIR)/bin/filelist_compile.py -t -f $(ADP_MANAGER_FLIST) -o $(ADP_MANAGER_TCL_OUTPUT_FILELIST) -r $(ADP_MANAGER_IMP_DIR)/src;)
	
# Environment Variables for Packaging NanoSoC
package_adp_manager: export FPGA_COMPONENT_FILELIST = $(ADP_MANAGER_TCL_OUTPUT_FILELIST)
package_adp_manager: export FPGA_COMPONENT_LIB      = $(ADP_MANAGER_IMP_DIR)
package_adp_manager: export FPGA_COMPONENT_TOP      = $(ADP_MANAGER_TOP)
package_adp_manager: export FPGA_VENDOR             = $(ADP_MANAGER_VENDOR)
package_adp_manager: export FPGA_CORE_REV           = $(ADP_MANAGER_CORE_REV)
	
# Package NanoSoC IP
package_adp_manager: flist_adp_manager
	@echo Packaging AXI Stream Interface Component
	@mkdir -p $(RUN_DIR)
	@cd $(RUN_DIR); vivado -mode batch -source $(SOCLABS_SOCTOOLS_FLOW_DIR)/resources/fpga/package_component.tcl
	@mkdir -p $(ADP_MANAGER_IMP_DIR)/logs
	@cp $(RUN_DIR)/vivado.log $(ADP_MANAGER_IMP_DIR)/logs
	@echo AXI Stream Interface Packaged
