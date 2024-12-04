#-----------------------------------------------------------------------------
# NanoSoC Bus Matrix Generation Makefile 
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright � 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

.DEFAULT_GOAL := build

# Name of Bus Matrix to generate
MATRIX_NAME ?= nanosoc

# Top-level directory of Bus Matrix
BUILD_DIR  ?= $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/nanosoc_busmatrix

# Directory location of BuildBusMatrix Script
SOURCE_DIR  = $(ARM_IP_LIBRARY_PATH)/latest/Corstone-101/logical/cmsdk_ahb_busmatrix

# Location of Generation Files
IPXACT_BUILD_DIR   = $(BUILD_DIR)/ipxact
VERILOG_BUILD_DIR  = $(BUILD_DIR)/verilog

# Location of Source Files
IPXACT_SOURCE_DIR   = $(SOURCE_DIR)/ipxact/src
VERILOG_SOURCE_DIR  = $(SOURCE_DIR)/verilog/src

# Location of Bus Matrix XML
XML_DIR      = $(BUILD_DIR)/xml

# Location of Generation Logs
LOGS_DIR     = $(BUILD_DIR)/logs

# BuildBusMatrix Script File Options
XML_OPTIONS     = -xmldir $(XML_DIR) -cfg $(MATRIX_NAME).xml
VERILOG_OPTIONS = -srcdir=$(VERILOG_SOURCE_DIR) -tgtdir=$(VERILOG_BUILD_DIR)
IPXACT_OPTIONS  = -ipxact -ipxactsrcdir=$(IPXACT_SOURCE_DIR) -ipxacttgtdir=$(IPXACT_BUILD_DIR)

GEN_OPTIONS  = -notimescales -over -verbose $(XML_OPTIONS) $(VERILOG_OPTIONS) $(IPXACT_OPTIONS)  >& $(LOGS_DIR)/$(MATRIX_NAME).log

build: 
	@echo "Generating NanoSoC Bus Matrix"
	@mkdir -p $(LOGS_DIR)
	@mkdir -p $(IPXACT_BUILD_DIR)
	@mkdir -p $(VERILOG_BUILD_DIR)
	@cd $(SOURCE_DIR) && bin/BuildBusMatrix.pl $(GEN_OPTIONS)